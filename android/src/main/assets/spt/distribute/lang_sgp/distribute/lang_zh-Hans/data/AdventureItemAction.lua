local null = nil
local var = 
{
	[ [=[1001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内天气变为晴天吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=2001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，天气卡]=]
	},
	[ [=[1002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内天气变为雨天吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=2002,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，天气卡]=]
	},
	[ [=[1003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内天气变为雪天吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=2003,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，天气卡]=]
	},
	[ [=[1004]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内天气变为大风天吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=2004,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，天气卡]=]
	},
	[ [=[1005]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内天气变为大雾天吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=2005,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，天气卡]=]
	},
	[ [=[1006]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内天气变为沙尘天吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=2006,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，天气卡]=]
	},
	[ [=[1007]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内天气变为酷热天吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=2007,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，天气卡]=]
	},
	[ [=[1008]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，通过这片海洋吗？]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=6001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，腮囊草]=]
	},
	[ [=[1009]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，免费通过该收费站吗？]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=6002,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，豪门通行证]=]
	},
	[ [=[1010]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，免费通过该碎石地块吗？]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=6003,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，挖掘机]=]
	},
	[ [=[1011]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，清空自身所有负面Buff吗？]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=7001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，健康药剂]=]
	},
	[ [=[1012]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，探测该区域是否有宝物吗？]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=4001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，金属探测器]=]
	},
	[ [=[1013]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用全员全属性-5%，削弱该玩家的战力吗？]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=8001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，豪门小道报]=]
	},
	[ [=[1014]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用全员全属性-10%，削弱该玩家的战力吗？]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=8001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，豪门小道报]=]
	},
	[ [=[1015]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用全员全属性-15%，削弱该玩家的战力吗？]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=8001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，豪门小道报]=]
	},
	[ [=[1200]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[道具使用成功！]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[通用弹白条提示]=]
	},
	[ [=[1201]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[顺利通过海洋，继续前进！]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[鳃囊草弹白条提示]=]
	},
	[ [=[1202]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[顺利通过收费站，继续前进！]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[通行证弹白条提示]=]
	},
	[ [=[1203]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[碎石清理完毕，继续前进！]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[挖掘机弹白条提示]=]
	},
	[ [=[1204]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已清除所有负面BUFF]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[健康药剂弹白条提示]=]
	},
	[ [=[1205]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[照明成功!]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[照明弹弹白条提示]=]
	},
	[ [=[1206]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为晴天]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[晴天卡弹白条提示]=]
	},
	[ [=[1207]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为雨天]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[雨天卡弹白条提示]=]
	},
	[ [=[1208]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为雪天]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[雪天卡弹白条提示]=]
	},
	[ [=[1209]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为大风天]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[大风卡弹白条提示]=]
	},
	[ [=[1210]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为大雾天]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[大雾卡弹白条提示]=]
	},
	[ [=[1211]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为沙尘天]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[沙尘卡弹白条提示]=]
	},
	[ [=[1212]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为酷热天]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[酷热卡弹白条提示]=]
	},
	[ [=[1213]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:日耀]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:日耀弹白条提示]=]
	},
	[ [=[1214]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:月影]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:月影弹白条提示]=]
	},
	[ [=[1215]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:星瀚]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:星瀚弹白条提示]=]
	},
	[ [=[1216]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:地煞]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:地煞弹白条提示]=]
	},
	[ [=[1217]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:天罚]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:天罚弹白条提示]=]
	},
	[ [=[1218]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:混沌]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:混沌弹白条提示]=]
	},
	[ [=[1219]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:光佑]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:光佑弹白条提示]=]
	},
	[ [=[1220]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:湮火]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:湮火弹白条提示]=]
	},
	[ [=[1221]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:宙海]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:宙海弹白条提示]=]
	},
	[ [=[1222]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[已切换为星象:宸变]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogToast]=],
		[ [=[desc]=] ]=[=[星象卡:宸变弹白条提示]=]
	},
	[ [=[1301]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[探测器毫无反应，看来此处并无宝物]=],
			[ [=[title]=] ]=[=[探测提示]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[DialogReward]=],
		[ [=[desc]=] ]=[=[有奖励弹奖励，没奖励显示配置的参数弹提示继续]=]
	},
	[ [=[1401]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为日耀吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20001,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:日耀]=]
	},
	[ [=[1402]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为月影吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20002,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:月影]=]
	},
	[ [=[1403]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为星瀚吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20003,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:星瀚]=]
	},
	[ [=[1404]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为地煞吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20004,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:地煞]=]
	},
	[ [=[1405]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为天罚吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20005,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:天罚]=]
	},
	[ [=[1406]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为混沌吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20006,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:混沌]=]
	},
	[ [=[1407]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为光佑吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20007,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:光佑]=]
	},
	[ [=[1408]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为湮火吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20008,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:湮火]=]
	},
	[ [=[1409]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为宙海吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20009,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:宙海]=]
	},
	[ [=[1410]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，使当前周期内星象变为宸变吗？（当前周期剩余{2}回合）]=],
			[ [=[{2}]=] ]=[=[_cycleLeft]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[title]=] ]=[=[提示]=]
		},
		[ [=[nextAction]=] ]=20010,
		[ [=[actionType]=] ]=[=[DialogConfirm]=],
		[ [=[desc]=] ]=[=[对话框提示，星象卡:宸变]=]
	},
	[ [=[2001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1206,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[切换天气至晴天]=]
	},
	[ [=[2002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1207,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[切换天气至雨天]=]
	},
	[ [=[2003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1208,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[切换天气至雪天]=]
	},
	[ [=[2004]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1209,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[切换天气至大风天]=]
	},
	[ [=[2005]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1210,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[切换天气至大雾天]=]
	},
	[ [=[2006]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1211,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[切换天气至沙尘天]=]
	},
	[ [=[2007]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1212,
		[ [=[actionType]=] ]=[=[WeatherChange]=],
		[ [=[desc]=] ]=[=[切换天气至酷热天]=]
	},
	[ [=[3001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[TreasureMap]=],
		[ [=[desc]=] ]=[=[查看藏宝图]=]
	},
	[ [=[3101]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[MysticHint]=],
		[ [=[desc]=] ]=[=[查看神秘指令]=]
	},
	[ [=[4001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1301,
		[ [=[actionType]=] ]=[=[TreasureOpen]=],
		[ [=[desc]=] ]=[=[金属探测器行为，调用adventure/openTreasure]=]
	},
	[ [=[6001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1201,
		[ [=[actionType]=] ]=[=[AdvTrigger]=],
		[ [=[desc]=] ]=[=[修改地图事件状态：海洋鳃囊草]=]
	},
	[ [=[6002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1202,
		[ [=[actionType]=] ]=[=[AdvTrigger]=],
		[ [=[desc]=] ]=[=[修改地图事件状态：收费站通行证]=]
	},
	[ [=[6003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1203,
		[ [=[actionType]=] ]=[=[AdvTrigger]=],
		[ [=[desc]=] ]=[=[修改地图事件状态：碎石坍塌挖掘机]=]
	},
	[ [=[7001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1204,
		[ [=[actionType]=] ]=[=[BuffChange]=],
		[ [=[desc]=] ]=[=[修改自身buff：健康药剂清楚自身所有debuff]=]
	},
	[ [=[8001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1200,
		[ [=[actionType]=] ]=[=[WeakenOpponent]=],
		[ [=[desc]=] ]=[=[削弱对手战力]=]
	},
	[ [=[9001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，照亮该区域吗？]=],
			[ [=[title]=] ]=[=[提示]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[3]=]
		},
		[ [=[nextAction]=] ]=1205,
		[ [=[actionType]=] ]=[=[FlashBang]=],
		[ [=[desc]=] ]=[=[威力照明弹]=]
	},
	[ [=[9002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，照亮该区域吗？]=],
			[ [=[title]=] ]=[=[提示]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[1]=]
		},
		[ [=[nextAction]=] ]=1205,
		[ [=[actionType]=] ]=[=[FlashBang]=],
		[ [=[desc]=] ]=[=[照明弹]=]
	},
	[ [=[9003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[msg]=] ]=[=[确定使用{1}x1，照亮该区域吗？]=],
			[ [=[title]=] ]=[=[提示]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[2]=]
		},
		[ [=[nextAction]=] ]=1205,
		[ [=[actionType]=] ]=[=[FlashBang]=],
		[ [=[desc]=] ]=[=[加强照明弹]=]
	},
	[ [=[10001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[title]=] ]=[=[提示]=],
			[ [=[msg_over]=] ]=[=[提示：请仔细观察该区域内的事件后再结束查看，结束查看后迷雾将会重新覆盖。]=],
			[ [=[msg]=] ]=[=[确定使用{1}x1，查看该迷雾区域下的事件吗？]=],
			[ [=[title_over]=] ]=[=[提示]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[1]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[Glasses]=],
		[ [=[desc]=] ]=[=[x线透视镜:1x1]=]
	},
	[ [=[10002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[title]=] ]=[=[提示]=],
			[ [=[msg_over]=] ]=[=[提示：请仔细观察该区域内的事件后再结束查看，结束查看后迷雾将会重新覆盖。]=],
			[ [=[msg]=] ]=[=[确定使用{1}x1，查看该迷雾区域下的事件吗？]=],
			[ [=[title_over]=] ]=[=[提示]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[2]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[Glasses]=],
		[ [=[desc]=] ]=[=[α线透视镜:2x2]=]
	},
	[ [=[10003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
			[ [=[title]=] ]=[=[提示]=],
			[ [=[msg_over]=] ]=[=[提示：请仔细观察该区域内的事件后再结束查看，结束查看后迷雾将会重新覆盖。]=],
			[ [=[msg]=] ]=[=[确定使用{1}x1，查看该迷雾区域下的事件吗？]=],
			[ [=[title_over]=] ]=[=[提示]=],
			[ [=[{1}]=] ]=[=[_name]=],
			[ [=[size]=] ]=[=[3]=]
		},
		[ [=[nextAction]=] ]=0,
		[ [=[actionType]=] ]=[=[Glasses]=],
		[ [=[desc]=] ]=[=[24k钛金透视镜:3x3]=]
	},
	[ [=[20001]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1213,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象日耀]=]
	},
	[ [=[20002]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1214,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象月影]=]
	},
	[ [=[20003]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1215,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象星瀚]=]
	},
	[ [=[20004]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1216,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象地煞]=]
	},
	[ [=[20005]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1217,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象天罚]=]
	},
	[ [=[20006]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1218,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象混沌]=]
	},
	[ [=[20007]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1219,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象光佑]=]
	},
	[ [=[20008]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1220,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象湮火]=]
	},
	[ [=[20009]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1221,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象宙海]=]
	},
	[ [=[20010]=] ]=
	{
		[ [=[actionParam]=] ]=
		{
		},
		[ [=[nextAction]=] ]=1222,
		[ [=[actionType]=] ]=[=[AstrologyChange]=],
		[ [=[desc]=] ]=[=[切换至星象宸变]=]
	}
}
return var