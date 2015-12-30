function DoEndgameReveal() {
	var ev = CustomNetTables.GetTableValue("endgame", "data")
	$.Msg(ev)
	$.GetContextPanel().SetHasClass("hide", false)
	$("#endgame-header").text = $.Localize("#alignment_" + ev.winning_alignment + "_victory")
	$("#endgame-header").SetHasClass("alignment-" + ev.winning_alignment, true)
	var body = $("#endgame-body")
	for (player in ev.roles) {
		var playerid = parseInt(player)
		var wrap = $.CreatePanel("Panel", body, "endgame-player-" + playerid)
		wrap.SetHasClass("endgame-player", true)
		var icon = $.CreatePanel("DOTAHeroImage", wrap, "endgame-icon-" + playerid)
		icon.SetHasClass("endgame-icon", true)
		icon.heroimagestyle = "landscape"
		icon.heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(playerid))
		var name = $.CreatePanel("Label", wrap, "endgame-name-" + playerid)
		name.SetHasClass("endgame-player-name", true)
		name.html = true
		name.text = Players.GetPlayerName(playerid) + ": <span class='strong alignment-" + ev.roles[player].alignment + "'>" + $.Localize(ev.roles[player].role) + "</span>"
	}
}

$.Msg("Loaded endgame.js")
DoEndgameReveal()
GameEvents.Subscribe("endgame_reveal", DoEndgameReveal)
