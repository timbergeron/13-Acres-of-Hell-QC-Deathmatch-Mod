float	intermission_running;	//originally declared in client.qc
void() respawn;	//originally declared in client.qc

//-----------------------------------------------------------------------------------
//
// Teamplay functions
//
//-----------------------------------------------------------------------------------


void() InitNewTeamMatch =
{
	local entity e, oself;


	if(gameover)
		return;

	oself = self;
	e = find(world, classname, "player");
	while(e)
	{
		if(e.mode == M_PLAYER)
		{
			self = e;
			PlayerObserverMode();
		}
		e = find(e, classname, "player");
	}
	self = oself;
	gamestatus = gamestatus - (gamestatus & G_STARTING);
	gamestatus = gamestatus - (gamestatus & G_STARTED);
	CheckStartGame(0);
};

float(float cteam) TeamExists =
{
local entity p;
	if(!teamplay)
		return FALSE;

	p = find(world, classname, "player");
	while(p)
	{
		if(p.genteam == cteam)
			return TRUE;
		p = find(p, classname, "player");
	}

	p = find(world, classname, "KasCam");
	while(p)
	{
		if(p.genteam == cteam)
			return TRUE;
		p = find(p, classname, "KasCam");
	}
	return FALSE;
};

float() FreeTeam =
{
	local float ct;

	ct = 1;
	while(ct < 7)
	{
		if(!(TeamExists(ct)))
			return ct;
	}
	return 0;
};

//returns FALSE if there is more than one team left
//otherwise it returns the team which is left

float() OneTeamLeft =
{
	local entity e;
	local float lt, teams;
	
	lt = -999;
	e = find(world, classname, "player");
	while(e)
	{
		if((e.mode == M_PLAYER) && (e.health > 0))
		{
			if(lt != -999)
			{
				bprint("Found team ");
				bprint(Team2String(e.genteam));
				bprint(": ");
				bprint(e.netname);
				bprint("\n");
				if(lt != e.genteam)
					return FALSE;
			}
			lt = e.genteam;
		}
		e = find(e, classname, "player");
	}
	return lt;
};

void() CheckRoundEnd =
{
		local string steam;
		local float tl;

		tl = OneTeamLeft();
		if(tl > 0)
		{
			ApplyTeamFrags2(tl);
			steam = Team2String(tl);
			bcenterprint("The ", steam, " team wins the round.", "", "");
			InitNewTeamMatch();
		}
		else if(tl == -999)	//no team left ???
		{
			bcenterprint("This round is a tie.", "", "", "", "");
			InitNewTeamMatch();
		}
};


void(float cteam) FindNewLeader =
{
local entity p;

	p = find(world, classname, "player");
	while(p)
	{
		if(p.genteam == cteam)
		{
			p.teamleader = TRUE;
			return;
		}
		p = find(p, classname, "player");
	}
};

float() NumberOfTeams =
{
local float i, n;
	i = 1;
	while(i < 7)
	{
		if(TeamExists(i))
			n = n + 1;
		i = i + 1;
	}
	return n;
};

void() DisplayTeamMenu =
{
	local string s1, s2, s3, s4, s5, s6;
	local float nteams;
	s1 = s2 = s3 = s4 = s5 = s6 = "";

	nteams = NumberOfTeams();

	if(TeamExists(TBLUE))
		s1 = "1: Join blue \bTICK\b Horde           \n";	//40 chars
	else if(nteams < maxteams)
		s1 = "1: Create blue \bTICK\b Horde         \n";

	if(TeamExists(TRED))
		s2 = "2: Join red \bMOUNTIE\b Patrol        \n";	//40 chars
	else if(nteams < maxteams)
		s2 = "2: Create red \bMOUNTIE\b Patrol      \n";

	if(!(teamplay & TEAM_CTF))	
	{
		if(TeamExists(TGREEN))
			s3 = "3: Join green \bTURTLE\b Squad        \n";
		else if(nteams < maxteams)
			s3 = "3: Create green \bTURTLE\b Squad      \n";

		if(TeamExists(TYELLOW))
			s4 = "4: Join yellow \bTAXIMAN\b Union      \n";
		else if(nteams < maxteams)
			s4 = "4: Create yellow \bTAXIMAN\b Union    \n";

		if(TeamExists(TWHITE))
			s5 = "5: Join white \bALIEN\b Invaders      \n";
		else if(nteams < maxteams)
			s5 = "5: Create white \bALIEN\b Invaders    \n";

		if(temp1 & T_ALLOWOBSERVER)
		{
			if(TeamExists(TBROWN)) 
				s6 = "6: Join brown \bWOOKIE\b\b Clan         \n7: Keep Observermode. \n";
			else if(nteams < maxteams)
				s6 = "6: Create brown \bWOOKIE\b Clan       \n7: Keep Observermode. \n";
			else 
				s6 = "7: Keep Observermode. \n";
		}
		else
		{
			if(TeamExists(TBROWN)) 
				s6 = "6: Join brown \bWOOKIE\b Clan         \n";
			else if(nteams < maxteams)
				s6 = "6: Create brown \bWOOKIE\b Clan       \n";
		}
	}
	else if(temp1 & T_ALLOWOBSERVER)
		s6 = "7: Keep Observermode. \n";

	gencenterprint7(self, "ÃÈÏÏÓÅ ÙÏÕÒ ÔÅÁÍº\n\n", s1, s2, s3, s4, s5, s6);
};

