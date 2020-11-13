local CoachMission = require("data.CoachMission")
local CoachMissionItem = require("data.CoachMissionItem")

local CoachTaskHelper = {}

-- 任务品质对应的背景图名字
CoachTaskHelper.BG = {
    "Quality_BG_1",
    "Quality_BG_1",
    "Quality_BG_2",
    "Quality_BG_2",
    "Quality_BG_3",
    "Quality_BG_3",
    "Quality_BG_4",
    "Quality_BG_4",
}

function CoachTaskHelper.CombineReward(rewardList)
    local contents = {}
    for i, v in ipairs(rewardList) do
        local missionItemData = clone(CoachMissionItem[tostring(v)])
        local tempContents = missionItemData.contents
        for k, contentValue in pairs(tempContents) do
            local valueType = type(contentValue)
            if valueType == "table" then
                if not contents[k] then
                    contents[k] = {}
                end
                for index, itemVale in ipairs(contentValue) do
                    local itemId = itemVale.id
                    local itemNum = itemVale.num
                    local isNotExist = true 
                    for tKey, tValue in ipairs(contents[k]) do
                        local tItemId = tValue.id
                        local tItemNum = tValue.num
                        if itemId == tItemId then
                            tValue.num = tItemNum + itemNum
                            isNotExist = false
                            break
                        end
                    end
                    if isNotExist then
                        table.insert(contents[k], itemVale)
                    end
                end
            end

            if valueType == "number" then
                if not contents[k] then
                    contents[k] = 0
                end
                contents[k] = contents[k] + contentValue
            end
        end
    end
    return contents
end

-- 执教任务要求的详细类型
CoachTaskHelper.Condition = {
    ["nation"] = "Nation",  -- 国家需求nation
    ["position"] = "Position",  -- 位置需求position
    ["quality"] = "Quality",  -- 球员品质quality
    ["upgrade"] = "Upgrade",  -- upgrade进阶
    ["skill"] = "Skill",  -- 技能强化（技能为自身技能）skill
    ["Power"] = "Power",  -- 战力需求Power
    ["ascend"] = "Ascend",  -- 转生要求ascend
    ["TrainingBase"] = "TrainingBase",  -- 特训要求TrainingBase
}

-- 任务基础配置表
CoachTaskHelper.CoachMissionConfig = CoachMission["1"]

-- 文字标题显示按照（来自“类型1”“类型2”的执教邀请）
CoachTaskHelper.NameType = {
    ["FirstType"] = 1,
    ["SecondType"] = 2
}

return CoachTaskHelper
