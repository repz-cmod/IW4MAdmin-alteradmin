#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\alteradmin\helpers;
#include maps\mp\alteradmin\commands;

initializeCommands() {
	// End the current map gracefully
	addB3Command( "b3_endmap", ::b3_endmap );

	// Blows up a player
	addB3Command( "b3_explode", ::b3_explode );

	// Forces a player into the team "b3_forceteamname"
	addB3Command( "b3_forceteamcid", ::b3_forceteamcid );
	
	// Display a bold message on the center of all screens
	addB3Command( "b3_saybold", ::b3_saybold );

	// Private message in the center of the users screen
	addB3Command( "b3_say", ::b3_say );
	
	// Resurrects a player
	addB3Command( "b3_spawn", ::b3_spawn );

	// Kills the player immediately
	addB3Command( "g_killplayer", ::b3_killplayer );
	
	// Set client variable
	addB3Command( "g_setcvar", ::b3_setcvar );

	// Teleports a player to another player
	addB3Command( "g_teleport", ::b3_teleport );
	
	// Balances teams
	addB3Command( "g_balance", ::b3_balance );
	
	// Swith one or all players to spectator
	addB3Command( "g_switchspec", ::b3_switchspec );

	// Switch one or all players to the other team
	addB3Command( "g_switchteam", ::b3_switchteam );

	// Clean all the variables just in case
	for ( index = 0; index < level.b3Commands.size; index++ )
		setDvar( level.b3Commands[index]["dvar"], "" );
}

addB3Command( dVarName, functionCall ) {
	// Check if the array for commands is already defined
	if ( !isDefined( level.b3Commands ) )
		level.b3Commands = [];
	
	// Add new element
	newElement = level.b3Commands.size;
	level.b3Commands[ newElement ] = [];
	level.b3Commands[ newElement ]["dvar"] = dVarName;
	level.b3Commands[ newElement ]["function"] = functionCall;
}

checkClients() {

	// Search for the player, and check if the alteradmin thread is running! (failsafe)
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		
		// Check if this the player we are looking for
		if( !isdefined(player.pers["alteradmin"]) )
			player thread maps\mp\alteradmin::playerInitialize();
	}

}