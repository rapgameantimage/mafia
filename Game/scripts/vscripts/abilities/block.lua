block = class({})
require("constants")
block.action_types = {[ACTION_TYPE_BLOCK] = true}
block.inform_on_failure = false

function block:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function block:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function block:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function block:Resolve()
	self.target:AddNewModifier(self:GetCaster(), self, "modifier_roleblocked", {})
end