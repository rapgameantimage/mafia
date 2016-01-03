dayvig_one_shot = class({})
require("constants")
dayvig_one_shot.action_types = {}
dayvig_one_shot.inform_on_failure = false

function dayvig_one_shot:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function dayvig_one_shot:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function dayvig_one_shot:OnSpellStart()
	GameMode:FocusCameras(self:GetCaster())
	self:GetCaster():EmitSound("Ability.AssassinateLoad")
	ProjectileManager:CreateTrackingProjectile({
		EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
		Source = self:GetCaster(),
		Target = self:GetCursorTarget(),
		Ability = self,
		vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
		iMoveSpeed = 950,
	})
	self:GetCaster():EmitSound("Ability.Assassinate")
	self.camera_dummy = CreateModifierThinker(self:GetCaster(), self, "modifier_dummy", {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeam(), false)
	for k,hero in pairs(HeroList:GetAllHeroes()) do
		hero:AddNewModifier(self:GetCaster(), self, "modifier_dayvig_in_progress", {duration = 5})
	end
end

function dayvig_one_shot:OnProjectileThink(loc)
	self.camera_dummy:SetAbsOrigin(loc)
	GameMode:FocusCameras(self.camera_dummy)
end

function dayvig_one_shot:OnProjectileHit(target, loc)
	local caster = self:GetCaster()
	GameMode:FocusCameras(nil)
	EmitSoundOnLocationWithCaster(loc, "Hero_Gyrocopter.CallDown.Damage", caster)
	CustomGameEventManager:Send_ServerToAllClients("daykill", {
		killer = caster:GetPlayerOwnerID(),
		player = target:GetPlayerOwnerID(),
		role = roles[target:GetPlayerOwner()],
		alignment = GameMode:GetPlayerAlignment(target:GetPlayerOwner())
	})
	target:Kill(self, caster)
	caster:RemoveAbility(self:GetAbilityName())
	for k,hero in pairs(HeroList:GetAllHeroes()) do
		hero:RemoveModifierByName("modifier_dayvig_in_progress")
	end
end

---

LinkLuaModifier("modifier_dayvig_in_progress", "abilities/dayvig", LUA_MODIFIER_MOTION_NONE)
modifier_dayvig_in_progress = class({})

function modifier_dayvig_in_progress:IsHidden() return true end
function modifier_dayvig_in_progress:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end