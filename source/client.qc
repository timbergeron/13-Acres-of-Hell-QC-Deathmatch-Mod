// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;
// CTF ->
void() UnHookPlayer;
// CTF <-

float	modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

//float	intermission_running;	GeN: moved to teamplay.qc
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};



void() SetChangeParms =
{
/* GeN
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}

// remove items
	self.items = self.items - (self.items & 
	(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );
	
// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;
 GeN don't keep items on level change*/

	SetNewParms ();
};

void() SetNewParms =
{
// < GeN
	parm1 = IT_SHOTGUN | IT_AXE;
	if(deathmatch & D_MOREHEALTH)
		parm2 = DM_MOREHEALTH_MAXHEALTH;
	else
// GeN >
		parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
};

void() DecodeLevelParms =
{
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;

	// *XXX* EXPERT CTF

	// Reset times for additional scoring system on level change and server join
	// dprint("decode level parms\n");
	self.last_returned_flag = -10;
	self.last_fragged_carrier = -10;
	self.flag_since = -10;
	self.last_hurt_carrier = -10;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
};



//~ FrikBot changes and Mezmorki additons
string nextmap;
float done_changelevel;
void() GotoNextMap ={
	local float p;
	if (done_changelevel) {
		return;
	}
	done_changelevel = TRUE;
	p = cvar("samelevel");
	if (p > 1) {
		localcmd("map");
		localcmd(ftos(ceil(random() * p)));
		localcmd("\n");
	}
	else if (p < 0) {
		localcmd("map");
		localcmd(ftos(floor(serverflags/16)+1));
		localcmd("\n");
		serverflags = serverflags+16;
		if (floor((serverflags/16)+1) > (0 - p)) {
			serverflags = serverflags & 16;
		}
	}
	else if (p) {
		// if samelevel is set, stay on same level
		changelevel (mapname);
	}
	else {
		changelevel (nextmap);
	}
};


void() ExitIntermission =
{
// skip any text in deathmatch
/* GeN always dm
	if (deathmatch)
	{
 GeN */

		GotoNextMap ();
		return;

/* GeN always dm
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}

		GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
		
	}

	GotoNextMap();
 GeN */

};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}	

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void() changelevel_touch =
{
	local entity	pos;

	if (other.classname != "player")
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000, 0);
		return;
	}

	if (deathmatch)
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}
	
	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	self.offhandhook = 0; //MEZ added to reset hook state
	// make a copy of the dead body for appearances sake
	if(teamplay & TEAM_MATCH2)
	{
		if(self.tm2 < 10)
			MakeRBody(self);
	}
	else
		CopyToBodyQue (self);
	// set default spawn parms
	SetNewParms ();
	// respawn		
// < GeN
	if((teamplay & TEAM_MATCH2) && (self.tm2 >= 10))
	{
		ccenterprint(self, "You have been resurrected.");
		PutClientInServer ();
	}
	else if((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2))
	{
		PlayerObserverMode();
		self.state = self.state | S_BECOMECAM;
	}
	else
	{
		PutClientInServer ();
	}
// GeN >
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	local float tl;
	local entity head, lh;

// < GeN
	if (intermission_running)
		return;
// KasCam ->
    if (self.classname == "KasCam") {
        return;
    }
// <- KasCam
	if(self.mode == M_OBSERVER)
	{
		sprint(self, "You cannot suicide while in Observer mode.\n");
		return;
	}
	if(temp1 & T_SUICIDEPROTECTION)
	{
		if(self.suicides > 4)
		{
			sprint(self, "You may not suicide more than 5 times");
			return;
		}
		self.suicides = self.suicides + 1;	
	}
	if((self.hashead) && (deathmatch & D_GETHEAD))
	{
		self.hashead = FALSE;
		head = find(world, classname, "head");
		if(head != world)
			head.owner = world;
			self.skin = 3; //Mez AvP skin to barbarian
		bcenterprint(self.netname, "\n\bhas fumbled the head.\b", "", "", "shambler/sdeath.wav");
	}
	if(deathmatch & D_HH)
	{
		if(self.genteam == THUNTED)
		{
			SetTeam(self, THUNTER);
			ccenterprint(self, "You are now hunter.");
		}
		lh = LastHunted();
		if(lh)
		{
			bcenterprint(lh.netname, " has won this round.", "", "", "");
			lh.frags = lh.frags + 10;
			InitRR(lh);
		}
	}
// GeN >

	bprint (self.netname);
	bprint (" suicides\n");
// CTF ->
	DropRune();
	TeamCaptureDropFlagOfPlayer(self);
	UnHookPlayer();
// CTF <-
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
// GeN >
	if((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2))
		CheckRoundEnd();
	else if(teamplay)
		ApplyTeamFrags(self);
// < GeN
	respawn ();
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local	entity thing;
	local	float  pcount;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
		
// choose a info_player_deathmatch point
	if (deathmatch)
	{
		spot = lastspawn;
		while (1)
		{
			spot = find(spot, classname, "info_player_deathmatch");
			if (spot != world)
			{
				if (spot == lastspawn)
					return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 32);
				while(thing)
				{
					if (thing.classname == "player")
						pcount = pcount + 1;
					thing = thing.chain;
				}
				if (pcount == 0)
				{
					lastspawn = spot;
					return spot;
				}
			}
		}
	}

