-- local LegendRoadImproveType = require("ui.models.legendRoad.LegendRoadImproveType")

-- 传奇之路解锁小关卡增益效果
-- 详见LegendRoadImprove
local LegendRoadImproveType = {
    Attr_All = 1, -- 全属性增加
    Attr_Train = 2, -- 潜力点增加
    Attr_Single = 3, -- 单属性增加
    Skill_Single = 4, -- 单技能等级增加
    Skill_All = 5, -- 全技能等级增加(不包括贴纸)
    Paster_EX = 6, -- 会把当前使用月贴变成EX技能
    Skill_New = 7, -- 新技能
}

return LegendRoadImproveType