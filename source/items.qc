void() W_SetCurrentAmmo;
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};



/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos(self.origin));
	dprint ("\n");
	remove (self);
};

/*
============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
	local float	oldz;

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;
	if (!droptofloor())
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
		return;
	}
};

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
		self.nextthink = time + 0.2;	// items start after other solids
		self.think = PlaceItem;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//

// < GeN changed healamount here to chealamount >
float (entity e, float chealamount, float ignore) T_Heal =
{
	if (e.health <= 0)
		return 0;
	if ((!ignore) && (e.health >= other.max_health))
		return 0;
	chealamount = ceil(chealamount);

	e.health = e.health + chealamount;
	if ((!ignore) && (e.health >= other.max_health))
		e.health = other.max_health;

	if(deathmatch & D_MOREHEALTH)
	{
		if (e.health > DM_MOREHEALTH_MAXHEALTH)
			e.health = DM_MOREHEALTH_MAXHEALTH;
	}		
	else
	{
		if (e.health > 250)
			e.health = 250;
	}
// < GeN 
	if((e.health > 10) && (e.state & S_BERSERK))
	{
		e.state = e.state - (e.state & S_BERSERK);
		e.items = e.items - (e.items & IT_QUAD);
		e.effects = e.effects - (self.effects & EF_DIMLIGHT);
		stuffcmd (e, "bf\n");
		sound (e, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
	}
// GeN >
	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
// < GeN now in defs.qc 
//.float	healamount, healtype;
// GeN >
void() health_touch;
void() item_megahealth_rot;

void() item_health =
{	
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(savedgamecfg & SK_NOHEALTH)
	{
		remove(self);
		return;
	}
// GeN >

	self.touch = health_touch;

	if (self.spawnflags & H_ROTTEN)
	{
		precache_model("maps/b_bh10.bsp");

		precache_sound("items/r_item1.wav");
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 15;
		self.healtype = 0;
	}
	else if (self.spawnflags & H_MEGA)
	{
		precache_model("maps/b_bh100.bsp");
		precache_sound("items/r_item2.wav");
		setmodel(self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}
	else
	{
		precache_model("maps/b_bh25.bsp");
		precache_sound("items/health1.wav");
		setmodel(self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.healamount = 25;
		self.healtype = 1;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

// 1998-08-11 Multiple megahealth rot down too fast fix by Maddes/Athos  start
void(entity rotowner) MakeHealthRot =
{
        local entity rot;
        rot = spawn ();
        rot.classname = "health_rot";
        rot.nextthink = time + 5;
        rot.think = item_megahealth_rot;
        rot.owner = rotowner;
};
// 1998-08-11 Multiple megahealth rot down too fast fix by Maddes/Athos  end

void() health_touch =
{
	local	float amount;
	local	string	s;
// < GeN 
	if((self.state & S_DROPPED) && (other == self.owner) && (self.nextthink > (time + 17.5)))
		return;
// GeN >
	if (other.classname != "player")
		return;
	
	if (self.healtype == 2) // Megahealth?  Ignore max_health...
	{
// < GeN 
		if(deathmatch & D_MOREHEALTH)
		{
			if (other.health >= DM_MOREHEALTH_MAXHEALTH)
				return;
		}
		else
		{
			if (other.health >= 250)
				return;
		}
// GeN >
		if (!T_Heal(other, self.healamount, 1))
			return;
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0))
			return;
	}
	
// < GeN
	if(!temp1 & T_NOMESSAGES)
	{
		sprint(other, "You receive ");
		s = ftos(self.healamount);
		sprint(other, s);
		sprint(other, " health");
		if(self.state & S_DROPPED)
		{
			sprint(other, " from ");
			sprint(other, self.owner.netname);
		}
		sprint(other, "\n");
	}
// GeN >
	
// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	stuffcmd (other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
// 1998-08-11 Multiple megahealth rot down too fast fix by Maddes/Athos  start
                local entity    stemp;

                // search player's health rot entity
                stemp = find (world, classname, "health_rot");
                while ( (stemp!=world) && (stemp.owner != other) )
                {
                        stemp = find(stemp,classname,"health_rot");
                }

                if (stemp)
                {
                        // delay health rotting again
                        stemp.nextthink = time + 5;
                        stemp.think = item_megahealth_rot;
                }
                else
                        MakeHealthRot(other);   // create rot entity
// 1998-08-11 Multiple megahealth rot down too fast fix by Maddes/Athos  end
		other.items = other.items | IT_SUPERHEALTH;
// 1998-08-11 Multiple megahealth rot down too fast fix by Maddes/Athos  start
/*
                self.nextthink = time + 5;
                self.think = item_megahealth_rot;
                self.owner = other;
*/
//                if (deathmatch == 1)    // deathmatch 2 is silly old rules
                  if (deathmatch)    // deathmatch 2 is silly old rules  //MEZ MODDED
                {
                        self.nextthink = time + self.healamount + 0;      // delay (5) + health + respawn wait (20) //MEZ MODDED
                        self.think = SUB_regen;
                }
