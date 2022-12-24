/*
*/
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;
void() NextLevel;
// CTF ->
void() HasteSound;
// CTF <-

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
	
	precache_model ("progs/w_g_key.mdl");
	precache_model ("progs/w_s_key.mdl");

// CTF ->
	precache_sound2 ("blob/land1.wav");     // chain go splorch!
// CTF <-
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;
	local	float	zone;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*128, FALSE, self); //MEZ Orginally forward 64 units for axe range 
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		zone = DetermineZone2(trace_endpos, trace_ent.origin, (source + v_forward*64));
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 80);
		T_Damage (trace_ent, self, self, 100, Z_CHEST);  //MEZ damage originally 20
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile, mpuff;
	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;
float	multi_zone;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	multi_zone = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage, multi_zone);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		multi_zone = DetermineZone2(trace_endpos, trace_ent.origin, direction);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x = -2;
	
// < GeN 
	if(!deathmatch & D_INFINITEAMMO)
// GeN >
		self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	if (deathmatch & D_ORIGBAL) //Mez Original Balance
	{
		dir = aim (self, 100000);
		FireBullets (6, dir, '0.04 0.04 0');
	}
	else if (!deathmatch & D_ORIGBAL) 
	{
		dir = aim (self, 1000); //MEZ originally 100000, changed to 1000
		FireBullets (12, dir, '0.01 0.01 0'); // MEZ spreads originally 0.04 0.04 0 and bullets was 6 (changed to 12)
	}
};

/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
// < GeN 
	if(!deathmatch & D_INFINITEAMMO)
