REPLACEME = class({})
require("constants")
REPLACEME.action_types = {[ACTION_TYPE_EXAMPLE] = true}
REPLACEME.inform_on_failure = false

function REPLACEME:CastFilterResultTarget(target)
	if not IsServer() then return end
	return GameMode:GenericAbilityCastFilter(self, target)
end

function REPLACEME:GetCustomCastErrorTarget(target)
	return GameMode:GenericAbilityCastError(self, target)
end

function REPLACEME:UseAbility(target)
	self.target = target:GetPlayerOwner()
	night_actions[self:GetCaster():GetPlayerOwner()] = self
end

function REPLACEME:Resolve()
	--[[	Result resolution
	return {
		type = RESOLUTION_TYPE_RESULT,
		event = {
			eventname = "result_SOMETHING",
			eventinfo = {
				target = self.target,
				result = "some_stuff",
			}
		}
	}
	]]

	--[[	Result resolution with callback
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

	]]

	--[[	Event resolution
	return {
		type = RESOLUTION_TYPE_EVENT,
		followthrough = function()
			GameMode:Nightkill(self.target)
			self.target = nil
		end
	}
	]]

	-- 		Or return nil to omit a visible effect.
end