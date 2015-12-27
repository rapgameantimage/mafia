mafia_kill = class({})
require("constants")
mafia_kill.action_types = {[ACTION_TYPE_KILL] = true}

function mafia_kill:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self)
end

function mafia_kill:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self)
end

function mafia_kill:OnSpellStart()
	self.target = self:GetCursorTarget():GetPlayerOwner()
	-- Place this on the night action pre-resolution stack
	pre_resolution_stack.mafia_kill = {
		killer = self:GetCaster():GetPlayerOwner(),
		ability = self,
	}
end

function mafia_kill:Resolve()
	if not self.target:GetAssignedHero():HasModifier("protected") then
		return {
			type = RESOLUTION_TYPE_EVENT,
			followthrough = function()
				CustomGameEventManager:Send_ServerToAllClients("nightkill", {player = self.target})
				self.target:GetAssignedHero():ForceKill(false)
				self.target = nil
			end
		}
	end
end