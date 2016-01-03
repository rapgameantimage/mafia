function GenerateSetup(numplayers)
	-- Config
	local accepted_variance = 2								-- How far from a "balanced" game of 0 are we willing to accept?
	local max_scum_percentage = 0.28 						-- What's the maximum % of players that can be scum?
	local target_power = 1.5 * numplayers					-- About how much town power do we want in the game? Higher is more.
	local accepted_power_variance = 4	 					-- How far can we vary from the target power?
	local power_exponent = 1.4								-- Very powerful roles will be less frequent when this number is higher.

	-- Index the roles table to pick random roles from
	local roles_index = {}
	for role,_ in pairs(ROLE_DEFINITIONS) do
		table.insert(roles_index, role)
	end

	local setup = {}
	local tries = 0
	local townpower = 0
	local scumpower = 0
	local slanted_setup_streak = 0
	repeat 													-- Repeat until we get an acceptable setup
		tries = tries + 1
		local balance = 0
		local scumcount,masoncount,vigcount = 0,0,0
		local count_by_role = {}
		townpower,scumpower = 0,0
		for i = 1,numplayers do 			-- For each player, generate a role
			local role
			repeat 											-- Repeat until we get a role that isn't rerolled
				local keep_role = true
				role = roles_index[RandomInt(1, #roles_index)]
				-- Apply reroll chances based on power and intended frequency.
				if RandomFloat(0,1) > math.abs(1 / ROLE_DEFINITIONS[role].power ^ power_exponent)
				or RandomFloat(0,1) > math.abs(ROLE_DEFINITIONS[role].frequency or 1)
				-- Reroll roles we already have 2+ of
				or (count_by_role[role] and count_by_role[role] >= 2 and role ~= "townie" and role ~= "goon") then
					keep_role = false
				end
			until keep_role
			setup[i] = role
			if count_by_role[role] then
				count_by_role[role] = count_by_role[role] + 1
			else
				count_by_role[role] = 1
			end
			local power = ROLE_DEFINITIONS[role].power
			balance = balance + power
			if power > 0 then
				townpower = townpower + power
				if role == "mason" then
					masoncount = masoncount + 1
				elseif role == "vigilante" or role == "one_shot_vigilante" or role == "two_shot_vigilante" or role == "one_shot_dayvig" then
					vigcount = vigcount + 1
				end
			else
				scumpower = scumpower + power
				scumcount = scumcount + 1
			end
		end

		if balance > 0 then
			slanted_setup_streak = slanted_setup_streak + 1
		elseif balance < 0 then
			slanted_setup_streak = slanted_setup_streak - 1
		end
		if slanted_setup_streak == 10 then
			-- print("Increasing power exponent...")
			power_exponent = power_exponent + 0.1
			slanted_setup_streak = 0
		elseif slanted_setup_streak == -10 then
			-- print("Decreasing power exponent...")
			power_exponent = power_exponent - 0.1
			slanted_setup_streak = 0
		end		

		-- print("Generated a setup with a balance of " .. balance .. " from a town power of " .. townpower .. " and a scum power of " .. scumpower .. " (" .. scumcount .. " scum).")
	until (math.abs(balance) <= accepted_variance
		and math.abs(townpower) >= target_power - accepted_power_variance
		and math.abs(townpower) <= target_power + accepted_power_variance
		and scumcount / numplayers <= max_scum_percentage
		and masoncount ~= 1 and masoncount < 4
		and vigcount < 3) 
		or tries > 25000
	print("Accepted a setup after " .. tries .. " tries.")
	return setup
end