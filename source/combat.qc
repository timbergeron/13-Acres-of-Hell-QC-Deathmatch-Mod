void(entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7) gencenterprint7 = #73;  // sprint, but in middle
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;
// < GeN
void() CheckRoundEnd;	//declared in teamplay.qc
void() rteammatch2think;	//declared in teamplay.qc
void(entity p, float cteam) SetTeam;	//declared in teamplay.qc
void(entity e, string s) ccenterprint;	//declared in gen_misc.qc
entity() LastHunted;	//declared in gen_misc.qc
void(entity hunter) InitRR;	//declared in gen_misc.qc
float() crandom;	//declared in weapons.qc
void(vector org, vector vel) SpawnMeatSpray;	//declared in weapons.qc
void() headBecomeItem;	//declared in headgames.qc
float() NumberOfPlayers;	//declared in gen_misc.qc

// GeN >

// CTF ->
void(entity who) ResistanceSound;
// CTF <-


//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
// < GeN
float() OneTeamLeft;	//declared in teamplay.qc
void(float cteam) ApplyTeamFrags2;	//declared in teamplay.qc
string(float cteam) Team2String;	//declared in teamplay.qc
void(string s1, string s2, string s3, string s4, string soundtoplay)bcenterprint;	//declared in genmisc.qc
void() InitNewTeamMatch;	//declared in teamplay.qc
// GeN >

void(entity targ, entity attacker) Killed =
{
	local entity oself, respawner, head, lh;
	local string h, a;
	local float tl;

	oself = self;
	self = targ;
	
	if (self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

	ClientObituary(self, attacker);

// < GeN
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
			lh.frags = lh.frags + 5;
			InitRR(lh);
		}
	}
	
	if((self.hashead) && (deathmatch & D_GETHEAD))
	{
		self.hashead = FALSE;
		if((attacker.flags & FL_CLIENT) && (attacker.takedamage == DAMAGE_AIM) && (attacker.health > 0) && (attacker != self))
		{
			head = find(world, classname, "head");
			if(head != world)
			{
				setorigin(head, attacker.origin);
				head.owner = attacker;
				attacker.skin = 4;	//Mez AvP set killer skin
				attacker.frags = attacker.frags + 1; //Mez AvP added frags
				attacker.items = attacker.items | IT_HOOK; //Give Pred Hook
			}
			attacker.hashead = TRUE;
			bcenterprint(attacker.netname ,"\n\bnow owns the head!\b", "", "", "shambler/smack.wav");	//MEZ
			//bcenterprint("The head has been Stolen!" , "", "", "", "shambler/smack.wav");	
		}
		else
		{
			head = find(world, classname, "head");
			if(head != world)
			{
				if(head.owner != world)
				{
					head.owner.hashead = FALSE;
					head.owner = world;
					self.skin = 3; //Mez Avp Set skin to conan
				}
				headBecomeItem();
			}
			bcenterprint(self.netname, "\n\bhas fumbled the head!\b", "", "", "shambler/sdeath.wav");  //MEZ
			//bcenterprint("The head is loose!", "", "", "", "shambler/sdeath.wav");  //MEZ
		}
	}

	if((temp1 & T_DEATHINFO) && (attacker.health > 0) && (self != attacker))
	{
		h = ftos(attacker.health);
		if(attacker.armorvalue)
			gencenterprint7(self, attacker.netname, " had ", h, " health and ", ftos(attacker.armorvalue), " armor.", "");
		else
			gencenterprint7(self, attacker.netname, " had ", h, " health.", "", "", "");
		if(NumberOfPlayers() > 2)
			gencenterprint7(attacker, "You killed ", self.netname, ".", "", "", "", "");
	}
	
	if(teamplay & TEAM_MATCH2)
	{
		self.tm2 = 0;
		respawner = spawn();
		respawner.owner = self;
		respawner.origin = self.owner.origin;
		respawner.nextthink = time + 1;
		respawner.think = rteammatch2think;
		respawner.classname = "tm2r";
	}
// GeN >
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;
	DropRune(); //MEZ Test
	self.th_die ();
	
// < GeN
	if((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2))
		CheckRoundEnd();
