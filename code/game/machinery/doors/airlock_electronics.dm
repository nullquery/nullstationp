/obj/item/weapon/electronics/airlock
	name = "airlock electronics"
	req_access = list(access_maint_tunnels)

	var/list/accesses = list()
	var/one_access = 0

/obj/item/weapon/electronics/airlock/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
													datum/tgui/master_ui = null, datum/ui_state/state = hands_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "airlock_electronics", name, 975, 420, master_ui, state)
		ui.open()

/obj/item/weapon/electronics/airlock/get_ui_data()
	var/list/data = list()
	var/list/regions = list()

	for(var/i in 1 to 7)
		var/list/region = list()
		var/list/accesses = list()
		for(var/j in get_region_accesses(i))
			var/list/access = list()
			access["name"] = get_access_desc(j)
			access["id"] = j
			access["req"] = (j in src.accesses)
			accesses[++accesses.len] = access
		region["name"] = get_region_accesses_name(i)
		region["accesses"] = accesses
		regions[++regions.len] = region
	data["regions"] = regions
	data["oneAccess"] = one_access

	return data

/obj/item/weapon/electronics/airlock/ui_act(action, params)
	switch(action)
		if("clear")
			accesses = list()
			one_access = 0
		if("one_access")
			one_access = !one_access
		if("set")
			var/access = text2num(params["access"])
			if (!(access in accesses))
				accesses += access
			else
				accesses -= access
	return 1
