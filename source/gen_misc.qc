void() ObserverThink;
void() SetAliases;
void() InitMod;
void(vector org, vector vel, float damage) SpawnBlood;
void() DisplayInfo;
float() W_BestWeapon;
void(float old, float new) Deathmatch_Weapon;
void() W_SetCurrentAmmo;
void() powerup_touch;
void() armor_touch;
void() health_touch;
void() BackpackTouch;
entity() SelectSpawnPoint;
void() bound_other_ammo;	//declared in items.qc
void() PlayerObserverMode;	//declared in observer.qc
float(entity damageinflictor, vector targorg) DetermineZone;	//declared below
void() SpawnHeads;	//declared in headgames.qc
entity() RandomPlayer;	//declared below

//-----------------------------------------------------------------------------------
//
// New print functions
//
//-----------------------------------------------------------------------------------

void(entity e, string s) ccenterprint =
{
	e.messagetime = time+3;
        centerprint(e, s,"","","");	//MEZ changed to centerprint2
};

void(string s1, string s2, string s3, string s4, string soundtoplay)bcenterprint =
{
	local entity cl;
	cl = find(world, classname, "player");
	while(cl)
	{
		if(cl.flags & FL_CLIENT)
		{
			cl.infotime = time + 3;
			centerprint(cl, s1, s2, s3, s4); //MEZ changed to centerprint2
			if(soundtoplay != "")
				sound(cl, CHAN_VOICE, soundtoplay, 1, ATTN_NORM);
		}
		cl = find(cl, classname, "player");
	}
};

void(float bchan, string soundtoplay, float vol, float batt)bsound =
{
	local entity cl;
	cl = find(world, classname, "player");
	while(cl)
	{
		if(cl.flags & FL_CLIENT)
				sound(cl, bchan, soundtoplay, vol, batt);
		cl = find(cl, classname, "player");
	}
};

//-----------------------------------------------------------------------------------
//
// Initialization
//
//-----------------------------------------------------------------------------------

void() SetCvars =
{
	cvar_set("sv_aim", "2.0");	//disable autoaiming
	if(deathmatch & D_SPEED)
	{
		cvar_set("cl_backspeed", "450");
		cvar_set("cl_sidespeed", "400");
		cvar_set("cl_forwardspeed", "450");
		cvar_set("sv_maxspeed", "450");
	}
	else
	{
		cvar_set("cl_backspeed", "400");
		cvar_set("cl_sidespeed", "375");
		cvar_set("cl_forwardspeed", "400");
		cvar_set("sv_maxspeed", "320");
	}
	cvar_set("scr_centertime", "3");
};

void() InitMod =	//done once for each player
{
	self.headmessage = FALSE;
	SetAliases();
};

float() GetMaxplayers;	//declared below

void(entity hunter) InitRR =
{
	local entity e, oself;

	if(gameover)
		return;

	e = find(world, classname, "player");
	while(e)
	{
		SetTeam(e, THUNTED);		
		e = find(e, classname, "player");
	}
	if(!hunter)
		e = RandomPlayer();
	else
		e = hunter;
	SetTeam(e, THUNTER);

	oself = self;
	e = find(world, classname, "player");
	while(e)
	{
		self = e;
		if(e.mode == M_PLAYER)
		{
			PlayerObserverMode();
		}
		if(!e.state & S_READYPLAY)
			e.state = e.state | S_READYPLAY;
		e = find(e, classname, "player");
	}
	self = oself;
	gamestatus = gamestatus - (gamestatus & G_STARTING);
	gamestatus = gamestatus - (gamestatus & G_STARTED);
	CheckStartGame(0);
};

void() InitGame2 =  //happens only once, called 3 secs after worldspawn
{
	SpawnHeads();

	if((deathmatch & D_HH) && (!teamplay))
		InitRR(world);

	remove(self);	//remove the timer
};

void() InitGame =  //happens only once
{
	maxplayers = GetMaxplayers();
	gscorepos = 0;
	SetCvars();

	blueteam = spawn();
	blueteam.scorepos = -1;
	blueteam.netname = "blueteam";

	redteam = spawn();
	redteam.scorepos = -1;
	redteam.netname = "redteam";

	whiteteam = spawn();
	whiteteam.scorepos = -1;
	whiteteam.netname = "whiteteam";

	yellowteam = spawn();
	yellowteam.scorepos = -1;
	yellowteam.netname = "yellowteam";

	greenteam = spawn();
	greenteam.scorepos = -1;
	greenteam.netname = "greenteam";

	brownteam = spawn();
	brownteam.scorepos = -1;
	brownteam.netname = "brownteam";
	
	teamplayon = FALSE;
};

