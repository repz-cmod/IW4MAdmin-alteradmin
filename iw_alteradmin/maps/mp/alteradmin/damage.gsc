#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\alteradmin\helpers;
//Showing damage functionality

//Called every time the player receives damage
//Based on _damage.gsc, but just the calculations...
Callback_PlayerDamage_internal( eInflictor, eAttacker, victim, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime ) {
	
	if ( isDefined( eAttacker ) && eAttacker.classname == "script_origin" && isDefined( eAttacker.type ) && eAttacker.type == "soft_landing" )
		iDamage = 0.0;//return;

	if ( sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" && iDamage != 1 )
	{
		iDamage *= getDvarFloat( "scr_explBulletMod" );	
		iDamage = int( iDamage );
	}

	if ( isDefined( eAttacker ) && eAttacker.classname == "worldspawn" )
		eAttacker = undefined;
	
	if ( isDefined( eAttacker ) && isDefined( eAttacker.gunner ) )
		eAttacker = eAttacker.gunner;
		
	attackerIsNPC = isDefined( eAttacker ) && !isDefined( eAttacker.gunner ) && (eAttacker.classname == "script_vehicle" || eAttacker.classname == "misc_turret" || eAttacker.classname == "script_model");
	attackerIsHittingTeammate = level.teamBased && isDefined( eAttacker ) && ( victim != eAttacker ) && isDefined( eAttacker.team ) && ( victim.pers[ "team" ] == eAttacker.team );

	stunFraction = 0.0;

	if ( iDFlags & level.iDFLAGS_STUN )
	{
		stunFraction = 0.0;
		//victim StunPlayer( 1.0 );
		iDamage = 0.0;
	}
	else if ( sHitLoc == "shield" )
	{
		if ( attackerIsHittingTeammate && level.friendlyfire == 0 )
			iDamage = 0.0;//return;
		
		if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" && !attackerIsHittingTeammate )
		{
			if ( isPlayer( eAttacker ) )
			{
				eAttacker.lastAttackedShieldPlayer = victim;
				eAttacker.lastAttackedShieldTime = getTime();
			}

			// fix turret + shield challenge exploits
			if ( sWeapon == "turret_minigun_mp" )
				shieldDamage = 25;
			else
				shieldDamage = maps\mp\perks\_perks::cac_modified_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );
						
			victim.shieldDamage += shieldDamage;

			// fix turret + shield challenge exploits
			if ( sWeapon != "turret_minigun_mp" || cointoss() )
				victim.shieldBulletHits++;

			if ( victim.shieldBulletHits >= level.riotShieldXPBullets )
			{				
				victim.shieldDamage = 0;
				victim.shieldBulletHits = 0;
			}
		}

		if ( iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT )
		{
			sHitLoc = "none";	// code ignores any damage to a "shield" bodypart.
			if ( !(iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT_HUGE) )
				iDamage *= 0.0;
		}
		else if ( iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_SPLASH )
		{
			if ( isDefined( eInflictor ) && isDefined( eInflictor.stuckEnemyEntity ) && eInflictor.stuckEnemyEntity == victim ) //does enough damage to shield carrier to ensure death
				iDamage = 101;
			
			sHitLoc = "none";	// code ignores any damage to a "shield" bodypart.
		}
		else
		{
			iDamage = 0.0;//return;
		}
	}
	else if ( (smeansofdeath == "MOD_MELEE") && IsSubStr( sweapon, "riotshield" ) )
	{
		if ( !(attackerIsHittingTeammate && (level.friendlyfire == 0)) )
		{
			stunFraction = 0.0;
		}
	}

	if ( !attackerIsHittingTeammate )
		iDamage = maps\mp\perks\_perks::cac_modified_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );
	
	if ( !iDamage )
		iDamage = 0.0;//return false;
	victim.iDFlags = iDFlags;
	victim.iDFlagsTime = getTime();

	// handle vehicles/turrets and friendly fire
	if ( attackerIsNPC && attackerIsHittingTeammate )
	{		
		if ( !level.friendlyfire )
			iDamage = 0.0;//return;
	}

	//prof_begin( "PlayerDamage flags/tweaks" );

	// Don't do knockback if the damage direction was not specified
	if ( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	friendly = false;

	if ( ( victim.health == victim.maxhealth && ( !isDefined( victim.lastStand ) || !victim.lastStand )  ) || !isDefined( victim.attackers ) && !isDefined( victim.lastStand )  )
	{
		victim.attackers = [];
		victim.attackerData = [];
	}

	if ( maps\mp\gametypes\_damage::isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, eAttacker ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if ( maps\mp\gametypes\_tweakables::getTweakableValue( "game", "onlyheadshots" ) )
	{
		if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" )
			iDamage = 0.0;//return;
		else if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
			iDamage = 150;
	}

	//prof_begin( "PlayerDamage world" );
	if ( attackerIsHittingTeammate )
	{
		if ( !matchMakingGame() && isPlayer(eAttacker) )
			eAttacker incPlayerStat( "mostff", 1 );
		
		//prof_begin( "PlayerDamage player" );// profs automatically end when the function returns
		if ( level.friendlyfire == 0 || ( !isPlayer(eAttacker) && level.friendlyfire != 1 ) )// no one takes damage
		{
			iDamage = 0.0;//return;
		}
		else if ( level.friendlyfire == 1 )// the friendly takes damage
		{
			if ( iDamage < 1 )
				iDamage = 1;

			victim.lastDamageWasFromEnemy = false;

		}
		else if ( ( level.friendlyfire == 2 ) && isReallyAlive( eAttacker ) )// only the attacker takes damage
		{
			iDamage = int( iDamage * .5 );
			if ( iDamage < 1 )
				iDamage = 1;

			eAttacker.lastDamageWasFromEnemy = false;

			eAttacker.friendlydamage = true;
			eAttacker.friendlydamage = undefined;
		}
		else if ( level.friendlyfire == 3 && isReallyAlive( eAttacker ) )// both friendly and attacker take damage
		{
			iDamage = int( iDamage * .5 );
			if ( iDamage < 1 )
				iDamage = 1;

			victim.lastDamageWasFromEnemy = false;
			eAttacker.lastDamageWasFromEnemy = false;

			if ( isReallyAlive( eAttacker ) )// may have died due to friendly fire punishment
			{
				eAttacker.friendlydamage = true;
				eAttacker.friendlydamage = undefined;
			}
		}

		friendly = true;
		
	}
	else// not hitting teammate
	{
		//prof_begin( "PlayerDamage world" );

		if ( iDamage < 1 )
			iDamage = 1;

		if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) && eAttacker != victim )
		{
			victim.attackerPosition = eAttacker.origin;
		}
		else
		{
			victim.attackerPosition = undefined;
		}

		if ( issubstr( sMeansOfDeath, "MOD_GRENADE" ) && isDefined( eInflictor.isCooked ) )
			victim.wasCooked = getTime();
		else
			victim.wasCooked = undefined;

		victim.lastDamageWasFromEnemy = ( isDefined( eAttacker ) && ( eAttacker != victim ) );

		if ( victim.lastDamageWasFromEnemy )
			eAttacker.damagedPlayers[ victim.guid ] = getTime();

		//prof_end( "PlayerDamage world" );
		
	}

	if ( attackerIsNPC && isDefined( eAttacker.gunner ) )
		damager = eAttacker.gunner;
	else
		damager = eAttacker;

	if ( isDefined( damager) && damager != victim && iDamage > 0 )
	{
		if ( iDFlags & level.iDFLAGS_STUN )
			typeHit = "stun";
		else if ( victim hasPerk( "specialty_armorvest", true ) || (isExplosiveDamage( sMeansOfDeath ) && victim _hasPerk( "_specialty_blastshield" )) )
			typeHit = "hitBodyArmor";
		else if ( victim _hasPerk( "specialty_combathigh") )
			typeHit = "hitEndGame";
		else
			typeHit = "standard";

	}

	//=================
	// Damage Logging
	//=================
	//Todo add stuff like typeHit in console, makes for interesting reading 
	//eAttacker thread maps\mp\gametypes\_hud_message::hintMessage("test");
	//eAttacker thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed("test");
	
	//Check if I'm not damaging myself
	if(eAttacker.name == victim.name)
		return;
	
	//parse hit location
	hitLocation = parseHitLoc( sHitLoc );
	
	/*
		eAttacker iPrintLnBold("^1"+ iDamage +"dmg -> ^2"+ hitLocation+" ("+victim.health+"/"+victim.maxhealth+")");
		victim iPrintLnBold("^1"+ iDamage +"dmg -> ^2"+ hitLocation+" ("+victim.health+"/"+victim.maxhealth+")");
	*/

	//display statistic
	if(eAttacker.pers["printDamage"] == true) {

		eAttacker.pers["damagefeedbackText"] setText("^1"+ iDamage +"dmg ^0-> ^2"+ hitLocation+" ^0(^1"+victim.health+"^0/^2"+victim.maxhealth+"^0)");
		eAttacker.pers["damagefeedbackText"].alpha = 1;
		eAttacker.pers["damagefeedbackText"] fadeOverTime(1);
		eAttacker.pers["damagefeedbackText"].alpha = 0;

	}
	
	if(victim.pers["printDamage"] == true) {
	
		victim.pers["damagefeedbackText"] setText("^1"+ iDamage +"dmg ^0-> ^2"+ hitLocation+" ^0(^1"+victim.health+"^0/^2"+victim.maxhealth+"^0)");
		victim.pers["damagefeedbackText"].alpha = 1;
		victim.pers["damagefeedbackText"] fadeOverTime(1);
		victim.pers["damagefeedbackText"].alpha = 0;
	
	}

}

