bodyguard = class({})
require("constants")
bodyguard.action_types = {}
bodyguard.inform_on_failure = false

function bodyguard:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function bodyguard:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function bodyguard:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function bodyguard:Resolve()
	self.target:GetAssignedHero():AddNewModifier(self:GetCaster(), self, "modifier_bodyguarded", {})
end