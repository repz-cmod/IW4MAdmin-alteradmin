#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\alteradmin\helpers;

SpawnBots(AmountOfBots)
{
	wait 10;
	if ( !isDefined( level.bots ) ) {
		self thread watchCrouch();
		self thread initTestClients(AmountOfBots);
		setDvar("testClients_doMove", 1 );
		setDvar("testClients_doAttack", 1 );
		setDvar("testClients_doCrouch", 1 );
	}
}

initTestClients(numberOfTestClients)
{
	level.bots = true;
        for(i = 0; i < numberOfTestClients; i++)
        {
                ent[i] = addtestclient();

                if (!isdefined(ent[i]))
                {
                        wait 1;
                        continue;
                }

                ent[i].pers["isBot"] = true;
                ent[i] thread initIndividualBot();
                wait 0.1;
        }
}

initIndividualBot()
{
        self endon( "disconnect" );
        while(!isdefined(self.pers["team"]))
                wait .05;
        self notify("menuresponse", game["menu_team"], "autoassign");
        wait 0.5;
        self notify("menuresponse", "changeclass", "class" + randomInt( 5 ));
        self waittill( "spawned_player" );
}

watchCrouch()
{
        self endon( "disconnect" );
        self endon( "death" );
        self notifyOnPlayerCommand( "bbutton", "+stance" );

        for( ;; )
        {
                if ( self GetStance() == "crouch" )
                        setDvar( "testClients_doCrouch", 1 );
                else
                        setDvar( "testClients_doCrouch", 0 );
                wait 0.1;
        }
}