investigate = class({})
require("constants")
investigate.action_types = {[ACTION_TYPE_INVESTIGATE] = true}
investigate.inform_on_failure = true

function investigate:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function investigate:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function investigate:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function investigate:Resolve()
	local result
	if self.target:GetAssignedHero():HasModifier("appears_guilty") then
		result = "guilty"
	elseif self.target:GetAssignedHero():HasModifier("appears_innocent") then
		result = "innocent"
	else
		if GameMode:GetPlayerAlignment(self.target) == ALIGNMENT_MAFIA then
			result = "guilty"
		else
			result = "innocent"
		end
	end

	return {
		type = RESOLUTION_TYPE_RESULT,
		event = {
			eventname = "result_investigation",
			eventinfo = {
				target = self.target:GetPlayerID(),
				result = result
			}
		}
	}
end

-- Variants

one_shot_investigate = class({})
require("constants")
one_shot_investigate.action_types = {[ACTION_TYPE_INVESTIGATE] = true}
one_shot_investigate.inform_on_failure = true

function one_shot_investigate:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function one_shot_investigate:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function one_shot_investigate:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function one_shot_investigate:Resolve()
	local result
	if self.target:GetAssignedHero():HasModifier("appears_guilty") then
		result = "guilty"
	elseif self.target:GetAssignedHero():HasModifier("appears_innocent") then
		result = "innocent"
	else
		if GameMode:GetPlayerAlignment(self.target) == ALIGNMENT_MAFIA then
			result = "guilty"
		else
			result = "innocent"
		end
	end

	return {
		type = RESOLUTION_TYPE_RESULT,
		event = {
			eventname = "result_investigation",
			eventinfo = {
				target = self.target:GetPlayerID(),
				result = result
			}
		}
	}
end

two_shot_investigate = class({})
require("constants")
two_shot_investigate.action_types = {[ACTION_TYPE_INVESTIGATE] = true}
two_shot_investigate.inform_on_failure = true

function two_shot_investigate:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function two_shot_investigate:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function two_shot_investigate:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function two_shot_investigate:Resolve()
	local result
	if self.target:GetAssignedHero():HasModifier("appears_guilty") then
		result = "guilty"
	elseif self.target:GetAssignedHero():HasModifier("appears_innocent") then
		result = "innocent"
	else
		if GameMode:GetPlayerAlignment(self.target) == ALIGNMENT_MAFIA then
			result = "guilty"
		else
			result = "innocent"
		end
	end

	return {
		type = RESOLUTION_TYPE_RESULT,
		event = {
			eventname = "result_investigation",
			eventinfo = {
				target = self.target:GetPlayerID(),
				result = result
			}
		}
	}
end