// GeN >
		self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	if (deathmatch & D_ORIGBAL) //Mez Original Balance
	{
		dir = aim (self, 100000);
		FireBullets (14, dir, '0.14 0.08 0');
	}
	else if (!deathmatch & D_ORIGBAL) 
	
	{
		dir = aim (self, 1000); //MEZ originally 100000, changed to 1000
		FireBullets (32, dir, '0.09 0.07 0'); //MEZ origially 14 bullets at 0.14 0.08 spread.  Boosted bigly.
	}
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() T_MissileTouch =
{
	local float	damg;
	local float	zone;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;
	
	if (other.health)
	{
		zone = DetermineZone(self, other.origin);
		T_Damage (other, self, self.owner, damg, zone);
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	local	entity missile;
	
// < GeN 

	if(!deathmatch & D_INFINITEAMMO)
// GeN >
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	makevectors (self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = T_MissileTouch;
	
// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	local float		zone;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		zone = DetermineZone2(trace_endpos, trace_ent.origin, (p1 - p2));
		T_Damage (trace_ent, from, from, damage, zone);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		zone = DetermineZone2(trace_endpos, trace_ent.origin, (p1 - p2));
		T_Damage (trace_ent, from, from, damage, zone);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		zone = DetermineZone2(trace_endpos, trace_ent.origin, (p1 - p2));
		T_Damage (trace_ent, from, from, damage, zone);
	}
};


void() W_FireLightning =
{
	local	vector		org;
	local	float		cells;

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;

// < GeN 
		if(!deathmatch & D_INFINITEAMMO)
// GeN >
			self.ammo_cells = 0;
		W_SetCurrentAmmo ();
		T_RadiusDamage (self, self, 35*cells, world);
		return;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	self.punchangle_x = -2;

// < GeN 

	if(!deathmatch & D_INFINITEAMMO)
// GeN >
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	org = self.origin + '0 0 16';
	
	traceline (org, org + v_forward*600, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

// < GeN 
	if(deathmatch & D_FASTRELOAD)
		LightningDamage (self.origin, trace_endpos + v_forward*4, self, 60);
	else	
// GeN >
		LightningDamage (self.origin, trace_endpos + v_forward*4, self, 30);
};


//=============================================================================


void() GrenadeExplode =
{
	if (deathmatch & D_ORIGBAL) //Mez Original Balance
		T_RadiusDamage (self, self.owner, 120, world);
	else if (!deathmatch & D_ORIGBAL) 
		T_RadiusDamage (self, self.owner, 150, world); // Mez buff damage to 150, was 120

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

// < GeN
void(entity e) GrenadeExplodeDirect =
{
	if (deathmatch & D_ORIGBAL) //Mez Original Balance
		T_RadiusDamage (self, self.owner, 120, world);
	else if (!deathmatch & D_ORIGBAL) 
		T_RadiusDamage (self, self.owner, 150, world); // Mez buff damage to 150, was 120

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};
// GeN >

void() GrenadeTouch =
{
local float zone;

	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		zone = DetermineZone(self, other.origin);
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			T_RadiusDamage (self, self.owner, 120, world);
		else if (!deathmatch & D_ORIGBAL) 
			T_RadiusDamage (self, self.owner, 150, world); // Mez buff damage to 150, was 120
		GrenadeExplodeDirect(other);
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile;
	
// < GeN 
	if(!deathmatch & D_INFINITEAMMO)
// GeN >
		self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	if (deathmatch & D_ORIGBAL) //Mez Original Balance
		newmis.velocity = dir * 1000;
	else if (!deathmatch & D_ORIGBAL) 
		newmis.velocity = dir * 1500; //MEZ original line = "newmis.velocity = dir * 1000;" slower speed than super NG for normal nailgun
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	local entity	old;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;

// < GeN 
	if(!deathmatch & D_INFINITEAMMO)
// GeN >
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			self.currentammo = self.ammo_nails = self.ammo_nails - 2;
		else if (!deathmatch & D_ORIGBAL) 
			self.currentammo = self.ammo_nails = self.ammo_nails - 1; // MEZ super nails cost 2 originally
		
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	if (deathmatch & D_ORIGBAL) //Mez Original Balance
		newmis.velocity = dir * 1000;
	else if (!deathmatch & D_ORIGBAL) 
		newmis.velocity = dir * 3500; //MEZ added to change projectile speed for just super nailgun
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	local entity	old;
	
	makevectors (self.v_angle);
	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;

// < GeN 
	if(!deathmatch & D_INFINITEAMMO)
// GeN >
		self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

	self.punchangle_x = -2;
};



.float hit_z;
void() spike_touch =
{
local float rand, zone;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		zone = DetermineZone(self, other.origin);
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			T_Damage (other, self, self.owner, 9, zone);
		else if (!deathmatch & D_ORIGBAL) 
			T_Damage (other, self, self.owner, 32, zone); // MEZ increase damage up from 9, slower firing
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
local float rand, zone;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		zone = DetermineZone(self, other.origin);
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			T_Damage (other, self, self.owner, 18, zone);
		else if (!deathmatch & D_ORIGBAL) 
			T_Damage (other, self, self.owner, 20, zone); // MEZ damage adjust	
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	player_run ();		// get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );

	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = 0;
	}
	else if (self.weapon == IT_HOOK)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = 0;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};

float() W_BestWeapon =
{
	local	float	it;
// < GeN 
    if (self.weaponallowed == FALSE)
	    return 0;
// GeN >

	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
			return IT_LIGHTNING;
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

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;
// CTF ->
	if ((self.weapon == IT_AXE) || (self.weapon == IT_HOOK))
// <- CTF
		return TRUE;
	
	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_light1;
void()	player_rocket1;
// CTF ->
void()	player_chain1;
void()  player_chain3;
// CTF <-

void() W_Attack =
{
	local	float	r, rt;

// < GeN 

    if (self.weaponallowed == FALSE)
	    return;
	if(self.rprotecttime > time)
		self.rprotecttime = 0;

// GeN >

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	rt = 0.2;
	if (self.weapon == IT_AXE)
	{
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			rt = 0.5;
		else if (!deathmatch & D_ORIGBAL) 
			rt = 0.35; // MEZ Originally 0.5
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			rt = 0.5;
		else if (!deathmatch & D_ORIGBAL) 
			rt = 0.4; // MEZ Originally 0.5
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			rt = 0.7;
		else if (!deathmatch & D_ORIGBAL) 
			rt = 0.6; //MEZ originally 0.7
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			rt = 0.2; // (uses defeault of 0.2)
		else if (!deathmatch & D_ORIGBAL) 
			rt = 0.15; //MEZ Orginally NO LINE here, not specified (uses defeault of 0.2)
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		if (deathmatch & D_ORIGBAL) //Mez Original Balance
			rt = 0.6;
		else if (!deathmatch & D_ORIGBAL) 
			rt = 0.5; //MEZ is this fire speed?  Originally 0.6
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		rt = 0.8;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		player_light1();
		rt = 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
	else if (self.weapon == IT_HOOK)
	{
		if (!self.hook_out)
			player_chain1();
		else
			player_chain3();
		rt = 0.3;
	}
// < GeN 
	if(deathmatch & D_FASTRELOAD)
	{
		rt = ceil(rt - (rt / 2));
		if ( rt < 0.1)
			rt = 0.1;
	}
// CTF ->
	if (self.player_flag & ITEM_RUNE3_FLAG)
	{
		rt = (rt - (rt / 2)); //rt = ceil(rt - (rt / 2));
		if (rt < 0.1)
			rt = 0.1;
		HasteSound();
	}
// CTF <-
	self.attack_finished = time + rt;
// GeN >
};

// CTF ->
void() NotifyWeapon =
{
	//if (self.weapon == IT_AXE)
	//	sprint(self, "Axe selected.\n"); // MEZ disabled axe/hook notification
	//else if (self.weapon == IT_HOOK)
	//	sprint(self, "Grappling hook selected.\n"); // MEZ disabled axe/hook notification
};
// CTF <-

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
// < GeN 

	if (self.weaponallowed == FALSE)
		return;

// GeN >

	it = self.items;
	am = 0;
	
	if (self.impulse == 1)
	{
// CTF ->							//MEZ Disable manual axe selection
		//if(temp1 & T_ALLOWHOOK)
		//{
		//	if (self.weapon == IT_AXE)
		//	{
		//		fl = IT_HOOK;
		//	}
		//	else
		//		fl = IT_AXE;
		//}
		//else
			fl = IT_AXE;
// CTF <-
	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}		
	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}
	else if (self.impulse == 20)	//MEZ
	{
		//bprint("check message hook\n"); 
		if((temp1 & T_ALLOWHOOK) || (self.hashead)) //Mez AvP Added
		{	
			sprint(self, "Grappling hook selected.\n");
			fl = IT_HOOK;	
		}
		else
			sprint(self, "Hook Disabled.\n");
	}

	self.impulse = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		if(!temp1 & T_NOMESSAGES)
			sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
		if(!temp1 & T_NOMESSAGES)
			sprint (self, "not enough ammo.\n");
		return;
	}

// CTF ->
//McBain: save current weapon
// For explicite weapon selection, allow previous weapon and new weapon to be
// same except for IT_HOOK.
	if (self.weapon != IT_HOOK || fl != IT_HOOK)
		self.previous_weapon = self.weapon;
// CTF <-

//
// set weapon, set ammo
//
	self.weapon = fl;
// CTF ->
	if(temp1 & T_ALLOWHOOK)
		NotifyWeapon();
// CTF <-
	W_SetCurrentAmmo ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (deathmatch)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 200;
	self.items = self.items | IT_LIGHTNING;

	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;
	
	if (self.weaponallowed == FALSE)
		return;

	it = self.items;
	self.impulse = 0;

// CTF ->
//McBain: save current weapon
	self.previous_weapon = self.weapon;
// CTF <-
	
	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
// < GeN
			//if(temp1 & T_ALLOWHOOK)		//MEZ Disable hook on cycle
			//	self.weapon = IT_HOOK;
			//else
			//{
// GeN >	//
				self.weapon = IT_SHOTGUN;
				if (self.ammo_shells < 1)
					am = 1;
// < GeN	//
			//}
// GeN >
		}
		else if (self.weapon == IT_HOOK) 
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
// CTF ->
			NotifyWeapon();
// CTF <-
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;

// CTF ->
//McBain: save current weapon
	self.previous_weapon = self.weapon;
// CTF <-

	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
// CTF ->
			//if(temp1 & T_ALLOWHOOK)	//MEZ Disable hook on cycling
			//	self.weapon = IT_HOOK;
			//else
// CTF <-
				self.weapon = IT_AXE;
		}
