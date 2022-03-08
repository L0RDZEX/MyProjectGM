/* ----- [ REGISTER & LOGIN SYSTEM ] ----- */

function OnPlayerDataLoaded(playerid)
{
	new string[115];
	if(cache_num_rows() > 0)
	{
		cache_get_value(0, "pPassword", pStruct[playerid][pPassword], 65);
		cache_get_value(0, "pSalt", pStruct[playerid][pSalt], 17);

		// saves the active cache in the memory and returns an cache-id to access it for later use
		pStruct[playerid][Cache_ID] = cache_save();

		format(string, sizeof string, "This account (%s) is registered. Please login by entering your password in the field below:", pStruct[playerid][pUsername]);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Abort");

		// from now on, the player has 30 seconds to login
		// pStruct[playerid][LoginTimer] = SetTimerEx("OnLoginTimeout", SECONDS_TO_LOGIN * 1000, false, "d", playerid);
	}
	else
	{
		format(string, sizeof string, "Welcome %s, you can register by entering your password in the field below:", pStruct[playerid][pUsername]);
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", string, "Register", "Abort");
	}
	return 1;
}

function OnPlayerRegister(playerid)
{
	// retrieves the ID generated for an AUTO_INCREMENT column by the sent query
	pStruct[playerid][pID] = cache_insert_id();

	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Registration", "Account successfully registered, you have been automatically logged in.", "Okay", "");

	pStruct[playerid][IsLoggedIn] = true;

	pStruct[playerid][pPosx] = DEFAULT_POS_X;
	pStruct[playerid][pPosy] = DEFAULT_POS_Y;
	pStruct[playerid][pPosz] = DEFAULT_POS_Z;
	pStruct[playerid][pPosa] = DEFAULT_POS_A;

	SetSpawnInfo(playerid, NO_TEAM, 0, pStruct[playerid][pPosx], pStruct[playerid][pPosy], pStruct[playerid][pPosz], pStruct[playerid][pPosa], 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}

AssignPlayerData(playerid)
{
	cache_get_value_int(0, "pID", pStruct[playerid][pID]);

	cache_get_value_float(0, "pPosx", pStruct[playerid][pPosx]);
	cache_get_value_float(0, "pPosy", pStruct[playerid][pPosy]);
	cache_get_value_float(0, "pPosz", pStruct[playerid][pPosz]);
	cache_get_value_float(0, "pPosa", pStruct[playerid][pPosa]);
	cache_get_value_int(0, "pInterior", pStruct[playerid][pInterior]);
	return 1;
}

UpdatePlayerData(playerid)
{
	if (pStruct[playerid][IsLoggedIn] == false) return 0;

	new query[145];
	mysql_format(g_SQL, query, sizeof query, "UPDATE `players` SET `pPosx` = %f, `pPosy` = %f, `pPosz` = %f, `pPosa` = %f, `pInterior` = %d WHERE `id` = %d LIMIT 1", pStruct[playerid][pPosx], pStruct[playerid][pPosy], pStruct[playerid][pPosz], pStruct[playerid][pPosa], GetPlayerInterior(playerid), pStruct[playerid][pID]);
	mysql_tquery(g_SQL, query);
	return 1;
}

function _KickPlayerDelayed(playerid)
{
	Kick(playerid);
	return 1;
}

DelayedKick(playerid, time = 500)
{
	SetTimerEx("_KickPlayerDelayed", time, false, "d", playerid);
	return 1;
}