float() TeamToJoin =
{
local entity p;
local float currentteam, lowestm, worstteam, cm;
	//bprint("ERROR CHECK: TeamToJoin Start Start\n");  //MEZ Check
	lowestm = 1000000;
	currentteam = worstteam = 1;
	cm = 0;
	
	while(currentteam < 7)
	{
		if(TeamExists(currentteam))
		{
			p = find(world, classname, "player");
			while(p)
			{
				if(p.genteam == currentteam)
					cm = cm + 1;
				p = find(p, classname, "player");
			}
		}
		if(cm < lowestm)
		{
			worstteam = currentteam;
			lowestm = cm;
		}
		currentteam = currentteam + 1;
		cm = 0;
	}
	return worstteam;
};

void() TeamScores =
{
local float currentteam, cf, t1f, t2f, t3f, t4f, t5f, t6f, t7f, t8f;
local string sf, leader;
local entity p;
	//bprint("ERROR CHECK: TeamScores Start\n");  //MEZ Check
	leader = "Team does not exist.";

	currentteam = 1;
	t1f = t2f = t3f = t4f = t5f = t6f = cf = 0;

	while(currentteam < 7)
	{
		if(TeamExists(currentteam))
		{
			p = find(world, classname, "player");
			while(p)
			{
				if(p.genteam == currentteam)
				{
					if(p.teamleader)
						leader = p.netname;
					cf = cf + p.frags;
				}
				p = find(p, classname, "player");
			}

			p = find(world, classname, "dcplayer");
			while(p)
			{
				if(p.genteam == currentteam)
				{
					if(p.teamleader)
						leader = p.netname;
					cf = cf + p.frags;
				}
				p = find(p, classname, "dcplayer");
			}
		}
		else cf = -9999999;

		if(currentteam == 1)
		{
			sprint(self, "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n");
			sprint(self, "Blue team  : ");
			if(cf != -9999999)
			{
				sf = ftos(cf);
				sprint(self, sf);
				sprint(self, " frags\n");	
			}
			else 
				sprint(self, "Team does not exist.\n");
			sprint(self, "Teamcaptain: ");
			sprint(self, leader);
			sprint(self, "\n");
			sprint(self, "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n");
		}
		else if(currentteam == 2)
		{
			sprint(self, "Red team   : ");
			if(cf != -9999999)
			{
				sf = ftos(cf);
				sprint(self, sf);
				sprint(self, " frags\n");	
			}
			else 
				sprint(self, "Team does not exist.\n");
			sprint(self, "Teamcaptain: ");
			sprint(self, leader);
			sprint(self, "\n");
			sprint(self, "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n");
		}
		else if(currentteam == 3)
		{
			sprint(self, "Green team : ");
			if(cf != -9999999)
			{
				sf = ftos(cf);
				sprint(self, sf);
				sprint(self, " frags\n");	
			}
			else 
				sprint(self, "Team does not exist.\n");
			sprint(self, "Teamcaptain: ");
			sprint(self, leader);
			sprint(self, "\n");
			sprint(self, "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n");
		}
		else if(currentteam == 4)
		{
			sprint(self, "Yellow team: ");
			if(cf != -9999999)
			{
				sf = ftos(cf);
				sprint(self, sf);
				sprint(self, " frags\n");	
			}
			else 
				sprint(self, "Team does not exist.\n");
			sprint(self, "Teamcaptain: ");
			sprint(self, leader);
			sprint(self, "\n");
			sprint(self, "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n");
		}
		else if(currentteam == 5)
		{
			sprint(self, "White team : ");
			if(cf != -9999999)
			{
				sf = ftos(cf);
				sprint(self, sf);
				sprint(self, " frags\n");	
			}
			else 
				sprint(self, "Team does not exist.\n");
			sprint(self, "Teamcaptain: ");
			sprint(self, leader);
			sprint(self, "\n");
			sprint(self, "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n");
		}
		else if(currentteam == 6)
		{
			sprint(self, "Brown team : ");
			if(cf != -9999999)
			{
				sf = ftos(cf);
				sprint(self, sf);
				sprint(self, " frags\n");	
			}
			else 
				sprint(self, "Team does not exist.\n");
			sprint(self, "Teamcaptain: ");
			sprint(self, leader);
			sprint(self, "\n");
			sprint(self, "žžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n");
		}
		cf = 0;
		leader = "Team does not exist.";
		currentteam = currentteam + 1;
	}
};