parseHitLoc( sHitLoc )
{
	/*
	possbilities:
	case "helmet":
	case "head":
	case "neck":
	case "torso_upper":
	case "right_arm_upper":
	case "left_arm_upper":
	case "right_arm_lower":
	case "left_arm_lower":
	case "right_hand":
	case "left_hand":
	case "gun":
	case "torso_lower":
	case "right_leg_upper":
	case "left_leg_upper":
	case "right_leg_lower":
	case "left_leg_lower":
	case "right_foot":
	case "left_foot":
	*/
	switch (sHitLoc) {
        case "torso_upper":
			return "upper torso";
        case "right_arm_upper":
			return "right upper arm";
		case "right_arm_lower":
			return "right lower arm";
        case "left_arm_upper":
			return "left upper arm";
        case "left_arm_lower":
			return "left lower arm";
        case "right_hand":
			return "right hand";
        case "left_hand":
			return "left hand";
        case "torso_lower":
            return "lower torso";
        case "right_leg_upper":
			return "right upper leg";
		case "right_leg_lower":
			return "right lower leg";
        case "left_leg_upper":
            return "left upper leg";
        case "left_leg_lower":
            return "left lower leg";
        case "right_foot":
			return "right foot";
        case "left_foot":
            return "left foot";
		default:
			return sHitLoc;
    }
}