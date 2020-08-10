#include <a_samp>
#include <crashdetect>
#include <a_mysql>
#include <YSI\y_ini>
#include <sscanf2>
#include <zcmd>
#include <progress>
#include <mapandreas>
#include <PreviewModelDialog>
#include <FCNPC>
#include <colandreas>
#include <streamer>
#include <foreach>
#include <strlib>

////////////////////////////////////////////////////////////////////////////////
// DEFINES /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define MYSQL_DETAILS_FILE      "just_aftermath/server_data/mysql.ini"

#define CREATED_ITEMS_FILE      "just_aftermath/items/created_items/items.txt"

#define SERVER_NAME             "Just : Aftermath [Zombie Roleplay]"
#define SERVER_MODE             "Zombie Roleplay"
#define SERVER_LANGUAGE         "English"
#define SERVER_WEBSITE          "www.yourwebsite.com"
#define SERVER_TAG              "{FED85D}[Aftermath]{FFFFFF}"
#define SERVER_NAME_TAG         ""

#define MAX_LOGIN_ATTEMPTS      3
#define MAX_SPAWN_AREAS         5
#define MAX_JOBS                8
#define MAX_PM_OFF              10

#define MAX_SLOTS               90
#define MAX_ITEMS               500

#define MAX_VEHICLE_SLOTS       30

#define MAX_WEAPON_ITEMS        18
#define MAX_AMMO_ITEMS           6

#define MAX_MELEE_WEAPON_ITEMS   5

#define MAX_HEAD_WEARABLE_ITEMS  6
#define MAX_BODY_WEARABLE_ITEMS 18

#define MAX_BACKPACK_ITEMS      21

#define MAX_FOOD_ITEMS          13
#define MAX_MEDICAL_ITEMS   	 8
#define MAX_COOKABLE_ITEMS  	 1
#define MAX_RESOURCE_ITEMS       5
#define MAX_TOOL_ITEMS			10
#define MAX_BIG_ITEMS   		 1
#define MAX_MISC_ITEMS  		 4
#define MAX_ARMOUR_ITEMS         2

#define MAX_CRAFTABLE_ITEMS      1

#define MAX_WEAPON_TYPES         5
#define MAX_WEAPON_SLOTS         5

#define LOGIN_TIME_LIMIT        "60"

#define MAX_SCATTERED_ZOMBIES   600

#define COLOR_WHITE             "{FFFFFF}"
#define COLOR_MAIN_HEX          "{FED85D}"

#define COLOR_MAIN              0xFED85DFF
#define COLOR_PM                0xFF0000FF

#define COLOR_HUNGER            0xFFA500FF
#define COLOR_THIRST            0x00BFFFFF

#define PRESSING(%0,%1) \
	(%0 & (%1))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

enum dialog_ids
{
    LOGIN_DIALOG_ID,
    
	SETUP_DIALOG_ID_1,
	SETUP_DIALOG_ID_2,
	SETUP_DIALOG_ID_3,
	SETUP_DIALOG_ID_4,
	SETUP_DIALOG_ID_5,
	SETUP_DIALOG_ID_6,
	
	ADD_ITEM_DIALOG_ID_1,
	ADD_ITEM_DIALOG_ID_2,
	ADD_ITEM_DIALOG_ID_3,
	
	PLAYER_INVENTORY_DIALOG_ID_1,
	PLAYER_INVENTORY_DIALOG_ID_2,
	
	NEARBY_ITEMS_DIALOG_ID_1,
	PM_OFF_LIST_DIALOG_ID,
	
	EQUIPPED_ITEMS_DIALOG_ID_1,
	EQUIPPED_ITEMS_DIALOG_ID_2,
	EQUIPPED_ITEMS_DIALOG_ID_3,
	
	NEARBY_ITEMS_DIALOG_ID_2,
	NEARBY_ITEMS_DIALOG_ID_3,
	NEARBY_ITEMS_DIALOG_ID_2_PART,
	
	CUFF_PLAYER_DIALOG_ID,
	UNCUFF_PLAYER_DIALOG_ID_1,
	UNCUFF_PLAYER_DIALOG_ID_2,
	
	DRIVING_LICENSE_DIALOG_ID,
	PLAYER_BADGE_DIALOG_ID,
	
	LOOTING_ACTOR_DIALOG_ID_1,
	LOOTING_ACTOR_DIALOG_ID_2,
	LOOTING_ACTOR_DIALOG_ID_3,
	
	CHARACTER_INFO_DIALOG_ID,
	CRAFTABLE_ITEMS_DIALOG_ID,
	
	CRAFTING_RECIPE_DIALOG_ID,
	CRAFTING_RECIPE_DIALOG_ID_2,
	
	CAR_REPAIR_DIALOG_ID,
	VEHICLE_INVENTORY_DIALOG_ID
};

enum player_data
{
	account_id,
	password [32],
	login_attempts,
	logged_in,
	loaded,

	age,
	skin,
	gender,

	Float: health,
	Float: hunger,
	Float: thirst,

	job,

	cooking,
	hunting,
	crafting,
	learning,
	repairing,
	durability,
	strength,

	Float: last_x,
	Float: last_y,
	Float: last_z,

	last_interior,

	private_messages,

	head_protection,

	carrying,

	cooked,
	cooking_time,
	cooking_timer,
	
	crafting_method[64],
	
	crafted,
	crafting_time,
	crafting_timer,
	
	player_action, // 1 = cooking, 2 = crafting

	equipped_wearable_items,
	inventory_virtual_slots,
	inventory_slots,
	slots_used,

	spawned,
	initiated,
	data_loaded,
	player_spawn,

	kick_timer,

	item_added,

	selected_nearby_item,
	selected_inventory_slot,

	selected_actor,
	selected_item_type,
	selected_item_ammo,
	selected_item_amount,
	selected_item_state,

	selected_item_model_id,
	selected_item_static_id,

	nearby_items [64],

	in_zombie_zone,

	weapon_shot,

	getting_chased,
	zombies_chasing,
	player_zombies,
	
	walking,
	
	selected_recipe,
	selected_recipe_method,
	
	current_weapon,
	
	sprinting,
	
	selected_vehicle
};

new WORLD_TIME;
new SERVER_SLOTS;
new PlayerInfo [MAX_PLAYERS][player_data];

#include <../../gamemodes/modules/mysql_connection.inc>
#include <../../gamemodes/modules/data_arrays.inc>
#include <../../gamemodes/modules/functions.inc>
#include <../../gamemodes/modules/zombies.inc>

////////////////////////////////////////////////////////////////////////////////
// ENUMERATORS /////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

enum job_data
{
	name [24],
	
	cooking,
	hunting,
	crafting,
	learning,
	repairing,
	strength,
	durability
	
};

enum slot_data
{
	item [124]
};

enum food_items_data
{
	name [34],
	model_id,

	Float: healing,
	Float: hunger,
	Float: thirst,

    ammo_per_use,
	item_ammo,

	item_static_id
};

enum medical_items_data
{
	name [46],
	model_id,

	Float: healing,

    ammo_per_use,
	item_ammo,

	item_static_id
};

enum cookable_items_data
{
	name [24],
	model_id,

	item_static_id
};

enum resource_items_data
{
	name [24],
	model_id,

	item_static_id
};

enum tool_items_data
{
	name [24],
	model_id,

	item_static_id
};

enum big_items_data
{
	name [24],

	model_id_1,
	model_id_2,
	
	item_ammo,

	item_static_id
};

enum misc_items_data
{
	name [24],
	model_id,

	item_static_id
};

enum weapon_items_data
{
	name [46],
	weapon_id,
	weapon_model_id,
	Float: weapon_damage,
	item_static_id,
	weapon_bullet_type
};

enum ammo_items_data
{
	name [54],
	item_static_id
};

enum melee_items_data
{
	name [44],
	weapon_id,
	weapon_model_id,
	Float: weapon_damage,
	
	item_static_id
};

enum head_wearable_items
{
	name [42],
	model_id,
	wearable_type,
	head_hits,

	item_static_id
};

enum body_wearable_items
{
	wearable_name [34],
	wearable_model_id,
	wearable_type,
	wearable_slots,

	item_static_id
};

enum backpack_items
{
	name [34],
	slots,
	model_id,

	item_static_id
};

enum armour_items_data
{
	name [24],
	model_id,

	Float: armour,

	item_static_id
};

enum created_item_data
{
	item_id,
	item_static_id,
	item_model_id,
	
	item_type,
	item_amount,
	item_ammo,

	item_attached,
	item_timer,

	item_unique_id
};

enum player_weapon_data
{
	weapon_id,
	weapon_model_id,
	weapon_static_id,
	weapon_type,
	Float: weapon_damage,
	weapon_ammo,
	
	slot_used
};

enum vehicle_data
{
	vehicle_model,

	vehicle_color_1,
	vehicle_color_2,
	
	Float: vehicle_health,
	Float: vehicle_fuel,
	
	vehicle_engine,
	vehicle_lights,
	vehicle_alarm,
	vehicle_doors,
	vehicle_bonnet,
	vehicle_boot,

	vehicle_d_panels,
	vehicle_d_doors,
	vehicle_d_lights,
	vehicle_d_tires,


	vehicle_driving,

	Float: vehicle_x,
	Float: vehicle_y,
	Float: vehicle_z,
	Float: vehicle_a,

	wheel_usage,
 	engine_usage
};

enum vehicle_slot_data
{
	item [124]
};

new VehicleInfo [MAX_VEHICLES][vehicle_data];
new VehicleInventory [MAX_VEHICLES][MAX_VEHICLE_SLOTS][vehicle_slot_data];

////////////////////////////////////////////////////////////////////////////////
// ARRAYS //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

new Jobs [MAX_JOBS][job_data] =
{
	{"Police",    2,  1,  4,  1,  2, 4, 2},
	{"Doctor",    0,  2,  2,  0,  4, 1, 1},
	{"Teacher",   0,  4,  0,  0,  6, 1, 1},
	{"Repairman", 10, 0,  3,  0,  3, 2, 1},
	{"Cooker",    0,  10, 4,  0,  4, 1, 1},
	{"Worker",    5,  0,  4,  2,  1, 3, 1},
	{"Hunter",    2,  4,  4,  9,  1, 3, 1},
	{"Soldier",   3,  1,  2,  2,  0, 6, 2}
};

new FoodItems [MAX_FOOD_ITEMS][food_items_data] =
{
    {"Pizza", 						19580, 5.0,   10.0,  2.0,   5,  10,  0},
	{"Milk Pack", 					19570, 10.0,  5.0,   50.0, 10,  50,  1},
	{"Apple", 						19576, 15.0,  10.0,  25.0,  1,   1,  2},
	{"Banana", 						19578, 15.0,  15.0,  15.0,  1,   1,  3},
	{"Box of Pizza", 				19571, 30.0,  50.0,  15.0,  1,   1,  4},
	{"Water Bottle", 				19570, 10.0,  2.5,   50.0, 20,  100, 5},
	{"Military MRE", 				2663,  15.0,  30.0,  10.0, 20,  120, 6},
	{"Civilian MRE", 				19573, 15.0,  30.0,  10.0, 20,  120, 7},
	{"Cooked Meat", 				-2027,  35.0,  50.0,  35.0, -1,  -1,  8},
	{"Tomato Can",                  11722, 10.0,  10.0,  10.0, -1,  -1,  9},
	{"Soup Can",                    11723, 10.0,  10.0,  10.0, -1,  -1,  10},
	{"Cola",                        -2026, 10.0,  20.0,  5.0,   5,  15,  11},
	{"Beans",                       -2020, 10.0,  20.0,  5.0,   5,  15,  12}
};

new MedicalItems [MAX_MEDICAL_ITEMS][medical_items_data] =
{
    {"IFAK Tactical Frist Aidkit", 	11738, 20.0,  20,  150, 0},
 	{"Car First Aidkit", 			11738, 25.0,  20,  100, 1},
	{"Solo First Aidkit", 			11736, 50.0,  25,  100, 2},
	{"Antibiotics", 				-2018, 40.0,   1,    2, 3},
	{"Morphine", 					-2040, 10.0,   1,    1, 4},
	{"Painkillers", 				-2045, 25.0,   2,    2, 5},
	{"Splint",                      11788, 25.0,   1,    1, 6},
    {"Fuel Can",        			 1650, 50.0,  20,  100, 7}
};

new CookableItems [MAX_COOKABLE_ITEMS][cookable_items_data] =
{
    {"Raw Meat", 2804, 0}
};

new ResourceItems [MAX_RESOURCE_ITEMS][resource_items_data] =
{
    {"Dollar", 			1212, 	0},
    {"Wood", 			19793, 	1},
    {"Paper", 			19873, 	2},
	{"Toilet Paper",    19873,  3},
	{"Cloth",           19469,  4}
};

new ToolItems [MAX_TOOL_ITEMS][tool_items_data] =
{
    {"Handcuff", 		11749, 	0},
	{"Hundcuff Key", 	11746, 	1},
	{"Toolbox",		 	-2051, 	2},
	{"Can Opener", 		   -1,	3},
    {"Pan", 			19581, 	4},
	{"Bear Trap", 		-2023,  5},
	{"Watch",           -2053,  6},
	{"Matches",            -1,  7},
	{"Box Of Cigarretes", 19897, 8},
	{"Car tire",          1096, 9}
};

new BigItems [MAX_BIG_ITEMS][big_items_data] =
{
	{"Camp Fire", 		1463, 18689, 3,  0}
};

new MiscItems [MAX_MISC_ITEMS][misc_items_data] =
{
    {"Driver License", 	19792, 	0},
	{"Badge", 			19785, 	1},
	{"Recipe Book", 	 2059,  2},
	{"Cigarette", 		19897,  3}
};

new WeaponItems [MAX_WEAPON_ITEMS][weapon_items_data] =
{
	{"Glock 17",			24, -2006, 63.0, 0, 0},
	{"Jericho 941",		    24,	-2007, 63.0, 1, 0},
	{"Clot M1911", 			24, -2004, 69.0, 2, 5},
	{"Python",              24, -2004, 74.0, 3, 5},
	{"Mossberg 590", 		25, -2013, 72.0, 4, 2},
	{"Remington 870", 		25, -2013, 72.0, 5, 2},
	{"Benelli M4", 			27, -2002, 65.0, 6, 2},
	{"MP5", 				29, -2014, 15.0, 7, 0},
	{"TEC-9", 				32, -2016, 14.0, 8, 0},
	{"Skorpion", 			32,   372, 14.0, 9, 0},
	{"AKS-74U", 			29,   353, 25.0, 10, 3},
	{"M16A2", 				31, -2011, 44.0, 11, 3},
	{"M4A1", 				31, -2008, 46.0, 12, 3},
	{"AK-47", 				30, -2001, 49.0, 13, 4},
	{"FN FAL", 				30, -2005, 53.0, 14, 4},
	{"Remington 700 BDL", 	34, -2015, 91.0, 15, 4},
	{"Hunter Rifle",		33, -2017, 79.0, 16, 4},
	{"M14", 				31, -2010, 86.0, 17, 4}
};

new AmmoItems [MAX_AMMO_ITEMS][ammo_items_data] =
{
	{"9mm Ammo", 		0},
	{".45 ACP Ammo", 	1},
	{"12 Gauge Ammo", 	2},
	{"5.56 Ammo", 		3},
	{"7.62 Ammo", 		4},
	{".50 Ammo",        5}
};

new MeleeWeaponItems [MAX_MELEE_WEAPON_ITEMS][melee_items_data] =
{
	{"Axe", 			3, 	334, 50.0,	0},
	{"Combat Knife", 	4, 	335, 15.0,	1},
	{"Kitchen Knife", 	4, 	335, 10.0,	2},
	{"Baseball Bat", 	5, 	336, 30.0,	3},
	{"Tire Lever", 		15, 326, 30.0,	4}
};

new HeadWearableItems [MAX_HEAD_WEARABLE_ITEMS][head_wearable_items] =
{
	{""COLOR_MAIN_HEX"Hard Hat",                     19093, 0,  3, 0},
	{""COLOR_MAIN_HEX"Army Helmet",                  19101, 0,  6, 1},
	{""COLOR_MAIN_HEX"Motorcycle Helmet",            -2024, 0,  4, 2},
	{""COLOR_MAIN_HEX"SWAT Helmet",                  19141, 0,  5, 3},
	{"Police Cap",                   			 	 19521, 0,  0, 4},
	{"Black Police Cap",             			 	 18636, 0,  0, 5}
};

new BodyWearableItems [MAX_BODY_WEARABLE_ITEMS][body_wearable_items] =
{
	{"Black Leather Jacket",     	2386, 1,  4, 0},
	{"Brown Leather Jacket",     	2386, 1,  4, 1},
	{"Red Raincoat",             	2386, 1,  3, 2},
	{"Green Raincoat",           	2386, 1,  3, 3},
	{"Military Shirt",           	2386, 1,  1, 4},
	{"Tactical Jacket",          	2386, 1,  6, 5},
	
	{"Hunter Vest",              	2386, 1,  8, 6},
	{"Alpha Vest",               	2386, 1, 14, 7},
	{"Military Vest",            	2386, 1, 19, 8},
	{"Construction Vest",        	2386, 1,  4, 9},
	
	{"Black Cargo Pants", 			2386, 3,  2, 10},
	{"Brown Cargo Pants",        	2386, 3,  2, 11},
	{"Khaki Cargo Pants",        	2386, 3,  2, 12},
	{"Black Jeans",              	2386, 3,  3, 13},
	{"Light Blue Jeans",         	2386, 3,  3, 14},
	{"Blue Jeans",               	2386, 3,  3, 15},
	{"Black Military Pants",     	2386, 3,  6, 16},
	{"Green Camo Military Pants",	2386, 3,  8, 17}
	
};

new BackpackItems [MAX_BACKPACK_ITEMS][backpack_items] =
{
	{"Child Backpack",   	     15, -2025, 0},
	{"Child Backpack (Red)",	 15, -2025, 1},
	{"Child Backpack (Green)",	 15, -2025, 2},
	{"Gucci Bag",				 23, -2029, 3},
	{"Improvised Backpack 1",	 12, 371,   4},
	{"Improvised Backpack 2",	 12, 371,   5},
	{"Marine Backpack (Green)",	 32, 371,   6},
	{"Marine Backpack (Orange)", 32, 371,   7},
	{"Marine Backpack (Red)",	 32, 371,   8},
	{"Marine Backpack (Yellow)", 32, 371,   9},
	{"Marine Backpack (Black)",	 32, 371,   10},
	{"Military Backpack (Green)",40, 371,   11},
	{"Military Backpack (Tan)",	 40, 371,   12},
	{"Mountain Backpack (Blue)", 60, 371,   13},
	{"Mountain Backpack (Green)",60, 371,   14},
	{"Mountain Backpack (Orange)",60,371,   15},
	{"Mountain Backpack (Red)",	 60, 371,   16},
	{"Sport Backpack",			 23, -2025, 17},
	{"Taloon Backpack (Blue)",	 26, 371,   18},
	{"Taloon Backpack (Green)",	 26, 371,   19},
	{"Taloon Backpack (Orange)", 26, 371,   20}
};

new ArmourItems [MAX_ARMOUR_ITEMS][armour_items_data] =
{
	{"Police Armour", 1242,  70.0, 0},
	{"Swat Armour",  19142, 100.0, 1}
};

enum craftable_items_data
{
	name [124],

	item_type,
	item_id,
	
	item_recipes,
	item_static_id
};

new CraftableItems [MAX_CRAFTABLE_ITEMS][craftable_items_data] =
{
	{"Camp Fire", 6, 0, 3, 0}
};

stock IsPlayerNearAnyVehicle (playerid)
{
	new Float: v_x, Float: v_y, Float: v_z;


	for (new i = 0; i < MAX_VEHICLES; i++)
	{
	    if (GetVehicleModel (i) != 0)
	    {
			GetVehiclePos (i, v_x, v_y, v_z);
			
			if (IsPlayerInRangeOfPoint (playerid, 2.5, v_x, v_y, v_z))
			{
			    return i;
			}
	    }
	}
	
	return -1;
}

stock GetRecipeString (i_static_id)
{
	new recipe_string [144 * 4];
	
	switch (i_static_id)
    {
		case 0: format (recipe_string, sizeof (recipe_string), "4 1 5 -1 -1,4 0 10 -1 -1 || 4 1 5 -1 -1,4 3 5 -1 -1 || 4 1 5 -1 -1");
    }
	
	return recipe_string;
}

stock GetSpecificRecipe (recipe_string [], recipe_id)
{
	new possibilities [10][144];

	strexplode (possibilities, recipe_string, " || ");

	return possibilities [recipe_id];
}

