modifier_protected = class({})
modifier_appears_guilty = class({})
modifier_appears_innocent = class({})
modifier_roleblocked = class({})
modifier_bodyguarded = class({})

mafia_game_modifiers = {"modifier_protected", "modifier_appears_innocent", "modifier_appears_innocent", "modifier_roleblocked", "modifier_bodyguarded"}

for k,modifier in pairs(mafia_game_modifiers) do
	LinkLuaModifier(modifier, "modifiers", LUA_MODIFIER_MOTION_NONE)
end

function modifier_protected:IsHidden() return true end
function modifier_appears_guilty:IsHidden() return true end
function modifier_appears_innocent:IsHidden() return true end
function modifier_roleblocked:IsHidden() return true end
function modifier_bodyguarded:IsHidden() return true end

----

modifier_sleeping = class({})
LinkLuaModifier("modifier_sleeping", "modifiers", LUA_MODIFIER_MOTION_NONE)

function modifier_sleeping:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

function modifier_sleeping:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_TURNING}
end

function modifier_sleeping:GetModifierDisableTurning()
	return 1
end

modifier_no_lynch_target = class({})
LinkLuaModifier("modifier_no_lynch_target", "modifiers", LUA_MODIFIER_MOTION_NONE)

function modifier_no_lynch_target:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true}
end

modifier_dummy = class({})
LinkLuaModifier("modifier_dummy", "modifiers", LUA_MODIFIER_MOTION_NONE)