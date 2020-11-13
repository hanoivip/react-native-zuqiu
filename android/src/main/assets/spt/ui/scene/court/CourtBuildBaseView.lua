local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildBaseView = class(unity.base)

function CourtBuildBaseView:ctor()
    self.currentIcon = self.___ex.currentIcon
    self.nextIcon = self.___ex.nextIcon
    self.currentLevel = self.___ex.currentLevel
    self.nextLevel = self.___ex.nextLevel
    self.levelUpCondition = self.___ex.levelUpCondition
    self.levelUpEffect = self.___ex.levelUpEffect
    self.levelUpTime = self.___ex.levelUpTime
    self.levelUpCost = self.___ex.levelUpCost

    self.btnLevelUp = self.___ex.btnLevelUp
    self.coolingTime = self.___ex.coolingTime

    self.buildTitle = self.___ex.buildTitle
    self.progressBar = self.___ex.progressBar
    self.cost = self.___ex.cost
    self.btnComplete = self.___ex.btnComplete
    self.btnClose = self.___ex.btnClose
    self.nextNormalArea = self.___ex.nextNormalArea
    self.maxArea = self.___ex.maxArea
    self.progressArea = self.___ex.progressArea
    self.buttonNormalArea = self.___ex.buttonNormalArea
    self.upgradeSign = self.___ex.upgradeSign
    self.levelUpButton = self.___ex.levelUpButton
    self.levelUpGradient = self.___ex.levelUpGradient
    self.levelUpText = self.___ex.levelUpText

    -- 立即完成消耗钻石
    self.dCost = 0
end

function CourtBuildBaseView:start()
    self.btnLevelUp:regOnButtonClick(function()
        self:OnBtnLevelUp()
    end)
    self.btnComplete:regOnButtonClick(function()
        self:OnBtnComplete()
    end)

    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)

    EventSystem.AddEvent("ShowBuild", self, self.ShowBuild)
    EventSystem.AddEvent("RefreshBuild", self, self.RefreshBuild)
end

function CourtBuildBaseView:onDestroy()
    EventSystem.SendEvent("BuildDialogClose", self.courtBuildType)
    EventSystem.RemoveEvent("ShowBuild", self, self.ShowBuild)
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
    EventSystem.SendEvent("CourtTimeDie", self)
end

function CourtBuildBaseView:RefreshBuild(buildType, courtBuildModel)
    if buildType == self.courtBuildType then 
        if self.refreshBuild then 
            self.refreshBuild()
        end
    end
end

function CourtBuildBaseView:ShowBuild()
    GameObjectHelper.FastSetActive(self.gameObject, true)
    self:InitView()
end

function CourtBuildBaseView:DisableBuild()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function CourtBuildBaseView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
            GuideManager.Show(self)
        end
    end)
end

function CourtBuildBaseView:OnBtnLevelUp()
    if self.clickLevelUp then 
        self.clickLevelUp()
    end
end

function CourtBuildBaseView:OnBtnComplete()
    if self.clickComplete then 
        self.clickComplete(self.dCost)
    end
end

function CourtBuildBaseView:InitView(courtBuildType, courtBuildModel)
    self.courtBuildModel = courtBuildModel or CourtBuildModel.new()
    self:InitInfo(courtBuildType, self.courtBuildModel)
end

function CourtBuildBaseView:InitInfo(courtBuildType, courtBuildModel)
    self.courtBuildType = courtBuildType
    self.courtBuildModel = courtBuildModel

    local level = self.courtBuildModel:GetBuildLevel(courtBuildType)
    self.buildTitle.text = self.courtBuildModel:GetBuildLevelStr(courtBuildType)
    local currentIcon = self.courtBuildModel:GetBuildIcon(courtBuildType, level)
    self.currentIcon.overrideSprite = CourtAssetFinder.GetCourtIcon(courtBuildType, currentIcon)
    self.currentLevel.text = "Lv." .. tostring(level)
    local nextLvl = level + 1
    local isMax = self.courtBuildModel:IsBuildMaxLvl(courtBuildType, nextLvl)
    local isCooling = false
    if isMax then
        self.levelUpCondition.text = lang.trans("maxLevel")
        self.levelUpTime.text = lang.trans("maxTime")

        self.levelUpButton.interactable = false
        self.btnLevelUp:onPointEventHandle(false)
        self.levelUpText.text = lang.trans("finished")
        ButtonColorConfig.SetDisableGradientColor(self.levelUpGradient)
    else
        local nextIcon = self.courtBuildModel:GetBuildIcon(courtBuildType, nextLvl)
        self.nextIcon.overrideSprite = CourtAssetFinder.GetCourtIcon(courtBuildType, nextIcon)
        self.nextLevel.text = "Lv." .. tostring(nextLvl)
        local conditionDesc = self.courtBuildModel:GetBuildUpgradeConditionDesc(courtBuildType, nextLvl)
        self.levelUpCondition.text = lang.trans("levelup_condition", conditionDesc)

        local upgradeTime = self.courtBuildModel:GetBuildUpgradeTime(courtBuildType, nextLvl)
        local time = string.convertSecondToTimeTrans(upgradeTime * 60)

        self.levelUpTime.text = lang.transstr("levelup_time", time)
        local upgradeCost = self.courtBuildModel:GetBuildUpgradeCost(courtBuildType, nextLvl)
        self.levelUpCost.text = tostring(upgradeCost)

        local time = self.courtBuildModel:GetBuildTime(courtBuildType) 
        if time > 0 then 
            EventSystem.SendEvent("CourtTimer", self, time, courtBuildType)
            isCooling = true
        else
            self.levelUpButton.interactable = true
            self.btnLevelUp:onPointEventHandle(true)
            self.levelUpText.text = lang.trans("levelUp")
            ButtonColorConfig.SetNormalGradientColor(self.levelUpGradient)
        end
    end
    GameObjectHelper.FastSetActive(self.buttonNormalArea.gameObject, not isCooling)
    GameObjectHelper.FastSetActive(self.progressArea.gameObject, isCooling)

    local effectDesc = self.courtBuildModel:GetBuildUpgradeEffectDesc(courtBuildType)
    self.levelUpEffect.text = lang.trans("levelup_desc", effectDesc)
    GameObjectHelper.FastSetActive(self.upgradeSign, not isMax)
    GameObjectHelper.FastSetActive(self.nextNormalArea, not isMax)
    GameObjectHelper.FastSetActive(self.levelUpCost.gameObject, not isMax)
    GameObjectHelper.FastSetActive(self.maxArea, isMax)
end

function CourtBuildBaseView:UpdateTime(time)
    self.coolingTime.text = string.formatTimeClock(time, 3600)
    local level = self.courtBuildModel:GetBuildLevel(self.courtBuildType)
    local totalTime = self.courtBuildModel:GetBuildUpgradeTime(self.courtBuildType, level + 1) * 60
    local percent = 1 - time / totalTime
    self.progressBar.value = percent
    self.dCost = math.ceil(time / 60)
    self.cost.text = "x" .. self.dCost
end

return CourtBuildBaseView