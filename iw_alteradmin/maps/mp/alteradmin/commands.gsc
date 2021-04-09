#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\alteradmin\helpers;

//Initialize a list of commands
b3_burn( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Get the time or use a default one
	burnTime = getdvarint( "b3_burntime" );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;
	
	// See which sound we'll use
	if ( !isDefined( player.myPainSound ) )
		player.myPainSound = "generic_pain_american_" + randomIntRange(1, 9);
	
	player iprintlnbold( "^1You are being burned by an admin" );
	
	// Shock the player
	killPlayerTime = gettime() + burnTime * 1000;
	lastSound = gettime();
	while ( isDefined( player ) && killPlayerTime > gettime() ) {
		wait (0.1);
		playfx( level._effect["b3_burn"], player.origin );
		if ( gettime() - lastSound > 1000 ) {
			lastSound = gettime();
			player playLocalSound( player.myPainSound );
		}
	}
	
	// Kill the player
	if ( isDefined( player ) ) {
		player suicide();
	}
}

unbanuser ( dVarValue ) {
	logPrint("Player successfully unbanned");
}

b3_compensate( dVarValue ) {
	// Let the other modules takes care of this request
	setDvar( "b3_death", "-1" );
	setDvar( "b3_deathcid", dVarValue );
	setDvar( "b3_score", "100" );
	setDvar( "b3_scorecid", dVarValue );
}

b3_reset( dVarValue ) {
	
	// Search for the player
	player = findPlayerByNumber( int(dVarValue) );
	if ( !isDefined( player ) )
		return;
	
	/*
	setDvar( "b3_death", abs(int(player.pers["deaths"])) );
	setDvar( "b3_deathcid", dVarValue );
	setDvar( "b3_score", abs(int(player.pers["score"])) );
	setDvar( "b3_scorecid", dVarValue );
	setDvar( "b3_kill", abs(int(player.pers["kills"])) );
	setDvar( "b3_killcid", dVarValue );
	player.deaths = 0;
	*/
	player.pers["deaths"] = 0;
	player.deaths = 0;
	
	player.score = 0;
	player.pers["score"] = 0;
	
	player.kills = 0;
	player.pers["kills"] = 0;

	player.assists = 0;
	player.pers["assists"] = 0;

	iprintln( "^7The admin has reset the number of deaths,kills and score for ^3&&1^7", player.name );
}

b3_deathcid( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have which value we need to apply to the player's death counter
	deathDif = getDvarInt( "b3_death" );
	if ( deathDif == 0 )
		return;
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) )
		return;
		
	// Change the player's deaths
	player.deaths += deathDif;
	player.pers["deaths"] += deathDif;
	
	// Display a message to the players
	if ( deathDif > 0 ) {
		iprintln( "^7The admin has increased the number of deaths for ^3&&1^7 by ^3&&2^7.", player.name, deathDif );
	} else {
		iprintln( "^7The admin has decreased the number of deaths for ^3&&1^7 by ^3&&2^7.", player.name, deathDif * -1 );
	}
}

b3_killscid( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have which value we need to apply to the player's death counter
	killDif = getDvarInt( "b3_kill" );
	if ( killDif == 0 )
		return;
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) )
		return;
		
	// Change the player's kills
	player.kills += killDif;
	player.pers["kills"] += killDif;
	
	// Display a message to the players
	if ( killDif > 0 ) {
		iprintln( "^7The admin has increased the number of kills for ^3&&1^7 by ^3&&2^7.", player.name, killDif );
	} else {
		iprintln( "^7The admin has decreased the number of kills for ^3&&1^7 by ^3&&2^7.", player.name, killDif * -1 );
	}
}


b3_endmap( dVarValue ) {
	// End the current map
	level.forcedEnd = true;
	thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["round_draw"] );
}


b3_explode( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;
	
	player iprintlnbold( "^7You have been punished by the server admin!" );
	
	// Shock the player
	playfx( level._effect["b3_explode"], player.origin );
	player playLocalSound( "exp_suitcase_bomb_main" );
	player suicide();
}


