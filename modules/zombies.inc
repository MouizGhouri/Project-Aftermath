

#define MAX_ZOMBIES 1000
#define MAX_ZONES 12

enum zombie_data
{
	zone_id,
	zombie_type,
	spawned,
	chasing,
	Float: chasing_range,
	
	finding_iterations,
	waiting_timer
};

enum actor_inventory
{
	item [124]
};

new Float:LosSantos [] = {
	2588.0,-2604.0,2900.0,-2568.0,2972.0,-2056.0,2952.0,-588.0,2932.0,136.0,2804.0,396.0,2204.0,492.0,1556.0,528.0,1320.0,588.0,1160.0,624.0,
	964.0,624.0,440.0,388.0,236.0,172.0,72.0,176.0,-104.0,292.0,-332.0,332.0,-680.0,312.0,-888.0,148.0,-960.0,-60.0,-1052.0,-160.0,
	-1012.0,-248.0,-952.0,-312.0,-808.0,-316.0,-588.0,-300.0,-460.0,-328.0,-380.0,-308.0,-236.0,-412.0,-84.0,-596.0,-160.0,-804.0,-108.0,-904.0,
	84.0,-912.0,60.0,-1080.0,112.0,-1156.0,88.0,-1204.0,64.0,-1280.0,52.0,-1540.0,52.0,-1676.0,112.0,-1816.0,104.0,-1988.0,380.0,-2128.0,
	916.0,-2120.0,1008.0,-2376.0,1212.0,-2540.0,1320.0,-2788.0,2164.0,-2796.0,2548.0,-2724.0,2588.0,-2604.0
};

new Float: Zone_0 [] = {
	2595.0,52.0,2594.0,31.0,2569.0,31.0,2568.0,-16.0,2524.0,-19.0,2523.0,-48.0,2454.0,-50.0,2453.0,-75.0,2356.0,-76.0,2355.0,-106.0,
	2332.0,-107.0,2333.0,-145.0,2234.0,-145.0,2234.0,-108.0,2213.0,-100.0,2176.0,-101.0,2175.0,-25.0,2176.0,52.0,2183.0,117.0,2220.0,149.0,
	2221.0,191.0,2271.0,190.0,2272.0,183.0,2296.0,183.0,2304.0,203.0,2323.0,222.0,2357.0,222.0,2383.0,203.0,2408.0,133.0,2447.0,147.0,
	2548.0,147.0,2571.0,102.0,2595.0,52.0
};

new Float:Zone_1 [] = {
	1229.0,113.0,1311.0,128.0,1400.0,192.0,1431.0,211.0,1442.0,238.0,1431.0,278.0,1525.0,361.0,1502.0,399.0,1419.0,465.0,1356.0,493.0,
	1303.0,419.0,1221.0,368.0,1190.0,297.0,1182.0,231.0,1185.0,146.0,1229.0,113.0
};

new Float:Zone_2 [] = {
	861.0,-636.0,871.0,-612.0,870.0,-577.0,831.0,-481.0,727.0,-435.0,651.0,-437.0,591.0,-475.0,591.0,-541.0,607.0,-614.0,655.0,-652.0,
	861.0,-636.0
};

new Float:Zone_3 [] = {
	270.0,-315.0,326.0,-258.0,378.0,-160.0,379.0,-61.0,337.0,-10.0,354.0,62.0,349.0,68.0,334.0,70.0,240.0,55.0,201.0,43.0,
	135.0,-8.0,123.0,-76.0,79.0,-147.0,77.0,-203.0,17.0,-219.0,-236.0,-175.0,-251.0,-214.0,-249.0,-249.0,-117.0,-392.0,18.0,-397.0,
	18.0,-344.0,203.0,-345.0,270.0,-315.0
};

new Float:Zone_4 [] = {
	-21.0,-1122.0,-41.0,-1160.0,-56.0,-1158.0,-83.0,-1222.0,-104.0,-1217.0,-99.0,-1201.0,-121.0,-1194.0,-78.0,-1098.0,-21.0,-1122.0
};