//-----------------------------------------------------------------------------------
//
// Starting the Game
//
//-----------------------------------------------------------------------------------

void() MakeHimPlayer =
{
	local entity stemp;
        
	stemp = self;
	self = self.owner;
	if((teamplay) || (deathmatch & D_HH))
	{
		if(self.state & S_TEAMCHOSEN)
		{
			PutClientInServer ();
			if(deathmatch & D_HH)
			{
				if(self.genteam == THUNTED)
				{
					ccenterprint(self, "You are Hunted!");
					self.skin = 3;	//MEZ Barbarian Skin
				}
				else if(self.genteam == THUNTER)
				{
					ccenterprint(self, "You are the Hunter!");
					self.skin = 4; //MEZ Predator Skin
				}
			}
		}
		else
			bprint("You have to choose a team before you may join the match.\n");
	}
	else
		PutClientInServer ();
	self = stemp;
	remove(self);
};

void() KickHim =
{
	local entity stemp;
        
	stemp = self;
	self = self.owner;
	sprint(self, "You got kicked off the server because you were not ready at match start.\n");
	stuffcmd(self, "disconnect\n");
	self = stemp;
	remove(self);
};

void() StartGame =
{
	local entity p, otimer;

	if(gameover)
		return;

	p = find(world, classname, "player");
	while(p)
	{
		if(p.state & S_READYOBSERVER)
		{
			if((!teamplay & TEAM_MATCH) && (!teamplay & TEAM_MATCH2))
				p.state = p.state - (p.state & S_READYOBSERVER);
			if(! p.state & S_OBSERVERNOCHANGE)
				p.state = p.state | S_OBSERVERNOCHANGE;
		}
		else if(p.state & S_READYPLAY)
		{
			if(!((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2)))
				p.state = p.state - (p.state & S_READYPLAY);
			otimer = spawn();
	    		otimer.owner = p;
			otimer.nextthink = time;
	    		otimer.think = MakeHimPlayer;
		}
		else if(p.client)
		{
			otimer = spawn();
	    		otimer.owner = p;
			otimer.nextthink = time;
	    		otimer.think = KickHim;
		}
		p = find(p, classname, "player");
	}

	if((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2))
	{
		p = find(world, classname, "KasCam");
		while(p)
		{
			if(p.state & S_READYOBSERVER)
			{
				if(! p.state & S_OBSERVERNOCHANGE)
					p.state = p.state | S_OBSERVERNOCHANGE;
			}
			else if(p.state & S_READYPLAY)
			{
				otimer = spawn();
		  		otimer.owner = p;
				otimer.nextthink = time;
		    		otimer.think = MakeHimPlayer;
			}
			p = find(p, classname, "KasCam");
		}
	}

	if(!gamestatus & G_STARTED)
		gamestatus = gamestatus | G_STARTED;
	gamestatus = gamestatus - (gamestatus & G_STARTING);
};