b3_forceteamcid( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have the new team for the player and that the game is really team based
	newTeam = getDvar( "b3_forceteamname" );
	if ( !level.teamBased || newTeam == "" || ( newTeam != "allies" && newTeam != "axis" && newTeam != "spectator" ) )
		return;
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || player.pers["team"] == newTeam )
		return;

	// Kill the player if it's alive
	if ( isAlive( player ) ) {
		// Set a flag on the player to they aren't robbed points for dying - the callback will remove the flag
		player.switching_teams = true;
		player.joining_team = newTeam;
		player.leaving_team = player.pers["team"];
	
		// Suicide the player so they can't hit escape
		player suicide();
	}
	player.pers["team"] = newTeam;
	player.team = newTeam;
	
	if ( newTeam != "spectator" ) {
		player iprintlnbold( "The server admin has switched you to the other team." );
		
		player.pers["teamTime"] = undefined;
		player.sessionteam = player.pers["team"];
		player updateObjectiveText();
	
		// update spectator permissions immediately on change of team
		player maps\mp\gametypes\_spectating::setSpectatePermissions();
	
		if ( player.pers["team"] == "allies" ) {
			player setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);
			player openMenu( game[ "menu_changeclass_allies" ] );
		}	else if ( player.pers["team"] == "axis" ) {
			player setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);
			player openMenu( game[ "menu_changeclass_axis" ] );
		}
	
		player notify( "end_respawn" );	
	} else {
		player.pers["class"] = undefined;
		player.class = undefined;
		player.pers["weapon"] = undefined;
		player.pers["savedmodel"] = undefined;

		player updateObjectiveText();

		player.sessionteam = "spectator";
		player [[level.spawnSpectator]]();

		player setclientdvar("g_scriptMainMenu", game["menu_team"]);

		player notify("joined_spectators");	
	}
}


b3_killplayer( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;
	
	player iprintlnbold( "7You have been punished by the server admin!" );
	
	player suicide();
}
/*
parameters[0] = client.cid
parameters[1] = cvar
parameters[2] = value
separates by "<*_*>"
*/
b3_setcvar( dVarValue ) {
	level endon( "game_ended" );
	// dVarValue contains the player's number
	parameters = strTok(dVarValue, "<*_*>");
	
	// Search for the player
	player = findPlayerByNumber( int( parameters[0] ) );
	if ( !isDefined( player ) )
		return;
	
	player setClientDvar(parameters[1], parameters[2]);
	
}

b3_fpsboost( dVarValue ) {
	level endon( "game_ended" );
	// dVarValue contains the player's number
	parameters = strTok(dVarValue, " ");
	
	// Search for the player
	player = findPlayerByNumber( int( parameters[0] ) );
	if ( !isDefined( player ) )
		return;
	
	if(int( parameters[1] ) == 1) {
		
		player setClientDvar("r_fullbright", 1);
	
	} else {
	
		player setClientDvar("r_fullbright", 0);
	
	}
	
}

b3_damage( dVarValue ) {
	level endon( "game_ended" );
	// dVarValue contains the player's number
	parameters = strTok(dVarValue, " ");
	
	// Search for the player
	player = findPlayerByNumber( int( parameters[0] ) );
	if ( !isDefined( player ) )
		return;
	
	if( !isdefined(player.pers["printDamage"]) )
		player.pers["printDamage"] = false;
	
	if(int( parameters[1] ) == 0) {
		
		player.pers["printDamage"] = false;
		//player.pers["damageNotify"].notifyText2 = "^1Disabled";
		//player.pers["damageNotify"].sound = "mp_obj_returned";
	
	} else {
	
		player.pers["printDamage"] = true;
		//player.pers["damageNotify"].notifyText2 = "^2Enabled";
		//player.pers["damageNotify"].sound = "mp_obj_captured`";
	
	}
	
	//player thread maps\mp\gametypes\_hud_message::notifyMessage( self.pers["damageNotify"] );	
	
}

b3_balance() {
	
	level endon( "game_ended" );
		
	iPrintLnBold( "Teams are being balanced" );
	maps\mp\gametypes\_teams::balanceTeams();
	
}

b3_saybold( dVarValue ) {
	level endon( "game_ended" );
	
	// Play a sound on all the players and print the message
	level thread playSoundOnEveryone( "mp_last_stand" );
	iprintlnbold( dVarValue );
}

b3_say( dVarValue ) {
	level endon( "game_ended" );
	
	parameters = strTok(dVarValue, "<+_+>");

	// Search for the player
	player = findPlayerByNumber( int( parameters[0] ) );
	if ( !isDefined( player ) )
		return;
		
	player playSound( "mp_last_stand" );
	//todo instead of iprintlnbold make it more fancy
	player iprintlnbold( parameters[1] );
}

b3_spawn( dVarValue ) {
	level endon( "game_ended" );

	// Search for the player
	player = findPlayerByNumber( int( dVarValue ) );
	if ( !isDefined( player ) )
		return;
		
	player thread maps\mp\gametypes\_playerlogic::spawnplayer();
	player playSound( "mp_last_stand" );
	player iPrintLnBold("^2Resurrected by an admin");
}

b3_scarynade( dVarValue ) {
	level endon( "game_ended" );
	
	// Play a sound on all the players 
	level thread playSoundOnEveryone( "grenade_bounce_default" );
}

b3_message( dVarValue ) {
	level endon( "game_ended" );
	
	setDvar( "B3MESSAGE", dVarValue );
}

b3_scaryshot( dVarValue ) {
	level endon( "game_ended" );
	
	// Play a sound on all the players 
	for ( times = 0; times < 3; times++ ) {
		level thread playSoundOnEveryone( "bullet_impact_headshot_2" );
		wait ( randomFloatRange( 0.15, 0.35 ) );
	}
}

