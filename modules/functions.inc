
stock GetName (playerid)
{
	new Name [MAX_PLAYER_NAME + 1];
	GetPlayerName (playerid, Name, sizeof (Name));
	strreplace (Name, "_", " ");
	return Name;
}

stock LoadServer ()
{

	SendRconCommand ("password server_loading");

    SetTimer ("LoadDatabase",    500, false);
	SendRconCommand ("hostname SERVER: Loading Database ... "SERVER_NAME_TAG"");
	return 1;
}

forward LoadDatabase ();
public LoadDatabase ()
{
	ConnectToDatabase ();

 	SetTimer ("CheckTables",     500, false);
	SendRconCommand ("hostname SERVER: Loading SQL Tables ... "SERVER_NAME_TAG"");
	return 1;
}

forward CheckTables ();
public CheckTables ()
{
	CreateTables ();
	
	SetTimer ("LoadMapFrame",    500, false);
	SendRconCommand ("hostname SERVER: Loading Map Frame ... "SERVER_NAME_TAG"");
	return 1;
}

forward LoadMapFrame ();
public LoadMapFrame ()
{
    MapAndreas_Init (MAP_ANDREAS_MODE_FULL);

    SetTimer ("LoadObjects",     500, false);
	SendRconCommand ("hostname SERVER: Loading Objects ... "SERVER_NAME_TAG"");
	return 1;
}

forward LoadObjects ();
public LoadObjects ()
{
	CreateMaps ();
	LoadLoginScreenMap ();
	
	SetTimer ("LoadServerItems", 500, false);
	SendRconCommand ("hostname SERVER: Loading Items ... "SERVER_NAME_TAG"");
	return 1;
}

forward LoadServerItems ();
public LoadServerItems ()
{
	LoadItems ();
	CreateGlobalTextDraws ();
	
 	SetTimer ("CreateZombies",   500, false);
	SendRconCommand ("hostname SERVER: Creating Zombies "SERVER_NAME_TAG"");
	return 1;
}

forward SetServerInfo ();
public SetServerInfo ()
{
    SendRconCommand ("hostname "SERVER_NAME" "SERVER_NAME_TAG"");
	SendRconCommand ("gamemodetext "SERVER_MODE"");
	SendRconCommand ("language "SERVER_LANGUAGE"");
	SendRconCommand ("weburl "SERVER_WEBSITE"");

	SetGameModeText(SERVER_MODE);
	
	GetServerSlots ();
	
	WORLD_TIME = 12;
	SetWorldTime (WORLD_TIME);
	SetTimer ("UpdateWorldTime", 60 * 60 * 1000, true);
	
	SendRconCommand ("password 0");
	
	return 1;
}

forward KickPlayer (playerid);
public KickPlayer (playerid)
{
	if (IsPlayerNPC (playerid)) return 0;
	Kick (playerid);
	return 1;
}

stock GetWeaponType (weaponid)
{
	switch (weaponid)
	{
	    case 3, 4, 5, 15:	return 0;
	    case 24: 			return 1;
	    case 25, 27: 		return 2;
	    case 29, 32: 		return 3;
	    case 30, 31: 		return 4;
	    case 33, 34: 		return 5;
	}
	return -1;
}

