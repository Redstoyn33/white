//Assassin
/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "режет"
	attack_verb_simple = "режет"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	playstyle_string = span_holoparasite("As an <b>assassin</b> type you do medium damage and have no damage resistance, but can enter stealth, massively increasing the damage of your next attack and causing it to ignore armor. Stealth is broken when you attack or take damage.")
	magic_fluff_string = span_holoparasite("..And draw the Space Ninja, a lethal, invisible assassin.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Assassin modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one! It's an assassin carp! Just when you thought it was safe to go back to the water... which is unhelpful, because we're in space.")
	miner_fluff_string = span_holoparasite("You encounter... Glass, a sharp, fragile attacker.")
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode/assassin
	var/toggle = FALSE
	var/stealthcooldown = 160
	var/atom/movable/screen/alert/canstealthalert
	var/atom/movable/screen/alert/instealthalert

/mob/living/simple_animal/hostile/guardian/assassin/Initialize(mapload)
	. = ..()
	stealthcooldown = 0

/mob/living/simple_animal/hostile/guardian/assassin/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	updatestealthalert()
	if(loc == summoner && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/get_status_tab_items()
	. = ..()
	if(stealthcooldown >= world.time)
		. += "Stealth Cooldown Remaining: [DisplayTimeText(stealthcooldown - world.time)]"

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget()
	. = ..()
	if(.)
		if(toggle && (isliving(target) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
			ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && toggle)
		ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/Recall()
	if(..() && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/ToggleMode(forced = 0)
	if(toggle)
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		armour_penetration = initial(armour_penetration)
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		alpha = initial(alpha)
		if(!forced)
			to_chat(src, "<span class='danger'><B>You exit stealth.</span></B>")
		else
			visible_message(span_danger("<b>[src.name]</b> suddenly appears!"))
			stealthcooldown = world.time + initial(stealthcooldown) //we were forced out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(src.loc == summoner)
			to_chat(src, "<span class='danger'><B>You have to be manifested to enter stealth!</span></B>")
			return
		melee_damage_lower = 50
		melee_damage_upper = 50
		armour_penetration = 100
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE
		new /obj/effect/temp_visual/guardian/phase/out(get_turf(src))
		alpha = 15
		if(!forced)
			to_chat(src, "<span class='danger'><B>You enter stealth, empowering your next attack.</span></B>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(src, "<span class='danger'><B>You cannot yet enter stealth, wait another [DisplayTimeText(stealthcooldown - world.time)]!</span></B>")

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = throw_alert("instealth", /atom/movable/screen/alert/instealth)
				clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = throw_alert("canstealth", /atom/movable/screen/alert/canstealth)
				clear_alert("instealth")
				instealthalert = null
	else
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null
