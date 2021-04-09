#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

findPlayerByNumber( entityNumber ) {
	foundPlayer = undefined;
	//failsafe
	entityNumber = int(entityNumber);
	
	//if (self getEntityNumber() == entityNumber)
	//	return self;
	
	// Search for the player
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		
		// Check if this the player we are looking for
		if ( player getEntityNumber() == entityNumber ) {
			foundPlayer = player;
			break;
		}
	}
	return foundPlayer;
}

playSoundOnEveryone( soundName ) {
	level endon( "game_ended" );
	
	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player playLocalSound( soundName );
	}
}