/* GeN not needed
	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}
*/	

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");
	
	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;


void() PutClientInServer =
{
	local	entity spot;
	local   string cms, tcolor;

// < GeN 
//	spot = SelectSpawnPoint ();
	spot = GeNSelectSpawnPoint ();
// GeN >

	self.classname = "player";
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
// < GeN 
	if(deathmatch & D_MOREHEALTH)
		self.max_health = DM_MOREHEALTH_MAXHEALTH;
	else
// GeN >
		self.max_health = 100;
// < GeN 
	self.waterlevel = 0;
	if(deathmatch & D_MOREHEALTH)
		self.health = 200;
	else
// GeN >
		self.health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
// CTF ->
	self.staydeadtime = 0;
	self.regen_time = 0;
	self.rune_notice_time = 0;
	self.runedelay = 0; //MEZ Added rune pickup delay flag

	self.last_hurt_carrier = -10;
	self.player_flag = 0;
// CTF <-

	DecodeLevelParms ();
	
	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
//	spot = SelectSpawnPoint ();
// GeN	self.origin = spot.origin + '0 0 1';
	self.origin = self.oldorigin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;
	
	if(deathmatch & D_GETHEAD)	//Mez AvP mode set skin for respawners
		self.skin = 3; //Mez

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

// < GeN
	if(temp1 & T_ALLOWHOOK)
		self.items = self.items | IT_HOOK;
	
	if(deathmatch & D_ALLWEAPONS)
	{
		self.items = self.items | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING;
		self.ammo_shells = 100;
		self.ammo_nails = 200;
		self.ammo_rockets = 100;
		self.ammo_cells = 100;
		self.weapon = IT_ROCKET_LAUNCHER;
		W_SetCurrentAmmo ();
	}
	else if(deathmatch & D_INFINITEAMMO)
	{
		self.ammo_shells = 100;
		self.ammo_nails = 200;
		self.ammo_rockets = 100;
		self.ammo_cells = 100;
	}
	if(deathmatch & D_FULLARMOR)	// modified by Mezmorki to start with green armor
	{
		self.armortype = 0.5;
		self.armorvalue = 100;
		self.items = self.items | IT_ARMOR1;
	}
	if((deathmatch & D_BERSERKDM) && (gamestatus & G_BERSERKMODE))
	{
		self.items = self.items | IT_QUAD;
		self.super_time = 1;
		self.super_damage_finished = time + 30;
	}
	if(temp1 & T_RPROTECTION)
		self.rprotecttime = time + 3;

	stuffcmd(self,"v_cshift 0 0 0 255\n");
	stuffcmd(self, "cl_rollangle 2\n");
	stuffcmd(self,"v_cshift 0 0 0 0\n");

	self.velocity = '0 0 0';	//old velocity bug
	self.weaponallowed = TRUE;
	self.mode = M_PLAYER;
	self.ringtime = 0;
	self.quadtime = 0;
	self.nexthurt = 0;
	self.lastplayerinview = "";
	self.viewupdatetime = 0;

//	if(!teamplay)
//		RestoreColormap(self);

// GeN >

	player_stand1 ();
	
	if (deathmatch)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);
	
	if((teamplay || (deathmatch & D_HH)) && (self.genteam))
		SetTeam(self, self.genteam);

// *************************************************************************
// **								          **
// ** M U L T I S K I N  1.1  (start)        centerprint                  **
// **									  **
// *************************************************************************

		if (self.skin == 0) sprint(self, "Respawning as Quakeguy\n"); else
		if (self.skin == 1) sprint(self, "Respawning as... Doomguy\n"); else
		if (self.skin == 2) sprint(self, "Respawning as... Arnold the Terminator\n"); else
		if (self.skin == 3) sprint(self, "Respawning as... Arnold the Conan\n"); else
		if (self.skin == 4) sprint(self, "Respawning as... The Predator\n"); else
		if (self.skin == 5) sprint(self, "Respawning as... The Punisher\n"); else
		if (self.skin == 6) sprint(self, "Respawning as... The Highlander\n"); else
		if (self.skin == 7) sprint(self, "Respawning as... Klingon\n"); else
		if (self.skin == 8) sprint(self, "Respawning as... Robocop\n"); else
		if (self.skin == 9) sprint(self, "Respawning as... T-800\n"); else
		if (self.skin == 10) sprint(self, "Respawning as... Vincent\n"); else
		if (self.skin == 11) sprint(self, "Respawning as... Tigger\n"); else
		if (self.skin == 12) sprint(self, "Respawning as... Lord Arioch\n"); else
		if (self.skin == 13) sprint(self, "Respawning as... Hellboy\n"); else
		if (self.skin == 14) sprint(self, "Respawning as... Skeleton\n"); else
		if (self.skin == 15) sprint(self, "Respawning as... Skull Demon\n"); else
		if (self.skin == 16) sprint(self, "Respawning as... Cowabunga Turtle!\n"); else
		if (self.skin == 17) sprint(self, "Respawning as... Zombie Biker\n"); else
		if (self.skin == 18) sprint(self, "Respawning as... Canadian Mountie\n"); else
		if (self.skin == 19) sprint(self, "Respawning as... Bad Biker Chic\n"); else
		if (self.skin == 20) sprint(self, "Respawning as... Gladiatress\n"); else
		if (self.skin == 21) sprint(self, "Respawning as... Army Ranger\n"); else
		if (self.skin == 22) sprint(self, "Respawning as... Smiley Face Guy\n"); else
		if (self.skin == 23) sprint(self, "Respawning as... Taximan\n)"); else
		if (self.skin == 24) sprint(self, "Respawning as... Alien Astronaut\n"); else
		if (self.skin == 25) sprint(self, "Respawning as... Swedish Mobster\n"); else
		if (self.skin == 26) sprint(self, "Respawning as... Spawn\n"); else
		if (self.skin == 27) sprint(self, "Respawning as... The Tick\n"); else
		if (self.skin == 28) sprint(self, "Respawning as... Stormtrooper\n"); else
		if (self.skin == 29) sprint(self, "Respawning as... Chewbacca\n"); else
		if (self.skin == 30) sprint(self, "Respawning as... C-3PO\n"); else
		if (self.skin == 31) sprint(self, "Respawning as... Boba Fett\n");