stock ShowSelectedRecipe (playerid, possibility [])
{
	new recipe_part [5][100],
	
	    s_type, s_id, s_amount, s_ammo, s_state,
	
	    string [1420];
	
	strexplode (recipe_part, possibility, ",");
	
	strcat (string, "You will need the following things to craft the item. \n", sizeof (string));
	
	for (new i = 0; i < 5; i++)
	{
        if (!sscanf (recipe_part [i], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
        {
            switch (s_type)
            {
	        	case  1: format (string, sizeof (string), "%s\n%s x%d", string, FoodItems [s_id][name], s_amount);
	        	case  2: format (string, sizeof (string), "%s\n%s x%d", string, MedicalItems [s_id][name], s_amount);
	        	case  3: format (string, sizeof (string), "%s\n%s x%d", string, CookableItems [s_id][name], s_amount);
	        	case  4: format (string, sizeof (string), "%s\n%s x%d", string, ResourceItems [s_id][name], s_amount);
	        	case  5: format (string, sizeof (string), "%s\n%s x%d", string, ToolItems [s_id][name], s_amount);
	        	case  6: format (string, sizeof (string), "%s\n%s x%d", string, BigItems [s_id][name], s_amount);
	        	case  7: format (string, sizeof (string), "%s\n%s x%d", string, MiscItems [s_id][name], s_amount);
	        	case  8: format (string, sizeof (string), "%s\n%s x%d", string, WeaponItems [s_id][name], s_amount);
	        	case  9: format (string, sizeof (string), "%s\n%s x%d", string, MeleeWeaponItems [s_id][name], s_amount);
	        	case 10: format (string, sizeof (string), "%s\n%s x%d", string, AmmoItems [s_id][name], s_amount);
	        	case 11: format (string, sizeof (string), "%s\n%s x%d", string, HeadWearableItems [s_id][name], s_amount);
	        	case 12: format (string, sizeof (string), "%s\n%s x%d", string, BodyWearableItems [s_id][wearable_name], s_amount);
	        	case 13: format (string, sizeof (string), "%s\n%s x%d", string, BackpackItems [s_id][name], s_amount);
	        	case 14: format (string, sizeof (string), "%s\n%s x%d", string, ArmourItems [s_id][name], s_amount);
        	}
		}
	}
	
	ShowPlayerDialog (playerid, CRAFTING_RECIPE_DIALOG_ID_2, DIALOG_STYLE_MSGBOX, ""SERVER_TAG" - Crafting Recipe", string, "Craft", "Cancel");
	return 1;
}

new PlayerInventory [MAX_PLAYERS][MAX_SLOTS][slot_data];
new PlayerWeaponInfo [MAX_PLAYERS][MAX_WEAPON_TYPES][player_weapon_data];

new PlayerPMOFFList [MAX_PLAYERS][MAX_PM_OFF];

new ItemInfo [MAX_OBJECTS][created_item_data];

new Text:CookingTD;
new Text:CraftingTD;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

main()
{
    WasteDeAMXersTime();

	print ("||||||||||||||||||||||||||||||||||||||||||||||||");
	print ("||  JUST : AFTERMATH (ZOMBIE ROLEPLAY) LOADED ||");
	print ("||||||||||||||||||||||||||||||||||||||||||||||||");
	print (" ");

}

////////////////////////////////////////////////////////////////////////////////
// CALLBACKS ///////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

public OnGameModeInit()
{
	/*

    AddSimpleModel (-1, 2000, -2001, "ak47.dff", "ak47.txd");
	AddSimpleModel (-1, 2000, -2002, "benelli_m4.dff", "benelli_m4.txd");
	AddSimpleModel (-1, 2000, -2003, "beretta92fs.dff", "beretta92fs.txd");
	AddSimpleModel (-1, 2000, -2004, "clot.dff", "clot.txd");
	AddSimpleModel (-1, 2000, -2005, "fn-fal.dff", "fn-fal.txd");
	AddSimpleModel (-1, 2000, -2006, "glock17.dff", "glock17.txd");
	AddSimpleModel (-1, 2000, -2007, "jericho941.dff", "jericho941.txd");
	AddSimpleModel (-1, 2000, -2008, "m4a1.dff", "m4a1.txd");
	AddSimpleModel (-1, 2000, -2009, "m14.dff", "m14.txd");
	AddSimpleModel (-1, 2000, -2010, "m16a1.dff", "m16a1.txd");
	AddSimpleModel (-1, 2000, -2011, "m16a4.dff", "m16a4.txd");
	AddSimpleModel (-1, 2000, -2012, "m1911.dff", "m1911.txd");
	AddSimpleModel (-1, 2000, -2013, "mossberg590.dff", "mossberg590.txd");
	AddSimpleModel (-1, 2000, -2014, "mp5.dff", "mp5.txd");
	AddSimpleModel (-1, 2000, -2015, "remington700bdl.dff", "remington700bdl.txd");
	AddSimpleModel (-1, 2000, -2016, "tec9.dff", "tec9.txd");
	AddSimpleModel (-1, 2000, -2017, "winchester73.dff", "winchester73.txd");
	
	AddSimpleModel (-1, 2000, -2018, "antibiotic.dff", "antibiotic.txd");
	AddSimpleModel (-1, 2000, -2019, "bandage.dff", "bandage.txd");
	AddSimpleModel (-1, 2000, -2020, "beans.dff", "beans.txd");
	AddSimpleModel (-1, 2000, -2023, "bear_trap.dff", "bear_trap.txd");
	AddSimpleModel (-1, 2000, -2024, "bikerhelmet.dff", "bikerhelmet.txd");
	AddSimpleModel (-1, 2000, -2025, "c_bp.dff", "c_bp.txd");
	AddSimpleModel (-1, 2000, -2026, "cola.dff", "cola.txd");
	AddSimpleModel (-1, 2000, -2027, "cooked_meat.dff", "cooked_meat.txd");
	AddSimpleModel (-1, 2000, -2028, "fuel_can.dff", "fuel_can.txd");
	AddSimpleModel (-1, 2000, -2029, "g_bp.dff", "g_bp.txd");
	AddSimpleModel (-1, 2000, -2030, "imp_bp.dff", "imp_bp_1.txd");
	AddSimpleModel (-1, 2000, -2031, "imp_bp.dff", "imp_bp_2.txd");
	AddSimpleModel (-1, 2000, -2032, "marine_bp.dff", "marine_green.txd");
	AddSimpleModel (-1, 2000, -2033, "marine_bp.dff", "marine_orange.txd");
	AddSimpleModel (-1, 2000, -2034, "marine_bp.dff", "marine_red.txd");
	AddSimpleModel (-1, 2000, -2035, "marine_bp.dff", "marine_yellow.txd");
	AddSimpleModel (-1, 2000, -2036, "marine_bp.dff", "marine_black.txd");
	AddSimpleModel (-1, 2000, -2037, "matches.dff", "matches.txd");
	AddSimpleModel (-1, 2000, -2038, "military_bp.dff", "military_green.txd");
	AddSimpleModel (-1, 2000, -2039, "military_bp.dff", "military_tan.txd");
	AddSimpleModel (-1, 2000, -2040, "morphine.dff", "morphine.txd");
	AddSimpleModel (-1, 2000, -2041, "mount_bp.dff", "mount_bp_blue.txd");
	AddSimpleModel (-1, 2000, -2042, "mount_bp.dff", "mount_bp_green.txd");
	AddSimpleModel (-1, 2000, -2043, "mount_bp.dff", "mount_bp_orange.txd");
	AddSimpleModel (-1, 2000, -2044, "mount_bp.dff", "mount_bp_red.txd");
	AddSimpleModel (-1, 2000, -2045, "painkiller.dff", "painkiller.txd");
	AddSimpleModel (-1, 2000, -2046, "raw_meat.dff", "raw_meat.txd");
	AddSimpleModel (-1, 2000, -2047, "revolver_mag.dff", "revolver_mag.txd");
	AddSimpleModel (-1, 2000, -2048, "sport_bp.dff", "sport_bp.txd");
	AddSimpleModel (-1, 2000, -2049, "taloon_bp.dff", "taloon_bp_blue.txd");
	AddSimpleModel (-1, 2000, -2050, "taloon_bp.dff", "taloon_bp_green.txd");
	AddSimpleModel (-1, 2000, -2051, "taloon_bp.dff", "taloon_bp_orange.txd");
	AddSimpleModel (-1, 2000, -2052, "toolbox.dff", "toolbox.txd");
	AddSimpleModel (-1, 2000, -2053, "watch.dff", "watch.txd");
	AddSimpleModel (-1, 2000, -2054, "wood_pile.dff", "wood_pile.txd");
	
	*/
	
    // WasteDeAMXersTime();
	
	AddPlayerClass (60, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	
	LoadServer ();
	LoadVehicles ();
	
	CA_Init ();

	SetTimer ("UpdateVehiclesData", 1000, true);
	return 1;
}

public OnGameModeExit()
{
	foreach (new i : Player)
	{
	    OnPlayerDisconnect (i, 0);
	}
	
	OnRconCommand ("close");
	return 1;
}

public OnRconCommand(cmd[])
{
	if (!strcmp (cmd, "close"))
	{
	    SaveItems ();
	    SaveVehicles ();
	    
	    foreach (new i : Player)
	    {
	        if (IsPlayerConnected (i))
	        {
	        	OnPlayerDisconnect (i, 0);
			}
	    }
	    
		SendRconCommand ("exit");
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	Streamer_UpdateEx (playerid, -401.7249, -1445.7130, 26.0625, 0, 0);

	//SetPlayerSpawnInfo, TogglePlayerSpectating

	SetPlayerInterior (playerid, 0);
    SetPlayerVirtualWorld (playerid, 0);
	SetPlayerPos (playerid, -401.7249, -1445.7130, 26.0625);
	SetPlayerFacingAngle (playerid, 179.5791);

	SetPlayerCameraPos(playerid, -399.0214, -1456.2310, 25.7266);
	SetPlayerCameraLookAt(playerid, -398.8493, -1438.2705, 25.7266);

	TogglePlayerControllable (playerid, false);
	return 1;
}

public OnPlayerConnect(playerid)
{
	if (IsPlayerNPC (playerid)) return 0;

	new query [124];
	mysql_format (mysql, query, sizeof (query), "SELECT * FROM `players` WHERE `NAME` = '%e' LIMIT 1", GetName (playerid));
	mysql_pquery (mysql, query, "OnPlayerInit", "i", playerid);
	
	CreatePlayerCookingBar (playerid);
	HideCookingBar (playerid);
	
	PlayerInfo [playerid][getting_chased] = -1;
	
	for (new i = 0; i < MAX_PM_OFF; i++)
	{
		PlayerPMOFFList [playerid][i] = -1;
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    GetPlayerPos (playerid, PlayerInfo [playerid][last_x], PlayerInfo [playerid][last_y], PlayerInfo [playerid][last_z]);
    
	if (PlayerInfo [playerid][initiated] == 1 && PlayerInfo [playerid][logged_in] == 1)
	{
		SavePlayerData (playerid);
		PlayerInfo [playerid][logged_in] = 0;
	}

	KillTimer (PlayerBarTimer [playerid]);
	DestroyPlayerProgressBars (playerid);

	PlayerInfo [playerid][spawned] = 0;

	PlayerInfo [playerid][hunger] = 100.0;
	PlayerInfo [playerid][thirst] = 100.0;

	HideProgressBars (playerid);

	for (new i = 0; i < 10; i++)
	{
		RemovePlayerAttachedObject (playerid, i);
	}

	HideCookingBar (playerid);
	KillTimer (PlayerInfo [playerid][cooking_timer]);

	for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	{
		PlayerWeaponInfo [playerid][i][slot_used] = 0;
		PlayerWeaponInfo [playerid][i][weapon_id] = 0;
		PlayerWeaponInfo [playerid][i][weapon_model_id] = 0;
		PlayerWeaponInfo [playerid][i][weapon_static_id] = -1;
		PlayerWeaponInfo [playerid][i][weapon_type] = -1;
		PlayerWeaponInfo [playerid][i][weapon_ammo] = -1;
		PlayerWeaponInfo [playerid][i][weapon_damage] = 0.0;
	}

	for (new i = 0; i < PlayerInfo [playerid][inventory_virtual_slots]; i++)
	{
		PlayerInventory [playerid][i][item][0] = EOS;
	}

	PlayerInfo [playerid][slots_used] = 0;
	PlayerInfo [playerid][inventory_virtual_slots] = PlayerInfo [playerid][inventory_slots];
	return 1;
}

public OnPlayerUpdate (playerid)
{

	if (GetPlayerState (playerid) == PLAYER_STATE_DRIVER)
	{
		if (VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_fuel] > 0.0)
		{
		    new keys, vertical, horizontal;
		    GetPlayerKeys (playerid, keys, vertical, horizontal);

		    if (keys == 8)
		    {
				VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_driving] = 1;
		    }
		    else VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_driving] = 0;
	    }
	}

	if (IsPlayerNPC (playerid)) return 0;

	switch (GetPlayerWeapon (playerid))
	{
	    case 24:
	    {
			for (new i = 0; i < MAX_WEAPON_TYPES; i++)
			{
			    if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 0)
			    {
			        SetPlayerAttachedObject (playerid, 8, -2006, 6, -0.032999, -0.031000, -0.051999, 0.000000, 0.000000, 0.000000, 1.422999, 2.459001, 1.600999);
			    }
			    else if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 1)
			    {
                    SetPlayerAttachedObject (playerid, 8, -2006, 6, -0.032999, -0.031000, -0.051999, 0.000000, 0.000000, 0.000000, 1.422999, 2.459001, 1.600999);
			    }
			    else if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 2)
			    {
                    SetPlayerAttachedObject (playerid, 8, -2004, 6, -0.040000, -0.019000, -0.048000, 8.999994, 2.700001, 1.099999, 1.418999, 2.548000, 1.440000);
			    }
			    else if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 3)
			    {
                    SetPlayerAttachedObject (playerid, 8, -2004, 6, -0.040000, -0.019000, -0.048000, 8.999994, 2.700001, 1.099999, 1.418999, 2.548000, 1.440000);
			    }
			}
	    }
	    case 25:
	    {
	        for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	        {
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 4)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2013, 6, 0.001000, -0.063999, 0.005999, 16.900001, -5.199998, 8.400013, 1.416000, 2.696001, 1.070001);
	            }
	        }
	    }
	    case 29:
	    {
	        for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	        {
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 7)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2014, 6, -0.038999, -0.018000, -0.012000, -2.599999, 6.400000, 4.599999, 1.164998, 1.851999, 1.408999);
	            }
	        }
	    }
	    case 30:
	    {
	        for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	        {
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 13)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2001, 6, -0.063000, -0.010999, -0.006000, 0.000000, 0.000000, 0.000000, 1.429999, 1.621999, 1.270999);
	            }
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 14)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2005, 6, -0.063000, -0.010999, -0.006000, 0.000000, 0.000000, 0.000000, 1.429999, 1.621999, 1.270999);
	            }
	        }
	    }
	    case 31:
	    {
	        for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	        {
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 11)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2011, 6, 0.028999, -0.037000, -0.041999, 0.000000, 0.000000, 3.500000, 1.245999, 2.126000, 1.385999);
	            }
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 12)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2008, 6, -0.019000, -0.030000, -0.029999, 0.000000, 4.399997, 2.999999, 1.391999, 1.877000, 1.402000);
	            }
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 17)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2010, 6, 0.020000, -0.016999, -0.043000, -0.199999, 2.399998, 0.000000, 1.252999, 1.812000, 1.382999);
	            }
	        }
	    }
	    case 32:
	    {
	        for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	        {
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 8)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2016, 6, -0.007000, -0.034999, -0.030999, 0.000000, 2.800004, 0.000000, 1.002999, 1.899000, 1.483999);
	            }
	        }
	    }
	    case 33:
	    {
	        for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	        {
	            if (PlayerWeaponInfo [playerid][i][weapon_static_id] == 16)
	            {
	                SetPlayerAttachedObject (playerid, 8, -2017, 6, 0.000000, -0.051000, 0.001999, 2.999997, 2.899997, 6.799992, 1.078999, 2.086000, 1.307000);
	            }
	        }
	    }
	    default: RemovePlayerAttachedObject (playerid, 8);
	}
	return 1;
}

