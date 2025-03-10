#define CULT_SCALING_COEFFICIENT 9.3 //Roughly one new cultist at roundstart per this many players

/datum/game_mode
	var/list/datum/mind/cult = list()

/proc/iscultist(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/cult)

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)
	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/proc/is_convertable_to_cult(mob/living/M,datum/team/cult/specific_cult)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.holy_role))
			return FALSE
		if(specific_cult?.is_sacrifice_target(M.mind))
			return FALSE
		if(is_servant_of_ratvar(M))
			return FALSE
		if(M.mind.enslaved_to && !iscultist(M.mind.enslaved_to))
			return FALSE
		if(M.mind.unconvertable)
			return FALSE
	else
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD) || issilicon(M) || isbot(M) || isdrone(M) || !M.client)
		return FALSE //can't convert machines, shielded, or braindead
	return TRUE

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	report_type = "cult"
	antag_flag = ROLE_CULTIST
	false_report_weight = 10
	restricted_jobs = list(JOB_PRISONER, JOB_CHAPLAIN,JOB_AI, JOB_CYBORG, JOB_RUSSIAN_OFFICER, JOB_TRADER, JOB_HACKER,JOB_VETERAN, JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_DETECTIVE, JOB_HEAD_OF_SECURITY, JOB_CAPTAIN, JOB_HEAD_OF_PERSONNEL, JOB_FIELD_MEDIC)
	protected_jobs = list()
	required_players = 29
	required_enemies = 4
	recommended_enemies = 4
	enemy_minimum_age = 14

	announce_span = "cult"
	announce_text = "Some crew members are trying to start a cult to Nar'Sie!\n\
	<span class='cult'>Cultists</span>: Carry out Nar'Sie's will.\n\
	<span class='notice'>Crew</span>: Prevent the cult from expanding and drive it out."

	var/acolytes_needed = 10 //for the survive objective
	var/acolytes_survived = 0

	var/list/cultists_to_cult = list() //the cultists we'll convert

	var/datum/team/cult/main_cult


/datum/game_mode/cult/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_ASSISTANT

	//cult scaling goes here
	recommended_enemies = 1 + round(num_players()/CULT_SCALING_COEFFICIENT)
	var/remaining = (num_players() % CULT_SCALING_COEFFICIENT) * 10 //Basically the % of how close the population is toward adding another cultis
	if(prob(remaining))
		recommended_enemies++

	recommended_enemies = max(recommended_enemies, required_enemies)

	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = antag_pick(antag_candidates)
		antag_candidates -= cultist
		cultists_to_cult += cultist
		cultist.special_role = ROLE_CULTIST
		cultist.restricted_roles = restricted_jobs
		log_game("[key_name(cultist)] has been selected as a cultist")

	if(cultists_to_cult.len>=required_enemies)
		for(var/antag in cultists_to_cult)
			GLOB.pre_setup_antags += antag
		return TRUE
	else
		setup_error = "Not enough cultist candidates"
		return FALSE


/datum/game_mode/cult/post_setup()
	main_cult = new

	for(var/datum/mind/cult_mind in cultists_to_cult)
		add_cultist(cult_mind, 0, equip=TRUE, cult_team = main_cult)
		GLOB.pre_setup_antags -= cult_mind

	main_cult.setup_objectives() //Wait until all cultists are assigned to make sure none will be chosen as sacrifice.

	. = ..()

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind, stun , equip = FALSE, datum/team/cult/cult_team = null)
	if (!istype(cult_mind))
		return FALSE

	var/datum/antagonist/cult/new_cultist = new()
	new_cultist.give_equipment = equip

	if(cult_mind.add_antag_datum(new_cultist,cult_team))
		if(stun)
			cult_mind.current.Unconscious(100)
		return TRUE

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, silent, stun)
	if(cult_mind.current)
		var/datum/antagonist/cult/cult_datum = cult_mind.has_antag_datum(/datum/antagonist/cult)
		if(!cult_datum)
			return FALSE
		cult_datum.silent = silent
		cult_mind.remove_antag_datum(cult_datum)
		if(stun)
			cult_mind.current.Unconscious(100)
		return TRUE

/datum/game_mode/cult/proc/check_cult_victory()
	return main_cult.check_cult_victory()


/datum/game_mode/cult/set_round_result()
	..()
	if(check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE

/datum/game_mode/cult/proc/check_survive()
	var/acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if (cult_mind.current && cult_mind.current.stat != DEAD)
			if(cult_mind.current.onCentCom() || cult_mind.current.onSyndieBase())
				acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return FALSE
	else
		return TRUE


/datum/game_mode/cult/generate_report()
	return "Некоторые станции в вашем секторе сообщили о кровавых жертвоприношениях и странной магии. Было доказано, что связи с Федерацией волшебников не существуют, и многие сотрудники \
			исчез; даже сотрудники Центрального командования, находящиеся на расстоянии световых лет от нас, ощущали странное присутствие и временами истерическое принуждение. Допросы указывают на то, что это работа \
			культ Нар'Си. Если на борту вашей станции будут обнаружены доказательства этого культа, следует проявлять крайнюю осторожность и предельную бдительность, и все ресурсы должны быть направлены на то, чтобы \
			остановить этот культ. Обратите внимание, что святая вода, кажется, ослабляет и в конечном итоге возвращает умы культистов, которые ее глотают, а имплантаты щита разума полностью предотвратят обращение."

#undef CULT_SCALING_COEFFICIENT