new Float:Zone_5 [] = {
	-631.0,-1300.0,-665.0,-1689.0,-707.0,-1725.0,-775.0,-1692.0,-776.0,-1296.0,-745.0,-1258.0,-684.0,-1292.0,-631.0,-1300.0
};

new Float:Zone_6 [] = {
	-303.0,-2140.0,-259.0,-2138.0,-253.0,-2174.0,-246.0,-2249.0,-308.0,-2269.0,-344.0,-2158.0,-303.0,-2140.0
};

new Float:Zone_7 [] = {
	148.0,-1743.0,346.0,-1741.0,384.0,-1777.0,463.0,-1751.0,642.0,-1776.0,711.0,-1809.0,711.0,-1916.0,398.0,-1908.0,399.0,-1933.0,380.0,-1933.0,
	380.0,-2011.0,400.0,-2013.0,400.0,-2047.0,408.0,-2047.0,410.0,-2089.0,348.0,-2089.0,348.0,-2047.0,359.0,-2047.0,359.0,-2038.0,352.0,-2038.0,
	352.0,-2024.0,359.0,-2024.0,360.0,-1902.0,167.0,-1892.0,165.0,-1935.0,177.0,-1951.0,166.0,-1970.0,142.0,-1972.0,130.0,-1952.0,143.0,-1934.0,
	148.0,-1743.0
};

new Float:Zone_8 [] = {
	2764.0,-2187.0,2764.0,-2251.0,2811.0,-2330.0,2810.0,-2566.0,2775.0,-2581.0,2721.0,-2581.0,2666.0,-2566.0,2526.0,-2697.0,2482.0,-2713.0,2427.0,-2713.0,
	2374.0,-2698.0,2275.0,-2706.0,2148.0,-2705.0,2150.0,-2657.0,2170.0,-2631.0,2184.0,-2589.0,2186.0,-2504.0,2185.0,-2433.0,2204.0,-2384.0,2294.0,-2293.0,
	2391.0,-2205.0,2432.0,-2183.0,2764.0,-2187.0
};

new Float:Zone_9 [] = {
	1753.0,-1601.0,1420.0,-1601.0,1448.0,-1430.0,1723.0,-1432.0,1753.0,-1601.0
};

new Float:Zone_10 [] = {
	2849.0,-265.0,2592.0,-331.0,2676.0,-455.0,2914.0,-566.0,2849.0,-265.0
};

new Float:Zone_11 [] = {
	1687.0,-262.0,1692.0,-374.0,1715.0,-483.0,1740.0,-499.0,1727.0,-638.0,1709.0,-773.0,1717.0,-816.0,1663.0,-795.0,1695.0,-667.0,1694.0,-563.0,
	1684.0,-473.0,1663.0,-370.0,1651.0,-289.0,1652.0,-177.0,1687.0,-262.0
};

new Float:SAFEZONE_1[] = {
	1192.0,-1411.0,1193.0,-1568.0,1047.0,-1561.0,1068.0,-1469.0,1072.0,-1436.0,1081.0,-1422.0,1094.0,-1415.0,1112.0,-1415.0,1146.0,-1414.0,1186.0,-1413.0,
	1192.0,-1411.0
};

new Float:SAFEZONE_2[] = {
	-377.0,2287.0,-333.0,2215.0,-369.0,2198.0,-410.0,2195.0,-425.0,2207.0,-467.0,2217.0,-454.0,2249.0,-426.0,2267.0,-377.0,2287.0
};

