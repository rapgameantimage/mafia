watch = class({})
require("constants")
watch.action_types = {}
watch.inform_on_failure = true

function watch:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function watch:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function watch:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function watch:Resolve()
	return {
		type = RESOLUTION_TYPE_RESULT_WITH_CALLBACK,
		callback = function()
			local results = {}
			for actor,victim in pairs(resolved_targets) do
				if victim == self.target and actor ~= self:GetCaster():GetPlayerOwner() then
					table.insert(results, actor:GetPlayerID())
				end
			end
			if not next(results) then results = nil end
			return {
				eventname = "result_watch",
				eventinfo = {
					target = self.target:GetPlayerID(),
					result = results
				}
			}
		end
	}
end