public OnPlayerSpawn (playerid)
{
	SetPlayerVirtualWorld (playerid, 1);

	if (PlayerInfo [playerid][spawned] == 0) { PlayerInfo [playerid][spawned] = 1; }

	if (PlayerInfo [playerid][data_loaded] == 0)
	{
	    SetPlayerSkin (playerid, PlayerInfo [playerid][skin]);
	
		SetPlayerHealth (playerid, PlayerInfo [playerid][health]);
		SetPlayerInterior (playerid, PlayerInfo [playerid][last_interior]);
		SetPlayerVirtualWorld (playerid, 1);

		SetPlayerPos (playerid, PlayerInfo [playerid][last_x], PlayerInfo [playerid][last_y], PlayerInfo [playerid][last_z]);
		
		PlayerInfo [playerid][data_loaded] = 1;
		
		new s_type, s_id, s_amount, s_ammo, s_status;
		
		for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
		{
			if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
			{
			    if (s_type == 7)
			    {
					if (s_status == -3)
					{
			        	SetPlayerAttachedObject (playerid, 0, HeadWearableItems [s_id][model_id], 2, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 1.200000, 1.200000, 1.200000);
			        }
			    }
			}
		}

	}
	else if (PlayerInfo [playerid][data_loaded] == 1)
	{
	    SpawnAtSelectedSpawnArea (playerid);
	}
	
	if (PlayerInfo [playerid][logged_in] == 1)
	{
		ShowProgressBars (playerid);
		UpdatePlayerBars (playerid);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{

	if (PlayerInfo [playerid][getting_chased] == 1)
	{
		for (new i = ((SERVER_SLOTS - Zombies) - 1); i < MAX_ZOMBIES; i++)
		{
		    if (ZombieInfo [i][chasing] == playerid)
		    {
				ZombieInfo [i][chasing] = -1;
				ZombieInfo [i][chasing_range] = 25.0;
				FCNPC_StopAttack (i);
				FindGoToPoint (i);
		    }
		}

	    PlayerInfo [playerid][zombies_chasing] = 0;
	    PlayerInfo [playerid][player_zombies] = 0;
    }
	
	if (IsPlayerNPC (playerid)) return 0;

	PlayerInfo [playerid][spawned] = 0;

	PlayerInfo [playerid][hunger] = 70.0;
	PlayerInfo [playerid][thirst] = 70.0;

	HideProgressBars (playerid);
	
	for (new i = 0; i < 10; i++)
	{
		RemovePlayerAttachedObject (playerid, i);
	}
	
	HideCookingBar (playerid);
	KillTimer (PlayerInfo [playerid][cooking_timer]);
	
	for (new i = 0; i < MAX_WEAPON_TYPES; i++)
	{
		PlayerWeaponInfo [playerid][i][slot_used] = 0;
		PlayerWeaponInfo [playerid][i][weapon_id] = 0;
		PlayerWeaponInfo [playerid][i][weapon_model_id] = 0;
		PlayerWeaponInfo [playerid][i][weapon_static_id] = -1;
		PlayerWeaponInfo [playerid][i][weapon_type] = -1;
		PlayerWeaponInfo [playerid][i][weapon_ammo] = -1;
		PlayerWeaponInfo [playerid][i][weapon_damage] = 0.0;
	}

	for (new i = 0; i < PlayerInfo [playerid][inventory_virtual_slots]; i++)
	{
		PlayerInventory [playerid][i][item][0] = EOS;
	}

	PlayerInfo [playerid][slots_used] = 0;
	PlayerInfo [playerid][inventory_virtual_slots] = PlayerInfo [playerid][inventory_slots];
    
    /*
    new Float: x, Float: y, Float: z,
		Float: fa,
		actor;

	GetPlayerPos (playerid, x, y, z);
    GetPlayerFacingAngle (playerid, fa);
    
    actor = CreateActor (PlayerInfo [playerid][skin], x, y, z, fa);

	new player_held_weapon = GetPlayerWeapon (playerid),
		player_held_weapon_ammo = GetPlayerAmmo (playerid),
		
		Float: w_x, Float: w_y, Float: w_z,
		
		created_weapon;

	w_x = (x + (random (2) * 1.0));
	w_y = (y + (random (2) * 1.0));
	
	MapAndreas_FindZ_For2DCoord (w_x, w_y, w_z);
	
	created_weapon = CreateObject (weapon, w_x, w_y, w_z, 0.0, 0.0, 0.0);
	
	ItemInfo [created_weapon][item_model_id] = weapon;
	ItemInfo [created_weapon][item_type
	
    
    
    SetTimerEx ("CreatePlayerZombie", 30 * 1000, false, "fff", x, y, z);

	*/
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER)
	{
		ShowFuelBar (playerid);
	}

	if (oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
	{
	    VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_driving] = 0;
		HideFuelBar (playerid);
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if (issuerid != INVALID_PLAYER_ID)
	{
		if (IsPlayerConnected (issuerid))
		{
		    if (bodypart == 9)
		    {
		        if (PlayerInfo [playerid][head_protection] <= 0)
		        {
		            SetPlayerHealth (playerid, 0.0);
					GameTextForPlayer (issuerid, "~r~HEADSHOT", 1000, 3);
		        }
		        else
		        {
                    PlayerInfo [playerid][head_protection]--;
                    
                    switch (PlayerInfo [playerid][head_protection])
                    {
						case 0: SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You helmet got shot and "COLOR_MAIN_HEX"broke. ");
						default: SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Your helmet for shot. ");
					}
		        }
		    }
		}
	}
	
	if (FCNPC_IsValid (issuerid))
	{
	    new Float: hp;
	    GetPlayerHealth (playerid, hp);
	    SetPlayerHealth (playerid, (hp - 25.0));
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if (damagedid != INVALID_PLAYER_ID)
	{
	    if (IsPlayerConnected (damagedid))
	    {
	        if (!IsPlayerNPC (playerid))
	        {
		        new Float: hp, slot;
		        GetPlayerHealth (damagedid, hp);

		        for (new i = 0; i < MAX_WEAPON_SLOTS; i++)
		        {
					if (PlayerWeaponInfo [playerid][i][weapon_id] == weaponid)
					{
					    slot = i;
					}
		        }

		        SetPlayerHealth (damagedid, (hp - PlayerWeaponInfo [playerid][slot][weapon_damage]));
	        }
	    }
	}
	return 1;
}

/*
public OnPlayerEnterDynamicArea(playerid, areaid)
{
	new Float: x, Float: y, Float: z;

	PlayerInfo [playerid][in_zombie_zone] = 1;

	for (new i = ((SERVER_SLOTS - Zombies) - 1); i < MAX_ZOMBIES; i++)
	{
	    if (Z_Zone [ZombieInfo [i][zone_id]] == areaid)
	    {
	        if (ZombieInfo [i][chasing] == 0)
	        {
			    FCNPC_GetPosition (i, x, y, z);

			    if (IsPlayerInRangeOfPoint (playerid, 15.0, x, y, z))
			    {
					FCNPC_GoToPlayer (i, playerid, FCNPC_MOVE_TYPE_SPRINT, FCNPC_MOVE_SPEED_SPRINT);
					PlayerInfo [playerid][getting_chased] = 1;
			    }
		    }
	    }
	}
	return 1;
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
    PlayerInfo [playerid][in_zombie_zone] = 0;
	return 1;
}
*/

public OnVehicleDeath (vehicleid)
{

	/*
	
	enum vehicle_data
	{
		vehicle_model,

		vehicle_color_1,
		vehicle_color_2,

		Float: vehicle_health,
		Float: vehicle_fuel,

		vehicle_engine,
		vehicle_lights,
		vehicle_alarm,
		vehicle_doors,
		vehicle_bonnet,
		vehicle_boot,

		vehicle_driving,

		Float: vehicle_x,
		Float: vehicle_y,
		Float: vehicle_z,
		Float: vehicle_a
	};

	
	*/

	DestroyVehicle (vehicleid);

	VehicleInfo [vehicleid][vehicle_model]   =
	
	VehicleInfo [vehicleid][vehicle_color_1] =
	VehicleInfo [vehicleid][vehicle_color_2] =
	
	VehicleInfo [vehicleid][vehicle_engine]  =
	VehicleInfo [vehicleid][vehicle_lights]  =
	VehicleInfo [vehicleid][vehicle_alarm]   =
	VehicleInfo [vehicleid][vehicle_doors]   =
	VehicleInfo [vehicleid][vehicle_bonnet]  =
	VehicleInfo [vehicleid][vehicle_boot]    =
	
	VehicleInfo [vehicleid][vehicle_driving] = 0;
	
	VehicleInfo [vehicleid][vehicle_x]       =
	VehicleInfo [vehicleid][vehicle_y]       =
	VehicleInfo [vehicleid][vehicle_z]       =
	VehicleInfo [vehicleid][vehicle_a]       =
	
	VehicleInfo [vehicleid][vehicle_health]  =
	VehicleInfo [vehicleid][vehicle_fuel]    = 0.0;
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED) ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1,0,1,1,0,0);

    if (PRESSING (newkeys, KEY_WALK))
	{
	    PlayerInfo [playerid][walking] = 1;
	}
	else if (RELEASED (KEY_WALK))
	{
	    PlayerInfo [playerid][walking] = 0;
	}
	
	if (PRESSING (newkeys, KEY_SPRINT))
	{
	    PlayerInfo [playerid][sprinting] = 1;
	}
	else if (RELEASED (KEY_SPRINT))
	{
	    PlayerInfo [playerid][sprinting] = 0;
	}
	
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if (GetWeaponType (weaponid) >= 1)
	{
	    new slot,
	    
		s_type, s_id, s_amount, s_ammo, s_status,
		
		added_weapon_ammo;
		
		if (PlayerInfo [playerid][weapon_shot] == 0)
		{
		    PlayerInfo [playerid][weapon_shot] = 1;
		    SetTimerEx ("FadeWeaponShotSound", 1000, false, "i", playerid);
		}
	    
	    for (new i = 0; i < MAX_WEAPON_SLOTS; i++)
	    {
			if (PlayerWeaponInfo [playerid][i][weapon_id] == weaponid)
			{
			    slot = i;
			    break;
			}
	    }
	
		PlayerWeaponInfo [playerid][slot][weapon_ammo]--;
		
		if (PlayerWeaponInfo [playerid][slot][weapon_ammo] == 0)
		{
		    SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Weapon ammo sole is empty. ");
    			
			for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
			{
			    if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
			    {
			        if (s_type == 10)
			        {
			            if (s_id == PlayerWeaponInfo [playerid][slot][weapon_ammo])
			            {
			                if(s_status == slot)
			                {
			                    RearrangePlayerInventorySlots (playerid, i);
			                }
			                if (!(s_status > 0)) // if (s_ammo != -1)
			                {
				                SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Unpacking new ammo pack. ");

				                // RearrangePlayerInventorySlots (playerid, i);

								format (PlayerInventory [playerid][i][item], 124, "10 %d %d -1 %d", s_id, s_amount, s_ammo, slot);

				                added_weapon_ammo = s_amount;
				                break;
			                }
			            }
			        }
			    }
			}
			
			if (added_weapon_ammo == 0)
			{
				
				for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
				{
				    if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
				    {
				        if (s_type == 8)
				        {
				            if (s_id == PlayerWeaponInfo [playerid][slot][weapon_static_id])
				            {
				                format (PlayerInventory [playerid][i][item], 124, "%d %d %d %d -2", s_type, s_id, s_amount, s_ammo);
				                break;
				            }
						}
					}
				}
				
				PlayerWeaponInfo [playerid][slot][slot_used] = 0;
				PlayerWeaponInfo [playerid][slot][weapon_id] = 0;
				PlayerWeaponInfo [playerid][slot][weapon_model_id] = 0;
				PlayerWeaponInfo [playerid][slot][weapon_type] = -1;
				PlayerWeaponInfo [playerid][slot][weapon_ammo] = -1;
				PlayerWeaponInfo [playerid][slot][weapon_damage] = 0.0;
				
			}
			else
			{
			    PlayerWeaponInfo [playerid][slot][weapon_ammo] = added_weapon_ammo;
			    GivePlayerWeapon (playerid, PlayerWeaponInfo [playerid][slot][weapon_id], added_weapon_ammo);
			    
			    new string [150];
			    format (string, sizeof (string), "[INFO] %sUnpacked %d bullets. ", COLOR_WHITE, added_weapon_ammo);
			    SendClientMessage (playerid, COLOR_MAIN, string);
			}
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
	    case LOGIN_DIALOG_ID:
	    {
	        if (IsPlayerNPC (playerid)) return 0;
	        if (!response) return ShowLoginDialog (playerid);
	    
	        if (strcmp (inputtext, PlayerInfo [playerid][password]))
	        {
	        
				PlayerInfo [playerid][login_attempts]++;
	        
	            SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You have entered a wrong password. ");
	            
				new string [50];
				format (string, sizeof (string), "[ERROR] {FFFFF}LOGIN ATTEMPTS: %s(%d/%d)", COLOR_MAIN, PlayerInfo [playerid][login_attempts], MAX_LOGIN_ATTEMPTS);
				SendClientMessage (playerid, COLOR_MAIN, string);
				
				if (PlayerInfo [playerid][login_attempts] == MAX_LOGIN_ATTEMPTS)
				{
				    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You have have failed all the login attempts. ");

					Kick (playerid);
					return 0;
				}
				
				ShowLoginDialog (playerid);
				return 0;
	        }
	        else if (strcmp (inputtext, PlayerInfo [playerid][password]) == 0)
	        {
	            KillTimer (PlayerInfo [playerid][kick_timer]);
	        
	            SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You have successfully logged in your account. ");
	            
	            PlayerInfo [playerid][logged_in] = 1;
	            
	            new query [124];

				mysql_format (mysql, query, sizeof (query), "SELECT * FROM `players` WHERE `NAME` = '%e' LIMIT 1", GetName (playerid));
	            mysql_pquery (mysql, query, "LoadPlayerData", "i", playerid);
	            
	            mysql_format (mysql, query, sizeof (query), "SELECT * FROM `inventories` WHERE `ACCOUNT_ID` = %d", PlayerInfo [playerid][account_id]);
				mysql_pquery (mysql, query, "LoadPlayerInventory", "i", playerid);
	            
	            PlayerBarTimer [playerid] = SetTimerEx ("UpdatePlayerBars", 10 * 1000, true, "i", playerid);
	        }
	    }
	    
	    case SETUP_DIALOG_ID_1:
	    {
	        ShowPlayerDialog (playerid, SETUP_DIALOG_ID_2, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Age", "Enter your age:", "Next", "");
	    }
	    case SETUP_DIALOG_ID_2:
	    {
	        if (!response) return ShowPlayerDialog (playerid, SETUP_DIALOG_ID_2, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Age", "Enter your age:", "Next", "");
	        
			if (strval (inputtext) > 99 || strval (inputtext) < 10)
			{
			    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Enter your age less than 99 and more than 10. ");
			    ShowPlayerDialog (playerid, SETUP_DIALOG_ID_2, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Age", "Enter your age:", "Next", "");
			    return 0;
			}
			
			if (isnull (inputtext))
			{
			    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You need to enter an age to proceed. ");
			    ShowPlayerDialog (playerid, SETUP_DIALOG_ID_2, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Age", "Enter your age (lower than 99):", "Next", "");
			    return 0;
			}
			
			PlayerInfo [playerid][age] = strval (inputtext);
			
			ShowPlayerDialog (playerid, SETUP_DIALOG_ID_3, DIALOG_STYLE_LIST, ""SERVER_TAG" - Gender Selection", "1. Male\n2. Female", "Select", "");
	    }
	    case SETUP_DIALOG_ID_3:
	    {
	        if (!response) return ShowPlayerDialog (playerid, SETUP_DIALOG_ID_3, DIALOG_STYLE_LIST, ""SERVER_TAG" - Gender Selection", "1. Male\n2. Female", "Select", "");
	        
	        PlayerInfo [playerid][gender] = listitem;
	        
	        new string [250];
	        for (new i = 0; i < MAX_JOBS; i++)
			{
			    if (i == 0) { format (string, sizeof (string), "%s\n", Jobs [i][name]); }
			    else if (i == (MAX_JOBS - 1)) { format (string, sizeof (string), "%s\n%s", string, Jobs [i][name]); }
				else { format (string, sizeof (string), "%s\n%s\n", string, Jobs [i][name]); }
			}
			
	        ShowPlayerDialog (playerid, SETUP_DIALOG_ID_4, DIALOG_STYLE_LIST, ""SERVER_TAG" - Job Selection", string, "Select", "");
	    }
	    case SETUP_DIALOG_ID_4:
	    {
	        if (!response)
			{
	            new string [250];
		        for (new i = 0; i < MAX_JOBS; i++)
				{
				    if (i == 0) { format (string, sizeof (string), "%s\n", Jobs [i][name]); }
				    else if (i == (MAX_JOBS - 1)) { format (string, sizeof (string), "%s\n%s", string, Jobs [i][name]); }
					else { format (string, sizeof (string), "%s\n%s\n", string, Jobs [i][name]); }
				}

		        ShowPlayerDialog (playerid, SETUP_DIALOG_ID_4, DIALOG_STYLE_LIST, ""SERVER_TAG" - Job Selection", string, "Select", "");
		        return 0;
			}
	        
	        PlayerInfo [playerid][job] = listitem;
	        
	        switch (PlayerInfo [playerid][job])
	        {
	            // Police
	            case 0:
	            {
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "8 0 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "10 0 17 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "2 2 1 100 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "5 0 1 -1 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "5 1 1 -1 -1");
	                PlayerInfo [playerid][slots_used]++;
	            }

				// Doctor
				case 1:
				{
				    format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "9 2 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "2 2 1 100 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "2 3 1 2 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "2 4 1 1 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "2 5 1 2 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "1 5 1 100 -1");
	                PlayerInfo [playerid][slots_used]++;
				}
				
				// Teacher
				case 2:
				{
				    // Add PENCIL and BOOK here
				}

				// Repairman
				case 3:
				{
				    format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "9 4 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "5 2 3 -1 -1");
	                PlayerInfo [playerid][slots_used]++;
				}

				// Cooker
				case 4:
				{
				    format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "7 2 1 -1 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "9 4 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "1 5 1 100 -1");
	                PlayerInfo [playerid][slots_used]++;
				}

				// Worker
				case 5:
				{
				    format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "9 3 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
				}

				// Hunter
				case 6:
				{
				    format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "8 16 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "10 4 20 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "12 6 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "9 1 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
				}

				// Soldier
				case 7:
				{
				    format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "8 11 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "10 3 50 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "2 0 1 150 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "1 6 1 120 -1");
	                PlayerInfo [playerid][slots_used]++;
	                
	                format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "12 7 1 -1 -2");
	                PlayerInfo [playerid][slots_used]++;
				}
	        }
	        
	        PlayerInfo [playerid][cooking]   = Jobs [PlayerInfo [playerid][job]][cooking];
	        PlayerInfo [playerid][hunting]   = Jobs [PlayerInfo [playerid][job]][hunting];
	        PlayerInfo [playerid][crafting]  = Jobs [PlayerInfo [playerid][job]][crafting];
	        PlayerInfo [playerid][learning]  = Jobs [PlayerInfo [playerid][job]][learning];
	        PlayerInfo [playerid][repairing] = Jobs [PlayerInfo [playerid][job]][repairing];
	        PlayerInfo [playerid][strength]  = Jobs [PlayerInfo [playerid][job]][strength];
	        PlayerInfo [playerid][durability]  = Jobs [PlayerInfo [playerid][job]][durability];

			switch (PlayerInfo [playerid][durability])
			{
			    case 1: PlayerInfo [playerid][inventory_slots] = 5;
			    case 2: PlayerInfo [playerid][inventory_slots] = 8;
			    case 3: PlayerInfo [playerid][inventory_slots] = 11;
			    case 4: PlayerInfo [playerid][inventory_slots] = 14;
			    case 5: PlayerInfo [playerid][inventory_slots] = 17;
			}

			PlayerInfo [playerid][inventory_virtual_slots] = PlayerInfo [playerid][inventory_slots];

	        new string [1250];

			if (PlayerInfo [playerid][gender] == 0)
			{
				for (new i = 0; i < sizeof (MaleSkins); i++)
				{
				    format (string, sizeof (string), "%s\n%i(0.0, 0.0, 0.0)", string, MaleSkins[i]);
				}
			}
			else if (PlayerInfo [playerid][gender] == 1)
			{
				for (new i = 0; i < sizeof (FemaleSkins); i++)
				{
				    format (string, sizeof (string), "%s\n%i(0.0, 0.0, 0.0)", string, FemaleSkins[i]);
				}
			}
			else if (PlayerInfo [playerid][gender] == 2)
			{
			    for (new i = 0; i < 311; i++)
				{
				    format (string, sizeof (string), "%s\n%d(0.0, 0.0, 0.0)", string, i);
				}
			}

			ShowPlayerDialog (playerid, SETUP_DIALOG_ID_5, DIALOG_STYLE_PREVIEW_MODEL, ""SERVER_TAG" - Skin Selection", string, "Select", "");
	        
	    }
	    case SETUP_DIALOG_ID_5:
	    {
	        if (!response)
	        {
		        new string [1250];

				if (PlayerInfo [playerid][gender] == 0)
				{
					for (new i = 0; i < sizeof (MaleSkins); i++)
					{
					    format (string, sizeof (string), "%s\n%i(0.0, 0.0, 0.0)", string, MaleSkins[i]);
					}
				}
				else if (PlayerInfo [playerid][gender] == 1)
				{
					for (new i = 0; i < sizeof (FemaleSkins); i++)
					{
					    format (string, sizeof (string), "%s\n%i(0.0, 0.0, 0.0)", string, FemaleSkins[i]);
					}
				}
				else if (PlayerInfo [playerid][gender] == 2)
				{
				    for (new i = 0; i < 311; i++)
					{
					    format (string, sizeof (string), "%s\n%i(0.0, 0.0, 0.0)", string, i);
					}
				}

				ShowPlayerDialog (playerid, SETUP_DIALOG_ID_5, DIALOG_STYLE_PREVIEW_MODEL, ""SERVER_TAG" - Skin Selection", string, "Select", "");
				return 0;
	        }
	        
	        if (PlayerInfo [playerid][gender] == 0) { PlayerInfo [playerid][skin] = MaleSkins [listitem]; }
	        else if (PlayerInfo [playerid][gender] == 1) { PlayerInfo [playerid][skin] = FemaleSkins [listitem]; }
	        else if (PlayerInfo [playerid][gender] == 2) { PlayerInfo [playerid][skin] = listitem; }
	        
	        SetPlayerSkin (playerid, PlayerInfo [playerid][skin]);
	        
	        ShowPlayerDialog (playerid, SETUP_DIALOG_ID_6, DIALOG_STYLE_LIST, ""SERVER_TAG" - Spawn Selection", "1. Los Santos\n2. Palomino Creek\n3. Montgomery\n4. Blueberry\n5. Dillimore", "Select", "");
	    }
	    case SETUP_DIALOG_ID_6:
	    {
	    
	        if (!response)
			{
			    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You must select a spawn place in order to proceed. ");
				ShowPlayerDialog (playerid, SETUP_DIALOG_ID_6, DIALOG_STYLE_LIST, ""SERVER_TAG" - Spawn Selection", "1. Los Santos\n2. Palomino Creek\n3. Montgomery\n4. Blueberry\n5. Dillimore", "Select", "");
	            return 0;
			}
			
			SetupPlayer (playerid);
			SpawnPlayer (playerid);
			
			PlayerInfo [playerid][player_spawn] = listitem;
			
			SpawnAtSelectedSpawnArea (playerid);
	    
	    }
	    case ADD_ITEM_DIALOG_ID_1:
	    {
	    
	        if (!response)
	        {
	            PlayerInfo [playerid][selected_item_type] = 0;
				PlayerInfo [playerid][selected_item_amount] = 0;

				PlayerInfo [playerid][selected_item_model_id] = -1;
			    PlayerInfo [playerid][selected_item_static_id] = -1;
	        }
	        else
	        {
	            new string [1024];
	        
		        if (listitem == 0)
		        {
					for (new i = 0; i < MAX_FOOD_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, FoodItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Food Items", string, "Select", "Back");
				}
				else if (listitem == 1)
		        {
					for (new i = 0; i < MAX_MEDICAL_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, MedicalItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Medical Items", string, "Select", "Back");
				}
				else if (listitem == 2)
				{
				    for (new i = 0; i < MAX_COOKABLE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, CookableItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Cookable Items", string, "Select", "Back");
				}
				else if (listitem == 3)
				{
				    for (new i = 0; i < MAX_RESOURCE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, ResourceItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Resource Items", string, "Select", "Back");
				}
				else if (listitem == 4)
				{
				    for (new i = 0; i < MAX_TOOL_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, ToolItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Tool Items", string, "Select", "Back");
				}
				else if (listitem == 5)
				{
				    for (new i = 0; i < MAX_BIG_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, BigItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Big Items", string, "Select", "Back");
				}
				else if (listitem == 6)
				{
				    for (new i = 0; i < MAX_MISC_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, MiscItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Misc Items", string, "Select", "Back");
				}
				else if (listitem == 7)
				{
				    for (new i = 0; i < MAX_WEAPON_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, WeaponItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Weapons", string, "Select", "Back");
				}
				else if (listitem == 8)
				{
				    for (new i = 0; i < MAX_MELEE_WEAPON_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, MeleeWeaponItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Melee Weapons", string, "Select", "Back");
				}
				else if (listitem == 9)
				{
				    for (new i = 0; i < MAX_AMMO_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, AmmoItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Ammo", string, "Select", "Back");
				}
				else if (listitem == 10)
				{
				    for (new i = 0; i < MAX_HEAD_WEARABLE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, HeadWearableItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Head Wearable Items", string, "Select", "Back");
				}
				else if (listitem == 11)
				{
				    for (new i = 0; i < MAX_BODY_WEARABLE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, BodyWearableItems [i][wearable_name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Body Wearable Items", string, "Select", "Back");
				}
				else if (listitem == 12)
				{
				    for (new i = 0; i < MAX_BACKPACK_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, BackpackItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Backpacks", string, "Select", "Back");
				}
				else if (listitem == 13)
				{
				    for (new i = 0; i < MAX_ARMOUR_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, ArmourItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Armours", string, "Select", "Back");
				}
				
				PlayerInfo [playerid][selected_item_type] = (listitem + 1);
			}
	    }
	    case ADD_ITEM_DIALOG_ID_2:
	    {
	        if (!response)
	        {
	            PlayerInfo [playerid][selected_item_type] = 0;
				PlayerInfo [playerid][selected_item_amount] = 0;

				PlayerInfo [playerid][selected_item_model_id] = -1;
			    PlayerInfo [playerid][selected_item_static_id] = -1;
			    
			    new string [2450];

				strcat (string, ""COLOR_MAIN_HEX"1.  "COLOR_WHITE"Food Items\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"2.  "COLOR_WHITE"Medical Items\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"3.  "COLOR_WHITE"Cookable Items\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"4.  "COLOR_WHITE"Resource Items\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"5.  "COLOR_WHITE"Tool Items\n", sizeof (string));
			    strcat (string, ""COLOR_MAIN_HEX"6.  "COLOR_WHITE"Big Items\n", sizeof (string));
			    strcat (string, ""COLOR_MAIN_HEX"7.  "COLOR_WHITE"Misc Items\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"8.  "COLOR_WHITE"Ranged Weapons\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"9.  "COLOR_WHITE"Melee Weapons\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"10. "COLOR_WHITE"Ammo\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"11. "COLOR_WHITE"Head Wearable Items\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"12. "COLOR_WHITE"Body Wearable Items\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"13. "COLOR_WHITE"Backpacks\n", sizeof (string));
				strcat (string, ""COLOR_MAIN_HEX"13. "COLOR_WHITE"Armours", sizeof (string));

				ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_1, DIALOG_STYLE_LIST, ""SERVER_TAG" - Add Item", string, "Select", "Cancel");
			    return 0;
	        }
	        else
			{
			    if      (PlayerInfo [playerid][selected_item_type] ==  1) { PlayerInfo [playerid][selected_item_model_id] = FoodItems [listitem][model_id]; }
				else if (PlayerInfo [playerid][selected_item_type] ==  2) { PlayerInfo [playerid][selected_item_model_id] = MedicalItems [listitem][model_id]; }
				else if (PlayerInfo [playerid][selected_item_type] ==  3) { PlayerInfo [playerid][selected_item_model_id] = CookableItems [listitem][model_id]; }
				else if (PlayerInfo [playerid][selected_item_type] ==  4) { PlayerInfo [playerid][selected_item_model_id] = ResourceItems [listitem][model_id]; }
				else if (PlayerInfo [playerid][selected_item_type] ==  5) { PlayerInfo [playerid][selected_item_model_id] = ToolItems [listitem][model_id]; }
				else if (PlayerInfo [playerid][selected_item_type] ==  6) { PlayerInfo [playerid][selected_item_model_id] = BigItems [listitem][model_id_1]; }
				else if (PlayerInfo [playerid][selected_item_type] ==  7) { PlayerInfo [playerid][selected_item_model_id] = MiscItems [listitem][model_id]; }
			    else if (PlayerInfo [playerid][selected_item_type] ==  8) { PlayerInfo [playerid][selected_item_model_id] = WeaponItems [listitem][weapon_model_id]; }
			    else if (PlayerInfo [playerid][selected_item_type] ==  9) { PlayerInfo [playerid][selected_item_model_id] = MeleeWeaponItems [listitem][weapon_model_id]; }
			    else if (PlayerInfo [playerid][selected_item_type] == 10) { PlayerInfo [playerid][selected_item_model_id] = 2040; }
			    else if (PlayerInfo [playerid][selected_item_type] == 11) { PlayerInfo [playerid][selected_item_model_id] = HeadWearableItems [listitem][model_id]; }
			    else if (PlayerInfo [playerid][selected_item_type] == 12) { PlayerInfo [playerid][selected_item_model_id] = BodyWearableItems [listitem][wearable_model_id]; }
			    else if (PlayerInfo [playerid][selected_item_type] == 13) { PlayerInfo [playerid][selected_item_model_id] = BackpackItems [listitem][model_id]; }
			    else if (PlayerInfo [playerid][selected_item_type] == 14) { PlayerInfo [playerid][selected_item_model_id] = ArmourItems [listitem][model_id]; }
			
				PlayerInfo [playerid][selected_item_static_id] = listitem;
			
				ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_3, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Item amount", "Enter the item amount: ", "Add", "Back");
			}
	    }
	    case ADD_ITEM_DIALOG_ID_3:
	    {
	        if (!response)
	        {
         		new string [450];

		        if (listitem == 0)
		        {
					for (new i = 0; i < MAX_FOOD_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, FoodItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Food Items", string, "Select", "Back");
				}
				else if (listitem == 1)
		        {
					for (new i = 0; i < MAX_MEDICAL_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, MedicalItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Medical Items", string, "Select", "Back");
				}
				else if (listitem == 2)
				{
				    for (new i = 0; i < MAX_COOKABLE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, CookableItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Cookable Items", string, "Select", "Back");
				}
				else if (listitem == 3)
				{
				    for (new i = 0; i < MAX_RESOURCE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, ResourceItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Resource Items", string, "Select", "Back");
				}
				else if (listitem == 4)
				{
				    for (new i = 0; i < MAX_TOOL_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, ToolItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Tool Items", string, "Select", "Back");
				}
				else if (listitem == 5)
				{
				    for (new i = 0; i < MAX_BIG_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, BigItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Big Items", string, "Select", "Back");
				}
				else if (listitem == 6)
				{
				    for (new i = 0; i < MAX_MISC_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, MiscItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Misc Items", string, "Select", "Back");
				}
				else if (listitem == 7)
				{
				    for (new i = 0; i < MAX_WEAPON_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, WeaponItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Weapons", string, "Select", "Back");
				}
				else if (listitem == 8)
				{
				    for (new i = 0; i < MAX_MELEE_WEAPON_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, MeleeWeaponItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Melee Weapons", string, "Select", "Back");
				}
				else if (listitem == 9)
				{
				    for (new i = 0; i < MAX_AMMO_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, AmmoItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Ammo", string, "Select", "Back");
				}
				else if (listitem == 10)
				{
				    for (new i = 0; i < MAX_HEAD_WEARABLE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, HeadWearableItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Head Wearable Items", string, "Select", "Back");
				}
				else if (listitem == 11)
				{
				    for (new i = 0; i < MAX_BODY_WEARABLE_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, BodyWearableItems [i][wearable_name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Body Wearable Items", string, "Select", "Back");
				}
				else if (listitem == 12)
				{
				    for (new i = 0; i < MAX_BACKPACK_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, BackpackItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Backpacks", string, "Select", "Back");
				}
				else if (listitem == 13)
				{
				    for (new i = 0; i < MAX_ARMOUR_ITEMS; i++) { format (string, sizeof (string), "%s\n%s", string, ArmourItems [i][name]); }
					ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Armours", string, "Select", "Back");
				}
				
				return 0;
			}
        
            if (isnull (inputtext) || strval (inputtext) == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Invalid amount");
            
            new items;
			for (new i = 0; i < MAX_OBJECTS; i++) { if (ItemInfo [i][item_type] != 0) { items++; } }

            if (items == MAX_ITEMS)
			{
				PlayerInfo [playerid][selected_item_type] = 0;
				PlayerInfo [playerid][selected_item_amount] = 0;

				PlayerInfo [playerid][selected_item_model_id] = -1;
			    PlayerInfo [playerid][selected_item_static_id] = -1;

				SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"ITEMS LIMIT REACHED, CANNOT CREATE MORE ITEMS. ");

				return 0;
			}
        
	        new created_object,
	        	Float: x,   Float: y,   Float: z;
	        	
            PlayerInfo [playerid][selected_item_amount] = strval (inputtext);
	            
	        GetPlayerPos (playerid, x, y, z);
         	created_object = CreateObject (PlayerInfo [playerid][selected_item_model_id], x, y, z, 0.0, 0.0, 0.0);

		    ItemInfo [created_object][item_id] = items;
		    ItemInfo [created_object][item_type] = PlayerInfo [playerid][selected_item_type];
		    ItemInfo [created_object][item_amount] = PlayerInfo [playerid][selected_item_amount];
		    ItemInfo [created_object][item_model_id] = PlayerInfo [playerid][selected_item_model_id];
		    ItemInfo [created_object][item_static_id] = PlayerInfo [playerid][selected_item_static_id];
            ItemInfo [created_object][item_ammo] = -1;
            ItemInfo [created_object][item_unique_id] = -1;

			if (ItemInfo [created_object][item_type] == 1)
			{
			    ItemInfo [created_object][item_ammo] = FoodItems [ItemInfo [created_object][item_static_id]][item_ammo];
			}
			
			if (ItemInfo [created_object][item_type] == 2)
			{
			    ItemInfo [created_object][item_ammo] = MedicalItems [ItemInfo [created_object][item_static_id]][item_ammo];
			}
			
			if (ItemInfo [created_object][item_type] == 6)
			{
			    ItemInfo [created_object][item_ammo] = BigItems [ItemInfo [created_object][item_static_id]][item_ammo];
			}
			
			if (ItemInfo [created_object][item_type] == 14)
			{
			    ItemInfo [created_object][item_ammo] = floatround (ArmourItems [ItemInfo [created_object][item_static_id]][armour], floatround_round);
			}

            PlayerInfo [playerid][selected_item_type] = 0;
			PlayerInfo [playerid][selected_item_amount] = 0;
			
			PlayerInfo [playerid][selected_item_model_id] = -1;
		    PlayerInfo [playerid][selected_item_static_id] = -1;
         	
	        EditObject (playerid, created_object);
	        
	    }
		case CAR_REPAIR_DIALOG_ID:
		{
		    if(response)
		    {
		        new s_type, s_id, s_amount, s_ammo, s_state,
		        	vehicleid;
		        
		        vehicleid = PlayerInfo [playerid][selected_vehicle];
		        
				switch (listitem)
				{
				    case 0:
					{
						if (VehicleInfo [vehicleid][engine_usage] < 300) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"No problem found in the vehicle's engine. ");
					    if (!sscanf (PlayerInfo [playerid][selected_inventory_slot], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
					    {
							s_ammo -= MedicalItems [s_id][ammo_per_use];

							SetVehicleHealth (vehicleid, 1000);

							VehicleInfo [vehicleid][engine_usage] = 0;

							SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You successfully fixed the vehicle's engine using the tool kit. ");
							
							RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]);

					    }
					}
					case 1:
					{
					    if (VehicleInfo [vehicleid][wheel_usage] < 200) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"There are no damaged tires of the vehicle found. ");
					
					    new required_tires, tires_found;
					    
					    switch (VehicleInfo [vehicleid][vehicle_d_tires])
					    {
					        case  0: required_tires = 0;
					        case  1: required_tires = 1;
					        case  2: required_tires = 1;
					        case  3: required_tires = 2;
					        case  4: required_tires = 1;
					        case  5: required_tires = 2;
					        case  6: required_tires = 2;
					        case  7: required_tires = 3;
					        case  8: required_tires = 1;
					        case  9: required_tires = 2;
					        case 10: required_tires = 2;
					        case 11: required_tires = 3;
					        case 12: required_tires = 2;
					        case 13: required_tires = 3;
					        case 14: required_tires = 3;
					        case 15: required_tires = 4;
					    }
					    
					    for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
					    {
					        if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
					        {
					            if (s_type == 4)
					            {
					                if (s_id == 9)
									{
									    if (s_amount >= required_tires)
									    {
									        tires_found = 1;
									        VehicleInfo [vehicleid][vehicle_d_tires] = 0;
									        UpdateVehicleDamageStatus (vehicleid, VehicleInfo [vehicleid][vehicle_d_panels], VehicleInfo [vehicleid][vehicle_d_doors], VehicleInfo [vehicleid][vehicle_d_lights], VehicleInfo [vehicleid][vehicle_d_tires]);
											RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]);
											SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You successfully repaired the damaged vehicle tire(s). ");
											break;
										}
									}
					            }
					        }
					    }
					    
					    if (tires_found == 0)
					    {
					        SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You don't have enough tires. ");
					    }
					
					}
				}
		    }
		}
	    case PLAYER_INVENTORY_DIALOG_ID_1:
	    {
	        if (response)
	        {
	            if (listitem == PlayerInfo [playerid][slots_used]) return 0;
	            if (listitem == (PlayerInfo [playerid][slots_used] + 1)) return ShowPlayerDialog (playerid, EQUIPPED_ITEMS_DIALOG_ID_1, DIALOG_STYLE_LIST, ""SERVER_TAG" - Equipped Items", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Equipped Weapons", "Select", "Back");

				PlayerInfo [playerid][selected_inventory_slot] = listitem;
				ShowPlayerDialog (playerid, PLAYER_INVENTORY_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Inventory Item", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Use\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Equip/Unequip\n"COLOR_MAIN_HEX"3. "COLOR_WHITE"Drop\n"COLOR_MAIN_HEX"4. "COLOR_WHITE"Move UP\n"COLOR_MAIN_HEX"5. "COLOR_WHITE"Move DOWN", "Select", "Back");
			}
		}
	    case PLAYER_INVENTORY_DIALOG_ID_2:
	    {
	        if (!response)
	        {
	            cmd_inv (playerid, "");
	            return 0;
	        }
	        if (response)
	        {
				new type, id, amount, ammo, status;
				sscanf (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], "iiiii", type, id, amount, ammo, status);

				if (listitem == 0)
				{
				    if (type == 1)
				    {
				    
				        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
        				if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
				    
				        new i_type, i_id, i_amount, i_ammo, i_state,
				            has_opener;
				    
				        if (id == 9 || id == 10)
				        {
							for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
							{
							    if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", i_type, i_id, i_amount, i_ammo, i_state))
							    {
							        if (i_type == 4 && i_id == 3)
							        {
							            has_opener = 1;
							        }
							    }
							}
							
							if (has_opener == 0)
							{
							    SendClientMessage (playerid, COLOR_MAIN, "[INFO] You need a can opener to use this item. ");
							    return 0;
							}
				        }
				        
				        if (FoodItems [id][hunger] > FoodItems [id][thirst])
				        {
				            if ((FoodItems [id][hunger] + PlayerInfo [playerid][hunger]) > 100.0)
				            {
				                new string [200];
				                format (string, sizeof (string), "[INFO] %sYou can use this item if your hunger level is lower than %d. ", COLOR_WHITE, floatround(100.0 - FoodItems [id][hunger], floatround_round));
				                SendClientMessage (playerid, COLOR_MAIN, string);
				                return 0;
				            }
				        }
				        else
				        {
				            if ((FoodItems [id][thirst] + PlayerInfo [playerid][thirst]) > 100.0)
				            {
				                new string [200];
				                format (string, sizeof (string), "[INFO] %sYou can use this item if your hydration level is lower than %d. ", COLOR_WHITE, floatround(100.0 - FoodItems [id][thirst], floatround_round));
				                SendClientMessage (playerid, COLOR_MAIN, string);
				                return 0;
				            }
				        }
						
						PlayerInfo [playerid][hunger] = (PlayerInfo [playerid][hunger] + FoodItems [id][hunger]);
						PlayerInfo [playerid][thirst] = (PlayerInfo [playerid][thirst] + FoodItems [id][thirst]);
				    
				        UpdatePlayerBars (playerid);
				    
				        if (FoodItems [id][item_ammo] != -1)
				        {
							
							ammo -= FoodItems [id][ammo_per_use];

							if (ammo <= 0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }
							else
							{
							    new item_data [124];
							    format (item_data, sizeof (item_data), "%d %d %d %d -1", type, id, amount, ammo);
							    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "%s", item_data);
							}
						}
						else
						{
							amount--;
							
							if (amount <= 0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }
							else
							{
							    new item_data [124];
							    format (item_data, sizeof (item_data), "%d %d %d %d -1", type, id, amount, ammo);
							    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "%s", item_data);
							}
						}

					}
					else if (type == 2)
				    {

                        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");


						if (id == 1)
						{
							if (IsPlayerNearAnyVehicle (playerid) == -1) return SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You are not near any vehicle. ");
							
							PlayerInfo [playerid][selected_vehicle] = IsPlayerNearAnyVehicle (playerid);
							ShowPlayerDialog (playerid, CAR_REPAIR_DIALOG_ID, DIALOG_STYLE_LIST, ""COLOR_WHITE"Car Repair Kit", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Repair Engine\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Repair tires", "Select", "Cancel");

							return 0;
						}
						
						if (id == 7)
						{
						    if (IsPlayerNearAnyVehicle (playerid) == -1) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not near any vehicle. ");

                            new vehicleid = IsPlayerNearAnyVehicle (playerid);
                            
                            if (VehicleInfo [vehicleid][vehicle_fuel] > 80.0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You can use this item if the vehicle's fuel is less than 80%. ");
                            
                            
                            VehicleInfo [vehicleid][vehicle_fuel] += 20.0;
                            
                            ammo -= MedicalItems [id][ammo_per_use];
                            
                            if (ammo <= 0.0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }
                            else
                            {
                                new item_data [124];
                                format (item_data, sizeof (item_data), "%d %d %d %d -1", type, id, amount, ammo);
                                format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "%s", item_data);
                            }

							SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Vehicle Refueled. ");

							return 0;
						}

        				new Float: hp;
				        GetPlayerHealth (playerid, hp);

						SetPlayerHealth (playerid, hp + MedicalItems [id][healing]);

				        if (MedicalItems [id][item_ammo] != -1)
				        {

							ammo -= MedicalItems [id][ammo_per_use];

							if (ammo <= 0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }
							else
							{
							    new item_data [124];
							    format (item_data, sizeof (item_data), "%d %d %d %d -1", type, id, amount, ammo);
							    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "%s", item_data);
							}
						}
						else
						{
							amount--;

							if (amount <= 0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }
							else
							{
							    new item_data [124];
							    format (item_data, sizeof (item_data), "%d %d %d %d -1", type, id, amount, ammo);
							    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "%s", item_data);
							}
						}

					}
					else if (type == 3)
					{
					    if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
                        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_SMOKE_CIGGY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You need to (/stopsmoking) first in order to do other tasks. ");
                        
						if (PlayerInfo [playerid][player_action] == 2) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot cook and craft at the same time. ");
					
						new near_campfire,

						campfire_id,

						Float: x, Float: y, Float: z;

						for (new i = 0; i < MAX_OBJECTS; i++)
						{
						    if (ItemInfo [i][item_type] == 6 && ItemInfo[i][item_static_id] == 0)
						    {
						        if (ItemInfo [i][item_attached] != -1)
						        {
							        GetObjectPos (i, x, y, z);
							        
							        if (IsPlayerInRangeOfPoint (playerid, 1.5, x, y, z))
									{
							            near_campfire = 1;
							            campfire_id = i;
							        }
						        }
						    }
						}

						if (near_campfire == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not near any burning campfire. ");

						new s_type, s_id, s_amount, s_ammo, s_state,

						    has_pan;

	                    for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
	                    {
	                        if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
	                        {
	                            if (s_type == 2 && s_id == 13)
	                            {
	                                has_pan = 1;
	                            }
	                        }
	                    }

						if (has_pan == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You do not have a pan to cook. ");

						switch (PlayerInfo [playerid][cooking])
						{
						    case 1:  PlayerInfo [playerid][cooking_time] = 60;
						    case 2:  PlayerInfo [playerid][cooking_time] = 58;
						    case 3:  PlayerInfo [playerid][cooking_time] = 56;
						    case 4:  PlayerInfo [playerid][cooking_time] = 54;
						    case 5:  PlayerInfo [playerid][cooking_time] = 52;
						    case 6:  PlayerInfo [playerid][cooking_time] = 50;
						    case 7:  PlayerInfo [playerid][cooking_time] = 48;
						    case 8:  PlayerInfo [playerid][cooking_time] = 46;
						    case 9:  PlayerInfo [playerid][cooking_time] = 44;
							case 10: PlayerInfo [playerid][cooking_time] = 42;
						}

                        PlayerInfo [playerid][player_action] = 1;

						PlayerInfo [playerid][cooked] = 0;

						ShowCookingBar (playerid);

						PlayerInfo [playerid][cooking_timer] = SetTimerEx ("OnPlayerCookFood", 1000, true, "iii", playerid, id, campfire_id);
						
					}
					else if (type == 5)
					{
					    if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
					
					    switch (id)
						{
						    case 0: ShowPlayerDialog (playerid, CUFF_PLAYER_DIALOG_ID, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Cuff Player", "Enter the id of player you want to cuff: ", "Ok", "Cancel");
						    case 1: ShowPlayerDialog (playerid, UNCUFF_PLAYER_DIALOG_ID_1, DIALOG_STYLE_LIST, ""SERVER_TAG" - Uncuff Player", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Uncuff yourself\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Uncuff another player", "Select", "Cancel");

							default:
							{
							    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This item cannot be used. ");
							    ShowPlayerDialog (playerid, PLAYER_INVENTORY_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Inventory Item", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Use\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Equip/Unequip\n"COLOR_MAIN_HEX"3. "COLOR_WHITE"Drop\n"COLOR_MAIN_HEX"4. "COLOR_WHITE"Move UP\n"COLOR_MAIN_HEX"5. "COLOR_WHITE"Move DOWN", "Select", "Back");
							}
						}
					}
					else if (type == 6)
					{
					    new Float: x, Float: y, Float: z,
					    
        				created_item,
        				created_item_2,
        				
				       	items;

				        GetPlayerPos (playerid, x, y, z);
				        MapAndreas_FindZ_For2DCoord (x, y, z);

						for (new i = 0; i < MAX_OBJECTS; i++)
						{
						    if (ItemInfo [i][item_type] >= 1)
						    {
						        items++;
						    }
						}

					    created_item = CreateObject (BigItems [id][model_id_1], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = BigItems [id][model_id_1];
					    
					    if (BigItems [id][model_id_2] != -1)
					    {
						    created_item_2 = CreateObject (BigItems [id][model_id_2], x, y, z -0.35, 0.0, 0.0, 0.0);
						    ItemInfo [created_item_2][item_model_id] = BigItems [id][model_id_2];
					    }
					    
					    AttachObjectToObject (created_item_2, created_item, 0.0, 0.0, -1.45, 0.0, 0.0, 0.0, 1);
					    
					    ammo--;
					    
					    RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]);

						ItemInfo [created_item][item_static_id] = id;
						ItemInfo [created_item][item_ammo] 		= ammo;
						
						if (ammo == 0)
						{
						    ItemInfo [created_item][item_type]  = 0;
						}
						else
						{
							ItemInfo [created_item][item_type]	= type;
						}
						
						ItemInfo [created_item][item_id] 		= items;
	                    ItemInfo [created_item][item_amount] 	= amount;
	                    ItemInfo [created_item][item_attached]  = created_item_2;
	                    ItemInfo [created_item][item_timer]     = SetTimerEx ("ExtinguishFire", 5 * 60 * 1000, false, "i", created_item);
	                    
	                    RemovePlayerAttachedObject (playerid, 2);
	                    SetPlayerSpecialAction (playerid, SPECIAL_ACTION_NONE);
	                    
	                    EditObject (playerid, created_item);
					    
					}
					else if (type == 7)
					{
					    if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
					
					    switch (id)
					    {
					        case 0:
					        {
					            new string [250];
						        format (string, sizeof (string), "%s- Name: %s\n\n%s- Age: {FFFFFF}%d\n\n%s- Date of issue: {FFFFFF}%s", COLOR_MAIN_HEX, "Player Name", COLOR_MAIN_HEX, 24, COLOR_MAIN_HEX, "5/20/19");
						        ShowPlayerDialog (playerid, DRIVING_LICENSE_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""SERVER_TAG" - Driving License", string, "Ok", "");
					        }
					        case 1:
						    {
						        new query [250];
						        mysql_format (mysql, query, sizeof (query), "SELECT * FROM `players` WHERE `ACCOUNT_ID` = %d", ammo);
						        mysql_tquery (mysql, query, "OnPlayerCheckDrivingLicense", "i", playerid);
						    }
						    case 2:
						    {
						        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This item cannot be used. ");
								ShowPlayerDialog (playerid, PLAYER_INVENTORY_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Inventory Item", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Use\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Equip/Unequip\n"COLOR_MAIN_HEX"3. "COLOR_WHITE"Drop\n"COLOR_MAIN_HEX"4. "COLOR_WHITE"Move UP\n"COLOR_MAIN_HEX"5. "COLOR_WHITE"Move DOWN", "Select", "Back");
						    }
						    case 3:
						    {
						        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_SMOKE_CIGGY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are already smoking a ciggarette. ");

						    
								SetPlayerSpecialAction (playerid, SPECIAL_ACTION_SMOKE_CIGGY);
								SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You lit up the cigarette to smoke it. ");
								SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Use (/stopsmoking) to stop. ");

								amount--;

								if (amount >= 1) { format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "2 %d %d -1 -1", id ); }
								else if (amount == 0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }
						    }
						    case 8:
						    {
						        SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You opened a box of cigarrete. ");
						        
						        new s_type, s_id, s_amount, s_ammo, s_state,
						            slot;
						            
								slot = -1;

						        for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
						        {
						            if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
						            {
						                if (s_type == 7 && s_id == 3)
						                {
						                    slot = i;
						                }
									}
						        }
						        
								if (slot == -1) { slot = PlayerInfo [playerid][selected_inventory_slot]; }
								
								format (PlayerInventory [playerid][slot][item], 124, "7 3 20 -1 -2");
						    }
					    }
					}
					else if (type == 4 || type == 8 || type == 9 || type == 10 || type == 11 || type == 12 || type == 13 || type == 14)
				    {
				        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This item cannot be used. ");
				        ShowPlayerDialog (playerid, PLAYER_INVENTORY_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Inventory Item", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Use\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Equip/Unequip\n"COLOR_MAIN_HEX"3. "COLOR_WHITE"Drop\n"COLOR_MAIN_HEX"4. "COLOR_WHITE"Move UP\n"COLOR_MAIN_HEX"5. "COLOR_WHITE"Move DOWN", "Select", "Back");
				        return 0;
				    }
				}
				else if (listitem == 1)
				{
				    if (type == 1 || type == 2 || type == 3 || type == 4 || type == 5 || type == 6  || type == 7  || type == 10)
				    {
				        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This item cannot be equipped. ");
				        return 0;
				    }
				    else if (type == 8)
				    {
				        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
				    
				        new s_type, s_id, s_amount, s_ammo, s_status,
				            kill_process,
				            found;

						if (status == -3)
						{
						
						    new weaponid, slot;
						
							switch (type)
							{
							    case 3: weaponid = WeaponItems [id][weapon_id];
							    case 4: weaponid = MeleeWeaponItems [id][weapon_id];
							}
						
						    for (new i = 0; i < MAX_WEAPON_SLOTS; i++)
						    {
						        if (PlayerWeaponInfo [playerid][i][slot_used] == 1)
						        {
							        if (PlayerWeaponInfo [playerid][i][weapon_id] == weaponid)
							        {
										slot = i;
							        }
						        }
						    }
							
							format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "8 %d 1 -1 -2", PlayerWeaponInfo [playerid][slot][weapon_static_id]);
							
							new a_type, a_id, a_amount, a_ammo, a_status;
							
							for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
							{
								if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", a_type, a_id, a_amount, a_ammo, a_status))
								{
								    if (a_type == 10 && a_id == WeaponItems [PlayerWeaponInfo [playerid][slot][weapon_static_id]][weapon_bullet_type] && status != -2)
								    {
									    format (PlayerInventory [playerid][i][item], 124, "10 %d %d -1 -2",
										WeaponItems [PlayerWeaponInfo [playerid][slot][weapon_static_id]][weapon_bullet_type],
										PlayerWeaponInfo [playerid][slot][weapon_ammo]);
									}
									else continue;
								}
							
							}

							RemovePlayerWeapon (playerid, PlayerWeaponInfo [playerid][slot][weapon_id]);

							PlayerWeaponInfo [playerid][slot][slot_used] = 0;
							PlayerWeaponInfo [playerid][slot][weapon_id] = 0;
			                PlayerWeaponInfo [playerid][slot][weapon_model_id] = 0;
							PlayerWeaponInfo [playerid][slot][weapon_static_id] = -1;
							PlayerWeaponInfo [playerid][slot][weapon_type] = 0;
			                PlayerWeaponInfo [playerid][slot][weapon_damage] = 0.0;
			                PlayerWeaponInfo [playerid][slot][weapon_ammo] = 0;
						
						}
						else if (status == -2)
						{
				    
					        for (new i = 0; i < MAX_WEAPON_SLOTS; i++)
					        {
					            if (PlayerWeaponInfo [playerid][i][weapon_id] == WeaponItems [id][weapon_id])
					            {
					                SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot equip two weapons of same type. ");
					                kill_process = 1;
					                break;
					            }
					        }

					        if (kill_process == 1) return 0;

					        for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
					        {
					            if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
					            {
					                if (s_type == 10)
					                {
					                    if (s_id == WeaponItems [id][weapon_bullet_type])
					                    {
					                        found = 1;

											for (new n = 0; n < MAX_WEAPON_SLOTS; n++)
											{
											    if (PlayerWeaponInfo [playerid][n][slot_used] == 0)
											    {

											        PlayerWeaponInfo [playerid][n][slot_used] = 1;
											        PlayerWeaponInfo [playerid][n][weapon_id] = WeaponItems [id][weapon_id];
											        PlayerWeaponInfo [playerid][n][weapon_model_id] = WeaponItems [id][weapon_model_id];
											        PlayerWeaponInfo [playerid][n][weapon_static_id] = WeaponItems [id][item_static_id];
											        PlayerWeaponInfo [playerid][n][weapon_damage] = WeaponItems [id][weapon_damage];
											        PlayerWeaponInfo [playerid][n][weapon_ammo] = s_amount;
											        PlayerWeaponInfo [playerid][n][weapon_type] = GetWeaponType (PlayerWeaponInfo [playerid][n][weapon_id]);

											        GivePlayerWeapon (playerid, PlayerWeaponInfo [playerid][n][weapon_id], PlayerWeaponInfo [playerid][n][weapon_ammo]);

                                                    format (PlayerInventory [playerid][i][item], 124, "10 %d -1 -1 %d", s_id, n);
					                        		format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "8 %d 1 -1 -3", id);

											        new string [250];
													format (string, sizeof (string), "[INFO] %sYou have equipped %s with %d bullets", COLOR_WHITE, WeaponItems [id][name], PlayerWeaponInfo [playerid][n][weapon_ammo]);
													SendClientMessage (playerid, COLOR_MAIN, string);
											        break;
											    }

											    if (n == (MAX_WEAPON_SLOTS - 1))
												{
												    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE" No space to equip more weapons. ");
												}
											}
											break;
					                    }
					                }
					            }
					        }
					        
					        if (found == 0)
					        {
						        new error_message [175];

		            			format (error_message, sizeof (error_message), "[ERROR] %sYou do not have %s for this weapon. ", COLOR_WHITE, AmmoItems [WeaponItems [id][weapon_bullet_type]][name]);
		               			SendClientMessage (playerid, COLOR_MAIN, error_message);
	               			}
						}
				    }
				    else if (type == 9)
				    {
				    
				        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
				    
				        for (new i = 0; i < MAX_WEAPON_SLOTS; i++)
						{
						    if (!GetWeaponType (PlayerWeaponInfo [playerid][i][weapon_id]))
						    {
						        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot equip two or more weapons of same type.");
						        return 0;
						    }
						}
						
						if (status == -3)
						{
							new weaponid, slot;

							weaponid = MeleeWeaponItems [id][weapon_id];

						    for (new i = 0; i < MAX_WEAPON_SLOTS; i++)
						    {
						        if (PlayerWeaponInfo [playerid][i][weapon_id] == weaponid)
						        {
									slot = i;
						        }
						    }

						    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "9 %d 1 -1 -2", PlayerWeaponInfo [playerid][slot][weapon_static_id]);

							RemovePlayerWeapon (playerid, PlayerWeaponInfo [playerid][slot][weapon_id]);

							PlayerWeaponInfo [playerid][slot][slot_used] = 0;
							PlayerWeaponInfo [playerid][slot][weapon_id] = 0;
			                PlayerWeaponInfo [playerid][slot][weapon_model_id] = 0;
							PlayerWeaponInfo [playerid][slot][weapon_static_id] = -1;
							PlayerWeaponInfo [playerid][slot][weapon_type] = 0;
			                PlayerWeaponInfo [playerid][slot][weapon_damage] = 0.0;
			                PlayerWeaponInfo [playerid][slot][weapon_ammo] = 0;
			                
						}
						else if (status == -2)
						{
					        for (new n = 0; n < MAX_WEAPON_SLOTS; n++)
							{
							    if (PlayerWeaponInfo [playerid][n][slot_used] == 0)
							    {
	                                format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "9 %d 1 -1 -3", id);

							        PlayerWeaponInfo [playerid][n][slot_used] = 1;
							        PlayerWeaponInfo [playerid][n][weapon_id] = MeleeWeaponItems [id][weapon_id];
							        PlayerWeaponInfo [playerid][n][weapon_model_id] = MeleeWeaponItems [id][weapon_model_id];
							        PlayerWeaponInfo [playerid][n][weapon_static_id] = MeleeWeaponItems [id][item_static_id];
							        PlayerWeaponInfo [playerid][n][weapon_damage] = MeleeWeaponItems [id][weapon_damage];
							        PlayerWeaponInfo [playerid][n][weapon_ammo] = 1;
							        PlayerWeaponInfo [playerid][n][weapon_type] = 0;

							        GivePlayerWeapon (playerid, MeleeWeaponItems [id][weapon_id], 1);

							        new string [124];
									format (string, sizeof (string), "[INFO] %sYou equipped a/an %s%s", COLOR_WHITE, COLOR_MAIN_HEX, MeleeWeaponItems [id][name]);
									SendClientMessage (playerid, COLOR_MAIN, string);
							        break;
							    }

							    if (n == MAX_WEAPON_SLOTS)
								{
								    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"No space to equip more weapons. ");
								}
							}
						}
				    }
				    else if (type == 11)
				    {
				        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
				    
				        if (status == -3)
				        {
				            new string [250];

					        format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "11 %d 1 -1 -2", id);
					        PlayerInfo [playerid][head_protection] = 0;

					        format (string, sizeof (string), "[INFO] %sYou have unequipped %s", COLOR_WHITE, HeadWearableItems [id][name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);
					        
					        RemovePlayerAttachedObject (playerid, 0);
					        
				        }
				        else if (status == -2)
						{
				        
				            if (PlayerInfo [playerid][head_protection] >= 1)
				            {
								SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are already wearing a helmet/hat. ");
								return 0;
				            }
				            
				            new string [250];
				            
				            format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "11 %d 1 -1 -3", id);
					        PlayerInfo [playerid][head_protection] += HeadWearableItems [id][head_hits];

					        format (string, sizeof (string), "[INFO] %sYou have equipped %s", COLOR_WHITE, HeadWearableItems [id][name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);
					        
					        SetPlayerAttachedObject (playerid, 0, HeadWearableItems [id][model_id], 2, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 1.200000, 1.200000, 1.200000);
				            
				        }
				    }
				    else if (type == 12)
				    {
				        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
				    
				        if (status == -3)
				        {
				            if ((PlayerInfo [playerid][inventory_virtual_slots] - BodyWearableItems [id][wearable_slots]) < PlayerInfo [playerid][slots_used])
				            {
				                SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This cloth cannot be un equipped while its containing other items. ");
				                return 0;
				            }
				            
				            new string [250];

					        format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "12 %d 1 -1 -2", id);
					        PlayerInfo [playerid][inventory_virtual_slots] -= BodyWearableItems [id][wearable_slots];

					        format (string, sizeof (string), "[INFO] %sYou have unequipped %s", COLOR_WHITE, BodyWearableItems [id][wearable_name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);
					        
				        }
				        else if (status == -2)
				        {
					        new s_type, s_id, s_amount, s_ammo, s_status;

					        for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
					        {
					            if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
					            {
					                if (s_type == 7 && s_id == id && s_status == -3)
					                {
										SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot equip two items of same type. ");
										return 0;
							        }
					            }
					        }

					        new string [250];

					        format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "12 %d 1 -1 -3", id);
					        PlayerInfo [playerid][inventory_virtual_slots] += BodyWearableItems [id][wearable_slots];

					        format (string, sizeof (string), "[INFO] %sYou have equipped %s", COLOR_WHITE, BodyWearableItems [id][wearable_name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);
				        }
				        
				    }
				    else if (type == 13)
					{
					    if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
					
					    if (status == -3)
				        {
				        
				            if (PlayerInfo [playerid][slots_used] > (PlayerInfo [playerid][inventory_virtual_slots] - BackpackItems [id][slots]))
				            {
				                SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This backpack cannot be un-equipped while its containing other items. ");
				                return 0;
				            }

				            new string [250];

					        format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "13 %d 1 -1 -2", id);
					        PlayerInfo [playerid][inventory_virtual_slots] -= BackpackItems [id][slots];

					        format (string, sizeof (string), "[INFO] %sYou have unequipped %s", COLOR_WHITE, BackpackItems [id][name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);
					        
					        RemovePlayerAttachedObject (playerid, 1);

				        }
				        else if (status == -2)
				        {
					        new s_type, s_id, s_amount, s_ammo, s_status;

					        for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
					        {
					            if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
					            {
					                if (s_type == 13 && s_status == -3)
					                {
										SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are already wearing a bag. ");
										return 0;
							        }
					            }
					        }

					        format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "13 %d 1 -1 -3", id);
					        
					        PlayerInfo [playerid][inventory_virtual_slots] += BackpackItems [id][slots];

                            new string [250];

					        format (string, sizeof (string), "[INFO] %sYou have equipped %s", COLOR_WHITE, BackpackItems [id][name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);
					        
							switch (BackpackItems [id][model_id])
							{
					        	case -2025: SetPlayerAttachedObject (playerid, 1, BackpackItems [id][model_id], 1, 0.0, -0.1, 0.0, 0.0, 90.0, 0.0);
								default: SetPlayerAttachedObject (playerid, 1, BackpackItems [id][model_id], 1, -0.164999, -0.153999, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
							}
						}
					}
					else if (type == 14)
					{
					    if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while handcuffed. ");
						if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot use items while carrying something. ");
					
					    if (status == -3)
					    {
					        new string [150],
					            Float: a;
					            
							GetPlayerArmour (playerid, a);
					        
							format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "14 %d 1 %d -2", id, floatround (a, floatround_round));
							
							format (string, sizeof (string), "[INFO] %sYou have unequipped %s. ", COLOR_WHITE, ArmourItems [id][name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);
					        
							SetPlayerArmour (playerid, 0.0);
					    }
					    else if (status == -2)
						{
					        new Float: a;
							GetPlayerArmour (playerid, a);
							
							if (a > 0.0) return SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You cannot equip two armour jackers at once. ");

                            new string [150];

							format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "14 %d 1 -1 -3", id);

							format (string, sizeof (string), "[INFO] %sYou have equipped %s. ", COLOR_WHITE, ArmourItems [id][name]);
					        SendClientMessage (playerid, COLOR_MAIN, string);

							SetPlayerArmour (playerid, ArmourItems [id][armour]);
						}
					}
				    
				}
				else if (listitem == 2)
				{
				
				    if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot pickup items while handcuffed. ");

					if (status == -3 || status >= 0)
				    {
				        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The item is equipped, it cannot be dropped. ");
				        return 0;
				    }
				
    				new Float: x, Float: y, Float: z,
        				created_item,
				       	items;

			        GetPlayerPos (playerid, x, y, z);

			        MapAndreas_FindZ_For2DCoord (x, y, z);

					for (new i = 0; i < MAX_OBJECTS; i++)
					{
					    if (ItemInfo [i][item_type] >= 1)
					    {
					        items++;
					    }
					}

					if (type == 1)
					{
					    created_item = CreateObject (FoodItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = FoodItems [id][model_id];

					}
					else if (type == 2)
					{
					    created_item = CreateObject (MedicalItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = MedicalItems [id][model_id];

					}
					else if (type == 3)
					{
					    created_item = CreateObject (CookableItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = CookableItems [id][model_id];

					}
					else if (type == 4)
					{
					    created_item = CreateObject (ResourceItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = ResourceItems [id][model_id];

					}
					else if (type == 5)
					{
					    created_item = CreateObject (ToolItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = ToolItems [id][model_id];
					}
					else if (type == 6)
					{
					    created_item = CreateObject (BigItems [id][model_id_1], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = BigItems [id][model_id_1];
					    
					    PlayerInfo [playerid][carrying] = 0;
					    
					    RemovePlayerAttachedObject (playerid, 2);
					    SetPlayerSpecialAction (playerid, SPECIAL_ACTION_NONE);

					}
					else if (type == 7)
					{
					    created_item = CreateObject (MiscItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = MiscItems [id][model_id];
					}
					else if (type == 8)
					{
					    created_item = CreateObject (WeaponItems [id][weapon_model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = WeaponItems [id][weapon_model_id];
					}
					else if (type == 9)
					{
					    created_item = CreateObject (MeleeWeaponItems [id][weapon_model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = MeleeWeaponItems [id][weapon_model_id];
					}
					else if (type == 10)
					{
					    created_item = CreateObject (2040, x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = 2040;
					}
					else if (type == 11)
					{
					    created_item = CreateObject (HeadWearableItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = HeadWearableItems [id][model_id];
					}
					else if (type == 12)
					{
						if (PlayerInfo [playerid][slots_used] >= (PlayerInfo [playerid][inventory_virtual_slots] - BodyWearableItems [id][wearable_slots]))
						{
						    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This cloth contains items. It cannot be dropped. ");
						    return 0;
						}
						
						created_item = CreateObject (BodyWearableItems [id][wearable_model_id], x, y, z, 0.0, 0.0, 0.0);
						ItemInfo [created_item][item_model_id] = BodyWearableItems [id][wearable_model_id];
						
					}
					else if (type == 13)
					{
					    if (PlayerInfo [playerid][slots_used] >= (PlayerInfo [playerid][inventory_virtual_slots] - BackpackItems [id][slots]))
					    {
					        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The backpack contains items, you cannot drop it. ");
					        return 0;
					    }
					    
					    created_item = CreateObject (BackpackItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
						ItemInfo [created_item][item_model_id] = BackpackItems [id][model_id];
					}
					else if (type == 14)
					{
					    created_item = CreateObject (ArmourItems [id][model_id], x, y, z, 0.0, 0.0, 0.0);
						ItemInfo [created_item][item_model_id] = ArmourItems [id][model_id];
					}

					
					RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]);
					
					ItemInfo [created_item][item_static_id] = id;
					ItemInfo [created_item][item_ammo] 		= ammo;
					ItemInfo [created_item][item_type]		= type;
					ItemInfo [created_item][item_id] 		= items;
                    ItemInfo [created_item][item_amount] 	= amount;
                    
                    EditObject (playerid, created_item);
                    
				}
				else if (listitem == 3)
				{
				
				    if (PlayerInfo [playerid][selected_inventory_slot] == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Item cannot be moved up. ");
				    
				    new slot_item [124];
				    
				    format (slot_item, 124, PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item]);
				    
				    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot] - 1][item]);
				    format (PlayerInventory [playerid][(PlayerInfo [playerid][selected_inventory_slot] - 1)][item], 124, slot_item);
				    
					PlayerInfo [playerid][selected_inventory_slot]--;
					
					SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Item moved UP. ");
					
					ShowPlayerDialog (playerid, PLAYER_INVENTORY_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Inventory Item", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Use\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Equip/Unequip\n"COLOR_MAIN_HEX"3. "COLOR_WHITE"Drop\n"COLOR_MAIN_HEX"4. "COLOR_WHITE"Move UP\n"COLOR_MAIN_HEX"5. "COLOR_WHITE"Move DOWN", "Select", "Back");
					
				}
				else if (listitem == 4)
				{
				    if (PlayerInfo [playerid][selected_inventory_slot] == (PlayerInfo [playerid][slots_used] - 1)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Item cannot be moved down. ");
				    
				    new slot_item [124];

				    format (slot_item, 124, PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item]);

				    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot] + 1][item]);
				    format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot] + 1][item], 124, slot_item);

					PlayerInfo [playerid][selected_inventory_slot]++;

					SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Item moved DOWN. ");
					
					ShowPlayerDialog (playerid, PLAYER_INVENTORY_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Inventory Item", ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Use\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Equip/Unequip\n"COLOR_MAIN_HEX"3. "COLOR_WHITE"Drop\n"COLOR_MAIN_HEX"4. "COLOR_WHITE"Move UP\n"COLOR_MAIN_HEX"5. "COLOR_WHITE"Move DOWN", "Select", "Back");
					
				}
			}
			
	    }
	    case NEARBY_ITEMS_DIALOG_ID_1:
		{
		    if (!response)
		    {
		        for (new i = 0; i < 64; i++) { PlayerInfo [playerid][nearby_items][i] = -1; }
		        return 0;
		    }
			else if (response)
			{
			    new string [250];

			    PlayerInfo [playerid][selected_nearby_item] = PlayerInfo [playerid][nearby_items][listitem];

			    switch (ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_type])
			    {
			    	case  1: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, FoodItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case  2: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MedicalItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case  3: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, CookableItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case  4: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ResourceItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
                    case  5: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ToolItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
					case  6: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BigItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case  7: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MiscItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case  8: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, WeaponItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case  9: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MeleeWeaponItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case 10: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, AmmoItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case 11: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, HeadWearableItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case 12: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BodyWearableItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][wearable_name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case 13: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BackpackItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
			    	case 14: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ArmourItems [ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][listitem]][item_amount]);
				}

			    ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_2, DIALOG_STYLE_LIST, string, ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Pickup All\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Enter an amount", "Select", "Back");
			}
		}
		case NEARBY_ITEMS_DIALOG_ID_2:
		{
		    if (!response)
		    {
				cmd_pickup (playerid, "");
		        return 0;
		    }
			else if (response)
			{
			    if (listitem == 0)
			    {
			        PickupItem (playerid, PlayerInfo [playerid][selected_nearby_item], -1);
			    }
			    else if (listitem == 1)
			    {
			        ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_3, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Pickup", "Enter an amount: ", "Pickup", "Back");
			    }
			}
		}
		case NEARBY_ITEMS_DIALOG_ID_2_PART:
		{
		    if (!response)
		    {
		        return 0;
		    }
			else if (response)
			{
			    if (listitem == 0)
			    {
			        PickupItem (playerid, PlayerInfo [playerid][selected_nearby_item], -1);
			    }
			    else if (listitem == 1)
			    {
			        ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_3, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Pickup", "Enter an amount: ", "Pickup", "Back");
			    }
			}
		}
		case NEARBY_ITEMS_DIALOG_ID_3:
		{
		    if (!response)
		    {
		        new string [250];
		    
		    	switch (ItemInfo[PlayerInfo [playerid][selected_nearby_item]][item_type])
			    {
			    	case  1: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, FoodItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  2: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MedicalItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  3: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, CookableItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  4: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ResourceItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  5: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ToolItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  6: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BigItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  7: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MiscItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  8: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, WeaponItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case  9: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MeleeWeaponItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case 10: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, AmmoItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case 11: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, HeadWearableItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case 12: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BodyWearableItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][wearable_name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case 13: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BackpackItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
			    	case 14: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ArmourItems [ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount]);
				}

			    ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_2, DIALOG_STYLE_LIST, string, ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Pickup All\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Enter an amount", "Pickup", "Back");
				return 0;
			}
		    else if (response)
		    {
		        if (isnull (inputtext) || !strval (inputtext))
		        {
		            ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_3, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Pickup", "Enter an amount: ", "Pickup", "Back");
		            SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Please enter a valid amount. ");
		            return 0;
		        }

				if (strval (inputtext) > ItemInfo [PlayerInfo [playerid][selected_nearby_item]][item_amount])
		        {
		            ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_3, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Pickup", "Enter an amount: ", "Pickup", "Back");
		            SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The amount cannot be greater than than the items present. ");
		            return 0;
		        }
		        
		        PickupItem (playerid, PlayerInfo [playerid][selected_nearby_item], strval (inputtext));
		        
		    }
		}
		case CUFF_PLAYER_DIALOG_ID:
		{
		    if (isnull (inputtext) || strval (inputtext) == INVALID_PLAYER_ID || !IsPlayerConnected (strval (inputtext))) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] The specified player is not connected. ");
			if (GetPlayerSpecialAction(strval (inputtext)) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The player is already cuffed. ");
            if (strval (inputtext) == playerid) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot uncuff yourself. ");

			new targetid,
			    Float: x, Float: y, Float: z;

			targetid = strval (inputtext);
			GetPlayerPos (playerid, x, y, z);

			if (!IsPlayerInRangeOfPoint (targetid, 1.5, x, y, z)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The player is not near you. ");

			if (GetPlayerSpecialAction (targetid) == SPECIAL_ACTION_CARRY)
			{
				switch (PlayerInfo [targetid][carrying])
				{
				    case 1:
				    {
					    new created_item,
					       	items;

				        GetPlayerPos (targetid, x, y, z);

				        MapAndreas_FindZ_For2DCoord (x, y, z);

						for (new i = 0; i < MAX_OBJECTS; i++)
						{
						    if (ItemInfo [i][item_type] >= 1)
						    {
						        items++;
						    }
						}
						
					    created_item = CreateObject (BigItems [0][model_id_1], x, y, z, 0.0, 0.0, 0.0);
					    ItemInfo [created_item][item_model_id] = BigItems [0][model_id_1];

						RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]);

						ItemInfo [created_item][item_static_id] =  6;
						ItemInfo [created_item][item_ammo] 		=  -1;
						ItemInfo [created_item][item_type]		=  2;
						ItemInfo [created_item][item_id] 		=  items;
	                    ItemInfo [created_item][item_amount] 	=  1;
	                    
	                    PlayerInfo [targetid][carrying] = 0;
				    }
				}
			}

			SetPlayerSpecialAction (targetid, SPECIAL_ACTION_NONE);
			SetPlayerSpecialAction (targetid, SPECIAL_ACTION_CUFFED);
			
			new o_type, o_id, o_amount, o_ammo, o_state;
			
			if (!sscanf (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], "iiiii", o_type, o_id, o_amount, o_ammo, o_state))
			{
			    o_amount--;
			    
				if (o_amount >= 1) { format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "2 %d %d -1 -1", o_id, o_amount); }
				else if (o_amount == 0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }

			}

			new string [200];

			format (string, sizeof (string), "[INFO] {FFFFFF}You have been handcuffed by %s (%d). ", GetName (playerid), playerid);
			SendClientMessage (targetid, COLOR_MAIN, string);

			format (string, sizeof (string), "[INFO] {FFFFFF}You have cuffed %s (%d). ", GetName (targetid), targetid);
			SendClientMessage (playerid, COLOR_MAIN, string);
			
		}
		case UNCUFF_PLAYER_DIALOG_ID_1:
		{
		    if (listitem == 0)
		    {
		        if (GetPlayerSpecialAction (playerid) != SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not cuffed. ");

		        SetPlayerSpecialAction (playerid, SPECIAL_ACTION_NONE);
		        SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You used your handcuff key to uncuff yourself. ");

		    }
		    else if (listitem == 1)
		    {
		        ShowPlayerDialog (playerid, UNCUFF_PLAYER_DIALOG_ID_2, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Uncuff Player", "Enter the id of player you want to uncuff: ", "Ok", "Cancel");
		    }
		}
		case UNCUFF_PLAYER_DIALOG_ID_2:
		{
		    if (isnull (inputtext) || strval (inputtext) == INVALID_PLAYER_ID || !IsPlayerConnected (strval (inputtext))) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] The specified player is not connected. ");
		    if (GetPlayerSpecialAction (strval (inputtext)) != SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The specified player is not cuffed. ");
			if (strval (inputtext) == playerid) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot uncuff yourself. ");

		    new targetid,
		        Float: x, Float: y, Float: z;

			targetid = strval (inputtext);
			GetPlayerPos (playerid, x, y, z);

			if (!IsPlayerInRangeOfPoint (targetid, 1.5, x, y, z)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The specified player is not near you. ");

			SetPlayerSpecialAction (targetid, SPECIAL_ACTION_NONE);

			new string [200];

			format (string, sizeof (string), "[INFO] {FFFFFF}You have been uncuffed by %s (%d). ", GetName (playerid), playerid);
			SendClientMessage (targetid, COLOR_MAIN, string);

			format (string, sizeof (string), "[INFO] {FFFFFF}You have uncuffed %s (%d), ", GetName (targetid), targetid);
			SendClientMessage (playerid, COLOR_MAIN, string);

		}
		case LOOTING_ACTOR_DIALOG_ID_1:
		{
			if (response)
			{
			    if (PlayerInfo [playerid][slots_used] == PlayerInfo [playerid][inventory_virtual_slots]) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Your inventory is full. ");

				PlayerInfo [playerid][selected_inventory_slot] = listitem;
				ShowPlayerDialog (playerid, LOOTING_ACTOR_DIALOG_ID_2, DIALOG_STYLE_LIST, ""SERVER_TAG" - Loot", "1. Pickup all", "Select", "Cancel");
			}
		}
		case LOOTING_ACTOR_DIALOG_ID_2:
		{
		    if (response)
		    {
		        new s_type, s_id, s_amount, s_ammo, s_state,
		        
		            slot;
		    
		        switch (listitem)
		        {
		            case 0:
		            {
		                sscanf (ActorInventory [PlayerInfo [playerid][selected_actor]][PlayerInfo [playerid][selected_inventory_slot]][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_state);
		            
                        if (s_ammo == -1 && s_type != 8 && s_type != 9 && s_type != 11 && s_type != 12 && s_type != 13)
                        {
                            new a_type, a_id, a_amount, a_ammo, a_state;
                            
                            slot = -1;
                            
                            for (new i = 0; i < PlayerInfo [playerid][slots_used]; i++)
                            {
                                if (!sscanf (PlayerInventory [playerid][i][item], "%d %d %d %d %d", a_type, a_id, a_amount, a_ammo, a_state))
                                {
                                    if (a_type == s_type)
									{
									    if (a_id == s_id)
									    {
									        slot = i;
									    }
									}
                                    
                                }
                            }
                            
                            if (slot == -1) { slot = PlayerInfo [playerid][slots_used]; }
                            
                            format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d %d", s_type, s_id, (s_amount + a_amount), s_ammo, s_state);
                            PlayerInfo [playerid][slots_used]++;
                        }
						else
						{

						    slot = PlayerInfo [playerid][slots_used];

							for (new i = 0; i < s_amount; i++)
							{
							    switch (s_type)
							    {
						    		case 8, 9, 11, 12, 13, 14: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -2", s_type, s_id, s_amount, s_ammo);
									default: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -1", s_type, s_id, s_amount, s_ammo);
								}
								
								PlayerInfo [playerid][slots_used]++;
						    }
						}
						
		                SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Picked up item. ");
		                RearrangeActorInventorySlots (PlayerInfo [playerid][selected_actor], PlayerInfo [playerid][selected_inventory_slot]);
		            }
		            case 1:
		            {
		                sscanf (ActorInventory [PlayerInfo [playerid][selected_actor]][PlayerInfo [playerid][selected_inventory_slot]][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_state);
		            
		                ShowPlayerDialog (playerid, LOOTING_ACTOR_DIALOG_ID_3, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Loot", "Enter the amount you want to pickup: ", "Ok", "Cancel");
		                
		                PlayerInfo [playerid][selected_item_type] = s_type;
		                PlayerInfo [playerid][selected_item_static_id] = s_id;
		                PlayerInfo [playerid][selected_item_amount] = s_amount;
                        PlayerInfo [playerid][selected_item_ammo] = s_ammo;
                        PlayerInfo [playerid][selected_item_state] = s_state;
		            }
		        }
		    }
		}
		case LOOTING_ACTOR_DIALOG_ID_3:
		{
		    if (strval (inputtext) <= 0 || strval (inputtext) > PlayerInfo [playerid][selected_item_amount]) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Invalid amount. ");
		    
		    format (ActorInventory [PlayerInfo [playerid][selected_actor]][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "%d %d %d %d %d",
		    PlayerInfo [playerid][selected_item_type],
		    PlayerInfo [playerid][selected_item_static_id],
			PlayerInfo [playerid][selected_item_amount],
			PlayerInfo [playerid][selected_item_ammo],
			PlayerInfo [playerid][selected_item_state]);
			
			SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You picked up an item. ");
			
			PlayerInfo [playerid][selected_inventory_slot] = -1;
			PlayerInfo [playerid][selected_item_type] = 0;
			PlayerInfo [playerid][selected_item_static_id] = -1;
			PlayerInfo [playerid][selected_item_amount] = -1;
			PlayerInfo [playerid][selected_item_ammo] = -1;
			PlayerInfo [playerid][selected_item_state] = -1;
		}
		case CRAFTABLE_ITEMS_DIALOG_ID:
		{
		    if (response)
		    {
		        PlayerInfo [playerid][selected_item_static_id] = listitem;
				
				new string [250];
				
				for (new i = 0; i < CraftableItems [listitem][item_recipes]; i++)
				{
				    format (string, sizeof (string), "%s\nMethod %d", string, (i + 1));
				}
				
				ShowPlayerDialog (playerid, CRAFTING_RECIPE_DIALOG_ID, DIALOG_STYLE_LIST, ""SERVER_TAG" - Crafting Recipes", string, "Select", "Cancel");
		    }
		}
		case CRAFTING_RECIPE_DIALOG_ID:
		{
		    if (response)
		    {
                ShowSelectedRecipe (playerid, GetSpecificRecipe (GetRecipeString (PlayerInfo [playerid][selected_item_static_id]), listitem));
                format (PlayerInfo [playerid][crafting_method], 144, GetSpecificRecipe (GetRecipeString (PlayerInfo [playerid][selected_item_static_id]), listitem));
                PlayerInfo [playerid][selected_recipe_method] = listitem;
			}
			else 
			{
			    PlayerInfo [playerid][selected_item_static_id] = -1;
			    PlayerInfo [playerid][selected_item_type] = -1;
			}
		}
		case CRAFTING_RECIPE_DIALOG_ID_2:
		{
		    if (response)
		    {
		        new split_recipe [5][50],
		        
					s_type, s_id, s_amount, s_ammo, s_state,
					i_type, i_id, i_amount, i_ammo, i_state,
					
					can_craft;
		        
		        strexplode (split_recipe, GetSpecificRecipe (GetRecipeString (PlayerInfo [playerid][selected_item_static_id]), PlayerInfo [playerid][selected_recipe_method]), ",");
		        
		        for (new i = 0; i < 5; i++)
		        {
                	if (!sscanf (split_recipe [i], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
					{
					    for (new n = 0; n < PlayerInfo [playerid][slots_used]; n++)
					    {
							if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", i_type, i_id, i_amount, i_ammo, i_state))
							{
							    if (i_type == s_type && i_id == s_id && i_amount >= s_amount && i_ammo >= s_ammo)
							    {
							        can_craft = 1;
							    }
							}
					    }
					}
                }
                
                if (!can_craft) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You do not have the resources to craft the item. ");
                else 
				{
				    if (PlayerInfo [playerid][player_action] == 1)
					{
					 	SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot craft and cook at the same time. ");
					 	
					 	PlayerInfo [playerid][selected_item_type] = -1;
					 	PlayerInfo [playerid][selected_item_static_id] = -1;
			    		PlayerInfo [playerid][selected_recipe_method] = -1;
			    		return 0;
					}
					
					// Checkpoint
					if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot craft items while being cuffed. ");
					if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot craft items while carrying something. ");
					
					switch (PlayerInfo [playerid][crafting])
					{
					    case  1: PlayerInfo [playerid][crafting_time] = 56;
					    case  2: PlayerInfo [playerid][crafting_time] = 54;
					    case  3: PlayerInfo [playerid][crafting_time] = 52;
					    case  4: PlayerInfo [playerid][crafting_time] = 50;
					    case  5: PlayerInfo [playerid][crafting_time] = 48;
					    case  6: PlayerInfo [playerid][crafting_time] = 46;
					    case  7: PlayerInfo [playerid][crafting_time] = 44;
					    case  8: PlayerInfo [playerid][crafting_time] = 42;
					    case  9: PlayerInfo [playerid][crafting_time] = 40;
					    case 10: PlayerInfo [playerid][crafting_time] = 38;
					}
					
					PlayerInfo [playerid][crafted] = 0;
					
					ShowCraftingBar (playerid);
					PlayerInfo [playerid][crafting_timer] = SetTimerEx ("OnPlayerCraft", 1000, true, "i", playerid);

                }
		    }
		    else
		    {
		        PlayerInfo [playerid][selected_item_type] = -1;
		        PlayerInfo [playerid][selected_item_static_id] = -1;
			    PlayerInfo [playerid][selected_recipe_method] = -1;
		    }
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    SetPlayerVirtualWorld (playerid, 0);

	if (PlayerInfo [playerid][logged_in] == 0)
	{
	    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You need to login in in order to play on this server. ");
	    ShowLoginDialog (playerid);
	    return 0;
	}
	
	if (PlayerInfo [playerid][initiated] == 0)
	{
	    TogglePlayerControllable (playerid, false);
 		// ShowPlayerDialog (playerid, SETUP_DIALOG_ID_1, DIALOG_STYLE_MSGBOX, ""SERVER_TAG" - Intro", "Welcome to the "SERVER_NAME" server.\n\nThe main aim of this server is to survive. Find resources, craft items,\nbuild a shelter, make friends and enemies and explore the world together with endless possibilities.", "Next", "");
        ShowPlayerDialog (playerid, SETUP_DIALOG_ID_2, DIALOG_STYLE_INPUT, ""SERVER_TAG" - Age", "Enter your age:", "Next", "");
		return 0;
	}
	return 1;
}

public OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
{

	if (ItemInfo [objectid][item_type] == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This object cannot be picked up. ");
	if (PlayerInfo [playerid][slots_used] >= PlayerInfo [playerid][inventory_virtual_slots]) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You inventory is full. ");

    CancelEdit (playerid);
	
	new string [250];

    PlayerInfo [playerid][selected_nearby_item] = objectid;

    switch (ItemInfo [objectid][item_type])
    {
    	case  1: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, FoodItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  2: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MedicalItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  3: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, CookableItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  4: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ResourceItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  5: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ToolItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  6: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BigItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  7: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MiscItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  8: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, WeaponItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case  9: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, MeleeWeaponItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case 10: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, AmmoItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case 11: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, HeadWearableItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case 12: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BodyWearableItems [ItemInfo [objectid][item_static_id]][wearable_name], ItemInfo [objectid][item_amount]);
    	case 13: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, BackpackItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
    	case 14: format (string, sizeof (string), "%s %s>%s %s (%d)", SERVER_TAG, COLOR_MAIN_HEX, COLOR_WHITE, ArmourItems [ItemInfo [objectid][item_static_id]][name], ItemInfo [objectid][item_amount]);
	}

    ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_2_PART, DIALOG_STYLE_LIST, string, ""COLOR_MAIN_HEX"1. "COLOR_WHITE"Pickup All\n"COLOR_MAIN_HEX"2. "COLOR_WHITE"Enter an amount", "Pickup", "Cancel");
	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	SetObjectPos (objectid, fX, fY, fZ);
 	SetObjectRot (objectid, fRotX, fRotY, fRotZ);
	return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    if (response == EDIT_RESPONSE_FINAL || response == EDIT_RESPONSE_CANCEL)
	{

	    SetPlayerAttachedObject (playerid, 0, modelid, 6, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);
		printf ("OFFSET (%d) : %f, %f, %f, %f, %f, %f, %f, %f, %f", modelid, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ);

	}
	return 1;
}


////////////////////////////////////////////////////////////////////////////////
// COMMANDS ////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

stock SendMessageToNearbyPlayers (playerid, message [], Float: message_range)
{
	new Float: x, Float: y, Float: z;
	GetPlayerPos (playerid, x, y, z);
	
	foreach (new i : Player)
	{
	    if (IsPlayerInRangeOfPoint (i, message_range, x, y, z))
	    {
	        SendClientMessage (i, 0xC2A2DAAA, message);
	    }
	}
	return 1;
}

stock IsPlayerNearVehicleTrunk (playerid, vehicleid)
{
	new Float: x, Float: y, Float: z;
	
	GetPosBehindVehicle (vehicleid, x, y, z);
	
	if (IsPlayerInRangeOfPoint (playerid, 1.0, x, y, z))
	{
		return 1;
	}

	return 0;
}

stock GetPosBehindVehicle(vehicleid, &Float:x, &Float:y, &Float:z, Float:offset=0.5)
{
    new Float:vehicleSize[3], Float:vehiclePos[3];
    GetVehiclePos(vehicleid, vehiclePos[0], vehiclePos[1], vehiclePos[2]);
    GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, vehicleSize[0], vehicleSize[1], vehicleSize[2]);
    GetXYBehindVehicle(vehicleid, vehiclePos[0], vehiclePos[1], (vehicleSize[1]/2)+offset);
    x = vehiclePos[0];
    y = vehiclePos[1];
    z = vehiclePos[2];
    return 1;
}

GetXYBehindVehicle(vehicleid, &Float:q, &Float:w, Float:distance)
{
    new Float:a;
    GetVehiclePos(vehicleid, q, w, a);
    GetVehicleZAngle(vehicleid, a);
    q += (distance * -floatsin(-a, degrees));
    w += (distance * -floatcos(-a, degrees));
}

CMD:engine(playerid, params [])
{
	if (!IsPlayerInAnyVehicle (playerid)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not in any vehicle. ");
	if (GetPlayerState (playerid) != PLAYER_STATE_DRIVER) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not on the driver's seat. ");
	if (VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_fuel] <= 0.0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The vehicle's fuel tank is empty. ");
	if (VehicleInfo [GetPlayerVehicleID (playerid)][engine_usage] >= 300) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The vehicle engine failed to start. ");

	switch (VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_engine])
	{
	    case 0:
	    {
	        VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_engine] = 1;
	        SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Vehicle engine started. ");
	    }
	    case 1:
	    {
	        VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_engine] = 0;
	        SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Vehicle engine turned off. ");
	    }
	}
	
	UpdateVehicleParams (GetPlayerVehicleID (playerid));
	return 1;
}

CMD:addvehicle(playerid, params[])
{
	new add_vehicle_id;
	if (sscanf (params, "i", add_vehicle_id)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /addvehicle [vehicle id]");

	new Float: x, Float: y, Float: z, Float: a,
		created_vehicle,
		color_1, color_2;
		
	GetPlayerPos (playerid, x, y, z);
	GetPlayerFacingAngle (playerid, a);
		
	color_1 = random (256);
	color_2 = random (256);
		
	created_vehicle = CreateVehicle (add_vehicle_id, x, y, z, a, color_1, color_2, -1);
	SetVehicleVirtualWorld (created_vehicle, 1);

	PutPlayerInVehicle (playerid, created_vehicle, 0);
	
	VehicleInfo [created_vehicle][vehicle_color_1] = color_1;
	VehicleInfo [created_vehicle][vehicle_color_2] = color_2;
	
	new objective;
	
	GetVehicleParamsEx (created_vehicle,
	VehicleInfo [created_vehicle][vehicle_engine],
	VehicleInfo [created_vehicle][vehicle_lights],
	VehicleInfo [created_vehicle][vehicle_alarm],
	VehicleInfo [created_vehicle][vehicle_doors],
	VehicleInfo [created_vehicle][vehicle_bonnet],
	VehicleInfo [created_vehicle][vehicle_boot], objective);


	GetVehicleDamageStatus (created_vehicle,
	VehicleInfo [created_vehicle][vehicle_d_panels],
	VehicleInfo [created_vehicle][vehicle_d_doors],
	VehicleInfo [created_vehicle][vehicle_d_lights],
	VehicleInfo [created_vehicle][vehicle_d_tires]);
	
	VehicleInfo [created_vehicle][vehicle_fuel] = 100;
	
	new query [750];

	mysql_format (mysql, query, sizeof (query), "INSERT INTO `vehicles` (`model`, `color_1`, `color_2`, `engine`, `lights`, `alarms`, `doors`, `bonnet`, `boot`, `d_panels`, `d_doors`, `d_lights`, `d_tires`, `health`, `fuel`, `last_x`, `last_y`, `last_z`, `last_a`) VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %f, %f, %f, %f, %f, %f)",
	add_vehicle_id,
	VehicleInfo [created_vehicle][vehicle_color_1], VehicleInfo [created_vehicle][vehicle_color_2],
	
	VehicleInfo [created_vehicle][vehicle_engine],
	VehicleInfo [created_vehicle][vehicle_lights],
	VehicleInfo [created_vehicle][vehicle_alarm],
	VehicleInfo [created_vehicle][vehicle_doors],
	VehicleInfo [created_vehicle][vehicle_bonnet],
	VehicleInfo [created_vehicle][vehicle_boot],
	
	VehicleInfo [created_vehicle][vehicle_d_panels],
	VehicleInfo [created_vehicle][vehicle_d_doors],
	VehicleInfo [created_vehicle][vehicle_d_lights],
	VehicleInfo [created_vehicle][vehicle_d_tires],
	
	1000.0, 100.0, x, y, z, a);

	mysql_query (mysql, query);
	
	new string [250];
	format (string, sizeof (string), "[INFO] {FFFFFF}CREATED VEHICLE: (Vehicle ID: %d, Model ID: %d)", created_vehicle, add_vehicle_id);
	SendClientMessage (playerid, COLOR_MAIN, string);
	return 1;
}

stock LoadVehicles ()
{
	mysql_tquery (mysql, "SELECT * FROM `vehicles` WHERE 1", "OnVehiclesLoad");
	return 1;
}

stock GetVehicleDriver (vehicleid)
{
	new player;
	foreach (new playerid : Player)
	{
	    if (IsPlayerConnected (playerid))
	    {
	        if (IsPlayerInAnyVehicle (playerid))
	        {
	            if (GetPlayerState (playerid) == PLAYER_STATE_DRIVER)
	            {
	                if (GetPlayerVehicleID (playerid) == vehicleid)
	                {
	                    player = playerid;
						break;
	                }
	            }
	        }
	    }
	}
	return player;
}

stock UpdateVehicleParams (vehicleid)
{
    SetVehicleParamsEx (vehicleid,
	VehicleInfo [vehicleid][vehicle_engine],
	VehicleInfo [vehicleid][vehicle_lights],
	VehicleInfo [vehicleid][vehicle_alarm],
	VehicleInfo [vehicleid][vehicle_doors],
	VehicleInfo [vehicleid][vehicle_bonnet],
	VehicleInfo [vehicleid][vehicle_boot], 0);
	return 1;
}

stock UpdateVehicleDamageStatusEx (vehicleid)
{
    UpdateVehicleDamageStatus (vehicleid,
	VehicleInfo [vehicleid][vehicle_d_panels],
	VehicleInfo [vehicleid][vehicle_d_doors],
	VehicleInfo [vehicleid][vehicle_d_lights],
	VehicleInfo [vehicleid][vehicle_d_tires]);
	return 1;
}

forward UpdateVehiclesData ();
public UpdateVehiclesData ()
{
	for (new i = 0; i < MAX_VEHICLES; i++)
	{
	    if (GetVehicleModel (i) != 0)
	    {
	        
	        if (VehicleInfo [i][vehicle_driving] == 1)
	        {
				if (VehicleInfo [i][vehicle_fuel] > 0.0) { VehicleInfo [i][vehicle_fuel] -= 1.0; }
				if (VehicleInfo [i][engine_usage] < 301) { VehicleInfo [i][engine_usage] += 1; }
				if (VehicleInfo [i][wheel_usage]  < 201) { VehicleInfo [i][wheel_usage] += 1; }
				
				if (VehicleInfo [i][vehicle_fuel] == 0.0)
		        {
		            VehicleInfo [i][vehicle_engine] = 0;
		            
		            UpdateVehicleParams (i);

					SendClientMessage (GetVehicleDriver (i), COLOR_MAIN, "[INFO] "COLOR_WHITE"There is no more fuel in the vehicle. ");
		        }
		        
		        if (VehicleInfo [i][engine_usage] == 300)
		        {
		            VehicleInfo [i][vehicle_engine] = 0;

		            UpdateVehicleParams (i);

					SendClientMessage (GetVehicleDriver (i), COLOR_MAIN, "[INFO] "COLOR_WHITE"The vehicle engine is jammed. ");
		        }
		        
		        if (VehicleInfo [i][wheel_usage] == 200)
		        {
					VehicleInfo [i][vehicle_d_tires] = random (16);

	    			UpdateVehicleDamageStatusEx (i);

					SendClientMessage (GetVehicleDriver (i), COLOR_MAIN, "[INFO] "COLOR_WHITE"The tires of the vehicles have been over used. ");
		        }
	        }
	    }
	}
	
	foreach (new playerid : Player)
	{
		if (IsPlayerConnected (playerid))
		{
		    if (IsPlayerInAnyVehicle (playerid) && GetPlayerState (playerid) == PLAYER_STATE_DRIVER)
		    {
		        UpdateFuelBar (playerid);
				ShowFuelBar (playerid);
			}
		}
	}
	
	return 1;
}

forward OnVehiclesLoad ();
public OnVehiclesLoad ()
{
	for (new i = 0; i < cache_num_rows (); i++)
	{
	    new created_vehicle,

			model,

	        color_1, color_2,

			Float: vlast_x, Float: vlast_y, Float: vlast_z,
			Float: vlast_a;
	        
		cache_get_value_name_int (i, "model", model);
		
		cache_get_value_name_int (i, "color_1", color_1);
		cache_get_value_name_int (i, "color_2", color_2);
		
		cache_get_value_name_float (i, "last_x", vlast_x);
		cache_get_value_name_float (i, "last_y", vlast_y);
		cache_get_value_name_float (i, "last_z", vlast_z);
		cache_get_value_name_float (i, "last_a", vlast_a);
		
		created_vehicle = CreateVehicle (model,
		
										 vlast_x,
										 vlast_y,
										 vlast_z,
										 vlast_a,
										 
										 color_1,
										 color_2,
										 
										 -1);


        VehicleInfo [created_vehicle][vehicle_model] = model;

		VehicleInfo [created_vehicle][vehicle_x] = vlast_x;
		VehicleInfo [created_vehicle][vehicle_y] = vlast_y;
		VehicleInfo [created_vehicle][vehicle_z] = vlast_z;
		VehicleInfo [created_vehicle][vehicle_a] = vlast_a;

		VehicleInfo [created_vehicle][vehicle_color_1] = color_1;
		VehicleInfo [created_vehicle][vehicle_color_2] = color_2;

        cache_get_value_name_float (i, "health", VehicleInfo [created_vehicle][vehicle_health]);
		cache_get_value_name_float (i, "fuel", VehicleInfo [created_vehicle][vehicle_fuel]);
		
		SetVehicleHealth (created_vehicle, VehicleInfo [created_vehicle][vehicle_health]);

        cache_get_value_name_int (i, "engine", VehicleInfo [created_vehicle][vehicle_engine]);
		cache_get_value_name_int (i, "lights", VehicleInfo [created_vehicle][vehicle_lights]);
		cache_get_value_name_int (i, "alarms", VehicleInfo [created_vehicle][vehicle_alarm]);
		cache_get_value_name_int (i, "doors", VehicleInfo [created_vehicle][vehicle_doors]);
		cache_get_value_name_int (i, "bonnet", VehicleInfo [created_vehicle][vehicle_bonnet]);
		cache_get_value_name_int (i, "boot", VehicleInfo [created_vehicle][vehicle_boot]);

		UpdateVehicleParams (created_vehicle);

        cache_get_value_name_int (i, "d_panels", VehicleInfo [created_vehicle][vehicle_d_panels]);
		cache_get_value_name_int (i, "d_doors", VehicleInfo [created_vehicle][vehicle_d_doors]);
		cache_get_value_name_int (i, "d_lights", VehicleInfo [created_vehicle][vehicle_d_lights]);
		cache_get_value_name_int (i, "d_tires", VehicleInfo [created_vehicle][vehicle_d_tires]);

        UpdateVehicleDamageStatus (created_vehicle,
		VehicleInfo [created_vehicle][vehicle_d_panels],
		VehicleInfo [created_vehicle][vehicle_d_doors],
		VehicleInfo [created_vehicle][vehicle_d_lights],
		VehicleInfo [created_vehicle][vehicle_d_tires]);
		
	}
	return 1;
}

stock SaveItems ()
{
	new	Float: px, Float: py, Float: pz,
     	Float: rx, Float: ry, Float: rz,

 		string [450],

     	File: file;

	file = fopen (CREATED_ITEMS_FILE, io_write);

	for (new i = 0; i < MAX_OBJECTS; i++)
	{
	    if (ItemInfo [i][item_type] > 0)
	    {
			GetObjectPos (i, px, py, pz);
			GetObjectRot (i, rx, ry, rz);

			format (string, sizeof (string), "%d %d %d %d %d %d %f %f %f %f %f %f\r\n",
			i,
			ItemInfo [i][item_static_id],
			ItemInfo [i][item_type],
			ItemInfo [i][item_amount],
			ItemInfo [i][item_ammo],
			ItemInfo [i][item_model_id],
			px, py, pz,
			rx, ry, rz );

			fwrite (file, string);
	    }
	}

	fclose (file);
	return 1;
}

stock SaveVehicles ()
{
	new query [1024], extra;
	
	mysql_format (mysql, query, sizeof (query), "DELETE FROM `vehicles` WHERE 1");
	mysql_query (mysql, query);
	
	for (new vehicleid = 0; vehicleid < MAX_VEHICLES; vehicleid++)
	{
		if (GetVehicleModel (vehicleid) != 0)
		{
			query [0] = '\0';

			GetVehicleHealth (vehicleid, VehicleInfo [vehicleid][vehicle_health]);

			GetVehiclePos (vehicleid, VehicleInfo [vehicleid][vehicle_x], VehicleInfo [vehicleid][vehicle_y], VehicleInfo [vehicleid][vehicle_z]);
			GetVehicleZAngle (vehicleid, VehicleInfo [vehicleid][vehicle_a]);

			GetVehicleParamsEx (vehicleid,
			VehicleInfo [vehicleid][vehicle_engine],
			VehicleInfo [vehicleid][vehicle_lights],
			VehicleInfo [vehicleid][vehicle_alarm],
			VehicleInfo [vehicleid][vehicle_doors],
			VehicleInfo [vehicleid][vehicle_bonnet],
			VehicleInfo [vehicleid][vehicle_boot], extra);

			GetVehicleDamageStatus (vehicleid,
			VehicleInfo [vehicleid][vehicle_d_panels],
			VehicleInfo [vehicleid][vehicle_d_doors],
			VehicleInfo [vehicleid][vehicle_d_lights],
			VehicleInfo [vehicleid][vehicle_d_tires]);

			mysql_format (mysql, query, sizeof (query), "INSERT INTO `vehicles` (`model`, `color_1`, `color_2`, `engine`, `lights`, `alarms`, `doors`, `bonnet`, `boot`, `d_panels`, `d_doors`, `d_lights`, `d_tires`, `health`, `fuel`, `last_x`, `last_y`, `last_z`, `last_a`) VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %f, %f, %f, %f, %f, %f)",

			VehicleInfo [vehicleid][vehicle_model],

			VehicleInfo [vehicleid][vehicle_color_1],
			VehicleInfo [vehicleid][vehicle_color_2],

			VehicleInfo [vehicleid][vehicle_engine],
			VehicleInfo [vehicleid][vehicle_lights],
			VehicleInfo [vehicleid][vehicle_alarm],
			VehicleInfo [vehicleid][vehicle_doors],
			VehicleInfo [vehicleid][vehicle_bonnet],
			VehicleInfo [vehicleid][vehicle_boot],
			
			VehicleInfo [vehicleid][vehicle_d_panels],
			VehicleInfo [vehicleid][vehicle_d_doors],
			VehicleInfo [vehicleid][vehicle_d_lights],
			VehicleInfo [vehicleid][vehicle_d_tires],

			VehicleInfo [vehicleid][vehicle_health],
			VehicleInfo [vehicleid][vehicle_fuel],

			VehicleInfo [vehicleid][vehicle_x],
			VehicleInfo [vehicleid][vehicle_y],
			VehicleInfo [vehicleid][vehicle_z],
			VehicleInfo [vehicleid][vehicle_a]);

			mysql_pquery (mysql, query);
			
			print (query);
		}
	}
	
	
	return 1;
}

CMD:weapon(playerid, params [])
{
	new weaponid;
	if (!sscanf (params, "i", weaponid))
	{
	    ResetPlayerWeapons (playerid);
	    GivePlayerWeapon (playerid, weaponid, 999999);
	}
	return 1;
}

CMD:spineobject(playerid, params [])
{
	new object_id;
	if (!sscanf (params, "i", object_id))
	{
		SetPlayerAttachedObject (playerid, 1, object_id, 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		EditAttachedObject (playerid, 0);
	}
	return 1;
}

CMD:editspine(playerid, params [])
{
	EditAttachedObject (playerid, 1);
	return 1;
}

CMD:handobject(playerid, params [])
{
	new object_id;
	if (!sscanf (params, "i", object_id))
	{
		SetPlayerAttachedObject (playerid, 0, object_id, 6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		EditAttachedObject (playerid, 0);
	}
	return 1;
}

CMD:edithand(playerid, params [])
{
	EditAttachedObject (playerid, 0);
	return 1;
}

CMD:craft(playerid, params [])
{
	if (PlayerInfo [playerid][player_action] == 2) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are already crafting an item. ");

	new string [1024];

	for (new i = 0; i < MAX_CRAFTABLE_ITEMS; i++)
	{
	    format (string, sizeof (string), "%s\%s", string, CraftableItems [i][name]);
	}
	
	ShowPlayerDialog (playerid, CRAFTABLE_ITEMS_DIALOG_ID, DIALOG_STYLE_LIST, ""SERVER_TAG" - Craft", string, "Select", "Cancel");
	return 1;
}

CMD:worldtime(playerid, params [])
{
	new world_time;
	if (sscanf (params, "i", world_time)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] SYNTAX: /worldtime [0 - 23] (0 = 12:00 AM || 12 = 12:00 PM)");
	if (world_time < 0 || world_time > 23) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] Wrong time. ");
	
	SetWorldTime (world_time);
	return 1;
}

CMD:ooc(playerid, params [])
{
	new message [250];
    if (sscanf (params, "s[250]", message)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /ooc [text]");

	new string [275];
	format (string, sizeof (string), "%s : %s", GetName (playerid), playerid);
	
	SendMessageToNearbyPlayers (playerid, string, 30.0);
	return 1;
}

CMD:ame(playerid, params [])
{
	new action [250];
	if (sscanf (params, "s[250]", action)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /ame [text]");

	new string [275];
	format (string, sizeof (string), "* %s[AME]%s %s %s", COLOR_MAIN_HEX, COLOR_WHITE, GetName (playerid), action);

	SendMessageToNearbyPlayers (playerid, string, 15.0);

	SetPlayerChatBubble (playerid, string, 0xFFFFFFFF, 100.0, 10 * 1000);
	return 1;
}

CMD:ado(playerid, params [])
{
	new action [250];
	if (sscanf (params, "s[250]", action)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /ame [text]");

	new string [275];
	format (string, sizeof (string), "* %s[ADO]%s %s %s", COLOR_MAIN_HEX, COLOR_WHITE, GetName (playerid), action);

	SendMessageToNearbyPlayers (playerid, string, 15.0);

	SetPlayerChatBubble (playerid, string, 0xFFFFFFFF, 100.0, 10 * 1000);
	return 1;
}

CMD:me(playerid, params [])
{
	new action [250];
	if (sscanf (params, "s[250]", action)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /me [action]");
	
	new string [275];
	format (string, sizeof (string), "* %s %s", GetName (playerid), action);
	
	SendMessageToNearbyPlayers (playerid, string, 30.0);
	return 1;
}

CMD:do(playerid, params [])
{
	new action [250];
	if (sscanf (params, "s[250]", action)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /do [action]");
	
	new string [175];
	
	format (string, sizeof (string), "* %s (( %s ))", action, GetName (playerid));
	
	SendMessageToNearbyPlayers (playerid, string, 30.0);
	return 1;
}

CMD:melow(playerid, params [])
{
	new action [250];
	if (sscanf (params, "s[250]", action)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /melow [action]");

	new string [275];
	format (string, sizeof (string), "* %s %s", GetName (playerid), action);

	SendMessageToNearbyPlayers (playerid, string, 15.0);
	return 1;
}

CMD:dolow(playerid, params [])
{
	new action [250];
	if (sscanf (params, "s[250]", action)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /dolow [action]");

	new string [175];

	format (string, sizeof (string), "* %s (( %s ))", action, GetName (playerid));

	SendMessageToNearbyPlayers (playerid, string, 15.0);
	return 1;
}

CMD:cw(playerid, params [])
{
	new message [250];
	if (sscanf (params, "s[250]", message)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /cw [message]");
	
	new string [275];
	format (string, sizeof (string), "* %s[IN-CAR]%s %s : %s", COLOR_MAIN_HEX, COLOR_WHITE, GetName (playerid), message);
	
	foreach (new i : Player)
	{
	    if (IsPlayerInVehicle (i, GetPlayerVehicleID (playerid)))
	    {
	        SendClientMessage (i, 0xFFFFFFFF, string);
	    }
	}
	return 1;
}

CMD:shout(playerid, params [])
{
	new message [250];
	if (sscanf (params, "s[250]", message)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /s(cream) [message]");

	new string [275];
	format (string, sizeof (string), "* %s shouts %s", GetName (playerid), message);
	
	SendMessageToNearbyPlayers (playerid, string, 50.0);
	return 1;
}

CMD:s(playerid, params [])
{
	cmd_shout (playerid, params);
	return 1;
}

CMD:character(playerid, params [])
{
	new player_name [2][16];
	
	strexplode (player_name, GetName (playerid), " ");

	new string [1024];
	format (string, sizeof (string), "- First Name: %s\n\n- Last Name: %s\n\nAge: %d\n\nFaction: N/A\n\nJob: %s",
	player_name [0], player_name [1],
	PlayerInfo [playerid][age],
	Jobs [PlayerInfo [playerid][job]][name]);
	
	ShowPlayerDialog (playerid, CHARACTER_INFO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""SERVER_TAG" - Character", string, "Ok", "");
	return 1;
}

CMD:kill(playerid, params[])
{
	SetPlayerHealth (playerid, 0.0);
	return 1;
}

CMD:stopsmoking(playerid, params[])
{
	if (GetPlayerSpecialAction (playerid) != SPECIAL_ACTION_SMOKE_CIGGY) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not smoking any cigarette. ");
	
	SetPlayerSpecialAction (playerid, SPECIAL_ACTION_NONE);
	SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You disposed your cigarette. ");
	return 1;
}

CMD:additem(playerid, params[])
{
	if (PlayerInfo [playerid][item_added] == 1) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] Wait before adding another item. ");
	if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot pickup items while handcuffed. ");

	new string [2450];
	
	strcat (string, ""COLOR_MAIN_HEX"1.  "COLOR_WHITE"Food Items\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"2.  "COLOR_WHITE"Medical Items\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"3.  "COLOR_WHITE"Cookable Items\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"4.  "COLOR_WHITE"Resource Items\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"5.  "COLOR_WHITE"Tool Items\n", sizeof (string));
    strcat (string, ""COLOR_MAIN_HEX"6.  "COLOR_WHITE"Big Items\n", sizeof (string));
    strcat (string, ""COLOR_MAIN_HEX"7.  "COLOR_WHITE"Misc Items\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"8.  "COLOR_WHITE"Ranged Weapons\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"9.  "COLOR_WHITE"Melee Weapons\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"10. "COLOR_WHITE"Ammo\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"11. "COLOR_WHITE"Head Wearable Items\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"12. "COLOR_WHITE"Body Wearable Items\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"13. "COLOR_WHITE"Backpacks\n", sizeof (string));
	strcat (string, ""COLOR_MAIN_HEX"13. "COLOR_WHITE"Armours", sizeof (string));

	ShowPlayerDialog (playerid, ADD_ITEM_DIALOG_ID_1, DIALOG_STYLE_LIST, ""SERVER_TAG" - Add Item", string, "Select", "Cancel");
	return 1;
}

CMD:pickup(playerid, params[])
{
    if (PlayerInfo [playerid][inventory_virtual_slots] == PlayerInfo [playerid][slots_used]) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"There is no inventory space. ");
	if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CUFFED) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot pickup items while handcuffed. ");

	for (new i = 0; i < 64; i++) { PlayerInfo [playerid][nearby_items][i] = -1; }
    
    new Float: x, Float: y, Float: z;
    new total_items;
    
    for (new i = 0; i < MAX_OBJECTS; i++)
    {
        if (ItemInfo [i][item_type] > 0)
        {
            GetObjectPos (i, x, y, z);
            
            if (IsPlayerInRangeOfPoint (playerid, 2.5, x, y, z))
            {
                PlayerInfo [playerid][nearby_items][total_items] = i;
                total_items++;
            }
        }
    }
    
    if (total_items == 0) return SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"There is no pickable item near you. ");
    
    new string [500];
    
    for (new i = 0; i < total_items; i++)
    {
		if (PlayerInfo [playerid][nearby_items][i] != -1)
		{
	        switch(ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_type])
	        {
	            case  1: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, FoodItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  2: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, MedicalItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  3: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, CookableItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  4: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, ResourceItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  5: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, ToolItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  6: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, BigItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  7: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, MiscItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  8: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, WeaponItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case  9: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, MeleeWeaponItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case 10: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, AmmoItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case 11: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, HeadWearableItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case 12: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, BodyWearableItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][wearable_name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
	            case 13: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, BackpackItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
                case 14: format (string, sizeof (string), "%s\n%s%d. %s%s (%d)\n", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, ArmourItems [ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_static_id]][name], ItemInfo [PlayerInfo [playerid][nearby_items][i]][item_amount]);
			}
		}
    }
    
    ShowPlayerDialog (playerid, NEARBY_ITEMS_DIALOG_ID_1, DIALOG_STYLE_LIST, ""SERVER_TAG" - Nearby Items", string, "Select", "Cancel");
	return 1;
}

CMD:pup(playerid, params[])
{
	if (PlayerInfo [playerid][inventory_virtual_slots] == PlayerInfo [playerid][slots_used]) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"There is no inventory space. ");

	SelectObject (playerid);
	return 1;
}

CMD:loot(playerid, params [])
{
    new s_state,
	
		loot_found,
		
		Float: x, Float: y, Float: z,
		
		type, id, amount, ammo,

		string [1024];

	#pragma unused s_state

	strcat (string, "Item\tValue", sizeof (string));

	for (new i = 0; i < MAX_ACTORS; i++)
	{
		GetActorPos (i, x, y, z);
		
		if (IsPlayerInRangeOfPoint (playerid, 5.0, x, y, z))
		{
			for (new n = 0; n < ActorSlotsUsed [i]; n++)
			{
				if(!sscanf (ActorInventory [i][n][item], "iiiii", type, id, amount, ammo, s_state))
				{
				    loot_found = 1;

				    switch (type)
					{
					    case 1:
					    {
					        if (ammo == -1)
					        {
					            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, FoodItems [id][name], amount);
					        }
					        else
					        {
					            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, FoodItems [id][name], ammo);
					        }
					    }
					    case 2:
					    {
					        if (ammo == -1)
					        {
					            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, MedicalItems [id][name], amount);
					        }
					        else
					        {
					            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, MedicalItems [id][name], ammo);
					        }
					    }
					    case 3: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, CookableItems [id][name], amount);
		                case 4: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, ResourceItems [id][name], amount);
		                case 5: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, ToolItems [id][name], amount);
		                case 6: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, BigItems [id][name], amount);
		                case 7: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, MiscItems [id][name], amount);
					    case 8: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, WeaponItems [id][name], amount);
					    case 9: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, MeleeWeaponItems [id][name], amount);
					    case 10:
					    {
					        new amount_string [12];

							if (amount == -1) { amount_string = "-"; }
							else { valstr (amount_string, amount); }

							format (string, sizeof (string), "%s\n%s%d. %s%s\t%s", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, AmmoItems [id][name], amount_string);
						}
						case 11: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, HeadWearableItems [id][name], amount);
						case 12: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, BodyWearableItems [id][wearable_name], amount);
						case 13: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, BackpackItems [id][name], amount);
						case 14:
						{
						    new ammo_string [12];

						    if (ammo == -1) { ammo_string = "-"; }
						    else { valstr (ammo_string, ammo); }

							format (string, sizeof (string), "%s\n%s%d. %s%s\t%s", string, COLOR_MAIN_HEX, (n + 1), COLOR_WHITE, ArmourItems [id][name], ammo_string);
						}
						default: continue;
					}
					
					PlayerInfo [playerid][selected_actor] = i;
				}
			}
			
			break;
		}
	}
	
	if (loot_found == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not near any dead bodies. ");
	ShowPlayerDialog (playerid, LOOTING_ACTOR_DIALOG_ID_1, DIALOG_STYLE_TABLIST_HEADERS, ""SERVER_TAG" - Loot", string, "Select", "Cancel");
	return 1;
}

CMD:opentrunk(playerid, params [])
{
	if (IsPlayerNearAnyVehicle (playerid) == -1) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not near any vehicle. ");
	if (!IsPlayerNearVehicleTrunk (playerid, IsPlayerNearAnyVehicle (playerid))) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You are not near the vehicle's trunk. ");

	new s_type, s_id, s_amount, s_ammo, s_state,

		vehicleid,

	    string [1024];

	vehicleid = IsPlayerNearAnyVehicle (playerid);

	for (new i = 0; i < MAX_VEHICLE_SLOTS; i++)
	{
	    if (!sscanf (VehicleInventory [vehicleid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
	    {

	        switch (s_type)
	        {
				case  1:
				{
					switch (s_ammo)
					{
			 			case -1: format (string, sizeof (string), "%d. %s\t%d", (i + 1), FoodItems [i][name], s_amount);
						default: format (string, sizeof (string), "%d. %s\t%d", (i + 1), FoodItems [i][name], s_ammo);
			 		}
				}
				case  2:
				{
					switch (s_ammo)
					{
			 			case -1: format (string, sizeof (string), "%d. %s\t%d", (i + 1), MedicalItems [i][name], s_amount);
						default: format (string, sizeof (string), "%d. %s\t%d", (i + 1), MedicalItems [i][name], s_ammo);
			 		}
				}
				case  3: format (string, sizeof (string), "%d. %s\t%d", (i + 1), CookableItems [i][name], s_amount);
				case  4: format (string, sizeof (string), "%d. %s\t%d", (i + 1), ResourceItems [i][name], s_amount);
				case  5: format (string, sizeof (string), "%d. %s\t%d", (i + 1), ToolItems [i][name], s_amount);
				case  6: format (string, sizeof (string), "%d. %s\t%d", (i + 1), BigItems [i][name], s_amount);
				case  7: format (string, sizeof (string), "%d. %s\t%d", (i + 1), MiscItems [i][name], s_amount);
				case  8: format (string, sizeof (string), "%d. %s\t%d", (i + 1), WeaponItems [i][name], s_amount);
				case  9: format (string, sizeof (string), "%d. %s\t%d", (i + 1), MeleeWeaponItems [i][name], s_amount);
				case 10: format (string, sizeof (string), "%d. %s\t%d", (i + 1), HeadWearableItems [i][name], s_amount);
				case 11: format (string, sizeof (string), "%d. %s\t%d", (i + 1), BodyWearableItems [i][wearable_name], s_amount);
				case 12: format (string, sizeof (string), "%d. %s\t%d", (i + 1), BackpackItems [i][name], s_amount);
				case 13: format (string, sizeof (string), "%d. %s\t%d", (i + 1), ArmourItems [i][name], s_amount);
			}

	    }
	}
	
	ShowPlayerDialog (playerid, VEHICLE_INVENTORY_DIALOG_ID, DIALOG_STYLE_TABLIST, ""COLOR_WHITE"Vehicle Trunk", string, "Select", "Cancel");
	return 1;
}

CMD:inv(playerid, params[])
{
	if (PlayerInventory [playerid][0][item][0] == EOS) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Your inventory is empty. ");
	
	new type, id, amount, ammo, status, status_string [44],
	    string [2500];
	    
	strcat (string, "Item\tValue\tStatus\n", sizeof (string));
	
	for (new i = 0; i < (PlayerInfo [playerid][inventory_virtual_slots] + 1); i++)
	{
	
		if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", type, id, amount, ammo, status))
		{
			switch (status)
			{
			    case -1: status_string = "{FFFFFF}N/A";
			    case -2: status_string = "{FFFFFF}Not Equipped";
			    case -3: status_string = "{00FF00}Equipped";
			    
				case 0, 1, 2, 3, 4:
				{
				    switch (PlayerWeaponInfo [playerid][status][weapon_type])
				    {
				    	case 0: format (status_string, sizeof (status_string), "{00FF00}Loaded {FFFFFF}(%s)", MeleeWeaponItems [PlayerWeaponInfo [playerid][status][weapon_static_id]][name]);
				    	default: format (status_string, sizeof (status_string), "{00FF00}Loaded {FFFFFF}(%s)", WeaponItems [PlayerWeaponInfo [playerid][status][weapon_static_id]][name]);
					}
				}
			}

			switch (type)
			{
			    case 1:
			    {
			        if (ammo == -1)
			        {
			            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, FoodItems [id][name], amount, status_string);
			        }
			        else
			        {
			            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, FoodItems [id][name], ammo, status_string);
			        }
			    }
			    case 2:
			    {
			        if (ammo == -1)
			        {
			            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, MedicalItems [id][name], amount, status_string);
			        }
			        else
			        {
			            format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, MedicalItems [id][name], ammo, status_string);
			        }
			    }
			    case 3: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, CookableItems [id][name], amount, status_string);
                case 4: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, ResourceItems [id][name], amount, status_string);
                case 5: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, ToolItems [id][name], amount, status_string);
                case 6: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, BigItems [id][name], amount, status_string);
                case 7: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, MiscItems [id][name], amount, status_string);
			    case 8: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, WeaponItems [id][name], amount, status_string);
			    case 9: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, MeleeWeaponItems [id][name], amount, status_string);
			    case 10:
			    {
			        new amount_string [12];

					if (amount == -1) { amount_string = "-"; }
					else { valstr (amount_string, amount); }

					format (string, sizeof (string), "%s\n%s%d. %s%s\t%s\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, AmmoItems [id][name], amount_string, status_string);
				}
				case 11: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, HeadWearableItems [id][name], amount, status_string);
				case 12: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, BodyWearableItems [id][wearable_name], amount, status_string);
				case 13: format (string, sizeof (string), "%s\n%s%d. %s%s\t%d\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, BackpackItems [id][name], amount, status_string);
				case 14:
				{
				    new ammo_string [12];
				    
				    if (ammo == -1) { ammo_string = "-"; }
				    else { valstr (ammo_string, ammo); }
				    
					format (string, sizeof (string), "%s\n%s%d. %s%s\t%s\t%s", string, COLOR_MAIN_HEX, (i + 1), COLOR_WHITE, ArmourItems [id][name], ammo_string, status_string);
				}
				default: continue;
			}
		}
	}
	
	new title [124];
	format (title, sizeof (title), "{FFFFFF}Inventory %s(%d/%d)", COLOR_MAIN_HEX, PlayerInfo [playerid][slots_used], PlayerInfo [playerid][inventory_virtual_slots]);
	ShowPlayerDialog (playerid, PLAYER_INVENTORY_DIALOG_ID_1, DIALOG_STYLE_TABLIST_HEADERS, title, string, "Select", "Close");
	return 1;
}

CMD:inventory(playerid, params[])
{
	cmd_inv(playerid, params);
	return 1;
}

CMD:pm(playerid, params[])
{
	new id, message;
	if (sscanf (params, "is[125]", id, message)) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"SYNTAX: /pm [player id] [message]");
	else
	{
	    if (!IsPlayerConnected (playerid) || id == INVALID_PLAYER_ID) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The specified player is offline.");
	    if (PlayerInfo [id][private_messages] == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Player has their private messages turned off. ");
	    if (id == playerid) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You cannot send private messages to yourself. ");
	    
	    for (new i = 0; i < MAX_PM_OFF; i++)
	    {
	        if (PlayerPMOFFList [playerid][i] == playerid) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The player has blocked your PMs. ");
	    }
	
	    new string [125];
	    format (string, sizeof (string), "[PM] %s (%d): %s", GetName (playerid), playerid, message);
	    SendClientMessage (id, COLOR_PM, string);
	}
	return 1;
}

CMD:pmoff(playerid, params[])
{
	new id;
	if (sscanf (params, "i", id))
	{
	    if (PlayerInfo [playerid][private_messages] == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Private messages are already off. ");
		
		PlayerInfo [playerid][private_messages] = 0;
		SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Private messages turned off. ");
		
	}
	else
	{
	    if (!IsPlayerConnected (playerid) || id == INVALID_PLAYER_ID) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The specified player is offline.");
	    
		for (new i = 0; i < MAX_PM_OFF; i++)
		{
		    if (PlayerPMOFFList [playerid][i] == id)
		    {
		        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Private Messages are already blocked from that player. ");
		    }
		    
		    if (PlayerPMOFFList [playerid][i] == -1)
      		{
      		    new string [125];
      		    format (string, sizeof (string), "[INFO] {FFFFFF}Private messages blocked from %s (%d). ", GetName (playerid), playerid);
      		    PlayerPMOFFList [playerid][i] = id;
				break;
      		}
		}
	    
	}
	return 1;
}

CMD:pmofflist(playerid, params[])
{
	new string [450];
	
	for (new i = 0; i < MAX_PM_OFF; i++)
	{
	    if (i != -1)
	    {
	        format (string, sizeof (string), "%s\n%s (%d)", string, GetName (i), i);
	    }
	}
	
	ShowPlayerDialog (playerid, PM_OFF_LIST_DIALOG_ID, DIALOG_STYLE_LIST, ""SERVER_TAG" - Private Messages Block List", string, "Close", "");
	return 1;
}

CMD:pmon(playerid, params[])
{
	new id;
	if (sscanf (params, "i", id))
	{
	    if (PlayerInfo [playerid][private_messages] == 1) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Private messages are already on. ");
		
		PlayerInfo [playerid][private_messages] = 1;
		SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Private messages turned on. ");

	}
	else
	{
	    if (!IsPlayerConnected (playerid) || id == INVALID_PLAYER_ID) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"The specified player is offline.");

		for (new i = 0; i < MAX_PM_OFF; i++)
		{
		    if (PlayerPMOFFList [playerid][i] == id)
		    {
		        new string [125];
      		    format (string, sizeof (string), "[INFO] {FFFFFF}Private messages enabled from %s (%d). ", GetName (playerid), playerid);
      		    PlayerPMOFFList [playerid][i] = -1;
				break;
		    }
		}

        SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Private Messages are already enabled from that player. ");

	}
	return 1;
}


////////////////////////////////////////////////////////////////////////////////
// CUSTOM CALLBACKS ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

forward UpdateWorldTime ();
public UpdateWorldTime ()
{
	if (WORLD_TIME == 23) { WORLD_TIME = 0; }
	else { WORLD_TIME++; }
	
	SetWorldTime (WORLD_TIME);
	return 1;
}

forward OnZombieCheckSurroundings ();
public OnZombieCheckSurroundings ()
{

	new Float: x, Float: y, Float: z,
	
	    Float: p_x, Float: p_y, Float: p_z,
	    
	    Float: out_x, Float: out_y, Float: out_z,
	    
	    Float: range, zombie_animation,

		Float: ray_x, Float: ray_y, Float: ray_z,

		Float: a;

	#pragma unused ray_x, ray_y, ray_z, out_x, out_y, out_z, a

	for (new i = (SERVER_SLOTS - Zombies); i < MAX_ZOMBIES; i++)
	{
	    if (ZombieInfo [i][spawned] == 1)
	    {
	        // a = FCNPC_GetAngle (i);
	        
	        FCNPC_GetPosition (i, x, y, z);
	        FCNPC_GetAnimation (i, zombie_animation);
	        
            // ray_x = (x + (2.5 * floatsin(-a, degrees)));
    		// ray_y = (y + (2.5 * floatcos(-a, degrees)));
    		
	        /*
	        if (CA_RayCastLine (x, y, z, ray_x, ray_y, z, out_x, out_y, out_z))
	        {
	            FindGoToPoint (i);
	            continue;
	        }
	        */
	        
	        ray_x = ray_y = ray_z = 0.0;
	    
	        if (zombie_animation == 1132)
	        {
				MapAndreas_FindZ_For2DCoord (x, y, z);
				FCNPC_GoTo (i, x, y, (z + 1.25), 2, 3.0);
				
				continue;
	        }
	    
	        if (ZombieInfo [i][chasing] == -1)
	        {

                if (range == 0.0) { range = 25.0; }
	        
				foreach (new playerid : Player)
				{
				    if (!IsPlayerConnected (playerid)) { continue; }

					if (PlayerInfo [playerid][zombies_chasing] >= 2) { continue; }
					if (IsPlayerInDynamicArea (playerid, SafeZone_1)) { continue; }

                    if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_DUCK)
					{
					    range = 7.5;
					}

					if (PlayerInfo [playerid][walking] == 1)
					{
					    range = 13.5;
					}
					
					GetPlayerPos (playerid, ray_x, ray_y, ray_z);

					/*

					CA_RayCastLine (x, y, z, ray_x, ray_y, z, out_x, out_y, out_z);
					
					if (ray_x != 0.0 || ray_y != 0.0 || ray_z != 0.0)
			        {
			            FindGoToPoint (i);
			            continue;
			        }

					*/
			        
			        if (IsPlayerInAnyVehicle (playerid))
			        {
			            new Float: v_x, Float: v_y, Float: v_z;

						GetVehicleVelocity (GetPlayerVehicleID (playerid), v_x, v_y, v_z);

						if (v_x != 0.0 || v_y != 0.0 || v_z != 0.0)
						{
						    range = 25.0;
						}
			        }
			        
			        if (PlayerInfo [playerid][weapon_shot] == 1)
			        {
			            range = 150.0;
			        }
				
				    if (IsPlayerInRangeOfPoint (playerid, range, x, y, z))
				    {
				        GetPlayerPos (playerid, p_x, p_y, p_z);
				        
						if ((z - p_z) > -0.75)
						{
						    FCNPC_ClearAnimations (playerid);
							FCNPC_GoTo (i, p_x, p_y, p_z, FCNPC_MOVE_TYPE_SPRINT, FCNPC_MOVE_SPEED_SPRINT);
							
							ZombieInfo [i][chasing] = playerid;
							ZombieInfo [i][chasing_range] = range;
							
							PlayerInfo [playerid][getting_chased] = i;
							PlayerInfo [playerid][zombies_chasing]++;
						}
					}
					else { FindGoToPoint (i); }
				}
			}
			else
			{
			
			    if (!IsPlayerInRangeOfPoint (ZombieInfo [i][chasing], ZombieInfo [i][chasing_range], x, y, z))
			    {
			    
			        PlayerInfo [ZombieInfo [i][chasing]][getting_chased] = -1;
			        PlayerInfo [ZombieInfo [i][chasing]][zombies_chasing]--;
			    
			        ZombieInfo [i][chasing] = -1;
			        ZombieInfo [i][chasing_range] = 25.0;

			        FCNPC_ResetAnimation (i);
					FCNPC_GetPosition (i, x, y, z);
					
					if (IsPointInDynamicArea (Z_Zone [ZombieInfo [i][zone_id]], x, y, z))
					{
			        	FindGoToPoint (i);
			        }
			        else
			        {
			            if (ZombieInfo [i][zone_id] == -1)
			            {
			            	FindGoToPoint (i);
			            }
			            else
			            {
			                ReturnPath (i);
			            }
			        }
			    }
			    else
			    {

					new npcid = i;

				    FCNPC_GetPosition (npcid, x, y, z);
				    GetPlayerPos (ZombieInfo [npcid][chasing], p_x, p_y, p_z);

					if (((z - p_z) < -0.75)

						|| IsPlayerInDynamicArea (ZombieInfo [npcid][chasing], SafeZone_1)
						|| IsPlayerInDynamicArea (ZombieInfo [npcid][chasing], SafeZone_2))
				    {

				        // PlayerInfo [ZombieInfo [npcid][chasing]][zombies_chasing]--;
				        // ZombieInfo [npcid][chasing] = -1;
				        // FindGoToPoint (npcid);

				        ZombieInfo [npcid][waiting_timer] = SetTimerEx ("OnZombieDetectHeight", 1000, false, "i", npcid);
				        return 0;
				    }

				    FCNPC_StopAim (npcid);
				    FCNPC_StopAttack (npcid);
				    FCNPC_ClearAnimations (npcid);
				    FCNPC_GoTo (npcid, p_x, p_y, p_z, FCNPC_MOVE_TYPE_SPRINT, FCNPC_MOVE_SPEED_SPRINT);
				    if (IsPlayerInRangeOfPoint (ZombieInfo [npcid][chasing], 2.5, x, y, z)) { FCNPC_MeleeAttack (npcid, 1000); } else { FCNPC_StopAttack (npcid); }
			    
			        /*
					if (ZombieInfo [i][chasing_range] == 100.0)
					{
			        	if (IsPlayerInRangeOfPoint (ZombieInfo [i][chasing], 25.0, x, y, z))
			        	{
			        	    ZombieInfo [i][chasing_range] = 25.0;
			        	}
			        }
			        */
			        
			    }
			}
		}
	}

	return 1;
}

forward FadeWeaponShotSound (playerid);
public FadeWeaponShotSound (playerid)
{
	PlayerInfo [playerid][weapon_shot] = 0;
	return 1;
}

forward ExtinguishFire (objectid);
public ExtinguishFire (objectid)
{
	DestroyObject (ItemInfo [objectid][item_attached]);
	ItemInfo [objectid][item_attached] = -1;
	
	if (ItemInfo [objectid][item_ammo] == 0)
	{
	    ItemInfo [objectid][item_id] = -1;
		ItemInfo [objectid][item_static_id] = -1;
		ItemInfo [objectid][item_type] = -1;
		ItemInfo [objectid][item_amount] = -1;
		ItemInfo [objectid][item_ammo] = -1;
  		ItemInfo [objectid][item_attached] = -1;

  		DestroyObject (objectid);
	}
	return 1;
}

forward OnPlayerCraft (playerid);
public OnPlayerCraft (playerid)
{
	PlayerInfo [playerid][crafted]++;
	UpdateCraftingBar (playerid);
	
	if (PlayerInfo [playerid][crafted] == PlayerInfo [playerid][crafting_time])
	{
	    new s_type, s_id, s_amount, s_ammo, s_state,
	    
	        p_type, p_id, p_amount, p_ammo, p_state,
	    
			string_parts [5][64],

			needed, found;
			
		strexplode (string_parts, PlayerInfo [playerid][crafting_method]);
		
		for (new i = 0; i < 5; i++)
		{
			if (!sscanf (string_parts [i], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
			{
			    needed++;
			    
			    for (new n = 0; i < PlayerInfo [playerid][slots_used]; i++)
			    {
			        if (!sscanf (PlayerInventory [playerid][n][item], "iiiii", p_type, p_id, p_amount, p_ammo, p_state))
			        {
			            if (s_type == p_type && s_id == p_id && p_amount >= s_amount && p_ammo >= s_ammo)
			            {
			                found++;
						}
					}
				}
			}
		}
	
		if (found == needed)
		{
			for (new i = 0; i < 5; i++)
			{
				if (!sscanf (string_parts [i], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
				{
				    for (new n = 0; i < PlayerInfo [playerid][slots_used]; i++)
				    {
				        if (!sscanf (PlayerInventory [playerid][n][item], "iiiii", p_type, p_id, p_amount, p_ammo, p_state))
				        {
				            if (s_type == p_type && s_id == p_id && p_amount >= s_amount && p_ammo >= s_ammo)
				            {
				                p_amount -= s_amount;

				                if (p_amount <= 0)
								{
								    RearrangePlayerInventorySlots (playerid, n);

									continue;
								}
				                else { format (PlayerInventory [playerid][n][item], 144, "%d %d %d %d %d", p_type, p_id, p_amount, p_ammo, p_state); }
				                

								switch (CraftableItems [PlayerInfo [playerid][selected_item_static_id]][item_type])
								{
								    case 6:
								    {
								        if (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_CARRY)
								        {

											new Float: x, Float: y, Float: z,
											    created_item,
											    items;
											    
											for (new m = 0; m < MAX_OBJECTS; m++) { if (ItemInfo [m][item_type] != 0) { items++; } }

											GetPlayerPos (playerid, x, y, z);
											MapAndreas_FindZ_For2DCoord (x, y, z);

											created_item = CreateObject (BigItems [CraftableItems [PlayerInfo [playerid][selected_item_static_id]][item_id]][model_id_1], x, y, z, 0.0, 0.0, 0.0);

											ItemInfo [created_item][item_static_id] = CraftableItems [PlayerInfo [playerid][selected_item_static_id]][item_id];
											ItemInfo [created_item][item_ammo] 		= 3;
											ItemInfo [created_item][item_type]		= CraftableItems [PlayerInfo [playerid][selected_item_static_id]][item_type];
											ItemInfo [created_item][item_id] 		= items;
						                    ItemInfo [created_item][item_amount] 	= 1;
						                    
								        }
								        else
								        {
											SetPlayerAttachedObject (playerid, 2, BigItems [CraftableItems [PlayerInfo [playerid][selected_item_static_id]][item_id]][model_id_1], 5, 0.0, 0.0, 0.0, 90.0, 190.0, 110.0, 0.25, 0.25, 0.25);
											SetPlayerSpecialAction (playerid, SPECIAL_ACTION_CARRY);

											format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "6 %d 1 %d -1", CraftableItems [PlayerInfo [playerid][selected_item_static_id]][item_id], BigItems [CraftableItems [PlayerInfo [playerid][selected_item_static_id]][item_id]][item_ammo]);
											PlayerInfo [playerid][slots_used]++;
										}
									}
								}

							}
				        }
				    }
				}
			}
		}
		else
		{
		    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Crafting failed. ");
		    SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"You don't have the resources to craft the item. ");
		}
		
		KillTimer (PlayerInfo [playerid][crafting_timer]);
		HideCraftingBar (playerid);
	}
	return 1;
}

forward OnPlayerCookFood (playerid, cookable_item, campfire_id);
public OnPlayerCookFood (playerid, cookable_item, campfire_id)
{

	new Float: x, Float: y, Float: z;
	GetObjectPos (campfire_id, x, y, z);
	
	if (!IsPlayerInRangeOfPoint (playerid, 1.5, x, y, z))
	{
	    SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You moved away from campfire, cooking cancelled. ");
	    
	    KillTimer (PlayerInfo [playerid][cooking_timer]);

		HideCookingBar (playerid);
		
		return 0;
	}

	PlayerInfo [playerid][cooked]++;
	UpdateCookingBar (playerid);

	if (PlayerInfo [playerid][cooked] == PlayerInfo[playerid][cooking_time])
	{

		KillTimer (PlayerInfo [playerid][cooking_timer]);
		HideCookingBar (playerid);

		new s_type, s_id, s_amount, s_ammo, s_state;
		if (!sscanf (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_state))
		{
			s_amount--;

			if (s_type == 2)
			{
			    if (s_id == cookable_item)
			    {
			        switch (cookable_item)
			        {
			            case 16:
			            {
							if (s_amount <= 0) { RearrangePlayerInventorySlots (playerid, PlayerInfo [playerid][selected_inventory_slot]); }
							else { format (PlayerInventory [playerid][PlayerInfo [playerid][selected_inventory_slot]][item], 124, "2 16 %d -1 -1", s_amount); }

							format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "1 15 1 -1 -1");

							SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You have cooked 1 raw meat. ");
						}
					}
				}
			}
		}
	}
	return 1;
}

forward ResetItemAddedVarValue (playerid);
public ResetItemAddedVarValue (playerid)
{
	PlayerInfo [playerid][item_added] = 0;
	return 1;
}

forward UpdatePlayerBars (playerid);
public UpdatePlayerBars (playerid)
{
	if (PlayerInfo [playerid][spawned] == 1 && PlayerInfo [playerid][loaded] == 1)
	{
		PlayerInfo [playerid][hunger] -= 2.0;
		PlayerInfo [playerid][thirst] -= 4.5;

		if (PlayerInfo [playerid][hunger] <= 0.0) { PlayerInfo [playerid][hunger] = 0.0; }
		if (PlayerInfo [playerid][thirst] <= 0.0) { PlayerInfo [playerid][thirst] = 0.0; }

		SetPlayerProgressBarValue (playerid, HungerBar [playerid], PlayerInfo [playerid][hunger]);
		SetPlayerProgressBarValue (playerid, ThirstBar [playerid], PlayerInfo [playerid][thirst]);

		ShowPlayerProgressBar (playerid, HungerBar [playerid]);
		ShowPlayerProgressBar (playerid, ThirstBar [playerid]);

		new Float: HP;
		GetPlayerHealth (playerid, HP);

		if (PlayerInfo [playerid][hunger] < 25.0) { SetPlayerHealth (playerid, (HP - 2.5)); }
		if (PlayerInfo [playerid][thirst] < 25.0) { SetPlayerHealth (playerid, (HP - 2.5)); }
	}
	return 1;
}

forward OnPlayerInit (playerid);
public OnPlayerInit (playerid)
{
	if (cache_num_rows () == 0)
	{
	    SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"In order to play on this server you need to register your account. ");
	    SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"If you don't already have an account, you can register here: "SERVER_WEBSITE"");

		SetTimerEx ("KickPlayer", 1000, false, "i", playerid);
	}
	else
	{
	    SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"This name is registered in the database. ");
	    SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Enter the password to login this account. ");
	    
	    cache_get_value_name (0, "PASSWORD", PlayerInfo [playerid][password], 32);
	    cache_get_value_name_int (0, "ACCOUNT_ID", PlayerInfo [playerid][account_id]);
	    
	    PlayerInfo [playerid][kick_timer] = SetTimerEx ("KickPlayer", strval(LOGIN_TIME_LIMIT) * 1000, false, "i", playerid);
	    
	    ShowLoginDialog (playerid);
	}
	return 1;
}

forward LoadPlayerData (playerid);
public LoadPlayerData (playerid)
{
	// GENERAL PLAYER DATA //
	cache_get_value_name_int (0, "ACCOUNT_ID", PlayerInfo [playerid][account_id]);

	cache_get_value_name_int (0, "INITIATED", PlayerInfo [playerid][initiated]);

	cache_get_value_name_int (0, "GENDER", PlayerInfo [playerid][gender]);
	cache_get_value_name_int (0, "AGE", PlayerInfo [playerid][age]);
	cache_get_value_name_int (0, "SKIN", PlayerInfo [playerid][skin]);
	
	cache_get_value_name_float (0, "HEALTH", PlayerInfo [playerid][health]);
	cache_get_value_name_float (0, "HUNGER", PlayerInfo [playerid][hunger]);
	cache_get_value_name_float (0, "THIRST", PlayerInfo [playerid][thirst]);
	
	cache_get_value_name_int (0, "JOB", PlayerInfo [playerid][job]);
	
	cache_get_value_name_float (0, "LAST_X", PlayerInfo [playerid][last_x]);
	cache_get_value_name_float (0, "LAST_Y", PlayerInfo [playerid][last_y]);
	cache_get_value_name_float (0, "LAST_Z", PlayerInfo [playerid][last_z]);
	
	cache_get_value_name_int (0, "LAST_INTERIOR", PlayerInfo [playerid][last_interior]);

	cache_get_value_name_int (0, "PLAYER_SPAWN", PlayerInfo [playerid][player_spawn]);

 	CreatePlayerProgressBars (playerid);
 	
 	PlayerInfo [playerid][loaded] = 1;
	return 1;
}

forward LoadPlayerInventory (playerid);
public LoadPlayerInventory (playerid)
{
	cache_get_value_name_int (0, "MAX_SLOTS", PlayerInfo [playerid][inventory_slots]);
	cache_get_value_name_int (0, "MAX_VIRTUAL_SLOTS", PlayerInfo [playerid][inventory_virtual_slots]);
	cache_get_value_name_int (0, "USED_SLOTS", PlayerInfo [playerid][slots_used]);

	cache_get_value_name (0, "SLOT_1", PlayerInventory [playerid][0][item], 124);
    cache_get_value_name (0, "SLOT_2", PlayerInventory [playerid][1][item], 124);
    cache_get_value_name (0, "SLOT_3", PlayerInventory [playerid][2][item], 124);
    cache_get_value_name (0, "SLOT_4", PlayerInventory [playerid][3][item], 124);
    cache_get_value_name (0, "SLOT_5", PlayerInventory [playerid][4][item], 124);
    cache_get_value_name (0, "SLOT_6", PlayerInventory [playerid][5][item], 124);
    cache_get_value_name (0, "SLOT_7", PlayerInventory [playerid][6][item], 124);
    cache_get_value_name (0, "SLOT_8", PlayerInventory [playerid][7][item], 124);
    cache_get_value_name (0, "SLOT_9", PlayerInventory [playerid][8][item], 124);
    cache_get_value_name (0, "SLOT_10", PlayerInventory [playerid][9][item], 124);
    cache_get_value_name (0, "SLOT_11", PlayerInventory [playerid][10][item], 124);
    cache_get_value_name (0, "SLOT_12", PlayerInventory [playerid][11][item], 124);
    cache_get_value_name (0, "SLOT_13", PlayerInventory [playerid][12][item], 124);
    cache_get_value_name (0, "SLOT_14", PlayerInventory [playerid][13][item], 124);
    cache_get_value_name (0, "SLOT_15", PlayerInventory [playerid][14][item], 124);
    cache_get_value_name (0, "SLOT_16", PlayerInventory [playerid][15][item], 124);
	return 1;
}

forward SavePlayerData (playerid);
public SavePlayerData (playerid)
{
	new query [1500], string [500];
	
	GetPlayerHealth (playerid, PlayerInfo [playerid][health]);
	
	PlayerInfo [playerid][last_interior] = GetPlayerInterior (playerid);

	// GENERAL PLAYER DATA //
	mysql_format (mysql, string, sizeof (string), "UPDATE `players` SET ");
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`INITIATED` = %d, ", 		PlayerInfo [playerid][initiated]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`GENDER` = %d, ", 			PlayerInfo [playerid][gender]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`AGE` = %d, ", 				PlayerInfo [playerid][age]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`SKIN` = %d, ", 				PlayerInfo [playerid][skin]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`HEALTH` = %f, ", 			PlayerInfo [playerid][health]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`HUNGER` = %f, ", 			PlayerInfo [playerid][hunger]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`THIRST` = %f, ", 			PlayerInfo [playerid][thirst]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`JOB` = %d ", 				PlayerInfo [playerid][job]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "WHERE `ACCOUNT_ID` = %d", 	PlayerInfo [playerid][account_id]);
	strcat (query, string, sizeof (string));
	
	mysql_pquery (mysql, query);
	
	// MORE PAYER DATA //
	
	mysql_format (mysql, query, sizeof (query), "UPDATE `players` SET ");
	
	mysql_format (mysql, string, sizeof (string), "`LAST_X` = %f,", 			PlayerInfo [playerid][last_x]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`LAST_Y` = %f,", 			PlayerInfo [playerid][last_y]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`LAST_Z` = %f,", 			PlayerInfo [playerid][last_z]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`LAST_INTERIOR` = %d,", 	PlayerInfo [playerid][last_interior]);
	strcat (query, string, sizeof (string));
	
	mysql_format (mysql, string, sizeof (string), "`PLAYER_SPAWN` = %d ", 		PlayerInfo [playerid][player_spawn]);
	strcat (query, string, sizeof (string));
	
    mysql_format (mysql, string, sizeof (string), "WHERE `ACCOUNT_ID` = %d", 	PlayerInfo [playerid][account_id]);
	strcat (query, string, sizeof (string));
	
	mysql_pquery (mysql, query);
	
	
	query [0] = '\0';
	
	// INVENTORY //
	mysql_format (mysql, string, sizeof (string), "UPDATE `inventories` SET ");
	strcat (query, string);

    mysql_format (mysql, string, sizeof (string), "`MAX_SLOTS` = %d, ", PlayerInfo [playerid][inventory_slots]);
	strcat (query, string);
	
	mysql_format (mysql, string, sizeof (string), "`MAX_VIRUTAL_SLOTS` = %d, ", PlayerInfo [playerid][inventory_virtual_slots]);
	strcat (query, string);
	
	mysql_format (mysql, string, sizeof (string), "`USED_SLOTS` = %d, ", PlayerInfo [playerid][slots_used]);
	strcat (query, string);
	
	for (new i = 0; i < PlayerInfo [playerid][inventory_virtual_slots]; i++)
	{

        mysql_format (mysql, string, sizeof (string), "`SLOT_%d` = '%e'%s ", (i + 1), PlayerInventory [playerid][i][item], (i == (PlayerInfo [playerid][inventory_virtual_slots] - 1) ? ("") : (",")));
		strcat (query, string);
	}
	
	mysql_format (mysql, string, sizeof (string), "WHERE `ACCOUNT_ID` = %d", PlayerInfo [playerid][account_id]);
	strcat (query, string);
	
	mysql_pquery (mysql, query);

	return 1;
}

////////////////////////////////////////////////////////////////////////////////
// STOCKS //////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

stock CreateTables ()
{
	new string [2500], part [200];

	// PLAYER DATA TABLE
    
	strcat (string, "CREATE TABLE IF NOT EXISTS `players` ", 						sizeof (string));
	strcat (string, "(`ACCOUNT_ID` INT (32) NOT NULL AUTO_INCREMENT PRIMARY KEY, ", sizeof (string));
	strcat (string, "`NAME` VARCHAR (24), ", 										sizeof (string));
	strcat (string, "`PASSWORD` VARCHAR (32), ", 									sizeof (string));
	strcat (string, "`INITIATED` INT (12) NOT NULL, ", 								sizeof (string));
	strcat (string, "`GENDER` INT (4), ", 											sizeof (string));
	strcat (string, "`AGE` INT (12), ", 											sizeof (string));
	strcat (string, "`SKIN` INT (24), ", 											sizeof (string));
	strcat (string, "`HEALTH` FLOAT (24), ", 										sizeof (string));
	strcat (string, "`HUNGER` FLOAT (24), ", 										sizeof (string));
	strcat (string, "`THIRST` FLOAT (24), ", 										sizeof (string));
	strcat (string, "`JOB` INT (12), ", 											sizeof (string));
	strcat (string, "`LAST_X` FLOAT (16), ", 										sizeof (string));
	strcat (string, "`LAST_Y` FLOAT (16), ", 										sizeof (string));
	strcat (string, "`LAST_Z` FLOAT (16), ", 										sizeof (string));
	strcat (string, "`LAST_INTERIOR` INT (12), ", 									sizeof (string));
	strcat (string, "`PLAYER_SPAWN` INT (12))", 									sizeof (string));

    mysql_query (mysql, string);

	string [0] = EOS;

	// PLAYER INVENTORY TABLE
	strcat (string, "CREATE TABLE IF NOT EXISTS `inventories` ", 	sizeof (string));
	
	strcat (string, "(`ACCOUNT_ID`       INT (32),  ", 				sizeof (string));
	
	strcat (string, "`MAX_SLOTS`         INT (16),  ", 				sizeof (string));
	strcat (string, "`MAX_VIRTUAL_SLOTS` INT (16),  ", 				sizeof (string));
	strcat (string, "`USED_SLOTS` 		 INT (16),  ", 				sizeof (string));
	

	for (new i = 0; i < (MAX_SLOTS); i++)
	{
	    part [0] = '\0';
	    format (part, sizeof (part), "`SLOT_%d` VARCHAR (32)%s ", (i + 1), ((i == (MAX_SLOTS - 1)) ? (")") : (",")));
		strcat (string, part, sizeof (string));
	}
	
	mysql_query (mysql, string);

	string [0] = EOS;

	// VEHICLES
	strcat (string, "CREATE TABLE IF NOT EXISTS `vehicles`", sizeof (string));
	
	strcat (string, "(`model`   INT (16),   ", sizeof (string));
	
	strcat (string, "`color_1`  INT (12),  ", sizeof (string));
	strcat (string, "`color_2`  INT (12),  ", sizeof (string));
	
	strcat (string, "`engine`  INT (12),  ", sizeof (string));
	strcat (string, "`lights`  INT (12),  ", sizeof (string));
	strcat (string, "`alarms`  INT (12),  ", sizeof (string));
	strcat (string, "`doors`   INT (12),  ", sizeof (string));
	strcat (string, "`bonnet`  INT (12),  ", sizeof (string));
	strcat (string, "`boot`    INT (12),  ", sizeof (string));
	
	strcat (string, "`d_panels`  INT (12),  ", sizeof (string));
	strcat (string, "`d_doors`   INT (12),  ", sizeof (string));
	strcat (string, "`d_lights`  INT (12),  ", sizeof (string));
	strcat (string, "`d_tires`   INT (12),  ", sizeof (string));
	
	strcat (string, "`health`   FLOAT (16), ", sizeof (string));
	strcat (string, "`fuel`     FLOAT (16), ", sizeof (string));
	
	strcat (string, "`last_x`   FLOAT (16), ", sizeof (string));
	strcat (string, "`last_y`   FLOAT (16), ", sizeof (string));
	strcat (string, "`last_z`   FLOAT (16), ", sizeof (string));
	strcat (string, "`last_a`   FLOAT (16)) ", sizeof (string));

	mysql_query (mysql, string);

	return 1;
}

forward OnPlayerCheckDrivingLicense (playerid);
public OnPlayerCheckDrivingLicense (playerid)
{
	new player_name [MAX_PLAYER_NAME + 1];
	cache_get_value_name (0, "NAME", player_name, sizeof (player_name));
	
	new string [250];
	format (string, sizeof (string), ""COLOR_MAIN_HEX"\n- Badge Owner: "COLOR_WHITE"%s\n", player_name);
	
	ShowPlayerDialog (playerid, PLAYER_BADGE_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""SERVER_TAG" - Player Badge", string, "Ok", "");
	return 1;
}

stock GetServerSlots ()
{

    if (!fexist ("../../server.cfg"))
	{
	    SERVER_SLOTS = 1000;
	    return 0;
	}

	new File: file = fopen ("../../server.cfg", io_read);

	new line [124],

	    cfg_text [24],
	    data;

	while (fread (file, line))
	{
	    if (strfind (line, "maxplayers"))
	    {
	        if (!sscanf (line, "s[24]i", cfg_text, data))
	        {
	            SERVER_SLOTS = data;
	        }
	    }
	}

	fclose (file);

	return 1;
}

stock ShowLoginDialog (playerid)
{
    ShowPlayerDialog (playerid, LOGIN_DIALOG_ID, DIALOG_STYLE_PASSWORD, ""SERVER_TAG" - Login", "Password:\n\n(You have "LOGIN_TIME_LIMIT" seconds to login)", "Login", "");
	return 1;
}

stock SetupPlayer (playerid)
{

	new query [250];
	mysql_format (mysql, query, sizeof (query), "INSERT INTO `inventories` (`ACCOUNT_ID`, `MAX_SLOTS`, `MAX_VIRTUAL_SLOTS`, `USED_SLOTS`) VALUES (%d, %d, %d, 0)",
	PlayerInfo [playerid][account_id],
	PlayerInfo [playerid][inventory_slots],
	PlayerInfo [playerid][inventory_virtual_slots]);

	mysql_query (mysql, query);

	PlayerInfo [playerid][health] = 100.0;
	PlayerInfo [playerid][hunger] = 100.0;
	PlayerInfo [playerid][thirst] = 100.0;
	
	PlayerInfo [playerid][data_loaded] = 1;

	SetPlayerInterior (playerid, 0);
	SetPlayerVirtualWorld (playerid, 0);

	PlayerInfo [playerid][initiated] = 1;

	SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"You are all set up, enjoy your survival. ");
	SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Need help ? Use (/help) for information about the server. ");
	SendClientMessage (playerid, COLOR_MAIN, "[INFO] "COLOR_WHITE"Don't forget to read the (/rules). ");
	return 1;
}

stock SpawnAtSelectedSpawnArea (playerid)
{
	if (PlayerInfo [playerid][player_spawn] == 0)
	{
		new selected_spawn = random (18);
		SetPlayerPos (playerid, LosSantosSpawns [selected_spawn][0], LosSantosSpawns [selected_spawn][1], LosSantosSpawns [selected_spawn][2]);
		SetPlayerFacingAngle (playerid, LosSantosSpawns [selected_spawn][3]);
	}
	else if (PlayerInfo [playerid][player_spawn] == 1)
	{
		new selected_spawn = random (6);
		SetPlayerPos (playerid, PalominoCreekSpawns [selected_spawn][0], PalominoCreekSpawns [selected_spawn][1], PalominoCreekSpawns [selected_spawn][2]);
		SetPlayerFacingAngle (playerid, PalominoCreekSpawns [selected_spawn][3]);
	}
	else if (PlayerInfo [playerid][player_spawn] == 2)
	{
		new selected_spawn = random (6);
		SetPlayerPos (playerid, MontgomerySpawns [selected_spawn][0], MontgomerySpawns [selected_spawn][1], MontgomerySpawns [selected_spawn][2]);
		SetPlayerFacingAngle (playerid, MontgomerySpawns [selected_spawn][3]);
	}
	else if (PlayerInfo [playerid][player_spawn] == 3)
	{
		new selected_spawn = random (6);
		SetPlayerPos (playerid, BlueberrySpawns [selected_spawn][0], BlueberrySpawns [selected_spawn][1], BlueberrySpawns [selected_spawn][2]);
		SetPlayerFacingAngle (playerid, BlueberrySpawns [selected_spawn][3]);
	}
	else if (PlayerInfo [playerid][player_spawn] == 4)
	{
		new selected_spawn = random (5);
		SetPlayerPos (playerid, DillimoreSpawns [selected_spawn][0], DillimoreSpawns [selected_spawn][1], DillimoreSpawns [selected_spawn][2]);
		SetPlayerFacingAngle (playerid, DillimoreSpawns [selected_spawn][3]);
	}
	return 1;
}

stock ShowProgressBars (playerid)
{
	if (PlayerInfo [playerid][loaded] == 1)
	{
		ShowPlayerProgressBar (playerid, HungerBar [playerid]);
		ShowPlayerProgressBar (playerid, ThirstBar [playerid]);
	}
	return 1;
}

stock HideProgressBars (playerid)
{
	if (PlayerInfo [playerid][loaded] == 1)
	{
		HidePlayerProgressBar (playerid, HungerBar [playerid]);
		HidePlayerProgressBar (playerid, ThirstBar [playerid]);
	}
	return 1;
}

stock UpdateCookingBar (playerid)
{
	SetPlayerProgressBarValue (playerid, CookingBar [playerid], (100 * PlayerInfo [playerid][cooked] / PlayerInfo [playerid][cooking_time]) * 1.0);
	ShowPlayerProgressBar (playerid, CookingBar [playerid]);
	return 1;
}

stock ShowCookingBar (playerid)
{
	TextDrawShowForPlayer (playerid, CookingTD);
	ShowPlayerProgressBar (playerid, CookingBar [playerid]);
	return 1;
}

stock HideCookingBar (playerid)
{
	TextDrawHideForPlayer (playerid, CookingTD);
    HidePlayerProgressBar (playerid, CookingBar [playerid]);
	return 1;
}

stock UpdateCraftingBar (playerid)
{
	SetPlayerProgressBarValue (playerid, CraftingBar [playerid], (100 * PlayerInfo [playerid][crafted] / PlayerInfo [playerid][crafting_time]) * 1.0);
	ShowPlayerProgressBar (playerid, CraftingBar [playerid]);
	return 1;
}

stock ShowCraftingBar (playerid)
{
	TextDrawShowForPlayer (playerid, CraftingTD);
	ShowPlayerProgressBar (playerid, CraftingBar [playerid]);
	return 1;
}

stock HideCraftingBar (playerid)
{
	TextDrawHideForPlayer (playerid, CraftingTD);
	HidePlayerProgressBar (playerid, CraftingBar [playerid]);
	return 1;
}

stock UpdateFuelBar (playerid)
{
	SetPlayerProgressBarValue (playerid, FuelBar [playerid], VehicleInfo [GetPlayerVehicleID (playerid)][vehicle_fuel]);
	return 1;
}

stock ShowFuelBar (playerid)
{
	ShowPlayerProgressBar (playerid, FuelBar [playerid]);
	return 1;
}

stock HideFuelBar (playerid)
{
    HidePlayerProgressBar (playerid, FuelBar [playerid]);
	return 1;
}

stock CreatePlayerProgressBars (playerid)
{
	HungerBar [playerid] = CreatePlayerProgressBar (playerid, 548, 26.75, 56.5, 5.0, COLOR_HUNGER, 100.0);
	ThirstBar [playerid] = CreatePlayerProgressBar (playerid, 548, 36.75, 56.5, 5.0, COLOR_THIRST, 100.0);
	
	SetPlayerProgressBarValue (playerid, HungerBar [playerid], PlayerInfo [playerid][hunger]);
	SetPlayerProgressBarValue (playerid, ThirstBar [playerid], PlayerInfo [playerid][thirst]);
	return 1;
}

stock CreatePlayerCookingBar (playerid)
{
	CookingBar [playerid] = CreatePlayerProgressBar (playerid, 435, 90.0, 56.5, 5.0, COLOR_MAIN, 100.0);
	SetPlayerProgressBarValue (playerid, CookingBar [playerid], 0.0);
	return 1;
}

stock CreatePlayerCraftingBar (playerid)
{
    CraftingBar [playerid] = CreatePlayerProgressBar (playerid, 435, 90.0, 56.5, 5.0, COLOR_MAIN, 100.0);
	SetPlayerProgressBarValue (playerid, CookingBar [playerid], 0.0);
	return 1;
}

stock CreatePlayerFuelBar (playerid)
{
	CreatePlayerProgressBar (playerid, 435, 90.0, 56.5, 5.0, COLOR_MAIN, 100.0);
	SetPlayerProgressBarValue (playerid, FuelBar [playerid], 0.0);
	return 1;
}

stock DestroyPlayerProgressBars (playerid)
{
	DestroyPlayerProgressBar (playerid, HungerBar [playerid]);
	DestroyPlayerProgressBar (playerid, ThirstBar [playerid]);
	DestroyPlayerProgressBar (playerid, CookingBar [playerid]);
	DestroyPlayerProgressBar (playerid, CraftingBar [playerid]);
	DestroyPlayerProgressBar (playerid, FuelBar [playerid]);
	return 1;
}

stock CreateGlobalTextDraws ()
{
    CookingTD = TextDrawCreate(432.666595, 75.511100, "COOKING");
	TextDrawLetterSize(CookingTD, 0.347111, 1.346133);
	TextDrawAlignment(CookingTD, 1);
	TextDrawColor(CookingTD, -5963521);
	TextDrawSetShadow(CookingTD, 0);
	TextDrawSetOutline(CookingTD, 0);
	TextDrawBackgroundColor(CookingTD, 255);
	TextDrawFont(CookingTD, 2);
	TextDrawSetProportional(CookingTD, 1);
	TextDrawSetShadow(CookingTD, 0);
	
	CraftingTD = TextDrawCreate(432.666595, 75.511100, "CRAFTING");
	TextDrawLetterSize(CookingTD, 0.347111, 1.346133);
	TextDrawAlignment(CookingTD, 1);
	TextDrawColor(CookingTD, -5963521);
	TextDrawSetShadow(CookingTD, 0);
	TextDrawSetOutline(CookingTD, 0);
	TextDrawBackgroundColor(CookingTD, 255);
	TextDrawFont(CookingTD, 2);
	TextDrawSetProportional(CookingTD, 1);
	TextDrawSetShadow(CookingTD, 0);
	return 1;
}

stock PickupItem (playerid, itemid, itemamount)
{
	
	new message [250],

	amount, ammo,

	slot, destroy,

	s_id, s_type, s_amount, s_ammo, s_status,
	
	items_pickedup;
	
	
	if (ItemInfo [itemid][item_type] == 6)
	{
		if (ItemInfo [itemid][item_static_id] == 0)
		{
		    if (ItemInfo [itemid][item_ammo] == 0) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"This item cannot be picked up. ");
		    
			format (PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item], 124, "6 0 1 %d -1", ItemInfo [itemid][item_ammo]);
			PlayerInfo [playerid][slots_used]++;

			SetPlayerAttachedObject (playerid, 2, ItemInfo [itemid][item_model_id], 5, 0.0, 0.0, 0.0, 90.0, 190.0, 110.0, 0.25, 0.25, 0.25);
			SetPlayerSpecialAction (playerid, SPECIAL_ACTION_CARRY);

			amount = 1;

			format (message, sizeof (message), "[INFO] %sYou picked up %d %s", COLOR_WHITE, amount, BigItems [ItemInfo [itemid][item_static_id]][name]);
			SendClientMessage (playerid, COLOR_MAIN, message);

			ItemInfo [itemid][item_amount]--;

			if (ItemInfo [itemid][item_amount] <= 0)
			{
			
			    DestroyObject (ItemInfo [itemid][item_attached]);
			
			    ItemInfo [itemid][item_id] = -1;
				ItemInfo [itemid][item_static_id] = -1;
				ItemInfo [itemid][item_type] = -1;
				ItemInfo [itemid][item_amount] = -1;
				ItemInfo [itemid][item_ammo] = -1;
		  		ItemInfo [itemid][item_attached] = -1;
		  		
		  		DestroyObject (itemid);

				KillTimer (ItemInfo [itemid][item_timer]);
			}
		}
		
		PlayerInfo [playerid][carrying] = 1;
	    return 0;
	}
	
	if (itemamount == -1)
	{
		if (ItemInfo [itemid][item_ammo] == -1 && ItemInfo [itemid][item_type] != 8 && ItemInfo [itemid][item_type] != 9 && ItemInfo [itemid][item_type] != 11 && ItemInfo [itemid][item_type] != 12 && ItemInfo [itemid][item_type] != 13)
		{
			for (new i = 0; i < PlayerInfo [playerid][inventory_virtual_slots]; i++)
			{
			    if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
	      		{
			        if (s_type == ItemInfo [itemid][item_type])
			        {
				        if (s_id == ItemInfo [itemid][item_static_id])
				        {
				            slot = i;
	                        amount = (s_amount + ItemInfo [itemid][item_amount]);
				        }
			        }
			    }

				if (i == PlayerInfo [playerid][slots_used] && amount == 0)
				{
				    slot = PlayerInfo [playerid][slots_used];
				    amount = ItemInfo [itemid][item_amount];

				    PlayerInfo [playerid][slots_used]++;
				    break;
				}
			}
			
			items_pickedup = 1;
			
			switch (ItemInfo [itemid][item_type])
		    {
	    		case 8, 9, 11, 12, 13, 14: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -2", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
				default: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -1", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
			}
			
		}
		else
		{
		    if (itemamount > (PlayerInfo [playerid][inventory_virtual_slots] - PlayerInfo [playerid][slots_used])) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Not enough inventory space. ");
		
		    slot = PlayerInfo [playerid][slots_used];

		    amount = 1;
			items_pickedup = ItemInfo [itemid][item_amount];
		    ammo = ItemInfo [itemid][item_ammo];

			for (new i = 0; i < items_pickedup; i++)
			{
			    PlayerInfo [playerid][slots_used]++;
			    
			    switch (ItemInfo [itemid][item_type])
			    {
		    		case 8, 9, 11, 12, 13, 14: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -2", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
					default: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -1", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
				}

				slot++;
		    }

		}

		switch (ItemInfo [itemid][item_type])
		{
			case  1: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, FoodItems [ItemInfo [itemid][item_static_id]][name]);
			case  2: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, MedicalItems [ItemInfo [itemid][item_static_id]][name]);
			case  3: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, CookableItems [ItemInfo [itemid][item_static_id]][name]);
			case  4: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, ResourceItems [ItemInfo [itemid][item_static_id]][name]);
			case  5: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, ToolItems [ItemInfo [itemid][item_static_id]][name]);
			case  6: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, BigItems [ItemInfo [itemid][item_static_id]][name]);
			case  7: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, MiscItems [ItemInfo [itemid][item_static_id]][name]);
			case  8: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, WeaponItems [ItemInfo [itemid][item_static_id]][name]);
			case  9: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, MeleeWeaponItems [ItemInfo [itemid][item_static_id]][name]);
			case 10: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, AmmoItems [ItemInfo [itemid][item_static_id]][name]);
			case 11: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, HeadWearableItems [ItemInfo [itemid][item_static_id]][name]);
			case 12: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, BodyWearableItems [ItemInfo [itemid][item_static_id]][wearable_name]);
			case 13: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, BackpackItems [ItemInfo [itemid][item_static_id]][name]);
			case 14: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, ArmourItems [ItemInfo [itemid][item_static_id]][name]);
		}
		
		destroy = 1;
	}
	else
	{
		if (ItemInfo [itemid][item_ammo] == -1 && ItemInfo [itemid][item_type] != 8 && ItemInfo [itemid][item_type] != 9 && ItemInfo [itemid][item_type] != 11 && ItemInfo [itemid][item_type] != 12 && ItemInfo [itemid][item_type] != 13)
		{
			for (new i = 0; i < PlayerInfo [playerid][inventory_virtual_slots]; i++)
			{
			    if (!sscanf (PlayerInventory [playerid][i][item], "iiiii", s_type, s_id, s_amount, s_ammo, s_status))
	      		{
			        if (s_type == ItemInfo [itemid][item_type])
			        {
				        if (s_id == ItemInfo [itemid][item_static_id])
				        {
				            slot = i;
	                        amount = (s_amount + itemamount);
				        }
			        }
			    }

				if (i == PlayerInfo [playerid][slots_used] && amount == 0)
				{
				    slot = PlayerInfo [playerid][slots_used];
				    amount = itemamount;

				    PlayerInfo [playerid][slots_used]++;
				    break;
				}
			}

			items_pickedup = 1;

			switch (ItemInfo [itemid][item_type])
		    {
	    		case 8, 9, 11, 12, 13, 14: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -2", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
				default: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -1", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
			}

		}
		else
		{
		    if (ItemInfo [itemid][item_amount] > (PlayerInfo [playerid][inventory_virtual_slots] - PlayerInfo [playerid][slots_used])) return SendClientMessage (playerid, COLOR_MAIN, "[ERROR] "COLOR_WHITE"Not enough inventory space. ");
		
		    slot = PlayerInfo [playerid][slots_used];

		    amount = 1;
			items_pickedup = itemamount;
		    ammo = ItemInfo [itemid][item_ammo];
		    
			ItemInfo [itemid][item_amount] -= amount;
			if (ItemInfo [itemid][item_amount] <= 0) { destroy = 1; }

			for (new i = 0; i < items_pickedup; i++)
			{
			    PlayerInfo [playerid][slots_used]++;

				switch (ItemInfo [itemid][item_type])
			    {
		    		case 8, 9, 11, 12, 13, 14: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -2", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
					default: format (PlayerInventory [playerid][slot][item], 124, "%d %d %d %d -1", ItemInfo [itemid][item_type], ItemInfo [itemid][item_static_id], amount, ammo);
				}

				slot++;
		    }

		}

		switch (ItemInfo [itemid][item_type])
		{
			case  1: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, FoodItems [ItemInfo [itemid][item_static_id]][name]);
			case  2: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, MedicalItems [ItemInfo [itemid][item_static_id]][name]);
			case  3: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, CookableItems [ItemInfo [itemid][item_static_id]][name]);
			case  4: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, ResourceItems [ItemInfo [itemid][item_static_id]][name]);
			case  5: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, ToolItems [ItemInfo [itemid][item_static_id]][name]);
			case  6: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, BigItems [ItemInfo [itemid][item_static_id]][name]);
			case  7: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, MiscItems [ItemInfo [itemid][item_static_id]][name]);
			case  8: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, WeaponItems [ItemInfo [itemid][item_static_id]][name]);
			case  9: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, MeleeWeaponItems [ItemInfo [itemid][item_static_id]][name]);
			case 10: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, AmmoItems [ItemInfo [itemid][item_static_id]][name]);
			case 11: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, HeadWearableItems [ItemInfo [itemid][item_static_id]][name]);
			case 12: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, BodyWearableItems [ItemInfo [itemid][item_static_id]][wearable_name]);
			case 13: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, BackpackItems [ItemInfo [itemid][item_static_id]][name]);
			case 14: format (message, sizeof (message), "[INFO] %sYou picked up %s", COLOR_WHITE, ArmourItems [ItemInfo [itemid][item_static_id]][name]);
		}
	}

	SendClientMessage (playerid, COLOR_MAIN, message);
	
	if (destroy == 1)
	{
		ItemInfo [itemid][item_id] = -1;
		ItemInfo [itemid][item_static_id] = -1;
		ItemInfo [itemid][item_type] = -1;
		ItemInfo [itemid][item_amount] = -1;
		ItemInfo [itemid][item_ammo] = -1;
		DestroyObject (itemid);
	}
	return 1;
}

