local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtSubsidiaryBuildView = class(unity.base)

function CourtSubsidiaryBuildView:ctor()
    self.currentBuildIcon = self.___ex.currentBuildIcon
    self.nextBuildIcon = self.___ex.nextBuildIcon
    self.currentBuildLevel = self.___ex.currentBuildLevel
    self.nextBuildLevel = self.___ex.nextBuildLevel
    self.levelUpCondition = self.___ex.levelUpCondition
    self.levelUpEffect = self.___ex.levelUpEffect
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
    self.currentEffect = self.___ex.currentEffect
    self.nextEffect = self.___ex.nextEffect
    self.currentEffectGold = self.___ex.currentEffectGold
    self.nextEffectGold = self.___ex.nextEffectGold
    self.completeCost = 0
end

function CourtSubsidiaryBuildView:start()
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

function CourtSubsidiaryBuildView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        self:ClickEvent()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function CourtSubsidiaryBuildView:OnBtnLevelUp(courtBuildType)
    if self.clickLevelUp then 
        self.clickLevelUp(courtBuildType)
    end
end

function CourtSubsidiaryBuildView:OnBtnComplete(courtBuildType)
    if self.clickComplete then 
        self.clickComplete(courtBuildType, self.completeCost)
    end
end

function CourtSubsidiaryBuildView:ClickEvent()
    if self.clickEvent then 
        self.clickEvent()
    end
end

function CourtSubsidiaryBuildView:onDestroy()
    EventSystem.SendEvent("CourtTimeDie", self)
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
end

function CourtSubsidiaryBuildView:RefreshBuild(buildType, courtBuildModel)
    if buildType == self.courtBuildType then 
        if self.refreshBuild then 
            self.refreshBuild(buildType, courtBuildModel)
        end
    end
end

function CourtSubsidiaryBuildView:InitView(courtBuildModel, buildType)
    self.courtBuildModel = courtBuildModel
    self.courtBuildType = buildType
    local currentLevel = courtBuildModel:GetBuildLevel(buildType)
    self.buildTitle.text = courtBuildModel:GetBuildLevelStr(buildType)
    local currentIcon = courtBuildModel:GetBuildIcon(buildType, currentLevel)
    self.currentBuildIcon.overrideSprite = CourtAssetFinder.GetCourtIcon(buildType, currentIcon)
    self.currentBuildLevel.text = "Lv." .. tostring(currentLevel)
    local nextLvl = currentLevel + 1
    local isMax = courtBuildModel:IsBuildMaxLvl(buildType, nextLvl)
    local isCooling = false
    local currentBuildIndex = courtBuildModel:GetBuildIndex(buildType, currentLevel)
    local nextBuildIndex = courtBuildModel:GetBuildIndex(buildType, nextLvl)
    local currentEffectText, nextEffectText

    if buildType == CourtBuildType.AudienceBuild then
        currentEffectText = lang.trans("audience_effect", tostring(currentBuildIndex))
        nextEffectText = lang.trans("audience_effect", tostring(nextBuildIndex))
    elseif buildType == CourtBuildType.LightingBuild then
        currentEffectText = lang.trans("light_effect", tostring(currentBuildIndex))
        nextEffectText = lang.trans("light_effect", tostring(nextBuildIndex))
    elseif buildType == CourtBuildType.ScoreBoardBuild then
        currentEffectText = lang.trans("score_board_effect", tostring(currentBuildIndex))
        nextEffectText = lang.trans("score_board_effect", tostring(nextBuildIndex))
    elseif buildType == CourtBuildType.StoreBuild then
        currentEffectText = lang.trans("store_effect", tostring(currentBuildIndex))
        nextEffectText = lang.trans("store_effect", tostring(nextBuildIndex))        
    end

    if isMax then
        self.levelUpCondition.text = lang.trans("maxLevel")
        self.levelUpTime.text = lang.trans("maxTime")
        self.levelUpButton.interactable = false
        self.btnLevelUp:onPointEventHandle(false)
        self.levelUpText.text = lang.trans("finished")
        self.nextEffect.text = lang.trans("maxLevel")
        self.currentEffect.text = currentEffectText
        if buildType == CourtBuildType.AudienceBuild then
            GameObjectHelper.FastSetActive(self.currentEffectGold, false)
            GameObjectHelper.FastSetActive(self.nextEffectGold, false)
        else
            GameObjectHelper.FastSetActive(self.currentEffectGold, true)
            GameObjectHelper.FastSetActive(self.nextEffectGold, false)
        end
        ButtonColorConfig.SetDisableGradientColor(self.levelUpGradient)
    else
        local nextIcon = courtBuildModel:GetBuildIcon(buildType, nextLvl)
        self.nextBuildIcon.overrideSprite = CourtAssetFinder.GetCourtIcon(buildType, nextIcon)
        self.nextBuildLevel.text = "Lv." .. tostring(nextLvl)
        local conditionDesc = courtBuildModel:GetBuildUpgradeConditionDesc(buildType, nextLvl)
        self.levelUpCondition.text = lang.trans("levelup_condition", conditionDesc)

        local upgradeTime = courtBuildModel:GetBuildUpgradeTime(buildType, nextLvl)
        local time = string.convertSecondToTimeTrans(upgradeTime * 60)
        self.levelUpTime.text = lang.transstr("levelup_time", time)
        local upgradeCost = courtBuildModel:GetBuildUpgradeCost(buildType, nextLvl)
        self.levelUpCost.text = tostring(upgradeCost)

        self.nextEffect.text = nextEffectText
        self.currentEffect.text = currentEffectText
        if buildType == CourtBuildType.AudienceBuild then
            GameObjectHelper.FastSetActive(self.currentEffectGold, false)
            GameObjectHelper.FastSetActive(self.nextEffectGold, false)
        else
            GameObjectHelper.FastSetActive(self.currentEffectGold, true)
            GameObjectHelper.FastSetActive(self.nextEffectGold, true)
        end
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
    end
    GameObjectHelper.FastSetActive(self.btnLevelUp.gameObject, not isCooling)
    GameObjectHelper.FastSetActive(self.completeArea.gameObject, isCooling)
    GameObjectHelper.FastSetActive(self.progressArea.gameObject, isCooling)

    local effectDesc = courtBuildModel:GetBuildUpgradeEffectDesc(buildType)
    self.levelUpEffect.text = lang.trans("levelup_desc", effectDesc)
    GameObjectHelper.FastSetActive(self.upgradeSign, not isMax)
    GameObjectHelper.FastSetActive(self.nextNormalArea, not isMax)
    GameObjectHelper.FastSetActive(self.levelUpCost.gameObject, not isMax)
    GameObjectHelper.FastSetActive(self.maxArea, isMax)
end

function CourtSubsidiaryBuildView:UpdateTime(time)
    self.coolingTime.text = string.formatTimeClock(time, 3600)
    local level = self.courtBuildModel:GetBuildLevel(self.courtBuildType)
    local totalTime = self.courtBuildModel:GetBuildUpgradeTime(self.courtBuildType, level + 1) * 60
    local percent = 1 - time / totalTime
    self.progressBar.value = percent
    local cost = math.ceil(time / 60)
    self.completeCost = cost
    self.cost.text = "x" .. cost
end

return CourtSubsidiaryBuildView