stock CreateMaps ()
{
    MapObject [0] = CreateObject(1348, 657.5518, -644.2800, 16.0219, 0.0000, 0.0000, 0.0000); //CJ_O2Tanks
	MapObject [1] = CreateObject(1348, 657.2116, -645.7897, 16.0219, 0.0000, 0.0000, 90.0000); //CJ_O2Tanks
	MapObject [2] = CreateObject(1271, 659.3073, -642.4140, 15.7459, 0.0000, 0.0000, 0.0000); //gunbox
	MapObject [3] = CreateObject(19944, 617.5139, -591.1206, 16.2248, 0.0000, 0.0000, 90.0000); //BodyBag1
	MapObject [4] = CreateObject(19944, 617.5139, -590.3098, 16.2248, 0.0000, 0.0000, 90.0000); //BodyBag1
	MapObject [5] = CreateObject(19944, 617.5139, -589.3889, 16.2248, 0.0000, 0.0000, 91.1998); //BodyBag1
	MapObject [6] = CreateObject(19944, 617.4979, -588.2288, 16.2248, 0.0000, 0.0000, 88.0000); //BodyBag1
	MapObject [7] = CreateObject(19944, 617.5526, -586.6599, 16.2248, 0.0000, 0.0000, 124.5999); //BodyBag1
	MapObject [8] = CreateObject(19944, 617.4561, -585.1229, 16.2248, 0.0000, 0.0000, 93.6000); //BodyBag1
	MapObject [9] = CreateObject(19944, 617.3577, -584.2113, 16.2248, 0.0000, 0.0000, 78.7002); //BodyBag1
	MapObject [10] = CreateObject(19944, 619.1276, -583.7614, 16.2248, 0.0000, 0.0000, 78.3002); //BodyBag1
	MapObject [11] = CreateObject(19944, 619.6071, -585.6497, 16.2248, 0.0000, 0.0000, 173.0001); //BodyBag1
	MapObject [12] = CreateObject(19944, 619.3051, -588.0629, 16.2248, 0.0000, 0.0000, -165.6997); //BodyBag1
	MapObject [13] = CreateObject(19944, 619.6303, -592.8333, 16.2248, 0.0000, 0.0000, 92.7002); //BodyBag1
	MapObject [14] = CreateObject(19944, 613.7399, -592.8333, 16.2248, 0.0000, 0.0000, 90.0000); //BodyBag1
	MapObject [15] = CreateObject(19944, 613.7399, -591.7229, 16.2248, 0.0000, 0.0000, 96.5998); //BodyBag1
	MapObject [16] = CreateObject(19944, 613.6273, -590.7495, 16.2248, 0.0000, 0.0000, 82.3999); //BodyBag1
	MapObject [17] = CreateObject(19944, 613.7598, -589.7385, 16.2248, 0.0000, 0.0000, 87.8999); //BodyBag1
	MapObject [18] = CreateObject(19944, 613.7922, -588.7293, 16.2248, 0.0000, 0.0000, 93.0998); //BodyBag1
	MapObject [19] = CreateObject(1462, 610.0117, -582.6953, 17.2026, 0.0000, 0.0000, 0.0000); //DYN_woodpile
	MapObject [20] = CreateObject(3260, 611.0463, -582.2761, 17.7369, 0.0000, 0.0000, 0.0000); //oldwoodpanel
	MapObject [21] = CreateObject(1756, 613.5878, -583.6594, 16.2257, 0.0000, 0.0000, 0.0000); //LOW_COUCH_4
	MapObject [22] = CreateObject(19944, 614.0117, -587.7857, 16.2248, 0.0000, 0.0000, 93.0998); //BodyBag1
	MapObject [23] = CreateObject(19944, 613.7410, -586.8590, 16.2248, 0.0000, 0.0000, 83.7998); //BodyBag1
	MapObject [24] = CreateObject(19944, 615.7661, -587.3095, 16.2248, 0.0000, 0.0000, 11.9998); //BodyBag1
	MapObject [25] = CreateObject(19868, 607.3211, -585.5855, 17.1856, 0.0000, 0.0000, 90.0000); //MeshFence1
	MapObject [26] = CreateObject(19868, 607.3211, -590.8657, 17.1856, 0.0000, 0.0000, 90.0000); //MeshFence1
	MapObject [27] = CreateObject(1428, 610.7947, -593.1146, 16.2940, -74.0999, 0.0000, 88.9999); //DYN_LADDER
	MapObject [28] = CreateObject(19869, 611.2526, -582.3079, 17.1392, 0.0000, 0.0000, 0.0000); //MeshFence2
	MapObject [29] = CreateObject(1757, 618.8377, -595.7202, 16.2408, 0.0000, 0.0000, 90.1998); //LOW_COUCH_5
	MapObject [30] = CreateObject(16444, 611.9622, -597.3959, 16.4375, 0.0000, 0.0000, 0.0000); //des_blackbags
	MapObject [31] = CreateObject(16444, 615.3950, -601.8872, 16.4375, 0.0000, 0.0000, 64.9999); //des_blackbags
	MapObject [32] = CreateObject(19944, 615.4937, -595.7713, 16.2248, 0.0000, 0.0000, 92.7002); //BodyBag1
	MapObject [33] = CreateObject(19944, 615.8292, -596.7265, 16.2248, 0.0000, 0.0000, 90.5002); //BodyBag1
	MapObject [34] = CreateObject(19944, 615.8941, -597.7039, 16.2248, 0.0000, 0.0000, 93.8002); //BodyBag1
	MapObject [35] = CreateObject(19944, 615.7199, -599.0415, 16.2248, 0.0000, 0.0000, 107.7002); //BodyBag1
	MapObject [36] = CreateObject(2670, 634.4868, -581.2733, 15.4159, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_1
	MapObject [37] = CreateObject(2671, 633.1365, -582.9730, 15.3359, 0.0000, 0.0000, -19.6000); //PROC_RUBBISH_3
	MapObject [38] = CreateObject(2669, 633.1868, -610.7443, 16.6912, 0.0000, 0.0000, 180.0000); //CJ_CHRIS_CRATE
	MapObject [39] = CreateObject(1299, 623.3139, -612.9233, 16.5002, 0.0000, 8.2999, 0.0000); //smashboxpile
	MapObject [40] = CreateObject(3504, 619.4534, -612.9171, 17.5098, 0.0000, 0.0000, 0.0000); //vgsN_portaloo
	MapObject [41] = CreateObject(3504, 621.2234, -612.9271, 17.5098, 0.0000, 0.0000, -0.4999); //vgsN_portaloo
	MapObject [42] = CreateObject(1224, 618.6870, -606.6188, 16.7831, 0.0000, 0.0000, 0.0000); //woodenbox
	MapObject [43] = CreateObject(1220, 619.3750, -604.8679, 16.5312, 0.0000, 0.0000, -35.6999); //cardboardbox2
	MapObject [44] = CreateObject(1221, 619.0693, -608.7777, 16.6836, 0.0000, 0.0000, 0.0000); //cardboardbox4
	MapObject [45] = CreateObject(1230, 619.0490, -607.7779, 16.5331, 0.0000, 0.0000, -17.5000); //cardboardbox
	MapObject [46] = CreateObject(1413, 633.1817, -608.2240, 15.3790, 0.0000, -90.0000, 180.0000); //DYN_MESH_3
	MapObject [47] = CreateObject(1230, 628.3940, -613.0209, 15.8567, 0.0000, 8.4999, 0.4999); //cardboardbox
	MapObject [48] = CreateObject(1230, 628.0728, -612.2076, 15.8468, 0.0000, 8.4999, -26.5000); //cardboardbox
	MapObject [49] = CreateObject(1349, 632.8051, -592.9711, 15.8912, 0.0000, 0.0000, -64.1999); //CJ_SHTROLLY
	MapObject [50] = CreateObject(1349, 632.5755, -612.8097, 16.0212, 0.0000, 1.1999, -0.7999); //CJ_SHTROLLY
	MapObject [51] = CreateObject(1771, 633.8424, -611.1372, 15.8459, 0.0000, 0.0000, 0.0000); //CJ_bunk_bed1
	MapObject [52] = CreateObject(11474, 632.4213, -613.9483, 17.2688, 0.0000, 4.6000, 5.7999); //des_swtfence2
	MapObject [53] = CreateObject(11474, 635.2832, -613.9976, 17.2006, 0.0000, 4.6000, 5.7999); //des_swtfence2
	MapObject [54] = CreateObject(1761, 613.6334, -611.8588, 16.2194, 0.0000, 0.0000, 180.0000); //SWANK_COUCH_2
	MapObject [55] = CreateObject(2672, 619.3339, -596.6505, 16.4989, 0.0000, 0.0000, -64.5000); //PROC_RUBBISH_4
	MapObject [56] = CreateObject(2672, 630.6072, -607.0888, 15.6425, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_4
	MapObject [57] = CreateObject(2673, 631.1378, -606.3187, 15.4125, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_5
	MapObject [58] = CreateObject(2674, 635.6996, -606.7382, 15.3416, 0.0000, 0.0000, -35.6999); //PROC_RUBBISH_2
	MapObject [59] = CreateObject(2675, 637.4711, -599.1031, 15.3959, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_6
	MapObject [60] = CreateObject(2676, 632.3605, -599.1591, 15.4586, 0.0000, 0.0000, -29.2000); //PROC_RUBBISH_8
	MapObject [61] = CreateObject(2677, 634.0150, -593.9151, 15.6059, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_7
	MapObject [62] = CreateObject(1440, 637.4003, -608.5596, 15.8462, 0.0000, 0.0000, 0.0000); //DYN_BOX_PILE_3
	MapObject [63] = CreateObject(926, 638.4267, -609.4050, 15.6011, 0.0000, 0.0000, -2.4000); //RUBBISH_BOX2
	MapObject [64] = CreateObject(1440, 636.3746, -610.1533, 15.8462, 0.0000, 0.0000, 104.2999); //DYN_BOX_PILE_3
	MapObject [65] = CreateObject(933, 638.5217, -612.4221, 15.3070, 0.0000, 0.0000, 0.0000); //CJ_CABLEROLL
	MapObject [66] = CreateObject(849, 639.5621, -610.7559, 15.6459, 0.0000, 0.0000, 0.0000); //CJ_urb_rub_3
	MapObject [67] = CreateObject(2674, 640.6649, -612.1653, 15.3416, 0.0000, 0.0000, -35.6999); //PROC_RUBBISH_2
	MapObject [68] = CreateObject(2674, 641.8612, -610.5007, 15.3416, 0.0000, 0.0000, -133.6999); //PROC_RUBBISH_2
	MapObject [69] = CreateObject(1349, 640.1740, -609.6327, 15.6810, -91.2999, -27.4999, -64.1999); //CJ_SHTROLLY
	MapObject [70] = CreateObject(1764, 611.6516, -609.5296, 16.2312, 0.0000, 0.0000, 0.0000); //LOW_COUCH_2
	MapObject [71] = CreateObject(1756, 1678.1889, -1456.9304, 12.5263, 0.0000, 0.0000, 1.1000); //LOW_COUCH_4
	MapObject [72] = CreateObject(1757, 1676.1561, -1463.5096, 12.5346, 0.0000, 0.0000, 93.2998); //LOW_COUCH_5
	MapObject [73] = CreateObject(1763, 1677.7042, -1459.9323, 12.5436, 0.0000, 0.0000, 91.1998); //LOW_COUCH_1
	MapObject [74] = CreateObject(1413, 1675.4306, -1462.7945, 14.6399, 0.0000, 0.0000, 88.5998); //DYN_MESH_3
	MapObject [75] = CreateObject(1413, 1675.6394, -1458.8067, 14.1099, 0.0000, 0.0000, 88.5998); //DYN_MESH_3
	MapObject [76] = CreateObject(1800, 1680.8902, -1463.9830, 12.3454, 0.0000, 0.0000, 90.0000); //LOW_BED_1
	MapObject [77] = CreateObject(1413, 1686.1170, -1464.7094, 12.9699, 0.0000, -90.0000, 180.0000); //DYN_MESH_3
	MapObject [78] = CreateObject(939, 1687.3192, -1452.1782, 14.8439, 0.0000, 0.0000, 0.0000); //CJ_DF_UNIT
	MapObject [79] = CreateObject(2670, 1681.2965, -1459.7325, 12.6267, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_1
	MapObject [80] = CreateObject(2671, 1685.5440, -1460.0899, 12.5567, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_3
	MapObject [81] = CreateObject(2672, 1690.5930, -1457.8768, 12.8268, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_4
	MapObject [82] = CreateObject(2673, 1690.0133, -1463.3050, 12.6367, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_5
	MapObject [83] = CreateObject(2674, 1686.7805, -1457.2307, 12.5668, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_2
	MapObject [84] = CreateObject(2675, 1691.0428, -1460.8089, 12.6168, 0.0000, 0.0000, 78.2998); //PROC_RUBBISH_6
	MapObject [85] = CreateObject(2676, 1689.6510, -1454.5190, 12.6568, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_8
	MapObject [86] = CreateObject(1347, 1679.4453, -1459.1239, 13.1094, 0.0000, 0.0000, 0.0000); //CJ_WASTEBIN
	MapObject [87] = CreateObject(1369, 1685.2244, -1455.7889, 13.1261, 0.0000, 0.0000, 176.1000); //CJ_WHEELCHAIR1
	MapObject [88] = CreateObject(1369, 1683.4863, -1457.0906, 13.1261, 0.0000, 0.0000, 0.0000); //CJ_WHEELCHAIR1
	MapObject [89] = CreateObject(1338, 1689.1623, -1454.0031, 13.2445, 0.0000, 0.0000, 0.0000); //BinNt08_LA
	MapObject [90] = CreateObject(1460, 1686.6036, -1453.2779, 13.5526, 0.0000, 0.0000, 0.0000); //DYN_F_R_WOOD_3
	MapObject [91] = CreateObject(1412, 1689.7255, -1464.2027, 13.7472, 10.8999, 0.0000, 0.0000); //DYN_MESH_2
	MapObject [92] = CreateObject(1412, 1692.5147, -1452.2023, 14.3816, 90.0000, 0.0000, 0.0000); //DYN_MESH_2
	MapObject [93] = CreateObject(1412, 1692.5350, -1451.0212, 15.6416, 0.0000, 0.0000, 0.0000); //DYN_MESH_2
	MapObject [94] = CreateObject(1344, 1685.2227, -1463.8100, 13.3344, 0.0000, 0.0000, 180.0000); //CJ_Dumpster2
	MapObject [95] = CreateObject(1344, 1682.9135, -1463.7299, 13.3344, 0.0000, 0.0000, 179.1999); //CJ_Dumpster2
	MapObject [96] = CreateObject(1412, 1692.5350, -1453.3220, 15.6416, 0.0000, 0.0000, 180.0000); //DYN_MESH_2
	MapObject [97] = CreateObject(1760, 1685.1145, -1454.1604, 12.5397, 0.0000, 0.0000, 0.0000); //MED_COUCH_2
	return 1;
}

stock LoadLoginScreenMap ()
{
	LoadingScreenObject [0] = CreateDynamicObject(1437, -399.4962, -1439.1544, 23.2810, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [1] = CreateDynamicObject(1362, -396.5457, -1445.2365, 25.2874, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [2] = CreateDynamicObject(1413, -398.0162, -1437.7069, 25.9140, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [3] = CreateDynamicObject(1413, -391.2058, -1437.7669, 25.9640, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [4] = CreateDynamicObject(1761, -399.9760, -1433.2780, 24.6394, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [5] = CreateDynamicObject(1757, -392.2263, -1434.2005, 24.6943, 0.0000, 0.0000, -90.0000);
	LoadingScreenObject [6] = CreateDynamicObject(933, -396.4717, -1438.7702, 24.7019, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [7] = CreateDynamicObject(1217, -393.2814, -1444.8345, 25.1127, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [8] = CreateDynamicObject(1217, -392.6215, -1444.3140, 25.1127, 0.0000, 0.0000, 0.0000);
	LoadingScreenObject [9] = CreateDynamicObject(1217, -392.2716, -1443.5837, 25.1127, 0.0000, 0.0000, -70.4999);
	LoadingScreenObject [10] = CreateDynamicObject(1217, -393.1963, -1443.7677, 25.1127, 0.0000, 0.0000, -61.2000);
	LoadingScreenObject [11] = CreateDynamicObject(16317, -404.7207, -1437.0513, 22.4576, 0.0000, 0.0000, -48.0999);
	LoadingScreenObject [12] = CreateDynamicObject(337, -402.1390, -1439.7728, 25.5390, 0.0000, -147.5001, -57.3999);
	LoadingScreenObject [13] = CreateDynamicObject(1463, -392.3722, -1449.0629, 25.0287, 0.0000, 0.0000, 90.0000);

	LoadingScreenObject [14] = CreateDynamicObject(1647, -399.5667, -1436.1052, 24.6575, 0.0000, 0.0000, 88.2000);
	SetObjectMaterial(LoadingScreenObject [14], 0, -1, "none", "none", 0xFF808080);

	LoadingScreenObject [15] = CreateDynamicObject(1647, -399.5387, -1435.2153, 24.6575, 0.0000, 0.0000, 88.2000);
	SetObjectMaterial(LoadingScreenObject [15], 0, -1, "none", "none", 0xFF808080);

	LoadingScreenActor [0] = CreateDynamicActor(179, -397.2381, -1445.4995, 25.7265, -82.7000, 1, 100.0);
	ApplyDynamicActorAnimation(LoadingScreenActor [0], "DEALER", "DEALER_IDLE_01", 4.0999, 1, 0, 0, 0, 0);

	LoadingScreenActor [1] = CreateDynamicActor(15, -396.6787, -1444.3099, 25.7209, -175.0000, 1, 100.0);
	ApplyDynamicActorAnimation(LoadingScreenActor [1], "CASINO", "DEALONE", 4.0999, 1, 0, 0, 0, 0);

	LoadingScreenActor [2] = CreateDynamicActor(195, -395.6858, -1445.3226, 25.5865, 94.6999, 1, 100.0);
	ApplyDynamicActorAnimation(LoadingScreenActor [2], "DEALER", "DEALER_IDLE", 4.0999, 1, 0, 0, 0, 0);
	return 1;
}

RemovePlayerWeapon(playerid, weaponid)
{
    if(!IsPlayerConnected(playerid) || weaponid < 0 || weaponid > 50)
        return;
    new saveweapon[13], saveammo[13];
    for(new slot = 0; slot < 13; slot++)
        GetPlayerWeaponData(playerid, slot, saveweapon[slot], saveammo[slot]);
    ResetPlayerWeapons(playerid);
    for(new slot; slot < 13; slot++)
    {
        if(saveweapon[slot] == weaponid || saveammo[slot] == 0)
            continue;
        GivePlayerWeapon(playerid, saveweapon[slot], saveammo[slot]);
    }
}

WasteDeAMXersTime()
{
    new b;
    #emit load.pri b
    #emit stor.pri b
}