stock LoadItems ()
{
	if (!fexist (CREATED_ITEMS_FILE))
	{
	    new File: file = fopen (CREATED_ITEMS_FILE, io_write);
	    fclose (file);
	}
	else
	{
	    new File: file = fopen (CREATED_ITEMS_FILE, io_read),
	    
		    line [400],

			id,
			type,
			ammo,
			model,
			amount,
			static_id,
			Float: p_x,
			Float: p_y,
			Float: p_z,
			Float: r_x,
			Float: r_y,
			Float: r_z,

			item_count,
	    	created_object;

	    while (fread (file, line))
	    {
	        if (!sscanf (line, "iiiiiiffffff", id, static_id, type, amount, ammo, model, p_x, p_y, p_z, r_x, r_y, r_z))
			{
			
		        created_object = CreateObject (model, p_x, p_y, p_z, r_x, r_y, r_z);

				ItemInfo [created_object][item_id] = id;
				ItemInfo [created_object][item_type] = type;
				ItemInfo [created_object][item_amount] = amount;
				ItemInfo [created_object][item_static_id] = static_id;
				ItemInfo [created_object][item_model_id] = model;
				ItemInfo [created_object][item_ammo] = ammo;

				item_count++;
			}
	    }
	    
	    fclose (file);
	}
	return 1;
}

