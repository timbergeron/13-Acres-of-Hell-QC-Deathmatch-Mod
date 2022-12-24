//-----------------------------------------------------------------------------------
//
// Info displayed at start + MOTD
//
//-----------------------------------------------------------------------------------

void() InitMOTD =
{
	MOTD = "\n Welcome to \b13 Acres of Hell!\b\n\n_____________________________________\n\nCustom Deathmatch Maps with BOTS!\n\nRunes, Hook, and Balance Tweaks\n\nversion 1.1\n\n";
	//original  MOTD = "\n ²·┐·┐·÷ ╠Ё ацрес ОФ хелл║║║ ²·┐·┐·÷\n\nCustom Deathmatch Maps with BOTS!\n\n";
};

void() DisplayInfo =
{
local string v;

	InitMOTD();

	v = ftos(VERSION);
	centerprint(self, MOTD, "_____________________________________\n\nType цоммандс for help.\n_____________________________________\n\nRunning ACRES Mod", "", "\nby: Mezmorki");
};

void() DisplayMOTD =
{
	InitMOTD();

	centerprint(self, MOTD, "_____________________________________\n\nType цоммандс for help.\n_____________________________________", "", "");
};