//returns -1 if team does not exist

float(float cteam) GetTeamScore =
{
local float tf;
local entity p;

	tf = 0;
	if(TeamExists(cteam))
	{
		p = find(world, classname, "player");
		while(p)
		{
			if(p.genteam == cteam)
				tf = tf + p.frags;
			p = find(p, classname, "player");
		}
//now check for disconnected players
		p = find(world, classname, "dcplayer");
		while(p)
		{
			if(p.genteam == cteam)
				tf = tf + p.frags;
			p = find(p, classname, "dcplayer");
		}
	}
	else 
		return -1;
	return tf;
};

string(float cteam) Team2String =
{
	if(cteam == TBLUE)
		return "blue";
	if(cteam == TRED)
		return "red";
	if(cteam == TWHITE)
		return "white";
	if(cteam == TBROWN)
		return "brown";
	if(cteam == TGREEN)
		return "green";
	if(cteam == TYELLOW)
		return "yellow";
};

string(float cteam) Team2Color =
{
	if(cteam == TBLUE)
		return "2";
	if(cteam == TRED)
		return "4";
	if(cteam == TWHITE)
		return "0";
	if(cteam == TBROWN)
		return "1";
	if(cteam == TGREEN)
		return "3";
	if(cteam == TYELLOW)
		return "12";
};

float(float cteam) Team2ScoreColor =
{
	if(cteam == TBLUE)
		return 39;
	if(cteam == TRED)
		return 71;
	if(cteam == TWHITE)
		return 7;
	if(cteam == TBROWN)
		return 23;
	if(cteam == TGREEN)
		return 55;
	if(cteam == TYELLOW)
		return 199;
};

void(entity p, float cteam) SetTeam =
{
local string tcolor;
	if(!p.flags & FL_CLIENT)
		return;
	tcolor = Team2Color(cteam);

	stuffcmd(p, "color ");
	stuffcmd(p, tcolor);
	stuffcmd(p, "\n");
	
// Mez Start
	if(cteam == TBLUE)
		self.skin = 27; //Tick
	if(cteam == TRED)
		self.skin = 18; //Mountie
	if(cteam == TWHITE) 
		self.skin = 24; //Alien
	if(cteam == TBROWN)
		self.skin = 29; //Wookie
	if(cteam == TGREEN)
		self.skin = 16; //Turtle
	if(cteam == TYELLOW)
		self.skin = 23; //Taximan
//MEZ End
	p.state = p.state - (p.state & S_CHOOSINGTEAM);
	if(!p.state & S_CHANGEDTEAM)
		p.state = p.state | S_CHANGEDTEAM;
	if(!p.state & S_TEAMCHOSEN)
		p.state = p.state | S_TEAMCHOSEN;
	p.genteam = cteam;
	p.team = cteam;
	p.lastteam = p.team;
};

void(float cteam) JoinTeam =
{
local string steamcolor;
	//bprint("ERROR CHECK: JoinTeam Start\n");  //MEZ Check
	SetTeam(self, cteam);

	steamcolor = Team2String(cteam);
	bprint(self.netname);
	bprint(" joins the ");
	bprint(steamcolor);
	bprint(" team.\n");
	//bprint("ERROR CHECK: JoinTeam End\n");  //MEZ Check
};

string(float cteam) Team2Netname =
{
	if(cteam == TBLUE)
		return "BLUE TEAM";
	if(cteam == TRED)
		return "RED TEAM";
	if(cteam == TWHITE)
		return "WHITE TEAM";
	if(cteam == TBROWN)
		return "BROWN TEAM";
	if(cteam == TGREEN)
		return "GREEN TEAM";
	if(cteam == TYELLOW)
		return "YELLOW TEAM";
};

