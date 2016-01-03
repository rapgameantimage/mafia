mafia_kill = class({})
require("constants")
mafia_kill.action_types = {[ACTION_TYPE_KILL] = true}

function mafia_kill:CastFilterResultTarget(target)
	if not IsServer() then return end
	if GameMode:GetPlayerAlignment(target:GetPlayerOwner()) == GameMode:GetPlayerAlignment(self:GetCaster():GetPlayerOwner()) then
		return UF_FAIL_CUSTOM
	else
		return GameMode:GenericAbilityCastFilter(self, target)
	end
end

function mafia_kill:GetCustomCastErrorTarget(target)
	if GameMode:GetPlayerAlignment(target:GetPlayerOwner()) == GameMode:GetPlayerAlignment(self:GetCaster():GetPlayerOwner()) then
		return "#dota_hud_error_cant_cast_on_ally"
	else
		return GameMode:GenericAbilityCastError(self, target)
	end
end

function mafia_kill:UseAbility(target)
	self.target = target:GetPlayerOwner()
	-- Place this on the night action pre-resolution stack
	pre_resolution_stack.mafia_kill = {
		killer = self:GetCaster():GetPlayerOwner(),
		ability = self,
	}
end

function mafia_kill:Resolve()
	if not self.target:GetAssignedHero():HasModifier("modifier_protected") then
		return {
			type = RESOLUTION_TYPE_EVENT,
			target = self.target,
			followthrough = function()
				GameMode:Nightkill(self.target)
				self.target = nil
			end
		}
	end
end