new Float: ZombieSpawns [MAX_ZONES][3] =
{
	{2343.9121,90.5595,26.3331},
	{1301.6693,276.5026,19.4063},
	{702.0027,-530.1036,16.1875},
    {182.9420,-211.8336,1.4237},
    {-102.0135,-1134.4237,1.1879},
    {-699.3594,-1487.8849,59.5143},
    {-279.3636,-2191.5967,28.6872},
    {316.4325,-1798.5173,4.6077},
    {2488.6072,-2511.6565,13.5718},
    {0.0000,0.0000,0.0000},
    {2883.7402,-532.0021,13.5521},
    {1704.8387,-683.8581,45.2792}
};

new Float: ZombieSpawns_9 [9][3] =
{
	{1600.7609,-1501.5806,37.4873},
	{1605.0305,-1464.5475,28.5859},
	{1592.9744,-1563.2410,28.5859},
	{1636.9594,-1536.6499,22.2934},
	{1559.0426,-1470.1554,26.2548},
	{1546.5002,-1441.0786,13.3828},
	{1662.9346,-1441.5476,13.3828},
	{1657.6051,-1594.1250,13.3931},
	{1551.6973,-1593.1128,13.3828}
};

new PoliceZombies [3] = { 279, 284, 285 };
new CivilianZombies [7] = { 77, 78, 134, 137, 159, 162, 200 };
new MixZombies [10] = { 77, 78, 134, 137, 159, 162, 200, 279, 284, 285 };

new Z_Zone [12],
	SafeZone_1,
	SafeZone_2,
	LS;

new Float:WeaponDamage [42][1] =
{
	{5.0},
	{10.0},
	{15.0},
	{16.0},
	{20.0},
	{20.0},
	{18.0},
	{22.0},
	{26.0},
	{18.0},
	{5.0},
	{50.0},
	{100.0},
	{100.0},
	{1.0},
	{12.0},
	{100.0},
	{20.0},
	{30.0},
	{15.0},
	{45.0},
	{50.0},
	{35.0},
	{30.0},
	{10.0},
	{15.0},
	{35.0},
	{35.0},
	{12.0},
	{70.0},
    {25.0},
	{25.0},
	{20.0},
	{30.0},
	{100.0},
	{100.0},
	{100.0},
	{5.0},
	{10.0},
	{0.0},
	{0.0},
	{0.0}
};

new ZombieItems [5][24] =
{
	{"1 0 3 -1 -1"},
	{"1 0 5 -1 -1"},
	{"1 8 3 -1 -1"},
	{"2 2 3 100 -1"},
	{"10 0 1 50 -1"}
};

new ZombieInfo [MAX_ZOMBIES][zombie_data];
new Zombies;

new ActorInventory [MAX_ACTORS][MAX_SLOTS][actor_inventory];
new ActorSlotsUsed [MAX_ACTORS];

public FCNPC_OnSpawn (npcid)
{
	ZombieInfo [npcid][spawned] = 1;
	return 1;
}

public FCNPC_OnRespawn (npcid)
{
    ZombieInfo [npcid][spawned] = 1;

	FCNPC_SetHealth (npcid, 100.0);
	
    switch (ZombieInfo [npcid][zone_id])
	{
		case 9:
		{
		    new place = random (9);
		    FCNPC_SetPosition (npcid, ZombieSpawns_9 [place][0], ZombieSpawns_9 [place][1], ZombieSpawns_9 [place][2]);
		}
		default: FCNPC_SetPosition (npcid, ZombieSpawns [ZombieInfo [npcid][zone_id]][0], ZombieSpawns [ZombieInfo [npcid][zone_id]][1], ZombieSpawns [ZombieInfo [npcid][zone_id]][2]);
	}
    
    FindGoToPoint (npcid);
	return 1;
}

