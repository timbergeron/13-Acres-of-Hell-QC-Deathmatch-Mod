//-----------------------------------------------------------------------------------
//
// Any commands that should be bound automatically here
//
//-----------------------------------------------------------------------------------

void() SetAliases =
{
        stuffcmd(self,"alias flagstatus \"impulse 21\"\n");
        stuffcmd(self,"alias fs \"impulse 21\"\n");
        stuffcmd(self,"alias id \"impulse 22\"\n");
        stuffcmd(self,"alias commands \"impulse 102\"\n");
        stuffcmd(self,"alias info \"impulse 102\"\n");
        stuffcmd(self,"alias cmds \"impulse 102\"\n");
        stuffcmd(self,"alias cmdlist \"impulse 102\"\n");
        stuffcmd(self,"alias ready \"impulse 103\"\n");
        stuffcmd(self,"alias observer \"impulse 104\"\n");
        stuffcmd(self,"alias settings \"impulse 106\"\n");
        stuffcmd(self,"alias break \"impulse 107\"\n");	// Break simple triggers next level change
        stuffcmd(self,"alias force_start \"impulse 110\"\n");
        stuffcmd(self,"alias playerstats \"impulse 111\"\n");
        stuffcmd(self,"alias torch \"impulse 112\"\n");
        stuffcmd(self,"alias flare \"impulse 113\"\n");
        stuffcmd(self,"alias force_break \"impulse 114\"\n");
        stuffcmd(self,"alias maxteams2 \"impulse 115\"\n");
        stuffcmd(self,"alias maxteams3 \"impulse 116\"\n");
        stuffcmd(self,"alias maxteams4 \"impulse 117\"\n");
        stuffcmd(self,"alias maxteams5 \"impulse 118\"\n");
        stuffcmd(self,"alias maxteams6 \"impulse 119\"\n");
        stuffcmd(self,"alias changeteam \"impulse 120\"\n");
        stuffcmd(self,"alias teamscores \"impulse 121\"\n");
        stuffcmd(self,"alias dropammo \"impulse 123\"\n");
        stuffcmd(self,"alias droparmor \"impulse 124\"\n");
        stuffcmd(self,"alias drophealth \"impulse 125\"\n");
        stuffcmd(self,"alias dropweapon \"impulse 126\"\n");
        stuffcmd(self,"alias about \"impulse 127\"\n");
        stuffcmd(self,"alias servercommands \"impulse 128\"\n");
        stuffcmd(self,"alias scmds \"impulse 128\"\n");
        stuffcmd(self,"alias motd \"impulse 129\"\n");
        stuffcmd(self,"alias p_info \"impulse 130\"\n");

        stuffcmd(self,"alias kascam \"impulse 250\"\n");

        stuffcmd(self,"alias quad \"impulse 150\"\n");
        stuffcmd(self,"alias ring \"impulse 151\"\n");
        stuffcmd(self,"alias pent \"impulse 152\"\n");
        stuffcmd(self,"alias observermode \"impulse 153\"\n");
        stuffcmd(self,"alias messages \"impulse 154\"\n");
        stuffcmd(self,"alias s_protect \"impulse 155\"\n");
        stuffcmd(self,"alias health \"impulse 156\"\n");
        stuffcmd(self,"alias redarmor \"impulse 157\"\n");
        stuffcmd(self,"alias yellowarmor \"impulse 158\"\n");
        stuffcmd(self,"alias greenarmor \"impulse 159\"\n");
        stuffcmd(self,"alias droppowerups \"impulse 160\"\n");
        stuffcmd(self,"alias speed \"impulse 161\"\n");
        stuffcmd(self,"alias supershotgun \"impulse 162\"\n");
        stuffcmd(self,"alias nailgun \"impulse 163\"\n");
        stuffcmd(self,"alias supernailgun \"impulse 164\"\n");
        stuffcmd(self,"alias grenadelauncher \"impulse 165\"\n");
        stuffcmd(self,"alias rocketlauncher \"impulse 166\"\n");
        stuffcmd(self,"alias thunderbolt \"impulse 167\"\n");
        stuffcmd(self,"alias moregibs \"impulse 168\"\n");
        stuffcmd(self,"alias fairweapon \"impulse 169\"\n");
        stuffcmd(self,"alias allweapons \"impulse 170\"\n");
        stuffcmd(self,"alias infiniteammo \"impulse 171\"\n");
        stuffcmd(self,"alias r_protect \"impulse 172\"\n");
        stuffcmd(self,"alias megahealth \"impulse 173\"\n");
        stuffcmd(self,"alias weaponsstay \"impulse 174\"\n");
        stuffcmd(self,"alias dark \"impulse 175\"\n");
        stuffcmd(self,"alias berserk \"impulse 176\"\n");
        stuffcmd(self,"alias teamchange \"impulse 177\"\n");
        stuffcmd(self,"alias autojoin \"impulse 178\"\n");
        stuffcmd(self,"alias h_protect \"impulse 179\"\n");
        stuffcmd(self,"alias a_protect \"impulse 180\"\n");
        stuffcmd(self,"alias dam_penalty \"impulse 181\"\n");
        stuffcmd(self,"alias f_penalty \"impulse 182\"\n");
        stuffcmd(self,"alias d_penalty \"impulse 183\"\n");
        stuffcmd(self,"alias lockserver \"impulse 184\"\n");
        stuffcmd(self,"alias averagefrags \"impulse 185\"\n");
        stuffcmd(self,"alias fastweapons \"impulse 186\"\n");
        stuffcmd(self,"alias berserk2 \"impulse 187\"\n");
        stuffcmd(self,"alias octa \"impulse 188\"\n");
        stuffcmd(self,"alias fullarmor \"impulse 189\"\n");
        stuffcmd(self,"alias harmself \"impulse 190\"\n");
        stuffcmd(self,"alias visbkpwpns \"impulse 191\"\n");
        stuffcmd(self,"alias teammatch \"impulse 192\"\n");
        stuffcmd(self,"alias deathinfo \"impulse 193\"\n");
        stuffcmd(self,"alias suddend \"impulse 194\"\n");
        stuffcmd(self,"alias shells \"impulse 195\"\n");
        stuffcmd(self,"alias nails \"impulse 196\"\n");
        stuffcmd(self,"alias rockets \"impulse 197\"\n");
        stuffcmd(self,"alias cells \"impulse 198\"\n");
        stuffcmd(self,"alias hitzones \"impulse 199\"\n");
        stuffcmd(self,"alias daminfo \"impulse 200\"\n");
//      stuffcmd(self,"alias teammatch2 \"impulse 201\"\n");
        stuffcmd(self,"alias gethead \"impulse 202\"\n");
        stuffcmd(self,"alias shead \"impulse 203\"\n");
        stuffcmd(self,"alias hh \"impulse 204\"\n");
        stuffcmd(self,"alias ctf \"impulse 205\"\n");
        stuffcmd(self,"alias runes \"impulse 206\"\n");
        stuffcmd(self,"alias hook \"impulse 207\"\n");
		
		//MEZ Added Alias Begin
		stuffcmd(self,"alias +hook \"impulse 91\"\n");//MEZ add for hook
        stuffcmd(self,"alias -hook \"impulse 92\"\n");//MEZ add for hook
		stuffcmd(self,"alias autoswitch \"impulse 98\"\n");
		stuffcmd(self,"alias addbot \"impulse 60\"\n");
		stuffcmd(self,"alias removebot \"impulse 62\"\n");
		stuffcmd(self,"alias nextskin \"impulse 96\"\n");
		stuffcmd(self,"alias prevskin \"impulse 97\"\n");
		stuffcmd(self,"alias +droprune \"impulse 95\"\n");
		stuffcmd(self,"alias -droprune \"impulse 94\"\n");
		stuffcmd(self,"alias runecheck \"impulse 93\"\n");	
		stuffcmd(self,"alias voteteam \"impulse 242\"\n"); //Mez Change to Teamplay Mode (voteteam)
		stuffcmd(self,"alias votefree \"impulse 241\"\n"); //Mez Change to FFA Mode (voteffa
        stuffcmd(self,"alias votepred \"impulse 243\"\n"); //Mez Change to Predator Mode (votepred)
        stuffcmd(self,"alias voteduel \"impulse 244\"\n"); //Mez Change to Duel Maps (voteduelmaps)
        stuffcmd(self,"alias votectf \"impulse 246\"\n"); //Mez Change to Bigger Maps (votelargemaps)
        stuffcmd(self,"alias lockflags \"impulse 247\"\n"); //Mez Change to Lock Flags
        stuffcmd(self,"alias placeflag \"impulse 99\"\n"); //Mez to Place Flag	
		stuffcmd(self,"alias origbal \"impulse 208\"n");
};