b3_scorecid( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Make sure we have which value we need to apply to the player's score
	scoreDif = getDvarInt( "b3_score" );
	if ( scoreDif == 0 )
		return;
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) )
		return;
		
	// Change the player's score
	player.score += scoreDif;
	player.pers["score"] += scoreDif;
	
	// Display a message to the players
	if ( scoreDif > 0 ) {
		iprintln( "^7The admin has increased the score for ^3&&1^7 by ^3&&2^7 points.", player.name, scoreDif );
	} else {
		iprintln( "^7The admin has decreased the score for ^3&&1^7 by ^3&&2^7 points", player.name, scoreDif * -1 );
	}
}


b3_shock( dVarValue ) {
	level endon( "game_ended" );
	
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	// Get the time or use a default one
	shockTime = getdvarint( "b3_shocktime" );
	
	// Search for the player
	player = findPlayerByNumber( dVarValue );
	if ( !isDefined( player ) || !isAlive( player ) )
		return;
	
	player iprintlnbold( "You have been punished by the server admin!" );
	
	// Shock the player
	player shellshock( "frag_grenade_mp", shockTime );
}


b3_switchspec( dVarValue ) {
	level endon( "game_ended" );
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// If it's only one player we'll use the other modules
	if ( dVarValue != -1 ) {
		setDvar( "b3_forceteamname", "spectator" );
		setDvar( "b3_forceteamcid", dVarValue );
		return;
	}
	
	// We need to switch all the players to spectator
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];

		// Make sure this player is not already an spectator
		if( player.pers["team"] != "spectator" ) {
			if( isAlive( player ) ) {
				player.switching_teams = true;
				player.joining_team = "spectator";
				player.leaving_team = player.pers["team"];
				player suicide();
			}
	
			player.pers["team"] = "spectator";
			player.team = "spectator";
			player.pers["class"] = undefined;
			player.class = undefined;
			player.pers["weapon"] = undefined;
			player.pers["savedmodel"] = undefined;
	
			player updateObjectiveText();
	
			player.sessionteam = "spectator";
			player [[level.spawnSpectator]]();
	
			player setclientdvar("g_scriptMainMenu", game["menu_team"]);
	
			player notify("joined_spectators");
		}
	}	
}

b3_teleport( dVarValue ) {
	
	level endon( "game_ended" );
	parameters = strTok(dVarValue, " ");
	
	// Search for the players
	telefrom = findPlayerByNumber(int(parameters[0]));
	teleto = findPlayerByNumber(int(parameters[1]));
	if ( !isDefined( telefrom ) || !isAlive( telefrom ) )
		return;

	if ( !isDefined( teleto ) || !isAlive( teleto ) )
		return;
	
	telefrom iPrintLnBold( "Teleporting you to "+teleto.name );
	telefrom setorigin(teleto.origin+ ( 0, 0, 100 ) );
	telefrom setplayerangles(teleto.angles);
	
}

// team switch command
b3_switchteam( dVarValue ) {
	level endon( "game_ended" );
	// dVarValue contains the player's number
	dVarValue = int( dVarValue );
	
	// If it's only one player we'll use the other modules
	if ( dVarValue != -1 ) {
		// Search for the player
		player = findPlayerByNumber( dVarValue );
		if ( !isDefined( player ) || player.pers["team"] == "spectator" )
			return;
		
		setDvar( "b3_forceteamname", level.otherTeam[player.pers["team"]] );
		setDvar( "b3_forceteamcid", dVarValue );
		return;
	}
	
	// We need to switch all the players to the other team
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		otherTeam = level.otherTeam[player.pers["team"]];
		
		// Make sure the player is not an spectator
		if ( player.pers["team"] != "spectator" ) {
			player iprintlnbold( "The server admin has switched you to the other team." );
				
			if ( isAlive( player ) ) {
				// Set a flag on the player to they aren't robbed points for dying - the callback will remove the flag
				player.switching_teams = true;
				player.joining_team = otherTeam;
				player.leaving_team = player.pers["team"];
			
				// Suicide the player so they can't hit escape
				player suicide();
			}
			
			player.pers["team"] = otherTeam;
			player.team = otherTeam;
			player.pers["teamTime"] = undefined;
			player.sessionteam = player.pers["team"];
			player updateObjectiveText();
		
			// update spectator permissions immediately on change of team
			player maps\mp\gametypes\_spectating::setSpectatePermissions();
		
			if ( player.pers["team"] == "allies" ) {
				player setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);
				player openMenu( game[ "menu_changeclass_allies" ] );
			}	else if ( player.pers["team"] == "axis" ) {
				player setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);
				player openMenu( game[ "menu_changeclass_axis" ] );
			}
		
			player notify( "end_respawn" );
		}		
	}	
}