public FCNPC_OnDeath (npcid)
{
	// FCNPC_ApplyAnimation (npcid, "PED", "KO_shot_stom", 4.1, 0, 1, 1, 1, 1);

	ZombieInfo [npcid][spawned] = 0;

	new Float: x, Float: y, Float: z,
	    Float: fa,
	    
	    actorid,
	    
	    selected_random_item,
	    
	    number_of_items = random (4);

	FCNPC_GetPosition (npcid, x, y, z);
	fa = FCNPC_GetAngle (npcid);
	
	actorid = CreateActor (FCNPC_GetSkin (npcid), x, y, z, fa);
	SetActorVirtualWorld (actorid, 1);
	
	ApplyActorAnimation (actorid, "PED", "KO_SHOT_STOM", 10.0, 0, 1, 1, 1, 1);
	
	if (number_of_items == 0) { number_of_items++; }
	
	for (new i = 0; i < number_of_items; i++)
	{
	    selected_random_item = random (sizeof (ZombieItems));
	    format (ActorInventory [actorid][i][item], 124, ZombieItems [selected_random_item]);
	    ActorSlotsUsed [actorid]++;
	}
	
	SetTimerEx ("DelayedRespawn", 100, false, "i", npcid);
	
	if (ZombieInfo [npcid][chasing] != -1 && ZombieInfo [npcid][chasing] != INVALID_PLAYER_ID)
	{
	    if (IsPlayerConnected (ZombieInfo [npcid][chasing]))
	    {
		    PlayerInfo [ZombieInfo [npcid][chasing]][getting_chased] = -1;
		    PlayerInfo [ZombieInfo [npcid][chasing]][zombies_chasing]--;
		    PlayerInfo [ZombieInfo [npcid][chasing]][player_zombies]--;

			ZombieInfo [npcid][chasing] = -1;
			ZombieInfo [npcid][chasing_range] = 25.0;
		}
	}
	return 1;
}

forward DelayedRespawn (npcid);
public DelayedRespawn (npcid)
{
    if (ZombieInfo [npcid][zone_id] != -1)
	{
		FCNPC_Respawn (npcid);
	}
	else
	{
	    FCNPC_Destroy (npcid);
	    ZombieInfo [npcid][zone_id] = -1;
		ZombieInfo [npcid][zombie_type] = -1;
		ZombieInfo [npcid][spawned] = 0;
		if (ZombieInfo [npcid][chasing] != -1) { PlayerInfo [ZombieInfo [npcid][chasing]][zombies_chasing]--; ZombieInfo [npcid][chasing] = -1; }
		ZombieInfo [npcid][chasing_range] = 25.0;
	}
	return 1;
}

public FCNPC_OnDestroy(npcid)
{
	Zombies--;
	return 1;
}

public FCNPC_OnTakeDamage(npcid, issuerid, Float:amount, weaponid, bodypart)
{
	if (IsPlayerConnected (issuerid) && issuerid != INVALID_PLAYER_ID)
	{
	    if (bodypart != 9)
	    {
		    new Float: new_health = (FCNPC_GetHealth (npcid) - WeaponDamage [weaponid][0]);

		    if (new_health < 0.0) { new_health = 0.0; }

			FCNPC_SetHealth (npcid, new_health);
			
			ZombieInfo [npcid][chasing] = issuerid;
			ZombieInfo [npcid][chasing_range] = 300.0;
			
			new Float: x, Float: y, Float: z;
			GetPlayerPos (issuerid, x, y, z);
			
			FCNPC_GoTo (npcid, x, y, z, FCNPC_MOVE_TYPE_SPRINT, FCNPC_MOVE_SPEED_SPRINT);
			
		}
		else FCNPC_SetHealth (npcid, 0.0);
	}
	return 1;
}