// *************************************************************************
// **								          **
// ** M U L T I S K I N  1.1  (end)                                       **
// **									  **
// *************************************************************************


};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
	local   string cms;


	self.classname = "testplayer";
	self.netname = "dummer bot";
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.show_hostile = 0;
	self.health = 99999900;
	self.flags = FL_MONSTER;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
	
	self.fixangle = TRUE;		// turn this way immediately

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

	self.velocity = '0 0 0';	//old velocity bug

	player_stand1 ();
	
	if (deathmatch)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/

// CTF ->
void() SpawnRunes;
// CTF <-

void() info_player_deathmatch =
{
// CTF ->
	temp1 = cvar("temp1");
	if((temp1 & T_ALLOWRUNES) && (deathmatch))
		StartRuneSpawn();
// CTF <-
};

// CTF ->
void() info_player_team1 =
{
};

void() info_player_team2 =
{
};
// CTF <-

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;
// < GeN
	nextmap = "";
	if (mapname == "start")
		nextmap = "reinc1";
	else if (mapname == "reinc1")
		nextmap = "reinc2";
	else if (mapname == "reinc2")
		nextmap = "reinc3";
	else if (mapname == "reinc3")
		nextmap = "reinc4";
	else if (mapname == "reinc4")
		nextmap = "reinc5";
	else if (mapname == "reinc5")
		nextmap = "reinc1";
	if(nextmap == "")
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
			nextmap = "start";
		else
			nextmap = o.map;
	}
	if(!o)
	{
		o = spawn();
		o.map = nextmap;
	}
// GeN >

	gameover = TRUE;
	
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
// < GeN 
	if (timelimit)
	{
		if(time >= timelimit)
		{
			if(MatchIsTied())
			{
				if(time = timelimit)
					bcenterprint("Game is a tie!\nSUDDEN DEATH mode activated because overtime is set.", "", "", "", "");
				return;
			}
			NextLevel ();
			return;
		}
		else
			TimeAlert();
	}
	
	if (fraglimit && (self.frags >= fraglimit) && (!((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2))))	//if teammatch only end when team reaches fraglimit!
// GeN >
	{
		NextLevel ();
		return;
	}	
};

//============================================================================

void() PlayerDeathThink =
{
	local entity	old_self;
	local float		forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
	local vector start, end;
	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

// play swiming sound
// < GeN 
//		if (self.swim_flag < time)
// GeN >
		if ((self.swim_flag < time) && (self.mode != M_OBSERVER))
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
	
	self.button2 = 0;
// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg, 0);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{	
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel, 0);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel, 0);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{	

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if ((! (self.flags & FL_WATERJUMP) ) && (self.mode == M_PLAYER))
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	if (BotPreFrame()) // FrikBot
	return;

	local	float	x, y;

	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

	makevectors (self.v_angle);		// is this still used

	CheckRules ();
	WaterMove ();

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';
// CTF ->
// RUNE: If player has rune of elder magic (4), regeneration	//MEZ increased cap (was 150) and rate (was 5)
	if ((self.player_flag & ITEM_RUNE4_FLAG) || ((deathmatch & D_GETHEAD) && (self.hashead))) //Mez Avp Added second argument
		{
		if (self.regen_time < time) {
			self.regen_time = time;
			if (self.health < 150) {
				self.health = self.health + 10;
				if (self.health > 150)
					self.health = 150;
				self.regen_time = self.regen_time + 0.5;
				RegenerationSound();
			}
			if (self.armorvalue < 200 && (self.armortype == 0.8)) // MEZ, originally: if (self.armorvalue < 200 && self.armortype)
			{
				self.armorvalue = self.armorvalue + 5;
				if (self.armorvalue > 200)
					self.armorvalue = 200;
				self.regen_time = self.regen_time + 0.5;
				RegenerationSound();
			}
			if (self.armorvalue < 150 && ( ( (self.armortype == 0.65) && (!deathmatch & D_ORIGBAL) ) || ( (self.armortype == 0.5) && (deathmatch & D_ORIGBAL) ) ) ) // MEZ, add this block
			{
				self.armorvalue = self.armorvalue + 5;
				if (self.armorvalue > 150)
					self.armorvalue = 150;
				self.regen_time = self.regen_time + 0.5;
				RegenerationSound();
			}
			if (self.armorvalue < 100 && ( ( (self.armortype == 0.5) && (!deathmatch & D_ORIGBAL) ) || ( (self.armortype == 0.3) && (deathmatch & D_ORIGBAL) ) ) )  // MEZ, add this block
			{
				self.armorvalue = self.armorvalue + 5;
				if (self.armorvalue > 100)
					self.armorvalue = 100;
				self.regen_time = self.regen_time + 0.5;
				RegenerationSound();
			}
		}
	}
// RUNE
// CTF <-

/*
// < GeN
	if(self.mode == M_OBSERVER)
	{
		if((rint(self.velocity_x * 0.02) == 0) && (rint(self.velocity_y * 0.02) == 0))
			self.velocity_z = 0;
	}
// GeN >
*/

// CTF ->
	if(time > self.attack_finished && self.currentammo == 0 && 
		self.weapon != IT_AXE && self.weapon != IT_HOOK)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}