// CTF ->
		else if (self.weapon == IT_HOOK)
			self.weapon = IT_AXE;
// CTF <-
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
// CTF ->
			NotifyWeapon();
// CTF <-
			W_SetCurrentAmmo ();
			return;
		}
	}

};

// CTF ->
//McBain: Here's the beef...
/*
============
PreviousWeaponCommand
============
*/
void() PreviousWeaponCommand =
{
	local	float	fl, am;
	
	self.impulse = 0;
	am = 0;

	if (!(self.items & self.previous_weapon))
	{	// don't have the weapon or the ammo
		if(!temp1 & T_NOMESSAGES)
			sprint (self, "no weapon.\n");
		return;
	}
	
	fl = self.weapon;
	self.weapon = self.previous_weapon;
	self.previous_weapon = fl;

	// this might not be the best method, but I'll be able to play sooner
	if (self.weapon == IT_SHOTGUN || self.weapon == IT_SUPER_SHOTGUN) {
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.weapon == IT_NAILGUN || self.weapon == IT_SUPER_NAILGUN) {
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER || self.weapon == IT_ROCKET_LAUNCHER) {
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.weapon == IT_LIGHTNING) {
		if (self.ammo_cells < 1)
			am = 1;
	}
	// ignore AXE & HOOK -- no ammo needed

	if (am)
		self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
};
// CTF <-

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

//MEZ FLAG PLACE START

/*
void() PlaceFlag = 				//MEZ Flag Drop
{
        if(!self.flag1_marker)  
                self.flag1_location = spawn();    //create a temp entity for the flag location
        self.flag1_location.origin = self.origin;      //records the location
        self.flag1_location.mangle = self.angles;
        self.flag1_marker = 1;
        bprint("Flag 1 Location Selected");
};

*/
//MEZ FLAG PLACE END


/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if((teamplay && (self.state & S_CHOOSINGTEAM)) && (self.impulse >= 1 && self.impulse <= 7))
	{
		TeamMenuImpulse();		
		return;
	}

	if (self.impulse >= 1 && self.impulse <= 8)//MEZ (self.impulse == 20) ORIGINAL: if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon ();
	else if (self.impulse == 9)
		CheatCommand ();
// < GeN
	else if ((self.impulse == 10) && (self.mode == M_PLAYER))
// GeN >
		CycleWeaponCommand ();
	if ((self.impulse == 11) && (!deathmatch))
		ServerflagsCommand ();

