// medical-related scrappables
// lots of silver

/obj/scrappable/sleeper
	name = "Sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

	required_tools = list(
		TOOL_CROWBAR = list("tier"=1, "chance"=100),
		TOOL_SCREWDRIVER = list("tier"=1, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=1, "chance"=100)
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 2,
		/obj/item/stack/ore/glass/scrap = 4,
		/obj/item/stack/ore/silver/scrap = 2
	)
	failure_effect = "Cold"

/obj/scrappable/cloning_pod
	name = "Cloning Pod"
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod0"

	required_tools = list(
		TOOL_SCREWDRIVER = list("tier"=1, "chance"=100),
		TOOL_WRENCH = list("tier"=1, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=1, "chance"=100),
		TOOL_MULTITOOL = list("tier"=1, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 4,
		/obj/item/stack/ore/glass/scrap = 3,
		/obj/item/stack/ore/silver/scrap = 3
	)
/obj/scrappable/cloning_scanner
	name = "Cloning Scanner"
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "scanner"

	required_tools = list(
		TOOL_SCREWDRIVER = list("tier"=1, "chance"=100),
		TOOL_WRENCH = list("tier"=1, "chance"=100),
		TOOL_WIRECUTTER = list("tier"=1, "chance"=100),
		TOOL_WELDER = list("tier"=1, "chance"=100),
	)
	scrap = list(
		/obj/item/stack/ore/iron/scrap = 5,
		/obj/item/stack/ore/glass/scrap = 2,
		/obj/item/stack/ore/silver/scrap = 2
	)