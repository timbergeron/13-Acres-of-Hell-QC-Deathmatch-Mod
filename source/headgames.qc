//---------------------------------------------------------------------
// Get the head sub game
//---------------------------------------------------------------------

void(entity tochange) Changepos =
{
        local entity spot, stemp;

	spot = GeNSelectSpawnPoint();
	setorigin(tochange, spot.origin);

	stemp = self;
	self = tochange;
	droptofloor ();
	self = stemp;
};

void(entity destent, float radius, vector offset) Float =
{
	local vector dir;
	local float dist;

	if((self.movetype != MOVETYPE_FLY) || (self.solid != SOLID_NOT))
	{
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_FLY;
		setsize(self, '0 0 0', '0 0 0');
		setorigin(self, destent.origin + offset);
		self.avelocity = '50 50 50';

		self.flags = 0;
	}

	if (self.floatpos > 3)
		self.floatpos = 0;
	else if (self.floatpos < 0)
		self.floatpos = 0;
	
	traceline (self.origin, destent.origin + offset, TRUE, world);
	if ( trace_fraction < 1 )
	{
		setorigin (self, destent.origin + offset);
	       self.floatpos = self.floatpos + 1;
		return;
	}
	
	if ( self.floatpos == 0)
	{
		dir = (destent.origin + offset) - self.origin;
		dir_x = dir_x + radius;
	}
	else if ( self.floatpos == 1)
	{
		dir = (destent.origin + offset) - self.origin;
	    	dir_y = dir_y + radius;
	}
	else if ( self.floatpos == 2)
	{
		dir = (destent.origin + offset) - self.origin;
		dir_x = dir_x - radius;
	}
	else
	{
		dir = (destent.origin + offset) - self.origin;
	     	dir_y = dir_y - radius;
	}

	dist = vlen(dir);

	if( dist < 8 )
	{
      		self.floatpos = self.floatpos + 1;
	}
	else
	{
		self.velocity = normalize(dir);
		self.velocity = self.velocity * (dist*4);
	}
};

void() headBecomeItem;

void() Spawnhead =
{
	local entity head, spot;
	
	spot = SelectSpawnPoint();
	head = spawn();
	head.skin = 1;
	head.classname = "head";
	setsize(head, '-20 -20 -20', '10 10 10'); //Mez Avp size adjusted originally: setsize(head, '-10 -10 -10', '10 10 10');
	setorigin(head, spot.origin + '0 0 1');
	setmodel(head, "progs/h_shams.mdl"); //Mez Avp new model: w_s_key.mdl
	//setmodel(head, "progs/invulner.mdl"); //Mez AvP
	head.nextthink = time;
	head.think = headBecomeItem;
	//head.effects = EF_DIMLIGHT;  //Mez Avp no glowing head
	bcenterprint("The head has appeared.","","","","shambler/ssight.wav");
};

void() headthink;

void() headTouch =
{
	if((other.classname != "player") || (!other.flags & FL_CLIENT))
		return;
	self.owner = other;
	other.hashead = TRUE;

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY;
	setsize(self, '0 0 0', '0 0 0'); //Mez Avp was 0 0 0 
	setorigin(self, other.origin + '0 0 48');
	self.avelocity = '50 50 50';
	self.flags = 0;

	self.think = headthink;
	self.nextthink = time + 0.1;
	
	other.items = other.items | IT_HOOK; //Mez AvP Give Pred Hook
	other.skin = 4; //Mez AvP set skin to predator
	
	bcenterprint(other.netname, "\n\bclaims the head!\b", "", "", "shambler/smack.wav"); //MEZ off
	//bcenterprint("The head has been found!", "", "", "", "shambler/smack.wav"); //MEZ remake
};

void(entity tochange) Changepos;

void() SUB_Changepos =
{
	bcenterprint("The head has changed its position.","","","","shambler/melee2.wav");
	Changepos(self);
	self.nextthink = time + 15; //Mez AvP was 15 seconds
};

void() headCheckPos =
{
	local float pc;
	pc = pointcontents(self.origin);
	if((pc == CONTENT_LAVA) || (pc == CONTENT_SLIME) || (pc == CONTENT_SKY))
	{
		Changepos(self);
		bcenterprint("The head has changed its position.","","","","shambler/melee2.wav");
	}
	self.nextthink = time + 10;
	self.think = SUB_Changepos;
};

