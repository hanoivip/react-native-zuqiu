-- local LimitType = require("ui.scene.itemList.LimitType")

local LimitType = {
    NoLimit = 0, -- 不限购
    DayLimit = 1, -- 每日限购
    ForeverLimit = 2, -- 活动或赛季，定义的周期内限购
    TimeLimit = 3, -- 限时，商店可购买时间内（绿茵征途）
    ExistLimit= 4, -- 黑市商人存在时间内（绿茵征途）
    PlayerLimit= 5, -- 永久购买限制
}

return LimitType
