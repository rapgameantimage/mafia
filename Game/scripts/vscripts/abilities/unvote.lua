unvote = class({})

function unvote:CastFilterResult()
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self)
end

function unvote:GetCustomCastError()
	return GameMode:GenericAbilityCastError(self)
end

function unvote:OnSpellStart()
	GameMode:ChangeVote(self:GetCaster():GetPlayerOwner(), nil)
end