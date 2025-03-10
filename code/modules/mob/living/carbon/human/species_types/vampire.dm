/datum/species/vampire
	name = "Vampire"
	id = "vampire"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,DRINKSBLOOD, HAS_FLESH, HAS_BONE)
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER,TRAIT_NOHUNGER,TRAIT_NOBREATH,TRAIT_CAN_STRIP,TRAIT_NOHYDRATION)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutant_bodyparts = list("tail_human" = "None", "ears" = "None", "wings" = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	exotic_bloodtype = "U"
	use_skintones = TRUE
	mutantheart = /obj/item/organ/heart/vampire
	mutanttongue = /obj/item/organ/tongue/vampire
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	var/info_text = "You are a <span class='danger'>Vampire</span>. You will slowly but constantly lose blood if outside of a coffin. If inside a coffin, you will slowly heal. You may gain more blood by grabbing a live victim and using your drain ability."

/datum/species/vampire/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/datum/species/vampire/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")
	C.skin_tone = "albino"
	C.update_body(0)
	C.set_safe_hunger_level()

/datum/species/vampire/spec_life(mob/living/carbon/human/C, delta_time, times_fired)
	. = ..()
	if(istype(C.loc, /obj/structure/closet/crate/coffin))
		C.heal_overall_damage(2 * delta_time, 2 * delta_time, 0, BODYPART_ORGANIC)
		C.adjustToxLoss(-2 * delta_time)
		C.adjustOxyLoss(-2 * delta_time)
		C.adjustCloneLoss(-2 * delta_time)
		return
	C.blood_volume -= 0.125 * delta_time
	if(C.blood_volume <= BLOOD_VOLUME_SURVIVE)
		to_chat(C, span_danger("You ran out of blood!"))
		var/obj/shapeshift_holder/H = locate() in C
		if(H)
			H.shape.dust() //make sure we're killing the bat if you are out of blood, if you don't it creates weird situations where the bat is alive but the caster is dusted.
		C.dust()
	var/area/A = get_area(C)
	if(istype(A, /area/service/chapel))
		to_chat(C, span_warning("You don't belong here!"))
		C.adjustFireLoss(10 * delta_time)
		C.adjust_fire_stacks(3 * delta_time)
		C.ignite_mob()

/datum/species/vampire/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/nullrod/whip))
		return 2 //Whips deal 2x damage to vampires. Vampire killer.
	return 1

/obj/item/organ/tongue/vampire
	name = "vampire tongue"
	actions_types = list(/datum/action/item_action/organ_action/vampire)
	color = "#1C1C1C"
	var/drain_cooldown = 0

#define VAMP_DRAIN_AMOUNT 50

/datum/action/item_action/organ_action/vampire
	name = "Drain Victim"
	desc = "Leech blood from any carbon victim you are passively grabbing."

/datum/action/item_action/organ_action/vampire/Trigger(trigger_flags)
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		var/obj/item/organ/tongue/vampire/V = target
		if(V.drain_cooldown >= world.time)
			to_chat(H, span_warning("You just drained blood, wait a few seconds!"))
			return
		if(H.pulling && iscarbon(H.pulling))
			var/mob/living/carbon/victim = H.pulling
			if(H.blood_volume >= BLOOD_VOLUME_MAXIMUM)
				to_chat(H, span_warning("You're already full!"))
				return
			if(victim.stat == DEAD)
				to_chat(H, span_warning("You need a living victim!"))
				return
			if(!victim.blood_volume || (victim.dna && ((NOBLOOD in victim.dna.species.species_traits) || victim.dna.species.exotic_blood)))
				to_chat(H, span_warning("[victim] doesn't have blood!"))
				return
			V.drain_cooldown = world.time + 30
			if(victim.anti_magic_check(FALSE, TRUE, FALSE, 0))
				to_chat(victim, span_warning("[H] tries to bite you, but stops before touching you!"))
				to_chat(H, span_warning("[victim] is blessed! You stop just in time to avoid catching fire."))
				return
			if(victim.has_reagent(/datum/reagent/consumable/garlic))
				to_chat(victim, span_warning("[H] tries to bite you, but recoils in disgust!"))
				to_chat(H, span_warning("[victim] reeks of garlic! you can't bring yourself to drain such tainted blood."))
				return
			if(!do_after(H, 30, target = victim))
				return
			var/blood_volume_difference = BLOOD_VOLUME_MAXIMUM - H.blood_volume //How much capacity we have left to absorb blood
			var/drained_blood = min(victim.blood_volume, VAMP_DRAIN_AMOUNT, blood_volume_difference)
			to_chat(victim, span_danger("[H] is draining your blood!"))
			to_chat(H, span_notice("You drain some blood!"))
			playsound(H, 'sound/items/drink.ogg', 30, TRUE, -2)
			victim.blood_volume = clamp(victim.blood_volume - drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			H.blood_volume = clamp(H.blood_volume + drained_blood, 0, BLOOD_VOLUME_MAXIMUM)
			if(!victim.blood_volume)
				to_chat(H, span_notice("You finish off [victim] blood supply."))

#undef VAMP_DRAIN_AMOUNT


/mob/living/carbon/get_status_tab_items()
	. = ..()
	var/obj/item/organ/heart/vampire/darkheart = getorgan(/obj/item/organ/heart/vampire)
	if(darkheart)
		. += "Уровень крови: [blood_volume]/[BLOOD_VOLUME_MAXIMUM]."


/obj/item/organ/heart/vampire
	name = "vampire heart"
	color = "#1C1C1C"
