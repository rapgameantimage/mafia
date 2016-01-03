var chatpanelcount = 0
var max_messages = 100
var archive = []
var issued_message_warning = false

function OnPlayerChat(ev) {
	if (Game.IsPlayerMuted(ev.userid - 1)) {
		return
	}

	var parent = $("#chat-contents")

	// If there's a scrollbar and we're at the bottom, we'll want to scroll down when we finish here
	var needs_to_scroll = (parent.contentheight > parent.actuallayoutheight) && (parent.actuallayoutheight - parent.contentheight == parent.scrolloffset_y)
	
	// Create the panel for this chat
	ev.userid = ev.userid - 1
	CreateChatLabel(ev.userid, ev.text)

	// If we have too many messages, archive one
	if (parent.Children().length > max_messages + 1) {
		if (archive.length === 0) {
			// Need to make the load more button appear
			$("#archive-button").SetHasClass("hide", false)
		}
		var oldest = parent.GetChild(1)
		archive.push({
			player: oldest.GetAttributeInt("player", -1),
			text: oldest.GetAttributeString("text", "There was an error saving this message.")
		})
		oldest.DeleteAsync(0)
	}

	// Scroll if we decided we need to
	if (needs_to_scroll) {
		parent.ScrollToBottom()
	}
}

function CreateChatLabel(player, text) {
	var parent = $("#chat-contents")
	chatpanelcount = chatpanelcount + 1
	var lbl = $.CreatePanel("Label", parent, "")
	lbl.html = true
	lbl.SetHasClass("chat-text", true)
	lbl.SetAttributeInt("player", player)
	lbl.SetAttributeString("text", text)
	var contents = "<img class=\"chat-image\" src=\"file://{images}/heroes/" + Entities.GetClassname(Players.GetPlayerHeroEntityIndex(player)) + ".png\" /> "
	contents = contents + "<font color=\"#" + RGBAPlayerColor(player) + "\">"
	contents = contents + Players.GetPlayerName(player) + "</font>: " + text
	lbl.text = contents
	return lbl
}

function RGBAPlayerColor(id) {
	var abgr = Players.GetPlayerColor(id).toString(16)
	var rgba = abgr.substring(6,8) + abgr.substring(4,6) + abgr.substring(2,4) + abgr.substring(0,2)
	return rgba
}

function LoadMessages() {
	for (var i = 0; i < 100; i++) {
		if (archive.length === 0) {
			$("#archive-button").SetHasClass("hide", true)
			break
		}
		var msg = archive.pop()
		var lbl = CreateChatLabel(msg.player, msg.text)
		var parent = lbl.GetParent()
		parent.MoveChildBefore(lbl, parent.GetChild(1))
	}
	if ($("#chat-contents").Children().length > 300 && !issued_message_warning) {
		$.DispatchEvent("DOTAShowTextTooltip", $("#show-button"), "#messages_warning")
		issued_message_warning = true
		$.Schedule(3, function() {$.DispatchEvent("DOTAHideTextTooltip")})
	}
}

function HideChat() {
	$.GetContextPanel().SetHasClass("hide", true)
}

function ShowChat() {
	$.GetContextPanel().SetHasClass("hide", false)
}

function ArchiveBacklog() {

}

(function() {
	GameEvents.Subscribe("player_chat", OnPlayerChat)
})()
/*
for (var i = 1; i < 50; i++) {
	var length = 10
OnPlayerChat({userid: 1, text: Math.round((Math.pow(36, length + 1) - Math.random() * Math.pow(36, length))).toString(36).slice(1)})
}
*/