// *************************************************************************
// **								          **
// ** M U L T I S K I N  1.1  (start)                                     **
// **									  **
// *************************************************************************
	
	if ((self.impulse == 96) || (self.impulse == 97))
	{
		if(teamplay)	//Mez added this is check to prevent changing skins in teamplay mode
		{
			bprint("No skin change during teamplay\n");
		}
		else
		{
			if (self.impulse == 96)
			{
			self.skin = self.skin + 1;
			if (self.skin == 32) self.skin = 0;
			} else
			if (self.impulse == 97)
			{
			self.skin = self.skin - 1;
			if (self.skin == -1) self.skin = 31;
			}
			if (self.skin == 0) centerprint(self, "SKIN: Quakeguy (1)", "", "", ""); else
			if (self.skin == 1) centerprint(self, "SKIN: Doomguy (2)", "", "", ""); else
			if (self.skin == 2) centerprint(self, "SKIN: Arnold the Terminator (3)", "", "", ""); else
			if (self.skin == 3) centerprint(self, "SKIN: Arnold the Conan (4)", "", "", ""); else
			if (self.skin == 4) centerprint(self, "SKIN: The Predator (5)", "", "", ""); else
			if (self.skin == 5) centerprint(self, "SKIN: The Punisher(6)", "", "", ""); else
			if (self.skin == 6) centerprint(self, "SKIN: The Highlander (7)", "", "", ""); else
			if (self.skin == 7) centerprint(self, "SKIN: Klingon (8)", "", "", ""); else
			if (self.skin == 8) centerprint(self, "SKIN: Robocop (9)", "", "", ""); else
			if (self.skin == 9) centerprint(self, "SKIN: T-800 (10)", "", "", ""); else
			if (self.skin == 10) centerprint(self,"SKIN: Vincent (11)", "", "", ""); else
			if (self.skin == 11) centerprint(self,"SKIN: Tigger (12)", "", "", ""); else
			if (self.skin == 12) centerprint(self,"SKIN: Lord Arioch (13)", "", "", ""); else
			if (self.skin == 13) centerprint(self,"SKIN: Hellboy (14)", "", "", ""); else
			if (self.skin == 14) centerprint(self,"SKIN: Skeleton (15)", "", "", ""); else
			if (self.skin == 15) centerprint(self,"SKIN: Skull Demon (16)", "", "", ""); else
			if (self.skin == 16) centerprint(self,"SKIN: Cowabunga Turtle! (17)", "", "", ""); else
			if (self.skin == 17) centerprint(self,"SKIN: Zombie Biker (18)", "", "", ""); else
			if (self.skin == 18) centerprint(self,"SKIN: Canadian Mountie (19)", "", "", ""); else
			if (self.skin == 19) centerprint(self,"SKIN: Bad Biker Chic (20)", "", "", ""); else
			if (self.skin == 20) centerprint(self,"SKIN: Gladiatress (21)", "", "", ""); else
			if (self.skin == 21) centerprint(self,"SKIN: Army Ranger (22)", "", "", ""); else
			if (self.skin == 22) centerprint(self,"SKIN: Smiley Face Guy(23)", "", "", ""); else
			if (self.skin == 23) centerprint(self,"SKIN: Taximan (24)", "", "", ""); else
			if (self.skin == 24) centerprint(self,"SKIN: Alien Astronaut (25)", "", "", ""); else
			if (self.skin == 25) centerprint(self,"SKIN: Swedish Mobster (26)", "", "", ""); else
			if (self.skin == 26) centerprint(self,"SKIN: Spawn (27)", "", "", ""); else
			if (self.skin == 27) centerprint(self,"SKIN: The Tick (28)", "", "", ""); else
			if (self.skin == 28) centerprint(self,"SKIN: Stormtrooper (29)", "", "", ""); else
			if (self.skin == 29) centerprint(self,"SKIN: Chewbacca (30)", "", "", ""); else
			if (self.skin == 30) centerprint(self,"SKIN: C-3PO (31)", "", "", ""); else
			if (self.skin == 31) centerprint(self,"SKIN: Boba Fett (32)", "", "", "");
		}
	}
	if (teamplay == 0)
	{
		if(self.impulse == 24)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 0;
			centerprint(self, "SKIN: Quakeguy (1)", "", "", "");
		}
		if(self.impulse == 25)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 1;
			centerprint(self, "SKIN: Doomguy (2)", "", "", "");
		}
		if(self.impulse == 26)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 2;
			centerprint(self, "SKIN: Arnold the Terminator (3)", "", "", "");
		}
		if(self.impulse == 27)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 3;
			centerprint(self, "SKIN: Arnold the Conan (4)", "", "", "");
		}
		if(self.impulse == 28)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 4;
			centerprint(self, "SKIN: The Predator (5)", "", "", "");
		}
		if(self.impulse == 29)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 5;
			centerprint(self, "SKIN: The Punisher(6)", "", "", "");
		}
		if(self.impulse == 30)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 6;
			centerprint(self, "SKIN: The Highlander (7)", "", "", "");
		}
		if(self.impulse == 31)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 7;
			centerprint(self, "SKIN: Klingon (8)", "", "", "");
		}
		if(self.impulse == 32)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 8;
			centerprint(self, "SKIN: Robocop (9)", "", "", "");
		}
		if(self.impulse == 33)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 9;
			centerprint(self, "SKIN: T-800 (10)", "", "", "");
		}
		if(self.impulse == 34)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 10;
			centerprint(self, "SKIN: Vincent (11)", "", "", "");
		}
		if(self.impulse == 35)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 11;
			centerprint(self, "SKIN: Tigger (12)", "", "", "");
		}
		if(self.impulse == 36)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 12;
			centerprint(self, "SKIN: Lord Arioch (13)", "", "", "");
		}
		if(self.impulse == 37)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 13;
			centerprint(self, "SKIN: Hellboy (14)", "", "", "");
		}
		if(self.impulse == 38)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 14;
			centerprint(self, "SKIN: Skeleton (15)", "", "", "");
		}
		if(self.impulse == 39)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 15;
			centerprint(self, "SKIN: Skull Demon (16)", "", "", "");
		}
		if(self.impulse == 40)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 16;
			centerprint(self, "SKIN: Cowabunga Turtle!(17)", "", "", "");
		}
		if(self.impulse == 41)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 17;
			centerprint(self, "SKIN: Zombie Biker (18)", "", "", "");
		}
		if(self.impulse == 42)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 18;
			centerprint(self, "SKIN: Canadian Mountie (19)", "", "", "");
		}
		if(self.impulse == 43)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 19;
			centerprint(self, "SKIN: Bad Biker Chic (20)", "", "", "");
		}
		if(self.impulse == 44)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 20;
			centerprint(self, "SKIN: Gladiatress (21)", "", "", "");
		}
		if(self.impulse == 45)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 21;
			centerprint(self, "SKIN: Army Ranger (22)", "", "", "");
		}
		if(self.impulse == 46)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 22;
			centerprint(self, "SKIN: Smiley Face Guy(23)", "", "", "");
		}
		if(self.impulse == 47)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 23;
			centerprint(self, "SKIN: Taximan (24)", "", "", "");
		}
		if(self.impulse == 48)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 24;
			centerprint(self, "SKIN: Alien Astronaut (25)", "", "", "");
		}
		if(self.impulse == 49)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 25;
			centerprint(self, "SKIN: Swedish Mobster (26)", "", "", "");
		}
		if(self.impulse == 50)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 26;
			centerprint(self, "SKIN: Spawn (27)", "", "", "");
		}
		if(self.impulse == 51)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 27;
			centerprint(self, "SKIN: The Tick (28)", "", "", "");
		}
		if(self.impulse == 52)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 28;
			centerprint(self, "SKIN: Stormtrooper (29)", "", "", "");
		}
		if(self.impulse == 53)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 29;
			centerprint(self, "SKIN: Chewbacca (30)", "", "", "");
		}
		if(self.impulse == 54)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 30;
			centerprint(self, "SKIN: C-3PO (31)", "", "", "");
		}
		if(self.impulse == 55)					//MEZ Added impulse commands for direct skin selection
		{
			self.skin = 31;
			centerprint(self, "SKIN: Boba Fett (32)", "", "", "");
		}
	}

