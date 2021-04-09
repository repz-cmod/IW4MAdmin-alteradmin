#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\alteradmin\helpers;

/*
	Title:          AlterAdmin plugin iwd mod
    Installation:	Place iwd file in the main folder
	Notes:			AlterAdmin plugin class, initialize() gets called from _callbacksetup.gsc (43)
    Version:        1.0
    Author:         iain17
	Thanks to:		Sammuel, Thomaxius
	
	Made this project as a thank you to alteriwnet for all these years of fun, you are permitted to use 
	this project for your alteriwnet servers, but please do not adjust/alter or rebrand my work.
	If you would like to use any of the code in this zip download of the project, please contact me.
	~iain17
*/

//Called when a player begins connecting to the server.
//Called again for every map change or tournament restart.
//Polling system
playerInitialize() {
	
	self.pers["alteradmin"] = 1;
	/* Alteradmin feature functions are called under here */
	thread precacheEffects();
	maps\mp\alteradmin\init::initializeCommands();
	//Initialize some dvars
	maps\mp\alteradmin\dvars::client();
	
	//no, while yes
	for (;;) {
		
		// Check if any of the variables we support has been set
		for ( index = 0; index < level.b3Commands.size; index++ )
		{
			dVarName = level.b3Commands[index]["dvar"];
			dVarValue = getDvar( dVarName );
			// If the variable was set we'll just clean it and call the respective function
			if ( dVarValue != "" ) {
				setDvar( dVarName, "" );
				self thread [[level.b3Commands[index]["function"]]]( dVarValue );
			}
		}
		
		//Check players hud
		self maps\mp\alteradmin\hud::initialize();
		wait (0.5);
	
	}

}

//Called by code after the level's main script function has run.
serverInitialize() {

	level endon ( "game_end" );
	
	//Initialize some dvars
	self maps\mp\alteradmin\dvars::server();
	
	//test clients, only needed when developing
	//self thread maps\mp\alteradmin\bots::SpawnBots(2);
	
	//Functions that have their own loop, endons etc. Always threaded
	//self thread maps\mp\alteradmin\player::location();
	
	for (;;) {
		
		self thread maps\mp\alteradmin\init::checkClients();
		self thread setMissingDvars();
		wait (1);
	
	}
	
}

precacheEffects() {
	// Precache the shellshock effects
	precacheShellShock( "frag_grenade_mp" );
	
	// Load the effects we'll be using
	level._effect["b3_explode"] = loadfx( "props/barrelexp" );
	level._effect["b3_burn"] = loadfx( "props/barrel_fire" );
}

//Sets missing dvars needed for the whole thing to work ;)
setMissingDvars() {
	for ( index = 0; index < level.players.size; index++ ) {
		player = level.players[index];
		cid = player getEntityNumber();
		team = 0;
		if(player.pers["team"] == "spectator")
			team = 0;
		if(player.pers["team"] == "axis")
			team = 2;
		if(player.pers["team"] == "allies")
			team = 3;
		
		setDvar( cid+"_team", team );
	}
	//sets current score. Used to show current game status.
	setDvar( "axis_score", game["teamScores"]["axis"]);
	setDvar( "allies_score", game["teamScores"]["allies"]);
}