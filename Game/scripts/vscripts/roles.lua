ROLE_DEFINITIONS = {
	--[[
	rolename = {
		alignment = constant representing alignment,
		abilities = { table containing a list of abilities this role should have },
		power = this role's estimated power for setup generation; more positive is more pro-town,
		frequency = an optional number between 0 and 1 representing the frequency of this role for setup generation; larger is more frequent (default = 1)
	}

	note that frequency is a separate check that is applied after the usual power check;
	i.e. powerful roles will still be less frequent than townies even if both have frequency = 1.
	]]
	townie = {
		alignment = ALIGNMENT_TOWN,
		abilities = {},
		power = 1,
		frequency = 1,
	},
	goon = {
		alignment = ALIGNMENT_MAFIA,
		abilities = { "mafia_kill" },
		power = -5.5,
		frequency = 1,
	},
	doctor = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "protect" },
		power = 5.5,
		frequency = 0.5,
	},
	cop = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "investigate" },
		power = 5.75,
	},
	vigilante = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "nonfactional_kill" },
		power = 4.5,
		frequency = 0.2,
	},
	roleblocker = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "block" },
		power = 3.5,
		frequency = 0.5,
	},
	jailkeeper = {
		alignment = ALIGNMENT_TOWN,
		abilities = {"jail"},
		power = 4,
	},
	tracker = {
		alignment = ALIGNMENT_TOWN,
		abilities = {"track"},
		power = 3.5,
		frequency = 0.5,
	},
	godfather = {
		alignment = ALIGNMENT_MAFIA,
		abilities = {"mafia_kill", "appears_innocent"},
		power = -6,
		frequency = 0.1,
	},
	watcher = {
		alignment = ALIGNMENT_TOWN,
		abilities = {"watch"},
		power = 6.5,
	},
	mafia_roleblocker = {
		alignment = ALIGNMENT_MAFIA,
		abilities = {"mafia_kill", "block"},
		power = -7.25,
		frequency = 0.2,
	},
	one_shot_doctor = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "protect_one_shot" },
		power = 2.5,
		frequency = 0.5,
	},
	two_shot_doctor = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "protect_two_shot" },
		power = 3.5,
		frequency = 0.5,
	},
	one_shot_vigilante = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "nonfactional_kill_one_shot" },
		power = 3.25,
		frequency = 0.4,
	},
	two_shot_vigilante = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "nonfactional_kill_two_shot" },
		power = 3.75,
		frequency = 0.2,
	},
	bodyguard = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "bodyguard" },
		power = 3,
		frequency = 0.25,
	},
	one_shot_dayvig = {
		alignment = ALIGNMENT_TOWN,
		abilities = { "dayvig_one_shot" },
		power = 4,
		frequency = 0.2,
	},
	ironskinned_townie = {
		alignment = ALIGNMENT_TOWN,
		abilities = {"ironskin"},
		power = 4,
		frequency = 0.5,
	},
	mason = { 
		alignment = ALIGNMENT_TOWN,
		abilities = {"mason"},
		power = 4,
	},
	one_shot_cop = {
		alignment = ALIGNMENT_TOWN,
		abilities = {"one_shot_investigate"},
		power = 3.5,
	},
	two_shot_cop = {
		alignment = ALIGNMENT_TOWN,
		abilities = {"two_shot_investigate"},
		power = 4.75,
	},
	jack_of_all_trades = {
		alignment = ALIGNMENT_TOWN,
		abilities = {"one_shot_investigate", "protect_one_shot", "nonfactional_kill_one_shot"},
		power = 5,
	},
}