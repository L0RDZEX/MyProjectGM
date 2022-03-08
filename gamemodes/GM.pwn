#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <sscanf2>

// MySQL connection handle
new MySQL: g_SQL;

// Data Player
enum PLAYER_STRUCTURE
{
	pID,
	pUsername[MAX_PLAYER_NAME],
	pPassword[65],
	pSalt[17],

	Float: pPosx,
	Float: pPosy,
	Float: pPosz,
	Float: pPosa,
	pInterior,

	Cache: Cache_ID,
	bool: IsLoggedIn,
	LoginAttempts,
	LoginTimer
};
new pStruct[MAX_PLAYERS][PLAYER_STRUCTURE];
new g_MysqlRaceCheck[MAX_PLAYERS];


// Data Dialog
enum
{
	DIALOG_UNUSED,
	// DIALOG LOGIN/REGISTER
	DIALOG_LOGIN,
	DIALOG_REGISTER
};

main()
{
	print("[GM]: Server Berhasil Dimulai.");
}

// Module Gamemode
#include "MODULE\DEFINE.pwn"
#include "MODULE\FUNCTIONS.pwn"
#include "MODULE\DIALOGS.pwn"

public OnGameModeInit()
{
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true);

	g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, option_id);
	if (g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
	{
		print("[GM]: MySQL connection failed. Server is shutting down.");
		SendRconCommand("exit");
		return 1;
	}

	print("[GM]: MySQL connection is successful.");	
	return 1;
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, pStruct[playerid][pUsername], MAX_PLAYER_NAME);

	new query[103];
	mysql_format(g_SQL, query, sizeof query, "SELECT * FROM `players` WHERE `pUsername` = '%e' LIMIT 1", pStruct[playerid][pUsername]);
	mysql_tquery(g_SQL, query, "OnPlayerDataLoaded", "d", playerid);	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	UpdatePlayerData(playerid);
	pStruct[playerid][IsLoggedIn] = false;
	return 1;
}

public OnGameModeExit()
{
	for (new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if (IsPlayerConnected(i))
		{
			OnPlayerDisconnect(i, 1);
		}
	}

	mysql_close(g_SQL);	
	return 1;
}