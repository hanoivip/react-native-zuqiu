local null = nil
local var = 
{
	[ [=[1]=] ]=
	{
		[ [=[itemId]=] ]=20001,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Available by default]=],
		[ [=[minLevel]=] ]=1,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[1]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[0]=]
		}
	},
	[ [=[2]=] ]=
	{
		[ [=[itemId]=] ]=20002,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Available by default]=],
		[ [=[minLevel]=] ]=2,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[2]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[0]=]
		}
	},
	[ [=[3]=] ]=
	{
		[ [=[itemId]=] ]=20003,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Available by default]=],
		[ [=[minLevel]=] ]=3,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[3]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[0]=]
		}
	},
	[ [=[4]=] ]=
	{
		[ [=[itemId]=] ]=20004,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[1st place in level 3]=],
		[ [=[minLevel]=] ]=4,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[4]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[3]=],[=[1]=]
		}
	},
	[ [=[5]=] ]=
	{
		[ [=[itemId]=] ]=20005,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Get 2 times first in level 4]=],
		[ [=[minLevel]=] ]=5,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[5]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[4]=],[=[2]=]
		}
	},
	[ [=[6]=] ]=
	{
		[ [=[itemId]=] ]=20006,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Get 3 times first in level 5]=],
		[ [=[minLevel]=] ]=6,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[6]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[5]=],[=[3]=]
		}
	},
	[ [=[7]=] ]=
	{
		[ [=[itemId]=] ]=20007,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Get 4 times first in level 6]=],
		[ [=[minLevel]=] ]=7,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[7]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[6]=],[=[4]=]
		}
	},
	[ [=[8]=] ]=
	{
		[ [=[itemId]=] ]=20008,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Get 5 times first in level 7]=],
		[ [=[minLevel]=] ]=8,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[8]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[7]=],[=[5]=]
		}
	},
	[ [=[9]=] ]=
	{
		[ [=[itemId]=] ]=20009,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Get 6 times first in level 8]=],
		[ [=[minLevel]=] ]=9,
		[ [=[guildScoreMax]=] ]=0,
		[ [=[effectName]=] ]=[=[9]=],
		[ [=[type]=] ]=[=[common]=],
		[ [=[conditionScoreLevelUp]=] ]=0,
		[ [=[condition]=] ]=
		{[=[8]=],[=[6]=]
		}
	},
	[ [=[10]=] ]=
	{
		[ [=[itemId]=] ]=20018,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[Available by default]=],
		[ [=[minLevel]=] ]=1,
		[ [=[guildScoreMax]=] ]=250000,
		[ [=[effectName]=] ]=[=[5]=],
		[ [=[type]=] ]=[=[mist]=],
		[ [=[conditionScoreLevelUp]=] ]=20,
		[ [=[condition]=] ]=
		{[=[7]=],[=[5]=]
		}
	},
	[ [=[11]=] ]=
	{
		[ [=[itemId]=] ]=20019,
		[ [=[conditionScoreLevelDown]=] ]=-20,
		[ [=[conditionDesc]=] ]=[=[Get 20 points on the 1st floor of the Misty Battlefield and upgrade to 2nd floor. If the score reaches -20 on this floor, then return to 1st floor.]=],
		[ [=[minLevel]=] ]=2,
		[ [=[guildScoreMax]=] ]=280000,
		[ [=[effectName]=] ]=[=[6]=],
		[ [=[type]=] ]=[=[mist]=],
		[ [=[conditionScoreLevelUp]=] ]=30,
		[ [=[condition]=] ]=
		{[=[7]=],[=[5]=]
		}
	},
	[ [=[12]=] ]=
	{
		[ [=[itemId]=] ]=20020,
		[ [=[conditionScoreLevelDown]=] ]=-20,
		[ [=[conditionDesc]=] ]=[=[Get 30 points on the 2nd floor of the Misty Battlefield and upgrade to 3rd floor. If the score reaches -20 on this layer, then return to 2nd floor.]=],
		[ [=[minLevel]=] ]=3,
		[ [=[guildScoreMax]=] ]=320000,
		[ [=[effectName]=] ]=[=[7]=],
		[ [=[type]=] ]=[=[mist]=],
		[ [=[conditionScoreLevelUp]=] ]=30,
		[ [=[condition]=] ]=
		{[=[7]=],[=[5]=]
		}
	},
	[ [=[13]=] ]=
	{
		[ [=[itemId]=] ]=20021,
		[ [=[conditionScoreLevelDown]=] ]=-20,
		[ [=[conditionDesc]=] ]=[=[Get 30 points on the 3rd floor of the Misty Battlefield and upgrade to 4th floor. If the score reaches -20 on this layer, then return to 3rd floor.]=],
		[ [=[minLevel]=] ]=4,
		[ [=[guildScoreMax]=] ]=350000,
		[ [=[effectName]=] ]=[=[8]=],
		[ [=[type]=] ]=[=[mist]=],
		[ [=[conditionScoreLevelUp]=] ]=40,
		[ [=[condition]=] ]=
		{[=[7]=],[=[5]=]
		}
	},
	[ [=[14]=] ]=
	{
		[ [=[itemId]=] ]=20022,
		[ [=[conditionScoreLevelDown]=] ]=-20,
		[ [=[conditionDesc]=] ]=[=[Get 40 points on the 4th floor of the Misty Battlefield and upgrade to 5th floor. If the score reaches -20 on this layer, then return to 4th floor.]=],
		[ [=[minLevel]=] ]=5,
		[ [=[guildScoreMax]=] ]=380000,
		[ [=[effectName]=] ]=[=[9]=],
		[ [=[type]=] ]=[=[mist]=],
		[ [=[conditionScoreLevelUp]=] ]=40,
		[ [=[condition]=] ]=
		{[=[7]=],[=[5]=]
		}
	}
}
return var