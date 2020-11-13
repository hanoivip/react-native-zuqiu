local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local MedalPageView = class(unity.base)

function MedalPageView:ctor()
    self.bottom = self.___ex.bottom
    self.bottomTitle = self.___ex.bottomTitle
    self.bottomTitleBar1 = self.___ex.bottomTitleBar1
    self.bottomTitleBar2 = self.___ex.bottomTitleBar2
    self.medalMap = self.___ex.medalMap
    self.medalAttrContent = self.___ex.medalAttrContent
    self.powerContent = self.___ex.powerContent
    self.baseAttrMap = self.___ex.baseAttrMap
    self.skillContentMap = self.___ex.skillContentMap
    self.benedictionContentMap = self.___ex.benedictionContentMap
    self.equipNum = self.___ex.equipNum
    self.infoArea = self.___ex.infoArea
    self.infoName = self.___ex.infoName
    self.benedictionName = self.___ex.benedictionName
    self.benedictionDesc = self.___ex.benedictionDesc
    self.benedictionBar = self.___ex.benedictionBar
    self.btnMenu = self.___ex.btnMenu
    self.btnAutoUnload = self.___ex.btnAutoUnload
    self.btnReplace = self.___ex.btnReplace
    self.btnStrengthin = self.___ex.btnStrengthin
    self.unloadButton = self.___ex.unloadButton
    self.medalIcon = self.___ex.medalIcon
    self.strengthenIcon = self.___ex.strengthenIcon
    self.medalName= self.___ex.medalName
    self.medalStrengthenName = self.___ex.medalStrengthenName
    self.benedictionName = self.___ex.benedictionName
    self.btnTip = self.___ex.btnTip
    self.autoUnloadGradient = self.___ex.autoUnloadGradient
    self.medalViewMap = {} -- 勋章放置区域
    self.medalSkillMap = {} -- 勋章技能区域
    self.medalBenedictionMap = {} -- 勋章祝福区域
    self.medalPowerMap = {} -- 勋章战力区域
    self.medalAttrMap = {} -- 勋章显示属性区域
end

function MedalPageView:start()
    self.btnMenu:regOnButtonClick(function()
        self:OnBtnMenu()
    end)
    self.btnAutoUnload:regOnButtonClick(function()
        self:UnloadMedal()
    end)
    self.btnReplace:regOnButtonClick(function()
        self:ShowEquipPage(self.pos, self.medalSingleModel)
    end)
    self.btnStrengthin:regOnButtonClick(function()
        self:Strengthin()
    end)
    self.btnTip:regOnButtonClick(function()
        self:OnBtnTip()
    end)
end

function MedalPageView:InitView(cardDetailModel)
    self.bottom.overrideSprite = cardDetailModel:GetImageRes("bottom")
    self.bottomTitle.overrideSprite = cardDetailModel:GetImageRes("bottomTitle")
    self.bottomTitleBar1.overrideSprite = cardDetailModel:GetImageRes("bottomTitleBar1")
    self.bottomTitleBar2.overrideSprite = cardDetailModel:GetImageRes("bottomTitleBar2")

    local cardModel = cardDetailModel:GetCardModel()
    self:ShowMedalAdditionReaction(cardModel)

    GameObjectHelper.FastSetActive(self.infoArea, false)
end

function MedalPageView:GetSkillRes()
    if not self.skillRes then
        self.skillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Medal/MedalSkill.prefab")
    end
    return self.skillRes
end

function MedalPageView:GetMedalRes()
    if not self.medalRes then
        self.medalRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Medal/Medal.prefab")
    end
    return self.medalRes
end

function MedalPageView:GetPowerRes()
    if not self.medalPowerRes then
        self.medalPowerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Medal/MedalPower.prefab")
    end
    return self.medalPowerRes
end

function MedalPageView:GetAttrRes()
    if not self.medalAttrRes then
        self.medalAttrRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Medal/MedelAttr.prefab")
    end
    return self.medalAttrRes
end