// GeN >
	self = oself;
};


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
// < GeN
void(entity targ, entity inflictor, entity attacker, float damage, float zone) T_Damage=
// GeN >
{
	local	vector	dir, rv;
	local	entity	oldself;
	local	float	save;
	local	float	take, r;
	local	string	dinfo;

	if (!targ.takedamage)
		return;
// < GeN 


	if((targ.rprotecttime > time) && ((targ != attacker) && (attacker != world)))
	{
		sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
		self.invincible_sound = time + 2;
		return;
	}
// GeN >

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

// check for quad damage powerup on the attacker
// < GeN
	if(temp1 & T_HITZONES)
	{
		if(zone)
			damage = damage * zone;
		if((zone == Z_HEAD) && (random() > 0.5) && (targ.gibtime < time))
		{
			makevectors(targ.angles);
			r = crandom() * 100;
			if(random() > 0.5)
				r = r * (-1);
			rv = v_right * r;
			r = crandom() * 100;
			if(random() > 0.5)
				r = r * (-1);
			rv = rv + v_forward * r;
			SpawnMeatSpray (targ.origin + '0 0 30', rv);
			targ.gibtime = time + 0.8;
		}
	}

	if ((attacker.super_damage_finished > time) || (attacker.state & S_BERSERK))
	{
		if(deathmatch & D_OCTADAMAGE)
			damage = damage * 8;
		else
// GeN >
			damage = damage * 4;
// < GeN
	}
// GeN >

// CTF ->
// RUNE: check for double damage for rune of Black Magic powerup
	if ((attacker.player_flag & ITEM_RUNE2_FLAG) || ((deathmatch & D_GETHEAD) && (self.hashead))) //Mez Avp Added second argument
		damage = damage * 2;

//RUNE check if target has rune of Earth Magic (half damage)
	if (targ.player_flag & ITEM_RUNE1_FLAG) 
	{
		damage = damage / 2;
		ResistanceSound(targ);
	}
//RUNE

	// *XXX* EXPERT CTF mark players who hurt the flag carrier, so they 
	// are worth more points for a while.
 	if ( (attacker.classname == "player") && // attacker must be a player
 	     (targ.player_flag & ITEM_ENEMY_FLAG) && // target is a flag carrier
 	     (attacker.genteam != targ.genteam)) // target and attacker on diff teams
 		attacker.last_hurt_carrier = time;
// CTF <-

// save damage based on the target's armor level

// < GeN 
	if ((teamplay & TEAM_DAMAGEPENALTY) && (targ.team > 0) && (targ.team == attacker.team) && (targ != attacker))
	{
		attacker.deathtype = "teamdamage";
		T_Damage(attacker, world, world, damage, 0);
	}

	if (!((teamplay & TEAM_ARMORPROTECT) && (targ.team > 0) && (targ.team == attacker.team) && (targ != attacker)))
	{
		if(!((deathmatch & D_CANTHARMSELF) && (targ == attacker)))
		{
			if(!((deathmatch & D_HH) && (((attacker.genteam == THUNTED) && (targ != attacker)) || ((attacker.genteam == THUNTER) && (targ.genteam == THUNTER) && (targ != attacker)))))
			{
				//if(!((deathmatch & D_GETHEAD) && (!targ.hashead) && (targ != attacker)))	//Mez AvP disabled this to allow full kills
				//{
// GeN >
					save = ceil(targ.armortype*damage);
					if (save >= targ.armorvalue)
					{
						save = targ.armorvalue;
						targ.armortype = 0;	// lost all armor
						targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
					}
					targ.armorvalue = targ.armorvalue - save;
					take = ceil(damage-save);
// < GeN
				//}
			}
		}
	}
// GeN >

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

// figure momentum add		//Mez push on damage modification
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		//MEZ Start
		if (targ.player_flag & ITEM_RUNE1_FLAG) 
			targ.velocity = targ.velocity + dir*damage*16;
		else
			targ.velocity = targ.velocity + dir*damage*8;
	}

// check for godmode or invincibility
	//if((deathmatch & D_GETHEAD) && (!targ.hashead) && (targ != attacker))	//Mez AvP everyone can damage everyone now
	//	return;
	if((deathmatch & D_CANTHARMSELF) && (targ == attacker))
		return;
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
// < GeN altered this in accordance to teamplay flag
	if ((teamplay & TEAM_HEALTHPROTECT) && (targ.team > 0) && (targ.team == attacker.team) && (targ != attacker))
		return;

// do the damage
	targ.health = targ.health - take;

	if((temp1 & T_DAMAGEINFO) && (targ.health > 0) && (take > 30))
	{
		sprint(attacker, "You inflicted ");
		take = floor(take);
		dinfo = ftos(take);
		sprint(attacker, dinfo);
		sprint(attacker, " damage at ");
		if(targ == attacker)
			sprint(attacker, "yourself");
		else
			sprint(attacker, targ.netname);
		sprint(attacker, ".\n");
	}
// GeN >
			
	if (targ.health <= 0)
	{
// < GeN 

		if((targ.team > 0) && (targ.team == attacker.team) && (targ != attacker))
		{
			if (teamplay & TEAM_DEATHPENALTY)
			{
				attacker.deathtype = "teamdeathpenalty";
				T_Damage(attacker, world, world, 500, 0);
			}
		}
// GeN >
		Killed (targ, attacker);
		return;
	}
	else if((deathmatch & D_BERSERKDM2) && (targ.health <= 10) && (targ.mode == M_PLAYER))
	{
		sound (self, CHAN_VOICE, "items/damage.wav", 1, ATTN_NORM);
		targ.state = targ.state | S_BERSERK;
		if(!targ.items & IT_QUAD)
			targ.items = targ.items | IT_QUAD;
	}

// react to the damage
	oldself = self;
	self = targ;

	if (self.th_pain)
		self.th_pain (attacker, take);

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;
// 1998-07-07 T_RadiusDamage workaround by Robert Field  start
        local   float   attacker_damaged;
        local   float   attacker_points;
// 1998-07-07 T_RadiusDamage workaround by Robert Field  end

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
// 1998-07-07 T_RadiusDamage workaround by Robert Field  start
/*
                                if (head == attacker)
                                        points = points * 0.5;
*/
// 1998-07-07 T_RadiusDamage workaround by Robert Field  end
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{
// 1998-07-07 T_RadiusDamage workaround by Robert Field  start
	                                        if (head != attacker)
        	                                {
// 1998-07-07 T_RadiusDamage workaround by Robert Field  end
							T_Damage (head, inflictor, attacker, points, 0);
// 1998-07-07 T_RadiusDamage workaround by Robert Field  start
                                                }
                                                else
                                                {
                                                        attacker_damaged = TRUE;
                                                        attacker_points = points * 0.5;
                                                }
// 1998-07-07 T_RadiusDamage workaround by Robert Field  end					}
					}
				}
			}
		}
		head = head.chain;
	}
// 1998-07-07 T_RadiusDamage workaround by Robert Field  start
        if (attacker_damaged)
                T_Damage (attacker, inflictor, attacker, attacker_points, 0);
// 1998-07-07 T_RadiusDamage workaround by Robert Field  end
};

/*
============
T_BeamDamage
============
*/
void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
					T_Damage (head, attacker, attacker, points, 0);
				}
			}
		}
		head = head.chain;
	}
};

