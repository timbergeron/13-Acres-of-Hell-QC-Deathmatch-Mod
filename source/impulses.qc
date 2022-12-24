void(float forced) CheckStartGame;		//declared in gen_misc.qc
void(entity e, string s) ccenterprint;	//declared in gen_misc.qc
float(float cteam) TeamExists;			//declared in teamplay.qc
void(float cteam) JoinTeam;				//declared in teamplay.qc
void(float cteam) CreateTeam;			//declared in teamplay.qc
void(entity p, float cteam) SetTeam;	//declared in teamplay.qc

//-----------------------------------------------------------------------------------
//
// Impulse handling
//
//-----------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------
// Teamplay Impulses
//-----------------------------------------------------------------------------------

void() TeamMenuImpulse =
{
	if((self.impulse > 0) && (self.impulse < 7) && (!temp1 & T_SERVERCLOSED) && (! self.starttime > time))
	{
		if(TeamExists(self.impulse))
			JoinTeam(self.impulse);
		else
			CreateTeam(self.impulse);

		if(((temp1 & T_ALLOWOBSERVER) || ((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2))) && (!gamestatus & G_STARTED))
			PlayerObserverMode();
		else if(!temp1 & T_SERVERCLOSED)
		{
			if(!gamestatus & G_STARTED)
				gamestatus = gamestatus | G_STARTED;
			CheckForDCP();
			PutClientInServer();
		}
		else
			ccenterprint(self, "The server is closed,\nyou have to stay in observer mode.\n");
	}
	if((self.impulse == 7) && (!temp1 & T_SERVERCLOSED) && (! self.starttime > time) && (temp1 & T_ALLOWOBSERVER))
	{
		self.state = self.state - (self.state & S_CHOOSINGTEAM);
		if(!self.state & S_CHANGEDTEAM)
			self.state = self.state | S_CHANGEDTEAM;
		if(!self.state & S_TEAMCHOSEN)
			self.state = self.state | S_TEAMCHOSEN;
		self.genteam = 0;
		self.team = 0;
		bprint(self.netname);
		if(self.state & S_READYPLAY)
			bprint(" changed from player to observer.\n");
		else
			bprint(" is ready to observe.\n");
		self.state = self.state - (self.state & (S_READYOBSERVER | S_READYPLAY));
		self.state = self.state | S_READYOBSERVER;
	}
	self.impulse = 0;
};

//-----------------------------------------------------------------------------------
// Server Impulses
//-----------------------------------------------------------------------------------