// CTF <-
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;	// don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
// < GeN
	if ((self.super_damage_finished) || (self.state & S_BERSERK))
// GeN >
	{
// sound and screen flash when items starts to run out

// < GeN
		if ((self.super_damage_finished < time + 3) && (!self.state & S_BERSERK))
// GeN >
		{
			if (self.super_time == 1)
			{
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
// < GeN
		if ((self.super_damage_finished < time) && (!self.state & S_BERSERK))
// GeN >
		{	// just stopped
			self.items = self.items - (self.items & IT_QUAD);
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
// < GeN
		if ((self.super_damage_finished > time) || (self.state & S_BERSERK))
		{
			if (self.health > 0)
// GeN >
				self.effects = self.effects | EF_DIMLIGHT;
// < GeN
		}
// GeN >
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}
	else if ((self.invincible_finished < time) && (self.super_damage_finished < time) && (!self.state & S_BERSERK))
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);

// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	
// < GeN 
	if(deathmatch & D_DARKDM)
	{
		if((self.state & S_TORCHON) && (self.health > 0))
			self.effects = self.effects | EF_DIMLIGHT;
		else if((self.super_damage_finished < time) && (self.invincible_finished < time))
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}
// GeN >
};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/

void() PlayerPostThink =
{
if (BotPostFrame()) // FrikBot
	return;

local float wt;
local entity e;

// GeN KasCam ->
    if ((self.classname == "KasCam") && !intermission_running)
    {
        CamThink();
        return;
    }
// <- KasCam

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale
	if (self.deadflag)
		return;
		
// do weapon stuff

	W_WeaponFrame ();
// < GeN 

	if(self.starttime == 0)
		self.starttime = time + 4;
	if((self.starttime > time) && (self.infotime < time))
	{
		self.infotime = time + 1.5;
		DisplayInfo ();
	}
	if((self.state & S_CHOOSINGTEAM) && (self.infotime < time) && (self.starttime < time) && (!temp1 & T_SERVERCLOSED))
	{
		if(teamplay & TEAM_AUTOJOIN)
		{
			wt = TeamToJoin();
			if(wt == 0)
			{
				wt = FreeTeam();
				if(wt)
					CreateTeam(wt);
			}
			else
			{
				if(TeamExists(wt))
					JoinTeam(wt);
				else
					CreateTeam(wt);
			}
		}
		else
		{
			self.infotime = time + 1.5;
			DisplayTeamMenu();
		}
	}
	if(self.checktime < time)	//should be used for various not so important checks
	{
		if(teamplay)
		{
			if(!self.client)
			{
				if(!TeamExists(TRED))
					RemoveSpecificTeamplayScoreposition(redteam);
				if(!TeamExists(TBLUE))
					RemoveSpecificTeamplayScoreposition(blueteam);
				if(!TeamExists(TGREEN))
					RemoveSpecificTeamplayScoreposition(greenteam);
				if(!TeamExists(TBROWN))
					RemoveSpecificTeamplayScoreposition(brownteam);
				if(!TeamExists(TYELLOW))
					RemoveSpecificTeamplayScoreposition(yellowteam);
				if(!TeamExists(TWHITE))
					RemoveSpecificTeamplayScoreposition(whiteteam);
			}
			if(teamplayon == FALSE)
				teamplayon = TRUE;
/*
			if((self.team != self.lastteam) && (self.state & S_TEAMCHOSEN) && (self.genteam) && (!self.state & S_CHANGEDTEAM))
			{
				SetTeam(self, self.genteam);
				sprint(self, "You are not allowed to change your team manually.\n");
				if(!teamplay & TEAM_NOCHANGE)
					sprint(self, "To change your team type: цхангетеам.\n");
			}
*/
		}
		else 
		{
			if(teamplayon)
			{
				teamplayon = FALSE;
				RemoveTeamplayScorepositions();
			}
		}
		self.state = self.state - (self.state & S_CHANGEDTEAM);
		self.lastteam = self.genteam;
		
		self.checktime = time + 2;
	}
	if (self.state & S_ORGINFO)
	{
		bprint("Origin: ");
		bprint(vtos(self.origin));
		bprint("\n");
		bprint("Viewangles: ");
		bprint(vtos(self.v_angle));
		bprint("\n");
	}
	if(self.state & S_BECOMECAM)
	{
		self.state = self.state - (self.state & S_BECOMECAM);
		CamClientInit();
	}
// GeN >

// check to see if player landed and play landing sound	
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, world, 5, 0); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	if((self.viewupdatetime < time) && (NumberOfPlayers() > 2) && self.id)
	{
		self.viewupdatetime = time + 0.8;
		e = PlayerInView();
		if(e == world)
			self.lastplayerinview = "";
		else if (e.netname != self.lastplayerinview)
		{
			self.lastplayerinview = e.netname;
			centerprint(self, e.netname, "", "", "");
		}
	}

	CheckPowerups ();
};