// 1998-08-11 Multiple megahealth rot down too fast fix by Maddes/Athos  end
	}
	else
	{
		if (deathmatch)
			self.nextthink = time + 20;
		self.think = SUB_regen;
	}
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};	

void() item_megahealth_rot =
{
	other = self.owner;
	
// < GeN
	if(other.mode == M_OBSERVER)
	{
		other.health = 666;
		other.items = other.items - (other.items & IT_SUPERHEALTH);
	
		self.nextthink = time + 20;
		self.think = SUB_regen;
		return;
	}
// GeN >

// CTF ->
//ZOID: player doesn't rot if they have Elder Magic rune
	if ((other.health > other.max_health) && (!(other.player_flag & ITEM_RUNE4_FLAG)))
// CTF <-
	{
                other.health = other.health - 1;
		self.nextthink = time + 1;
		return;
	}

// it is possible for a player to die and respawn between rots, so don't
// just blindly subtract the flag off
	other.items = other.items - (other.items & IT_SUPERHEALTH);
	remove(self);
/*	
	if (deathmatch)
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
*/
};

/*
===============================================================================

ARMOR

===============================================================================
*/

void() armor_touch;

void() armor_touch =
{
	local	float	type, value, bit;
	
// < GeN 
	if((self.state & S_DROPPED) && (other == self.owner) && (self.nextthink > (time + 17.5)))
		return;
// GeN >
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;

	if (self.classname == "item_armor1")
	{
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			type = 0.3;
		else if (!deathmatch & D_ORIGBAL) 
			type = 0.5; //Mez increased armor
		value = 100;
		bit = IT_ARMOR1;
	}
	if (self.classname == "item_armor2")
	{
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			type = 0.5;
		else if (!deathmatch & D_ORIGBAL) 
			type = 0.65; //Mez increased armor
		value = 150;
		bit = IT_ARMOR2;
	}
	if (self.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
		bit = IT_ARMOR3;
	}
// < GeN 
	if(self.state & S_DROPPED)
		value = self.armorvalue;
// GeN >
	if (other.armortype*other.armorvalue >= type*value)
		return;
		
	other.armortype = type;
	other.armorvalue = value;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;

	self.solid = SOLID_NOT;
	self.model = string_null;
// < GeN 
	if (!self.state & S_DROPPED) 
	{
// GeN >
		self.nextthink = time + 20;
		self.think = SUB_regen;
// < GeN 
	}
	if(!temp1 & T_NOMESSAGES)
	{
		sprint(other, "You got armor");
		if(self.state & S_DROPPED)
		{
			sprint(other, " from ");
			sprint(other, self.owner.netname);
		}
		sprint(other, "\n");
	}
// GeN >

// armor touch sound
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
// < GeN
	if(self.state & S_DROPPED)
		remove(self);
// GeN >
};


/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor1 =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(savedgamecfg & SK_NOGA)
	{
		remove(self);
		return;
	}
// GeN >
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 0;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor2 =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(savedgamecfg & SK_NOYA)
	{
		remove(self);
		return;
	}
// GeN >
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 1;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armorInv =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(savedgamecfg & SK_NORA)
	{
		remove(self);
		return;
	}
// GeN >
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 2;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void() bound_other_ammo =
{
	if (other.ammo_shells > 100)
		other.ammo_shells = 100;
	if (other.ammo_nails > 200)
		other.ammo_nails = 200;
	if (other.ammo_rockets > 100)
		other.ammo_rockets = 100;		
	if (other.ammo_cells > 100)
		other.ammo_cells = 100;		
};


