investigate = class({})
require("constants")
investigate.action_types = {[ACTION_TYPE_INVESTIGATE] = true}
investigate.inform_on_failure = true

function investigate:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self)
end

function investigate:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self)
end

function investigate:OnSpellStart()
	self.target = self:GetCursorTarget():GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function investigate:Resolve()
	local result
	if self.target:GetAssignedHero():HasModifier("appears_guilty") then
		result = "guilty"
	elseif self.target:GetAssignedHero():HasModifier("appears_innocent") then
		result = "innocent"
	else
		if GameMode:GetPlayerAlignment(self.target) == ALIGNMENT_TOWN then
			result = "innocent"
		else
			result = "guilty"
		end
	end

	return {
		type = RESOLUTION_TYPE_RESULT,
		event = {
			eventname = "result_investigation",
			eventinfo = {
				target = self.target,
				result = result
			}
		}
	}
end