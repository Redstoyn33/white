/datum/job/cyborg
	title = JOB_CYBORG
	ru_title = "Киборг"
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "моим законам и ИИ"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 14
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	departments_list = list(
		/datum/job_department/silicon,
	)

	display_order = JOB_DISPLAY_ORDER_CYBORG

/datum/job/cyborg/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source = null)
	if(visualsOnly)
		CRASH("dynamic preview is unsupported")
	return H.Robotize(FALSE, latejoin)

/datum/job/cyborg/after_spawn(mob/living/silicon/robot/R, mob/M)
	. = ..()
	R.updatename(M.client)
	R.gender = NEUTER

/datum/job/cyborg/radio_help_message(mob/M)
	to_chat(M, "<b>Добавь :b перед сообщением, чтобы говорить с другими роботами и ИИ.</b>")
