//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	var/obj/item/clothing/head/hood
	var/hoodtype = /obj/item/clothing/head/winterhood //so the chaplain hoodie or other hoodies can override this

/obj/item/clothing/suit/hooded/New()
	MakeHood()
	..()

/obj/item/clothing/suit/hooded/Destroy()
	qdel(hood)
	return ..()

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/W = new hoodtype(src)
		hood = W

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(slot != slot_wear_suit)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	src.icon_state = "[initial(icon_state)]"
	suittoggled = 0
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.unEquip(hood, 1)
		H.update_inv_wear_suit()
	hood.loc = src

/obj/item/clothing/suit/hooded/dropped()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!suittoggled)
		if(ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if(H.wear_suit != src)
				H << "<span class='warning'>You must be wearing [src] to put up the hood!</span>"
				return
			if(H.head)
				H << "<span class='warning'>You're already wearing something on your head!</span>"
				return
			else
				H.equip_to_slot_if_possible(hood,slot_head,0,0,1)
				suittoggled = 1
				src.icon_state = "[initial(icon_state)]_t"
				H.update_inv_wear_suit()
	else
		RemoveHood()

//Toggle exosuits for different aesthetic styles (hoodies, suit jacket buttons, etc)

/obj/item/clothing/suit/toggle/AltClick(mob/user)
	..()
	if(!user.canUseTopic(user))
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		suit_toggle(user)

/obj/item/clothing/suit/toggle/ui_action_click()
	suit_toggle()

/obj/item/clothing/suit/toggle/proc/suit_toggle()
	set src in usr

	if(!can_use(usr))
		return 0

	usr << "<span class='notice'>You toggle [src]'s [togglename].</span>"
	if(src.suittoggled)
		src.icon_state = "[initial(icon_state)]"
		src.suittoggled = 0
	else if(!src.suittoggled)
		src.icon_state = "[initial(icon_state)]_t"
		src.suittoggled = 1
	usr.update_inv_wear_suit()

/obj/item/clothing/suit/toggle/examine(mob/user)
	..()
	user << "Alt-click on [src] to toggle the [togglename]."

//Hardsuit toggle code
/obj/item/clothing/suit/space/hardsuit/New()
	MakeHelmet()
	if(!jetpack)
		verbs -= /obj/item/clothing/suit/space/hardsuit/verb/Jetpack
		verbs -= /obj/item/clothing/suit/space/hardsuit/verb/Jetpack_Rockets
	..()
/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(helmet)
		helmet.suit = null
		qdel(helmet)
	qdel(jetpack)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(suit)
		suit.helmet = null
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	if(!helmettype)
		return
	if(slot != slot_wear_suit)
		RemoveHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmet)
		return
	suittoggled = 0
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.unEquip(helmet, 1)
		H.update_inv_wear_suit()
		H << "<span class='notice'>The helmet on the hardsuit disengages.</span>"
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	helmet.loc = src

/obj/item/clothing/suit/space/hardsuit/dropped()
	RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!helmet)
		return
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				H << "<span class='warning'>You must be wearing [src] to engage the helmet!</span>"
				return
			if(H.head)
				H << "<span class='warning'>You're already wearing something on your head!</span>"
				return
			else
				H << "<span class='notice'>You engage the helmet on the hardsuit.</span>"
				H.equip_to_slot_if_possible(helmet,slot_head,0,0,1)
				suittoggled = 1
				H.update_inv_wear_suit()
				playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	else
		RemoveHelmet()
