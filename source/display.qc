//-----------------------------------------------------------------------------------
//
// Display
//
//-----------------------------------------------------------------------------------

void() DisplaySettings =
{
	local float t;
	local string tl, fl, dm;

	sprint(self, "\n");
	sprint(self, "\n");
	sprint(self, "\n");	//general settings

	sprint(self, "ΔΕΑΤΘΝΑΤΓΘ   Ί\n");	//deathmatch
	if(deathmatch & D_WEAPONSSTAY)
		sprint(self, "             Weapons stay\n");
	if(deathmatch & D_ALLWEAPONS)
		sprint(self, "             Start fully armed\n");
	if(deathmatch & D_INFINITEAMMO)
		sprint(self, "             Infinite ammo\n");
	if(deathmatch & D_FULLARMOR)
		sprint(self, "             Full armor\n");
	if(deathmatch & D_SPEED)
		sprint(self, "             Speed DM\n");
	if(deathmatch & D_FASTRELOAD)
		sprint(self, "             Fast-weapons DM\n");
	if(deathmatch & D_MOREHEALTH)
		sprint(self, "             Megahealth DM\n");
	if(deathmatch & D_BERSERKDM)
		sprint(self, "             Berserk DM (time)\n");
	if(deathmatch & D_BERSERKDM2)
		sprint(self, "             Berserk DM (health)\n");
	if(deathmatch & D_DARKDM)
		sprint(self, "             Dark DM\n");
	if(deathmatch & D_GETHEAD)
		sprint(self, "             GetHead-Game\n");
	if(deathmatch & D_SHAMBLERHEAD)
		sprint(self, "             ShamblerHead Game\n");
	if(deathmatch & D_HH)
		sprint(self, "             Hunter and Hunted\n");
	if(deathmatch == 1)
		sprint(self, "             Normal DM\n");
	sprint(self, "\n");


	if(teamplay)
		sprint(self, "ΤΕΑΝΠΜΑΩ     Ί\n");	//teamplay
	if(teamplay & TEAM_HEALTHPROTECT)
		sprint(self, "             Healthprotection\n");
	if(teamplay & TEAM_ARMORPROTECT)
		sprint(self, "             Armorprotection\n");
	if(teamplay & TEAM_DAMAGEPENALTY)
		sprint(self, "             Damage-penalty\n");
	if(teamplay & TEAM_FRAGPENALTY)
		sprint(self, "             Frag-penalty\n");
	if(teamplay & TEAM_DEATHPENALTY)
		sprint(self, "             Death-penalty\n");
	if(teamplay & TEAM_AUTOJOIN)
		sprint(self, "             Auto-choose teams\n");
	if(teamplay & TEAM_NOCHANGE)
		sprint(self, "             Changing teams disabled\n");
	if(teamplay & TEAM_MATCH)
		sprint(self, "             Team Match\n");
	if(teamplay & TEAM_MATCH2)
		sprint(self, "             Team Match 2\n");
	if(teamplay & TEAM_CTF)
		sprint(self, "             Capture the flag\n");
	if(teamplay == 1)
		sprint(self, "             Normal teamplay\n");
	if(teamplay)
		sprint(self, "\n");

	if(temp1)
		sprint(self, "ΙΝΠ?ΟΦΕΝΕΞΤΣ Ί\n");	//improvements
	if(temp1 & T_ALLOWOBSERVER)
		sprint(self, "             Observer Mode\n");
	if(temp1 & T_RPROTECTION)
		sprint(self, "             Respawn protection\n");
	if(temp1 & T_SUICIDEPROTECTION)
		sprint(self, "             Suicide protection\n");
	if(temp1 & T_DROPPOWERUPS)
		sprint(self, "             Drop powerups\n");
	if(temp1 & T_FAIRWEAPON)
		sprint(self, "             Fair backpack weapons\n");
	if(temp1 & T_VISBKPWEAPONS)
		sprint(self, "             Visible backpack weapons\n");
	if(temp1 & T_NOMESSAGES)
		sprint(self, "             Unimportant messages off\n");
	if(temp1)
		sprint(self,"\n");

	if(savedgamecfg)	//Mez Added
		sprint(self, "ΔΙΣΑΒΜΕΔ ΙΤΕΝΣΊ\n");	//disabled items
	if(savedgamecfg & SK_NOSSG)
		sprint(self, "             Supershotgun\n");
	if(savedgamecfg & SK_NONG)
		sprint(self, "             Nailgun\n");
	if(savedgamecfg & SK_NOSNG)
		sprint(self, "             Supernailgun\n");
	if(savedgamecfg & SK_NOGL)
		sprint(self, "             Grenade launcher\n");
	if(savedgamecfg & SK_NORL)
		sprint(self, "             Rocket launcher\n");
	if(savedgamecfg & SK_NOLG)
		sprint(self, "             Thunderbolt\n");
	if(savedgamecfg & SK_NOHEALTH)
		sprint(self, "             Health\n");
	if(savedgamecfg & SK_NOGA)
		sprint(self, "             Green Armor\n");
	if(savedgamecfg & SK_NOYA)
		sprint(self, "             Yellow Armor\n");
	if(savedgamecfg & SK_NORA)
		sprint(self, "             Red Armor\n");
	if(savedgamecfg & SK_NOQUAD)
		sprint(self, "             Quad\n");
	if(savedgamecfg & SK_NORING)
		sprint(self, "             Ring\n");
	if(savedgamecfg & SK_NOPENT)
		sprint(self, "             Invulnerability\n");
	if(savedgamecfg & SK_NOSHELLS)
		sprint(self, "             Shells\n");
	if(savedgamecfg & SK_NONAILS)
		sprint(self, "             Nails\n");
	if(savedgamecfg & SK_NOROCKETS)
		sprint(self, "             Rockets\n");
	if(savedgamecfg & SK_NOCELLS)
		sprint(self, "             Cells\n");
	sprint(self, "\n");

	sprint(self, "ΝΙΣΓΕΜΜΑΞΟΥΣ Ί\n");	//miscellanous
	if(deathmatch & D_OVERTIME)
		sprint(self, "             Sudden death if tied\n");
	if(deathmatch & D_CANTHARMSELF)
		sprint(self, "             Players cannot harm self\n");
	if(deathmatch & D_OCTADAMAGE)
		sprint(self, "             Octadamage\n");
	if(temp1 & T_MOREGIBS)
		sprint(self, "             More Gibs\n");
	if(temp1 & T_DEATHINFO)
		sprint(self, "             Deathinfo\n");
	if(temp1 & T_DAMAGEINFO)
		sprint(self, "             Damageinfo\n");
	if(temp1 & T_HITZONES)
		sprint(self, "             Hitzones\n");
	if(temp1 & T_ALLOWRUNES)
		sprint(self, "             Runes\n");
	if(temp1 & T_ALLOWHOOK)
		sprint(self, "             Grappling hook\n");
	sprint(self, "\n");

	sprint(self, "ΣΕ?ΦΕ? ΖΜΑΗΣ Ί\n");	//server flags
	if(temp1 & T_SERVERCLOSED)
		sprint(self, "             Joining forbidden\n");
	else
		sprint(self, "             Joining allowed\n");
	if(temp1 & T_JOINAVERAGEFRAGS)
		sprint(self, "             Join with average frags\n");
	sprint(self, "\n");

	sprint(self, "ΤΙΝΕΜΙΝΙΤ    Ί ");	//timelimit
	t = cvar("timelimit");
	tl = ftos(t);
	sprint(self, tl);
	sprint(self, "\n");

	sprint(self, "Ζ?ΑΗΜΙΝΙΤ    Ί ");	//fraglimit
	t = cvar("fraglimit");
	fl = ftos(t);
	sprint(self, fl);
	sprint(self, "\n\n");
	sprint(self, "\n");
	sprint(self, "(Use PgUp/PgDn keys to scroll)");
	sprint(self, "\n\n");
};

