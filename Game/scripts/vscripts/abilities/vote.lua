vote = class({})

function vote:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self)
end

function vote:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self)
end

function vote:OnSpellStart()
	GameMode:ChangeVote(self:GetCaster():GetPlayerOwner(), self:GetCursorTarget():GetPlayerOwner())
end