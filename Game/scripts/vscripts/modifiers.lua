modifier_protected = class({})
modifier_appears_guilty = class({})
modifier_appears_innocent = class({})

function DeclareModifiers()
	local modifiers = {"modifier_protected", "modifier_appears_innocent", "modifier_appears_innocent"}
	for k,modifier in pairs(modifiers) do
		LinkLuaModifier(modifier, "modifiers", LUA_MODIFIER_MOTION_NONE)
	end
end
DeclareModifiers()