// < GeN 
void() ConnectThink =
{
local entity stemp;
        
	stemp = self;
	self = self.owner;
	self.impulse = 0;
	self.suicides = 0;
	self.genteam = 0;
	self.lastteam = self.team;
	self.id = 0;
	if(gamestatus & G_SERVERENTEREDGAME)
		self.client = TRUE;
	else
	{
		self.client = FALSE;
		gamestatus = gamestatus | G_SERVERENTEREDGAME;
	}

	DisplaySettings();
	if((self.client) && (temp1 & T_SERVERCLOSED))
	{
		bprint (self.netname);
		bprint (" tried to enter the game\n");
		sprint(self, "You were disconnected because the server is closed.\n");
		stuffcmd(self, "disconnect\n");
	}
	else
	{
		bprint (self.netname);
		bprint (" entered the game\n");
	}

	self.scorepos = gscorepos;
	gscorepos = gscorepos + 1;

	InitMod();

// KasCam ->
	if ((self.netname == "CamClient") || (self.netname == ""))
	{
		self.impulse = 250;
		self = stemp;
		remove(self);
		return;
	}
// <- KasCam

	if((temp1 & T_ALLOWOBSERVER) || (teamplay) || (deathmatch & D_HH))
		PlayerObserverMode ();
	else
	{
		if(!gamestatus & G_STARTED)
			gamestatus = gamestatus | G_STARTED;
		else if (gamestatus & G_STARTED)
		{
			if(temp1 & T_JOINAVERAGEFRAGS)
				self.frags = AverageFrags();
			CheckForDCP();
		}
	}
	self = stemp;
	remove(self);
};
// GeN >

/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
ClientInRankings(); // FrikBot	//MEZ Disable test

local entity otimer;

	if((gscorepos + 1) >= maxplayers)
		RemoveTeamplayScoreposition();	

// < GeN 
	otimer = spawn();
   	otimer.owner = self;
	otimer.nextthink = time;
   	otimer.think = ConnectThink;
// GeN >
	
// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
ClientDisconnected(); // FrikBot
// < GeN
	local entity dcplayer;
	local string cms;

	gscorepos = gscorepos - 1;
	if(teamplay)
		FindTeamForScorepos(self.scorepos);
// GeN >


	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
// < GeN
	dcplayer = spawn();
	dcplayer.netname = self.netname;
	dcplayer.frags = self.frags;
	dcplayer.team = self.team;
	dcplayer.genteam = self.genteam;
	dcplayer.delay = time;			//store the time when the player left
	dcplayer.classname = "dcplayer";

	//leave with the correct colormap
//	RestoreColormap(self);
	self.genteam = 0;
	RemoveNotUsedTeamplayScorepositions();

// CTF ->
	DropRune();
	TeamCaptureDropFlagOfPlayer(self);

// CTF <-
// GeN >

// KasCam ->
    if (CamDisconnect()) {
// KasCam <-

// < GeN don't glow after disconnected
		self.effects = 0;
		self.health = 0;
// GeN >
		bprint (self.netname);
		bprint (" left the game with ");
		bprint (ftos(self.frags));
		bprint (" frags.\n");
		sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
		set_suicide_frame ();
// KasCam ->
    }