float(float w) RankForWeapon =
{
	if (w == IT_LIGHTNING)
		return 1;
	if (w == IT_ROCKET_LAUNCHER)
		return 2;
	if (w == IT_SUPER_NAILGUN)
		return 3;
	if (w == IT_GRENADE_LAUNCHER)
		return 4;
	if (w == IT_SUPER_SHOTGUN)
		return 5;
	if (w == IT_NAILGUN)
		return 6;
	return 7;
};

// CTF ->
float (float w) WeaponCode =
{
	if (w == IT_SUPER_SHOTGUN)
		return 3;
	if (w == IT_NAILGUN)
		return 4;
	if (w == IT_SUPER_NAILGUN)
		return 5;
	if (w == IT_GRENADE_LAUNCHER)
		return 6;
	if (w == IT_ROCKET_LAUNCHER)
		return 7;
	if (w == IT_LIGHTNING)
		return 8;
	return 1;
};
// CTF <-

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
void(float old, float new) Deathmatch_Weapon =
{
	local float or, nr;

// change self.weapon if desired
// CTF ->
	if (self.weapon == IT_HOOK && self.button0)
		return; // never change if we pulled ourselves to it.
// CTF <-
	if (self.weapautoswitch == 1)	//MEZ Added line
	{
		or = RankForWeapon (self.weapon);
		nr = RankForWeapon (new);
		if ( nr < or )
			self.weapon = new;
	}
};

/*
=============
weapon_touch
=============
*/
float() W_BestWeapon;

void() weapon_touch =
{
	local	float	hadammo, best, new, old;
	local	entity	stemp;
	local	float	leave;
// CTF ->
//McBain: added prevweapon local variable
	local	float	prevweapon;
// CTF <-

	if (!(other.flags & FL_CLIENT))
		return;

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

	if ((deathmatch & D_WEAPONSSTAY) || coop)
		leave = 1;
	else
		leave = 0;
	
	if (self.classname == "weapon_nailgun")
	{
		if (leave && (other.items & IT_NAILGUN) )
			return;
		hadammo = other.ammo_nails;			
		new = IT_NAILGUN;
		other.ammo_nails = other.ammo_nails + 30;
	}
	else if (self.classname == "weapon_supernailgun")
	{
		if (leave && (other.items & IT_SUPER_NAILGUN) )
			return;
		hadammo = other.ammo_rockets;			
		new = IT_SUPER_NAILGUN;
		other.ammo_nails = other.ammo_nails + 30;
	}
	else if (self.classname == "weapon_supershotgun")
	{
		if (leave && (other.items & IT_SUPER_SHOTGUN) )
			return;
		hadammo = other.ammo_rockets;			
		new = IT_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + 5;
	}
	else if (self.classname == "weapon_rocketlauncher")
	{
		if (leave && (other.items & IT_ROCKET_LAUNCHER) )
			return;
		hadammo = other.ammo_rockets;			
		new = IT_ROCKET_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 5;
	}
	else if (self.classname == "weapon_grenadelauncher")
	{
		if (leave && (other.items & IT_GRENADE_LAUNCHER) )
			return;
		hadammo = other.ammo_rockets;			
		new = IT_GRENADE_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 5;
	}
	else if (self.classname == "weapon_lightning")
	{
		if (leave && (other.items & IT_LIGHTNING) )
			return;
		hadammo = other.ammo_rockets;			
		new = IT_LIGHTNING;
		other.ammo_cells = other.ammo_cells + 15;
	}
	else
		objerror ("weapon_touch: unknown classname");

// < GeN
	if(!temp1 & T_NOMESSAGES)
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}
// GeN >

// weapon touch sound
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	bound_other_ammo ();

// change to the weapon
	old = other.items;
	other.items = other.items | new;
	
	stemp = self;
	self = other;

// CTF ->
//McBain: temp store old weapon
	prevweapon = self.weapon; 
// CTF <-

	if (!deathmatch)
		self.weapon = new;
	else
	{
// < GeN
		if(!((new == IT_LIGHTNING) && (self.waterlevel > 1)))
// GeN >
			Deathmatch_Weapon (old, new);
	}

// CTF ->
//McBain: save previous weapon if different
	if (self.weapon != prevweapon)
		self.previous_weapon = prevweapon;
// CTF <-

	W_SetCurrentAmmo();

	self = stemp;

	if (leave)
		return;

// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch)
		self.nextthink = time + 30;
	self.think = SUB_regen;
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supershotgun =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if((savedgamecfg & SK_NOSSG) || (deathmatch & D_ALLWEAPONS))
	{
		remove(self);
		return;
	}
