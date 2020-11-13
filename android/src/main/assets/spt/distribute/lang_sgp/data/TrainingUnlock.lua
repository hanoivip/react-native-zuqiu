local null = nil
local var = 
{
	[ [=[1]=] ]=
	{
		[ [=[name]=] ]=[=[Chongming Island Training Base]=],
		[ [=[skillLvConditionText]=] ]=[=[The player's skill level average is at least Lv. 3]=],
		[ [=[skillLvCondition]=] ]=3,
		[ [=[unlockQuality]=] ]=
		{[=[3]=],[=[4]=],[=[5]=],[=[6]=],[=[7]=],[=[8]=]
		}
	},
	[ [=[2]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at Chongming Island Training Base]=],
		[ [=[name]=] ]=[=[Amsterdam Tokem Training Base]=],
		[ [=[skillLvConditionText]=] ]=[=[The player's skill level average is at least Lv. 5]=],
		[ [=[correlationConditionText]=] ]=[=[Partner Player %s, %s unlocks Chongming Island Training Base]=],
		[ [=[skillLvCondition]=] ]=5,
		[ [=[unlockQuality]=] ]=
		{[=[3]=],[=[4]=],[=[5]=],[=[6]=],[=[7]=],[=[8]=]
		},
		[ [=[correlationCondition]=] ]=1,
		[ [=[trainingCondition]=] ]=
		{
			[ [=[1]=] ]=[=[4]=]
		}
	},
	[ [=[3]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at Amsterdam Tokem Training Base]=],
		[ [=[name]=] ]=[=[Paris Claire Academy Training Base]=],
		[ [=[chemicalConditionText]=] ]=[=[Activate 1 chemical reaction for this player]=],
		[ [=[correlationConditionText]=] ]=[=[Partner Player %s, %s unlocks Amsterdam Tokem Training Base]=],
		[ [=[chemicalCondition]=] ]=1,
		[ [=[unlockQuality]=] ]=
		{[=[4]=],[=[5]=],[=[6]=],[=[7]=],[=[8]=]
		},
		[ [=[correlationCondition]=] ]=2,
		[ [=[trainingCondition]=] ]=
		{
			[ [=[2]=] ]=[=[4]=]
		}
	},
	[ [=[4]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at Paris Claire Academy Training Base]=],
		[ [=[medalConditionText]=] ]=[=[Equip 2 SS Badges]=],
		[ [=[name]=] ]=[=[Kearney #4 Training Base]=],
		[ [=[skillLvConditionText]=] ]=[=[The player's skill level average is at least Lv. 12]=],
		[ [=[skillLvCondition]=] ]=12,
		[ [=[unlockQuality]=] ]=
		{[=[4]=],[=[5]=],[=[6]=],[=[7]=],[=[8]=]
		},
		[ [=[throughCondition]=] ]=2,
		[ [=[throughConditionText]=] ]=[=[Complete Rebirth 2 times with this player]=],
		[ [=[trainingCondition]=] ]=
		{
			[ [=[3]=] ]=[=[4]=]
		},
		[ [=[medalCondition]=] ]=
		{
			[ [=[5]=] ]=[=[2]=]
		}
	},
	[ [=[5]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at Kearney #4 Training Base]=],
		[ [=[name]=] ]=[=[Milanello Training Base]=],
		[ [=[chemicalConditionText]=] ]=[=[Activate 3 chemical reactions for this player]=],
		[ [=[correlationConditionText]=] ]=[=[Partner Player %s, %s unlocks Kearney #4 Training Base]=],
		[ [=[chemicalCondition]=] ]=3,
		[ [=[unlockQuality]=] ]=
		{[=[5]=],[=[6]=],[=[7]=],[=[8]=]
		},
		[ [=[correlationCondition]=] ]=4,
		[ [=[trainingCondition]=] ]=
		{
			[ [=[4]=] ]=[=[4]=]
		}
	},
	[ [=[6]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at Milanello Training Base]=],
		[ [=[medalConditionText]=] ]=[=[Equip 3 SS Badges]=],
		[ [=[name]=] ]=[=[London Deepblue Center Training Base]=],
		[ [=[skillLvConditionText]=] ]=[=[The player's skill level average is at least Lv. 18]=],
		[ [=[skillLvCondition]=] ]=18,
		[ [=[unlockQuality]=] ]=
		{[=[5]=],[=[6]=],[=[7]=],[=[8]=]
		},
		[ [=[throughCondition]=] ]=3,
		[ [=[throughConditionText]=] ]=[=[Complete Rebirth 3 times with this player]=],
		[ [=[trainingCondition]=] ]=
		{
			[ [=[5]=] ]=[=[4]=]
		},
		[ [=[medalCondition]=] ]=
		{
			[ [=[5]=] ]=[=[3]=]
		}
	},
	[ [=[7]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at London Deepblue Center Training Base]=],
		[ [=[name]=] ]=[=[Trafford Carrington Training Base]=],
		[ [=[chemicalConditionText]=] ]=[=[Activate 4 chemical reactions for this player]=],
		[ [=[correlationConditionText]=] ]=[=[Partner Player %s, %s unlocks London Deepblue Center Training Base]=],
		[ [=[chemicalCondition]=] ]=4,
		[ [=[unlockQuality]=] ]=
		{[=[6]=],[=[7]=],[=[8]=]
		},
		[ [=[correlationCondition]=] ]=6,
		[ [=[trainingCondition]=] ]=
		{
			[ [=[6]=] ]=[=[4]=]
		}
	},
	[ [=[8]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at Trafford Carrington Training Base]=],
		[ [=[medalConditionText]=] ]=[=[Equip 4 SS Badges]=],
		[ [=[name]=] ]=[=[La Fabrica Training Base]=],
		[ [=[potentialConditionText]=] ]=[=[Train the player's Potential(reaches 0)]=],
		[ [=[unlockQuality]=] ]=
		{[=[6]=],[=[7]=],[=[8]=]
		},
		[ [=[throughCondition]=] ]=4,
		[ [=[potentialCondition]=] ]=1,
		[ [=[throughConditionText]=] ]=[=[Complete Rebirth 4 times with this player]=],
		[ [=[trainingCondition]=] ]=
		{
			[ [=[7]=] ]=[=[4]=]
		},
		[ [=[medalCondition]=] ]=
		{
			[ [=[5]=] ]=[=[4]=]
		}
	},
	[ [=[9]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at La Fabrica Training Base]=],
		[ [=[name]=] ]=[=[Manchester Academy Training Base]=],
		[ [=[chemicalConditionText]=] ]=[=[Activate 5 chemical reactions for this player]=],
		[ [=[correlationConditionText]=] ]=[=[Partner Player %s, %s unlocks La Fabrica Training Base]=],
		[ [=[chemicalCondition]=] ]=5,
		[ [=[unlockQuality]=] ]=
		{[=[7]=],[=[8]=]
		},
		[ [=[correlationCondition]=] ]=8,
		[ [=[trainingCondition]=] ]=
		{
			[ [=[8]=] ]=[=[4]=]
		}
	},
	[ [=[10]=] ]=
	{
		[ [=[trainingConditionText]=] ]=[=[Complete the 4th training task at Manchester Academy Training Base]=],
		[ [=[medalConditionText]=] ]=[=[Equip 5 SS Badges]=],
		[ [=[name]=] ]=[=[Masia Football Village]=],
		[ [=[skillLvConditionText]=] ]=[=[The player's skill level average is at least Lv. 32]=],
		[ [=[skillLvCondition]=] ]=32,
		[ [=[unlockQuality]=] ]=
		{[=[7]=],[=[8]=]
		},
		[ [=[throughCondition]=] ]=5,
		[ [=[throughConditionText]=] ]=[=[Complete Rebirth 5 times with this player]=],
		[ [=[trainingCondition]=] ]=
		{
			[ [=[9]=] ]=[=[4]=]
		},
		[ [=[medalCondition]=] ]=
		{
			[ [=[5]=] ]=[=[5]=]
		}
	}
}
return var