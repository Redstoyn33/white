/obj/structure/closet/crate/critter
	name = "ящик для животных"
	desc = "Ящик, предназначенный для безопасной перевозки животных. Он имеет кислородный баллон для безопасной транспортировки в космосе. «Животных в загон»"
	icon_state = "crittercrate"
	horizontal = FALSE
	allow_objects = FALSE
	breakout_time = 600
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	contents_pressure_protection = 0.8
	var/obj/item/tank/internals/emergency_oxygen/tank

/obj/structure/closet/crate/critter/Initialize(mapload)
	. = ..()
	tank = new

/obj/structure/closet/crate/critter/Destroy()
	var/turf/T = get_turf(src)
	if(tank)
		tank.forceMove(T)
		tank = null

	return ..()

/obj/structure/closet/crate/critter/update_icon_state()
	return

/obj/structure/closet/crate/critter/update_overlays()
	. = ..()
	if(opened)
		. += "crittercrate_door_open"
	else
		. += "crittercrate_door"
		if(manifest)
			. += "manifest"

/obj/structure/closet/crate/critter/return_air()
	if(tank)
		return tank.air_contents
	else
		return loc.return_air()

/obj/structure/closet/crate/critter/return_analyzable_air()
	if(tank)
		return tank.return_analyzable_air()
	else
		return null
