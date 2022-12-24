//-----------------------------------------------------------------------------------
//
// Level and gameplay mode voting
//
//-----------------------------------------------------------------------------------

float() ChangeModeFFA =
{
	local float gbreak_ffa;
	local float b_ffa;
	local float np_ffa;
	local entity pl_ffa;
	
	np_ffa = 0;
	b_ffa = 0;
	gbreak_ffa = 0;
	
	pl_ffa = find(world, classname, "player");
	while(pl_ffa != world)
	{
		//if(pl_ffa.mode != M_OBSERVER) //Mez Vote - disable observer mode check
			np_ffa = np_ffa + 1;
		if(pl_ffa.state & S_VOTEREINC1)
			b_ffa = b_ffa + 1;
		pl_ffa = find(pl_ffa, classname, "player");
	}
	np_ffa = rint(np_ffa);

	gbreak_ffa = b_ffa / np_ffa;
	if(gbreak_ffa > 0.5)
		return TRUE;
	return FALSE;
};

float() ChangeModeTeam =
{
	local float gbreak_team;
	local float b_team;
	local float np_team;
	local entity pl_team;
	
	np_team = 0;
	b_team = 0;
	gbreak_team = 0;

	pl_team = find(world, classname, "player");
	while(pl_team != world)
	{
		//if(pl_team.mode != M_OBSERVER) //Mez Vote - disable observer mode check
			np_team = np_team + 1;
		if(pl_team.state & S_VOTEREINC2)
			b_team = b_team + 1;
		pl_team = find(pl_team, classname, "player");
	}
	np_team = rint(np_team);

	gbreak_team = b_team / np_team;
	if(gbreak_team > 0.5)
		return TRUE;
	return FALSE;
};