// GeN >
	setmodel (self, "progs/g_shot.mdl");
	self.weapon = IT_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if((savedgamecfg & SK_NONG) || (deathmatch & D_ALLWEAPONS))
	{
		remove(self);
		return;
	}
// GeN >
	setmodel (self, "progs/g_nail.mdl");
	self.weapon = IT_NAILGUN;
	self.netname = "nailgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supernailgun =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if((savedgamecfg & SK_NOSNG) || (deathmatch & D_ALLWEAPONS))
	{
		remove(self);
		return;
	}
// GeN >
	setmodel (self, "progs/g_nail2.mdl");
	self.weapon = IT_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_grenadelauncher =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if((savedgamecfg & SK_NOGL) || (deathmatch & D_ALLWEAPONS))
	{
		remove(self);
		return;
	}
// GeN >
	setmodel (self, "progs/g_rock.mdl");
	self.weapon = 3;
	self.netname = "Grenade Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_rocketlauncher =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if((savedgamecfg & SK_NORL) || (deathmatch & D_ALLWEAPONS))
	{
		remove(self);
		return;
	}
// GeN >
	setmodel (self, "progs/g_rock2.mdl");
	self.weapon = 3;
	self.netname = "Rocket Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_lightning =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if((savedgamecfg & SK_NOLG) || (deathmatch & D_ALLWEAPONS))
	{
		remove(self);
		return;
	}
// GeN >
	setmodel (self, "progs/g_light.mdl");
	self.weapon = 3;
	self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
local entity	stemp;
local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;


// shotgun
	if (self.weapon == 1)
	{
		if (other.ammo_shells >= 100)
			return;
		other.ammo_shells = other.ammo_shells + self.aflag;
	}

// spikes
	if (self.weapon == 2)
	{
		if (other.ammo_nails >= 200)
			return;
		other.ammo_nails = other.ammo_nails + self.aflag;
	}

//	rockets
	if (self.weapon == 3)
	{
		if (other.ammo_rockets >= 100)
			return;
		other.ammo_rockets = other.ammo_rockets + self.aflag;
	}

//	cells
	if (self.weapon == 4)
	{
		if (other.ammo_cells >= 100)
			return;
		other.ammo_cells = other.ammo_cells + self.aflag;
	}

	bound_other_ammo ();
	
// < GeN
	if(!temp1 & T_NOMESSAGES)
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}
// GeN >
// ammo touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// change to a better weapon if appropriate

	if ( other.weapon == best )
	{
		stemp = self;
		self = other;
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo ();
		self = stemp;
	}

// if changed current ammo, update it
	stemp = self;
	self = other;
	W_SetCurrentAmmo();
	self = stemp;

// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch)
		self.nextthink = time + 30;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};




float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_shells =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(deathmatch & D_INFINITEAMMO)
	{
		remove(self);
		return;
	}
	if(savedgamecfg & SK_NOSHELLS)
	{
		remove(self);
		return;
	}
// GeN >

	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_shell1.bsp");
		setmodel (self, "maps/b_shell1.bsp");
		self.aflag = 40;
	}
	else
	{
		precache_model ("maps/b_shell0.bsp");
		setmodel (self, "maps/b_shell0.bsp");
		self.aflag = 20;
	}
	self.weapon = 1;
	self.netname = "shells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_spikes =
{
// < GeN
	savedgamecfg = cvar("savedgamecfg");
	if(deathmatch & D_INFINITEAMMO)
	{
		remove(self);
		return;
	}
	if(savedgamecfg & SK_NONAILS)
	{
		remove(self);
		return;
	}
// GeN >

	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_nail1.bsp");
		setmodel (self, "maps/b_nail1.bsp");
		self.aflag = 50;
	}
	else
	{
		precache_model ("maps/b_nail0.bsp");
		setmodel (self, "maps/b_nail0.bsp");
		self.aflag = 25;
	}
	self.weapon = 2;
	self.netname = "nails";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_rockets =
{
// < GeN
	savedgamecfg = cvar("savedgamecfg");
	if(deathmatch & D_INFINITEAMMO)
	{
		remove(self);
		return;
	}
	if(savedgamecfg & SK_NOROCKETS)
	{
		remove(self);
		return;
	}
// GeN >


	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_rock1.bsp");
		setmodel (self, "maps/b_rock1.bsp");
		self.aflag = 10;
	}
	else
	{
		precache_model ("maps/b_rock0.bsp");
		setmodel (self, "maps/b_rock0.bsp");
		self.aflag = 5;
	}
	self.weapon = 3;
	self.netname = "rockets";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_cells =
{
// < GeN
	savedgamecfg = cvar("savedgamecfg");
	if(deathmatch & D_INFINITEAMMO)
	{
		remove(self);
		return;
	}
	if(savedgamecfg & SK_NOCELLS)
	{
		remove(self);
		return;
	}
// GeN >

	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_batt1.bsp");
		setmodel (self, "maps/b_batt1.bsp");
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			self.aflag = 12;
		else if (!deathmatch & D_ORIGBAL) 
			self.aflag = 18; //MEZ increased cell count
	}
	else
	{
		precache_model ("maps/b_batt0.bsp");
		setmodel (self, "maps/b_batt0.bsp");
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			self.aflag = 6;
		else if (!deathmatch & D_ORIGBAL) 
			self.aflag = 9; //MEZ increased cell count
		
	}
	self.weapon = 4;
	self.netname = "cells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/

