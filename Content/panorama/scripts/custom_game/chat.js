var msgid = 0

function OnPlayerChat(ev) {
	var parent = $("#chat-contents")
	var needs_to_scroll = (parent.contentheight > parent.actuallayoutheight) && (parent.actuallayoutheight - parent.contentheight == parent.scrolloffset_y)
	msgid = msgid + 1
	ev.userid = ev.userid - 1
	var p = $.CreatePanel("Panel", parent, "chat-message-" + msgid)
	p.SetHasClass("chat-message", true)
	/*
	var img = $.CreatePanel("DOTAHeroImage", p, "")
	img.heroimagestyle = "landscape"
	img.heroname = Entities.GetClassname(Players.GetPlayerHeroEntityIndex(ev.userid))
	img.SetHasClass("chat-image", true)
	*/
	var lbl = $.CreatePanel("Label", p, "")
	lbl.html = true
	lbl.SetHasClass("chat-text", true)
	var contents = "<img class=\"chat-image\" src=\"file://{images}/heroes/" + Entities.GetClassname(Players.GetPlayerHeroEntityIndex(ev.userid)) + ".png\" /> "
	contents = contents + "<font color=\"#" + RGBAPlayerColor(ev.userid) + "\">"
	contents = contents + Players.GetPlayerName(ev.userid) + "</font>: " + ev.text
	lbl.text = contents
	if (needs_to_scroll) {
		parent.ScrollToBottom()
	}
}

function RGBAPlayerColor(id) {
	var abgr = Players.GetPlayerColor(id).toString(16)
	var rgba = abgr.substring(6,8) + abgr.substring(4,6) + abgr.substring(2,4) + abgr.substring(0,2)
	return rgba
}

(function() {
	GameEvents.Subscribe("player_chat", OnPlayerChat)
})()

for (var i = 1; i < 2000; i++) {
OnPlayerChat({userid: 1, text: "test"})
}
