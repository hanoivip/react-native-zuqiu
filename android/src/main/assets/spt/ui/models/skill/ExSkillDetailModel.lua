local Model = require("ui.models.Model")

local ExSkillDetailModel = class(Model)

function ExSkillDetailModel:ctor(skillItemModel)
    self.staticData = skillItemModel.staticData
    self.skillLevel = skillItemModel:GetLevel()
    self.currentLevelStr = lang.transstr("current_level")
    self.nextLevelStr = lang.transstr("next_level")
    self.fullLevelStr = lang.transstr("skillDetail_tip3")

end

-- 技能描述
function ExSkillDetailModel:GetDesc()
    return self.staticData.desc
end

-- 获取技能的图片索引
function ExSkillDetailModel:GetIconIndex()
    return self.staticData.picIndex
end

-- 获取技能的名称
function ExSkillDetailModel:GetName()
    return self.staticData.skillName
end

-- 获取技能的等级
function ExSkillDetailModel:GetLevel()
    return self.skillLevel
end

-- 根据技能的等级获取技能的加成属性
function ExSkillDetailModel:GetRatesByLevel()
    local levelNum = "lvl" .. self.skillLevel
    return self.staticData[levelNum]
end

-- 获取当前技能等级标题
function ExSkillDetailModel:GetLevelTitle()
    return self.currentLevelStr .. "Lv." .. self.skillLevel
end

local function GetSkillValueAddition(level, staticData)
    local skillAddition = {}
    local baseLevelTable = staticData["lvlBase"]
    if baseLevelTable then -- 技能表优化
        local lvlImprove = staticData["lvlImprove"] or {}
        for k, value in ipairs(baseLevelTable) do
            local improveValue = lvlImprove[k] 
            if improveValue then 
                valuePlus = tonumber(value) + improveValue * (level - 1)
                table.insert(skillAddition, math.round(tonumber(valuePlus) * 100))
            end
        end
    end
    return skillAddition
end

-- 获取当前等级技能描述
function ExSkillDetailModel:GetDescByLevel()
    local desc2 = self.staticData.desc2

    local tempLevelNum = {}

    local skillAddition = GetSkillValueAddition(self.skillLevel, self.staticData)
    if next(skillAddition) then -- 技能表优化
        tempLevelNum = skillAddition
    else
        local levelNum = "lvl" .. self.skillLevel
        local levelNum = self.staticData[levelNum]
        if levelNum and type(levelNum) == "table" then
            for i,v in ipairs(levelNum) do
                table.insert(tempLevelNum, math.round(tonumber(v) * 100))
            end
        end
    end
    return string.format(desc2, unpack(tempLevelNum))
end


-- 获取下一等级技能标题
function ExSkillDetailModel:GetNextLevelTitle()
    local nextlvl = (tonumber(self.skillLevel) + 1)

    local levelNum = "lvl" .. nextlvl
    local levelNum = self.staticData[levelNum]

    local baseLevelTable = self.staticData["lvlBase"]
    if baseLevelTable then -- 技能表优化
        return self.nextLevelStr .. "Lv." .. nextlvl
    elseif levelNum and type(levelNum) == "table" then
        return self.nextLevelStr .. "Lv." .. nextlvl
    else
        return self.fullLevelStr
    end
end

-- 获取下一等级技能描述
function ExSkillDetailModel:GetDescByNextLevel()
    local desc2 = self.staticData.desc2
    local nextlvl = (tonumber(self.skillLevel) + 1)

    local skillAddition = GetSkillValueAddition(nextlvl, self.staticData)
    if next(skillAddition) then -- 技能表优化
        return string.format(desc2, unpack(skillAddition))
    else
        local levelNum = "lvl" .. nextlvl
        local levelNum = self.staticData[levelNum]
        if levelNum and type(levelNum) == "table" then
            local tempLevelNum = {}
            for i,v in ipairs(levelNum) do
                table.insert(tempLevelNum, math.round(tonumber(v) * 100))
            end
            return string.format(desc2, unpack(tempLevelNum))
        else
            return self.fullLevelStr
        end
    end
end

return ExSkillDetailModel
