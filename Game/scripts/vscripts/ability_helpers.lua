function GameMode:GenericAbilityCastFilter(ability, target, allow_self_target)
  local abdata = ability_data[ability:GetName()]
  if current_stage == STAGE_NIGHT and not abdata.UsableDuringNight
  or current_stage == STAGE_DAY and not abdata.UsableDuringDay
  or current_stage == STAGE_TWILIGHT and not abdata.UsableDuringTwilight
  or current_stage == STAGE_DAWN and not abdata.UsableDuringDawn
  or target == ability:GetCaster() and not allow_self_target then
    return UF_FAIL_CUSTOM
  else
    return UF_SUCCESS
  end
end

function GameMode:GenericAbilityCastError(ability)
  local abdata = ability_data[ability:GetName()]
  if current_stage == STAGE_NIGHT then
    if not abdata.UsableDuringNight then
      return "#dota_hud_error_not_usable_during_night"
    end
  elseif current_stage == STAGE_DAY then
    if not abdata.UsableDuringDay then
      return "#dota_hud_error_not_usable_during_day"
    end
  elseif current_stage == STAGE_TWILIGHT then
    if not abdata.UsableDuringTwilight then
      return "#dota_hud_error_not_usable_during_twilight"
    end
  elseif current_stage == STAGE_DAWN then
    if not abdata.UsableDuringDawn then
      return "#dota_hud_error_not_usable_during_dawn"
    end
  end
  return "#dota_hud_error_cant_cast_on_self"
end