//todo
/datum/artifact_effect/dnaswitch
	name = "dnaswitch"
	possible_effect_types = list(EFFECT_TOUCH, EFFECT_AURA, EFFECT_PULSE)
	var/severity

/datum/artifact_effect/dnaswitch/getDescription()
	return "The artifact emits unstable genetical aura."

/datum/artifact_effect/dnaswitch/New()
	..()
	if(effect_type == EFFECT_AURA)
		severity = rand(5,30)
	else
		severity = rand(25,95)

/datum/artifact_effect/dnaswitch/proc/get_feeling()
	return pick(" feel a little different"," feel very strange","r stomach churns","r skin feels loose"," feel a stabbing pain in your head"," feel a tingling sensation in your chest","r entire body vibrates")

/datum/artifact_effect/dnaswitch/DoEffect(mob/toucher)
	var/weakness = GetAnomalySusceptibility(toucher)
	if(ishuman(toucher) && prob(weakness * 100))
		to_chat(toucher, "<span class='alium'>You[get_feeling()].</span>")
		if(prob(75))
			scramble(1, toucher, weakness * severity)
		else
			scramble(0, toucher, weakness * severity)
	return 1

/datum/artifact_effect/dnaswitch/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/carbon/human/H in range(range, T))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(30))
					to_chat(H, "<span class='alium'>You[get_feeling()].</span>")
				if(prob(50))
					scramble(1, H, weakness * severity)
				else
					scramble(0, H, weakness * severity)

/datum/artifact_effect/dnaswitch/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for(var/mob/living/carbon/human/H in range(range, T))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(75))
					to_chat(H, "<span class='alium'>You[get_feeling()].</span>")
				if(prob(25))
					if(prob(75))
						scramble(1, H, weakness * severity)
					else
						scramble(0, H, weakness * severity)
