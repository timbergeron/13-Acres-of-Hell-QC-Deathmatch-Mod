/****************************************************************************
 * ThreeWave Capture The Flag
 ****************************************************************************
 * Based on John Spikles Complete Enhanced Teamplay
 ****************************************************************************
 * Version 4.0 rewrite Mar 21, 1997
 ****************************************************************************/

//GeN: modified for Reincarnation
void(entity e, string s) ccenterprint;
void(entity e) ApplyTeamFrags;	//from teamplay.qc

/** Defs **/


// Globals

entity team1_lastspawn;
entity team2_lastspawn;
float	nextteamupdtime;	// time until next team update
float last_flag_capture;	// time of last capture
float last_capture_team;	// last team that captured

float TEAM_CAPTURE_CAPTURE_BONUS = 15; // what you get for capture //MEZ WAS: 15
float TEAM_CAPTURE_TEAM_BONUS = 0; // what your team gets for capture // MEZ WAS: 10 - doesn't appear to be getting added to team score
float TEAM_CAPTURE_RECOVERY_BONUS = 0; // what you get for recovery
float TEAM_CAPTURE_FLAG_BONUS = 0; // what you get for picking up enemy flag
float TEAM_CAPTURE_FRAG_CARRIER_BONUS = 0; // what you get for fragging enemy flag carrier //MEZ WAS: 2
float TEAM_CAPTURE_FLAG_RETURN_TIME = 30; // seconds until auto return //MEZ WAS: 40

// XXX EXPERT CTF Additional scoring system

// bonuses

float TEAM_CAPTURE_CARRIER_DANGER_PROTECT_BONUS = 0; // bonus for fraggin someone who has recently hurt your flag carrier //MEZ WAS: 2
float TEAM_CAPTURE_CARRIER_PROTECT_BONUS = 0; // bonus for fraggin someone while either you or your target are near your flag carrier //MEZ WAS: 1
float TEAM_CAPTURE_FLAG_DEFENSE_BONUS = 0; // bonus for fraggin someone while either you or your target are near your flag //MEZ WAS: 1
float TEAM_CAPTURE_RETURN_FLAG_ASSIST_BONUS = 0; // awarded for returning a flag that causes a capture to happen almost immediately //MEZ WAS: 1
float TEAM_CAPTURE_FRAG_CARRIER_ASSIST_BONUS = 0; // award for fragging a flag carrier if a capture happens almost immediately //MEZ WAS: 2

// radii

float TEAM_CAPTURE_TARGET_PROTECT_RADIUS = 550; // the radius around an object being
// defended where a target will be worth extra frags
float TEAM_CAPTURE_ATTACKER_PROTECT_RADIUS = 550; // the radius around an object being
// defended where an attacker will get extra frags when making kills

// timeouts

float TEAM_CAPTURE_CARRIER_DANGER_PROTECT_TIMEOUT = 4;
float TEAM_CAPTURE_CARRIER_FLAG_SINCE_TIMEOUT = 2;
float TEAM_CAPTURE_FRAG_CARRIER_ASSIST_TIMEOUT = 6;
float TEAM_CAPTURE_RETURN_FLAG_ASSIST_TIMEOUT = 4;

float TEAM_CAPTURE_UPDATE_TIME = 120;

// END EXPERT CTF

// flag status used in cnt field of flag
float FLAG_AT_BASE = 0;
float FLAG_CARRIED = 1;
float FLAG_DROPPED = 2;


// Prototypes
float() W_BestWeapon;
void() W_SetCurrentAmmo;
void() bound_other_ammo;
void(float o, float n) Deathmatch_Weapon;
void() BackpackTouch;

// *XXX* EXPERT CTF
// Just a quickie to return the ASCII-ized team names for CTF
string(float Team) GetCTFTeam =
{
	if (Team == TRED) return "“≈ƒ";
	if (Team == TBLUE) return "¬Ã’≈";
	return "";
};

