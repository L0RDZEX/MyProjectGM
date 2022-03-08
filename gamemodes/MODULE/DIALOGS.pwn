/* ----- [ DIALOGS SYSTEM ] ----- */

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
		case DIALOG_UNUSED: return 1; // Useful for dialogs that contain only information and we do nothing depending on whether they responded or not

		case DIALOG_LOGIN:
		{
			if (!response) return Kick(playerid);

			new hashed_pass[65];
			SHA256_PassHash(inputtext, pStruct[playerid][pSalt], hashed_pass, 65);

			if (strcmp(hashed_pass, pStruct[playerid][pPassword]) == 0)
			{
				//correct password, spawn the player
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have been successfully logged in.", "Okay", "");

				// sets the specified cache as the active cache so we can retrieve the rest player data
				cache_set_active(pStruct[playerid][Cache_ID]);

				AssignPlayerData(playerid);

				// remove the active cache from memory and unsets the active cache as well
				cache_delete(pStruct[playerid][Cache_ID]);
				pStruct[playerid][Cache_ID] = MYSQL_INVALID_CACHE;

				KillTimer(pStruct[playerid][LoginTimer]);
				pStruct[playerid][LoginTimer] = 0;
				pStruct[playerid][IsLoggedIn] = true;

				// spawn the player to their last saved position after login
				SetSpawnInfo(playerid, NO_TEAM, 0, pStruct[playerid][pPosx], pStruct[playerid][pPosy], pStruct[playerid][pPosz], pStruct[playerid][pPosa], 0, 0, 0, 0, 0, 0);
				SpawnPlayer(playerid);
			}
			else
			{
				pStruct[playerid][LoginAttempts]++;

				if (pStruct[playerid][LoginAttempts] >= 3)
				{
					ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have mistyped your password too often (3 times).", "Okay", "");
					DelayedKick(playerid);
				}
				else ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Wrong password!\nPlease enter your password in the field below:", "Login", "Abort");
			}
		}
		case DIALOG_REGISTER:
		{
			if (!response) return Kick(playerid);

			if (strlen(inputtext) <= 5) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", "Your password must be longer than 5 characters!\nPlease enter your password in the field below:", "Register", "Abort");

			// 16 random characters from 33 to 126 (in ASCII) for the salt
			for (new i = 0; i < 16; i++) pStruct[playerid][pSalt][i] = random(94) + 33;
			SHA256_PassHash(inputtext, pStruct[playerid][pSalt], pStruct[playerid][pPassword], 65);

			new query[221];
			mysql_format(g_SQL, query, sizeof query, "INSERT INTO `players` (`pUsername`, `pPassword`, `pSalt`) VALUES ('%e', '%s', '%e')", pStruct[playerid][pUsername], pStruct[playerid][pPassword], pStruct[playerid][pSalt]);
			mysql_tquery(g_SQL, query, "OnPlayerRegister", "d", playerid);
		}
	}
	return 1;
}