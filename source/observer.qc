//-----------------------------------------------------------------------------------
//
// Observer Mode
//
//-----------------------------------------------------------------------------------

void() PlayerObserverMode =
{
	local entity thinker, spot;

	spot = GeNSelectSpawnPoint();

	self.impulse = 0;
	self.mode = M_OBSERVER;
	if((teamplay) && (!self.state & S_TEAMCHOSEN))
		self.state = S_CHOOSINGTEAM;	//handled in postthink
	self.classname = "player";

	self.flags = FL_CLIENT | FL_NOTARGET | FL_ONGROUND;
	self.waterlevel = 3;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY;
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.items = 0;
	self.health = 666;
	self.ammo_rockets = 0;
	self.ammo_nails = 0;
	self.ammo_shells = 0;
	self.ammo_cells = 0;

	self.armortype = 0;
	self.armorvalue = 0;
	self.weaponallowed = FALSE;

	self.weapon = FALSE;
	self.model = string_null;
	self.mdl = string_null;
	self.modelindex = 0;
	self.weaponmodel = string_null;

	self.super_time = 0;
	self.super_damage_finished = 0;
	self.invisible_time = 0;
	self.invisible_finished = 0;
	self.invincible_time = 0;
	self.invincible_finished = 0;
	self.rad_time = 0;
	self.radsuit_finished = 0;
	self.effects = 0;
	self.currentammo = 0;
	self.ringtime = 0;
	self.quadtime = 0;

	stuffcmd(self, "cl_rollangle 0\n");

	thinker = spawn();
	thinker.owner = self;
	thinker.think = ObserverThink;
	thinker.nextthink = time + 0.5;

	self.attack_finished = time;
	self.th_pain = SUB_Null;
	self.th_die = SUB_Null;

	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;

	if(!self.state & S_CHANGEDTEAM)
		self.state = self.state | S_CHANGEDTEAM;
	self.origin = spot.origin + '0 0 8';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

	self.view_ofs = '0 0 22';
	stuffcmd(self,"v_cshift 0 0 0 255\n");
	stuffcmd(self,"v_cshift 0 0 0 0\n");
	stuffcmd(self, "cl_rollangle 2\n");
//	stuffcmd(self, "color 0\n");
	self.velocity = '0 0 0';
	RemoveNotUsedTeamplayScorepositions();
	if(deathmatch & D_DARKDM)
		self.effects = EF_BRIGHTLIGHT;
};

//GeN: ObserverDoor function from CTF
void(entity player,entity door) ObserverDoor =
{
  local entity d,d_master;
  local vector dmin,dmax;
    local float is_x,is_y,is_z,set;
    local vector dir,or;
  
  d_master = d = door.owner;
  if (d_master) {
    dmin = d_master.absmin;
    dmax = d_master.absmax;
  } else { 
    dmin = dmax = '0 0 0'; 
  }
  if (dmin != dmax) {
    // regular doors
    if (d_master.state != STATE_BOTTOM) return;
    do {
      // dprint (vtos(d.absmin)); dprint (" "); dprint (vtos(d.absmax)); dprint ("\n");
      if (d.absmin_x < dmin_x) { dmin_x = d.absmin_x; }
      if (d.absmax_x > dmax_x) { dmax_x = d.absmax_x; }
      if (d.absmin_y < dmin_y) { dmin_y = d.absmin_y; }
      if (d.absmax_y > dmax_y) { dmax_y = d.absmax_y; }
      if (d.absmin_z < dmin_z) { dmin_z = d.absmin_z; }
      if (d.absmax_z > dmax_z) { dmax_z = d.absmax_z; }
      d = d.enemy; // next linked door;
    } while ((d != d_master) && (d != world));
  }
  else {
    // secret doors
    // we ignore these currently
    return;
  }
  
    set = is_x = is_y = is_z = FALSE;
    or = player.origin;
    if (dmin_x + 15 < player.absmin_x && player.absmax_x < dmax_x - 15) is_x = TRUE;
    if (dmin_y + 15 < player.absmin_y && player.absmax_y < dmax_y - 15) is_y = TRUE;
    if (dmin_z + 15 < player.absmin_z && player.absmax_z < dmax_z - 15) is_z = TRUE;
    // dprint("doors:  "); dprint (vtos(dmin)); dprint (" "); dprint (vtos(dmax)); dprint ("\n");
    // dprint("player: "); dprint (vtos(player.absmin)); dprint (" "); dprint (vtos(player.absmax)); dprint ("\n");
    if (is_x && is_y) {
      // dprint("door is in xy plane\n");
      if      (or_z < dmin_z) { dir = '0 0  1'; or_z = dmax_z + 25; }
      else if (or_z > dmax_z) { dir = '0 0 -1'; or_z = dmin_z - 25; }
      set = TRUE;
    }
    else if (is_x && is_z) {
      // dprint("door is in xz plane\n");
      if      (or_y < dmin_y) { dir = '0  1 0'; or_y = dmax_y + 25; }
      else if (or_y > dmax_y) { dir = '0 -1 0'; or_y = dmin_y - 25; }
      set = TRUE;
    }
    else if (is_y && is_z) {
      // dprint("door is in yz plane\n");
      if      (or_x < dmin_x) { dir = ' 1 0 0'; or_x = dmax_x + 25; }
      else if (or_x > dmax_x) { dir = '-1 0 0'; or_x = dmin_x - 25; }
      set = TRUE;
    }
      if (set) { 
		local vector v;
		v =  normalize(player.velocity);
		if (dir * v < 0.5) return;
		player.origin = or;
		setorigin (player, player.origin);
      }
};

