local Skill = class(nil, "Skill")

function Skill:ctor(level)
    self.id = "invalid"
    self.alias = "invalid"
    self.level = level
    self.cooldown = 0
    self.remainingCooldown = 0
    self.probability = 0
    -- 如果有多个球员有该技能，标识当前技能在这一组技能中的发动顺序
    self.launchIndex = nil
end

function Skill.lerpLevel(minValue, maxValue, level)
    return minValue + (maxValue - minValue) / 99 * (level - 1)
end

function Skill.calcLaunchIndex(team, skillClass)
    local skillDatas = {}

    for _, itemAthlete in ipairs(team.athletes) do
        local targetSkill = itemAthlete:getSkill(skillClass)
        if targetSkill ~= nil then
            table.insert(skillDatas, {
                skill = targetSkill,
                athleteId = itemAthlete.id,
            })
        end
    end

    table.sort(skillDatas, function (a, b)
        if a.skill.level ~= b.skill.level then
            return a.skill.level > b.skill.level
        end

        return a.athleteId > b.athleteId
    end)

    for i, item in ipairs(skillDatas) do
        item.skill.launchIndex = i
    end
end

-- 勋章技能
function Skill:isMedalSkill()
    return string.sub(self.id, 1, 1) == "M"
end

-- 小技能
function Skill:isLowPowerSkill()
    return string.sub(self.id, 1, 1) == "F"
end

-- 射门技能
function Skill:isShootSkill()
    return string.sub(self.id, 1, 1) == "D"
end

-- 防守技能
function Skill:isDefendSkill()
    return string.sub(self.id, 1, 1) == "A"
end

-- 技能触发概率衰减
function Skill:decreaseProbability()
    -- 技能基础概率
    if self.probability then
        self.probability = self.probability * 0.3
    end

    -- 技能ex1概率
    if self.ex1Probability then
        self.ex1Probability = self.ex1Probability * 0.3
    end
end

return Skill
