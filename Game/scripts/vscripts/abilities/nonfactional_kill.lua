nonfactional_kill = class({})
require("constants")
nonfactional_kill.action_types = {[ACTION_TYPE_KILL] = true}
nonfactional_kill.inform_on_failure = false

function nonfactional_kill:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function nonfactional_kill:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function nonfactional_kill:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function nonfactional_kill:Resolve()
	if not self.target:GetAssignedHero():HasModifier("modifier_protected") then
		return {
			type = RESOLUTION_TYPE_EVENT,
			followthrough = function()
				GameMode:Nightkill(self.target)
				self.target = nil
			end
		}
	end
end

-- Variants

nonfactional_kill_one_shot = class({})
require("constants")
nonfactional_kill_one_shot.action_types = {[ACTION_TYPE_KILL] = true}
nonfactional_kill_one_shot.inform_on_failure = false

function nonfactional_kill_one_shot:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function nonfactional_kill_one_shot:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function nonfactional_kill_one_shot:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function nonfactional_kill_one_shot:Resolve()
	if not self.target:GetAssignedHero():HasModifier("modifier_protected") then
		return {
			type = RESOLUTION_TYPE_EVENT,
			followthrough = function()
				GameMode:Nightkill(self.target)
				self.target = nil
			end
		}
	end
end

nonfactional_kill_two_shot = class({})
require("constants")
nonfactional_kill_two_shot.action_types = {[ACTION_TYPE_KILL] = true}
nonfactional_kill_two_shot.inform_on_failure = false

function nonfactional_kill_two_shot:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function nonfactional_kill_two_shot:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function nonfactional_kill_two_shot:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function nonfactional_kill_two_shot:Resolve()
	if not self.target:GetAssignedHero():HasModifier("modifier_protected") then
		return {
			type = RESOLUTION_TYPE_EVENT,
			followthrough = function()
				GameMode:Nightkill(self.target)
				self.target = nil
			end
		}
	end
end