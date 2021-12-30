/obj/item/dyespray
	name = "hair dye spray"
	desc = "A spray to dye your hair any gradients you'd like."
	icon = 'icons/obj/dyespray.dmi'
	icon_state = "dyespray"
	onflooricon = 'icons/wod13/onfloor.dmi'

/obj/item/dyespray/attack_self(mob/user)
	dye(user)

/obj/item/dyespray/pre_attack(atom/target, mob/living/user, params)
	dye(target)
	return ..()

/**
 * Applies a gradient and a gradient color to a mob.
 *
 * Arguments:
 * * target - The mob who we will apply the gradient and gradient color to.
 */

/obj/item/dyespray/proc/dye(mob/target)
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/human_target = target
	var/beard_or_hair = tgui_alert(user, "What do you want to dye?", "Character Preference", list("Hair", "Facial Hair"))
	if(!beard_or_hair || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE))
		return

	var/list/choices = beard_or_hair == "Hair" ? GLOB.hair_gradients_list : GLOB.facial_hair_gradients_list
	var/new_grad_style = tgui_input_list(user, "Choose a color pattern", "Character Preference", choices)
	if(isnull(new_grad_style))
		return
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE))
		return

	human_target.grad_style = new_grad_style
	human_target.grad_color = sanitize_hexcolor(new_grad_color)
	to_chat(human_target, "<span class='notice'>You start applying the hair dye...</span>")
	if(!do_after(usr, 3 SECONDS, target))
		return
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
	human_target.update_hair()