function MedalPageView:ShowMedalAdditionReaction(cardModel)
    self.cardModel = cardModel
    local medalsData = cardModel:GetMedals()
    local beEquipNum = table.nums(medalsData)
    local medalMaxPos = cardModel:GetMedalMaxPos()
    local isFull = beEquipNum >= medalMaxPos and true or false 
    local isEmpty = beEquipNum <= 0 and true or false 

    self.unloadButton.interactable = not isEmpty
    self.autoUnloadGradient.enabled = not isEmpty
    local addIndex = cardModel:IsGKPlayer() and 5 or 0 -- 非守门员1-5，守门员勋章位置从6-10
    local medalModels = cardModel:GetMedalModels()
    for k, v in pairs(self.medalMap) do
        local index = string.sub(k, 2)
        if not self.medalViewMap[index] then 
            local viewObj = Object.Instantiate(self:GetMedalRes())
            local viewSpt = res.GetLuaScript(viewObj)
            viewObj.transform:SetParent(v.transform, false)
            self.medalViewMap[index] = viewSpt
        end
        local pos = tonumber(index) + addIndex
        local medalSingleModel = medalModels[tostring(pos)]
        self.medalViewMap[index]:InitView(pos, isFull, medalSingleModel)
        self.medalViewMap[index].btnMedal:regOnButtonClick(function() self:OnClickMedal(pos, medalSingleModel) end)
    end
    self.equipNum.text = beEquipNum .. "/" .. medalMaxPos

    local skillsModel = cardModel:GetSkillsModel()
    for k, v in pairs(self.skillContentMap) do
        local index = string.sub(k, 2)
        local skillModel = skillsModel[tonumber(index)]
        local hasSkill = false
        if skillModel then
            hasSkill = true
            if not self.medalSkillMap[index] then 
                local viewObj = Object.Instantiate(self:GetSkillRes())
                local viewSpt = res.GetLuaScript(viewObj)
                viewObj.transform:SetParent(v.transform, false)
                self.medalSkillMap[index] = viewSpt
            end
            self.medalSkillMap[index]:InitView(skillModel)
        end
        GameObjectHelper.FastSetActive(v, hasSkill)
    end

    local benedictionsModel = cardModel:GetBenedictionsModel()
    for k, v in pairs(self.benedictionContentMap) do
        local index = string.sub(k, 2)
        local benedictionModel = benedictionsModel[tonumber(index)]
        local hasBenediction = false
        if benedictionModel then
            hasBenediction = true
            if not self.medalBenedictionMap[index] then 
                local viewObj = Object.Instantiate(self:GetSkillRes())
                local viewSpt = res.GetLuaScript(viewObj)
                viewObj.transform:SetParent(v.transform, false)
                self.medalBenedictionMap[index] = viewSpt
            end
            self.medalBenedictionMap[index]:InitView(benedictionModel)
        end
        GameObjectHelper.FastSetActive(v, hasBenediction)
    end

    local pentagonOrder
    if cardModel:IsGKPlayer() then
        pentagonOrder = CardHelper.GoalKeeperOrder
    else
        pentagonOrder = CardHelper.NormalPlayerOrder
    end
    local medalCombine = cardModel:GetMedalCombine()
    local attrPlusMap = cardModel:GetMedalAttrPlus()
    for i, abilityIndex in ipairs(pentagonOrder) do
        local attrPlus = attrPlusMap[tostring(abilityIndex)] or 0
        local base, plus, train, total = cardModel:GetAbility(abilityIndex, medalCombine)
        local totalAbility = total
        local extraPlus = medalCombine.extraAttribute[abilityIndex] or 0
        local addPlus = totalAbility - (totalAbility - attrPlus - attrPlus * extraPlus)/(1 + extraPlus)
        self.baseAttrMap["s" .. tostring(i)]:InitView(abilityIndex, addPlus)
    end

    local medalPower = tonumber(cardModel:GetPower()) - tonumber(cardModel:GetPowerWithOutMedal())
    local valueMap = {}
    if medalPower == 0 then table.insert(valueMap, 0) end
    while medalPower > 0 do
        local value = medalPower % 10
        table.insert(valueMap, value)
        medalPower = math.floor(medalPower / 10)
    end
    local count = 0
    for i = table.nums(valueMap), 1, -1 do
        local num = valueMap[i]
        count = count + 1
        if not self.medalPowerMap[count] then 
            local viewObj = Object.Instantiate(self:GetPowerRes())
            local viewSpt = res.GetLuaScript(viewObj)
            viewObj.transform:SetParent(self.powerContent.transform, false)
            self.medalPowerMap[count] = viewSpt
        end
        self.medalPowerMap[count]:InitView(num)
        local obj = self.medalPowerMap[count].gameObject
        GameObjectHelper.FastSetActive(obj, true)
    end
    for i = count + 1, table.nums(self.medalPowerMap) do
        local obj = self.medalPowerMap[i].gameObject
        GameObjectHelper.FastSetActive(obj, false)
    end
end

