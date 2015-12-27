function GameMode:GenericAbilityCastFilter(ability)
  local abdata = ability_data[ability:GetName()]
  if current_stage == STAGE_NIGHT then
    if abdata.UsableDuringNight then
      return UF_SUCCESS
    else
      return UF_FAIL_CUSTOM
    end
  elseif current_stage == STAGE_DAY then
    if abdata.UsableDuringDay then
      return UF_SUCCESS
    else
      return UF_FAIL_CUSTOM
    end
  elseif current_stage == STAGE_TWILIGHT then
    if abdata.UsableDuringTwilight then
      return UF_SUCCESS
    else
      return UF_FAIL_CUSTOM
    end
  elseif current_stage == STAGE_DAWN then
    if abdata.UsableDuringDawn then
      return UF_SUCCESS
    else
      return UF_FAIL_CUSTOM
    end
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
end