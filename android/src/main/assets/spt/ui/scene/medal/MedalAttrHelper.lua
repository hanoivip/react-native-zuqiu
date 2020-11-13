local MedalAttrHelper = {}

function MedalAttrHelper.ShowCurrentAttr(medalSingleModel, currentArrtMap, useBreakAttr)
    local baseAttr = medalSingleModel:GetBaseAttr()
    local attr = { }
    for k, v in pairs(currentArrtMap) do
        local data = { title = "", name = "", lvl = "" }
        table.insert(attr, data)
    end
    if next(baseAttr) then
        local title = lang.transstr("breakThrough_baseAttr")
        local name, lvl = next(baseAttr)
        name = lang.transstr(name)
        lvl = "+" .. lvl
        attr[1] = { title = title, name = name, lvl = lvl }
    end
    local exaAttr = medalSingleModel:GetExAttr()
    if next(exaAttr) then
        local maxPercent = useBreakAttr and math.max(medalSingleModel:GetBreakTroughMaxPercent(), medalSingleModel:GetExAttrMaxPercent()) or medalSingleModel:GetExAttrMaxPercent()
        local title = lang.transstr("extra_attr")
        local name, plus = next(exaAttr)
        local max = tobool(plus >= maxPercent) and "\n(MAX)" or ""
        name = lang.transstr(name)
        plus = plus * 100
        plus = "+" .. plus .. "%" .. max
        attr[2] = { title = title, name = name, lvl = plus }
    end
    local skillAttr = medalSingleModel:GetSkill()
    if next(skillAttr) then
        local title = lang.transstr("skill_attr")
        local name, lvl = medalSingleModel:GetSkillNameAndLvl()
        lvl = "+" .. "Lv" .. lvl
        attr[3] =  { title = title, name = name, lvl = lvl }
    end
    local benediction = medalSingleModel:GetBenediction()
    if next(benediction) then
        local name, lvl = medalSingleModel:GetBenedictionNameAndLvl()
        lvl = "Lv" .. lvl
        attr[4] =  { title = "", name = name, lvl = lvl }
    end
    for k, v in pairs(currentArrtMap) do
        local index = string.sub(k, 2)
        v:InitView(attr[tonumber(index)])
    end
    return attr
end

function MedalAttrHelper.ShowStaticAttr(medalSingleModel, currentArrtMap)
    local attr = { }
    for k, v in pairs(currentArrtMap) do
        local data = { title = "", name = "", lvl = "" }
        table.insert(attr, data)
    end
    local name, lvl = "", ""
    local baseAttr = medalSingleModel:GetStaticAttr()
    if next(baseAttr) then
        local title = lang.transstr("breakThrough_baseAttr")
        name, lvl = next(baseAttr)
        name = lang.transstr(name)
        lvl = "+" .. lvl
        attr[1] = { title = title, name = name, lvl = lvl }
    end

    name, lvl = "", ""
    local minPercent = medalSingleModel:GetExAttrMinPercent()
    local maxPercent = medalSingleModel:GetExAttrMaxPercent()
    if tonumber(maxPercent) > 0 then 
        name = lang.transstr("ex_attr_levelup")
        lvl = minPercent * 100 .. "%-" .. maxPercent * 100 .. "%"
    end
    attr[2] = { title = "", name = name, lvl = lvl }

    name, lvl = "", ""
    local skillLvl = medalSingleModel:GetRandomSkill()
    if tonumber(skillLvl) > 0 then
        name = lang.transstr("ex_skill_levelup")
        lvl = "+" .. "Lv" .. skillLvl
    end
    attr[3] = { title = "", name = name, lvl = lvl }

    name, lvl = "", ""
    local skillLvl = medalSingleModel:GetRandomBenediction()
    if tonumber(skillLvl) > 0 then
        name = lang.transstr("ex_benediction_levelup")
        lvl = "Lv" .. skillLvl
    end
    attr[4] = { title = "", name = name, lvl = lvl }

    for k, v in pairs(currentArrtMap) do
        local index = string.sub(k, 2)
        v:InitView(attr[tonumber(index)])
    end
    return attr
end

local function BuildMedalData(attr, key, currentDesc)
    local desc = currentDesc
    if attr[key] and attr[key] ~= "" then
        desc = attr[key]
    end
    return desc
end

local function BuildMedalAttr(oldAttrMap, index, title, name, lvl)
    local newTitle, newName, newLvl = title, name, lvl
    local oldAttr = oldAttrMap[index]
    if oldAttr then 
        newTitle = BuildMedalData(oldAttr, "title", newTitle)
        newName = BuildMedalData(oldAttr, "name", newName)
    end

    return {title = newTitle, name = newName, lvl = newLvl}
end

function MedalAttrHelper.ShowNextAttr(medalSingleModel, currentAttr, nextArrtMap)
    local attr = { }
    for k, v in pairs(nextArrtMap) do
        local data = { title = "", name = "", lvl = "" }
        table.insert(attr, data)
    end
    local name, lvl = "", ""
    local baseAttr = medalSingleModel:GetStaticAttr()
    if next(baseAttr) then
        local title = lang.transstr("breakThrough_baseAttr")
        name, lvl = next(baseAttr)
        name = lang.transstr(name)
        lvl = "+" .. lvl
        attr[1] = BuildMedalAttr(currentAttr, 1, title, name, lvl)
    end

    name, lvl = "", ""
    name = lang.transstr("ex_attr_levelup")
    local minPercent = medalSingleModel:GetExAttrMinPercent()
    local maxPercent = medalSingleModel:GetExAttrMaxPercent()
    lvl = minPercent * 100 .. "%-" .. maxPercent * 100 .. "%"
    attr[2] = BuildMedalAttr(currentAttr, 2, "", name, lvl)

    name, lvl = "", ""
    local skillLvl = medalSingleModel:GetRandomSkill()
    if tonumber(skillLvl) > 0 then
        name = lang.transstr("ex_skill_levelup")
        lvl = "+" .. "Lv" .. skillLvl
    end
    attr[3] = BuildMedalAttr(currentAttr, 3, "", name, lvl)

    name, lvl = "", ""
    local skillLvl = medalSingleModel:GetRandomBenediction()
    if tonumber(skillLvl) > 0 then
        name = lang.transstr("ex_benediction_levelup")
        lvl = "Lv" .. skillLvl
    end
    attr[4] = BuildMedalAttr(currentAttr, 4, "", name, lvl)

    for k, v in pairs(nextArrtMap) do
        local index = string.sub(k, 2)
        v:InitView(attr[tonumber(index)])
    end
end

return MedalAttrHelper
