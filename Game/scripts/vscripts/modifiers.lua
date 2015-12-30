modifier_protected = class({})
modifier_appears_guilty = class({})
modifier_appears_innocent = class({})

mafia_game_modifiers = {"modifier_protected", "modifier_appears_innocent", "modifier_appears_innocent"}

for k,modifier in pairs(mafia_game_modifiers) do
	LinkLuaModifier(modifier, "modifiers", LUA_MODIFIER_MOTION_NONE)
end

function modifier_protected:IsHidden() return true end
function modifier_appears_guilty:IsHidden() return true end
function modifier_appears_innocent:IsHidden() return true end