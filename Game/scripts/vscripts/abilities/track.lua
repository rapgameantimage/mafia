track = class({})
require("constants")
track.action_types = {}
track.inform_on_failure = true

function track:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function track:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function track:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function track:Resolve()
	return {
		type = RESOLUTION_TYPE_RESULT_WITH_CALLBACK,
		callback = function()
			local result = resolved_targets[self.target]
			if result then result = result:GetPlayerID() end
			return {
				eventname = "result_track",
				eventinfo = {
					target = self.target:GetPlayerID(),
					result = result
				}
			}
		end
	}
end