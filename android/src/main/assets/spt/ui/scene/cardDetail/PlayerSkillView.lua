local PlayerSkillView = class(unity.base)

function PlayerSkillView:ctor()
    self.skillLayout = self.___ex.skillLayout -- table
    self.skillPoint = self.___ex.skillPoint
end

function PlayerSkillView:start()
end

function PlayerSkillView:InitView(skillsList, skillsMap, cardDetailModel)
    assert(skillsList and skillsMap)
    self.skillPoint.text = tostring(cardDetailModel:GetCardModel():GetSkillPoint())

    local skillNum = #skillsList
    for i = 1, 6 do
        if skillNum ~= i then
            self.skillLayout["layout" .. tostring(i)]["obj"]:SetActive(false)
        end
    end

    if not self.skillItemsView then
        self.skillItemsView = {}
    end

    if not self.skillItemsView["layout" .. tostring(skillNum)] then
        self.skillItemsView["layout" .. tostring(skillNum)] = {}
    end

    local currentLayout = self.skillLayout["layout" .. tostring(skillNum)]
    currentLayout["obj"]:SetActive(true)

    local currentLayoutView = self.skillItemsView["layout" .. tostring(skillNum)]

    for slot, skillData in ipairs(skillsList) do
        local skillView = currentLayoutView["e" .. tostring(slot)]
        if not skillView then
            local viewObj, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/SkillItemJp.prefab")
            viewObj.transform:SetParent(currentLayout["e" .. tostring(slot)].transform, false)
            currentLayoutView["e" .. tostring(slot)] = viewSpt
            skillView = viewSpt
        end

        local skillItemModel = skillsMap[slot]
        -- 判断缘分类技能是否被激活
        local unactivated = false
        if skillItemModel:IsChemicalSkill() and not cardDetailModel:GetCardModel():IsChemicalSkillActivate(skillItemModel) then
            unactivated = true
        end

        skillView:InitView(skillItemModel, cardDetailModel:IsOperable() and cardDetailModel:CanSkillLevelUp(slot), unactivated)
        skillView.button:regOnButtonClick(function()
            if type(self.clickSkill) == "function" then
                self.clickSkill(slot, skillData.sid)
            end
        end)
    end
end

return PlayerSkillView
