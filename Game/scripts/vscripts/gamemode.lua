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
require("setup_generator")

if roles == nil then
  roles = {}
end
votes = {}
if not current_stage then current_stage = STAGE_DAY end
if not current_cycle then current_cycle = 1 end

pre_resolution_stack = {}
night_actions = {}
resolved_targets = {}
starting_locations = {}
factional_target_particles = {}

ability_data = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

TEST_ROLE = "ironskinned_townie"

function GameMode:PostLoadPrecache()
end

function GameMode:OnFirstPlayerLoaded()
end

function GameMode:OnAllPlayersLoaded()
  local setup = GenerateSetup(PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS))
  -- Distribute roles randomly
  local player_count = 0
  for _,player in pairs(GetPlayersOnTeam(DOTA_TEAM_GOODGUYS)) do
    -- WHY DOESN'T LUA HAVE ARRAYS???
    player_count = player_count + 1
    local role
    local rolenum
    repeat
      rolenum = RandomInt(1,#setup)
      role = setup[rolenum]
    until role ~= "taken"
    roles[player] = role
    if player:GetPlayerID() == 0 and TEST_ROLE and Convars:GetBool("developer") then
      roles[player] = TEST_ROLE
    end
    setup[rolenum] = "taken"
    CustomGameEventManager:Send_ServerToPlayer(player, "distribute_role", {role = role, alignment = ROLE_DEFINITIONS[role].alignment})
  end

  -- Determine start positions
  local center = Vector(0,0,0)
  local radius = 600
  local start = RandomFloat(0, 2 * math.pi)   -- Randomize the orientation of the circle
  for k = 0,player_count - 1 do
    local x = center.x + radius * math.cos(start + 2 * k * math.pi / player_count)
    local y = center.y + radius * math.sin(start + 2 * k * math.pi / player_count)
    starting_locations[k] = Vector(x, y, 0)
  end

  local nolynch = CreateUnitByName("no_lynch_target", Vector(100, 0, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
  nolynch:AddNewModifier(nil, nil, "modifier_no_lynch_target", {})
end

function GameMode:OnHeroInGame(hero)
  PlayerResource:SetOverrideSelectionEntity(hero:GetPlayerOwnerID(), hero)  -- thank you based Noya for suggesting the use of this function.
  -- Remove this hero's standard abilities.
  for i = 0,hero:GetAbilityCount() - 1 do
    if hero:GetAbilityByIndex(i) then
      hero:RemoveAbility(hero:GetAbilityByIndex(i):GetAbilityName())
    end
  end

  if roles[hero:GetPlayerOwner()] then
    -- Grant the vote ability
    hero:AddAbility("vote"):SetLevel(1)
    hero:AddAbility("unvote"):SetLevel(1)
    hero:SetAbilityPoints(0)
    -- Grant other abilities to this hero as appropriate
    for k,ability in pairs(ROLE_DEFINITIONS[roles[hero:GetPlayerOwner()]].abilities) do
      hero:AddAbility(ability):SetLevel(1)
      if ability_data[ability].HasLimitedUses then
        hero:FindAbilityByName(ability).uses_left = tonumber(ability_data[ability].HasLimitedUses)
      end
    end
    Timers:CreateTimer(0.03, function()
      local origin = starting_locations[hero:GetPlayerOwnerID()]
      hero:SetAbsOrigin(origin)
      hero:SetForwardVector(origin:Normalized() * Vector(-1, -1, 0))
    end)
  end

  hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
end

function GameMode:OnGameInProgress()
  for _,player in pairs(GetPlayersOnTeam(DOTA_TEAM_GOODGUYS)) do
    if PlayerResource:GetSteamAccountID(player:GetPlayerID()) == 0 then     -- Bots
      local heroname = PlayerResource:GetSelectedHeroName(player:GetPlayerID())
      local oldhero = player:GetAssignedHero()
      local replaced = PlayerResource:ReplaceHeroWith(player:GetPlayerID(), heroname, 0, 0)
      if not replaced then
        CreateHeroForPlayer(heroname, player)
      end
      oldhero:RemoveSelf()
    else
      player:MakeRandomHeroSelection()
    end
  end
  Timers:CreateTimer(5, function()
    GameMode:ChangeStage(STAGE_DAY, 1)
  end)
end

function GameMode:InitGameMode()
  GameMode = self
  GameMode:_InitGameMode()
  Convars:RegisterCommand( "test", Dynamic_Wrap(GameMode, 'Test'), "Test", FCVAR_CHEAT )
  Convars:RegisterCommand( "eval", Dynamic_Wrap(GameMode, 'Eval'), "Eval", FCVAR_CHEAT )
  Convars:RegisterCommand( "update_abilities", Dynamic_Wrap(GameMode, 'UpdateAbilities'), "Update abilities", FCVAR_CHEAT )
  Convars:RegisterCommand( "alohamora", Dynamic_Wrap(GameMode, 'UnlockSelection'), "wizard shit", FCVAR_CHEAT )
  Convars:RegisterCommand( "stage", Dynamic_Wrap(GameMode, 'ConsoleChangeStage'), "", FCVAR_CHEAT)
  Convars:RegisterCommand( "role", Dynamic_Wrap(GameMode, 'ConsoleChangeRole'), "", FCVAR_CHEAT)
  Convars:RegisterCommand( "gen", Dynamic_Wrap(GameMode, 'TestSetupGenerator'), "", FCVAR_CHEAT)

  CustomGameEventManager:RegisterListener("get_role", Dynamic_Wrap(GameMode, 'SendRoleToClient'))
end

function GameMode:TestSetupGenerator(players)
  if not players then players = 13 end
  PrintTable(GenerateSetup(tonumber(players)))
end

function GameMode:ConsoleChangeRole(role)
  roles[PlayerResource:GetPlayer(0)] = role
  GameMode:OnHeroInGame(PlayerResource:GetPlayer(0):GetAssignedHero())
  CustomGameEventManager:Send_ServerToPlayer(player, "distribute_role", {role = role, alignment = ROLE_DEFINITIONS[role].alignment})
end

function GameMode:ConsoleChangeStage(stage)
  GameMode:ChangeStage(tonumber(stage), current_cycle)
end

function GameMode:Test()
  p = ParticleManager:CreateParticle("particles/voteline.vpcf", PATTACH_ABSORIGIN_FOLLOW, PlayerResource:GetPlayer(0):GetAssignedHero())
  ParticleManager:SetParticleControl(p, 0, Vector(500,0,0)) 
  ParticleManager:SetParticleControl(p, 1, Vector(0,0,0)) 
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

function GameMode:UnlockSelection()
  PlayerResource:SetOverrideSelectionEntity(0, nil)
end

function GameMode:ChangeVote(player, target)
  votes[player] = target
  local votes_for_event = {}
  for player,vote in pairs(votes) do
    if vote == "no lynch" then
      votes_for_event[player:GetPlayerID()] = "no lynch"
    else
      votes_for_event[player:GetPlayerID()] = vote:GetPlayerID()
    end
  end
  CustomGameEventManager:Send_ServerToAllClients("update_votes", {votes = votes_for_event, votes_to_lynch = GameMode:GetVotesToLynch()})

  -- See if we have reached a lynch
  local votes_to_lynch = GameMode:GetVotesToLynch()
  vote_counts = {}
  for voter,vote in pairs(votes) do
    if vote_counts[vote] then
      vote_counts[vote] = vote_counts[vote] + 1
    else
      vote_counts[vote] = 1
    end
    if vote_counts[vote] >= votes_to_lynch then
      if vote == "no lynch" then
        CustomGameEventManager:Send_ServerToAllClients("no_lynch", {})
        GameMode:ChangeStage(STAGE_TWILIGHT, current_cycle, {})
      else
        CustomGameEventManager:Send_ServerToAllClients("player_will_be_lynched", {lynchee = vote:GetPlayerID(), votes = votes_for_event})
        GameMode:ChangeStage(STAGE_TWILIGHT, current_cycle, {lynchee = vote})
      end
      break
    end
  end
end

function GameMode:ChangeStage(stage, cycle, options)
  Timers:RemoveTimer("stage_tick_timer")
  last_stage_change = GameRules:GetGameTime()
  local stage_change_event = {stage = stage, cycle = cycle, options = options, votes_to_lynch = GameMode:GetVotesToLynch()}
  CustomGameEventManager:Send_ServerToAllClients("stage_change", stage_change_event)
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
    EmitGlobalSound("Mafia.Lynch_Bell")
    local hero = lynchee:GetAssignedHero()
    Timers:CreateTimer("primary_timer", {
      endTime = STAGE_LENGTH_TWILIGHT, 
      callback = function()
        CustomGameEventManager:Send_ServerToAllClients("begin_lynch", {})
        lynch_in_progress = true
        GameMode:FocusCameras(hero)
        StartSoundEvent("Hero_Necrolyte.ReapersScythe.Cast", hero)
        local p = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
        ParticleManager:SetParticleControl(p, 1, hero:GetAbsOrigin())
        ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)

        Timers:CreateTimer("primary_timer", {
          endTime = 1.5,
          callback = function()
            StartSoundEvent("Hero_Necrolyte.ReapersScythe.Target", hero)
            CustomGameEventManager:Send_ServerToAllClients("finish_lynch", {})
            hero:ForceKill(false)
            GameMode:FocusCameras(nil)

            Timers:CreateTimer(1.5, function() 
              CustomGameEventManager:Send_ServerToAllClients("flip_player", GameMode:GetFlip(lynchee:GetPlayerID()))
              CustomNetTables:SetTableValue("graveyard", tostring(lynchee:GetPlayerID()), {
                role = roles[lynchee],
                alignment = GameMode:GetPlayerAlignment(lynchee),
                death_type = "lynched",
                stage = STAGE_DAY,
                cycle = current_cycle
              })
            end)

            Timers:CreateTimer("primary_timer", {
              endTime = 8,
              callback = function()
                lynch_in_progress = nil
                GameMode:ChangeStage(STAGE_NIGHT, current_cycle)
              end
            })

          end
        })

      end
    })
  else
    Timers:CreateTimer("primary_timer", {
      endTime = STAGE_LENGTH_TWILIGHT,
      callback = function()
        GameMode:ChangeStage(STAGE_NIGHT, current_cycle)
      end
    })
  end
end

function GameMode:EnterNight()
  GameRules:SetTimeOfDay(0)
  pre_resolution_stack = {}
  night_actions = {}
  
  for k,hero in pairs(HeroList:GetAllHeroes()) do
    if hero:IsAlive() then
      hero:AddNewModifier(nil, nil, "modifier_sleeping", {})
    end
  end

  Timers:CreateTimer("stage_tick_timer", {
    endTime = 0.1,
    callback = function()
      CustomGameEventManager:Send_ServerToAllClients("stage_tick", {elapsed = GameRules:GetGameTime() - last_stage_change, duration = STAGE_LENGTH_NIGHT, stage = current_stage})
      return 0.1
    end
  })
  Timers:CreateTimer("primary_timer", {
    endTime = STAGE_LENGTH_NIGHT, 
    callback = function()
      GameMode:ChangeStage(STAGE_DAWN, current_cycle)
    end
  })
end

function GameMode:EnterDawn()
  GameRules:SetTimeOfDay(0.5)

  -- Clear particles
  for _,player in pairs(GetPlayersOnTeam(DOTA_TEAM_GOODGUYS)) do
    if player.target_particle then
      ParticleManager:DestroyParticle(player.target_particle, false)
      player.target_particle = nil
    end
  end
  for _,faction in pairs(factional_target_particles) do
    for _,particle in pairs(faction) do
      ParticleManager:DestroyParticle(particle, false)
    end
  end
  factional_target_particles = {}

  -- Action resolution begins.
  -- Start by adding things on the pre-resolution stack (mainly factional kills) to the night actions table.
  for name,details in pairs(pre_resolution_stack) do
    if name == "mafia_kill" then
      night_actions[details.killer] = details.ability
    end
  end

  -- Add intrinsic modifiers that might have been removed.
  for _,hero in pairs(HeroList:GetAllHeroes()) do
    for i = 0,hero:GetAbilityCount() - 1 do
      local ability = hero:GetAbilityByIndex(i)
      if ability then
        local intrinsic = ability:GetIntrinsicModifierName()
        if intrinsic and not hero:HasModifier(intrinsic) then
          hero:AddNewModifier(hero, hero:GetAbilityByIndex(i), intrinsic, {})
        end
      end
    end
  end

  local events = {}
  local results = {}
  local result_callbacks = {}

  -- This action resolution basically adheres to Natural Action Resolution:
  -- http://wiki.mafiascum.net/index.php?title=Natural_Action_Resolution

  -- Loop through night actions... possibly several times depending on the complexity of the setup.
  while next(night_actions) do
    --print("Top level while loop")
    local actions_checked = 0
    local actions_skipped = 0
    -- Loop through each night action.
    for player,ability in pairs(night_actions) do
      --print("Main loop through actions")
      --print("+ Checking " .. player:GetPlayerID() .. "'s use of " .. ability:GetName())
      actions_checked = actions_checked + 1
      -- Configure skip types based on the action being checked.
      -- For example, if we're checking to resolve a kill, we need to make sure that there is not a pending
      -- protect action on its target that hasn't been resolved. We also need to make sure that there aren't pending
      -- blocks, redirects, or other relevant acitons on the actor.
      local skip = false
      local skip_if_pending_on_actor = {[ACTION_TYPE_BLOCK] = true}
      local skip_if_pending_on_target = {}
      if ability.action_types[ACTION_TYPE_KILL] then
        skip_if_pending_on_target[ACTION_TYPE_PROTECT] = true
      end
      if ability.action_types[ACTION_TYPE_BLOCK] then
        skip_if_pending_on_actor[ACTION_TYPE_BLOCK] = nil
      end
      --print("+ Will skip if we find these types on actor:")
      --PrintTable(skip_if_pending_on_actor)
      --print("+ Will skip if we find these types on target:")
      --PrintTable(skip_if_pending_on_target)
      
      -- Skip this action if the target has one of the skip types we decided on above.
      for actiontype,v in pairs(skip_if_pending_on_target) do
        for pplayer,pability in pairs(night_actions) do
          if pability.target == ability.target and pability.action_types[actiontype] then
            skip = true
          end
        end
      end

      -- Skip this action if the actor has one of the skip types we decided on above.
      --print("+ Checking actor skips")
      for actiontype,v in pairs(skip_if_pending_on_actor) do
        for pplayer,pability in pairs(night_actions) do
          --print("+ Checking actiontype " .. actiontype .. " against " .. pability:GetAbilityName() .. " against target " .. pability.target:GetPlayerID())
          if pability.target == player and pability.action_types[actiontype] then
            skip = true
          end
        end
      end

      if not skip then
        --print("+ Resolving this action")
        -- Resolve action, first checking to be sure that we aren't roleblocked.
        if not player:GetAssignedHero():HasModifier("modifier_roleblocked") or ability_data[ability:GetAbilityName()].IsUnblockable then
          resolved_targets[player] = ability.target
          local success,resolution = pcall(ability.Resolve, ability)  -- Defined in each ability. Using pcall to not break everything if an ability has an error.
          -- Remove charges from limited-use abilities
          if ability_data[ability:GetAbilityName()].HasLimitedUses then
            ability.uses_left = ability.uses_left - 1
            if ability.uses_left == 0 then
              ability:GetCaster():RemoveAbility(ability:GetAbilityName())
            end
          end

          if resolution then
            --print("+ Received resolution:")
            --PrintTable(resolution)
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
            elseif resolution.type == RESOLUTION_TYPE_RESULT_WITH_CALLBACK then
              -- These actions can be resolved now, but we won't know the result of them until later.
              -- For example, we can resolve a watcher's ability at any time, but we won't know for sure who targeted
              -- the target until we're done.
              result_callbacks[player] = resolution.callback
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
        --print("+ Skipping this action due to other pending actions that potentially affect it")
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

  -- Do results with callbacks.
  for player,resolution in pairs(result_callbacks) do
    local result = resolution()
    if results[player] then
      table.insert(results[player], result)
    else
      results[player] = {result}
    end
  end

--[[  print("==========")
  print("Events:")
  PrintTable(events)
  print("Results:")
  PrintTable(results)
  print("==========")  ]]

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
        GameMode:ChangeStage(STAGE_DAY, current_cycle + 1)
      end
    end
  })