void() StartCountdown =
{
	local string s;
	local entity cl;

	if(self.delay > 0)
	{
		if(self.health == 1)
		{
			cl = find(world, classname, "player");
			while(cl)
			{
				if((cl.flags & FL_CLIENT) && ((!cl.state & S_READYPLAY) || (cl.state & S_READYOBSERVER)))
				{
					cl.infotime = time + 3;
					centerprint(cl, "If you do not type реады\nto play or обсержер to observe\nyou will be kicked off the server\nin 10 seconds.", "", "", "");
					sound(cl, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
				}
				cl = find(cl, classname, "player");
			}
		}
		bprint("тхе матцх бегинс ин ");
		s = ftos(self.delay);
		bprint(s);

		if(self.delay != 1)
			bprint(" сецондс╝\n");
		else
			bprint(" сецонд╝\n");

   		bsound(CHAN_VOICE, "misc/talk.wav", 1, ATTN_NONE);
	}
	else
	{
		StartGame();
		bcenterprint("┘матцх хас бегун┘", "", "", "", "boss1/out1.wav");
		remove(self);
	}
	self.delay = self.delay - 1;
	self.nextthink = time + 1;
};

void(float forced) CheckStartGame =
{
	local entity p, gtimer;

	if(gameover)
		return;	

	if(gamestatus & G_STARTING)
		return;

	if(forced)
		bcenterprint("If you do not type реады\nto play or обсержер to observe\nyou will be kicked off the server\nin 10 seconds.", "", "", "", "misc/talk.wav");
	else
	{
		p = find(world, classname, "player");
		while(p)
		{
			if(!((p.state & S_READYOBSERVER) || (p.state & S_READYPLAY)))
				return;
			p = find(p, classname, "player");
		}
	}
	gamestatus = gamestatus | G_STARTING;
	gtimer = spawn();
	gtimer.delay = 10;
	gtimer.classname = "cdtimer";
	if(forced)
		gtimer.health = 1;
	gtimer.think = StartCountdown;
	gtimer.nextthink = time + 0.1;
};

void() StopCountdown =
{
local entity cdt;
	cdt = find(world, classname, "cdtimer");
	while(cdt)
	{
		remove(cdt);
		cdt = find(cdt, classname, "cdtimer");
	}
	bprint("Countdown stopped by server.\n");
};

//-----------------------------------------------------------------------------------
//
// Alerts of timelimit
//
//-----------------------------------------------------------------------------------

void() BerserkMode;

void() TimeAlert =
{
local float timeleft, tl;
local string s;

	tl = cvar("timelimit");
	timeleft = tl * 60 - time;	//the time left in seconds

	timeleft = floor(timeleft) + 1;
	if((timeleft <= BERSERKTIME) && (!gamestatus & G_BERSERKMODE) && (deathmatch & D_BERSERKDM))
		BerserkMode();

	if((timeleft <= 10) && (lasttimealert != timeleft))
	{
		if(timeleft > 0)
		{
		    s = ftos(timeleft);
    		bprint(s);
			if(timeleft != 1)
			    bprint(" сецондс лефт╝\n");
			else
			    bprint(" сецонд лефт╝\n");
    		bsound(CHAN_VOICE, "misc/talk.wav", 1, ATTN_NONE);
			lasttimealert = timeleft;
		}
	}
	if(timeleft <= 10)
		return;

    timeleft = floor(timeleft / 60 + 0.1) + 1;	//minutes to go
	if (timeleft <= ALERTMINUTES)
	{
		if((timeleft != lasttimealert) && (timeleft < tl) && (timeleft >= 1))
		{
		    s = ftos(timeleft);
    		bprint(s);
			if(timeleft != 1)
			{
			    bprint(" минутес лефт╝\n");
	    		bsound(CHAN_VOICE, "misc/power.wav", 1, ATTN_NONE);
			}
			else
			{
			    bprint(" минуте лефт╝\n");
	    		bsound(CHAN_VOICE, "boss1/out1.wav", 1, ATTN_NONE);
			}
			lasttimealert = timeleft;
		}
	}
	else
	{
		if((timeleft != lasttimealert) && (timeleft != tl) && (timeleft > ALERTMINUTES))
		{
			if((timeleft == 10) || 
			   (timeleft == 15) || 
			   (timeleft == 20) || 
			   (timeleft == 25) || 
			   (timeleft == 30) || 
			   (timeleft == 40) || 
			   (timeleft == 50))
			{
			    s = ftos(timeleft);
	    		bprint(s);
			    bprint(" минутес лефт╝\n");
	    		bsound(CHAN_VOICE, "misc/power.wav", 1, ATTN_NONE);
			}
			else if(timeleft == 60)
			{
			    bprint("1 хоур лефт╝\n");
	    		bsound(CHAN_VOICE, "misc/power.wav", 1, ATTN_NONE);
			}
			lasttimealert = timeleft;
		}
	}
};

//-----------------------------------------------------------------------------------
//
// Functions initially declared in the .qcs of monsters which I excluded
//
//-----------------------------------------------------------------------------------


float (entity targ) visible =
{
	local vector	spot1, spot2;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, self);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

void() Laser_Touch =
{
	local vector org;
	local float zone;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		zone = DetermineZone(self, other.origin);
		SpawnBlood (org, self.velocity*0.2, 15);
		T_Damage (other, self, self.owner, 15, zone);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
	
	remove(self);	
};

void(vector org, vector vec) LaunchLaser =
{
	local	vector	vec;
		
	if (self.classname == "monster_enforcer")
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);
	
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Laser_Touch;
};

