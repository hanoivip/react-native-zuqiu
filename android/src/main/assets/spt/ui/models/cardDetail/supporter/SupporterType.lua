-- local SupporterType = require("ui.models.cardDetail.supporter.SupporterType")
local SupporterType = {}

-- 是否使用助阵卡牌特训进度
SupporterType.StType =
{
	SelfCard = 0,    -- 使用本卡的进度
    SupportCard = 1, -- 使用助阵卡的进度
}

-- 是否使用助阵卡牌传奇之路进度
SupporterType.SlrType =
{
    SelfCard = 0,    -- 使用本卡的进度
    SupportCard = 1, -- 使用助阵卡的进度
}

return SupporterType