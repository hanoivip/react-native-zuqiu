local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local CoachMainPageConfig = {}

-- tab 标签 key 代码调用  value 配表
CoachMainPageConfig.Tag = {
    ["CoachMission"] = "CoachMission",    -- 执教任务
    ["Market"] = "Market", -- 交易市场
    ["AssistantCoachInfomationGacha"] = "AssistantCoachInfomationGacha",    -- 助教情报
    ["AssistantCoachInfomationLibrary"] = "AssistantCoachInfomationLibrary",   -- 助教情报库
    ["AssistantCoachLibrary"] = "AssistantCoachLibrary", -- 助教候选库
    ["CoachBaseInfo"] = "CoachBaseInfo", -- 教练信息
    ["CoachNation"] = "CoachNation",  -- 执教经历
    ["CoachTalentSkill"] = "CoachTalentSkill",  -- 执教天赋
    ["CoachGuide"] = "CoachGuide",   -- 教练指导
    ["AssistantCoachSystem"] = "AssistantCoachSystem",    -- 助理教练
}

-- 功能开启
CoachMainPageConfig.OpenState = {
    [CoachMainPageConfig.Tag.CoachMission] = true,
    [CoachMainPageConfig.Tag.Market] = false,
    [CoachMainPageConfig.Tag.AssistantCoachInfomationGacha] = true,
    [CoachMainPageConfig.Tag.AssistantCoachInfomationLibrary] = true,
    [CoachMainPageConfig.Tag.AssistantCoachLibrary] = true,
    [CoachMainPageConfig.Tag.CoachBaseInfo] = true,
    [CoachMainPageConfig.Tag.CoachNation] = false,
    [CoachMainPageConfig.Tag.CoachTalentSkill] = true,
    [CoachMainPageConfig.Tag.CoachGuide] = true,
    [CoachMainPageConfig.Tag.AssistantCoachSystem] = true,
}

-- 等级开启
function CoachMainPageConfig.GetOpenStateByTag(tag, level)
    if not CoachMainPageConfig.OpenState[tag] then
        return false
    end
    local coachLvl = level
    if not coachLvl then
        local coachMainModel = CoachMainModel.new()
        coachLvl = tonumber(coachMainModel:GetCoachLevel())
    end
    for k,v in pairs(CoachBaseLevel) do
        local unlock = v.unlock
        if type(unlock) == "table" then
            for index, tagName in ipairs(unlock) do
                local lvl = tonumber(k)
                if tagName == tag and lvl <= coachLvl then
                    return true
                end
            end
        end
    end
end

return CoachMainPageConfig
