local null = nil
local var = 
{
	[ [=[ArtificialLong]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，客队拦截属性降低]=],
		[ [=[name]=] ]=[=[人工长草]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=
		{[=[steal]=]
		},
		[ [=[condition]=] ]=
		{[=[League]=],[=[3]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[ArtificialShort]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，客队抢断属性降低]=],
		[ [=[name]=] ]=[=[人工短草]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=
		{[=[intercept]=]
		},
		[ [=[condition]=] ]=
		{[=[League]=],[=[3]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[Audience]=] ]=
	{
		[ [=[fuction]=] ]=[=[capacity]=],
		[ [=[fuctionDesc]=] ]=[=[提高体育场容纳的观众人数，从而提升联赛主场收入。]=],
		[ [=[name]=] ]=[=[观众席]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=0
	},
	[ [=[Board]=] ]=
	{
		[ [=[fuction]=] ]=[=[price2]=],
		[ [=[fuctionDesc]=] ]=[=[改善电子计分板提升球迷满意度，提升门票售价，从而提升联赛主场收入。]=],
		[ [=[name]=] ]=[=[计分板]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=0
	},
	[ [=[Common]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[没有特殊效果。]=],
		[ [=[name]=] ]=[=[普通草]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=0
	},
	[ [=[Fog]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，双方#等级降低]=],
		[ [=[name]=] ]=[=[大雾]=],
		[ [=[skillAffect]=] ]=
		{[=[C01]=],[=[D02]=]
		},
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=
		{[=[League]=],[=[2]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[Heat]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，双方#等级降低]=],
		[ [=[name]=] ]=[=[酷热]=],
		[ [=[skillAffect]=] ]=
		{[=[C03]=],[=[D03]=]
		},
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=
		{[=[League]=],[=[3]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[Lighting]=] ]=
	{
		[ [=[fuction]=] ]=[=[price1]=],
		[ [=[fuctionDesc]=] ]=[=[改善照明设备提升球迷满意度，提升门票价格，从而提升联赛主场收入。]=],
		[ [=[name]=] ]=[=[照明设备]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=0
	},
	[ [=[Mixed]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，客队全属性降低]=],
		[ [=[name]=] ]=[=[混合草]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=
		{[=[dribble]=],[=[pass]=],[=[intercept]=],[=[steal]=],[=[shoot]=]
		},
		[ [=[condition]=] ]=
		{[=[League]=],[=[1]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[NatureLong]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，客队传球属性降低]=],
		[ [=[name]=] ]=[=[天然长草]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=
		{[=[pass]=]
		},
		[ [=[condition]=] ]=
		{[=[League]=],[=[2]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[NatureShort]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，客队带球属性降低]=],
		[ [=[name]=] ]=[=[天然短草]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=
		{[=[dribble]=]
		},
		[ [=[condition]=] ]=
		{[=[League]=],[=[2]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[Parking]=] ]=
	{
		[ [=[fuction]=] ]=[=[attendance]=],
		[ [=[fuctionDesc]=] ]=[=[提供更多的停车位，增加主场比赛的上座率，从而提升联赛主场收入。]=],
		[ [=[name]=] ]=[=[停车场]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=0
	},
	[ [=[Rain]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，双方#等级降低]=],
		[ [=[name]=] ]=[=[雨天]=],
		[ [=[skillAffect]=] ]=
		{[=[D01]=],[=[B01]=],[=[C04]=]
		},
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=
		{[=[League]=],[=[1]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[Sand]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，双方#等级降低]=],
		[ [=[name]=] ]=[=[沙尘]=],
		[ [=[skillAffect]=] ]=
		{[=[C02]=],[=[D04]=]
		},
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=
		{[=[League]=],[=[3]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[Scout]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[解锁更多转会市场球员，解锁转会市场额外栏位。]=],
		[ [=[name]=] ]=[=[球探社]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=1
	},
	[ [=[Snow]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，双方#等级降低]=],
		[ [=[name]=] ]=[=[雪天]=],
		[ [=[skillAffect]=] ]=
		{[=[B02]=],[=[F02]=],[=[F03]=]
		},
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=
		{[=[League]=],[=[1]=]
		},
		[ [=[initLvl]=] ]=1
	},
	[ [=[Stadium]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[解锁更高级别的观众席、照明设备、计分板、零售商店、停车场。]=],
		[ [=[name]=] ]=[=[体育场]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=1
	},
	[ [=[Store]=] ]=
	{
		[ [=[fuction]=] ]=[=[priceExtra]=],
		[ [=[fuctionDesc]=] ]=[=[出售球队周边产品，额外增加联赛主场收入。]=],
		[ [=[name]=] ]=[=[零售商店]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=0
	},
	[ [=[SunShine]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[没有特殊效果。]=],
		[ [=[name]=] ]=[=[晴天]=],
		[ [=[skillAffect]=] ]=[=[]=],
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=[=[]=],
		[ [=[initLvl]=] ]=0
	},
	[ [=[Wind]=] ]=
	{
		[ [=[fuction]=] ]=[=[]=],
		[ [=[fuctionDesc]=] ]=[=[主场对战时，双方#等级降低]=],
		[ [=[name]=] ]=[=[大风]=],
		[ [=[skillAffect]=] ]=
		{[=[D07]=],[=[D06]=],[=[D05]=]
		},
		[ [=[attrAffect]=] ]=[=[]=],
		[ [=[condition]=] ]=
		{[=[League]=],[=[2]=]
		},
		[ [=[initLvl]=] ]=1
	}
}
return var