// <- KasCam
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{
// CTF ->
	// *XXX* EXPERT CTF variable for 
	// flag/flag carrier defense bonus determination
	local	entity head;
	local float flag_radius;
	local float flag_carrier_radius;
	local string s;
// CTF <-

	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

	if (targ.classname == "player")
	{
// CTF ->
		// *XXX* EXPERT CTF: 
		// When the flag carrier dies, reset the last_hurt_carrier field in
		// all players on the opposite team from the flag carrier.  The carrier
		// has been killed, so there is no longer a reason to award points for
		// killing off his assailants
		if (targ.player_flag & ITEM_ENEMY_FLAG) 
		{
			head = find(world, classname, "player");

			while (head != world) 
			{	
				if (head.team != targ.team) 
				{
					head.last_hurt_carrier = -10;
				}
				head = find(head, classname, "player");
			}
		}
		// END EXPERT CTF
// CTF <-
		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
			bprint ("\n");
// < GeN
			if(!((deathmatch & D_GETHEAD) || (deathmatch & D_SHAMBLERHEAD) || ((deathmatch & D_HH) && (attacker.owner.genteam != THUNTER))))
			{
				attacker.owner.frags = attacker.owner.frags + 1;
				if(teamplay)
					ApplyTeamFrags(attacker.owner);
			}
// GeN >
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

// < GeN 
			if(!((deathmatch & D_GETHEAD) || (deathmatch & D_SHAMBLERHEAD) || (deathmatch & D_HH)))
			{
				targ.frags = targ.frags - 1;
				if(teamplay)
					ApplyTeamFrags(targ);
			}
// GeN >
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
// < GeN 
				attacker.frags = attacker.frags - 1;
				if(teamplay)
					ApplyTeamFrags(attacker);
// GeN >
				bprint (targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					bprint (" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER)
					bprint (" tries to put the pin back in\n");
				else
					bprint (" becomes bored with life\n");
				return;
			}
			else if ((teamplay) && (targ.genteam > 0)&&(targ.genteam == attacker.genteam) )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (attacker.netname);
				bprint (deathstring);
// < GeN 
				if(teamplay & TEAM_FRAGPENALTY)
				{
					attacker.frags = attacker.frags - 1;
					ApplyTeamFrags(attacker);
				}
// GeN >
				return;
			}
			else
			{
// < GeN 
				if(!(((deathmatch & D_GETHEAD) && (!attacker.hashead)) || (deathmatch & D_SHAMBLERHEAD) || ((deathmatch & D_HH) && (attacker.genteam != THUNTER)))) //MeZ AvP - modified first condition. Originally: (deathmatch & D_GETHEAD)
				{
					attacker.frags = attacker.frags + 1;
// CTF ->
 					if ((targ.player_flag & ITEM_ENEMY_FLAG) && (targ.team != attacker.team)) 
					{
 						//ZOID: one team fragged the other team's flag carrier
 
 						// *XXX* EXPERT CTF
 						// Mark the attacker with the time at which he killed the flag
 						// carrier, for awarding assist points
 
 						attacker.last_fragged_carrier = time;
 
 						// *XXX* EXPERT CTF: give player only the normal amount of frags
 						// if the carrier has only had the flag for a few seconds, to
 						// prevent ppl intentionally allowing enemies to grab the flag,
 						// then immediately fragging them
 
 						if (targ.flag_since + TEAM_CAPTURE_CARRIER_FLAG_SINCE_TIMEOUT > time) 
						{
 							sprint(attacker, "Enemy flag carrier killed, no bonus\n");
 						}
						else
						{
 							attacker.frags = attacker.frags + TEAM_CAPTURE_FRAG_CARRIER_BONUS;
                         			// TeamScore (attacker, TEAM_CAPTURE_FRAG_CARRIER_BONUS);
 							sprint(attacker, "Enemy flag carrier killed: ");
 							s = ftos(TEAM_CAPTURE_FRAG_CARRIER_BONUS);
 							sprint(attacker, s);
 							sprint(attacker, " bonus frags\n");
 						}
 						// END FLAG CARRIER FRAG CODE
 					}
 					
 					// *XXX* EXPERT CTF
 					// This code checks for all game-critical kills OTHER THAN fragging the enemy
 					// flag carrier, like killing players who are trying to kill your flag carrier
 					// or trying to grab your flag, and hands out bonus frags.
 
 					// The two variables below track whether special bonus frags have already
 					// been awarded for the attacker or target being near the flag or flag carrier.  
 
 					flag_radius = 0;
 					flag_carrier_radius = 0;
 
 					// get a string for the attacker's team now, for later announcements
 					s = GetCTFTeam(attacker.team);
 
 					if ((targ.last_hurt_carrier + TEAM_CAPTURE_CARRIER_DANGER_PROTECT_TIMEOUT > time) &&
 					    !(attacker.player_flag & ITEM_ENEMY_FLAG) ) 
					{
 						// a player on the same team as the flag carrier killed 
 						// someone who recently shot the flag carrier
 						attacker.frags = attacker.frags + 
 							TEAM_CAPTURE_CARRIER_DANGER_PROTECT_BONUS;
 						flag_carrier_radius = 1;
 						// NOTE: getting CARRIER_DANGER_PROTECT_BONUS precludes getting
 						// other kinds of bonuses for defending the flag carrier, since
 						// it's worth more points
 						bprint(attacker.netname);
 						bprint(" defends ");
 						bprint(s);
 						bprint("'s flag carrier against an agressive enemy\n");
 					}
 
 					// *XXX* EXPERT CTF
 					// Bonusus for defending the flag carrier or the flag itself.
 					// Extra frags are awarded if either the attacker or the target are
 					// 1. within 40 feet of a flag carrier on the same team as the attacker
 					// 2. within 40 feet of the attacker's flag
 					// These bonuses are cumulative with respect to defending both the
 					// flag and the flag carrier at the same time, but not cumulative with
 					// respect to both the target and attacker being near the object being defended
 
 					// find flags or flag carriers within a radius of the attacker
 					head = findradius(attacker.origin, TEAM_CAPTURE_ATTACKER_PROTECT_RADIUS);
 
 					while (head) 
					{
 						if (head.classname == "player") 
						{
 							if ( (head.team == attacker.team) &&
 							     (head.player_flag & ITEM_ENEMY_FLAG) &&
 							     (head != attacker) && // self defense
 							     (!flag_carrier_radius) ) 
							{ 
								// attacker was near his own flag carrier
 								attacker.frags = attacker.frags + 
 									TEAM_CAPTURE_CARRIER_PROTECT_BONUS;
 								flag_carrier_radius = 1;
 								bprint(attacker.netname);
 								bprint(" defends ");
 								bprint(s);
 								bprint("'s flag carrier\n");
 							}
 						}
 						if ( (head.classname == "item_flag_team1") ||
 						     (head.classname == "item_flag_team2")) 
						{
 							if (((attacker.team == TBLUE) &&
								(head.classname == "item_flag_team1")) ||
 								((attacker.team == TRED) &&
 								(head.classname == "item_flag_team2"))) 
							{ 
								// attacker was near his own flag
 								attacker.frags = attacker.frags + 
 									TEAM_CAPTURE_FLAG_DEFENSE_BONUS;
 								flag_radius = 1; 
 								bprint(attacker.netname);
 								bprint(" defends the ");
 								bprint(s);
 								bprint(" flag\n");
 							}
 						}
 						head = head.chain;
 					}
 
 					// find flags or flag carriers within a radius from the target
 					head = findradius(targ.origin, TEAM_CAPTURE_TARGET_PROTECT_RADIUS);
 					while (head) 
					{
 						if (head.classname == "player") 
						{
 							if ( (head.team == attacker.team) &&
 							     (head.player_flag & ITEM_ENEMY_FLAG) &&
 							     (head != attacker) &&
 							     (!flag_carrier_radius)) 
							{ // prevents redundant points awarded
 								// target was near attacker's flag carrier
 								attacker.frags = attacker.frags + 
 									TEAM_CAPTURE_CARRIER_PROTECT_BONUS;
 								flag_carrier_radius = 1;
 								bprint(attacker.netname);
 								bprint(" defends ");
 								bprint(s);
 								bprint("'s flag carrier\n");
 							}
 						}
						if (((attacker.team == TBLUE) &&
							(head.classname == "item_flag_team1")) ||
							((attacker.team == TRED) &&
							(head.classname == "item_flag_team2"))
							&& (!flag_radius)) 
						{ // prevents redundant points awarded
							// target was near attacker's flag
							attacker.frags = attacker.frags + 
								TEAM_CAPTURE_FLAG_DEFENSE_BONUS;
							flag_radius = 1;
							bprint(attacker.netname);
							bprint(" defends the ");
							bprint(s);
							bprint(" flag\n");
						}
 						head = head.chain;
 					}
 			 
 				// *XXX* EXPERT CTF 
 				// End frag determination code.  Now determine death text for
 				// a member of one team killing a member of the other
// CTF <-
					if(teamplay)
						ApplyTeamFrags(attacker);
				}
// GeN >

				rnum = attacker.weapon;
				if (rnum == IT_AXE)
				{
					deathstring = " was ax-murdered by ";
// < GeN 
					if(attacker.items & IT_QUAD)
					{
						if(deathmatch & D_OCTADAMAGE)
							deathstring2 = "'s octa axe\n";
						else
							deathstring2 = "'s quad axe\n";
					}
					else
// GeN >
						deathstring2 = "\n";
				}
// CTF ->
				if (rnum == IT_HOOK) {
					if (random() < 0.5)
						deathstring = " was disembowled by ";
					else
						deathstring = " was hooked by ";
					deathstring2 = "\n";
				}
// CTF <-
				if (rnum == IT_SHOTGUN)
				{
					deathstring = " chewed on ";
// < GeN 
					if(attacker.items & IT_QUAD)
					{
						if(deathmatch & D_OCTADAMAGE)
							deathstring2 = "'s octa boomstick\n";
						else
							deathstring2 = "'s quad boomstick\n";
					}
					else
// GeN >
						deathstring2 = "'s boomstick\n";
				}
				if (rnum == IT_SUPER_SHOTGUN)
				{
					deathstring = " ate 2 loads of ";
// < GeN 
					if(attacker.items & IT_QUAD)
					{
						if(deathmatch & D_OCTADAMAGE)
							deathstring2 = "'s octa buckshot\n";
						else
							deathstring2 = "'s quad buckshot\n";
					}
					else
// GeN >
					deathstring2 = "'s buckshot\n";
				}
				if (rnum == IT_NAILGUN)
				{
// < GeN 
					if(attacker.items & IT_QUAD)
					{
						if(deathmatch & D_OCTADAMAGE)
							deathstring = " was octa-nailed by";
						else
							deathstring = " was quad-nailed by";
					}
					else
// GeN >
						deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_SUPER_NAILGUN)
				{
// < GeN 
					if(attacker.items & IT_QUAD)
					{
						if(deathmatch & D_OCTADAMAGE)
							deathstring = " was octa punctured by ";
						else
							deathstring = " was quad punctured by ";
					}
					else
// GeN >
						deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				if (rnum == IT_GRENADE_LAUNCHER)
				{
					deathstring = " eats ";
// < GeN 
					if(attacker.items & IT_QUAD)
					{
						if(deathmatch & D_OCTADAMAGE)
							deathstring2 = "'s octa pineapple\n";
						else
							deathstring2 = "'s quad pineapple\n";
					}
					else
// GeN >
						deathstring2 = "'s pineapple\n";
					if ((targ.health < -40) || ((targ.health < -20) && (temp1 & T_MOREGIBS)))
					{
						deathstring = " was gibbed by ";
// < GeN 
						if(attacker.items & IT_QUAD)
						{
							if(deathmatch & D_OCTADAMAGE)
								deathstring2 = "'s octa grenade\n";
							else
								deathstring2 = "'s quad grenade\n";
						}
						else
// GeN >
						deathstring2 = "'s grenade\n";
					}
				}
				if (rnum == IT_ROCKET_LAUNCHER)
				{
					deathstring = " rides ";
// < GeN 
					if(attacker.items & IT_QUAD)
					{
						if(deathmatch & D_OCTADAMAGE)
							deathstring2 = "'s octa rocket\n";
						else
							deathstring2 = "'s quad rocket\n";
					}
					else
// GeN >
						deathstring2 = "'s rocket\n";
					if ((targ.health < -40) || ((targ.health < -20) && (temp1 & T_MOREGIBS)))
					{
						deathstring = " was gibbed by ";
// < GeN 
						if(attacker.items & IT_QUAD)
						{
							if(deathmatch & D_OCTADAMAGE)
								deathstring2 = "'s octa rocket\n";
							else
								deathstring2 = "'s quad rocket\n";
						}
						else
// GeN >
							deathstring2 = "'s rocket\n" ;
					}
				}
				if (rnum == IT_LIGHTNING)
				{
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
					{
// < GeN 
						if(attacker.items & IT_QUAD)
						{
							if(deathmatch & D_OCTADAMAGE)
								deathstring2 = "'s octa discharge\n";
							else
								deathstring2 = "'s quad discharge\n";
						}
						else
// GeN >
							deathstring2 = "'s discharge\n";
					}
					else
					{
// < GeN 
						if(attacker.items & IT_QUAD)
						{
							if(deathmatch & D_OCTADAMAGE)
								deathstring2 = "'s octa shaft\n";
							else
								deathstring2 = "'s quad shaft\n";
						}
						else
// GeN >
							deathstring2 = "'s shaft\n";
					}
				}
				bprint (targ.netname);
				bprint (deathstring);
				bprint (attacker.netname);
				bprint (deathstring2);
			}
			return;
		}
		else
		{
// < GeN 
			targ.frags = targ.frags - 1;
			if(teamplay)
				ApplyTeamFrags(targ);
// GeN >
			bprint (targ.netname);

/* GeN no monsters left...

			// killed by a monster?
			if (attacker.flags & FL_MONSTER)
			{
				if (attacker.classname == "monster_army")
					bprint (" was shot by a Grunt\n");
				if (attacker.classname == "monster_demon1")
					bprint (" was eviscerated by a Fiend\n");
				if (attacker.classname == "monster_dog")
					bprint (" was mauled by a Rottweiler\n");
				if (attacker.classname == "monster_dragon")
					bprint (" was fried by a Dragon\n");
				if (attacker.classname == "monster_enforcer")
					bprint (" was blasted by an Enforcer\n");
				if (attacker.classname == "monster_fish")
					bprint (" was fed to the Rotfish\n");
				if (attacker.classname == "monster_hell_knight")
					bprint (" was slain by a Death Knight\n");
				if (attacker.classname == "monster_knight")
					bprint (" was slashed by a Knight\n");
				if (attacker.classname == "monster_ogre")
					bprint (" was destroyed by an Ogre\n");
				if (attacker.classname == "monster_oldone")
					bprint (" became one with Shub-Niggurath\n");
				if (attacker.classname == "monster_shalrath")
					bprint (" was exploded by a Vore\n");
				if (attacker.classname == "monster_shambler")
					bprint (" was smashed by a Shambler\n");
				if (attacker.classname == "monster_tarbaby")
					bprint (" was slimed by a Spawn\n");
				if (attacker.classname == "monster_vomit")
					bprint (" was vomited on by a Vomitus\n");
				if (attacker.classname == "monster_wizard")
					bprint (" was scragged by a Scrag\n");
				if (attacker.classname == "monster_zombie")
					bprint (" joins the Zombies\n");

				return;
			}
 GeN */
			// tricks and traps
			if (attacker.classname == "explo_box")
			{
				bprint (" blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{	
				bprint (" was squished\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint (" was spiked\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
				bprint (" ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}

			// in-water deaths
			rnum = targ.watertype;
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (" sleeps with the fishes\n");
				else
					bprint (" sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (" gulped a load of slime\n");
				else
					bprint (" can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (" turned into hot slag\n");
				else
					bprint (" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if (targ.deathtype == "falling")
			{
				targ.deathtype = "";
				bprint (" fell to his death.\n");
				return;
			}
// < GeN 
			else if (targ.deathtype == "teamdamage")
			{
				targ.deathtype = "";
				bprint (" harmed his teammate.\n");
				return;
			}
			else if (targ.deathtype == "teamdeathpenalty")
			{
				targ.deathtype = "";
				bprint (" killed his teammate.\n");
				return;
			}
// GeN >

			// hell if I know; he's just dead!!!
			bprint (" died\n");
		}
	}
};
