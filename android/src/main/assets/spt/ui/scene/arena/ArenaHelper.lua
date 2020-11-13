local ArenaHelper = {}

-- 竞技场星星位置
ArenaHelper.GetStarPos = 
{
    ['1'] = 
    {   
        {x = 0, y = 0 },
    },
    ['2'] = 
    {   
        {x = -48, y = -16 },
        {x = 48, y = -16 },
    },
    ['3'] = 
    {   
        {x = -80, y = -32 },
        {x = 0, y = 0 },
        {x = 80, y = -32 },
    },
    ['4'] = 
    {   
        {x = -96, y = -32 },
        {x = -32, y = -12 },
        {x = 32, y = -12 },
        {x = 96, y = -32 },
    },
    ['5'] = 
    {   
        {x = -96, y = -32 },
        {x = -48, y = -16 },
        {x = 0, y = 0 },
        {x = 48, y = -16 },
        {x = 96, y = -32 },
    },
}

-- 竞技场小段位位置显示
ArenaHelper.GetMinStagePos =
{
    ['1'] =
    {
        x = 0,
        y = -66.5
    },
    ['2'] =
    {
        x = 0,
        y = -81.46
    },
    ['3'] =
    {
        x = 0,
        y = -81.46
    },
    ['4'] =
    {
        x = 0,
        y = -76.9
    },
    ['5'] =
    {
        x = 0,
        y = -76.9
    },
    ['6'] =
    {
        x = 10.7,
        y = -100
    },
}

-- 竞技场小段位希腊数字显示
ArenaHelper.GetMinStageNum =
{
    "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"
}

-- 球队段位
ArenaHelper.StageType =
{
    RookieStage = 1,
    StandardStage = 2,
    EliteStage = 3,
    TrumpStage = 4,
    LegendStage = 5,
    StoryStage = 6,
}
-- 球队风云段位最低星星
ArenaHelper.MinStoryStar = 84

-- 好友详情中显示竞技场星星位置
ArenaHelper.GetStarPos4Friend = 
{
    ['1'] = 
    {   
        {x = 0, y = 119 },
    },
    ['2'] = 
    {   
        {x = -40, y = 99 },
        {x = 38, y = 99 },
    },
    ['3'] = 
    {   
        {x = -77, y = 73 },
        {x = 0, y = 119 },
        {x = 73, y = 73 },
    },
    ['4'] = 
    {   
        {x = -77, y = 73 },
        {x = -40, y = 99 },
        {x = 38, y = 99 },
        {x = 73, y = 73 },
    },
    ['5'] = 
    {   
        {x = -77, y = 73 },
        {x = -40, y = 99 },
        {x = 0, y = 119 },
        {x = 38, y = 99 },
        {x = 73, y = 73 },
    },
}

return ArenaHelper