void() t_movetarget =
{
local entity	temp;

	if (other.movetarget != self)
		return;
	
	if (other.enemy)
		return;		// fighting, not following a path

	temp = self;
	self = other;
	other = temp;

	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

//dprint ("t_movetarget\n");
	self.goalentity = self.movetarget = find (world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget)
	{
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
};

void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
		
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
	
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
// For trains, too
void() path_corner =
{
	movetarget_f ();
};


//Remove all monsters, this is a DM mod

void() monster_oldone =
{
	remove(self);
	return;
};

void() monster_enforcer =
{
	remove(self);
	return;
};

void() monster_boss =
{
	remove(self);
	return;
};

void() monster_demon1 =
{
	remove(self);
	return;
};

void() monster_dog =
{
	remove(self);
	return;
};

void() monster_fish =
{
	remove(self);
	return;
};

void() monster_hell_knight =
{
	remove(self);
	return;
};

void() monster_knight =
{
	remove(self);
	return;
};

void() monster_ogre =
{
	remove(self);
	return;
};

void() monster_shalrath =
{
	remove(self);
	return;
};

void() monster_shambler =
{
	remove(self);
	return;
};

void() monster_army =
{
	remove(self);
	return;
};

void() monster_tarbaby =
{
	remove(self);
	return;
};

void() monster_wizard =
{
	remove(self);
	return;
};

void() monster_zombie =
{
	remove(self);
	return;
};



//-----------------------------------------------------------------------------------
//
// Various essential functions
//
//-----------------------------------------------------------------------------------


void() CheckForDCP =
{
local entity dcp;
local float mt;
local string smt;

//	dcp = find(world, classname, "dcplayer");	//get to know if this player was already on the server
//	while(dcp != world)
//		if((dcp.netname != self.netname) && ((dcp.team != self.team) && teamplay))
//			dcp = find(dcp, classname, "dcplayer");
//	if(dcp)
//	{
//		if(dcp.netname == self.netname)
//		{
//			bprint(self.netname);
//			bprint(" re-entered the game after ");
//			mt = rint(time - dcp.delay);
//			MOTD = " seconds.\n";	//MOTD currently not used
//			if(mt >= 60)
//			{
//				mt = mt / 60;
//				MOTD = " minutes.\n";
//			}
//			smt = ftos(mt);
//			bprint(smt);
//			bprint(MOTD);
//		}
//		else
//		{
//			bprint(self.netname);
//			bprint(" gets the frags of his disconnected teammate ");
//			bprint(dcp.netname);
//			bprint(".\n");
//		}
//		self.frags = dcp.frags;
//		dcp.frags = 0;
//		remove(dcp);
//	}
};

float() GetMaxplayers =
{
	local entity player;
	local float mps;

	player = nextent(world);
	while(player)
	{
		mps = mps + 1;
		player = nextent(player);
	}
	if (mps > 16)	//MEZ ADDED
	return 16;		//MEZ ADDED
	return mps;
};

entity() RandomPlayer =
{
local float ps, rp;
local entity e;

	ps = 0;
	e = find(world, classname, "player");
	while(e)
	{
		if(e.mode == M_PLAYER)
			ps = ps + 1;
		e = find(e, classname, "player");
	}
	rp = rint(random()*(ps - 1) + 1);	//pick a random player

	ps = 0;
	e = find(world, classname, "player");
	while(e)
	{
		if(e.mode == M_PLAYER)
			ps = ps + 1;
		if(ps == rp)
			return e;
		e = find(e, classname, "player");
	}
	return world;
};

entity() LastHunted =
{
local float hunted;
local entity e, lasthunted;

	hunted = 0;
	e = find(world, classname, "player");
	while(e)
	{
		if((e.mode == M_PLAYER) && (e.genteam == THUNTED))
		{
			hunted = hunted + 1;
			lasthunted = e;
		}
		e = find(e, classname, "player");
	}
	if(hunted == 1)
		return lasthunted;
	return world;
};

float() MatchIsTied =
{
	local entity e;
	local float hs, d;

	hs = -999;
	if(teamplay)
	{
		e = find(world, classname, "team_e");
		while(e)
		{
			if(e.frags > hs)
				hs = e.frags;
			e = find(e, classname, "team_e");
		}		

		e = find(world, classname, "team_e+scorepos");
		while(e)
		{
			if(e.frags > hs)
				hs = e.frags;
			e = find(e, classname, "team_e+scorepos");
		}
		//defined highest team score

		e = find(world, classname, "team_e");
		while(e)
		{
			if(e.frags == hs)
				d = d + 1;
			e = find(e, classname, "team_e");
		}		

		e = find(world, classname, "team_e+scorepos");
		while(e)
		{
			if(e.frags == hs)
				d = d + 1;
			e = find(e, classname, "team_e+scorepos");
		}
		if(d > 1)
			return TRUE;
	}
	else
	{
		e = find(world, classname, "player");
		while(e)
		{
			if(e.frags > hs)
				hs = e.frags;
			e = find(e, classname, "player");
		}
		//defined highest score

		e = find(world, classname, "player");
		while(e)
		{
			if(e.frags == hs)
				d = d + 1;
			e = find(e, classname, "player");
		}
		if(d > 1)
			return TRUE;
	}
	return FALSE;
};

float() NumberOfPlayers =
{
	local float np = 0;
	local entity p;

	p = find(world, classname, "player");
	while(p != world)
	{
		if(p.mode != M_OBSERVER)
			np = np + 1;
		p = find(p, classname, "player");
	}
	return rint(np);
};

void() PlayerStats =
{
	local entity p;
	local float acount;

	p = find(world, classname, "player");
	while(p != world)
	{
		sprint(self, p.netname);

		if(!gamestatus & G_STARTED)
		{
			sprint(self, ":\n");
			if(p.state & S_READYPLAY)
				sprint(self, " ready to play.\n");
			else if(p.state & S_READYOBSERVER)
				sprint(self, " ready to observe.\n");
			else
				sprint(self, " НОТ ready.\n");	//=NOT
		}
		else
		{
			sprint(self, ":");
			if(deathmatch & D_HH)
			{
				if(p.genteam == THUNTER)
				{
					sprint(self, "\n is Hunter");
					acount = TRUE;
				}
				if(p.genteam == THUNTED)
				{
					sprint(self, "\n is Hunted");
					acount = TRUE;
				}
			}
			if(p.state & S_BREAK)
			{
				sprint(self, "\n voted for a matchbreak");
				acount = TRUE;
			}
			if(p.state & S_VOTEREINC1)
			{
				if(acount)	//Mez vote disabled these lines
					sprint(self, ",");
				sprint(self, "\n voted for REINC1");
				acount = TRUE;
			}
			if(p.state & S_VOTEREINC2)
			{
				if(acount)
					sprint(self, ",");
				sprint(self, "\n voted for REINC2");
				acount = TRUE;
			}
			if(p.state & S_VOTEREINC3)
			{
				if(acount)
					sprint(self, ",");
				sprint(self, "\n voted for REINC3");
				acount = TRUE;
			}
			if(p.state & S_VOTEREINC4)
			{
				if(acount)
					sprint(self, ",");
				sprint(self, "\n voted for REINC4");
				acount = TRUE;
			}
			if(p.state & S_VOTEREINC5)
			{
				if(acount)
					sprint(self, ",");
				sprint(self, "\n voted for REINC5");
				acount = TRUE;
			}
			if(p.state & S_VOTEREINC6)
			{
				if(acount)
					sprint(self, ",");
				sprint(self, "\n voted for REINC6");
				acount = TRUE;
			}
		}
		sprint(self, "\n");

		p = find(p, classname, "player");
	}
};

float() AverageFrags =
{
	local float ts = 0;
	local float as = 0;
	local float np = 0;
	local entity pl;

	pl = find(world, classname, "player");
	while(pl != world)
	{
		if(pl.mode != M_OBSERVER)
		{
			np = np + 1;
			ts = ts + pl.frags;
		}
		pl = find(pl, classname, "player");
	}
	np = rint(np);
	as = ts / np;
	return rint(as);
};



float() BreakGame =
{
	local float gbreak = 0;
	local float b = 0;
	local float np = 0;
	local entity pl;

	pl = find(world, classname, "player");
	while(pl != world)
	{
		if(pl.mode != M_OBSERVER)
			np = np + 1;
		if(pl.state & S_BREAK)
			b = b + 1;
		pl = find(pl, classname, "player");
	}
	np = rint(np);

	gbreak = b / np;
	if(gbreak > 0.5)
		return TRUE;
	return FALSE;
};

//-----------------------------------------------------------------------------------
//
// Functions that replace old functions
//
//-----------------------------------------------------------------------------------

float() GeN_BestWeapon =
{
	local	float	it;
// < GeN 

    if (self.weaponallowed == FALSE)
    {
	    return 0;
    }
	
// GeN >

	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
			return IT_LIGHTNING;
	if(self.ammo_rockets >= 1 && (it & IT_ROCKET_LAUNCHER) )
		return IT_ROCKET_LAUNCHER;
	if(self.ammo_rockets >= 1 && (it & IT_GRENADE_LAUNCHER) )
		return IT_GRENADE_LAUNCHER;
	if(self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;
	return IT_AXE;
};

float(entity s) BadSpot =
{
	local entity thing;
	thing = findradius(s.origin, 40);	//slightly bigger radius
	while(thing)
	{
		if ((thing.classname == "player") && (thing.health > 0))
			return TRUE;
		thing = thing.chain;
	}
	return FALSE;
};

entity() GeNSelectSpawnPoint =
{
	local	entity rspot, spot, e;
	local	entity thing;
	local	float  pcount, sp, rsp;
	
// choose a info_player_deathmatch point

	sp = 0;
	e = find(world, classname, "info_player_deathmatch");
	while(e)
	{
		sp = sp + 1;
		e = find(e, classname, "info_player_deathmatch");
	}
	rsp = rint(random()*(sp - 1) + 1);	//pick a random spawn pos

	sp = 0;
	spot = find(world, classname, "info_player_deathmatch");
	while(spot)
	{
		sp = sp + 1;
		if((sp >= rsp) && (spot != lastspawn) && (!BadSpot(spot)))
		{
//			bprint("found goodspot\n");
			lastspawn = spot;
			return spot;
		}
		spot = find(spot, classname, "info_player_deathmatch");
	}

	sp = 0;
	spot = find(world, classname, "info_player_deathmatch");
	while(spot)
	{
		sp = sp + 1;
		if((sp < rsp) && (spot != lastspawn) && (!BadSpot(spot)))
		{
//			bprint("found goodspot2\n");
			lastspawn = spot;
			return spot;
		}
		spot = find(spot, classname, "info_player_deathmatch");
	}

	sp = 0;
	spot = find(world, classname, "info_player_deathmatch");
	while(spot)
	{
		sp = sp + 1;
		if(rsp == sp)
		{
//			bprint("forced randomspot\n");
			lastspawn = spot;
			return spot;
		}
		spot = find(spot, classname, "info_player_deathmatch");
	}

	spot = find(world, classname, "info_player_start");
	if (!spot)
		error ("GeNSelectSpawnPoint: no info_player_start on level");
	
	return spot;
};

void() GeNBackpackTouch =
{
	local string	s;
	local	float	best, old, new;
	local		entity	stemp;
	local	float	acount;
	
	if((self.state & S_DROPPED) && (other == self.owner) && (self.nextthink > (time + 17.5)))
		return;
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	acount = 0;
	if(!temp1 & T_NOMESSAGES)
		sprint (other, "You get ");

	if((deathmatch & D_MOREHEALTH) && (!self.state & S_DROPPED))
	{
		if((T_Heal(other, 10, 1)) && (!temp1 & T_NOMESSAGES))
			sprint(other,"10 health ");
		acount = 1;
	}

// change weapons
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	bound_other_ammo ();

	if(!temp1 & T_NOMESSAGES)
	{
		if (self.ammo_shells)
		{
			if (acount)
				sprint(other, ", ");
			acount = 1;
			s = ftos(self.ammo_shells);
			sprint (other, s);
			sprint (other, " shells");
		}
		if (self.ammo_nails)
		{
			if (acount)
				sprint(other, ", ");
			acount = 1;
			s = ftos(self.ammo_nails);
			sprint (other, s);
			sprint (other, " nails");
		}
		if (self.ammo_rockets)
		{
			if (acount)
				sprint(other, ", ");
			acount = 1;
			s = ftos(self.ammo_rockets);
			sprint (other, s);
			sprint (other, " rockets");
		}
		if (self.ammo_cells)
		{
			if (acount)
				sprint(other, ", ");
			acount = 1;
			s = ftos(self.ammo_cells);
			sprint (other, s);
			sprint (other, " cells");
		}

		if(self.state & S_DROPPED)
		{
			sprint(other, " from ");
			sprint(other, self.owner.netname);
		}
		sprint (other, "\n");
	}
	
// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// remove the backpack, change self to the player
	remove(self);
	self = other;

	W_SetCurrentAmmo ();
};

void() GeNDropBackpack =
{
	local entity	item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells + self.items))
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = GeNBackpackTouch;
	item.classname = "backpack";
	
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};

