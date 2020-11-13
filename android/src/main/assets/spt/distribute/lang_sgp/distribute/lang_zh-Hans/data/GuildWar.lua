local null = nil
local var = 
{
	[ [=[1]=] ]=
	{
		[ [=[itemId]=] ]=20001,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[默认开启]=],
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
		[ [=[conditionDesc]=] ]=[=[默认开启]=],
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
		[ [=[conditionDesc]=] ]=[=[默认开启]=],
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
		[ [=[conditionDesc]=] ]=[=[在层级3中获得1次第一]=],
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
		[ [=[conditionDesc]=] ]=[=[在层级4中获得2次第一]=],
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
		[ [=[conditionDesc]=] ]=[=[在层级5中获得3次第一]=],
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
		[ [=[conditionDesc]=] ]=[=[在层级6中获得4次第一]=],
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
		[ [=[conditionDesc]=] ]=[=[在层级7中获得5次第一]=],
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
		[ [=[conditionDesc]=] ]=[=[在层级8中获得6次第一]=],
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
		[ [=[conditionDesc]=] ]=[=[默认开启]=],
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
		[ [=[conditionDesc]=] ]=[=[在迷雾战场1层获得20分升级为2层，在该层积分达到-20则重新降回1层。]=],
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
		[ [=[conditionDesc]=] ]=[=[在迷雾战场2层获得30分升级为3层，在该层积分达到-20则重新降回2层。]=],
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
		[ [=[conditionDesc]=] ]=[=[在迷雾战场3层获得30分升级为4层，在该层积分达到-20则重新降回3层。]=],
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
		[ [=[conditionDesc]=] ]=[=[在迷雾战场4层获得40分升级为5层，在该层积分达到-20则重新降回4层。]=],
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