void() ServerImpulses =
{
	if(self.impulse == 150)
	{
		if(savedgamecfg & SK_NOQUAD)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOQUAD);
			bprint("Quad Damage enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOQUAD;
			bprint("Quad Damage disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 151)
	{
		if(savedgamecfg & SK_NORING)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NORING);
			bprint("Ring of Shadows enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NORING;
			bprint("Ring of Shadows disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 152)
	{
		if(savedgamecfg & SK_NOPENT)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOPENT);
			bprint("Pentagram of Protection enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOPENT;
			bprint("Pentagram of Protection disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 153)
	{
		if(temp1 & T_ALLOWOBSERVER)
		{
			temp1 = temp1 - (temp1 & T_ALLOWOBSERVER);
			bprint("Observermode disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			temp1 = temp1 | T_ALLOWOBSERVER;
			bprint("Observermode enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 154)
	{
		if(temp1 & T_NOMESSAGES)
		{
			temp1 = temp1 - (temp1 & T_NOMESSAGES);
			bprint("Unimportant messages enabled.\n");
		}
		else
		{
			temp1 = temp1 | T_NOMESSAGES;
			bprint("Unimportant messages disabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 155)
	{
		if(temp1 & T_SUICIDEPROTECTION)
		{
			temp1 = temp1 - (temp1 & T_SUICIDEPROTECTION);
			bprint("Suicide protection disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_SUICIDEPROTECTION;
			bprint("Suicide protection enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 156)
	{
		if(savedgamecfg & SK_NOHEALTH)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOHEALTH);
			bprint("Health enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOHEALTH;
			bprint("Health disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 157)
	{
		if(savedgamecfg & SK_NORA)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NORA);
			bprint("Red armor enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NORA;
			bprint("Red armor disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 158)
	{
		if(savedgamecfg & SK_NOYA)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOYA);
			bprint("Yellow armor enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOYA;
			bprint("Yellow armor disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 159)
	{
		if(savedgamecfg & SK_NOGA)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOGA);
			bprint("Green armor enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOGA;
			bprint("Green armor enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 160)
	{
		if(temp1 & T_DROPPOWERUPS)
		{
			temp1 = temp1 - (temp1 & T_DROPPOWERUPS);
			bprint("Drop powerups disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_DROPPOWERUPS;
			bprint("Drop powerups enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 161)
	{
		if(deathmatch & D_SPEED)
		{
			deathmatch = deathmatch - (deathmatch & D_SPEED);
			bprint("Speed Deathmatch mode disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			deathmatch = deathmatch | D_SPEED;
			bprint("Speed Deathmatch mode enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		temp1 = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 162)
	{
		if(savedgamecfg & SK_NOSSG)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOSSG);
			bprint("Super Shotgun enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOSSG;
			bprint("Super Shotgun disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 163)
	{
		if(savedgamecfg & SK_NONG)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NONG);
			bprint("Nailgun enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NONG;
			bprint("Nailgun disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 164)
	{
		if(savedgamecfg & SK_NOSNG)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOSNG);
			bprint("Super Nailgun enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOSNG;
			bprint("Super Nailgun disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 165)
	{
		if(savedgamecfg & SK_NOGL)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOGL);
			bprint("Grenade Launcher enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOGL;
			bprint("Grenade Launcher disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 166)
	{
		if(savedgamecfg & SK_NORL)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NORL);
			bprint("Rocket Launcher enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NORL;
			bprint("Rocket Launcher disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 167)
	{
		if(savedgamecfg & SK_NOLG)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOLG);
			bprint("Thunderbolt enabled.\n");
			sprint(self, "You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOLG;
			bprint("Thunderbolt disabled.\n");
			sprint(self, "You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 168)
	{
		if(temp1 & T_MOREGIBS)
		{
			temp1 = temp1 - (temp1 & T_MOREGIBS);
			bprint("More gibs disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_MOREGIBS;
			bprint("More gibs enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 169)
	{
		if(temp1 & T_FAIRWEAPON)
		{
			temp1 = temp1 - (temp1 & T_FAIRWEAPON);
			bprint("Backpacks with fair weapons disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_FAIRWEAPON;
			bprint("Backpacks with fair weapons enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 170)
	{
		if(deathmatch & D_ALLWEAPONS)
		{
			deathmatch = deathmatch - (deathmatch & D_ALLWEAPONS);
			bprint("Start with all weapons disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_ALLWEAPONS;
			bprint("Start with all weapons enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 171)
	{
		if(deathmatch & D_INFINITEAMMO)
		{
			deathmatch = deathmatch - (deathmatch & D_INFINITEAMMO);
			bprint("Infinite ammo disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_INFINITEAMMO;
			bprint("Infinite ammo enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 172)
	{
		if(temp1 & T_RPROTECTION)
		{
			temp1 = temp1 - (temp1 & T_RPROTECTION);
			bprint("Respawn protection disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_RPROTECTION;
			bprint("Respawn protection enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 173)
	{
		if(deathmatch & D_MOREHEALTH)
		{
			deathmatch = deathmatch - (deathmatch & D_MOREHEALTH);
			bprint("Megahealth DM disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_MOREHEALTH;
			bprint("Megahealth DM enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 174)
	{
		if(deathmatch & D_WEAPONSSTAY)
		{
			deathmatch = deathmatch - (deathmatch & D_WEAPONSSTAY);
			bprint("Weaponsstay disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_WEAPONSSTAY;
			bprint("Weaponsstay enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 175)
	{
		if(deathmatch & D_DARKDM)
		{
			deathmatch = deathmatch - (deathmatch & D_DARKDM);
			bprint("Dark DM disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			deathmatch = deathmatch | D_DARKDM;
			bprint("Dark DM enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 176)
	{
		if(deathmatch & D_BERSERKDM)
		{
			deathmatch = deathmatch - (deathmatch & D_BERSERKDM);
			bprint("Berserk DM (time) disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_BERSERKDM;
			bprint("Berserk DM (time) enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 177)
	{
		if(teamplay & TEAM_NOCHANGE)
		{
			teamplay = teamplay - (teamplay & TEAM_NOCHANGE);
			bprint("Changing teams enabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_NOCHANGE;
			bprint("Changing teams disabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 178)
	{
		if(teamplay & TEAM_AUTOJOIN)
		{
			teamplay = teamplay - (teamplay & TEAM_AUTOJOIN);
			bprint("Auto-join-team disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_AUTOJOIN;
			bprint("Auto-join-team enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 179)
	{
		if(teamplay & TEAM_HEALTHPROTECT)
		{
			teamplay = teamplay - (teamplay & TEAM_HEALTHPROTECT);
			bprint("Team-Healthprotect disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_HEALTHPROTECT;
			bprint("Team-Healthprotect enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 180)
	{
		if(teamplay & TEAM_ARMORPROTECT)
		{
			teamplay = teamplay - (teamplay & TEAM_ARMORPROTECT);
			bprint("Team-Armorprotect disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_ARMORPROTECT;
			bprint("Team-Armorprotect enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 181)
	{
		if(teamplay & TEAM_DAMAGEPENALTY)
		{
			teamplay = teamplay - (teamplay & TEAM_DAMAGEPENALTY);
			bprint("Team-Damagepenalty disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_DAMAGEPENALTY;
			bprint("Team-Damagepenalty enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 182)
	{
		if(teamplay & TEAM_FRAGPENALTY)
		{
			teamplay = teamplay - (teamplay & TEAM_FRAGPENALTY);
			bprint("Team-Fragpenalty disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_FRAGPENALTY;
			bprint("Team-Fragpenalty enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 183)
	{
		if(teamplay & TEAM_DEATHPENALTY)
		{
			teamplay = teamplay - (teamplay & TEAM_DEATHPENALTY);
			bprint("Team-Deathpenalty disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_DEATHPENALTY;
			bprint("Team-Deathpenalty enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 184)	//lockserver
	{
		if(temp1 & T_SERVERCLOSED)
		{
			temp1 = temp1 - (temp1 & T_SERVERCLOSED);
			bprint("The server is unlocked again.\n");
		}
		else
		{
			temp1 = temp1 | T_SERVERCLOSED;
			bprint("The server is locked.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 185)	//averagefrags
	{
		if(temp1 & T_JOINAVERAGEFRAGS)
		{
			temp1 = temp1 - (temp1 & T_JOINAVERAGEFRAGS);
			bprint("Players do not join with average frags.\n");
		}
		else
		{
			temp1 = temp1 | T_JOINAVERAGEFRAGS;
			bprint("Players join with average frags.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 186)
	{
		if(deathmatch & D_FASTRELOAD)
		{
			deathmatch = deathmatch - (deathmatch & D_FASTRELOAD);
			bprint("Fast-weapons DM disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_FASTRELOAD;
			bprint("Fast-weapons DM enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 187)
	{
		if(deathmatch & D_BERSERKDM2)
		{
			deathmatch = deathmatch - (deathmatch & D_BERSERKDM2);
			bprint("Berserk DM (health) disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_BERSERKDM2;
			bprint("Berserk DM (health) enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 188)
	{
		if(deathmatch & D_OCTADAMAGE)
		{
			deathmatch = deathmatch - (deathmatch & D_OCTADAMAGE);
			bprint("Octa Damage is now Quad Damage.\n");
		}
		else
		{
			deathmatch = deathmatch | D_OCTADAMAGE;
			bprint("Quad Damage is now Octa Damage.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 189)
	{
		if(deathmatch & D_FULLARMOR)
		{
			deathmatch = deathmatch - (deathmatch & D_FULLARMOR);
			bprint("Start with full armor disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_FULLARMOR;
			bprint("Start with full armor enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 190)
	{
		if(deathmatch & D_CANTHARMSELF)
		{
			deathmatch = deathmatch - (deathmatch & D_CANTHARMSELF);
			bprint("Players can harm themselves.\n");
		}
		else
		{
			deathmatch = deathmatch | D_CANTHARMSELF;
			bprint("Players cannot harm themselves.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 191)	//visbkpwpns
	{
		if(temp1 & T_VISBKPWEAPONS)
		{
			temp1 = temp1 - (temp1 & T_VISBKPWEAPONS);
			bprint("Backpack weapons are not visible anymore.\n");
		}
		else
		{
			temp1 = temp1 | T_VISBKPWEAPONS;
			bprint("Backpack weapons visible from now on.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 192)
	{
		if(teamplay & TEAM_MATCH)
		{
			teamplay = teamplay - (teamplay & TEAM_MATCH);
			bprint("Team Match disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_MATCH;
			bprint("Team Match enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 193)	//deathinfo
	{
		if(temp1 & T_DEATHINFO)
		{
			temp1 = temp1 - (temp1 & T_DEATHINFO);
			bprint("Deathinfo disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_DEATHINFO;
			bprint("Deathinfo enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 194)
	{
		if(deathmatch & D_OVERTIME)
		{
			deathmatch = deathmatch - (deathmatch & D_OVERTIME);
			bprint("Sudden death when match is tied is disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_OVERTIME;
			bprint("Sudden death when match is tied is enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 195)	//shells
	{
		if(savedgamecfg & SK_NOSHELLS)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOSHELLS);
			bprint("Shells enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOSHELLS;
			bprint("Shells disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);

		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 196)	//nails
	{
		if(savedgamecfg & SK_NONAILS)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NONAILS);
			bprint("Nails enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NONAILS;
			bprint("Nails disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 197)	//rockets
	{
		if(savedgamecfg & SK_NOROCKETS)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOROCKETS);
			bprint("Rockets enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOROCKETS;
			bprint("Rockets disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 198)	//cells
	{
		if(savedgamecfg & SK_NOCELLS)
		{
			savedgamecfg = savedgamecfg - (savedgamecfg & SK_NOCELLS);
			bprint("Cells enabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		else
		{
			savedgamecfg = savedgamecfg | SK_NOCELLS;
			bprint("Cells disabled.\n");
			sprint(self,"You have to restart the server.\n");
		}
		savedgamecfg = rint(savedgamecfg);
		MOTD = ftos(savedgamecfg);		//MOTD is a global string which is not used ATM
		cvar_set("savedgamecfg", MOTD);
	}
	else if(self.impulse == 199)	//hitzones
	{
		if(temp1 & T_HITZONES)
		{
			temp1 = temp1 - (temp1 & T_HITZONES);
			bprint("Hitzones disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_HITZONES;
			bprint("Hitzones enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 200)	//daminfo
	{
		if(temp1 & T_DAMAGEINFO)
		{
			temp1 = temp1 - (temp1 & T_DAMAGEINFO);
			bprint("Damage info disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_DAMAGEINFO;
			bprint("Damage info enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
/*
	else if(self.impulse == 201)	//teammatch2 currently disabled... bugs
	{
		if(teamplay & TEAM_MATCH2)
		{
			teamplay = teamplay - (teamplay & TEAM_MATCH2);
			bprint("Team Match mode 2 disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_MATCH2;
			bprint("Team Match mode 2 enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
*/
	else if(self.impulse == 202)	//gethead
	{
		if(deathmatch & D_GETHEAD)
		{
			deathmatch = deathmatch - (deathmatch & D_GETHEAD);
			bprint("GetHead-Game disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_GETHEAD;
			bprint("GetHead-Game enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 203)	//shead
	{
		if(deathmatch & D_SHAMBLERHEAD)
		{
			deathmatch = deathmatch - (deathmatch & D_SHAMBLERHEAD);
			bprint("Shamblerhead disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_SHAMBLERHEAD;
			bprint("Shamblerhead enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 204)	//hh
	{
		if(deathmatch & D_HH)
		{
			deathmatch = deathmatch - (deathmatch & D_HH);
			bprint("Hunter and Hunted disabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_HH;
			bprint("Hunter and Hunted enabled.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);
	}
	else if(self.impulse == 205)	//ctf
	{
		if(teamplay & TEAM_CTF)
		{
			teamplay = teamplay - (teamplay & TEAM_CTF);
			bprint("Capture the flag disabled.\n");
		}
		else
		{
			teamplay = teamplay | TEAM_CTF;
			bprint("Capture the flag enabled.\n");
		}
		teamplay = rint(teamplay);
		MOTD = ftos(teamplay);		//MOTD is a global string which is not used ATM
		cvar_set("teamplay", MOTD);
	}
	else if(self.impulse == 206)	//runes
	{
		if(temp1 & T_ALLOWRUNES)
		{
			temp1 = temp1 - (temp1 & T_ALLOWRUNES);
			bprint("Runes disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_ALLOWRUNES;
			bprint("Runes enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if(self.impulse == 207)	//hook
	{
		if(temp1 & T_ALLOWHOOK)
		{
			temp1 = temp1 - (temp1 & T_ALLOWHOOK);
			bprint("Grappling hook disabled.\n");
		}
		else
		{
			temp1 = temp1 | T_ALLOWHOOK;
			bprint("Grappling hook enabled.\n");
		}
		temp1 = rint(temp1);
		MOTD = ftos(temp1);		//MOTD is a global string which is not used ATM
		cvar_set("temp1", MOTD);
	}
	else if (self.impulse == 208)	//Mez Original Balance
		{
		if(deathmatch & D_ORIGBAL)
		{
			deathmatch = deathmatch - (deathmatch & D_ORIGBAL);
			bprint("Vastly Superior Weapon Balance Re-Enabled.\n");
		}
		else
		{
			deathmatch = deathmatch | D_ORIGBAL;
			bprint("Orginal Weapon Balance Restored.\n");
		}
		deathmatch = rint(deathmatch);
		MOTD = ftos(deathmatch);		//MOTD is a global string which is not used ATM
		cvar_set("deathmatch", MOTD);	
	}
	self.impulse = 0;
};

//-----------------------------------------------------------------------------------
// Observer Impulses
//-----------------------------------------------------------------------------------

void() ObserverImpulses =
{
	if((!temp1 & T_SERVERCLOSED) || (!self.client))
	{
		if((self.impulse == 103) && teamplay && (!self.genteam))
		{
			centerprint(self, "You have to choose your team first.", "", "", "");
			self.infotime = time + 1.5;
			if(!self.state & S_CHOOSINGTEAM)
				self.state = self.state | S_CHOOSINGTEAM;
			return;
		}
		if((self.impulse == 103) && (!gamestatus & G_STARTED))		//ready
		{
			if(self.state & S_READYPLAY)
			{
				sprint(self, "You are still ready to play.\n");
				return;
			}
			bprint(self.netname);
			if(self.state & S_READYOBSERVER)
				bprint(" changed from Observer to player.\n");
			else
				bprint(" is ready to play.\n");
			self.state = self.state - (self.state & (S_READYOBSERVER | S_READYPLAY));
			self.state = self.state | S_READYPLAY;
			if((!gamestatus & G_STARTING) && (!gamestatus & G_STARTING))
				CheckStartGame(0);
		}
		else if((self.impulse == 103) && (gamestatus & G_STARTED))	//ready
		{
			if(temp1 & T_JOINAVERAGEFRAGS)
				self.frags = AverageFrags();
			if((teamplay) && (!self.genteam) && (!self.state & S_CHOOSINGTEAM))
				self.state = self.state | S_CHOOSINGTEAM;
//			else if(!((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2)))
			else if(teamplay & TEAM_MATCH)
			{
				if(self.state & S_READYPLAY)
				{
					sprint(self, "You are still ready to play.\n");
					return;
				}
				bprint(self.netname);
				if(self.state & S_READYOBSERVER)
					bprint(" changed from Observer to player.\n");
				else
					bprint(" is ready to play.\n");
				self.state = self.state - (self.state & (S_READYOBSERVER | S_READYPLAY));
				self.state = self.state | S_READYPLAY;
			}
			else
			{
				CheckForDCP();
				PutClientInServer ();
			}
		}
	}
	else if (self.impulse == 103)
		sprint(self, "The server is closed, you have to stay in observer mode.\n");
	
	if((self.impulse == 104) && (!gamestatus & G_STARTED) && (!temp1 & T_SERVERCLOSED))		//observer
	{
		if(self.state & S_READYOBSERVER)
		{
			sprint(self, "You are still ready to observe.\n");
			return;
		}
		bprint(self.netname);
		if(self.state & S_READYPLAY)
			bprint(" changed from player to observer.\n");
		else
			bprint(" is ready to observe.\n");
		self.state = self.state - (self.state & (S_READYOBSERVER | S_READYPLAY));
		self.state = self.state | S_READYOBSERVER;
		if((!gamestatus & G_STARTED) && (!gamestatus & G_STARTING))
			CheckStartGame(0);
	}
	else if((self.impulse == 104) && ((gamestatus & G_STARTED) || ((temp1 & T_SERVERCLOSED) && (self.client))))
	{
		self.genteam = 0;
		PlayerObserverMode();
	}

	if((self.impulse == 107) && (!gamestatus & G_STARTED))		//break
	{
		if(deathmatch & D_HH)
		{
			sprint(self,"You may not stop the countdown in Hunter and Hunted.\n");
			return;
		}
		if(!((self.state & S_READYPLAY) || (self.state & S_READYOBSERVER)))
			sprint(self,"You were not ready.\n");
		else
		{
			bprint(self.netname);
			bprint(" is not ready anymore.\n");
			self.state = self.state - (self.state & (S_READYOBSERVER | S_READYPLAY));
		}
	}
	else if((self.impulse == 104) && (gamestatus & G_STARTED))
		sprint(self, "You may not vote for a cancellation of the match because you are an observer.\n");
};

//-----------------------------------------------------------------------------------
// Voting level Impulses
//-----------------------------------------------------------------------------------

/*
void() VoteLevelImpulses =
{
local float level;
local string slevel;

	level = rint(self.impulse - 240);
	slevel = ftos(level);

	if(level == 1)
	{
		//MEZ START
		if(self.state & S_VOTEREINC1)
		{
			self.state = self.state - (self.state & S_VOTEREINC1);
			sprint(self,"You cancelled your application to change the map to REINC1.\n");
			self.impulse = 0;
			return;
		}
		else
			self.state = self.state | S_BREAK;
			bprint("MSTEP 1: Someone voted for Map XXXXXXX\n"); //Mez Vote Check
			//self.impulse = 0;
			//return;
		if(CheckLevelChange2())
		{
			bprint("Majority of players switch to new level\n");
			changelevel("reinc1"); 
		}
		//MEZ END
		/*
		if(self.state & S_VOTEREINC1)
		{
			self.state = self.state - (self.state & S_VOTEREINC1);
			sprint(self,"You cancelled your application to change the map to REINC");
			sprint(self, slevel);
			sprint(self, ".\n");
			self.impulse = 0;
			return;
		}
		else
		{
			bprint("Someone voted for Map XXXXXXX\n"); //Mez Vote Check
			self.state = self.state | S_VOTEREINC1;
			self.impulse = 0;
			return;
		}
	}
	/*
	else if(level == 2)	//Mez Vote turn these from else if into "if"
	{
		if(self.state & S_VOTEREINC2)
		{
			self.state = self.state - (self.state & S_VOTEREINC2);
			sprint(self,"You cancelled your application to change the map to REINC");
			sprint(self, slevel);
			sprint(self, ".\n");
			self.impulse = 0;
			return;
		}
		else
		{
			self.state = self.state | S_VOTEREINC2;
			self.impulse = 0;
			return;
		}
	}
	else if(level == 3)
	{
		if(self.state & S_VOTEREINC3)
		{
			self.state = self.state - (self.state & S_VOTEREINC3);
			sprint(self,"You cancelled your application to change the map to REINC");
			sprint(self, slevel);
			sprint(self, ".\n");
			self.impulse = 0;
			return;
		}
		else
		{
			self.state = self.state | S_VOTEREINC3;
			self.impulse = 0;
			return;
		}
	}
	else if(level == 4)
	{
		if(self.state & S_VOTEREINC4)
		{
			self.state = self.state - (self.state & S_VOTEREINC4);
			sprint(self,"You cancelled your application to change the map to REINC");
			sprint(self, slevel);
			sprint(self, ".\n");
			self.impulse = 0;
			return;
		}
		else
		{
			self.state = self.state | S_VOTEREINC4;
			self.impulse = 0;
			return;
		}
	}
	else if(level == 5)
	{
		if(self.state & S_VOTEREINC5)
		{
			self.state = self.state - (self.state & S_VOTEREINC5);
			sprint(self,"You cancelled your application to change the map to REINC");
			sprint(self, slevel);
			sprint(self, ".\n");
			self.impulse = 0;
			return;
		}
		else
		{
			self.state = self.state | S_VOTEREINC5;
			self.impulse = 0;
			return;
		}
	}
	*/
/*
	else if(level == 6)
	{
		if(self.state & S_VOTEREINC6)
		{
			self.state = self.state - (self.state & S_VOTEREINC6);
			sprint(self,"You cancelled your application to change the map to REINC");
			sprint(self, slevel);
			sprint(self, ".\n");
			self.impulse = 0;
			return;
		}
		else
		{
			self.state = self.state | S_VOTEREINC6;
			self.impulse = 0;
			return;
		}
	}
*/
	/*
	if(!CheckChangeLevel())	//Mez Original was: if(!CheckChangeLevel(level))
	{
		bprint("MSTEP 2: Check for Changelevel thing in impulses\n"); //Mez Vote Check
		bprint(self.netname);
		bprint(" has voted for map REINC");
		bprint(slevel);
		bprint(".\nType vote_reinc");
		bprint(slevel);
		bprint(" to vote for it, too.\n");

		sprint(self,"Not enough players have voted for REINC");
		sprint(self, slevel);
		sprint(self, " to change the map.\n");
	}
	*/
//};