entity(float cteam) Team2Entity =
{
	if(cteam == TBLUE)
		return blueteam;
	if(cteam == TRED)
		return redteam;
	if(cteam == TWHITE)
		return whiteteam;
	if(cteam == TBROWN)
		return brownteam;
	if(cteam == TGREEN)
		return greenteam;
	if(cteam == TYELLOW)
		return yellowteam;
};

void(float sp) FindTeamForScorepos =
{
	local float current, sp, fg, col;
	local string nm;
	local entity team_e;
	//bprint("ERROR CHECK: FindTeamForScorepos 1\n");  //MEZ Check
	current = 1;
	while(current < 7)
	{
		if(TeamExists(current))
		{
			team_e = Team2Entity(current);
			if(team_e.classname == "team_e")
			{
				team_e.scorepos = FindFreeScorepos();
				if(team_e.scorepos != -1)
				{
					//network messages won't work without this...
					sp = team_e.scorepos;
					fg = team_e.frags;
					col = Team2ScoreColor(team_e.genteam);
					nm = team_e.netname;
	
					WriteByte(MSG_ALL, MSG_NAME);
					WriteByte(MSG_ALL, sp);
					WriteString(MSG_ALL, nm);
	
					WriteByte(MSG_ALL, MSG_FRAGS);
					WriteByte(MSG_ALL, sp);
					WriteShort(MSG_ALL, fg);
	
					WriteByte(MSG_ALL, MSG_COLORS);
					WriteByte(MSG_ALL, sp);
					WriteByte(MSG_ALL, col);

					team_e.classname = "team_e+scorepos";
				}
			}
		}
		current = current + 1;
		//bprint("ERROR CHECK: FindTeamForScorepos 2\n");  //MEZ Check
	}
};

void(entity cteam, entity player) InitTeamEntity =
{
local string nm;
local float sp, fg, col, ffsp;

	cteam.netname = Team2Netname(player.genteam);
	cteam.frags = GetTeamScore(player.genteam);
	cteam.genteam = player.genteam;
	cteam.classname = "team_e";
	//bprint("ERROR CHECK: InitTeamEntity START\n");  //MEZ Check
	ffsp = FindFreeScorepos();
	
	if(ffsp != -1)	//there is a free scorepos so move the team into it	
	{
		cteam.scorepos = ffsp;

		//network messages won't work without this...
		sp = cteam.scorepos;
		fg = cteam.frags;
		col = Team2ScoreColor(player.genteam);
		nm = cteam.netname;
		
		WriteByte(MSG_ALL, MSG_NAME);
		WriteByte(MSG_ALL, sp);
		WriteString(MSG_ALL, nm);
		
		WriteByte(MSG_ALL, MSG_FRAGS);
		WriteByte(MSG_ALL, sp);
		WriteShort(MSG_ALL, fg);

		WriteByte(MSG_ALL, MSG_COLORS);
		WriteByte(MSG_ALL, sp);
		WriteByte(MSG_ALL, col);
		
		cteam.classname = "team_e+scorepos";
		
		//bprint("ERROR CHECK: InitTeamEntity END\n");  //MEZ Check
	}	
};

void() NextLevel;	//declared in client.qc

void(entity cteam) ApplyFragsToTeam = 
{
	local float fraglimit, fg, sp;

	//bprint("ERROR CHECK: ApplyFragsToTeam START\n");  //MEZ ERROR
	if(!teamplay)
		return;
	if(!TeamExists(cteam.genteam))
		return;

	cteam.frags = GetTeamScore(cteam.genteam);

	fraglimit = cvar("fraglimit");
	if (fraglimit)
		if (cteam.frags >= fraglimit)
			NextLevel ();

	if(cteam.scorepos != -1)
	{
		sp = cteam.scorepos;
		fg = cteam.frags;

		WriteByte(MSG_ALL, MSG_FRAGS);
		WriteByte(MSG_ALL, sp);
		WriteShort(MSG_ALL, fg);
	//bprint("ERROR CHECK: ApplyFragsToTeam END\n");  //MEZ ERROR
	}
};

void(entity cteam) ApplyFragsToTeam2 = 	//teammatch
{
	local float fraglimit, fg, sp;

	if(!teamplay)
		return;
	if(!TeamExists(cteam.genteam))
		return;

	cteam.frags = cteam.frags + 1;

	fraglimit = cvar("fraglimit");
	if (fraglimit)
		if (cteam.frags >= fraglimit)
			NextLevel ();

	if(cteam.scorepos != -1)
	{
		sp = cteam.scorepos;
		fg = cteam.frags;

		WriteByte(MSG_ALL, MSG_FRAGS);
		WriteByte(MSG_ALL, sp);
		WriteShort(MSG_ALL, fg);
	}
};