void() headBecomeItem =
{
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	setsize(self, '-20 -20 -20', '10 10 10');	//Mez original: setsize(self, '-10 -10 -10', '10 10 10');

	self.touch = headTouch;

	self.nextthink = time + 1;
	self.think = headCheckPos;

	self.effects = EF_DIMLIGHT;  //Mez glow on ground
	self.flags = FL_ITEM;

	droptofloor();
};

void() headthink =
{
	local entity p;

	if((self.owner != world) && ((self.owner.takedamage != DAMAGE_AIM) || (self.owner.health < 1) || (self.owner.mode != M_PLAYER)))
	{
		bcenterprint(self.owner.netname, "\n\bhas fumbled the head\b", "", "", "shambler/sdeath.wav");	//MEZ off
		//bcenterprint("The head is loose!", "", "", "", "shambler/sdeath.wav"); //MEZ remake
		self.owner.hashead = FALSE;
		self.owner = world;
		self.skin = 3; //Mez AvP set skin to non-head
		headBecomeItem();
	}
	if((!self.owner.hashead) && (self.owner != world))
		self.owner = world;
		self.effects = 0;  //Mez no glow on char
		
	if(self.owner.classname != "player")
	{
		self.owner = world;
		self.effects = EF_DIMLIGHT;  //Mez glow on ground

		p = find(world, classname, "player");
		while((p != world) && (self.owner == world))
		{
			if((p.hashead) && (p.flags & FL_CLIENT))
			{
				self.owner = p;
				setorigin(self, p.origin);
			}
			p = find(p, classname, "player");
		}
	}
	if(self.owner == world)	//no valid player found
	{
		headBecomeItem();
		return;
	}
	
	/*if((self.count < time) && (self.owner.flags & FL_CLIENT)) //Mez Avp I'll eventually need to disable this?
	{
		self.count = time + 5;
		self.owner.frags = self.owner.frags + 1;
		if(teamplay)
			ApplyTeamFrags(self.owner);
	}
	*/
	Float(self.owner, 20, '0 0 48');
	self.nextthink = time + 0.1;
};

void() ShamblerheadThink =
{
	local entity p, nearest, best;
	local float rangeto_p, rangeto_n;
	local string rt, rt2;

	best = world;
	self.nextthink = time + 0.1;

	if(self.ltime < time)
	{
		self.ltime = time + 90+(random()*90);
		Changepos(self);
		bcenterprint("The Shamblerhead changed its position.\n", "", "", "", "shambler/melee2.wav");
	}
	if(self.count < time)
	{
		self.count = time + 5;
		nearest = world;
		p = find(world, classname, "player");
		while(p)
		{
			rangeto_p = vlen(p.origin - self.origin);
			rangeto_n = vlen(nearest.origin - self.origin);
			if((nearest == world) || (rangeto_p < rangeto_n))
				nearest = p;
			p = find(p, classname, "player");
		}
		if(nearest.flags & FL_CLIENT)
		{
			if(!nearest.headmessage)
			{
				ccenterprint(nearest, "Stay near to the Shamblerhead to\ngain frags");
				nearest.headmessage = TRUE;
			}
			nearest.frags = nearest.frags + 1;
			if(teamplay)
				ApplyTeamFrags(nearest);
		}
	}
};

void() SpawnShamblerhead =
{
        local entity head, spot, check;

	check = find(world, classname, "shamblerhead");
	if(check)
	{
		bprint("ERROR: Tried to spawn second Shamblerhead.\n");
            	self.nextthink = time + 150;
		return;
	}
	spot = GeNSelectSpawnPoint();

	head = spawn();
	head.effects = EF_DIMLIGHT;
	head.solid = SOLID_TRIGGER;
	head.movetype = MOVETYPE_NOCLIP;

	setsize (head, '-16 -16 -48', '16 16 32');
	setmodel(head, "progs/h_shams.mdl");
	setorigin(head, spot.origin);

	head.classname = "shamblerhead";
	head.avelocity_y = 50;
	head.ltime = time + 90+(random()*90);
	head.count = 0;
	head.nextthink = time + 1;
	head.think = ShamblerheadThink;
	bcenterprint("The Shamblerhead appeared.\n", "", "", "", "shambler/ssight.wav");
	
	remove(self);
};

void() SpawnHeads =
{
local entity head;

	if(deathmatch & D_GETHEAD)
	{
		head = find(world, classname, "head");
		if(!head)
			Spawnhead();
	}
	if(deathmatch & D_SHAMBLERHEAD)
	{
		head = find(world, classname, "shamblerhead");
		if(!head)
			SpawnShamblerhead();
	}
};

