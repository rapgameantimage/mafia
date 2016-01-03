"use strict";

function UpdateScoreboard(tbl, key, val) {
	var graveyard = CustomNetTables.GetAllTableValues("graveyard")
	$("#graveyard-body").RemoveAndDeleteChildren()
	for (var i = 0; i < graveyard.length; i++) {
		var player = parseInt(graveyard[i].key)
		var flip = graveyard[i].value
		var panel = $.CreatePanel("Panel", $("#graveyard-body"), "graveyard-player-" + player)
		panel.SetHasClass("scoreboard-player", true)
		var image = $.CreatePanel("DOTAHeroImage", panel, "")
		image.heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(player))
		image.heroimagestyle = "landscape"
		var label = $.CreatePanel("Label", panel, "")
		label.SetHasClass("alignment-" + flip.alignment, true)
		var txt = Players.GetPlayerName(player) + ", " + $.Localize(flip.role) + ", " + $.Localize(flip.death_type) + " " + GetStageName(flip.stage) + " " + flip.cycle
		label.text = txt
	}

	var all_players = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
	$("#living-players-body").RemoveAndDeleteChildren();
	for (var i = 0; i < all_players.length; i++) {
		if (Players.GetPlayerHeroEntityIndex(all_players[i]) == -1 || Entities.IsAlive(Players.GetPlayerHeroEntityIndex(all_players[i]))) {
			var panel = $.CreatePanel("Panel", $("#living-players-body"), "")
			panel.SetHasClass("scoreboard-player", true)
			var image = $.CreatePanel("DOTAHeroImage", panel, "")
			image.heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(all_players[i]))
			image.heroimagestyle = "landscape"
			var label = $.CreatePanel("Label", panel, "");
			label.text = Players.GetPlayerName(all_players[i]);
			label.SetHasClass("scoreboard-player", true);
		}
	}
}

function HTMLHeroImage(player, imgtype) {
	var path
	switch (imgtype) {
		case "landscape":
			path = "file://{images}/heroes/";
			break;
		case "icon":
			path = "file://{images}/heroes/icons/";
			break;
		case "portrait":
			path = "file://{images}/heroes/"
			break;
	}
	return "<img src=\"" + path + Entities.GetClassname(Players.GetPlayerHeroEntityIndex(player)) + ".png\" class=\"inline-heroimage-" + imgtype + "\"/>"
}

function GetStageName(num) {
	switch (num) {
		case 0:
			return $.Localize("#day")
		case 1:
			return $.Localize("#twilight")
		case 2:
			return $.Localize("#night")
		case 3 || -1:
			return $.Localize("#dawn")
	}
}

function SetScoreboardVisibility(should_be_visible) {
	$.GetContextPanel().SetHasClass("visible", should_be_visible)
}

(function() {
	GameEvents.Subscribe("npc_spawned", UpdateScoreboard)
	CustomNetTables.SubscribeNetTableListener("graveyard", UpdateScoreboard)
	UpdateScoreboard()
	$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetScoreboardVisibility);
})() 