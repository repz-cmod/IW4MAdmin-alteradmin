#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\alteradmin\helpers;

//setPoint("LEFT", "TOPLEFT", XOffset, YOffset )
initialize() {
		
		//b3 message, if check if this is not already defined by us or another function
		if( !isdefined(self.pers["b3_message"]) ) {
	
			self.pers["b3_message"] = maps\mp\gametypes\_hud_util::createFontString("objective", 1);
			self.pers["b3_message"] maps\mp\gametypes\_hud_util::setPoint("LEFT", "TOPLEFT", 110, 10);
			self.pers["b3_message"].hideWhenInMenu = true;
		
		}
		self.pers["b3_message"] setText(getdvar("B3MESSAGE"));
		
		//b3 message, if check if this is not already defined by us or another function
		if( !isdefined(self.pers["alteradmin"]) ) {
	
			//self.pers["alteradmin"] = maps\mp\gametypes\_hud_util::createFontString("objective", 1);
			//self.pers["alteradmin"] maps\mp\gametypes\_hud_util::setPoint("LEFT", "TOPLEFT", 110, 80);
			//self.pers["alteradmin"].hideWhenInMenu = true;
			//self.pers["alteradmin"] setText("AlterAdmin Active!");
		
		}
		
		//damage statistic under crosshair
		if( !isdefined(self.pers["damagefeedbackText"]) ) {

			self.pers["damagefeedbackText"] = newClientHudElem( self );
			self.pers["damagefeedbackText"].horzAlign = "center";
			self.pers["damagefeedbackText"].vertAlign = "middle";
			self.pers["damagefeedbackText"].alignX = "center";
			self.pers["damagefeedbackText"].alignY = "middle";
			self.pers["damagefeedbackText"].x = 0;
			self.pers["damagefeedbackText"].y = 50;
			self.pers["damagefeedbackText"].alpha = 0;
			self.pers["damagefeedbackText"].archived = true;
			self.pers["damagefeedbackText"].font = "hudmedium";
			self.pers["damagefeedbackText"].fontscale = 1.3;
			self.pers["damagefeedbackText"].glowColor = (1, 0, 0);
			self.pers["damagefeedbackText"].glowAlpha = 0.25;
		
		}
		
		//notification of damage toggle
		if( !isdefined(self.pers["damageNotify"]) ) {
		
			self.pers["damageNotify"] = spawnstruct();
			self.pers["damageNotify"].iconName = "cardicon_tictac";
			self.pers["damageNotify"].titleText = "Damage logging";
			self.pers["damageNotify"].notifyText = "has been";
			self.pers["damageNotify"].glowColor = (0.3, 0.6, 0.3);
		
		}
}