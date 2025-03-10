/datum/job/freelancer
	title = JOB_FREELANCER
	ru_title = "Путешественник"
	department_head = list()
	faction = "Station"
	total_positions = 10
	spawn_positions = 10
	supervisors = "никому"
	selection_color = "#e005e4"

	exp_type = EXP_TYPE_CREW
	exp_requirements = 0

	outfit = /datum/outfit/job/freelancer

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_STA

	display_order = JOB_DISPLAY_ORDER_SPECIAL
	bounty_types = CIV_JOB_RANDOM

	departments_list = list(
		/datum/job_department/assistant,
	)

	rpg_title = "Freelancer"
	rpg_title_ru = "Путешественник"

	// пока так
	whitelisted = list("nikitauou", "valtosss")

/datum/outfit/job/freelancer
	name = JOB_FREELANCER
	jobtype = /datum/job/freelancer

	mask = /obj/item/clothing/mask/breath
	glasses = /obj/item/clothing/glasses/sunglasses

	r_pocket = /obj/item/kitchen/knife/combat
	l_pocket = /obj/item/gps

	back = /obj/item/mod/control/pre_equipped/prototype
	suit_store = /obj/item/tank/internals/tactical
	internals_slot = ITEM_SLOT_SUITSTORE

	id_trim = /datum/id_trim/job/freelancer

/datum/job/freelancer/override_latejoin_spawn(mob/living/carbon/human/H)
	if(SSmapping.spawn_type_shuttle(/datum/map_template/shuttle/freelancer/medium))
		for(var/_sloc in GLOB.start_landmarks_list)
			var/obj/effect/landmark/start/sloc = _sloc
			if(sloc.name != JOB_FREELANCER)
				continue
			H.forceMove(get_turf(sloc))
	return TRUE

/datum/outfit/job/freelancer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	return

/datum/outfit/job/freelancer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	spawn(50)
		var/obj/item/card/id/ID = H.get_idcard()
		if(ID)
			ID.registered_account.adjust_money(15000, 25000)

/datum/id_trim/job/freelancer
	assignment = JOB_FREELANCER
	trim_state = "trim_freelancer"
	full_access = list(ACCESS_MAINT_TUNNELS, ACCESS_AWAY_GENERAL)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_AWAY_GENERAL)
	config_job = "freelancer"
	template_access = list(ACCESS_CAPTAIN, ACCESS_HOP, ACCESS_CHANGE_IDS)

/obj/item/circuitboard/computer/freelancer
	build_path = /obj/machinery/computer/shuttle_flight/freelancer

/obj/machinery/computer/shuttle_flight/freelancer
	name = "Консоль Управления Фрегатом"
	desc = "Используется для управления данным быстрым и мобильным кораблём."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = COLOR_SOFT_RED
	req_access = list()
	circuit = /obj/item/circuitboard/computer/freelancer
	shuttleId = "freelancer_small"
	possible_destinations = "freelancer_small_custom"

/obj/machinery/computer/shuttle_flight/freelancer/LateInitialize()
	. = ..()
	launch_shuttle()

/area/shuttle/freelancer
	name = "Фрегат Путешественника"
	requires_power = TRUE
	area_flags = VALID_TERRITORY | UNIQUE_AREA
	ambience_index = AMBIENCE_NONE
	ambientsounds = SCARLET_DAWN_AMBIENT
	area_limited_icon_smoothing = /area/shuttle/freelancer

/area/shuttle/freelancer/cabine
	name = "Фрегат Путешественника: Кабина"

/area/shuttle/freelancer/cargo
	name = "Фрегат Путешественника: Трюм"

/area/shuttle/freelancer/passengers
	name = "Фрегат Путешественника: Пассажиры"

/area/shuttle/freelancer/rnd
	name = "Фрегат Путешественника: Исследования"

/area/shuttle/freelancer/med
	name = "Фрегат Путешественника: Медбей"

/obj/docking_port/mobile/freelancer
	name = "Фрегат Путешественника"
	id = "freelancer_small"
	ignitionTime = 5
	callTime = 5
	port_direction = 2
	preferred_direction = 1