//-----------------------------------------------------------------------------------
//
// "Drop" functions
//
//-----------------------------------------------------------------------------------

void() GeNWeaponTouch =
{
	local string	s;
	local float best, old, new;
	local entity	stemp;
	local float acount;
	
	if((self.state & S_DROPPED) && (other == self.owner) && (self.nextthink > (time + 17.5)))
		return;
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;


// < GeN
	if(!temp1 & T_NOMESSAGES)
	{
		sprint (other, "You get a ");
		sprint (other, self.netname);
		if(self.state & S_DROPPED)
		{
			sprint (other, " from ");
			sprint (other, self.owner.netname);
		}
		sprint (other, "\n");
	}
// GeN >

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	new = self.items;
	if (!new)
		new = other.weapon;
	old = other.items;
	other.items = other.items | new;
	
// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// remove the weapon, change self to the player
	remove(self);
	self = other;

// change to the weapon
	if (!deathmatch)
		self.weapon = new;
	else
		Deathmatch_Weapon (old, new);

	W_SetCurrentAmmo ();
};

void(float bkpk) DropWeapon =
{
	local entity	item;

// < GeN 
	if (!self.items)
		return;	// nothing to drop
// GeN >

	if((self.weapon == IT_HOOK) || (self.weapon == IT_AXE) || (self.weapon == IT_SHOTGUN))
		return;

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
	if((temp1 & T_FAIRWEAPON) && (self.health < 1))
		self.weapon = GeN_BestWeapon();
	item.items = self.weapon;

	if (item.items == IT_SUPER_SHOTGUN)
	{
		item.netname = "Double-barrelled Shotgun";
		setmodel (item, "progs/g_shot.mdl");
	}
	else if (item.items == IT_NAILGUN)
	{
		item.netname = "Nailgun";
		setmodel (item, "progs/g_nail.mdl");
	}
	else if (item.items == IT_SUPER_NAILGUN)
	{
		item.netname = "Super Nailgun";
		setmodel (item, "progs/g_nail2.mdl");
	}
	else if (item.items == IT_GRENADE_LAUNCHER)
	{
		item.netname = "Grenade Launcher";
		setmodel (item, "progs/g_rock.mdl");
	}
	else if (item.items == IT_ROCKET_LAUNCHER)
	{
		item.netname = "Rocket Launcher";
		setmodel (item, "progs/g_rock2.mdl");
	}
	else if (item.items == IT_LIGHTNING)
	{
		item.netname = "Thunderbolt";
		setmodel (item, "progs/g_light.mdl");
	}
	else
	{
		item.netname = "";
		setmodel (item, "progs/backpack.mdl");
	}

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setsize (item, '-16 -16 0', '16 16 56');
	item.classname = "tossedweapon";

	if(!bkpk)
	{
		item.state = S_DROPPED;
		item.owner = self;
	}
	item.touch = GeNWeaponTouch;
	
	if(!bkpk)
		item.nextthink = time + 20;	// remove after 20 secs
	else
		item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};

