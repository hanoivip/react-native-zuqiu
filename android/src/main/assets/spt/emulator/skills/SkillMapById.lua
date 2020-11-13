local Skills = import("./Skills")

local SkillMapById = { }

for _, skill in pairs(Skills) do
    SkillMapById[skill.id] = skill
end

return SkillMapById