void(entity totele, entity teleporter) ObserverTeleport =
{
local entity	t;
local vector	org;

	if (teleporter.targetname)
	{
		if (teleporter.nextthink < time)
		{
			return;		// not fired yet
		}
	}

// only teleport living creatures
	if (totele.health <= 0)
		return;

// put a tfog where the player was

	t = find (world, targetname, teleporter.target);
	if (!t)
		objerror ("couldn't find target");
		
// spawn a tfog flash in front of the destination
	makevectors (t.mangle);
	org = t.origin + 32 * v_forward;

// move the player and lock him down for a little while
	if (!totele.health)
	{
		totele.origin = t.origin;
		totele.velocity = (v_forward * totele.velocity_x) + (v_forward * totele.velocity_y);
		return;
	}

	setorigin (totele, t.origin);
	totele.angles = t.mangle;
    if (totele.classname == "player")
	{
		totele.fixangle = 1;		// turn this way immediately
		totele.teleport_time = time + 0.7;
		if (totele.flags & FL_ONGROUND)
			totele.flags = totele.flags - FL_ONGROUND;
		totele.velocity = v_forward * 300;
	}
	totele.flags = totele.flags - totele.flags & FL_ONGROUND;
	totele.timer = time + 0.8;
};

void() ObserverThink =
{
	local entity e;
	local vector org, org1;
	local float counter, pc;

	
	if(self.owner.mode != M_OBSERVER)
	{
		remove(self);
		return;
	}

  { 
    local float invcos,nv,nvp,nvpmax,nvs,nsp,sp,svz;
    local vector f,vp,vs;
    
    svz = self.velocity_z * 0.75;
    self.velocity_z = 0;
    
    // v_forward is already normalized
    f_x = v_forward_x; 
    f_y = v_forward_y; 
    f_z = 0;
    invcos = vlen(f); if (invcos) invcos= 1/invcos; else invcos=0;
    f = f*invcos; // normalize f
    
    sp = f * self.velocity;
    vp = sp*f;
    nvp = vlen(vp); if (sp<0) nvp = nvp*(-1);
    vs = self.velocity - vp;
    
    vp = v_forward * (nvp * invcos);
    vp_z = vp_z + svz;
    nvp = vlen(vp);
    nvpmax = (320 - 100*(v_forward * '0 0 1'));
    if (nvp > nvpmax) { vp = vp * (nvpmax/nvp); }
    
    self.velocity = vp + vs;
  }

	e = findradius(self.owner.origin, 60);
	while(e)
	{
		if(e.classname == "trigger_teleport")
			ObserverTeleport(self.owner, e);
		if (e.classname == "door") 
			ObserverDoor(self.owner, e);
		e = e.chain;
	}
	self.nextthink = time + 0.2;
};