stock RearrangePlayerInventorySlots (playerid, empty_slot)
{
    PlayerInventory [playerid][empty_slot][item][0] = EOS;

    for (new i = empty_slot; i < PlayerInfo [playerid][slots_used]; i++)
    {
        PlayerInventory [playerid][i][item][0] = EOS;
        format (PlayerInventory [playerid][i][item], 124, "%s", PlayerInventory [playerid][i + 1][item]);
    }

    PlayerInventory [playerid][PlayerInfo [playerid][slots_used]][item] = EOS;
    PlayerInfo [playerid][slots_used]--;
	return 1;
}

stock RearrangeActorInventorySlots (actorid, empty_slot)
{
	ActorInventory [actorid][empty_slot][item][0] = EOS;
	
	for (new i = empty_slot; i < ActorSlotsUsed [actorid]; i++)
	{
	    ActorInventory [actorid][i][item][0] = EOS;
	    format (ActorInventory [actorid][i][item], 124, "%s", ActorInventory [actorid][i + 1][item]);
	}
	
	ActorInventory [actorid][ActorSlotsUsed [actorid]][item][0] = EOS;
	ActorSlotsUsed [actorid]--;
	
	if (ActorSlotsUsed [actorid] == 0)
	{
	    DestroyActor (actorid);
	}
	return 1;
}

stock IsPointInRangeOfPoint(Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2, Float:range)
{
    x2 -= x;
    y2 -= y;
    z2 -= z;
    return ((x2 * x2) + (y2 * y2) + (z2 * z2)) < (range * range);
}
