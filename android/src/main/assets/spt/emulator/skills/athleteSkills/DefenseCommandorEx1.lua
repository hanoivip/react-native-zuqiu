local Skill = import("../Skill")
local DefenseCommandor = import("./DefenseCommandor")

local DefenseCommandorEx1 = class(DefenseCommandor, "DefenseCommandorEx1")
DefenseCommandorEx1.id = "E04_1"
DefenseCommandorEx1.alias = "防线统领"

local minAddConfig = 0.1
local maxAddConfig = 0.1
-- 生效技能ID，必须保证基础技能有self.probability这一属性
local skillsConfig = {
    "G03", "G03_1", "G02", "G02_1","E11", "E11_1", "E06_1", "Z26_1", "A01_1",
}

function DefenseCommandorEx1:ctor(level)
    DefenseCommandor.ctor(self, level)    
    self.ex1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
end

function DefenseCommandorEx1:enterField(athlete)
    DefenseCommandor.enterField(self, athlete)
    for _, friend in ipairs(athlete.team.athletes) do
        if friend:isBack() then
            for i, skill in ipairs(friend.skills) do
                if table.isArrayInclude(skillsConfig, skill.id) then
                    skill.probability = skill.probability + self.ex1AddRatio
                    skill.probability = math.min(skill.probability, 1)
                end
            end
        end
    end
end

return DefenseCommandorEx1