end

function GameMode:EnterDay()
  GameRules:SetTimeOfDay(0.25)
  votes = {}
  CustomGameEventManager:Send_ServerToAllClients("update_votes", {votes = {}, votes_to_lynch = GameMode:GetVotesToLynch()})

  for k,hero in pairs(HeroList:GetAllHeroes()) do
    for j,modifier in pairs(mafia_game_modifiers) do
      hero:RemoveModifierByName(modifier)
    end
    hero:RemoveModifierByName("modifier_sleeping")
  end

  Timers:CreateTimer("stage_tick_timer", {
    endTime = 0.25,
    callback = function()
      CustomGameEventManager:Send_ServerToAllClients("stage_tick", {elapsed = GameRules:GetGameTime() - last_stage_change, duration = STAGE_LENGTH_DAY, stage = current_stage})
      return 0.25
    end
  })
  Timers:CreateTimer("primary_timer", {
    endTime = STAGE_LENGTH_DAY,
    callback = function()
      CustomGameEventManager:Send_ServerToAllClients("deadline_reached", {})
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
    GameMode:VictoryFor(ALIGNMENT_TOWN)
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
      GameMode:VictoryFor(ALIGNMENT_MAFIA)
    end
  end
end

function GameMode:VictoryFor(alignment)
  Timers:CreateTimer(4, function()
    GameRules:SetCustomVictoryMessage("")
    GameRules:SetCustomVictoryMessageDuration(0)
    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
    GameRules:SetCustomGameEndDelay(0)
    local event = {}
    event.winning_alignment = alignment
    event.roles = {}
    for player,role in pairs(roles) do
      event.roles[player:GetPlayerID()] = {
        role = roles[player],
        alignment = GameMode:GetPlayerAlignment(player)
      }
    end
    CustomNetTables:SetTableValue("endgame", "data", event)
  end)
end

function GameMode:GetVotesToLynch()
  local living_player_count = 0
  for player,role in pairs(roles) do
    if player:GetAssignedHero() and player:GetAssignedHero():IsAlive() then
      living_player_count = living_player_count + 1
    end
  end
  local votes_to_lynch = math.ceil(living_player_count / 2)
  if votes_to_lynch == living_player_count / 2 then
    votes_to_lynch = votes_to_lynch + 1
  end
  return votes_to_lynch
end

function GameMode:SendRoleToClient(ev)
  local player = PlayerResource:GetPlayer(ev.PlayerID)
  local alignment = GameMode:GetPlayerAlignment(player)
  local response = {
    role = roles[player],
    alignment = alignment
  }

  local allies = {}
  if alignment == ALIGNMENT_MAFIA or alignment == ALIGNMENT_WEREWOLVES then
    local thisalign = GameMode:GetAllPlayersWithAlignment(alignment)
    for k,p in pairs(thisalign) do
      if p ~= player then
        allies[p:GetPlayerID()] = roles[p]
      end
    end
    response.allies = allies
  elseif roles[player] == "mason" then
    for p,role in pairs(roles) do
      if role == "mason" and player ~= p then
        allies[p:GetPlayerID()] = roles[p]
      end
    end
    response.allies = allies
  end

  CustomGameEventManager:Send_ServerToPlayer(player, "distribute_role", response)
end

function GameMode:SendFlipToClient(ev)
  CustomGameEventManager:Send_ServerToPlayer(ev.PlayerID, "flip_player", GameMode:GetFlip(tonumber(ev.requested_player)))
end

function GameMode:GetFlip(playerid)
  local player = PlayerResource:GetPlayer(playerid)
  if player:GetAssignedHero():IsAlive() then
    print("Flip rejected because player " .. PlayerResource:GetPlayerName(playerid) .. " is still alive")
    return {}
  end

  local flip = {
    playerID = playerid,
    role = roles[player],
    alignment = GameMode:GetPlayerAlignment(player)
  }
  return flip
end

function GameMode:Nightkill(player)
  if player:GetAssignedHero():HasModifier("modifier_bodyguarded") then
    player = player:GetAssignedHero():FindModifierByName("modifier_bodyguarded"):GetCaster():GetPlayerOwner()
  end
  GameMode:FocusCameras(player:GetAssignedHero())
  Timers:CreateTimer(1, function()
    CustomGameEventManager:Send_ServerToAllClients("nightkill", {player = player:GetPlayerID(), role = roles[player], alignment = GameMode:GetPlayerAlignment(player)})
    local hero = player:GetAssignedHero()
    local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControl(blood, 1, hero:GetAbsOrigin())
    hero:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
    hero:ForceKill(false)
    GameMode:FocusCameras(nil)
    CustomNetTables:SetTableValue("graveyard", tostring(player:GetPlayerID()), {
      role = roles[player],
      alignment = GameMode:GetPlayerAlignment(player),
      death_type = "killed",
      stage = STAGE_NIGHT,
      cycle = current_cycle
    })
  end)
end

function GameMode:FocusCameras(target)
  for k,player in pairs(GetPlayersOnTeam(DOTA_TEAM_GOODGUYS)) do
    PlayerResource:SetCameraTarget(player:GetPlayerID(), target)
  end
end