function GameMode:GenericAbilityCastFilter(ability, target, allow_self_target)
  local abilityname = ability:GetAbilityName()
  if current_stage == STAGE_DAY and (abilityname == "vote" or abilityname == "unvote" or abilityname == "dayvig_one_shot") and target ~= ability:GetCaster() then
    return UF_SUCCESS
  else
    return UF_FAIL_CUSTOM
  end
end

function GameMode:GenericAbilityCastError(ability, target, allow_self_target)
  local abdata = ability_data[ability:GetName()]
  if current_stage == STAGE_NIGHT and not abdata.UsableDuringNight then
    return "#dota_hud_error_not_usable_during_night"
  elseif current_stage == STAGE_DAY and not abdata.UsableDuringDay then
    return "#dota_hud_error_not_usable_during_day"
  elseif current_stage == STAGE_TWILIGHT and not abdata.UsableDuringTwilight then
    return "#dota_hud_error_not_usable_during_twilight"
  elseif current_stage == STAGE_DAWN and not abdata.UsableDuringDawn then
    return "#dota_hud_error_not_usable_during_dawn"
  end
  if ability:GetCaster() == target and not allow_self_target then
    return "#dota_hud_error_cant_cast_on_self"
  end
  local player = ability:GetCaster():GetPlayerOwner()
  EmitSoundOnClient("Loot_Drop_Stinger_Short", player)

  if abdata.IsFactionalAbility then
    local alignment = GameMode:GetPlayerAlignment(player)
    local particles = factional_target_particles[alignment]
    if particles then
      for _,particle in pairs(particles) do
        ParticleManager:DestroyParticle(particle, false)
      end
    end
    factional_target_particles[alignment] = {}
    for _,member in pairs(GameMode:GetAllPlayersWithAlignment(alignment, true)) do
      local p = ParticleManager:CreateParticleForPlayer("particles/faction_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, member)
      ParticleManager:SetParticleControl(p, 2, target:GetAbsOrigin())
      table.insert(factional_target_particles[alignment], p)
    end
  else
    if player.target_particle then
      ParticleManager:DestroyParticle(player.target_particle, false)
    end
    player.target_particle = ParticleManager:CreateParticleForPlayer("particles/night_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, player)
    ParticleManager:SetParticleControl(player.target_particle, 2, target:GetAbsOrigin())
  end

  pcall(ability.UseAbility, ability, target)
  return "#dota_hud_error_silent"
end