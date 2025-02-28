/datum/round_event_control/blob
	name = "Масса"
	typepath = /datum/round_event/ghost_role/blob
	weight = 10
	max_occurrences = 1

	min_players = 20
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("blob") //Just in case a blob survives that long

/datum/round_event_control/blob/canSpawnEvent(players, gamemode)
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN) // no blobs if the shuttle is past the point of no return
		return FALSE

	return ..()

/datum/round_event/ghost_role/blob
	announceChance	= 0
	role_name = "blob overmind"
	fakeable = TRUE

/datum/round_event/ghost_role/blob/announce(fake)
	priority_announce("Подтвержденная вспышка биологической опасности уровня 5 на борту [station_name()]. Весь персонал должен противостоять эпидемии.", "Биологическая тревога", ANNOUNCER_OUTBREAK5)

/datum/round_event/ghost_role/blob/spawn_role()
	if(!GLOB.blobstart.len)
		return MAP_ERROR
	var/list/candidates = get_candidates(ROLE_BLOB, null, ROLE_BLOB)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/new_blob = pick(candidates)
	var/mob/camera/blob/BC = new_blob.become_overmind()
	spawned_mobs += BC
	message_admins("[ADMIN_LOOKUPFLW(BC)] has been made into a blob overmind by an event.")
	log_game("[key_name(BC)] was spawned as a blob overmind by an event.")
	return SUCCESSFUL_SPAWN