void(entity e) ApplyTeamFrags =
{
	//bprint("ERROR CHECK: ApplyTeamFrags START\n");  //MEZ ERROR
	if((teamplay & TEAM_MATCH) || (teamplay & TEAM_MATCH2))
		return;

	if(e.genteam == TBLUE)
		ApplyFragsToTeam(blueteam);
	else if(e.genteam == TRED)
		ApplyFragsToTeam(redteam);
	else if(e.genteam == TWHITE)
		ApplyFragsToTeam(whiteteam);
	else if(e.genteam == TBROWN)
		ApplyFragsToTeam(brownteam);
	else if(e.genteam == TGREEN)
		ApplyFragsToTeam(greenteam);
	else if(e.genteam == TYELLOW)
		ApplyFragsToTeam(yellowteam);
	//bprint("ERROR CHECK: ApplyTeamFrags END\n");  //MEZ ERROR
};

void(float cteam) ApplyTeamFrags2 =	//for teammatch
{
	if(cteam == TBLUE)
		ApplyFragsToTeam2(blueteam);
	else if(cteam == TRED)
		ApplyFragsToTeam2(redteam);
	else if(cteam == TWHITE)
		ApplyFragsToTeam2(whiteteam);
	else if(cteam == TBROWN)
		ApplyFragsToTeam2(brownteam);
	else if(cteam == TGREEN)
		ApplyFragsToTeam2(greenteam);
	else if(cteam == TYELLOW)
		ApplyFragsToTeam2(yellowteam);
};

void(float cteam) CreateTeam =
{
local string steamcolor;
	//bprint("ERROR CHECK: CreateTeam START\n");  //MEZ Check
	SetTeam(self, cteam);
	self.teamleader = TRUE;

	if(cteam == TBLUE)
		InitTeamEntity(blueteam, self);
	else if(cteam == TRED)
		InitTeamEntity(redteam, self);
	else if(cteam == TWHITE)
		InitTeamEntity(whiteteam, self);
	else if(cteam == TBROWN)
		InitTeamEntity(brownteam, self);
	else if(cteam == TGREEN)
		InitTeamEntity(greenteam, self);
	else if(cteam == TYELLOW)
		InitTeamEntity(yellowteam, self);
	
	steamcolor = Team2String(cteam);
	bprint(self.netname);
	bprint(" creates the ");
	bprint(steamcolor);
	bprint(" team.\n");
	//bprint("ERROR CHECK: CreateTeam END\n");  //MEZ Check
};

void() rteammatch2think =
{
local entity e, oself;
	
	if(((self.owner.health > 0) && (self.owner.mode != M_OBSERVER)) || (!teamplay))
	{
		remove(self);
		return;
	}
	bprint("thinking\n");
	e = findradius(self.origin, 100);
	while(e)
	{
		if((e.genteam == self.owner.genteam) && (e != self.owner) && (e.mode == M_PLAYER))
		{
			sprint(self.owner, "You are currently healed by ");
			sprint(self.owner, e.netname);
			sprint(self.owner, "\n");

			sprint(e, "You are currently healing ");
			sprint(e, self.owner.netname);
			sprint(e, "\n");

			self.owner.tm2 = self.owner.tm2 + 1;
		}
		e = e.chain;
	}
	if(self.owner.tm2 >= 10)
	{
		oself = self;
		self = self.owner;
		if(e.mode == M_PLAYER)
			centerprint(e, "You resurrected ", self.netname, ".", "");
		centerprint(self, "You were resurrected by ", e.netname, ".", "");
		respawn();
		self = oself;
		remove(self);
		return;
	}
	self.nextthink = time + 1;
};

void() BodyThink =
{
	if((self.owner.health > 0) && (self.owner.mode == M_PLAYER))
	{
		remove(self);
		return;
	}
	self.nextthink = time + 1;
};

void(entity ent) MakeRBody =
{
	local entity body;	

	body = spawn();
	body.angles = ent.angles;
	body.model = ent.model;
	body.modelindex = ent.modelindex;
	body.frame = ent.frame;
	body.colormap = ent.colormap;
	body.movetype = ent.movetype;
	body.velocity = ent.velocity;
	body.flags = 0;
	body.owner = ent;
	setorigin (body, ent.origin);
	setsize (body, ent.mins, ent.maxs);
	body.nextthink = time + 1;
	body.think = BodyThink;
	//bprint("ERROR CHECK: MakeRBody\n");  //MEZ Check
};