// *************************************************************************
// **								          **
// ** M U L T I S K I N  1.1  (end)                                       **
// **									  **
// *************************************************************************

// < GeN
	if ((self.impulse == 12) && (self.mode == M_PLAYER))
// GeN >
		CycleWeaponReverseCommand ();

// CTF ->
//McBain: I picked 69 -- seems appropriate!  I hope 69 hasn't been used in
// other add-ons.  This is my first attempt at Quake C, and I hope I haven't
// violated any Quake C ettiquette.  :(
	if ((self.impulse == 69) && (self.mode == M_PLAYER))
		PreviousWeaponCommand ();

	if (self.impulse == 21)
		TeamFlagStatusReport();

	if (self.impulse == 22)
	{
		self.id = !self.id;
		if(self.id)
			sprint(self, "Player identification activated.\n");
		else
			sprint(self, "Player identification deactivated.\n");
	}


// CTF <-

	if (self.impulse == 255)
		QuadCheat ();

// < GeN
	if(!self.client)	//only for server
	{
		if((self.impulse > 149) && (self.impulse < 240))
		{
			ServerImpulses();
			return;
		}

		if(self.impulse == 115)	//maxteams2
			maxteams = 2;
		if(self.impulse == 116)	//maxteams3
			maxteams = 3;
		if(self.impulse == 117)	//maxteams4
			maxteams = 4;
		if(self.impulse == 118)	//maxteams5
			maxteams = 5;
		if(self.impulse == 119)	//maxteams6
			maxteams = 6;

		if(self.impulse == 110)	//force_start
			CheckStartGame(1);

		if(self.impulse == 114)	//force_break
		{
			if(gamestatus & G_STARTING)
			{
				StopCountdown();
			}
			else if(gamestatus & G_STARTED)
			{
				bprint("The server forced to break the match.\n");
				NextLevel();
			}
			gamestatus = gamestatus - (gamestatus & (G_STARTED | G_STARTING));
		}
	}

	if(self.impulse == 102)					//commands
		DisplayHelp();

	if(self.impulse == 106)
		DisplaySettings();					//settings

	if(self.impulse == 128)
		DisplayServerCommands();			//servercommands
	
	if(self.impulse == 129)					//motd
		DisplayMOTD();
		
//MEZ Start
	if(self.impulse == 95)				//drop rune command
	{
		if (self.runedelay == 0)
		{
		//self.runedelay = 1;
		//sprint(self, "rune drop delay = 1\n");
		
			if (self.player_flag & ITEM_RUNE1_FLAG)
			{
				DropRune();
				self.runedelay = 1;
				sprint(self, "You dropped the \bResistance\b rune\n");		
			}
			if (self.player_flag & ITEM_RUNE2_FLAG)
			{
				DropRune();
				self.runedelay = 1;
				sprint(self, "You dropped the \bStrength\b rune\n");		
			}
			if (self.player_flag & ITEM_RUNE3_FLAG)
			{
				DropRune();
				self.runedelay = 1;
				sprint(self, "You dropped the \bHaste\b rune\n");		
			}
			if (self.player_flag & ITEM_RUNE4_FLAG)
			{
				DropRune();
				self.runedelay = 1;
				sprint(self, "You dropped the \bRegeneration\b rune\n");		
			}
			//if (self.player_flag == 0)
			//{
			//	sprint(self, "No rune equipped! Go find one!\n");
			//}
		//self.nextthink = time + 2;
		//self.think(self.runedelay = 0);
		}
		//else if (self.runedelay == 1)
		//{
		//	self.runedelay = 0;
		//	sprint(self, "Time to pick up a rune...\n");
		//}
	}
	if(self.impulse == 94)				//Mez drop rune command
	{
		self.runedelay = 0;
	}
	if(self.impulse == 93)				//Mez rune check command
	{
		if (self.player_flag & ITEM_RUNE1_FLAG)
			sprint(self, "You have the \bResistance\b rune\n");		
		if (self.player_flag & ITEM_RUNE2_FLAG)
			sprint(self, "You have the \bStrength\b rune\n");		
		if (self.player_flag & ITEM_RUNE3_FLAG)
			sprint(self, "You have the \bHaste\b rune\n");		
		if (self.player_flag & ITEM_RUNE4_FLAG)
			sprint(self, "You have the \bRegeneration\b rune\n");		
	}
	if (self.impulse == 20) // MezOff-Hand Hook ImpulseCommands - Hook Fire at line 1035
	{
		//bprint("impulse20\n");
		W_ChangeWeapon ();
	}
		if(self.impulse == 91)  //Mez Off-Hand +Hook
	{
		if((temp1 & T_ALLOWHOOK) || (self.hashead)) //Mez AvP added hook for predator
		{
			self.offhandhook = 1;
			if (!self.hook_out)
				player_chain1();
			else
				player_chain3();
			//sprint(self, "Hook fire\n");
		}
		else
			sprint(self, "Hook disabled\n");
	}
	if(self.impulse == 92) //Mez Off-Hand -Hook
	{
		if((temp1 & T_ALLOWHOOK) || (self.hashead)) //Mez AvP added hook for predator
		{
			self.offhandhook = 0;
			//sprint(self, "Hook release\n");
		}
	}
	if ((self.impulse == 98) && (self.weapautoswitch == 0)) //Mez Autoweapon switch
	{
		self.weapautoswitch = 1;
		sprint(self, "Weapon Auto Switching ENABLED\n");
	}
	else if ((self.impulse == 98) && (self.weapautoswitch == 1))
	{
		self.weapautoswitch = 0;
		sprint(self, "Weapon Auto Switching DISABLED\n");
	}
