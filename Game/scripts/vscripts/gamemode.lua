if GameMode == nil then
    _G.GameMode = class({})
end

require('libraries/timers')
require('libraries/physics')
require('libraries/projectiles')
require('libraries/notifications')
require('libraries/animations')
require('libraries/attachments')

require('internal/gamemode')
require('internal/events')

require('settings')
require('events')
require("helper_functions")

require("constants")
require("roles")
require("modifiers")
require("ability_helpers")

if roles == nil then
  roles = {}
end
votes = {}
current_stage = STAGE_DAY
current_cycle = 1

pre_resolution_stack = {}
night_actions = {}

ability_data = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function GameMode:PostLoadPrecache()
end

function GameMode:OnFirstPlayerLoaded()
end

function GameMode:OnAllPlayersLoaded()
  local setup = { "goon", "goon", "townie", "townie", "townie", "cop", "doctor" }
  -- Distribute roles randomly
  for _,player in pairs(GetPlayersOnTeam(DOTA_TEAM_GOODGUYS)) do
    -- WHY DOESN'T LUA HAVE ARRAYS???
    local role
    local rolenum
    repeat
      rolenum = RandomInt(1,#setup)
      role = setup[rolenum]
    until role ~= "taken" or (#setup == 0)
    roles[player] = role
    setup[rolenum] = "taken"
    player:MakeRandomHeroSelection()
  end
  PrintTable(roles)
end

function GameMode:OnHeroInGame(hero)
  -- Remove this hero's standard abilities.
  for i = 0,hero:GetAbilityCount() - 1 do
    if hero:GetAbilityByIndex(i) then
      hero:RemoveAbility(hero:GetAbilityByIndex(i):GetAbilityName())
    end
  end

  if roles[hero:GetPlayerOwner()] then
    -- Grant the vote ability
    hero:AddAbility("vote"):SetLevel(1)
    -- Grant other abilities to this hero as appropriate
    for k,ability in pairs(ROLE_DEFINITIONS[roles[hero:GetPlayerOwner()]].abilities) do
      hero:AddAbility(ability):SetLevel(1)
    end
  end
end

function GameMode:OnGameInProgress()
  for k,hero in pairs(HeroList:GetAllHeroes()) do
    GameMode:OnHeroInGame(hero)
  end
end

function GameMode:InitGameMode()
  GameMode = self
  GameMode:_InitGameMode()
  Convars:RegisterCommand( "test", Dynamic_Wrap(GameMode, 'Test'), "Test", FCVAR_CHEAT )
  Convars:RegisterCommand( "eval", Dynamic_Wrap(GameMode, 'Eval'), "Eval", FCVAR_CHEAT )
  Convars:RegisterCommand( "update_abilities", Dynamic_Wrap(GameMode, 'UpdateAbilities'), "Update abilities", FCVAR_CHEAT )
end

function GameMode:Test()
  --local player = PlayerResource:GetPlayer(0)
  --night_actions[player] = player:GetAssignedHero():FindAbilityByName("mafia_kill")
  GameMode:EnterDawn(0)
end

function GameMode:Eval(string)
  print("Evaluating: " .. string)
  local f = loadstring(string)
  print(f())
end

function GameMode:UpdateAbilities()
  SendToConsole("script_reload")
  SendToConsole("cl_script_reload")
  for k,hero in pairs(HeroList:GetAllHeroes()) do
    PlayerResource:ReplaceHeroWith(hero:GetPlayerID(), hero:GetClassname(), PlayerResource:GetGold(hero:GetPlayerID()), hero:GetCurrentXP())
    hero:Destroy()
  end
end

function GameMode:ChangeVote(player, target)
  votes[player] = target
  CustomGameEventManager:Send_ServerToAllClients("update_votes", {votes = votes})

  -- See if we have reached a lynch
  local living_player_count = 0
  for player,role in pairs(roles) do
    if player:GetAssignedHero():IsAlive() then
      living_player_count = living_player_count + 1
    end
  end
  local votes_to_lynch = math.ceil(living_player_count / 2)
  if votes_to_lynch == living_player_count / 2 then
    votes_to_lynch = votes_to_lynch + 1
  end
  print(living_player_count .. " alive, " .. votes_to_lynch .. " to lynch")
  PrintTable(votes)
  vote_counts = {}
  for voter,vote in pairs(votes) do
    if vote_counts[vote] then
      vote_counts[vote] = vote_counts[vote] + 1
    else
      vote_counts[vote] = 1
    end
    if vote_counts[vote] >= votes_to_lynch then
      GameMode:ChangeStage(STAGE_TWILIGHT, current_cycle, {lynchee = vote})
      break
    end
  end
end

function GameMode:ChangeStage(stage, cycle, options)
  print("Changing stage to " .. stage)
  CustomGameEventManager:Send_ServerToAllClients("stage_change", {stage = stage, cycle = cycle, options = options})
  current_stage = stage
  current_cycle = cycle
  if stage == STAGE_TWILIGHT then
    GameMode:EnterTwilight(options.lynchee)
  elseif stage == STAGE_NIGHT then
    GameMode:EnterNight()
  elseif stage == STAGE_DAWN then
    GameMode:EnterDawn()
  elseif stage == STAGE_DAY then
    GameMode:EnterDay()
  end
end

function GameMode:EnterTwilight(lynchee)
  if lynchee then
    CustomGameEventManager:Send_ServerToAllClients("player_will_be_lynched", {lynchee = lynchee})
    print("Lynching " .. tostring(lynchee))
    Timers:CreateTimer("primary_timer", {
      endTime = STAGE_LENGTH_TWILIGHT, 
      callback = function()
        lynchee:GetAssignedHero():ForceKill(false)
        Timers:CreateTimer("primary_timer", {
          endTime = 5,
          callback = function()
            GameMode:ChangeStage(STAGE_NIGHT, current_cycle)
          end
        })
      end
    })
  else
    CustomGameEventManager:Send_ServerToAllClients("no_lynch", {})
    Timers:CreateTimer("primary_timer", {
      endTime = STAGE_LENGTH_TWILIGHT,
      callback = function()
        GameMode:ChangeStage(STAGE_NIGHT, current_cycle)
      end
    })
  end
  GameRules:SetTimeOfDay(0)
end

function GameMode:EnterNight()
  GameRules:SetTimeOfDay(0)
  pre_resolution_stack = {}
  night_actions = {}
  -- Wait for night actions.

  Timers:CreateTimer("primary_timer", {
    endTime = STAGE_LENGTH_NIGHT, 
    callback = function()
      GameMode:ChangeStage(STAGE_DAWN, current_cycle + 1)
    end
  })
end

function GameMode:EnterDawn()
  GameRules:SetTimeOfDay(0.5)
  -- Action resolution begins.
  -- Start by adding things on the pre-resolution stack (mainly factional kills) to the night actions table.
  for name,details in pairs(pre_resolution_stack) do
    if name == "mafia_kill" then
      night_actions[details.killer] = details.ability
    end
  end

  local events = {}
  local results = {}

  -- This action resolution basically adheres to Natural Action Resolution:
  -- http://wiki.mafiascum.net/index.php?title=Natural_Action_Resolution

  -- Loop through night actions... possibly several times depending on the complexity of the setup.
  while next(night_actions) do
    print("Top level while loop")
    local actions_checked = 0
    local actions_skipped = 0
    -- Loop through each night action.
    for player,ability in pairs(night_actions) do
      print("Main loop through actions")
      print("Checking " .. player:GetPlayerID() .. "'s use of " .. ability:GetName())
      actions_checked = actions_checked + 1
      -- Configure skip types based on the action being checked.
      -- For example, if we're checking to resolve a kill, we need to make sure that there is not a pending
      -- protect action on its target that hasn't been resolved. We also need to make sure that there aren't pending
      -- blocks, redirects, or other relevant acitons on the actor.
      local skip = false
      local skip_if_pending_on_actor = {ACTION_TYPE_BLOCK = true}
      local skip_if_pending_on_target = {}
      if ability.action_types[ACTION_TYPE_KILL] then
        skip_if_pending_on_target[ACTION_TYPE_PROTECT] = true
      end
      if ability.action_types[ACTION_TYPE_BLOCK] then
        skip_if_pending_on_target[ACTION_TYPE_BLOCK] = nil
      end
      
      -- Skip this action if the target has one of the skip types we decided on above.
      for actiontype,v in pairs(skip_if_pending_on_target) do
        for pplayer,pability in pairs(night_actions) do
          if pability.target == ability.target and pability.action_types[actiontype] then
            skip = true
          end
        end
      end

      -- Skip this action if the actor has one of the skip types we decided on above.
      for actiontype,v in pairs(skip_if_pending_on_actor) do
        for pplayer,pability in pairs(night_actions) do
          if pability.target == player and pability.action_types[actiontype] then
            skip = true
          end
        end
      end

      if not skip then
        print("Resolving this action")
        -- Resolve action, first checking to be sure that we aren't roleblocked.
        if not player:GetAssignedHero():HasModifier("modifier_roleblocked") or ability_data[ability].IsUnblockable then
          local resolution = ability:Resolve()  -- Defined in each ability.
          if resolution then
            print("Received resolution:")
            PrintTable(resolution)
            -- Three possible kinds of resolutions:
            -- RESOLUTION_TYPE_RESULT -- displayed to a single player at the start of the day, e.g. investigate
            -- RESOLUTION_TYPE_EVENT -- displayed publicly at the start of the day, e.g. nightkill
            -- Nothing -- displays nothing (but doesn't necessarily do nothing!), e.g. protect
            if resolution.type == RESOLUTION_TYPE_RESULT then
              if results[player] then
                table.insert(results[player], resolution.info)
              else
                results[player] = {resolution.event}
              end
            else
              table.insert(events, resolution.followthrough)
            end
          end
        else
          -- This action was blocked; but, if it was an action that returns a result, we still need to send
          -- a "no result" result to the actor.
          if ability.inform_on_failure then
            if results[player] then
              table.insert(results[player], {eventname = "no_result", eventinfo = {}})
            else
              results[player] = {{eventname = "no_result", eventinfo = {}}}
            end
          end
        end
        night_actions[player] = nil
      else
        print("Skipping this action due to other pending actions that potentially affect it")
        actions_skipped = actions_skipped + 1
      end
    end

    -- If we skipped every action due to other pending actions, we've found our way into an infinite loop.
    -- We need to fall back on a hard-coded order of actions.
    if actions_checked == actions_skipped then
      -- TODO: Tiebreaker resolution
      break
    end
  end
  print("==========")
  print("Events:")
  PrintTable(events)
  print("Results:")
  PrintTable(results)
  print("==========")

  -- Send results to players.
  for player,tbl in pairs(results) do
    for _,result in pairs(tbl) do
      CustomGameEventManager:Send_ServerToPlayer(player, result.eventname, result.eventinfo)
    end
  end

  Timers:CreateTimer("primary_timer", {
    endTime = STAGE_LENGTH_DAWN,
    callback = function()
      if next(events) then
        -- Show events (mostly nightkills).
        for k,event in pairs(events) do
          event()
          events[k] = nil
          return 5
        end
      else
        -- Cock a doodle doo!
        GameMode:ChangeStage(STAGE_DAY, current_cycle)
      end
    end
  })
end

function GameMode:EnterDay()
  GameRules:SetTimeOfDay(0.25)
  votes = {}
  Timers:CreateTimer("primary_timer", {
    endTime = STAGE_LENGTH_DAY,
    callback = function()
      GameMode:ChangeStage(STAGE_TWILIGHT, current_cycle, {})
    end
  })
end

function GameMode:GetPlayersByAlignment(include_dead)
  local players = {}
  for player,role in pairs(roles) do
    local align = ROLE_DEFINITIONS[role].alignment
    if player:GetAssignedHero():IsAlive() or include_dead then
      if players[align] then
        table.insert(players[align], player)
      else
        players[align] = {player}
      end
    end
  end
  return players
end

function GameMode:GetAllPlayersWithAlignment(alignment, include_dead)
  local players = {}
  for player,role in pairs(roles) do
    if ROLE_DEFINITIONS[role].alignment == alignment and (include_dead or player:GetAssignedHero():IsAlive()) then
      table.insert(players, player)
    end
  end
  return players
end

function GameMode:GetPlayerAlignment(player)
  return ROLE_DEFINITIONS[roles[player]].alignment
end

function GameMode:CheckVictory()
  local alignments = GameMode:GetPlayersByAlignment(false)
  if not alignments[ALIGNMENT_MAFIA] then
    print("Town wins!")
  else
    local total_living = 0
    local counts = {}
    for alignment,players in pairs(alignments) do
      for k,player in pairs(players) do
        if counts[alignment] then
          counts[alignment] = counts[alignment] + 1
        else
          counts[alignment] = 1
        end
        total_living = total_living + 1
      end
    end
    if counts[ALIGNMENT_MAFIA] >= total_living / 2 then
      print("Mafia wins!")
    end
  end
end