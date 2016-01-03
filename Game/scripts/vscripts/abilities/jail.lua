jail = class({})
require("constants")
jail.action_types = {[ACTION_TYPE_BLOCK] = true, [ACTION_TYPE_PROTECT] = true}
jail.inform_on_failure = false

function jail:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function jail:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function jail:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function jail:Resolve()
	self.target:GetAssignedHero():AddNewModifier(self:GetCaster(), self, "modifier_roleblocked", {})
	self.target:GetAssignedHero():AddNewModifier(self:GetCaster(), self, "modifier_protected", {})
end