//MEZ End

	if((self.impulse > 119) && (self.impulse < 127))
	{
		if(teamplay)
		{
			if(self.impulse == 120)			//changeteam
			{
				if(!teamplay & TEAM_NOCHANGE)
				{
					bprint(self.netname);
					bprint(" leaves the ");
					bprint(Team2String(self.genteam));
					bprint(" team.\n");
					self.team = self.genteam;
					self.genteam = 0;
					self.teamleader = FALSE;
					self.state = self.state - (self.state & S_TEAMCHOSEN);
					if(!self.state & S_CHOOSINGTEAM)
						self.state = self.state | S_CHOOSINGTEAM;
//					FindNewLeader(self.team);
					PlayerObserverMode();
				}
				else
					sprint(self, "This command was disabled by server.\n");
			}
			if(self.impulse == 121)		//teamscores
				TeamScores();

			if(self.impulse == 123)						//dropammo
				DropAmmo();

			if(self.impulse == 124)						//droparmor
				DropArmor();

			if(self.impulse == 125)						//drophealth
				DropHealth();

			if(self.impulse == 126)						//dropweapon
			{
				DropWeapon(0);
				self.items = self.items - (self.items & self.weapon);
				self.weapon = W_BestWeapon();
				W_SetCurrentAmmo();
			}
		}
		else
			sprint(self, "This command only works in teamplay.\n");
	}


	if((self.impulse == 107) && (gamestatus & G_STARTED))	//break
	{
		if(self.state & S_BREAK)
		{
			self.state = self.state - (self.state & S_BREAK);
			sprint(self,"You cancelled your application to end the match.\n");
			self.impulse = 0;
			return;
		}
		else
			self.state = self.state | S_BREAK;
		if(BreakGame())
		{
			bprint("The match ended because the majority of players voted for a cancellation.\n");
			NextLevel();
		}
		else
		{
			bprint(self.netname);
			bprint(" voted for a match-break.\n");
			sprint(self,"Not enough players have voted for a cancellation to end the match.\n");
		}
	}

	//MEZ START --- Removed the references to this function - just not working correctly.  Replicate new functions based on mimicing "break"  vote
	/* 
	if((self.impulse > 240) && (self.impulse < 246))
	{
		VoteLevelImpulses();
		return;
	}
	*/ 
	if((self.impulse == 241) && (gamestatus & G_STARTED))	//MezVOTE: Free For All Mode
	{
		bprint("impulse 241 activated\n");
		if(self.state & S_VOTEREINC1)
		{
			self.state = self.state - (self.state & S_VOTEREINC1);
			sprint(self,"You cancelled your request to change to \bFree-For-All\b mode.\n");
			self.impulse = 0;
			return;
		}
		else
			self.state = self.state | S_VOTEREINC1;
		if(ChangeModeFFA())
		{
			bprint("Most players wanted to change to \bFree-For-All\b mode.\n");
			localcmd("exec aservffa.cfg\n"); //also triggers amaps50.cfg
			NextLevel();
		}
		else
		{
			bprint(self.netname);
			bprint(" voted for \bFree-For-All\b mode. Enter 'voteffa' to support.\n");
			//sprint(self,"Not enough players have 'yet' voted for \bFree-For-All\b mode.\n");
		}
	}
	if((self.impulse == 242) && (gamestatus & G_STARTED))	//MezVOTE: Teamplay Mode
	{
		if(self.state & S_VOTEREINC2)
		{
			self.state = self.state - (self.state & S_VOTEREINC2);
			sprint(self,"You cancelled your request to change to \bTeamplay\b mode.\n");
			self.impulse = 0;
			return;
		}
		else
			self.state = self.state | S_VOTEREINC2;
		if(ChangeModeTeam())
		{
			bprint("Most players wanted to change to \bTeamplay\b mode.\n");
			localcmd("exec aservteam.cfg\n"); //also triggers amapsteam.cfg
			NextLevel();
		}
		else
		{
			bprint(self.netname);
			bprint(" called a voted for \bTeamplay\b mode. Enter 'voteteam' to support.\n");
			//sprint(self,"Not enough players have 'yet' voted for \bTeamplay\b mode.\n");
		}
	}	
	if((self.impulse == 243) && (gamestatus & G_STARTED))	//MezVOTE: Predator Mode
	{
		if(self.state & S_VOTEREINC3)
		{
			self.state = self.state - (self.state & S_VOTEREINC3);
			sprint(self,"You cancelled your request to change to \bPredator\b mode.\n");
			self.impulse = 0;
			return;
		}
		else
			self.state = self.state | S_VOTEREINC3;
		if(ChangeModePred())
		{
			bprint("Most players wanted to change to \bPredator\b mode.\n");
			localcmd("exec aservpred.cfg\n"); //also triggers amapsteam.cfg
			NextLevel();
		}
		else
		{
			bprint(self.netname);
			bprint(" voted for \bPredator\b mode. Enter 'votepred' to support.\n");
			//sprint(self,"Not enough players have 'yet' voted for \bPredator\b mode.\n");
		}
	}		
	if((self.impulse == 244) && (gamestatus & G_STARTED))	//MezVOTE: Duel Mode
	{
		if(self.state & S_VOTEREINC4)
		{
			self.state = self.state - (self.state & S_VOTEREINC4);
			sprint(self,"You cancelled your request to change to \bDuel\b mode.\n");
			self.impulse = 0;
			return;
		}
		else
			self.state = self.state | S_VOTEREINC4;
		if(ChangeModeDuel())
		{
			bprint("Most players wanted to change to \bDuel\b mode.\n");
			localcmd("exec aservduel.cfg\n"); //also triggers amapsduel.cfg
			NextLevel();
		}
		else
		{
			bprint(self.netname);
			bprint(" voted for \bDuel\b mode. Enter 'voteduel' to support.\n");
			//sprint(self,"Not enough players have 'yet' voted for \bDuel\b mode.\n");
		}
	}	
	if((self.impulse == 246) && (gamestatus & G_STARTED))	//MezVOTE: CTF Mode
	{
		if(self.state & S_VOTEREINC5)
		{
			self.state = self.state - (self.state & S_VOTEREINC5);
			sprint(self,"You cancelled your request to change to \bCTF\b mode.\n");
			self.impulse = 0;
			return;
		}
		else
			self.state = self.state | S_VOTEREINC5;
		if(ChangeModeCTF())
		{
			bprint("Most players wanted to change to \bCTF\b mode.\n");
			localcmd("exec aservctf.cfg\n"); //also triggers amapsctf.cfg
			NextLevel();
		}
		else
		{
			bprint(self.netname);
			bprint(" voted for \bCTF\b mode. Enter 'votctf' to support.\n");
			//sprint(self,"Not enough players have 'yet' voted for \bDuel\b mode.\n");
		}
	}
	if((self.impulse == 247) && (gamestatus & G_STARTED) && (teamplay & TEAM_CTF))	//MezVOTE: Lock Flag Placement for CTF
	{
		local entity flagcheck1;
		local entity flagcheck2;
		
		// find if flag exists;
		flagcheck1 = find (world, classname, "item_flag_team1");
		flagcheck2 = find (world, classname, "item_flag_team2");
		
		if ((flagcheck1) && (flagcheck2))
		{
			if(self.state & S_VOTEREINC6)
			{
				self.state = self.state - (self.state & S_VOTEREINC6);
				sprint(self,"You cancelled your request to \bLock Flag Placement\b.\n");
				self.impulse = 0;
				return;
			}
			else
				self.state = self.state | S_VOTEREINC6;
			if(LockFlagVote())
			{
				bprint("Most players wanted to \bLock Flag Placement\b.\n");
				flagcheck1.lockflag = 1;
				flagcheck2.lockflag = 1;
				bcenterprint("\bBoth flags are placed and locked!\b\nLet the Game Begin!","","","","");
				//execute setting the flag changes here on a successful vote
			}
			else
			{
				bprint(self.netname);
				bprint(" voted for \bLocking Flag Placement\b. Enter 'lockflags' to support.\n");
				//sprint(self,"Not enough players have 'yet' voted for \bDuel\b mode.\n");
			}
		}
		else
			bprint("Can't vote to lock flag placement. Not all flags placed!\n");	
	}	
	//MEZ ctf flag placement
	if((self.impulse == 99)	&& (teamplay & TEAM_CTF))
	{
		local entity f1;
		local entity f2;
		
		// find if flag exists;
		f1 = find (world, classname, "item_flag_team1");
		f2 = find (world, classname, "item_flag_team2");
		
		if ((f1.lockflag) && (f2.lockflag))
		{
			bprint("Flag Placement \bLOCKED\b! No Moving Flag Locations!\n");
			self.impulse = 0;
			return; // both flags exist
		}

		if (self.genteam == TRED)
		{
			if (f1)
				remove (f1);			
			f1 = spawn();
			f1.origin = self.origin;
			f1.classname = "item_flag_team1";
			//bprint("Placing the Red Team (gold) Flag\n");
			bcenterprint("The Red Team (gold) Flag is Placed!","","","","");
			f1.think = item_flag_team1_place;
			f1.nextthink = time + 0.5;
		}
		if (self.genteam == TBLUE)
		{
			if (f2)
				remove (f2);	
			f2 = spawn();
			f2.origin = self.origin;
			f2.classname = "item_flag_team2";
			//bprint("Placing the Blue Team (silver) Flag\n");
			bcenterprint("The Blue Team (silver) Flag is Placed!","","","","");
			f2.think = item_flag_team2_place;
			f2.nextthink = time + 0.5;
		}
	}
	
	
	
	//MEZ END

	if(self.impulse == 111)  //playerstats
		PlayerStats();

	if((self.impulse == 112) && (self.mode == M_PLAYER))		//torch
	{
		if(deathmatch & D_DARKDM)
		{
			if(self.state & S_TORCHON)
			{
				self.state = self.state - (self.state & S_TORCHON);
				if(!temp1 & T_NOMESSAGES)
					sprint(self, "Torch is off.\n");
			}
			else
			{
				self.state = self.state | S_TORCHON;
				if(!temp1 & T_NOMESSAGES)
					sprint(self, "Torch is on.\n");
			}
		}
		else
			sprint(self, "This command only works in Dark Deathmatch mode.\n");
	}

	if((self.impulse == 113) && (self.mode == M_PLAYER))		//flare
	{
		if(deathmatch & D_DARKDM)
			W_FireFlare();
		else
			sprint(self, "This command only works in Dark Deathmatch mode.\n");
	}

	if(self.impulse == 127)
	{
		MOTD = ftos(VERSION);

		sprint(self, "\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\nžÒÅÉÎÃÁÒÎÁÔÉÏÎžŸ v");
		sprint(self, MOTD);
		sprint(self, "\nQuakeC by:\nSebastian \"ÇåÎ\" Bentler\n\nLevels by:\nSebastian \"ÇåÎ\" Bentler\nChristoph \"Çïîúï\" Werner\nMagnus \"÷òÁôè\" Andersson\n\nHomepage:\nhttp://www.telefragged.com/genclasses/\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\n");
	}

	else if(self.impulse == 130)
	{
		if(self.state & S_ORGINFO)
		{
			self.state = self.state - S_ORGINFO;
			sprint(self,"Origin and viewangles info off.\n");
		}
		else
		{
			self.state = self.state + S_ORGINFO;
			sprint(self,"Origin and viewangles info on.\n");
		}
	}

	if(self.mode == M_OBSERVER)
		ObserverImpulses();
	else
	{
		if(self.impulse == 104)
		{
			if(temp1 & T_ALLOWOBSERVER)
			{
				self.genteam = 0;
				PlayerObserverMode();
			}
			else
				sprint(self, "The server has disabled observer mode.\n");
		}
	}