function MedalPageView:OnClickMedal(pos, medalSingleModel)
    local medalStrengthenName, medalName, benedictionName = "", "", ""
    local hasStrength, hasBenediction, hasMedal = false, false, false
    local attr = {}
    self.pos = pos
    self.medalSingleModel = medalSingleModel
    if medalSingleModel then 
        hasMedal = true
        local picIndex = medalSingleModel:GetPic()
        self.medalIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
        self.medalIcon:SetNativeSize()
        local state = medalSingleModel:GetBenedictionState()
        if state > 0 then 
            hasStrength = true
            medalStrengthenName = lang.trans("benediction_desc", state)
            self.strengthenIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Benediction" .. state ..".png")
        end
        medalName = medalSingleModel:GetName()
        local benediction = medalSingleModel:GetBenediction()
        if next(benediction) then 
            hasBenediction = true
            local name, lvl = medalSingleModel:GetBenedictionNameAndLvl()
            benedictionName = name .. " Lv" .. lvl
        end

        local baseAttr = medalSingleModel:GetBaseAttr()
        if next(baseAttr) then 
            local title = lang.transstr("breakThrough_baseAttr")
            local name, lvl = next(baseAttr)
            name = lang.transstr(name)
            lvl = "+" .. lvl
            table.insert(attr, {title = title, name = name, lvl = lvl})
        end 
        local exaAttr = medalSingleModel:GetExAttr()
        if next(exaAttr) then 
            local title = lang.transstr("extra_attr")
            local name, plus = next(exaAttr)
            name = lang.transstr(name)
            plus = plus * 100
            plus = "+" .. plus .. "%"
            table.insert(attr, {title = title, name = name, lvl = plus})
        end 
        local skillAttr = medalSingleModel:GetSkill()
        if next(skillAttr) then 
            local title = lang.transstr("skill_attr")
            local name, lvl = medalSingleModel:GetSkillNameAndLvl()
            lvl = "+Lv" .. lvl
            table.insert(attr, {title = title, name = name, lvl = lvl})
        end 
        for i, v in ipairs(attr) do
            if not self.medalAttrMap[i] then 
                local viewObj = Object.Instantiate(self:GetAttrRes())
                local viewSpt = res.GetLuaScript(viewObj)
                viewObj.transform:SetParent(self.medalAttrContent.transform, false)
                self.medalAttrMap[i] = viewSpt
            end
            self.medalAttrMap[i]:InitView(v)
            local obj = self.medalAttrMap[i].gameObject
            GameObjectHelper.FastSetActive(obj, true)
        end
        for i = table.nums(attr) + 1, table.nums(self.medalAttrMap) do
            local obj = self.medalAttrMap[i].gameObject
            GameObjectHelper.FastSetActive(obj, false)
        end
        self.medalStrengthenName.text = medalStrengthenName
        self.medalName.text = medalName
        self.benedictionName.text = benedictionName
    else
        local medalsData = self.cardModel:GetMedals()
        local beEquipNum = table.nums(medalsData)
        local medalMaxPos = self.cardModel:GetMedalMaxPos()
        local isFull = beEquipNum >= medalMaxPos and true or false 
        if not isFull then 
            self:ShowEquipPage(self.pos)
        end
    end

    GameObjectHelper.FastSetActive(self.infoArea, hasMedal)
    GameObjectHelper.FastSetActive(self.strengthenIcon.gameObject, hasStrength)
    GameObjectHelper.FastSetActive(self.benedictionBar.gameObject, hasBenediction)
    GameObjectHelper.FastSetActive(self.btnStrengthin.gameObject, hasMedal)
end

function MedalPageView:ShowEquipPage(pos, medalSingleModel)
    if self.showEquipPage then 
        local pcid = self.cardModel:GetPcid()
        self.showEquipPage(pos, pcid, medalSingleModel)
    end
end

function MedalPageView:UnloadMedal()
    if self.unloadMedal then 
        local medalsData = self.cardModel:GetMedals()
        local beEquipNum = table.nums(medalsData)
        local isEmpty = beEquipNum <= 0 and true or false 
        if not isEmpty then 
            self.unloadMedal()
        end
    end
end

function MedalPageView:OnBtnMenu()
    if self.clickMenu then 
        self.clickMenu()
    end
end

function MedalPageView:OnBtnTip()
    if self.clickTip then 
        self.clickTip()
    end
end

function MedalPageView:Strengthin()
    if self.strengthin then 
        local medalsData = self.cardModel:GetMedals()
        local beEquipNum = table.nums(medalsData)
        local isEmpty = beEquipNum <= 0 and true or false 
        if not isEmpty then 
            self.strengthin(self.medalSingleModel)
        end
    end
end

function MedalPageView:EnterScene()

end

function MedalPageView:ExitScene()
   
end

function MedalPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function MedalPageView:OnDestory()
    self.skillRes = nil
    self.medalRes = nil
    self.medalPowerRes = nil
    self.medalAttrRes = nil
end

return MedalPageView
