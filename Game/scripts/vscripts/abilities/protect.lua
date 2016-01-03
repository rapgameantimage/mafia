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

function protect:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function protect:Resolve()
	self.target:GetAssignedHero():AddNewModifier(self:GetCaster(), self, "modifier_protected", {})
end

-- Duplicates for minor variants

protect_one_shot = class({})
require("constants")
protect_one_shot.action_types = {[ACTION_TYPE_PROTECT] = true}

function protect_one_shot:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function protect_one_shot:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function protect_one_shot:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function protect_one_shot:Resolve()
	self.target:GetAssignedHero():AddNewModifier(self:GetCaster(), self, "modifier_protected", {})
end

protect_two_shot = class({})
require("constants")
protect_two_shot.action_types = {[ACTION_TYPE_PROTECT] = true}

function protect_two_shot:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function protect_two_shot:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function protect_two_shot:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function protect_two_shot:Resolve()
	self.target:GetAssignedHero():AddNewModifier(self:GetCaster(), self, "modifier_protected", {})
end