﻿local null = nil
local var = 
{
	[ [=[101]=] ]=
	{
		[ [=[gameID]=] ]=101,
		[ [=[success]=] ]=5,
		[ [=[gameName]=] ]=[=[射门]=],
		[ [=[gameType]=] ]=1,
		[ [=[positionLimit]=] ]=
		{[=[FL]=],[=[FC]=],[=[FR]=]
		},
		[ [=[bigSuccess]=] ]=10,
		[ [=[errorNumber]=] ]=10000
	},
	[ [=[201]=] ]=
	{
		[ [=[gameID]=] ]=201,
		[ [=[success]=] ]=10,
		[ [=[gameName]=] ]=[=[颠球]=],
		[ [=[gameType]=] ]=2,
		[ [=[positionLimit]=] ]=
		{[=[ML]=],[=[MC]=],[=[MR]=],[=[AMC]=],[=[DMC]=]
		},
		[ [=[bigSuccess]=] ]=30,
		[ [=[errorNumber]=] ]=10000
	},
	[ [=[301]=] ]=
	{
		[ [=[gameID]=] ]=301,
		[ [=[success]=] ]=80,
		[ [=[gameName]=] ]=[=[回追]=],
		[ [=[gameType]=] ]=3,
		[ [=[positionLimit]=] ]=
		{[=[DL]=],[=[DC]=],[=[DR]=]
		},
		[ [=[bigSuccess]=] ]=65,
		[ [=[errorNumber]=] ]=3
	},
	[ [=[401]=] ]=
	{
		[ [=[gameID]=] ]=401,
		[ [=[success]=] ]=3,
		[ [=[gameName]=] ]=[=[扑救]=],
		[ [=[gameType]=] ]=4,
		[ [=[positionLimit]=] ]=
		{[=[GK]=]
		},
		[ [=[bigSuccess]=] ]=6,
		[ [=[errorNumber]=] ]=10000
	},
	[ [=[501]=] ]=
	{
		[ [=[gameID]=] ]=501,
		[ [=[success]=] ]=4,
		[ [=[gameName]=] ]=[=[答题]=],
		[ [=[gameType]=] ]=5,
		[ [=[positionLimit]=] ]=
		{[=[FL]=],[=[FC]=],[=[FR]=],[=[ML]=],[=[MC]=],[=[MR]=],[=[AMC]=],[=[DMC]=],[=[DL]=],[=[DC]=],[=[DR]=],[=[GK]=]
		},
		[ [=[bigSuccess]=] ]=8,
		[ [=[errorNumber]=] ]=10
	}
}
return var