void() GeNBackpackTouch;	//declared below
void() DropAmmo =
{
	local entity item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it


	item = spawn();
	item.origin = self.origin - '0 0 24';

	if(self.ammo_shells > 9)
	{
		item.ammo_shells = 10;
		self.ammo_shells = self.ammo_shells - 10;
	}
	if(self.ammo_nails > 9)
	{
		item.ammo_nails = 10;
		self.ammo_nails = self.ammo_nails - 10;
	}
	if(self.ammo_rockets > 9)
	{
		item.ammo_rockets = 10;
		self.ammo_rockets = self.ammo_rockets - 10;
	}
	if(self.ammo_cells > 9)
	{
		item.ammo_cells = 10;
		self.ammo_cells = self.ammo_cells - 10;
	}

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.state = S_DROPPED;
	item.owner = self;
	item.touch = GeNBackpackTouch;
	item.classname = "tossedammo";
	
	item.nextthink = time + 20;	// remove after 20 secs
	item.think = SUB_Remove;

	W_SetCurrentAmmo ();
};

void() DropHealth =
{
	local entity item;

	if (self.health < 11)
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';

	item.healamount = 10;
	self.health = self.health - 10;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel(item, "maps/b_bh10.bsp");
	item.noise = "items/r_item1.wav";
	setsize (item, '0 0 0', '32 32 56');
	item.state = S_DROPPED;
	item.owner = self;
	item.touch = health_touch;
	item.healtype = 0;
	item.classname = "tossedhealth";
	
	item.nextthink = time + 20;	// remove after 20 secs
	item.think = SUB_Remove;

	W_SetCurrentAmmo ();
};

