/obj/machinery/computer/virtualreality
	name = "virtual reality console"
	desc = "Used to control a virtual environment."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
//	circuit = /obj/item/weapon/circuitboard/virtualreality
	var/id = 0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed

/obj/machinery/computer/virtualreality/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "nullstation/virtualreality", name, 400, 200, master_ui, state)
		ui.open()

