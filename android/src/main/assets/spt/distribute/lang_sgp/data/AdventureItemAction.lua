local null = nil
local var = 
{
	[ [=[1001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the weather of the current cycle into Sunny? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=2001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Weather Card]=]
	},
	[ [=[1002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the weather of the current cycle into Rain? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=2002,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Weather Card]=]
	},
	[ [=[1003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the weather of the current cycle into Snow? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=2003,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Weather Card]=]
	},
	[ [=[1004]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the weather of the current cycle into Wind? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=2004,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Weather Card]=]
	},
	[ [=[1005]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the weather of the current cycle into Fog? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=2005,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Weather Card]=]
	},
	[ [=[1006]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the weather of the current cycle into Sand Storm? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=2006,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Weather Card]=]
	},
	[ [=[1007]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the weather of the current cycle into Sizzling Hot? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=2007,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Weather Card]=]
	},
	[ [=[1008]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to cross this part of ocean?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=6001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Gillyweed]=]
	},
	[ [=[1009]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to pass this toll gate free of charge?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=6002,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Pass of the Big Clubs]=]
	},
	[ [=[1010]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to cross the rubble area free of charge?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=6003,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Excavator]=]
	},
	[ [=[1011]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to remove all of your negative Buff?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=7001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Medications]=]
	},
	[ [=[1012]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to explore if there is any treasure in this area?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=4001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: The metal detector]=]
	},
	[ [=[1013]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use the All-Attributes of All Members Reduced by 5% function to reduce the player's combat power?]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=8001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Gossips of the Big Clubs]=]
	},
	[ [=[1014]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use the All-Attributes of All Members Reduced by 10% function to reduce the player's combat power?]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=8001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Gossips of the Big Clubs]=]
	},
	[ [=[1015]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use the All-Attributes of All Members Reduced by 15% function to reduce the player's combat power?]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=8001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[Message in the Dialog Box: Gossips of the Big Clubs]=]
	},
	[ [=[1200]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The item is applied successfully!]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up]=]
	},
	[ [=[1201]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Cross the ocean successfully, keep moving on!]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Gillyweed]=]
	},
	[ [=[1202]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Pass the toll gage successfully, keep moving on!]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Pass]=]
	},
	[ [=[1203]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Rubbles are cleaned, keep moving on!]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Excavator]=]
	},
	[ [=[1204]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[All negative BUFF is cleaned]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing Medications]=]
	},
	[ [=[1205]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The flare is on!]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Flare]=]
	},
	[ [=[1206]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The weather has been changed to Sunny]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Sunny Card]=]
	},
	[ [=[1207]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The weather has been changed to Rain]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Rain Card]=]
	},
	[ [=[1208]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The weather has been changed to Snow]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Snow Card]=]
	},
	[ [=[1209]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The weather has been changed to Wind]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Wind Card]=]
	},
	[ [=[1210]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The weather has been changed to Fog]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Fog Card]=]
	},
	[ [=[1211]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The weather has been changed to Sand Storm]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Sand Storm Card]=]
	},
	[ [=[1212]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The weather has been changed to Sizzling Hot]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[A white dialog box pops up showing the Sizzling Hot Card]=]
	},
	[ [=[1213]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Sunshine]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Sunshine]=]
	},
	[ [=[1214]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Moon Shadow]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Moon Shadow]=]
	},
	[ [=[1215]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Twinkling Stars]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Twinkling Stars]=]
	},
	[ [=[1216]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Fire of the Hell]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Fire of the Hell]=]
	},
	[ [=[1217]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Plagues]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Plagues]=]
	},
	[ [=[1218]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Chaos]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Chaos]=]
	},
	[ [=[1219]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Blessings of Light]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Blessings of Light]=]
	},
	[ [=[1220]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Annihilation into Fire]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Annihilation into Fire]=]
	},
	[ [=[1221]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Universe]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Universe]=]
	},
	[ [=[1222]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[The astrology has been changed to Change of Time]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[The astrology card: a white dialog box pops up showing Change of Time]=]
	},
	[ [=[1301]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[There is no responding from the scanner. It seems there is no treasure in this area]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogReward]=],
		[ [=[desc]=] ]=[=[If there are awards, a dialog box is to be pop up to remind players. If there is no award, the configuration of current cycle is to be displayed before a new dialog box to continue.]=]
	},
	[ [=[1401]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current cycle into Sunshine? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Sunshine]=]
	},
	[ [=[1402]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current cycle into Moon Shadow? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20002,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Moon Shadow]=]
	},
	[ [=[1403]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current cycle into Twinkling Stars? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20003,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Twinkling Stars]=]
	},
	[ [=[1404]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current cycle into Fire of the Hell? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20004,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Fire of the Hell]=]
	},
	[ [=[1405]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current cycle into Plagues? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20005,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Plagues]=]
	},
	[ [=[1406]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current session into Chaos? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20006,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Chaos]=]
	},
	[ [=[1407]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current session into Blessings of Light? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20007,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Blessings of Light]=]
	},
	[ [=[1408]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current cycle into Annihilation into Fire? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20008,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Annihilation into Fire]=]
	},
	[ [=[1409]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current session into Universe? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20009,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Universe]=]
	},
	[ [=[1410]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to change the astrology of the current session into Change of Time? (Remaining {2} rounds in the current cycle)]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=]
		},
		[ [=[nextAction]=] ]=20010,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[The Dialog Box pops up, showing the Astrology Card: Change of Time]=]
	},
	[ [=[2001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1206,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[The weather is switched to Sunny]=]
	},
	[ [=[2002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1207,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[The weather is switched to Rain]=]
	},
	[ [=[2003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1208,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[The weather is switched to Snow]=]
	},
	[ [=[2004]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1209,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[The weather is switched to Wind]=]
	},
	[ [=[2005]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1210,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[The weather is switched to Fog]=]
	},
	[ [=[2006]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1211,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[The weather is switched to Sand Storm]=]
	},
	[ [=[2007]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1212,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[The weather is switched to Sizzling Hot]=]
	},
	[ [=[3001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[TreasureMap]=],
		[ [=[desc]=] ]=[=[Check the Treasure Map]=]
	},
	[ [=[3101]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[MysticHint]=],
		[ [=[desc]=] ]=[=[Check the mystery codes]=]
	},
	[ [=[4001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1301,
		[ [=[actionType]=] ]=[=[TreasureOpen]=],
		[ [=[desc]=] ]=[=[the metal detector action, use adventure/openTreasure]=]
	},
	[ [=[6001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1201,
		[ [=[actionType]=] ]=[=[AdvTrigger]=],
		[ [=[desc]=] ]=[=[Change the status of the event on the map: Gillyweed in the ocean]=]
	},
	[ [=[6002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1202,
		[ [=[actionType]=] ]=[=[AdvTrigger]=],
		[ [=[desc]=] ]=[=[Change the status of the event on the map: Toll Pass]=]
	},
	[ [=[6003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1203,
		[ [=[actionType]=] ]=[=[AdvTrigger]=],
		[ [=[desc]=] ]=[=[Change the status of the event on the map: excavator of the rubbles]=]
	},
	[ [=[7001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1204,
		[ [=[actionType]=] ]=[=[BuffChange]=],
		[ [=[desc]=] ]=[=[Change self buff: clean all debuff with medications]=]
	},
	[ [=[8001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1200,
		[ [=[actionType]=] ]=[=[WeakenOpponent]=],
		[ [=[desc]=] ]=[=[Reduce the opponent's combat power]=]
	},
	[ [=[9001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to illuminate this area?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=],
			[ [=[size]=] ]=[=[3]=]
		},
		[ [=[nextAction]=] ]=1205,
		[ [=[actionType]=] ]=[=[FlashBang]=],
		[ [=[desc]=] ]=[=[The powerful flare]=]
	},
	[ [=[9002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to illuminate this area?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=],
			[ [=[size]=] ]=[=[1]=]
		},
		[ [=[nextAction]=] ]=1205,
		[ [=[actionType]=] ]=[=[FlashBang]=],
		[ [=[desc]=] ]=[=[The flare]=]
	},
	[ [=[9003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to illuminate this area?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[Message]=],
			[ [=[size]=] ]=[=[2]=]
		},
		[ [=[nextAction]=] ]=1205,
		[ [=[actionType]=] ]=[=[FlashBang]=],
		[ [=[desc]=] ]=[=[The enhanced flare]=]
	},
	[ [=[10001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[title]=] ]=[=[Message]=],
			[ [=[msg_over]=] ]=[=[Attention, please make sure you have checked the details of the event in the area before you finish it. The fog will cover the area again once you finish the checking.]=],
			[ [=[title_over]=] ]=[=[Message]=],
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to check the event under the fog in this area?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[1]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[Glasses]=],
		[ [=[desc]=] ]=[=[The X-ray scanner: 1x1]=]
	},
	[ [=[10002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[title]=] ]=[=[Message]=],
			[ [=[msg_over]=] ]=[=[Attention, please make sure you have checked the details of the event in the area before you finish it. The fog will cover the area again once you finish the checking.]=],
			[ [=[title_over]=] ]=[=[Message]=],
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to check the event under the fog in this area?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[2]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[Glasses]=],
		[ [=[desc]=] ]=[=[The α-ray scanner: 2x2]=]
	},
	[ [=[10003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[title]=] ]=[=[Message]=],
			[ [=[msg_over]=] ]=[=[Attention, please make sure you have checked the details of the event in the area before you finish it. The fog will cover the area again once you finish the checking.]=],
			[ [=[title_over]=] ]=[=[Message]=],
			[ [=[msg]=] ]=[=[Are you sure to use {1}x1 to check the event under the fog in this area?]=],
			[ [=[ {1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[3]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[Glasses]=],
		[ [=[desc]=] ]=[=[The 24k titanium photoscopy: 3x3]=]
	},
	[ [=[20001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1213,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Sunshine]=]
	},
	[ [=[20002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1214,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Moon Shadow]=]
	},
	[ [=[20003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1215,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Twinkling Stars]=]
	},
	[ [=[20004]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1216,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Fire of the Hell]=]
	},
	[ [=[20005]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1217,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Plagues]=]
	},
	[ [=[20006]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1218,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Chaos]=]
	},
	[ [=[20007]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1219,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Blessings of Light]=]
	},
	[ [=[20008]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1220,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Annihilation into Fire]=]
	},
	[ [=[20009]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1221,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Universe]=]
	},
	[ [=[20010]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1222,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[The astrology is switched to Change of Time]=]
	}
}
return var