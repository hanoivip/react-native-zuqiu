local null = nil
local var = 
{
	[ [=[1]=] ]=
	{
		[ [=[itemId]=] ]=20001,
		[ [=[conditionScoreLevelDown]=] ]=0,
		[ [=[conditionDesc]=] ]=[=[พร้อมใช้งานโดยค่าเริ่มต้น]=],
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
		[ [=[conditionDesc]=] ]=[=[พร้อมใช้งานโดยค่าเริ่มต้น]=],
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
		[ [=[conditionDesc]=] ]=[=[พร้อมใช้งานโดยค่าเริ่มต้น]=],
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
		[ [=[conditionDesc]=] ]=[=[อันดับที่ 1 ในระดับ 3]=],
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
		[ [=[conditionDesc]=] ]=[=[รับ 2 ครั้งแรกในระดับ 4]=],
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
		[ [=[conditionDesc]=] ]=[=[ได้รับ 3 ครั้งแรกในระดับ 5]=],
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
		[ [=[conditionDesc]=] ]=[=[รับ 4 ครั้งแรกในระดับ 6]=],
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
		[ [=[conditionDesc]=] ]=[=[รับ 5 ครั้งแรกในระดับ 7]=],
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
		[ [=[conditionDesc]=] ]=[=[ได้รับ 6 ครั้งแรกในระดับ 8]=],
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
		[ [=[conditionDesc]=] ]=[=[พร้อมใช้งานโดยค่าเริ่มต้น]=],
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
		[ [=[conditionDesc]=] ]=[=[รับ 20 คะแนนบนชั้น 1 ของ Misty Battlefield และอัปเกรดเป็นชั้น 2 หากคะแนนถึง -20 ในชั้นนี้ให้กลับไปที่ชั้น 1]=],
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
		[ [=[conditionDesc]=] ]=[=[รับ 30 คะแนนบนชั้น 2 ของ Misty Battlefield และอัพเกรดเป็นชั้น 3 หากคะแนนถึง -20 ในเลเยอร์นี้ให้กลับไปที่ชั้น 2]=],
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
		[ [=[conditionDesc]=] ]=[=[รับ 30 คะแนนบนชั้น 3 ของ Misty Battlefield และอัพเกรดเป็นชั้น 4 หากคะแนนถึง -20 ในเลเยอร์นี้ให้กลับไปที่ชั้น 3]=],
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
		[ [=[conditionDesc]=] ]=[=[รับ 40 คะแนนบนชั้น 4 ของ Misty Battlefield และอัพเกรดเป็นชั้น 5 หากคะแนนถึง -20 ในเลเยอร์นี้ให้กลับไปที่ชั้น 4]=],
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