/*
=======================
TossBackPack

Original idea by Vhold
Rewritten by John Spickes

Toss out a backpack containing some ammo from your current weapon,
and any weapons you don't have.
=======================
*/
void() TossBackpack =
{
	local entity 	item;

	// If we don't have any ammo, return
	if(self.currentammo <= 0)
		return;

	item = spawn();

	// See if you have the Shotgun or Super Shotgun on
        if ( (self.weapon == IT_SHOTGUN) || (self.weapon == IT_SUPER_SHOTGUN)) {
		if( self.ammo_shells >= 20 ) {
			item.ammo_shells = 20;
			self.ammo_shells = self.ammo_shells - 20;
		}
		else
		{
			item.ammo_shells = self.ammo_shells;
			self.ammo_shells = 0;
		}
	}		
	
	// See if you have neither the Shotgun or Super Shotgun
        if ( !(self.items & IT_SHOTGUN) && !(self.items & IT_SUPER_SHOTGUN)) {
		if( self.ammo_shells >= 20 ) {
			item.ammo_shells = 20;
			self.ammo_shells = self.ammo_shells - 20;
		}
		else
		{
			item.ammo_shells = self.ammo_shells;
			self.ammo_shells = 0;
		}
	}		
	
	// See if we are using a nailgun
        if ( (self.weapon == IT_NAILGUN) || (self.weapon == IT_SUPER_NAILGUN) )
	{
		if( self.ammo_nails >= 20 )
		{
			item.ammo_nails = 20;
			self.ammo_nails = self.ammo_nails - 20;
		}
		else
		{
			item.ammo_nails = self.ammo_nails;
			self.ammo_nails = 0;
		}
	}	
	// Check to see if we have neither nailgun
        if ( !(self.items & IT_NAILGUN) && !(self.items & IT_SUPER_NAILGUN) )
	{
		if( self.ammo_nails >= 20 )
		{
			item.ammo_nails = 20;
			self.ammo_nails = self.ammo_nails - 20;
		}
		else
		{
			item.ammo_nails = self.ammo_nails;
			self.ammo_nails = 0;
		}
	}	
	
	// See if we are using a grenade or rocket launcher
        if ( (self.weapon == IT_GRENADE_LAUNCHER) || (self.weapon == IT_ROCKET_LAUNCHER) )
	{
		if( self.ammo_rockets >= 10 )
		{
			item.ammo_rockets = 10;
			self.ammo_rockets = self.ammo_rockets - 10;
		}
		else
		{
			item.ammo_rockets = self.ammo_rockets;
			self.ammo_rockets = 0;
		}
	}
	// See if we have neither the Grenade or rocket launcher
        if ( !(self.items & IT_GRENADE_LAUNCHER) && !(self.items & IT_ROCKET_LAUNCHER) )
	{
		if( self.ammo_rockets >= 10 )
		{
			item.ammo_rockets = 10;
			self.ammo_rockets = self.ammo_rockets - 10;
		}
		else
		{
			item.ammo_rockets = self.ammo_rockets;
			self.ammo_rockets = 0;
		}
	}

	// See if we're using the lightning gun
	if ( self.weapon == IT_LIGHTNING )
	{	
		if( self.ammo_cells >= 20 )
		{
			item.ammo_cells = 20;
			self.ammo_cells = self.ammo_cells - 20;
		}
		else
		{
			item.ammo_cells = self.ammo_cells;
			self.ammo_cells = 0;
		}
	}
	// see if we don't have the lightning gun
        if ( !(self.items & IT_LIGHTNING) )
	{	
		if( self.ammo_cells >= 20 )
		{
			item.ammo_cells = 20;
			self.ammo_cells = self.ammo_cells - 20;
		}
		else
		{
			item.ammo_cells = self.ammo_cells;
			self.ammo_cells = 0;
		}
	}
	 
	item.owner = self;
	makevectors(self.v_angle);

	setorigin(item, self.origin + '0 0 16');
	item.velocity = aim(self, 1000);
	item.velocity = item.velocity * 500;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_BOUNCE;

	setmodel (item, "progs/backpack.mdl");
	setsize(item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;

	W_SetCurrentAmmo();

};

void(entity flg) RegenFlag =
{
	flg.movetype = MOVETYPE_TOSS;
	flg.solid = SOLID_TRIGGER;
	sound (flg, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin(flg, flg.oldorigin); //MEZ CTF This is the problem function
	//bprint (vtos(flg.oldorigin));
	flg.angles = flg.mangle;
	flg.cnt = FLAG_AT_BASE; // it's at home base
	flg.owner = world;
};

void(entity flg) TeamCaptureReturnFlag =		//MEZ CTF This might be the problem blocks? Original: void(entity flg) TeamCaptureReturnFlag =
{
	local entity p;
	
	RegenFlag(flg);

	p = find(world, classname, "player");
	while (p != world) 
	{
		if (p.genteam != flg.genteam)
			ccenterprint(p, "Your flag has been returned to base!"); //Mez try disabling WAS: ccenterprint(p, "Enemy flag has been returned to base!");
		else if (p.genteam == flg.genteam)
			ccenterprint(p, "Enemy flag has been returned to base!"); //Mez try disabling WAS: ccenterprint(p, "Your flag has been returned to base!");
		p = find(p, classname, "player");
	}
};

void () TeamCaptureRegenFlags =
{
	local entity f;

	f = find(world, classname, "item_flag_team1");
	if (f != world)
		RegenFlag(f);
	f = find(world, classname, "item_flag_team2");
	if (f != world)
		RegenFlag(f);
};

void(entity flg) TeamDropFlag =
{
	local entity item, f, oself;
	local entity p;

	p = flg.owner;

	bprint(p.netname);
	if (p.genteam == TBLUE)
		bprint(" ÏÔÛÙ the “≈ƒ flag!\n"); // red
	else
		bprint(" ÏÔÛÙ the ¬Ã’≈ flag!\n"); // blue
	LogMsg(p, "FLAG-DROP");

	flg.origin = p.origin - '0 0 24';
	flg.cnt = FLAG_DROPPED;
	//NOTE! We check lastteam here instead of team--this is because
	//in the mode where we change colors, we get killed
	flg.velocity_z = 300;
	flg.velocity_x = 0;
	flg.velocity_y = 0;
	flg.flags = FL_ITEM;
	flg.solid = SOLID_TRIGGER;
	flg.movetype = MOVETYPE_TOSS;
	setsize(flg, '-16 -16 -24', '16 16 32');
	// return it after so long
	flg.super_time = time + TEAM_CAPTURE_FLAG_RETURN_TIME;
};

void(entity player) TeamCaptureDropFlagOfPlayer =
{
	local string kn;
	local entity e;

	if (!(player.player_flag & ITEM_ENEMY_FLAG))
		return;
	if (player.genteam == TBLUE) 
		kn = "item_flag_team2";
	else
		kn = "item_flag_team1";
	player.player_flag = player.player_flag - ITEM_ENEMY_FLAG;
	e = find(world, classname, kn);
	if (e != world)
		TeamDropFlag(e);
};

void () TeamCaptureReturnFlag_think =	//MEZ Added Slot Zero made check for Qrack break
{
    TeamCaptureReturnFlag(self.owner);
    remove (self);
};


void() TeamCaptureFlagTouch =
{
	local entity p, oself;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	if (self.lockflag == 0) // MEZ Added condution
	{
		centerprint(other, "Capturing not allowed yet!\nLock Flag Placement First\n. ", "", "", "");
		return;
	}

	if (other.genteam != other.lastteam)
		return; // something is fishy, somebody is playing with colors

	if (self.lastteam == other.lastteam) 
	{
		// same team, if the flag is *not* at the base, return
		// it to base.  we overload the 'cnt' field for this
		if (self.cnt == FLAG_AT_BASE) {
			// the flag is at home base.  if the player has the enemy
			// flag, he's just won!

			if (other.player_flag & ITEM_ENEMY_FLAG) {
				bprint(other.netname);
				if (other.genteam == TBLUE)
					bprint(" „·ÙıÚÂ‰ the “≈ƒ flag!\n"); // red
				else
					bprint(" „·ÙıÚÂ‰ the ¬Ã’≈ flag!\n"); // blue
				LogMsg(other, "FLAG-CAPTURE");
				other.items = other.items - (other.items & (IT_KEY1 | IT_KEY2));

				last_flag_capture = time;
				last_capture_team = other.team;

				sound (other, CHAN_VOICE, "doors/meduse.wav", 1, ATTN_NONE);

				// other gets another 10 frag bonus
				other.frags = other.frags + TEAM_CAPTURE_CAPTURE_BONUS;
				ApplyTeamFrags(other);
	
				// Ok, let's do the player loop, hand out the bonuses
				p = find(world, classname, "player");
				while (p != world) {
					self = p;
					self.killed = 0;
					if (self.lastteam == other.lastteam && self != other)
					{
						self.frags = self.frags + TEAM_CAPTURE_TEAM_BONUS;
						ApplyTeamFrags(self);
					}
					if (self.lastteam != other.lastteam) {
						// *XXX* EXPERT CTF
						// reset the last_hurt_carrier variable in all enemy players, so that you don't get
						// bonuses for defending the flag carrier if the flag carrier has already
						// completed a capture
						self.last_hurt_carrier = -5;
					} else if (self.lastteam == other.lastteam) {
						// done to all players on the capturing team
						// *XXX* EXPERT CTF
	
						// award extra points for capture assists
						if (self.last_returned_flag + TEAM_CAPTURE_RETURN_FLAG_ASSIST_TIMEOUT > time) {
							bprint(self.netname);
							bprint(" gets an assist for returning his flag!\n");
							self.frags = self.frags + TEAM_CAPTURE_RETURN_FLAG_ASSIST_BONUS;
							ApplyTeamFrags(self);
						}
						if (self.last_fragged_carrier + TEAM_CAPTURE_FRAG_CARRIER_ASSIST_TIMEOUT > time) {
							bprint(self.netname);
							bprint(" gets an assist for fragging the flag carrier!\n");
							self.frags = self.frags + TEAM_CAPTURE_FRAG_CARRIER_ASSIST_BONUS;
							ApplyTeamFrags(self);
						}
					}
					self.player_flag = self.player_flag - (self.player_flag & ITEM_ENEMY_FLAG);
					
					p = find(p, classname, "player");
				}

				p = find(world, classname, "player");
				while (p != world) {
					if ((p.lastteam == TBLUE && other.lastteam == TRED) ||
						(p.lastteam == TRED && other.lastteam == TBLUE))
						ccenterprint(p, "Your flag was captured!");
					else if (p.lastteam == other.lastteam)
						ccenterprint(p, "Your team captured the flag!");
					p = find(p, classname, "player");
				}
				// respawn flags
				TeamCaptureRegenFlags();
				return;
			}
			return; // its at home base already
		}	
		// hey, its not home.  return it by teleporting it back
		bprint(other.netname);
		if (other.team == TBLUE)
			bprint(" ÚÂÙıÚÓÂ‰ the “≈ƒ flag!\n"); // red
		else
			bprint(" ÚÂÙıÚÓÂ‰ the ¬Ã’≈ flag!\n"); // blue
		LogMsg(other, "FLAG-RECOVERY");
		other.frags = other.frags + TEAM_CAPTURE_RECOVERY_BONUS;
		ApplyTeamFrags(other);
		// *XXX* EXPERT CTF set time when player last returned his flag
		other.last_returned_flag = time;
		sound (other, CHAN_ITEM, self.noise1, 1, ATTN_NORM);
		//TeamCaptureReturnFlag(self); //Mez removed per Slot Zero Add
		//Mez / Slot Zero Start
		if (self.cnt == FLAG_DROPPED)
		{
			self.cnt = FLAG_AT_BASE;
			p = spawn ();
			p.owner = self;
			p.think = TeamCaptureReturnFlag_think;
			p.nextthink	= time;
		}
		//Mez / Slot Zero End
		return;
	}

	// hey, its not our flag, pick it up
	bprint(other.netname);
	if (other.genteam == TBLUE)
		bprint(" ÁÔÙ the “≈ƒ flag!\n"); // red
	else
		bprint(" ÁÔÙ the ¬Ã’≈ flag!\n"); // blue
	LogMsg(other, "FLAG-PICKUP");
	if (TEAM_CAPTURE_FLAG_BONUS)
	{
		other.frags = other.frags + TEAM_CAPTURE_FLAG_BONUS;
		ApplyTeamFrags(other);
	}
//	TeamPlayerUpdate(other, "YOU GOT THE ENEMY FLAG!  RETURN TO BASE!");
	ccenterprint(other, "Ÿœ’ «œ‘ ‘»≈ ≈Œ≈ÕŸ ∆Ã¡«  “≈‘’“Œ ‘œ ¬¡”≈");
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	other.player_flag = other.player_flag + ITEM_ENEMY_FLAG;
	other.items = other.items | self.items;

	// *XXX* EXPERT CTF set the time at which the carrier picked up the flag
	other.flag_since = time;

	// pick up the flag
	self.cnt = FLAG_CARRIED;
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;
	self.owner = other;

	p = find(world, classname, "player");
	while (p != world) {
		if (p != other) {
			if ((p.team == TBLUE && other.team == TBLUE) ||
				(p.team == TRED && other.team == TRED))
				ccenterprint(p, "Your flag has been taken!");
			else if (p.team == other.team)
				ccenterprint(p, "Your team has the enemy flag!");
		}
		p = find(p, classname, "player");
	}
};

void() TeamCaptureFlagThink =
{
	local entity e;
	local vector v;
	local float f;
	local string s;

	self.nextthink = time + 0.1;

	if (self.cnt == FLAG_AT_BASE)
		return; // just sitting around waiting to be picked up

	if (self.cnt == FLAG_DROPPED) {
		if (time - self.super_time > TEAM_CAPTURE_FLAG_RETURN_TIME)
			TeamCaptureReturnFlag(self);
		return;
	}

	if (self.cnt != FLAG_CARRIED)
		objerror("Flag in invalid state\n");

	e = self.owner;
	if ((e.classname != "player") || (e.deadflag) ||
		(!(e.player_flag & ITEM_ENEMY_FLAG))) {
		TeamDropFlag(self);
		return;
	}
	makevectors (e.angles);
	v = v_forward;
	v_z = (-1) * v_z; // reverse z component

	f = 14;
	if (self.owner.frame >= 29 && self.owner.frame <= 40) {
		if (self.owner.frame >= 29 && self.owner.frame <= 34) { //axpain
			if      (self.owner.frame == 29) f = f + 2; 
			else if (self.owner.frame == 30) f = f + 8;
			else if (self.owner.frame == 31) f = f + 12;
			else if (self.owner.frame == 32) f = f + 11;
			else if (self.owner.frame == 33) f = f + 10;
			else if (self.owner.frame == 34) f = f + 4;
		} else if (self.owner.frame >= 35 && self.owner.frame <= 40) { // pain
			if      (self.owner.frame == 35) f = f + 2; 
			else if (self.owner.frame == 36) f = f + 10;
			else if (self.owner.frame == 37) f = f + 10;
			else if (self.owner.frame == 38) f = f + 8;
			else if (self.owner.frame == 39) f = f + 4;
			else if (self.owner.frame == 40) f = f + 2;
		}
	} else if (self.owner.frame >= 103 && self.owner.frame <= 118) {
		if      (self.owner.frame >= 103 && self.owner.frame <= 104) f = f + 6;  //nailattack
		else if (self.owner.frame >= 105 && self.owner.frame <= 106) f = f + 6;  //light 
		else if (self.owner.frame >= 107 && self.owner.frame <= 112) f = f + 7;  //rocketattack
		else if (self.owner.frame >= 112 && self.owner.frame <= 118) f = f + 7;  //shotattack
	}
	self.origin = e.origin + '0 0 -16' - f*v + v_right * 22;
	self.angles = e.angles + '0 0 -45';
	setorigin (self, self.origin);
	self.nextthink = time + 0.01;
};

// self is player
entity() TeamCaptureSpawn =
{
	if (self.team == TBLUE) {
		team1_lastspawn = find(team1_lastspawn, classname, "info_player_team1");
		if (team1_lastspawn == world)
			team1_lastspawn = find(team1_lastspawn, classname, "info_player_team1");
		return team1_lastspawn;
	} else if (self.team == TRED) {
		team2_lastspawn = find(team2_lastspawn, classname, "info_player_team2");
		if (team2_lastspawn == world)
			team2_lastspawn = find(team2_lastspawn, classname, "info_player_team2");
		return team2_lastspawn;
	}
	return world;
};

/*
	From byron@caseware.com Wed Oct 16 18:57:44 1996
	Date: Wed, 16 Oct 1996 21:22:37 -0400
	From: Byron Long <byron@caseware.com>
	To: zoid@mindlink.net
	Subject: Team Status Command (source code included) :-)

	A co-worker of mine wondered if it was possible to add a function to
	your capture the flag code that would give a status report on an
	impulse. I think he may have mailed you, but I wrote a quick version
	myself, which your welcome to use if you like the feature (it offsets
	some of the problems with the chat capabilities in Quake so it seems
	like a worthwhile feature). Feel free to change it
	as necessary.
*/

// *Capture The Flag - Status report by Wonko
void() TeamFlagStatusReport =
{
	local entity flag1, flag2, p;

	// Find the flags at home base
	flag1 = find (world,classname, "item_flag_team1");
	flag2 = find (world,classname, "item_flag_team2");

	// If on team 2 switch meanings of flags
	if (self.team != TBLUE) {
		p = flag1;
		flag1 = flag2;
		flag2 = p;
	}

	if (flag1 != world && flag1.cnt == FLAG_CARRIED) {
		sprint(self, flag1.owner.netname);
		sprint(self, " has your flag. ");
	} else {
		sprint(self, "Your flag is ");
		if (flag1 == world)
			sprint(self, "missing! ");
		if (flag1.cnt == FLAG_AT_BASE)
			sprint(self, "in your base. ");
		else if (flag1.cnt == FLAG_DROPPED)
			sprint(self, "lying about. ");
		else
			sprint(self, " corrupt. ");
	}

	if (flag2 != world && flag2.cnt == FLAG_CARRIED) {
		if (self == flag2.owner) 
			sprint(self, "You have the enemy flag.\n");
		else {
			sprint(self, flag2.owner.netname);
			sprint(self, " has the enemy flag.\n");
		}
	} else {
		sprint(self, "The enemy flag is ");
		if (flag2 == world)
			sprint(self, "missing!\n");
		if (flag2.cnt == FLAG_AT_BASE)
			sprint(self, "in their base.\n");
		else if (flag2.cnt == FLAG_DROPPED)
			sprint(self, "lying about.\n");
		else
			sprint(self, " corrupt.\n");
	}
};

/////////////////////////////////////////////////////////////////////////

$cd id1/models/flag
$base base
$skin skin

void() place_flag = 
{
	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	self.think = TeamCaptureFlagThink;
	self.touch = TeamCaptureFlagTouch;
	self.nextthink = time + 0.1;
	self.cnt = FLAG_AT_BASE;
	self.mangle = self.angles;
	self.effects = self.effects | EF_DIMLIGHT;
	if (!droptofloor()) {
		dprint ("Flag fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
		return;
	}
	self.oldorigin = self.origin; // save for flag return
};

// ZOID Capture the flag
void() item_flag_team1 =
{
	teamplay = cvar("teamplay");
	if(!teamplay & TEAM_CTF)
	{
		remove(self);
		return;
	}
	self.team = TRED;
	self.lastteam = TRED;
	self.items = IT_KEY2;
	precache_model ("progs/w_g_key.mdl");
	setmodel (self, "progs/w_g_key.mdl");
	precache_sound ("misc/medkey.wav");
	precache_sound ("doors/meduse.wav");
	precache_sound ("doors/runetry.wav");
	self.noise = "misc/medkey.wav";
	self.noise1 = "doors/runetry.wav";
	self.origin_z = self.origin_z + 24;
	self.lockflag = 1; //MEZ Added
	setsize(self, '-16 -16 -24', '16 16 32');
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = place_flag;
};

void() item_flag_team2 =
{
	teamplay = cvar("teamplay");
	if(!teamplay & TEAM_CTF)
	{
		remove(self);
		return;
	}
	self.team = TBLUE;
	self.lastteam = TBLUE;
	self.items = IT_KEY1;
	precache_model ("progs/w_s_key.mdl");
	setmodel (self, "progs/w_s_key.mdl");
	precache_sound ("misc/medkey.wav");
	precache_sound ("doors/meduse.wav");
	precache_sound ("doors/runetry.wav");
	self.noise = "misc/medkey.wav";
	self.noise1 = "doors/runetry.wav";
	self.origin_z = self.origin_z + 24;
	self.lockflag = 1; //MEZ Added
	setsize(self, '-16 -16 -24', '16 16 32');
	// make it glow
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = place_flag;
};


// MEZ MANUAL PLACEMENT FUNCTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> START

void() item_flag_team1_place =
{
	teamplay = cvar("teamplay");
	if(!teamplay & TEAM_CTF)
	{
		remove(self);
		return;
	}
	self.team = TRED;
	self.lastteam = TRED;
	self.items = IT_KEY2;
	//precache_model ("progs/w_g_key.mdl");
	setmodel (self, "progs/w_g_key.mdl");
	//precache_sound ("misc/medkey.wav");
	//precache_sound ("doors/meduse.wav");
	//precache_sound ("doors/runetry.wav");
	self.noise = "misc/medkey.wav";
	self.noise1 = "doors/runetry.wav";
	self.origin_z = self.origin_z + 24;
	setsize(self, '-16 -16 -24', '16 16 32');
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = place_flag;
};

void() item_flag_team2_place =
{
	teamplay = cvar("teamplay");
	if(!teamplay & TEAM_CTF)
	{
		remove(self);
		return;
	}
	self.team = TBLUE;
	self.lastteam = TBLUE;
	self.items = IT_KEY1;
	//precache_model ("progs/w_s_key.mdl");
	setmodel (self, "progs/w_s_key.mdl");
	//precache_sound ("misc/medkey.wav");
	//precache_sound ("doors/meduse.wav");
	//precache_sound ("doors/runetry.wav");
	self.noise = "misc/medkey.wav";
	self.noise1 = "doors/runetry.wav";
	self.origin_z = self.origin_z + 24;
	setsize(self, '-16 -16 -24', '16 16 32');
	// make it glow
	self.nextthink = time + 0.2;	// items start after other solids
	self.think = place_flag;
};

// MEZ MANUAL PLACEMENT FUNCTIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> END


/*QUAKED func_ctf_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
Only appears in CTF teamplay
*/
void() func_ctf_wall =
{
	if(!teamplay & TEAM_CTF)
	{
		remove(self);
		return;
	}
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
};