void() DisplayHelp =
{
	local float t;
	local string tl, fl, dm;
	sprint(self, "\n");
	sprint(self, "\n");
	sprint(self, "\n");
	sprint(self, "ΓΟΝΝΑΞΔ ΜΙΣΤΊ\n");	//Command list:
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΙΞΖΟ:                                \n");	//info
	sprint(self, "Displays this command list          \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΑΒΟΥΤ:                               \n");	//about
	sprint(self, "Displays version number and other   \n");
	sprint(self, " info                                \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΝΟΤΔ:                                \n");	//motd
	sprint(self, "Displays \"message of the day\"     \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΣΕ?ΦΕ?ΓΟΝΝΑΞΔΣ:                      \n");	//servercommands
	sprint(self, "Displays all commands which are only\n");
	sprint(self, " available to server                 \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΣΕΤΤΙΞΗΣ:                            \n");	//settings
	sprint(self, "Displays the current server settings\n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "?ΕΑΔΩ (in observer mode):            \n");	//ready
	sprint(self, "You become player when all players  \n");
	sprint(self, " are ready                           \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΟΒΣΕ?ΦΕ? (in observer mode):         \n");	//observer
	sprint(self, "You become observer when all players\n");
	sprint(self, " are ready                           \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "Β?ΕΑΛ (in observer mode):            \n");	//break
	sprint(self, "Tells the server that you are not   \n");
	sprint(self, " ready if you already typed ready or \n");
	sprint(self, " observer                            \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΛΑΣΓΑΝ:                              \n");	//kascam
	sprint(self, "Watch other players through kascam  \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΠΜΑΩΕ?ΣΤΑΤΣ:                         \n");	//playerstats
	sprint(self, "Prints some information about the   \n");
	sprint(self, " players (i.e. ready or not, ...)    \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "Β?ΕΑΛ (in match):                    \n");	//break
	sprint(self, "If the majority of players vote for \n");
	sprint(self, " a break by typing this the match    \n");
	sprint(self, " ends                                \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΦΟΤΕί[?ΕΙΞΓ±-?ΕΙΞΓΆ]:                \n");	//vote_[reinc1-reinc4]
	sprint(self, "Vote for the respective map         \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΙΔ:                                  \n");	//id
	sprint(self, "Displays name of players infront    \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "Δ?ΟΠΧΕΑΠΟΞ (in teamplay):            \n");	//dropweapon
	sprint(self, "Drops your current weapon           \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "Δ?ΟΠΑΝΝΟ (in teamplay):              \n");	//dropammo
	sprint(self, "Drops 10 of all ammotypes           \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "Δ?ΟΠΑ?ΝΟ? (in teamplay):             \n");	//droparmor
	sprint(self, "Drops your current armor            \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "Δ?ΟΠΘΕΑΜΤΘ (in teamplay):            \n");	//drophealth
	sprint(self, "Drops 10 of your health             \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΤΕΑΝΣΓΟ?ΕΣ (in teamplay):            \n");	//teamscores
	sprint(self, "Shows the scores of all teams       \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΓΘΑΞΗΕΤΕΑΝ (in teamplay):            \n");	//changeteam
	sprint(self, "Allows you to change your team      \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΤΟ?ΓΘ (in Dark DM):                  \n");	//torch
	sprint(self, "Toggles your torch                  \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "ΖΜΑ?Ε (in Dark DM):                  \n");	//flare
	sprint(self, "Shoots a flare to light your way    \n");
	sprint(self, "-------------------------------------\n");
	sprint(self, "\n");
	sprint(self, "\n");
	sprint(self, "(Use PgUp/PgDn keys to scroll)");
	sprint(self, "\n\n");
};

void() DisplayServerCommands =
{
	sprint(self, "\n");
	sprint(self, "\n");
	sprint(self, "\n");
	sprint(self, "ΣΕ?ΦΕ?ΓΟΝΝΑΞΔΣ\n");	//servercommands:
	sprint(self, "(only for server)Ί\n");
	sprint(self, "\n");
	sprint(self, "ΔΕΑΤΘΝΑΤΓΘ ΙΝΠ?ΟΦΕΝΕΞΤΣΊ\n");			//new improvements:
	sprint(self, "observermode.............Observermode\n");
	sprint(self, "r_protect..........Respawn protection\n");
	sprint(self, "s_protect..........Suicide protection\n");
	sprint(self, "droppowerups............Drop powerups\n");
	sprint(self, "fairweapon.......Fair Backpack weapon\n");
	sprint(self, "messages.........Unimportant messages\n");
	sprint(self, "moregibs....................More Gibs\n");
	sprint(self, "visbkpwpns...Visible backpack weapons\n");
	sprint(self, "deathinfo....Display info when killed\n");
	sprint(self, "daminfo...Display damage ( > 30) done\n");
	sprint(self, "hitzones.............Damage locations\n");
	sprint(self, "runes.....................Spawn runes\n");
	sprint(self, "hook...................Grappling hook\n");
	sprint(self, "\n");
	sprint(self, "ΖΟ?ΒΙΔ ΙΤΕΝΣΊ\n");				//forbid items:
	sprint(self, "supershotgun.............Supershotgun\n");
	sprint(self, "nailgun.......................Nailgun\n");
	sprint(self, "supernailgun.............Supernailgun\n");
	sprint(self, "grenadelauncher......Grenade launcher\n");
	sprint(self, "rocketlauncher........Rocket launcher\n");
	sprint(self, "thunderbolt...............Thunderbolt\n");
	sprint(self, "health.........................Health\n");
	sprint(self, "greenarmor................Green Armor\n");
	sprint(self, "yellowarmor..............Yellow Armor\n");
	sprint(self, "redarmor....................Red Armor\n");
	sprint(self, "quad......................Quad Damage\n");
	sprint(self, "ring..................Ring of Shadows\n");
	sprint(self, "pent..................Invulnerability\n");
	sprint(self, "shells.........................Shells\n");
	sprint(self, "nails...........................Nails\n");
	sprint(self, "rockets.......................Rockets\n");
	sprint(self, "cells...........................Cells\n");
	sprint(self, "\n");
	sprint(self, "ΞΕΧ ΔΕΑΤΘΝΑΤΓΘ ΝΟΔΙΊ\n");			//new deathmatch modi
	sprint(self, "speed................Speed Deathmatch\n");
	sprint(self, "allweapons..........Start fully armed\n");
	sprint(self, "infiniteammo............Infinite ammo\n");
	sprint(self, "octa.........Quad becomes Octa damage\n");
	sprint(self, "fullarmor.......Start with full armor\n");
	sprint(self, "megahealth..............Megahealth DM\n");
	sprint(self, "weaponsstay..............Weapons stay\n");
	sprint(self, "dark..................Dark Deathmatch\n");
	sprint(self, "berserk.............Berserk DM (time)\n");
	sprint(self, "berserk2..........Berserk DM (health)\n");
	sprint(self, "fastweapons...Fast-weapons Deathmatch\n");
	sprint(self, "harmself..Players can harm themselves\n");
	sprint(self, "suddend..SuddenDeath if match is tied\n");
	sprint(self, "hh...............Hunter and Hunted DM\n");
	sprint(self, "gethead...................Get-Head DM\n");
	sprint(self, "shead.................Shamblerhead DM\n");
	sprint(self, "\n");
	sprint(self, "ΣΕ?ΦΕ? ΖΜΑΗΣΊ\n");			//Server flags
	sprint(self, "lockserver.....Players may join match\n");
	sprint(self, "averagefrags..Join with average frags\n");
	sprint(self, "\n");
	sprint(self, "ΤΕΑΝΠΜΑΩ ΖΜΑΗΣΊ\n");			//teamplay flags
	sprint(self, "autojoin...Choose teams automatically\n");
	sprint(self, "teamchange......Change teams in-match\n");
	sprint(self, "h_protect..............Protect health\n");
	sprint(self, "a_protect...............Protect armor\n");
	sprint(self, "dam_penalty............Damage penalty\n");
	sprint(self, "d_penalty...............Death penalty\n");
	sprint(self, "f_penalty................Frag penalty\n");
	sprint(self, "teammatch.....TeamMatch (view readme)\n");
//	sprint(self, "teammatch2...TeamMatch2 (view readme)\n");
	sprint(self, "ctf..................Capture the flag\n");
	sprint(self, "\n");
	sprint(self, "ΝΙΣΓ ΓΟΝΝΑΞΔΣΊ\n");			//misc commands
	sprint(self, "force_start.........force match start\n");
	sprint(self, "force_break.........force match break\n");
	sprint(self, "maxteamsΫ2­6έ.number of teams allowed\n");	//[2-6]
	sprint(self, "\n");
	sprint(self, "(Use PgUp/PgDn keys to scroll)");
	sprint(self, "\n\n");
};

