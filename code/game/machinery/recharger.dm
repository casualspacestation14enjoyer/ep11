//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/recharger
	name = "recharger"
	desc = "An all-purpose recharger for a variety of devices."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = TRUE
	idle_power_usage = 4
	active_power_usage = 30 KILOWATTS
	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	var/lowest_active_power_usage = 30 KILOWATTS // Used for RefreshParts() proc
	var/obj/item/charging = null
	var/list/allowed_devices = list(/obj/item/gun/energy, /obj/item/gun/magnetic/railgun, /obj/item/melee/baton, /obj/item/cell, /obj/item/modular_computer/, /obj/item/device/suit_sensor_jammer, /obj/item/stock_parts/computer/battery_module, /obj/item/shield_diffuser, /obj/item/clothing/mask/smokable/ecig, /obj/item/device/radio)
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0" //also when unpowered
	var/icon_state_open = "recharger-open" // When panel is open
	var/portable = 1

/obj/machinery/recharger/attackby(obj/item/G as obj, mob/user as mob)
	var/allowed = FALSE
	for(var/allowed_type in allowed_devices)
		if(istype(G, allowed_type))
			allowed = TRUE

	if(allowed)
		if(panel_open)
			to_chat(user, "<span class='warning'>Close the panel first.</span>")
			return
		if(charging)
			to_chat(user, "<span class='warning'>\A [charging] is already charging here.</span>")
			return
		// Checks to make sure he's not in space doing it, and that the area got proper power.
		if(!powered())
			to_chat(user, "<span class='warning'>The [name] blinks red as you try to insert the item!</span>")
			return
		if (istype(G, /obj/item/gun/energy/))
			var/obj/item/gun/energy/E = G
			if(E.self_recharge)
				to_chat(user, "<span class='notice'>You can't find a charging port on \the [E].</span>")
				return
		if(!G.get_cell())
			to_chat(user, "This device does not have a battery installed.")
			return

		if(user.unEquip(G))
			G.forceMove(src)
			charging = G
		return

	if(portable && isWrench(G) && !panel_open)
		if(charging)
			to_chat(user, "<span class='warning'>Remove [charging] first!</span>")
			return
		anchored = !anchored
		to_chat(user, "You [anchored ? "attached" : "detached"] the recharger.")
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
		return

	..()
	update_icon()

/obj/machinery/recharger/physical_attack_hand(mob/user)
	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		update_icon()
		return TRUE

/obj/machinery/recharger/Process()
	if(panel_open)
		icon_state = icon_state_open
		return

	if(stat & (NOPOWER|BROKEN) || !anchored)
		update_use_power(POWER_USE_OFF)
		icon_state = icon_state_idle
		return

	if(!charging)
		update_use_power(POWER_USE_IDLE)
		icon_state = icon_state_idle
		return

	var/obj/item/cell/C = charging.get_cell()
	if(istype(C))
		if(!C.fully_charged())
			icon_state = icon_state_charging
			C.give(active_power_usage*CELLRATE)
			update_use_power(POWER_USE_ACTIVE)
		else
			icon_state = icon_state_charged
			update_use_power(POWER_USE_IDLE)

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return
	if(charging)
		var/obj/item/cell/C = charging.get_cell()
		if(istype(C))
			C.emp_act(severity)
	..(severity)

/obj/machinery/recharger/on_update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(panel_open)
		icon_state = icon_state_open
	else if(charging)
		icon_state = icon_state_charging
	else
		icon_state = icon_state_idle

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	to_chat(user, "Current charge rate is [active_power_usage / (1 KILOWATTS)] kilowatts.")
	if(isnull(charging))
		return

	var/obj/item/cell/C = charging.get_cell()
	if(!isnull(C))
		to_chat(user, "Item's charge at [round(C.percent())]%.")

/obj/machinery/recharger/RefreshParts()
	..()
	active_power_usage = (lowest_active_power_usage / 2) * Clamp(total_component_rating_of_type(/obj/item/stock_parts/capacitor), 1, 10)

/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	desc = "A heavy duty wall recharger specialized for energy weaponry."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"
	active_power_usage = 50 KILOWATTS
	lowest_active_power_usage = 100 KILOWATTS // If we ever make it buildable - keep in mind that it is currently
											 // divided by 2 due to lack of any components
	allowed_devices = list(/obj/item/gun/magnetic/railgun, /obj/item/gun/energy, /obj/item/melee/baton, /obj/item/device/radio)
	icon_state_charged = "wrecharger2"
	icon_state_charging = "wrecharger1"
	icon_state_idle = "wrecharger0"
	portable = 0
	construct_state = null // Unable to be built normally.
	uncreated_component_parts = list(/obj/item/stock_parts/power/apc)
