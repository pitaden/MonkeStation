// scrappables used for objectives


/obj/scrappable/objective/databank
	name = "Databank"
	desc = "The ship's databank. Some people would pay good money for the data on it."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "exonet_node_idle"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=2, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=2, "chance"=100),
		TOOL_WRENCH = list("tier"=2, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=2, "chance"=100),
		TOOL_MULTITOOL = list("tier"=3, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 8,
		/obj/item/stack/ore/glass/scrap = 6,
		/obj/item/stack/ore/gold/scrap = 5,
		/obj/item/stack/ore/silver/scrap = 5,
		/obj/item/scrap_objective/data_rack = 1
	)

/obj/scrappable/objective/blackbox
	name = "Blackbox Recorder"
	desc = "A blackbox recorder, containing the last moments of the ship's crew."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox_b"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=3, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=2, "chance"=100),
		TOOL_WRENCH = list("tier"=2, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=2, "chance"=100),
		TOOL_MULTITOOL = list("tier"=2, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 8,
		/obj/item/stack/ore/glass/scrap = 6,
		/obj/item/stack/ore/gold/scrap = 5,
		/obj/item/stack/ore/silver/scrap = 5,
		/obj/item/scrap_objective/blackbox = 1
	)

/obj/scrappable/objective/pirate_radio
	name = "Pirate Radio"
	desc = "A highly illegal radio, playing Nanotrasen's music without a license."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator-red"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=2, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=2, "chance"=100),
		TOOL_WRENCH = list("tier"=3, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=2, "chance"=100),
		TOOL_MULTITOOL = list("tier"=2, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 8,
		/obj/item/stack/ore/glass/scrap = 6,
		/obj/item/stack/ore/gold/scrap = 5,
		/obj/item/stack/ore/silver/scrap = 5,
		/obj/item/scrap_objective/radio_disk = 1
	)