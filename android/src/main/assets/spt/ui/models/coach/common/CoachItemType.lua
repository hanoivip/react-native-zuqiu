-- local CoachItemType = require("ui.models.coach.common.CoachItemType")

local CoachItemType = {}

-- 类型配置在CoachItem表中
CoachItemType.PlayerTalentSkillBook = 1 -- 特性书
CoachItemType.PlayerTalentFunctionalityItem = 2 -- 特性道具
CoachItemType.CoachTacticsItem = 3 -- 阵型/战术道具
CoachItemType.AssistCoachInfo = 4 -- 助教情报
CoachItemType.Normal = 5 -- 教练礼包

-- 阵型/战术升级书类型
-- 配置在CoachTacticsItem表中
CoachItemType.TacticItemType = {
    Tactic = 1,
    Formation = 2
}

-- 特性道具替换状态
CoachItemType.ItemChooseType = {
    Unload = 1,
    Replace = 2,
    Equip = 3,
}

-- 特性道具功能状态（1为锁定型道具，2为增加型道具，3为指定替换道具，4为选择替换道具）
CoachItemType.ItemFuncType = {
    Lock = 1,
    Add = 2,
    Replace = 3,
	Choose = 4,
}

-- 特性技能显示状态（1为正常状态，2为锁定状态，3为指定状态，4为可选择状态）
CoachItemType.SkillFuncType = {
	Normal = 1,
	Lock = 2,
	Appoint = 3,
	Choose = 4
}

-- 默认特性技能为10个
CoachItemType.SkillFeaturesNum = 10

return CoachItemType
