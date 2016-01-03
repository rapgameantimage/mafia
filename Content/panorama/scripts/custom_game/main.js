"use strict"

function OnStageChange(ev) {
	// AHHHHHHHHHHHHHHHHHHHHH I MADE SO MANY PANELS
	if (ev.stage == STAGE_DAY) {
		$("#kill-alert").SetHasClass("hide", true)
		$("#phase-label").text = $.Localize("#day") + " " + ev.cycle
		$("#clock-text").SetHasClass("hide", true)
		$("#clock-fill").SetHasClass("day", true)
		$("#clock-fill").SetHasClass("night", false)
		$("#clock-fill").style.width = "0%;"
		$("#lynchcount-label").SetHasClass("hide", false)
		$("#lynchcount-label").text = ev.votes_to_lynch + " " + $.Localize("#votes_to_lynch").toLowerCase()
		$("#phase-label").SetHasClass("hide", false)
		$("#votecount").SetHasClass("hide", false)
		$.Schedule(5, function() {
			$("#clock-text").text = $.Localize("#day") + " " + ev.cycle
			$("#clock-text").SetHasClass("hide", false)
			$("#phase-label").SetHasClass("hide", true)
			$("#lynchcount-label").SetHasClass("hide", true)
		})
		UnmuteLivingPlayers()
	} else if (ev.stage == STAGE_NIGHT) {
		$("#phase-label").text = $.Localize("#night") + " " + ev.cycle
		$("#clock-text").SetHasClass("hide", true)
		$("#clock-fill").SetHasClass("day", false)
		$("#clock-fill").SetHasClass("night", true)
		$("#clock-fill").style.width = "0%;"
		$("#phase-label").SetHasClass("hide", false)
		$("#votecount").SetHasClass("hide", true)
		$.Schedule(5, function() {
			$("#clock-text").text = $.Localize("#night") + " " + ev.cycle
			$("#clock-text").SetHasClass("hide", false)
			$("#phase-label").SetHasClass("hide", true)
		})
		MuteAllPlayers()
	} else if (ev.stage == STAGE_DAWN) {
		$("#clock-fill").style.width = "0%;"
		$("#clock-text").SetHasClass("hide", true)
	}
}

function OnStageTick(ev) {
	$("#clock-fill").style.width = (parseFloat(ev.elapsed) / parseFloat(ev.duration) * 100).toString()  + "%;";
}

function OnUpdateVotes(ev) {
	// votecount: an object containing each player being voted for, and the players voting for him
	var votecount = {}
	for (var vote in ev.votes) {
		if (votecount[ev.votes[vote]]) {
			votecount[ev.votes[vote]].push(parseInt(vote))
		} else {
			votecount[ev.votes[vote]] = [parseInt(vote)]
		}
	}
	$("#votes-to-lynch").text = ev.votes_to_lynch + " " + $.Localize("#votes_to_lynch").toLowerCase()
	$("#votecount-votecount").RemoveAndDeleteChildren()
	$.CreatePanel("Panel", $("#votecount-body"), "votecount-votecount")
	
	while (Object.keys(votecount).length > 0) {
		var mostvotes = 0
		var mostvoted
		for (var p in votecount) {
			if (votecount[p].length > mostvotes) {
				mostvotes = votecount[p].length
				mostvoted = p
			}
		}

		var player = mostvoted
		var panel = $.CreatePanel("Panel", $("#votecount-votecount"), "votecount-player" + player)
		panel.SetHasClass("votecount-player", true)
		panel.SetHasClass("lynch-minus-one", mostvotes >= ev.votes_to_lynch - 1)
		var top = $.CreatePanel("Panel", panel, "votecount-player" + player + "-top")
		top.SetHasClass("votecount-player-top", true)
		if (player != "no lynch") {
			var img = $.CreatePanel("DOTAHeroImage", top, "votecount-player" + player + "-heroimage")
			img.heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(parseInt(player)))
			img.heroimagestyle = "icon"
		}
		var lbl = $.CreatePanel("Label", top, "votecount-player" + player + "-label")

		var pluralized
		if (votecount[player].length == 1) {
			pluralized = $.Localize("#vote").toLowerCase()
		} else {
			pluralized = $.Localize("#votes").toLowerCase()
		}
		lbl.text = votecount[player].length + " " + pluralized + " for " + (player != "no lynch" ? Players.GetPlayerName(parseInt(player)) : $.Localize("#no_lynch"))
		
		var voterspanel = $.CreatePanel("Panel", panel, "votecount-player" + player + "-voters")
		voterspanel.SetHasClass("votecount-player-voters", true)
		var txt = $.CreatePanel("Label", voterspanel, "")
		txt.text = $.Localize("#votes") + ": "
		for (var voter in votecount[player]) {
			var voterimg = $.CreatePanel("DOTAHeroImage", voterspanel, "votecount-player" + player + "-voters-" + voter)
			voterimg.heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(parseInt(votecount[player][voter])))
			voterimg.heroimagestyle = "icon"
		}

		delete votecount[player]
	}
}

function OnPlayerWillBeLynched(ev) {
	var lynchee = parseInt(ev.lynchee)
	var votecount = ev.votes
	$("#lynch-header").text = Players.GetPlayerName(lynchee) + " " + $.Localize("#lynch_header")
	$("#lynch-image").heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(lynchee))
	var mob = $("#lynch-mob")
	mob.RemoveAndDeleteChildren()
	var leftcol = $.CreatePanel("Panel", mob, "lynch-mob-left-column")
	var rightcol = $.CreatePanel("Panel", mob, "lynch-mob-right-column")
	var parent = leftcol
	for (var vote in votecount) {
		if (parseInt(votecount[vote]) == lynchee) {
			var player = parseInt(vote)
			var panel = $.CreatePanel("Panel", parent, "lynch-mob-player-" + player)
			panel.SetHasClass("lynch-mob-player", true)
			var img = $.CreatePanel("DOTAHeroImage", panel, "lynch-mob-player-" + player + "-image")
			img.heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(player))
			img.heroimagestyle = "icon"
			var txt = $.CreatePanel("Label", panel, "lynch-mob-player-" + player + "-text")
			txt.text = Players.GetPlayerName(player)

			if (parent === leftcol) {
				parent = rightcol
			} else {
				parent = leftcol
			}
		}
	}
	$("#lynch-alert").SetHasClass("fade", false)
	$("#lynch-alert").SetHasClass("hide", false)
}