public FCNPC_OnReachDestination (npcid)
{
    new Float: z_x, Float: z_y, Float: z_z;
    FCNPC_GetPosition (npcid, z_x, z_y, z_z);
    
    if (ZombieInfo [npcid][chasing] != -1) // Chasing
    {
        new Float: x, Float: y, Float: z,
			Float: zx, Float: zy, Float: zz;

	    FCNPC_GetPosition (npcid, zx, zy, zz);
	    GetPlayerPos (ZombieInfo [npcid][chasing], x, y, z);
	    
		if (((zz - z) < -0.75)
		
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
	    
	    if (IsPlayerInAnyVehicle (ZombieInfo [npcid][chasing]))
	    {
			if (IsPlayerInRangeOfPoint (ZombieInfo [npcid][chasing], 5.0, zx, zy, zz))
			{
				new calculation,
				 	Float: new_x, Float: new_y, Float: new_z;
				
				calculation = random (2);

				if (calculation == 0)
				{ new_x += 1.25; }
				else if (calculation == 1)
				{ new_x -= 1.25; }
				
				calculation = random (2);

				if (calculation == 0)
				{ new_y += 1.25; }
				else if (calculation == 1)
				{ new_y -= 1.25; }

				MapAndreas_FindZ_For2DCoord (new_x, new_y, new_z);
                FCNPC_GoTo (npcid, new_x, new_y, new_z, FCNPC_MOVE_TYPE_SPRINT, FCNPC_MOVE_SPEED_SPRINT);
                if (IsPlayerInRangeOfPoint (ZombieInfo [npcid][chasing], 4.0, zx, zy, zz)) { FCNPC_MeleeAttack (npcid, 1000); new Float: v_h; GetVehicleHealth (GetPlayerVehicleID (ZombieInfo [npcid][chasing]), v_h); SetVehicleHealth (GetPlayerVehicleID (ZombieInfo [npcid][chasing]), (v_h - 50.0));  } else { FCNPC_StopAttack (npcid); }
			}
	    }
	    else
	    {
	        FCNPC_GoTo (npcid, x, y, z, FCNPC_MOVE_TYPE_SPRINT, FCNPC_MOVE_SPEED_SPRINT);
	        if (IsPlayerInRangeOfPoint (ZombieInfo [npcid][chasing], 2.5, zx, zy, zz)) { FCNPC_MeleeAttack (npcid, 1000); } else { FCNPC_StopAttack (npcid); }
	    }
    }
    else if (ZombieInfo [npcid][chasing] == -1) // Not Chasing
    {
        if (ZombieInfo [npcid][zone_id] != -1) { if (!IsPointInDynamicArea (Z_Zone [ZombieInfo [npcid][zone_id]], z_x, z_y, z_z)) { ReturnPath (npcid); FCNPC_StopAttack (npcid); return 0; } }
        else { if (!IsPointInDynamicArea (LS, z_x, z_y, z_z)) return 0; }
        
        FindGoToPoint (npcid);
        FCNPC_StopAttack (npcid);
    }
	return 1;
}

forward OnZombieDetectHeight (npcid);
public OnZombieDetectHeight (npcid)
{
	new Float: x, Float: y, Float: z,

		Float: px, Float: py, Float: pz,

	    Float: new_x, Float: new_y, Float: new_z,

	    calculation [2];

	
	for (new i = 0; i < 7; i++)
	{

        GetPlayerPos (ZombieInfo [npcid][chasing], px, py, pz);

		FCNPC_AimAtPlayer (npcid, ZombieInfo [npcid][chasing]);
		FCNPC_MeleeAttack (npcid, 1000);

		FCNPC_GetPosition (npcid, x, y, z);

	    new_x = (random (3) * 1.0);
	    new_y = (random (3) * 1.0);

		calculation [0] = random (2);
		calculation [1] = random (2);

		switch (calculation [0])
		{
		    case 0: new_x = (x + new_x);
		    case 1: new_x = (x - new_x);
		}

		switch (calculation [1])
		{
		    case 0: new_y = (y + new_y);
		    case 1: new_y = (y - new_y);
		}

	   	MapAndreas_FindZ_For2DCoord (new_x, new_y, new_z);

		if (IsPointInDynamicArea (SafeZone_1, new_x, new_y, new_z)) { continue; }
	    if (IsPointInDynamicArea (SafeZone_2, new_x, new_y, new_z)) { continue; }

		if (ZombieInfo [npcid][finding_iterations] < 7)
		{
		    ZombieInfo [npcid][finding_iterations]++;

		    if (new_z == 0.0) { continue; }
		    if ((z - new_z) < -1.0 || (z - new_z) > 1.0) { continue; }
	    }
	    else { ZombieInfo [npcid][finding_iterations] = 0; }

		FCNPC_GoTo (npcid, new_x, new_y, (new_z + 1.25), FCNPC_MOVE_TYPE_WALK, FCNPC_MOVE_SPEED_WALK);
		
	}
	
    // FCNPC_ApplyAnimation (npcid, "PED", "WALK_DRUNK", 4.1, 1, 0, 0, 0);
	return 1;
}

stock GetDistance( Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2 ){ return floatround( floatsqroot( ( ( x1 - x2 ) * ( x1 - x2 ) ) + ( ( y1 - y2 ) * ( y1 - y2 ) ) + ( ( z1 - z2 ) * ( z1 - z2 ) ) )  ); }

stock randomEx(min, max)
{
    new rand = random(max-min)+min;
    return rand;
}


forward CheckPlayers ();
public CheckPlayers ()
{
	new in_red;
	
	if (SERVER_SLOTS <= 150) return 0;
	
	foreach (new playerid : Player)
	{
	    if (
	    
	       (PlayerInfo [playerid][walking] == 1)
	    || (PlayerInfo [playerid][sprinting] == 0)

	    || (PlayerInfo [playerid][zombies_chasing] >= 2)
		|| (PlayerInfo [playerid][player_zombies] >= 2)

		|| (GetPlayerSpecialAction (playerid) == SPECIAL_ACTION_DUCK)
	    
		|| (IsPlayerInDynamicArea (playerid, SafeZone_1))
		|| (IsPlayerInDynamicArea (playerid, SafeZone_2))

		) { continue; }
	
	    in_red = 0;
	    
	    if (IsPlayerInDynamicArea (playerid, LS))
	    {
			for (new i = 0; i < MAX_ZONES; i++)
			{
			    if (IsPlayerInDynamicArea (playerid, Z_Zone [i]))
			    {
			        in_red = 1;
			    }
			}
			
			if (!in_red)
			{
			
			    new Float: x, Float: y, Float: z,
			        Float: new_x, Float: new_y, Float: new_z,
			        zid, zombie_name [24],
			        z_skin, z_type;
			    
				GetPlayerPos (playerid, x, y, z);
    			
    			new_x = (x + (randomEx (13, 15) * 1.0));
    			new_y = (y + (randomEx (13, 15) * 1.0));

    			MapAndreas_FindZ_For2DCoord (new_x, new_y, new_z);

				new_x += 1.25;

				if ((z - new_z) < -1.0) { continue; }

    			format (zombie_name, sizeof (zombie_name), "Zombie_%d", Zombies);
    			zid = FCNPC_Create (zombie_name);
    			SetPlayerColor (zid, 0xFFFFFF00);
    			Zombies++;

				switch (z_type)
				{
					case 0: z_skin = CivilianZombies [random (7)];
					case 1: z_skin = PoliceZombies [random (3)];
					case 2: z_skin = MixZombies [random (10)];
				}

				FCNPC_Spawn (zid, z_skin, new_x, new_y, new_z);

                ZombieInfo [zid][spawned] = 1;
                ZombieInfo [zid][zone_id] = -1;
                
    			ZombieInfo [zid][chasing] = playerid;
    			ZombieInfo [zid][chasing_range] = 100.0;

                ZombieInfo [zid][zombie_type] = z_type;

				FCNPC_SetHealth (zid, 100.0);
				
				FCNPC_SetInterior (zid, 0);
				FCNPC_SetVirtualWorld (zid, 1);
				
				PlayerInfo [playerid][player_zombies]++;
				PlayerInfo [playerid][zombies_chasing]++;
				
				FCNPC_ClearAnimations (zid);
				FCNPC_GoTo (zid, x, y, z, FCNPC_MOVE_TYPE_SPRINT, FCNPC_MOVE_SPEED_SPRINT);
			}
	    }
	}
	return 1;
}


forward CreateZombies ();
public CreateZombies ()
{

    new z_id,
	    z_type,
	    z_skin,
		iterations,
		npc_name [24];

    LS = CreateDynamicPolygon (LosSantos);

	Z_Zone [0] = CreateDynamicPolygon (Zone_0);
	Z_Zone [1] = CreateDynamicPolygon (Zone_1);
	Z_Zone [2] = CreateDynamicPolygon (Zone_2);
	Z_Zone [3] = CreateDynamicPolygon (Zone_3);
	Z_Zone [4] = CreateDynamicPolygon (Zone_4);
	Z_Zone [5] = CreateDynamicPolygon (Zone_5);
	Z_Zone [6] = CreateDynamicPolygon (Zone_6);
	Z_Zone [7] = CreateDynamicPolygon (Zone_7);
	Z_Zone [8] = CreateDynamicPolygon (Zone_8);
	Z_Zone [9] = CreateDynamicPolygon (Zone_9);
	Z_Zone [10] = CreateDynamicPolygon (Zone_10);
	Z_Zone [11] = CreateDynamicPolygon (Zone_11);
	
	SafeZone_1 = CreateDynamicPolygon (SAFEZONE_1);
	SafeZone_2 = CreateDynamicPolygon (SAFEZONE_2);
	
	for (new n = 0; n < MAX_ZONES; n++)
	{
	    switch (n)
	    {
	        case  0: iterations = 35; // 35
	        case  1: iterations = 30; // 30
	        case  2: iterations = 25; // 25
	        case  3: iterations = 35; // 35
	        case  4: iterations = 20; // 20
	        case  5: iterations = 20; // 20
	        case  6: iterations = 10;  // 10
	        case  7: iterations = 40; // 40
	        case  8: iterations = 50; // 50
	        case  9: iterations = 40; // 40
	        case 10: iterations = 35; // 35
	        case 11: iterations = 75; // 75
	    }

		
	    for (new i = 0; i < iterations; i++)
		{
		    format (npc_name, sizeof (npc_name), "Zombie_%d", Zombies);
		    z_id = FCNPC_Create (npc_name);
		    SetPlayerColor (z_id, 0xFFFFFF00);
		    Zombies++;

		    ZombieInfo [z_id][zone_id] = n;

			switch (z_type)
			{
				case 0: z_skin = CivilianZombies [random (7)];
				case 1: z_skin = PoliceZombies [random (3)];
				case 2: z_skin = MixZombies [random (10)];
			}

			switch (n)
			{
				case 9:
				{
				    new place = random (9);

				    FCNPC_Spawn (z_id, z_skin, ZombieSpawns_9 [place][0], ZombieSpawns_9 [place][1], ZombieSpawns_9 [place][2]);
				}
				default: FCNPC_Spawn (z_id, z_skin, ZombieSpawns [n][0], ZombieSpawns [n][1], ZombieSpawns [n][2]);
			}

            ZombieInfo [z_id][spawned] = 1;
            ZombieInfo [z_id][zombie_type] = z_type;
            ZombieInfo [z_id][chasing] = -1;

			FCNPC_SetHealth (z_id, 100.0);
			FCNPC_SetInterior (z_id, 0);
			FCNPC_SetVirtualWorld (z_id, 1);
			
			FindGoToPoint (z_id);
		}
		
	}
	
    SetTimer ("SetServerInfo",   500, false);
    SetTimer ("CheckPlayers", 5 * 1000, true);
    SetTimer ("OnZombieCheckSurroundings", 1000, true);
	SendRconCommand ("hostname SERVER: Unlocking Server "SERVER_NAME_TAG"");
	return 1;
}

stock FindGoToPoint (npcid)
{
	new Float: x, Float: y, Float: z,

	    Float: new_x, Float: new_y, Float: new_z,

	    calculation [2];

	FCNPC_StopAttack (npcid);
	FCNPC_GetPosition (npcid, x, y, z);

    new_x = (random (12) * 1.0);
    new_y = (random (12) * 1.0);

	calculation [0] = random (2);
	calculation [1] = random (2);

	switch (calculation [0])
	{
	    case 0: new_x = (x + new_x);
	    case 1: new_x = (x - new_x);
	}

	switch (calculation [1])
	{
	    case 0: new_y = (y + new_y);
	    case 1: new_y = (y - new_y);
	}

   	MapAndreas_FindZ_For2DCoord (new_x, new_y, new_z);

	if (IsPointInDynamicArea (SafeZone_1, new_x, new_y, new_z)) return FindGoToPoint (npcid);
    if (IsPointInDynamicArea (SafeZone_2, new_x, new_y, new_z)) return FindGoToPoint (npcid);

	if (ZombieInfo [npcid][finding_iterations] < 7)
	{
	    ZombieInfo [npcid][finding_iterations]++;
	    
	    if (new_z == 0.0) return FindGoToPoint (npcid);
	    if ((z - new_z) < -1.5 || (z - new_z) > 1.5) return FindGoToPoint (npcid);
    }
    else { ZombieInfo [npcid][finding_iterations] = 0; }
    
    if (ZombieInfo [npcid][zone_id] != -1)
    {
    	if (!IsPointInDynamicArea (Z_Zone [ZombieInfo [npcid][zone_id]], new_x, new_y, new_z)) return FindGoToPoint (npcid);
    }
    /*
    else
    {
        if(!IsPointInDynamicArea (LS, new_x, new_y, new_z)) return FindGoToPoint (npcid);
    }
    */

    FCNPC_ApplyAnimation (npcid, "PED", "WALK_DRUNK", 4.1, 1, 0, 0, 0);
	FCNPC_GoTo (npcid, new_x, new_y, (new_z + 1.25), FCNPC_MOVE_TYPE_WALK, FCNPC_MOVE_SPEED_WALK);
	return 1;
}

stock SetNPCLookAt(npcid, Float:x, Float:y)
{
	new Float:Px, Float:Py, Float: Pa;
	FCNPC_GetPosition (npcid, Px, Py, Pa);
	Pa = floatabs(atan((y-Py)/(x-Px)));
	if (x <= Px && y >= Py) Pa = floatsub(180, Pa);
	else if (x < Px && y < Py) Pa = floatadd(Pa, 180);
	else if (x >= Px && y <= Py) Pa = floatsub(360.0, Pa);
	Pa = floatsub(Pa, 90.0);
	if (Pa >= 360.0) Pa = floatsub(Pa, 360.0);
	FCNPC_SetAngle (npcid, Pa);
}

stock ReturnPath (npcid)
{
    FCNPC_Stop (npcid);

	new Float: new_x, Float: new_y, Float: new_z,
	    Float: a;
		
	switch (ZombieInfo [npcid][zone_id])
	{
		case 9: SetNPCLookAt (npcid, ZombieSpawns_9 [0][0], ZombieSpawns_9 [0][1]);
		default: SetNPCLookAt (npcid, ZombieSpawns [ZombieInfo [npcid][zone_id]][0], ZombieSpawns [ZombieInfo [npcid][zone_id]][1]);
	}

	a = FCNPC_GetAngle (npcid);
	
	FCNPC_GetPosition (npcid, new_x, new_y, new_z);
	
	new_x += (5.0 * floatsin(-a, degrees));
    new_y += (5.0 * floatcos(-a, degrees));
    
    MapAndreas_FindZ_For2DCoord (new_x, new_y, new_z);

	FCNPC_GoTo (npcid, new_x, new_y, (new_z + 1.25), FCNPC_MOVE_TYPE_RUN, FCNPC_MOVE_SPEED_RUN);

	return 1;
}