float WEAPON_SHOTGUN = 1;
float WEAPON_ROCKET = 2;
float WEAPON_SPIKES = 4;
float WEAPON_BIG = 8;
void() item_weapon =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_SHOTGUN)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_shell1.bsp");
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_shell0.bsp");
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}
		self.weapon = 1;
		self.netname = "shells";
	}

	if (self.spawnflags & WEAPON_SPIKES)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_nail1.bsp");
			setmodel (self, "maps/b_nail1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_nail0.bsp");
			setmodel (self, "maps/b_nail0.bsp");
			self.aflag = 20;
		}
		self.weapon = 2;
		self.netname = "spikes";
	}

	if (self.spawnflags & WEAPON_ROCKET)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_rock1.bsp");
			setmodel (self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else
		{
			precache_model ("maps/b_rock0.bsp");
			setmodel (self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}
		self.weapon = 3;
		self.netname = "rockets";
	}
	
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*
===============================================================================

KEYS

===============================================================================
*/

void() key_touch =
{
local entity	stemp;
local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.items & self.items)
		return;

// < GeN
	if(!temp1 & T_NOMESSAGES)
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other,"\n");
	}
// GeN >

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	if (!coop)
	{	
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


void() key_setsounds =
{
	if (world.worldtype == 0)
	{
		precache_sound ("misc/medkey.wav");
		self.noise = "misc/medkey.wav";
	}
	if (world.worldtype == 1)
	{
		precache_sound ("misc/runekey.wav");
		self.noise = "misc/runekey.wav";
	}
	if (world.worldtype == 2)
	{
		precache_sound2 ("misc/basekey.wav");
		self.noise = "misc/basekey.wav";
	}
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key1 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_s_key.mdl");
		setmodel (self, "progs/w_s_key.mdl");
		self.netname = "silver key";
	}
	else if (world.worldtype == 1)
	{
		precache_model ("progs/m_s_key.mdl");
		setmodel (self, "progs/m_s_key.mdl");
		self.netname = "silver runekey";
	}
	else if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_s_key.mdl");
		setmodel (self, "progs/b_s_key.mdl");
		self.netname = "silver keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key2 =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/w_g_key.mdl");
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}
	if (world.worldtype == 1)
	{
		precache_model ("progs/m_g_key.mdl");
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}
	if (world.worldtype == 2)
	{
		precache_model2 ("progs/b_g_key.mdl");
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{
local entity	stemp;
local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	centerprint (other, "You got the rune!", "", "", "");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = "";		// so rune doors won't find it
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{
local entity	stemp;
local float		best;

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

// < GeN 
	if(!temp1 & T_NOMESSAGES)
	{
// GeN >
		sprint (other, "You got the ");
// < GeN 
		if((self.netname == "Quad Damage") && (deathmatch & D_OCTADAMAGE))
			sprint (other, "Octa Damage");
		else		
// GeN >
			sprint (other, self.netname);
		sprint (other,"\n");
// < GeN 
	}

	if (!self.state & S_DROPPED)	//was not dropped by a player
// GeN >
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_invulnerability") ||
			(self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
		
		self.think = SUB_regen;
	}	

	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}
	
	if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
// < GeN 
		other.invincible_finished = time + self.health;
// GeN >
	}
	
	if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
// < GeN 
		if(self.state & S_DROPPED)//MEZ ADDED
		{
			other.invisible_finished = time + self.ringleft - 5; //MEZ ADDED
			//bprint("DROPPED RING time"); //MEZ ADDED check LINE
		}
		else
			other.invisible_finished = time + self.health; // ORIGINAL LINE: other.invisible_finished = time + self.health;
// GeN >
	}

	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
