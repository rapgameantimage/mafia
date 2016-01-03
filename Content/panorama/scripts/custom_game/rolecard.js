if ($.GetContextPanel().GetParent().paneltype === "DOTACustomUITypeContainer") {
// Root-level rolecard = player's rolecard.

	function OnDistributeRole(ev) {
		$.Msg(ev) 
		var context = $.GetContextPanel()
		context.FindChildrenWithClassTraverse("rolecard-rolename")[0].text = $.Localize(ev.role)
		context.FindChildrenWithClassTraverse("rolecard-description")[0].text = $.Localize(ev.role + "_description")
		context.FindChildrenWithClassTraverse("rolecard-win-condition")[0].text = $.Localize("win_condition_" + ev.alignment)
		context.SetHasClass("alignment-" + ev.alignment, true)
		if (ev.allies) {
			var allies_remaining = Object.keys(ev.allies).length
			var allystr = ""
			for (var i in ev.allies) {
				allystr = allystr + Players.GetPlayerName(parseInt(i)) + " (" + $.Localize(ev.allies[i]) + ")"
				allies_remaining = allies_remaining - 1
				if (allies_remaining > 1) { 
					allystr = allystr + ", " 
				} else if (allies_remaining === 1) {
					allystr = allystr + " and "
				}
			}
			if (Object.keys(ev.allies).length === 1) {
				context.FindChildrenWithClassTraverse("rolecard-allies")[0].text = allystr + " " + $.Localize("is_your_ally") + "."
			} else {
				context.FindChildrenWithClassTraverse("rolecard-allies")[0].text = $.Localize("your_allies_are") + " " + allystr + "."
			} 
			context.FindChildrenWithClassTraverse("rolecard-allies")[0].style.visibility = "visible"
		} else {
			context.FindChildrenWithClassTraverse("rolecard-allies")[0].style.visibility = "collapse"
		}
	}

	(function() {
		GameEvents.Subscribe("distribute_role", OnDistributeRole)
		GameEvents.SendCustomGameEventToServer("get_role", {})
	})()

} else {
// Some other rolecard.

 
}

function ShowRolecard() {
	if ($.GetContextPanel().GetParent().paneltype === "DOTACustomUITypeContainer") {
		$.GetContextPanel().SetHasClass("hide", false)
	}
}

function HideRolecard() {
	if ($.GetContextPanel().GetParent().paneltype === "DOTACustomUITypeContainer") {
		$.GetContextPanel().SetHasClass("hide", true)
	} else {
		$.GetContextPanel().GetParent().RemoveAndDeleteChildren()
	}
}

var ALIGNMENT_TOWN = 0
var ALIGNMENT_MAFIA = 1
var ALIGNMENT_WEREWOLVES = 2
var ALIGNMENT_SERIAL_KILLER = 3