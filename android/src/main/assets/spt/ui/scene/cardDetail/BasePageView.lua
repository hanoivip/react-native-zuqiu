local CardHelper = require("ui.scene.cardDetail.CardHelper")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")
local LevelLimit = require("data.LevelLimit")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local BasePageView = class(unity.base)
local tostring = tostring
local tonumber = tonumber

function BasePageView:ctor()
    self.pass = self.___ex.pass
    self.passPlus = self.___ex.passPlus
    self.dribble = self.___ex.dribble
    self.dribblePlus = self.___ex.dribblePlus
    self.shoot = self.___ex.shoot
    self.shootPlus = self.___ex.shootPlus
    self.intercept = self.___ex.intercept
    self.interceptPlus = self.___ex.interceptPlus
    self.steal = self.___ex.steal
    self.stealPlus = self.___ex.stealPlus
    self.save = self.___ex.save
    self.savePlus = self.___ex.savePlus
    self.level = self.___ex.level
    self.limit = self.___ex.limit
    self.btnLevelUp = self.___ex.btnLevelUp
    self.levelProgress = self.___ex.levelProgress

    self.ploygonCustom = self.___ex.ploygonCustom
    self.pentagonText = self.___ex.pentagonText     -- table
    self.pentagonValue = self.___ex.pentagonValue   -- table
    self.advanceView = self.___ex.advanceView
    self.bottom = self.___ex.bottom
    self.bottomTitle = self.___ex.bottomTitle
    self.bottomTitleBar1 = self.___ex.bottomTitleBar1
    self.bottomTitleBar2 = self.___ex.bottomTitleBar2
    self.infoArea = self.___ex.infoArea

    self.normalLevelUp = self.___ex.normalLevelUp
    self.training = self.___ex.training
    self.trainingBtn = self.___ex.trainingBtn
    self.lvlTxt = self.___ex.lvlTxt
end

function BasePageView:start()
    self.btnLevelUp:regOnButtonClick(function()
        self:OnBtnLevelUp()
    end)
    self.trainingBtn:regOnButtonClick(function ()
        self:OnBtnTraing()
    end)

    EventSystem.AddEvent("LevelUpPageClose", self, self.LevelUpEnd)
end

function BasePageView:OnBtnLevelUp()
    if self.clickLevelUp then 
        self.clickLevelUp()
    end
end

function BasePageView:OnBtnTraing()
    if self.clickTraining then
        self.clickTraining()
    end
end

function BasePageView:InitView(cardDetailModel)
    local cardModel = cardDetailModel:GetCardModel()
    self.level.text = tostring(cardModel:GetLevel())
    self.lvlTxt.text = "LV <size=52>" .. tostring(cardModel:GetLevel()) .. "</size>"
    self.limit.text = '/' .. cardModel:GetLevelLimit()
    self.levelProgress.fillAmount = tonumber(cardModel:GetExp() - cardModel:GetExpLimit()) / tonumber(cardModel:GetLevelUpExp())

    local pentagonOrder
    if cardModel:IsGKPlayer() then
        pentagonOrder = CardHelper.GoalKeeperOrder
    else
        pentagonOrder = CardHelper.NormalPlayerOrder
    end

    local fiveAbilityValueList = {}
    local maxAbilityValue = -1

    local medalCombine = cardModel:GetMedalCombine()
    for i, abilityIndex in ipairs(pentagonOrder) do
        local base, plus, train, total = cardModel:GetAbility(abilityIndex, medalCombine)
        if total > maxAbilityValue then
            maxAbilityValue = total
        end
        table.insert(fiveAbilityValueList, base + plus + train)
        self.pentagonText["p" .. tostring(i)].text = lang.trans(abilityIndex)
        self.pentagonValue["p" .. tostring(i)].text = tostring(base + plus + train)
    end

    local color, maxValue = CardHelper.GetPolygonColorAndMaxValue(maxAbilityValue)
    local abilityValues = {
        math.sqrt(fiveAbilityValueList[1] / maxValue),
        math.sqrt(fiveAbilityValueList[2] / maxValue),
        math.sqrt(fiveAbilityValueList[3] / maxValue),
        math.sqrt(fiveAbilityValueList[4] / maxValue),
        math.sqrt(fiveAbilityValueList[5] / maxValue),
    }
    self.ploygonCustom.color = color
    self.ploygonCustom.maxValue = 1
    self.ploygonCustom.abilityValues = clr.array(abilityValues, clr.System.Single)
    self.ploygonCustom:SetAllDirty()

    self:SetProgressInfo(cardModel)

    local canTrainingBase = cardModel:CanTrainingBase()
    local isMaxLevel = cardModel:IsMaxLevel()
    local isMaxUpgrade = not cardModel:IsExistUpgradeNum()
    local islvlReach = PlayerInfoModel.new():GetLevel() >= LevelLimit["TrainingBase"].playerLevel
    -- 当查看好友球员时，不显示特训入口
    local isMyPlayer = cardModel:IsOperable()
    local isOpen = canTrainingBase and isMaxLevel and isMaxUpgrade and islvlReach and isMyPlayer

    GameObjectHelper.FastSetActive(self.training, isOpen)
    GameObjectHelper.FastSetActive(self.normalLevelUp, not isOpen)

    self.bottom.overrideSprite = cardDetailModel:GetImageRes("bottom")
    self.bottomTitle.overrideSprite = cardDetailModel:GetImageRes("bottomTitle")
    self.bottomTitleBar1.overrideSprite = cardDetailModel:GetImageRes("bottomTitleBar1")
    self.bottomTitleBar2.overrideSprite = cardDetailModel:GetImageRes("bottomTitleBar2")
    self.infoArea.overrideSprite = cardDetailModel:GetImageRes("infoArea")
end

function BasePageView:SetProgressInfo(cardModel)

end

function BasePageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

return BasePageView