// < GeN 
		if(self.state & S_DROPPED)//MEZ ADDED
		{
			other.super_damage_finished = time + self.quadleft - 5; //MEZ ADDED
			//bprint("DROPPED QUAD time"); //MEZ ADDED check LINE
		}
		else
			other.super_damage_finished = other.super_damage_finished = time + self.health; // ORIGINAL LINE: other.super_damage_finished = time + self.health;
		//bprint("super damage time set"); //MEZ ADDED check LINE
// GeN >
	}	

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets

// < GeN 
	if(self.state & S_DROPPED)
		remove(self);
// GeN >
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/
void() item_artifact_invulnerability =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(savedgamecfg & SK_NOPENT)
	{
		remove(self);
		return;
	}
	self.health = 30;
// GeN >
	self.touch = powerup_touch;
	precache_model ("progs/invulner.mdl");
	precache_sound ("items/protect.wav");

// < GeN 

//	precache_sound ("items/protect2.wav");
//	precache_sound ("items/protect3.wav");

// GeN >
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;

	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(savedgamecfg & SK_NORING)
	{
		remove(self);
		return;
	}
	self.health = 30;
// GeN >
	self.touch = powerup_touch;

	precache_model ("progs/invisibl.mdl");	//drop powerups
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");

	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void() item_artifact_super_damage =
{
// < GeN 
	savedgamecfg = cvar("savedgamecfg");
	if(savedgamecfg & SK_NOQUAD)
	{
		remove(self);
		return;
	}
	self.health = 30;
// GeN >
	self.touch = powerup_touch;

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");

	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() BackpackTouch =
{
	local string	s;
	local	float	best, old, new;
	local		entity	stemp;
	local	float	acount;
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	acount = 0;
// < GeN
	if(!temp1 & T_NOMESSAGES)
		sprint (other, "You get ");
// GeN >

// < GeN 
	if((deathmatch & D_MOREHEALTH) && (!self.state & S_DROPPED))
	{
		if((T_Heal(other, 10, 1)) && (!temp1 & T_NOMESSAGES))
			sprint(other,"10 health ");
		acount = 1;
	}
// GeN >

// < GeN
	if(!temp1 & T_NOMESSAGES)
		if (self.items)
			if ((other.items & self.items) == 0)
			{
				acount = 1;
				sprint (other, "the ");
				sprint (other, self.netname);
			}
// GeN >

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

// change weapons
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	new = self.items;
	if (!new)
		new = other.weapon;
	old = other.items;
	other.items = other.items | new;
	
	bound_other_ammo ();

// < GeN
	if(!temp1 & T_NOMESSAGES)
	{
// GeN >
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
	
	sprint (other, "\n");
// < GeN
	}
// GeN >

// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// remove the backpack, change self to the player
	remove(self);
	self = other;

// change to the weapon
	if (!deathmatch)
		self.weapon = new;
	else
		Deathmatch_Weapon (old, new);

	W_SetCurrentAmmo ();
};

/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
	local entity	item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
// < GeN
//shotgun, axe and hook don't go into backpack
	if ((self.weapon != IT_HOOK) && (self.weapon != IT_AXE) && (self.weapon != IT_SHOTGUN))
// GeN >
		item.items = self.weapon;
	if (item.items == IT_SUPER_SHOTGUN)
		item.netname = "Double-barrelled Shotgun";
	else if (item.items == IT_NAILGUN)
		item.netname = "Nailgun";
	else if (item.items == IT_SUPER_NAILGUN)
		item.netname = "Super Nailgun";
	else if (item.items == IT_GRENADE_LAUNCHER)
		item.netname = "Grenade Launcher";
	else if (item.items == IT_ROCKET_LAUNCHER)
		item.netname = "Rocket Launcher";
	else if (item.items == IT_LIGHTNING)
		item.netname = "Thunderbolt";
	else
		item.netname = "";

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
	item.touch = BackpackTouch;
	
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};