// KasCam ->
    if (self.impulse == 250)
        CamClientInit();
// <- KasCam

// GeN >

	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

// < GeN 

	if (self.mode == M_OBSERVER)
	{
		if (((self.button0) || (self.button1) || (self.button2)) && (!self.infotime > time))
		{
			if((!gamestatus & G_STARTED) && (!temp1 & T_SERVERCLOSED))
				ccenterprint(self, "Type ÒÅÁÄÙ to play or ÏÂÓÅÒÖÅÒ\nto observe when the game starts.\n");
			else if((temp1 & T_SERVERCLOSED) && (self.client))
				ccenterprint(self, "The server is closed,\nyou have to stay in observer mode.\n");
			else if(((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2)) && (gamestatus & G_STARTED) && self.genteam)
				ccenterprint(self, "You will join automatically\nwhen one team is defeated.");
			else
				ccenterprint(self, "Type ÒÅÁÄÙ to join the match.\n");
		}
	}
	if (self.impulse)
// GeN >
		ImpulseCommands ();
// check for attack
	if ((self.button0) && (self.weaponallowed))
	{
		SuperDamageSound ();
		W_Attack ();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
// CTF ->
// RUNE play super damage sound if player has Black Magic, too

	if ((self.super_damage_finished > time) || (self.state & S_BERSERK))
	{
		if (self.super_sound < time) 
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}

	if (self.player_flag & ITEM_RUNE2_FLAG) 
	{
		if (self.super_sound < time) 
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
// CTF <-
};

// CTF ->
/*
========
Resistancesound

Plays sound if needed
========
*/
void(entity who) ResistanceSound =
{
// RUNE play resistance sound if player has Earth Magic
	if (who.player_flag & ITEM_RUNE1_FLAG) {
		if (who.invincible_sound < time) {
			who.invincible_sound = time + 1;
			sound(who, CHAN_BODY, "items/protect3.wav", 1, ATTN_NORM);
		}
	}
};

/*
========
RegenerationSound

Plays sound if needed
========
*/
void() RegenerationSound =
{
// RUNE play healing sound if player has Elder Magic
	if (self.player_flag & ITEM_RUNE4_FLAG) {
		if (self.regeneration_sound < time) {
			self.regeneration_sound = time + 1;
			sound(self, CHAN_BODY, "items/r_item1.wav", 1, ATTN_NORM);
		}
	}
};

/*
========
HasteSound

Plays sound if needed
========
*/
void() HasteSound =
{
// RUNE play haste (Chthon's roar) sound if player has Hell Magic
	if (self.player_flag & ITEM_RUNE3_FLAG) {
		if (self.haste_sound < time) {
			self.haste_sound = time + 1;
			sound(self, CHAN_BODY, "boss1/sight1.wav", 1, ATTN_NORM);
		}
	}
};

// CTF <-
