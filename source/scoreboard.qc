float(float cteam) TeamExists;	//declared in teamplay.qc

//-----------------------------------------------------------------------------------
//
// Scoreboard manipulations
//
//-----------------------------------------------------------------------------------

//returns -1 if not found

float() FindFreeScorepos =
{
	local entity e;
	local float cp, sp;
	
//	bprint("maxplayers: ");
//	bprint(ftos(maxplayers));
//	bprint("\n");

	cp = maxplayers - 1;
	sp = -1;
	while(cp >= 0)
	{
		sp = cp;
//		bprint("Sp try: ");
//		bprint(ftos(sp));
//		bprint("\n");

		e = find(world, classname, "player");
		while(e)
		{
			if(e.scorepos == cp)
			{
//				bprint("Sp occupied by: ");
//				bprint(e.netname);
//				bprint("\n");
				sp = -1;
			}
			e = find(e, classname, "player");
		}
		
		if(sp >= 0)
		{
			e = find(world, classname, "team_e+scorepos");
			while(e)
			{
				if(e.scorepos == cp)
				{
//					bprint("Sp occupied by: ");
//					bprint(e.netname);
//					bprint("\n");
					sp = -1;
				}
				e = find(e, classname, "team_e+scorepos");
			}
		}

		if((sp >= 0) && (sp < maxplayers))	//found a free pos
		{
//			bprint("Sp final: ");
//			bprint(ftos(sp));
//			bprint("\n");
			return sp;
		}

		cp = cp - 1;
	}

//	bprint("Sp final: ");
//	bprint(ftos(sp));
//	bprint("\n");

	return sp;
};

void(float to, entity e) ClearScorepos =
{
	WriteByte(to, MSG_NAME);
	WriteByte(to, e.scorepos);  //scorepos
	WriteByte(to, 0);
};

void() RemoveTeamplayScoreposition =
{
	local entity e;
	e = find(world, classname, "team_e+scorepos");
	if(e)
	{
		ClearScorepos(MSG_ALL, e);
		gscorepos = gscorepos - 1;
		e.classname = "team_e";
		e.scorepos = -1;
	}
};

void(entity e) RemoveSpecificTeamplayScoreposition =
{
	if(e.classname != "team_e+scorepos")
		return;
	ClearScorepos(MSG_ALL, e);
	gscorepos = gscorepos - 1;
	e.classname = "team_e";
	e.scorepos = -1;
};

void() RemoveTeamplayScorepositions =
{
	RemoveSpecificTeamplayScoreposition(redteam);
	RemoveSpecificTeamplayScoreposition(blueteam);
	RemoveSpecificTeamplayScoreposition(greenteam);
	RemoveSpecificTeamplayScoreposition(brownteam);
	RemoveSpecificTeamplayScoreposition(yellowteam);
	RemoveSpecificTeamplayScoreposition(whiteteam);
};

void() RemoveNotUsedTeamplayScorepositions =
{
	if(!(TeamExists(TRED)))
		RemoveSpecificTeamplayScoreposition(redteam);
	if(!(TeamExists(TBLUE)))
		RemoveSpecificTeamplayScoreposition(blueteam);
	if(!(TeamExists(TGREEN)))
		RemoveSpecificTeamplayScoreposition(greenteam);
	if(!(TeamExists(TBROWN)))
		RemoveSpecificTeamplayScoreposition(brownteam);
	if(!(TeamExists(TYELLOW)))
		RemoveSpecificTeamplayScoreposition(yellowteam);
	if(!(TeamExists(TWHITE)))
		RemoveSpecificTeamplayScoreposition(whiteteam);
};


