// This file handles the results of investigations, etc.

function CreateResult() {
	var p = $.CreatePanel("Panel", $.GetContextPanel(), "test")
	p.BLoadLayout("file://{resources}/layout/custom_game/result.xml", false, false)
	return p
}

function DoResultInvestigation(ev) {
	var p = CreateResult()
	var body = p.FindChildrenWithClassTraverse("result-body")[0]
	var txt = $.Localize("#you_targeted") + " " + Players.GetPlayerName(ev.target) + "<br />"
	txt = txt + $.Localize("#result") + " "
	if (ev.result === "innocent") {
		txt = txt + "<span class=\"strong alignment-0\">" + $.Localize(ev.result) + "</span>"
	} else if (ev.result === "guilty") {
		txt = txt + "<span class=\"strong alignment-1\">" + $.Localize(ev.result) + "</span>"
	}
	body.text = txt 
	p.FindChildrenWithClassTraverse("result-target")[0].heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(ev.target))
}

(function() {
GameEvents.Subscribe("result_investigation", DoResultInvestigation)
})()