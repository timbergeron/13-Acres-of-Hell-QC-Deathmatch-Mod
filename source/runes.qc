// CTF ->

/*----------------------------------------------------------------------
  The Rune Game modes

  Rune 1 - Earth Magic
	  resistance
  Rune 2 - Black Magic
	  strength
  Rune 3 - Hell Magic
	  haste
  Rune 4 - Elder Magic
	  regeneration

 ----------------------------------------------------------------------*/

entity() SelectRuneSpawnPoint =
{
	runespawn = find(runespawn, classname, "info_player_deathmatch");
	if (runespawn == world)
		runespawn = find (runespawn, classname, "info_player_deathmatch");
	if (runespawn == world)
		error("no info_player_deathmatch to spawn rune");
	return runespawn;
};

void() RuneTouch =
{
	local string	s;
	local	float	best, runecur;
	local		entity	stemp;
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.player_flag & ITEM_RUNE_MASK) 
	{
		if (other.rune_notice_time < time) {
			//sprint(other, "You already have a rune."); // MEZ Commented out for new addition
			//MEZ start
			if (self.player_flag & ITEM_RUNE1_FLAG)
				sprint(other, "You have a rune. Drop it to switch to \bResistance\b Rune.\n");
			if (self.player_flag & ITEM_RUNE2_FLAG)
				sprint(other, "You have a rune. Drop it to switch to \bStrength\b Rune.\n");
			if (self.player_flag & ITEM_RUNE3_FLAG)
				sprint(other, "You have a rune. Drop it to switch to \bHaste\b Rune.\n");
			if (self.player_flag & ITEM_RUNE4_FLAG)
				sprint(other, "You have a rune. Drop it to switch to \bRegeneration\b Rune\n");
			//MEZ end
			other.rune_notice_time = time + 3; //MEZ was orignally 5-seconds
		}
		return; // one per customer
	}
	if (other.runedelay == 1)	//MEZ Added this function for delay for better rune dropping
	{
		//bprint("rune delay on\n");
		return;
	}	
	other.player_flag = other.player_flag | self.player_flag;

	// notification of rune, no nofity in team mode
	if (self.player_flag & ITEM_RUNE1_FLAG) {
		self.items = self.items | IT_SIGIL1;
		if (teamplay == 0) //if(runecur == 0) // MEZ modified - was: if (teamplay == 0)
		{
			bprint(other.netname);
			bprint(" has the \bResistance Rune\b (half damage taken)\n");
		//	runecur = 1; // MEZ added
		}
		else
			sprint(other, "You have the \bResistance Rune\b (half damage taken)\n");
		//	runecur = 1; // MEZ added
	}
	if (self.player_flag & ITEM_RUNE2_FLAG) {
		self.items = self.items | IT_SIGIL2;
		if (teamplay == 0) 
		{
			bprint(other.netname);
			bprint(" has the \bStrength Rune\b (double damage)\n");
		}
		else
			sprint(other, "You have \bStrength Rune\b (double damage)\n");
	}
	if (self.player_flag & ITEM_RUNE3_FLAG) {
		self.items = self.items | IT_SIGIL3;
		if (teamplay == 0) 
		{
			bprint(other.netname);
			bprint(" has the \bHaste Rune\b (hasted attacks)\n");
		}
		else
			sprint(other, "You have the \bHaste Rune\b (hasted attacks)\n");
	}
	if (self.player_flag & ITEM_RUNE4_FLAG) {
		self.items = self.items | IT_SIGIL4;
		if (teamplay == 0) 
		{
			bprint(other.netname);
			bprint(" has the \bRegeneration Rune\b (regen armor & life)\n");
		}
		else
			sprint(other, "You have the \bRegeneration Rune\b (regen armor & life)\n");
	}
	// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	remove(self);
};

void (float flag) Do_DropRune;

void() RuneRespawn =
{
	local entity oself;

	oself = self;

	// choose random starting points
	self = SelectRuneSpawnPoint();
	Do_DropRune(oself.player_flag);

	remove(oself);
};

void (float flag) Do_DropRune = 
{
	local entity	item;

	item = spawn();
	item.origin = self.origin - '0 0 0'; //MEZ was 0 0 24
	
	item.player_flag = flag;

	item.velocity_z = 400; //MEZ was 400
	item.velocity_x = -500 + (random() * 1000); //MEZ was: -500 + (random() * 1000);
	item.velocity_y = -500 + (random() * 1000); //MEZ 
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	if (flag & ITEM_RUNE1_FLAG)
		setmodel (item, "progs/end1.mdl");
	else if (flag & ITEM_RUNE2_FLAG)
		setmodel (item, "progs/end2.mdl");
	else if (flag & ITEM_RUNE3_FLAG)
		setmodel (item, "progs/end3.mdl");
	else if (flag & ITEM_RUNE4_FLAG)
		setmodel (item, "progs/end4.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.nextthink = time + 3; //MEZ no touch for 3 seconds
	item.touch = RuneTouch;
	
	item.nextthink = time + 120; /* if no one touches it in two minutes,
		respawn it somewhere else, so inaccessible ones will come 'back' */
	item.think = RuneRespawn;
};

/*
===============
Droprune
self is player
===============
*/
void() DropRune =
{
	if (self.player_flag & ITEM_RUNE1_FLAG)
		Do_DropRune(ITEM_RUNE1_FLAG);
	if (self.player_flag & ITEM_RUNE2_FLAG)
		Do_DropRune(ITEM_RUNE2_FLAG);
	if (self.player_flag & ITEM_RUNE3_FLAG)
		Do_DropRune(ITEM_RUNE3_FLAG);
	if (self.player_flag & ITEM_RUNE4_FLAG)
		Do_DropRune(ITEM_RUNE4_FLAG);
		//if (self.health > 100) //MEZ Added - DISABLED because accidential drop rune press deletes extra health
		//	self.health = 100;  //MEZ Added
	self.player_flag = self.player_flag - (self.player_flag & ITEM_RUNE_MASK);
};

/*
================
SpawnRunes
spawn all the runes
self is the entity that was created for us, we remove it
================
*/
void() SpawnRunes =
{
	local entity oself;
	local float i;

	oself = self;

	// choose random starting points
	i = random() * 10;
	while (i > 0) {
		self = SelectRuneSpawnPoint();
		i = i - 1;
	}

	self = SelectRuneSpawnPoint();
	Do_DropRune(ITEM_RUNE1_FLAG);
	self = SelectRuneSpawnPoint();
	Do_DropRune(ITEM_RUNE2_FLAG);
	self = SelectRuneSpawnPoint();
	Do_DropRune(ITEM_RUNE3_FLAG);
	self = SelectRuneSpawnPoint();
	Do_DropRune(ITEM_RUNE4_FLAG);

	remove(oself);
};

void() StartRuneSpawn =
{
	local entity rspawn;

	if (runespawned)
		return;

	runespawned = 1;

	precache_model ("progs/end1.mdl");
	precache_model ("progs/end2.mdl");
	precache_model ("progs/end3.mdl");
	precache_model ("progs/end4.mdl");

	precache_sound("boss1/sight1.wav");
	precache_sound("items/r_item1.wav");
	precache_sound("items/damage3.wav");
	precache_sound("items/protect3.wav");

	// spawn the runes
	rspawn = spawn();
	rspawn.nextthink = time + 0.1;
	rspawn.think = SpawnRunes;
};

// CTF <-