void() DropArmor =
{
	local entity	item;

	if (!self.armorvalue) 
		return;	// no armor

	item = spawn();
	item.origin = self.origin - '0 0 24';

	if(self.armortype == 0.8)
	{
		self.items = self.items - (self.items & IT_ARMOR3);
		item.classname = "item_armorInv";
		item.skin = 2;
	}	
	else if( ((self.armortype == 0.65) && (!deathmatch & D_ORIGBAL)) || ((self.armortype == 0.5) && (deathmatch & D_ORIGBAL)) ) //Mez Balance
	{
		self.items = self.items - (self.items & IT_ARMOR2);
		item.classname = "item_armor2";
		item.skin = 1;
	}
	else if( ((self.armortype == 0.5) && (!deathmatch & D_ORIGBAL) ) || ( (self.armortype == 0.3) && (deathmatch & D_ORIGBAL)) ) //Mez Balance
	{
		self.items = self.items - (self.items & IT_ARMOR1);
		item.classname = "item_armor1";
		item.skin = 0;
	}
	item.armorvalue = self.armorvalue;
	self.armorvalue = 0;
	self.armortype = 0;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/armor.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.state = S_DROPPED;
	item.owner = self;
	item.touch = armor_touch;
	item.classname = "tossedarmor";
	
	item.nextthink = time + 20;	// remove after 20 secs
	item.think = SUB_Remove;
};

