// This file handles the results of investigations, etc.

function CreateResult(target) {
	var p = $.CreatePanel("Panel", $.GetContextPanel(), "test")
	p.BLoadLayout("file://{resources}/layout/custom_game/result.xml", false, false)
	if (target) {
		p.FindChildrenWithClassTraverse("result-target")[0].heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(target))
	} else {
		p.FindChildrenWithClassTraverse("result-target")[0].SetHasClass("hide", true)
	}
	p.SetBodyText = function(txt) {
		this.FindChildrenWithClassTraverse("result-body")[0].text = txt
	}
	return p
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

function InvestigationTopLine(target) {
	return $.Localize("#you_targeted") + " " + Players.GetPlayerName(target) + " (" + $.Localize(Entities.GetClassname(Players.GetPlayerHeroEntityIndex(target))) + ")<br />" + $.Localize("#result") + " "
}

function GetHeroName(player) {
	return $.Localize(Entities.GetClassname(Players.GetPlayerHeroEntityIndex(player)))
}

function DoResultInvestigation(ev) {
	var p = CreateResult(ev.target) 
	var txt = InvestigationTopLine(ev.target)
	if (ev.result === "innocent") {
		txt = txt + "<span class=\"strong alignment-0\">" + $.Localize(ev.result) + "</span>"
	} else if (ev.result === "guilty") {
		txt = txt + "<span class=\"strong alignment-1\">" + $.Localize(ev.result) + "</span>"
	}
	p.SetBodyText(txt)
}

function DoResultTrack(ev) {
	var p = CreateResult(ev.target)
	var txt = InvestigationTopLine(ev.target)
	if (ev.result) {
		txt = txt + Players.GetPlayerName(ev.target) + " " + $.Localize("#targeted") + " "
		txt = txt + Players.GetPlayerName(ev.result) + " (" + $.Localize(Entities.GetClassname(Players.GetPlayerHeroEntityIndex(ev.result))) + ")"
	} else {
		txt = txt + HTMLHeroImage(ev.target, "landscape") + " " + Players.GetPlayerName(ev.target) + " " + $.Localize("#targeted") + " " + $.Localize("#nobody") + "."
	}
	p.SetBodyText(txt)
}

function DoResultWatch(ev) {
	var p = CreateResult(ev.target)
	var txt = InvestigationTopLine(ev.target)
	if (ev.result) {
		txt = txt + Players.GetPlayerName(ev.target) + " " + $.Localize("#was_targeted_by") + " "
		var targets_remaining = Object.keys(ev.result).length
		for (var i in ev.result) {
			txt = txt + Players.GetPlayerName(ev.result[i]) + " (" + GetHeroName(ev.result[i]) + ")"
			targets_remaining = targets_remaining - 1
			if (targets_remaining > 1) {
				txt = txt + ", "
			} else if (targets_remaining === 1) {
				txt = txt + " and "
			}
		}
		txt = txt + "."
	} else {
		txt = txt + Players.GetPlayerName(ev.target) + " " + $.Localize("#watch_nobody")
	}
	p.SetBodyText(txt)
}

function DoNoResult(ev) {
	// This happens if an action that would normally return a result fails due to roleblock, rolestop, etc.
	// Not showing anything to the player is a confusing UX.
	var p = CreateResult()
	p.SetBodyText($.Localize("#no_result"))
	var explanation = $.CreatePanel("Label", p, "")
	explanation.SetHasClass("result-body-smalltext", true)
	explanation.text = $.Localize("#no_result_explanation")
}


(function() {
GameEvents.Subscribe("result_investigation", DoResultInvestigation)
GameEvents.Subscribe("result_track", DoResultTrack)
GameEvents.Subscribe("result_watch", DoResultWatch)
GameEvents.Subscribe("no_result", DoNoResult)
})()