function OnBeginLynch(ev) {
	$("#lynch-alert").SetHasClass("fade", true)
}

function OnNoLynch(ev) {
	$("#phase-label").text = $.Localize("#no_lynch_reached")
	$("#phase-label").SetHasClass("hide", false)
}

function OnDeadlineReached(ev) {
	$("#phase-label").text = $.Localize("#deadline_reached")
	$("#phase-label").SetHasClass("hide", false)
}

function FlipPlayer(ev) {
	var playername = Players.GetPlayerName(parseInt(ev.playerID))
	var was_a = "aeiou".indexOf($.Localize(ev.role).charAt(0)) === -1 ? $.Localize("#was_a") : $.Localize("#was_an")
	$("#lynch-header").text = playername + " " + was_a + " <span class='strong alignment-" + ev.alignment + "'>" + $.Localize(ev.role) + "</span>."
	$("#lynch-alert").SetHasClass("fade", false)
	$.Schedule(4, function() {
		$("#lynch-alert").SetHasClass("hide", true)
	})
}

function GetColorForAlignment(alignment) {
	switch (alignment) {
		case 0:
			return "green"
		case 1:
			return "red"
		case 2:
			return "blue"
		case 3:
			return "violet"
	}
}

function ShowRolecard(ev) {
	$("#rolecard-container").RemoveAndDeleteChildren()
	var flip = $.CreatePanel("Panel", $("#rolecard-container"), "rolecard-flip")
	flip.BLoadLayout("file://{resources}/layout/custom_game/rolecard.xml", false, false)
	flip.FindChildrenWithClassTraverse("rolecard-header-text")[0].text = Players.GetPlayerName(parseInt(ev.playerID)) + "'s role"
	flip.FindChildrenWithClassTraverse("rolecard-rolename")[0].text = $.Localize(ev.role)
	flip.FindChildrenWithClassTraverse("rolecard-description")[0].text = $.Localize(ev.role + "_description")
	flip.FindChildrenWithClassTraverse("rolecard-win-condition")[0].text = $.Localize("win_condition_" + ev.alignment)
	flip.SetHasClass("alignment-" + ev.alignment, true)
	flip.FindChildrenWithClassTraverse("rolecard-allies")[0].style.visibility = "collapse"
}

function OnNightkill(ev) {
	$("#kill-alert").SetHasClass("hide", false)
	$("#kill-caption").text = Players.GetPlayerName(ev.player) + ", " + $.Localize("#a") + " <span class='strong alignment-" + ev.alignment + "'>" + $.Localize(ev.role) + "</span>, " + $.Localize("#was_nightkilled") + "."
}

function OnDaykill(ev) {
	$("#kill-alert").SetHasClass("hide", false)
	$("#kill-caption").text = Players.GetPlayerName(ev.player) + ", " + $.Localize("#a") + " <span class='strong alignment-" + ev.alignment + "'>" + $.Localize(ev.role) + "</span>, " + $.Localize("#was_daykilled_by") + " " + Players.GetPlayerName(ev.killer) + "!"
	$.Schedule(5, function() {
		$("#kill-alert").SetHasClass("hide", true)
	})
}

function MuteDeadPlayers() {
	var players = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS)
	for (var i = 0; i < players.length; i++) {
		if (!Entities.IsAlive(Players.GetPlayerHeroEntityIndex(players[i]))) {
			Game.SetPlayerMuted(players[i], true)
		}
	}
}

function MuteAllPlayers() {
	var players = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS)
	for (var i = 0; i < players.length; i++) {
		Game.SetPlayerMuted(players[i], true)
	}
}

function UnmuteLivingPlayers() {
	var players = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS)
	for (var i = 0; i < players.length; i++) {
		if (Entities.IsAlive(Players.GetPlayerHeroEntityIndex(players[i]))) {
			Game.SetPlayerMuted(players[i], false)
		}
	}
}

(function() {
	GameEvents.Subscribe("stage_change", OnStageChange)
	GameEvents.Subscribe("stage_tick", OnStageTick)
	GameEvents.Subscribe("update_votes", OnUpdateVotes)
	GameEvents.Subscribe("player_will_be_lynched", OnPlayerWillBeLynched)
	GameEvents.Subscribe("begin_lynch", OnBeginLynch)
	GameEvents.Subscribe("flip_player", FlipPlayer)
	GameEvents.Subscribe("show_rolecard", ShowRolecard)
	GameEvents.Subscribe("nightkill", OnNightkill)
	GameEvents.Subscribe("no_lynch", OnNoLynch)
	GameEvents.Subscribe("deadline_reached", OnDeadlineReached)
	GameEvents.Subscribe("daykill", OnDaykill)

	CustomNetTables.SubscribeNetTableListener("graveyard", MuteDeadPlayers)
	UnmuteLivingPlayers()
	MuteDeadPlayers()

	GameUI.SetRenderBottomInsetOverride(0)
})()

var STAGE_DAY = 0
var STAGE_TWILIGHT = 1
var STAGE_NIGHT = 2
var STAGE_DAWN = 3