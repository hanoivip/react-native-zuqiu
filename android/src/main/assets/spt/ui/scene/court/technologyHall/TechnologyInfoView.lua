local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local TechnologyInfoView = class(unity.base)

function TechnologyInfoView:ctor()
    self.currentBuildIcon = self.___ex.currentBuildIcon
    self.nextBuildIcon = self.___ex.nextBuildIcon
    self.currentBuildLevel = self.___ex.currentBuildLevel
    self.nextBuildLevel = self.___ex.nextBuildLevel
    self.levelUpCondition = self.___ex.levelUpCondition
    self.levelUpTime = self.___ex.levelUpTime
    self.levelUpCost = self.___ex.levelUpCost
    
    self.coolingTime = self.___ex.coolingTime
    self.buildTitle = self.___ex.buildTitle
    self.progressBar = self.___ex.progressBar
    self.cost = self.___ex.cost
    self.btnComplete = self.___ex.btnComplete
    self.btnClose = self.___ex.btnClose
    self.infoArea = self.___ex.infoArea
    self.nextNormalArea = self.___ex.nextNormalArea
    self.maxArea = self.___ex.maxArea
    self.progressArea = self.___ex.progressArea
    self.upgradeSign = self.___ex.upgradeSign
    self.completeArea = self.___ex.completeArea
    self.levelUpButton = self.___ex.levelUpButton
    self.levelUpGradient = self.___ex.levelUpGradient
    self.levelUpText = self.___ex.levelUpText
    self.btnLevelUp = self.___ex.btnLevelUp
    self.normalDesc = self.___ex.normalDesc
    self.maxDesc = self.___ex.maxDesc
    self.currentSkillArea = self.___ex.currentSkillArea
    self.nextSkillArea = self.___ex.nextSkillArea

    self.currentAttrArea = self.___ex.currentAttrArea
    self.nextAttrArea = self.___ex.nextAttrArea
    self.currentAttrText = self.___ex.currentAttrText
    self.nextAttrText = self.___ex.nextAttrText
    self.currentReduceDesc = self.___ex.currentReduceDesc
    self.nextReduceDesc = self.___ex.nextReduceDesc
    self.currentReduce = self.___ex.currentReduce
    self.nextReduce = self.___ex.nextReduce
    self.currentMatchDesc = self.___ex.currentMatchDesc
    self.nextMatchDesc = self.___ex.nextMatchDesc
    self.completeCost = 0
end

function TechnologyInfoView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnLevelUp:regOnButtonClick(function()
        self:OnBtnLevelUp(self.courtBuildType)
    end)
    self.btnComplete:regOnButtonClick(function()
        self:OnBtnComplete(self.courtBuildType)
    end)

    EventSystem.AddEvent("RefreshBuild", self, self.RefreshBuild)
end

function TechnologyInfoView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function TechnologyInfoView:OnBtnLevelUp(courtBuildType)
    if self.clickLevelUp then 
        self.clickLevelUp(courtBuildType)
    end
end

function TechnologyInfoView:OnBtnComplete(courtBuildType)
    if self.clickComplete then 
        self.clickComplete(courtBuildType, self.completeCost)
    end
end

function TechnologyInfoView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

function TechnologyInfoView:onDestroy()
    EventSystem.SendEvent("CourtTimeDie", self)
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
end

function TechnologyInfoView:RefreshBuild(buildType, courtBuildModel)
    if buildType == self.courtBuildType then 
        if self.refreshBuild then 
            self.refreshBuild(buildType, courtBuildModel)
        end
    end
end

function TechnologyInfoView:ClearChildren(parent)
    for i = parent.childCount, 1, -1 do
        Object.Destroy(parent:GetChild(i - 1).gameObject)
    end
end

function TechnologyInfoView:GetEffetSkillRes()
    if not self.skillRes then 
        self.skillRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/EffectSkill.prefab")
    end

    return self.skillRes
end

function TechnologyInfoView:SetEffect(courtBuildModel, buildType, buildLevel, contentArea, reduceText, attrText, reduceDesc)
    local isEffectSkill, effect, point = courtBuildModel:GetEffect(buildType, buildLevel)
    if isEffectSkill then 
        self:ClearChildren(contentArea)
        for i, sid in ipairs(effect) do
            local obj = Object.Instantiate(self:GetEffetSkillRes())
            obj.transform:SetParent(contentArea, false)
            local spt = res.GetLuaScript(obj)
            spt:InitView(sid)
        end
        reduceText.text = lang.trans("reduce_num", point)
        reduceDesc.text = lang.trans("lvl_reduce")
    else
        local textStr = ''
        for i, attr in ipairs(effect) do
            local symbol = ''
            if i < #effect then 
                symbol = '、'
            end
            textStr = textStr .. lang.transstr(attr) .. symbol
        end
        attrText.text = textStr
        reduceText.text = lang.trans("reduce_point", point)
        reduceDesc.text = lang.trans("attr_reduce")
    end
    GameObjectHelper.FastSetActive(self.currentSkillArea.gameObject, isEffectSkill)
    GameObjectHelper.FastSetActive(self.currentAttrArea.gameObject, not isEffectSkill)
    GameObjectHelper.FastSetActive(self.nextSkillArea.gameObject, isEffectSkill)
    GameObjectHelper.FastSetActive(self.nextAttrArea.gameObject, not isEffectSkill)
