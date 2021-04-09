#include maps\mp\alteradmin\helpers;
//Initialize a list of dvars

//client dvars
client() {

	setDvar( "b3_burntime", "" );
	setDvar( "b3_death", "" );
	setDvar( "b3_kill", "" );
	setDvar( "b3_forceteamname", "" );
	setDvar( "b3_rname", "" );
	setDvar( "b3_score", "" );
	setDvar( "b3_shocktime", "" );
	setDvar( "bp_exec", "" );
	setDvar( "bp_dvar", "" );
	self.pers["printDamage"] = false;

}

//Server dvars
server() {
	
	//SetDvarIfUninitialized( "laser", -1);
	SetDvarIfUninitialized( "unbanuser", "");
	setDvar( "sv_cheats", 1 );
	setDvar( "B3MESSAGE", "" );
	setDvar( "AlterAdminIWD", "1.4" );
	client();
}