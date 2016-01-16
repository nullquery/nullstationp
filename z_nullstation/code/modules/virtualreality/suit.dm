/obj/item/clothing/glasses/vrgoggles
	name = "virtual reality goggles"
	//desc = "Such a dapper eyepiece!"
	icon = 'z_nullstation/icons/obj/clothing/glasses.dmi'
	icon_state = "vrgoggles"
	alternate_worn_icon = 'z_nullstation/icons/mob/eyes.dmi'
	item_state = "vrgoggles"

/obj/item/clothing/gloves/vrgloves
	name = "virtual reality gloves"
	//desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon = 'z_nullstation/icons/obj/clothing/gloves.dmi'
	icon_state = "vrgloves"
	alternate_worn_icon = 'z_nullstation/icons/mob/hands.dmi'
	item_state = "vrgloves"

/obj/item/clothing/shoes/vrshoes
	name = "virtual reality shoes"
	//desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon = 'z_nullstation/icons/obj/clothing/shoes.dmi'
	icon_state = "vrshoes"
	alternate_worn_icon = 'z_nullstation/icons/mob/feet.dmi'
	item_state = "vrshoes"

/obj/item/clothing/suit/vrsuit
	name = "virtual reality suit"
	//desc = "A suit that protects against radiation. The label reads, 'Made with lead. Please do not consume insulation.'"
	icon = 'z_nullstation/icons/obj/clothing/suits.dmi'
	icon_state = "vrsuit"
	alternate_worn_icon = 'z_nullstation/icons/mob/suit.dmi'
	item_state = "vrsuit"
	w_class = 4 // bulky item
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 0.5

	// Negative to energy due to the electrical components
	armor = list(melee = 0, bullet = 0, laser = 0, energy = -5, bomb = 0, bio = 0, rad = 0)

	strip_delay = 40
	put_on_delay = 40
	flags_inv = HIDEJUMPSUIT