float() ChangeModePred =
{
	local float gbreak_pred;
	local float b_pred;
	local float np_pred;
	local entity pl_pred;
	
	np_pred = 0;
	b_pred = 0;
	gbreak_pred = 0;

	pl_pred = find(world, classname, "player");
	while(pl_pred != world)
	{
		//if(pl_pred.mode != M_OBSERVER) //Mez Vote - disable observer mode check
			np_pred = np_pred + 1;
		if(pl_pred.state & S_VOTEREINC3)
			b_pred = b_pred + 1;
		pl_pred = find(pl_pred, classname, "player");
	}
	np_pred = rint(np_pred);

	gbreak_pred = b_pred / np_pred;
	if(gbreak_pred > 0.5)
		return TRUE;
	return FALSE;
};
float() ChangeModeDuel =
{
	local float gbreak_duel;
	local float b_duel;
	local float np_duel;
	local entity pl_duel;
	
	np_duel = 0;
	b_duel = 0;
	gbreak_duel = 0;

	pl_duel = find(world, classname, "player");
	while(pl_duel != world)
	{
		//if(pl_duel.mode != M_OBSERVER) //Mez Vote - disable observer mode check
			np_duel = np_duel + 1;
		if(pl_duel.state & S_VOTEREINC4)
			b_duel = b_duel + 1;
		pl_duel = find(pl_duel, classname, "player");
	}
	np_duel = rint(np_duel);

	gbreak_duel = b_duel / np_duel;
	if(gbreak_duel > 0.5)
		return TRUE;
	return FALSE;
};
float() ChangeModeCTF =
{
	local float gbreak_ctf;
	local float b_ctf;
	local float np_ctf;
	local entity pl_ctf;
	
	np_ctf = 0;
	b_ctf = 0;
	gbreak_ctf = 0;

	pl_ctf = find(world, classname, "player");
	while(pl_ctf != world)
	{
		//if(pl_duel.mode != M_OBSERVER) //Mez Vote - disable observer mode check
			np_ctf = np_ctf + 1;
		if(pl_ctf.state & S_VOTEREINC5)
			b_ctf = b_ctf + 1;
		pl_ctf = find(pl_ctf, classname, "player");
	}
	np_ctf = rint(np_ctf);

	gbreak_ctf = b_ctf / np_ctf;
	if(gbreak_ctf > 0.5)
		return TRUE;
	return FALSE;
};
float() LockFlagVote =
{
	local float gbreak_flag;
	local float b_flag;
	local float np_flag;
	local entity pl_flag;
	
	np_flag = 0;
	b_flag = 0;
	gbreak_flag = 0;

	pl_flag = find(world, classname, "player");
	while(pl_flag != world)
	{
		//if(pl_duel.mode != M_OBSERVER) //Mez Vote - disable observer mode check
			np_flag = np_flag + 1;
		if(pl_flag.state & S_VOTEREINC6)
			b_flag = b_flag + 1;
		pl_flag = find(pl_flag, classname, "player");
	}
	np_flag = rint(np_flag);

	gbreak_flag = b_flag / np_flag;
	if(gbreak_flag >= 0.75)
		return TRUE;
	return FALSE;
};
/*
float(float clevel) CheckChangeLevel = //MEz Vote original: float(float clevel) CheckChangeLevel =
{
	local float gbreak; //Mez vote original: local float gbreak = 0;
	local float cl1, cl2, cl3, cl4, cl5, cl6;
	local float np; //Mez vote original: local float np = 0;
	local entity pl;

	gbreak = 0; //Mez vote added
	np = 0; //Mez vote added
	cl1 = cl2 = cl3 = cl4 = cl5 = cl6 = 0;

	pl = find(world, classname, "player");
	while(pl != world)
	{
		if(pl.mode != M_OBSERVER)
		{
			np = np + 1;				//Mez Vote note: sets denominator for number of players (+1)
			if(pl.state & S_VOTEREINC1)
			{
				bprint("MSTEP 4: CheckCgangeLevel Running\n"); //Mez Vote Check
				cl1 = cl1 + 1;
			}
			if(pl.state & S_VOTEREINC2)
				cl2 = cl2 + 1;
			if(pl.state & S_VOTEREINC3)
				cl3 = cl3 + 1;
			if(pl.state & S_VOTEREINC4)
				cl4 = cl4 + 1;
			if(pl.state & S_VOTEREINC5)
				cl5 = cl5 + 1;
			if(pl.state & S_VOTEREINC6)
				cl6 = cl6 + 1;
		}
		pl = find(pl, classname, "player");
	}
	np = rint(np);

	gbreak = cl1 / np;
	if(gbreak > 0.1) //Mez vote change to equal to or greater
	{
		bprint("MSTEP 5: Got to CheckChangeLevel Reinc1\n"); // MEZ Check
		changelevel("reinc1");
		bprint("The majority of players voted for map REINC1.\nChanging map.\n");
		return TRUE;
	}

	gbreak = cl2 / np;
	if(gbreak > 0.5)
	{
		changelevel("reinc2");
		bprint("The majority of players voted for map REINC2.\nChanging map.\n");
		return TRUE;
	}

	gbreak = cl3 / np;
	if(gbreak > 0.5)
	{
		changelevel("reinc3");
		bprint("The majority of players voted for map REINC3.\nChanging map.\n");
		return TRUE;
	}

	gbreak = cl4 / np;
	if(gbreak > 0.5)
	{
		changelevel("reinc4");
		bprint("The majority of players voted for map REINC4.\nChanging map.\n");
		return TRUE;
	}

	gbreak = cl5 / np;
	if(gbreak > 0.5)
	{
		changelevel("reinc5");
		bprint("The majority of players voted for map REINC5.\nChanging map.\n");
		return TRUE;
	}

	gbreak = cl6 / np;
	if(gbreak > 0.5)
	{
		changelevel("reinc6");
		bprint("The majority of players voted for map REINC6.\nChanging map.\n");
		return TRUE;
	}

	return FALSE;
};
*/

