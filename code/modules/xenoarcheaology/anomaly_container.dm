/obj/structure/anomaly_container
	name = "anomaly container"
	desc = "Used to safely contain and move anomalies."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anomaly_container"
	density = TRUE

	var/obj/machinery/artifact/contained

/obj/structure/anomaly_container/Initialize()
	. = ..()

	var/obj/machinery/artifact/A = locate() in loc
	if(A)
		contain(A)

/obj/structure/anomaly_container/Destroy()
	release()
	. = ..()

/obj/structure/anomaly_container/attack_hand(var/mob/user)
	release(user)

/obj/structure/anomaly_container/attack_robot(var/mob/user)
	if(Adjacent(user))
		release(user)

/obj/structure/anomaly_container/proc/contain(var/obj/machinery/artifact/artifact, var/mob/user)
	if(contained)
		return
	contained = artifact
	contained.forceMove(src)
	contained.stasis = TRUE
	underlays += image(contained)
	playsound(loc, 'sound/machines/bolts_down.ogg', 50, 1)
	if(user)
		user.visible_message(SPAN_NOTICE("[user] puts [artifact] into \the [src]."), SPAN_NOTICE("You put [artifact] into \the [src]."))

/obj/structure/anomaly_container/proc/release(var/mob/user)
	if(!contained)
		return
	contained.dropInto(src)
	contained.stasis = FALSE
	contained = null
	underlays.Cut()
	playsound(loc, 'sound/machines/bolts_up.ogg', 50, 1)
	if(user)
		user.visible_message(SPAN_NOTICE("[user] opens \the [src]."), SPAN_NOTICE("You open \the [src]."))

/obj/structure/anomaly_container/examine(mob/user)
	. = ..()
	if(contained)
		to_chat(user, "\The [contained] is kept inside.")

/obj/machinery/artifact/MouseDrop(var/obj/structure/anomaly_container/over_object)
	if(istype(over_object) && Adjacent(over_object) && CanMouseDrop(over_object, usr))
		Bumped(usr)
		over_object.contain(src, usr)
