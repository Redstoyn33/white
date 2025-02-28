/datum/antagonist/blob
	name = "Blob"
	roundend_category = "blobs"
	antagpanel_category = "Blob"
	show_to_ghosts = TRUE
	job_rank = ROLE_BLOB
	greentext_reward = 30

	var/datum/action/innate/blobpop/pop_action
	var/starting_points_human_blob = OVERMIND_STARTING_POINTS

/datum/antagonist/blob/roundend_report()
	var/basic_report = ..()
	//Display max blobpoints for blebs that lost
	if(isovermind(owner.current)) //embarrasing if not
		var/mob/camera/blob/overmind = owner.current
		if(!overmind.victory_in_progress) //if it won this doesn't really matter
			var/point_report = "<br><b>[owner.name]</b> захватил [overmind.max_count] клеток."
			return basic_report+point_report
	return basic_report

/datum/antagonist/blob/greet()
	if(!isovermind(owner.current))
		to_chat(owner,span_userdanger("Чет меня раздуло."))

/datum/antagonist/blob/on_gain()
	create_objectives()
	. = ..()

/datum/antagonist/blob/proc/create_objectives()
	var/datum/objective/blob_takeover/main = new
	main.owner = owner
	objectives += main

/datum/antagonist/blob/apply_innate_effects(mob/living/mob_override)
	if(!isovermind(owner.current))
		if(!pop_action)
			pop_action = new
		pop_action.Grant(owner.current)

/datum/objective/blob_takeover
	explanation_text = "Достичь критической массы!"
	reward = 40

//Non-overminds get this on blob antag assignment
/datum/action/innate/blobpop
	name = "Чпоньк"
	desc = "Высвободить массу"
	icon_icon = 'icons/mob/blob.dmi'
	button_icon_state = "blob"

/datum/action/innate/blobpop/Activate()
	var/mob/living/old_body = owner
	var/datum/antagonist/blob/blobtag = owner.mind.has_antag_datum(/datum/antagonist/blob)
	if(!blobtag)
		Remove()
		return
	var/mob/camera/blob/B = new /mob/camera/blob(get_turf(old_body), blobtag.starting_points_human_blob)
	owner.mind.transfer_to(B)
	old_body.gib()
	B.place_blob_core(placement_override = TRUE, pop_override = TRUE)

/datum/antagonist/blob/antag_listing_status()
	. = ..()
	if(owner?.current)
		var/mob/camera/blob/B = owner.current
		if(istype(B))
			. += "(Прогресс: [B.blobs_legit.len]/[B.blobwincount])"
