
/************\
* BreakChain *
\************/

void (entity Head) BreakChain =
{
        local entity link;

        link = Head.goalentity;
        while (link != world)
        {
                Head = link.goalentity;
                remove (link);
                link = Head;
        }
};

/*********\
* LinkPos *
\*********/

void () LinkPos =
{
        makevectors (self.enemy.angles);
        setorigin (self, self.owner.origin + ( ( ( self.enemy.origin + 
                (v_up * 16 * (!self.enemy.button2)) + (v_forward * 16) ) - self.owner.origin ) *
                ( self.weapon ) ) );
        self.nextthink = time + 0.1;
};

/***********\
* MakeChain *
\***********/

entity (entity head, entity tail, float num) MakeChain =
{  
        local entity link, prevlink;
        local float linknum;

        linknum = num;
        num = num + 1;
        prevlink = world;
        while (linknum > 0)
        {
                link = spawn();

                link.goalentity = prevlink;
                prevlink = link;

                link.owner = head;
                link.enemy = tail;
                link.weapon = linknum / num;
                link.movetype = MOVETYPE_NOCLIP;
                link.solid = SOLID_NOT;
                link.angles_z = 51 * linknum;
                link.angles_y = 41 * linknum;
                link.angles_x = 31 * linknum;
                link.avelocity = '310 410 510';
		setmodel (link, "progs/s_spike.mdl");
                setsize (link, '0 0 0', '0 0 0');
                makevectors (tail.angles);
                setorigin (link, head.origin + ( ( ( tail.origin 
                        + (v_up * 16 * (!tail.button2)) + ( v_forward * 16 ) ) - head.origin )
                        * ( link.weapon ) ) );
                link.nextthink = time + 0.1;
                link.think = LinkPos;
                linknum = linknum - 1;
        }
		//sprint(self, "got to MakeChain End \n"); //MEZ line notice WORKS TO HERE
		return link;
};


/************\
* HookVanish *
\************/

void () HookVanish =
{
        self.owner.hook_out = FALSE;
        BreakChain (self);
        remove (self);
};

void() UnHookPlayer =
{
	local entity oself;

	if (self.hook_out) {
		oself = self;
		self = self.goalentity;
		HookVanish();
		self = oself;
	}
};

/**********\
* HookPull *
\**********/

void () HookPull =
{
        local vector vel, spray;
        local float v, dorg;
	
	if ((!self.owner.button0 && !self.owner.offhandhook) ||  // MEZ original: if ((!self.owner.button0 && (self.owner.weapon == IT_HOOK)) || 
		(self.owner.teleport_time > time ) || self.owner.deadflag ) {
		HookVanish();
		return;
	} else {
		if (self.enemy.takedamage) {
			// don't hurt teammates
			if (self.enemy.classname != "player" || !teamplay ||
				self.enemy.lastteam != self.owner.lastteam) {

				// 4.1, if we can't see our enemy, unlock
				if (!CanDamage(self.enemy, self.owner)) {
					HookVanish();
					return;
				}

				sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);
				
				T_Damage (self.enemy, self, self.owner, 1, 0);
				makevectors (self.v_angle);
				spray_x = 100 * crandom();
				spray_y = 100 * crandom();
				spray_z = 100 * crandom() + 50;
				SpawnBlood (self.origin, spray, 20);
			}
			if (self.enemy.solid == SOLID_SLIDEBOX) {
					self.velocity = '0 0 0';
					setorigin (self, self.enemy.origin +
							self.enemy.mins +
							(self.enemy.size * 0.5));
			} else {
					self.velocity = self.enemy.velocity;
			}
		} else {
				self.velocity = self.enemy.velocity;
		}
		if (self.enemy.solid == SOLID_NOT) {
				HookVanish();
				return;
		}
		makevectors (self.owner.angles);
		vel = self.origin - ( self.owner.origin + (v_up * 16 *
				(!self.owner.button2)) + (v_forward * 16));
		v = vlen (vel);
		if (v <= 100)
				vel = normalize(vel) * v * 10;  
		if ( v > 100 )
				vel = normalize(vel) * 1000;  

		self.owner.velocity = vel;
		self.dest = self.owner.origin;
		self.nextthink = time + 0.1;
	}
};

/**************\
* T_ChainTouch *
\**************/

void() T_ChainTouch =
{   
	//bprint("got to ChainTouch Start \n"); //MEZ line notice 
	if (other == self.owner)
			return;         // don't attach to owner

	if (pointcontents(self.origin) == CONTENT_SKY) {
                HookVanish();
                return;
	}

	if (other.classname == "player" && teamplay &&
		other.team == self.owner.lastteam)
		return; // just pass through teammates

	if (other.takedamage) {
		// don't damage teammates
		if (other.classname == "player")
			other.axhitme = 1; // make axe noise
		else
			sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		T_Damage (other, self, self.owner, 30, 0); //MEZ upped hook damage! Originally 10
		SpawnBlood (self.origin, self.velocity, 10);
	} else {
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		self.avelocity = '0 0 0';
	}            
	if (!self.owner.button0 && !self.owner.offhandhook) { //MEZ added 
			HookVanish();
			//bprint("got to HookVanish \n"); //MEZ line notice 
			return;
	} else {
			if (other.solid == SOLID_SLIDEBOX) {
					setorigin (self, other.origin + other.mins +
							(other.size * 0.5));
					self.velocity = '0 0 0';
			} else {
					self.velocity = other.velocity;
			}
			self.weapon = other.nextthink - time;

			self.style = 2;
			self.enemy = other;
			self.nextthink = time + 0.1;
			self.think = HookPull;
			//bprint( "got to HookPull call \n"); //MEZ line notice 
			self.touch = SUB_Null;
	}
};

/*************\
* W_FireChain *
\*************/

void() W_FireChain =
{
        local entity hook;

        self.hook_out = TRUE;
        hook = spawn ();
        hook.owner = self;
		self.goalentity = hook;
        hook.movetype = MOVETYPE_FLY;
        hook.solid = SOLID_BBOX;
		
// set hook speed 

        makevectors (self.v_angle);
        hook.velocity = aim(self, 1000); //MEZ originally 1000
        hook.velocity = hook.velocity * 2000; //MEZ originally 800, then 2400
        hook.angles = vectoangles(hook.velocity);
        hook.avelocity = '0 0 -500';
        hook.touch = T_ChainTouch;
// set hook sound
        hook.nextthink = time + 5;
        hook.think = HookVanish;
		setmodel (hook, "progs/v_spike.mdl");
        setsize (hook, '0 0 0', '0 0 0');     
        setorigin (hook, self.origin + (v_forward*16) + '0 0 16' );
		sound (self, CHAN_WEAPON, "hknight/hit.wav", 1, ATTN_NORM);	
        hook.goalentity = MakeChain (hook, self, 3);   
		//sprint(self, "got to MakeChainCall \n"); //MEZ line notice WORKS TO HERE
};