end

function TechnologyInfoView:InitView(courtBuildModel, buildType)
    self.courtBuildModel = courtBuildModel
    self.courtBuildType = buildType
    local currentLevel = courtBuildModel:GetBuildLevel(buildType)
    self.buildTitle.text = courtBuildModel:GetBuildLevelStr(buildType)
    local currentIcon = courtBuildModel:GetBuildIcon(buildType, currentLevel)
    self.currentBuildIcon.overrideSprite = CourtAssetFinder.GetCourtIcon(buildType, currentIcon)
    self.currentBuildLevel.text = "Lv." .. tostring(currentLevel)

    self:SetEffect(self.courtBuildModel, buildType, currentLevel, self.currentSkillArea, self.currentReduce, self.currentAttrText, self.currentReduceDesc)

    local matchDesc
    if courtBuildModel:IsGrass(buildType) then 
        matchDesc = lang.trans("match_desc1")
    elseif courtBuildModel:IsWeather(buildType) then 
        matchDesc = lang.trans("match_desc2")
    end
    self.currentMatchDesc.text = matchDesc
    self.nextMatchDesc.text = matchDesc

    local nextLvl = currentLevel + 1
    local isMax = courtBuildModel:IsBuildMaxLvl(buildType, nextLvl)
    local isCooling = false
    if isMax then
        self.levelUpCondition.text = lang.trans("maxLevel")
        self.levelUpTime.text = lang.trans("maxTime")
        self.levelUpButton.interactable = false
        self.btnLevelUp:onPointEventHandle(false)
        self.levelUpText.text = lang.trans("finished")
        ButtonColorConfig.SetDisableGradientColor(self.levelUpGradient)
    else
        local nextIcon = courtBuildModel:GetBuildIcon(buildType, nextLvl)
        self.nextBuildIcon.overrideSprite = CourtAssetFinder.GetCourtIcon(buildType, nextIcon)
        self.nextBuildLevel.text = "Lv" .. tostring(nextLvl)
        local conditionDesc = courtBuildModel:GetBuildUpgradeConditionDesc(buildType, nextLvl)
        self.levelUpCondition.text = lang.trans("levelup_condition", conditionDesc)

        local upgradeTime = courtBuildModel:GetBuildUpgradeTime(buildType, nextLvl)
        local time = string.convertSecondToTimeTrans(upgradeTime * 60)
        self.levelUpTime.text = lang.transstr("levelup_time", time)
        local upgradeCost = courtBuildModel:GetBuildUpgradeCost(buildType, nextLvl)
        self.levelUpCost.text = tostring(upgradeCost)

        local time = courtBuildModel:GetBuildTime(buildType)
        if time > 0 then 
            EventSystem.SendEvent("CourtTimer", self, time, buildType)
            isCooling = true
        else
            self.levelUpButton.interactable = true
            self.btnLevelUp:onPointEventHandle(true)
            self.levelUpText.text = lang.trans("levelUp")
            ButtonColorConfig.SetNormalGradientColor(self.levelUpGradient)
        end

        self:SetEffect(self.courtBuildModel, buildType, nextLvl, self.nextSkillArea, self.nextReduce, self.nextAttrText, self.nextReduceDesc)
    end
    GameObjectHelper.FastSetActive(self.normalDesc, not isMax)
    GameObjectHelper.FastSetActive(self.maxDesc, isMax)
    GameObjectHelper.FastSetActive(self.btnLevelUp.gameObject, not isCooling)
    GameObjectHelper.FastSetActive(self.completeArea.gameObject, isCooling)
    GameObjectHelper.FastSetActive(self.progressArea.gameObject, isCooling)

    GameObjectHelper.FastSetActive(self.upgradeSign, not isMax)
    GameObjectHelper.FastSetActive(self.nextNormalArea, not isMax)
    GameObjectHelper.FastSetActive(self.levelUpCost.gameObject, not isMax)
    GameObjectHelper.FastSetActive(self.maxArea, isMax)
end

function TechnologyInfoView:UpdateTime(time)
    self.coolingTime.text = string.formatTimeClock(time, 3600)
    local level = self.courtBuildModel:GetBuildLevel(self.courtBuildType)
    local totalTime = self.courtBuildModel:GetBuildUpgradeTime(self.courtBuildType, level + 1) * 60
    local percent = 1 - time / totalTime
    self.progressBar.value = percent
    local cost = math.ceil(time / 60)
    self.completeCost = cost
    self.cost.text = "x" .. cost
end

return TechnologyInfoView