void(entity e) DropPowerup =
{
	local entity	ring, quad;

	if((gamestatus & G_BERSERKMODE) || (e.state & S_BERSERK))	//That would be some dropped quads too much =)
		return;

	if(e.quadtime > time)
	{
		quad = spawn();
		quad.origin = e.origin - '0 0 24';
	
		quad.netname = "Quad Damage";
		quad.classname = "item_artifact_super_damage";
		quad.health = (e.quadtime - time) + 1;
		quad.quadleft = quad.health; //MEZ Added

		quad.velocity_z = 300;
		quad.velocity_x = -100 + (random() * 200);
		quad.velocity_y = -100 + (random() * 200);
	
		quad.flags = FL_ITEM;
		quad.solid = SOLID_TRIGGER;
		quad.movetype = MOVETYPE_TOSS;
		quad.noise = "items/damage.wav";
		quad.items = IT_QUAD;
		setsize (quad, '-16 -16 -24', '16 16 32');
		setmodel (quad, "progs/quaddama.mdl");
		quad.touch = powerup_touch;
		quad.state = S_DROPPED;
		//quad.classname = "tossedquad"; //MEZ maybe this is overriding?

		quad.nextthink = time + quad.health * 1;	// remove after a certain time // MEZ changed multiplier from 2 to 1
		quad.think = SUB_Remove;
	}
	if(e.ringtime > time)
	{
		ring = spawn();
		ring.origin = e.origin - '0 0 24';
	
		ring.netname = "Ring of Shadows";
		ring.classname = "item_artifact_invisibility";
		ring.health = (e.ringtime - time) + 1;
		ring.ringleft = ring.health; //MEZ Added

		ring.velocity_z = 300;
		ring.velocity_x = -100 + (random() * 200);
		ring.velocity_y = -100 + (random() * 200);
	
		ring.flags = FL_ITEM;
		ring.solid = SOLID_TRIGGER;
		ring.movetype = MOVETYPE_TOSS;
		ring.noise = "items/inv1.wav";
		ring.items = IT_INVISIBILITY;
		setsize (ring, '-16 -16 -24', '16 16 32');
		setmodel (ring, "progs/invisibl.mdl");
		ring.touch = powerup_touch;
		ring.state = S_DROPPED;	
		//ring.classname = "tossedring"; //MEZ DISABLED

		ring.nextthink = time + ring.health * 1;	// remove after a certain time  // MEZ changed multiplier from 2 to 1
		ring.think = SUB_Remove;
	}
};

//-----------------------------------------------------------------------------------
//
// Dark DM
//
//-----------------------------------------------------------------------------------

void() Flare_Touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (!other.health)
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
	remove(self);	
};

void() W_FireFlare =
{
	sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_STATIC);

	if(self.attack_finished > time)
		return;

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	makevectors (self.v_angle);
	newmis.velocity = aim(self, 1000);
	newmis.velocity = newmis.velocity * 1000;
	newmis.angles = vectoangles(newmis.velocity);
	
	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Flare_Touch;

	self.attack_finished = time + 0.3;
};

//-----------------------------------------------------------------------------------
//
// Berserk 
//
//-----------------------------------------------------------------------------------

void() BerserkMode =
{
	local entity p, otimer;

	bprint("┘берсеркмоде┘\n");
	p = find(world, classname, "player");
	while(p)
	{
		if((p.health > 0) && (p.mode == M_PLAYER))
		{
			p.invincible_finished = time + 2;
			p.invincible_time = 1;
			p.super_damage_finished = time + 30;
			p.super_time = 1;
			if(!p.items & IT_INVULNERABILITY)
				p.items = p.items | IT_INVULNERABILITY;
			if(!p.items & IT_QUAD)
				p.items = p.items | IT_QUAD;
			sound (p, CHAN_VOICE, "items/damage.wav", 1, ATTN_NORM);
		}
		p = find(p, classname, "player");
	}
	if(!gamestatus & G_BERSERKMODE)
		gamestatus = gamestatus | G_BERSERKMODE;
};

//-----------------------------------------------------------------------------------
//
// Other stuff
//
//-----------------------------------------------------------------------------------

float(entity damageinflictor, vector targorg) DetermineZone =
{
local vector d;
local float dist;
local entity test;

	d = damageinflictor.origin - targorg;
	d_z = 0;
	dist = vlen(d);
	d = damageinflictor.origin + dist*normalize(damageinflictor.velocity);

	dist = d_z - targorg_z;
	if((dist >= 24) && (dist < 32))
		return Z_HEAD;
	if(dist >= 16)
		return Z_CHEST;
	if(dist < -5)
		return Z_FEET;
};

float(vector damageinflictor, vector targorg, vector dir) DetermineZone2 =
{
local vector d;
local float dist;
local entity test;

	d = damageinflictor - targorg;
	d_z = 0;
	dist = vlen(d);
	d = damageinflictor + dist*normalize(dir);

	dist = d_z - targorg_z;
	if((dist >= 24) && (dist < 32))
		return Z_HEAD;
	if(dist >= 16)
		return Z_CHEST;
	if(dist < -5)
		return Z_FEET;
};

