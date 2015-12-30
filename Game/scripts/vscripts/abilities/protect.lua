protect = class({})
require("constants")
protect.action_types = {[ACTION_TYPE_PROTECT] = true}

function protect:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function protect:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function protect:OnSpellStart()
	self.target = self:GetCursorTarget():GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function protect:Resolve()
	self.target:GetAssignedHero():AddNewModifier(self:GetCaster(), self, "modifier_protected", {})
end