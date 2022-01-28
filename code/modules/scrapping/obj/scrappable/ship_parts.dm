// scrappables unique to ships

/obj/scrappable/ship/laser
	name = "Ship Laser"
	desc = "A broken ship-mounted laser cannon."
	icon = 'icons/obj/scrapping/objects.dmi'
	icon_state = "laser_placeholder"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=1, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=1, "chance"=100),
		TOOL_WRENCH = list("tier"=1, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=2, "chance"=100),
		TOOL_MULTITOOL = list("tier"=2, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 8,
		/obj/item/stack/ore/glass/scrap = 6,
		/obj/item/stack/ore/plasma/scrap = 5,
		/obj/item/stack/ore/diamond/scrap = 2
	)
	failure_effect = "Fire"

/obj/scrappable/ship/ballistic
	name = "Ship Railgun"
	desc = "A broken ship-mounted railgun."
	icon = 'icons/obj/scrapping/objects.dmi'
	icon_state = "ballistic_placeholder"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=1, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=1, "chance"=100),
		TOOL_WRENCH = list("tier"=1, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=2, "chance"=100),
		TOOL_MULTITOOL = list("tier"=2, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 10,
		/obj/item/stack/ore/glass/scrap = 4,
		/obj/item/stack/ore/plasma/scrap = 5,
		/obj/item/stack/ore/gold/scrap = 6
	)
	failure_effect = "Fire"

/obj/scrappable/ship/missile
	name = "Ship Missile Launcher"
	desc = "A broken ship-mounted missile launcher."
	icon = 'icons/obj/scrapping/objects.dmi'
	icon_state = "missile_placeholder"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=1, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=1, "chance"=100),
		TOOL_WRENCH = list("tier"=1, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=2, "chance"=100),
		TOOL_MULTITOOL = list("tier"=2, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 15,
		/obj/item/stack/ore/glass/scrap = 5,
		/obj/item/stack/ore/plasma/scrap = 10,
		/obj/item/stack/ore/titanium/scrap = 8
	)
	failure_effect = "Explosion"

/obj/scrappable/ship/reactor
	name = "Nuclear Reactor"
	desc = "A reactor built to power a ship. Right now, this one isn't powering anything."
	icon = 'icons/obj/scrapping/objects.dmi'
	icon_state = "reactor_placeholder"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=2, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=3, "chance"=100),
		TOOL_WRENCH = list("tier"=1, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=1, "chance"=100),
		TOOL_MULTITOOL = list("tier"=2, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 30,
		/obj/item/stack/ore/plasma/scrap = 10,
		/obj/item/stack/ore/uranium/scrap = 20,
		/obj/item/stack/ore/titanium/scrap = 10
	)
	failure_effect = "Radiation"