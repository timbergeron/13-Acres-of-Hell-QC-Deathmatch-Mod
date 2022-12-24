float(entity targ, float t) MyInfront =
{
	local vector	vec;
	local float		dot;
	
	makevectors (self.v_angle);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;
	
	if ( dot > t)
		return TRUE;
	return FALSE;
};

entity() PlayerInView =
{
local entity e, player;

	local float bestdist = -999;
	local vector playerdir, selfdir;
	local float curdist;

	e = find(world, classname, "player");
	while (e != world)
	{
		playerdir = e.origin - self.origin;
		playerdir = normalize(playerdir);
		selfdir = normalize(self.angles);
		playerdir = playerdir - selfdir;
		curdist = vlen(playerdir);
		traceline(self.origin + '0 0 22', e.origin, FALSE, self);
		if(trace_ent != e)
			traceline(self.origin + '0 0 22', e.origin + e.maxs, FALSE, self);
		if(trace_ent != e)
			traceline(self.origin + '0 0 22', e.origin + e.mins, FALSE, self);
		if ((trace_ent == e) && (MyInfront(e, 0.9)))
		{
			if (bestdist == -999)
			{
				bestdist = curdist;
				player = e;
			}
			else if (curdist < bestdist)
			{
				bestdist = curdist;
				player = e;
			}
		}
		e = find(e, classname, "player");
	}
	return player;
};

