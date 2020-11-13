local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local RewardDataCtrl = require('ui.controllers.common.RewardDataCtrl')
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local BuildingBase = require("data.BuildingBase")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local AdventureItem = require("data.AdventureItem")
local OpponentDialog = class(unity.base)

function OpponentDialog:ctor()
--------Start_Auto_Generate--------
    self.titleAreaGo = self.___ex.titleAreaGo
    self.titleTxt = self.___ex.titleTxt
    self.disableGo = self.___ex.disableGo
    self.detailGo = self.___ex.detailGo
    self.flagImg = self.___ex.flagImg
    self.iconImg = self.___ex.iconImg
    self.iconBorderImg = self.___ex.iconBorderImg
    self.weatherAndGrassGo = self.___ex.weatherAndGrassGo
    self.weatherImg = self.___ex.weatherImg
    self.weatherTxt = self.___ex.weatherTxt
    self.grassImg = self.___ex.grassImg
    self.grassTxt = self.___ex.grassTxt
    self.detailBtn = self.___ex.detailBtn
    self.powerTxt = self.___ex.powerTxt
    self.reduceTxt = self.___ex.reduceTxt
    self.infoGo = self.___ex.infoGo
    self.logoImg = self.___ex.logoImg
    self.competeSignImg = self.___ex.competeSignImg
    self.nameTxt = self.___ex.nameTxt
    self.lvlTxt = self.___ex.lvlTxt
    self.serverTxt = self.___ex.serverTxt
    self.viewSpt = self.___ex.viewSpt
    self.vipGo = self.___ex.vipGo
    self.vipLvlTxt = self.___ex.vipLvlTxt
    self.starGo = self.___ex.starGo
    self.startEffectTxt = self.___ex.startEffectTxt
    self.effectGo = self.___ex.effectGo
    self.effectTxt = self.___ex.effectTxt
    self.rewardGo = self.___ex.rewardGo
    self.rewardContentTrans = self.___ex.rewardContentTrans
    self.tipGo = self.___ex.tipGo
    self.tipTxt = self.___ex.tipTxt
    self.weatherEffectGo = self.___ex.weatherEffectGo
    self.weatherEffectTxt = self.___ex.weatherEffectTxt
    self.weatherRiseTxt = self.___ex.weatherRiseTxt
    self.weatherDropTxt = self.___ex.weatherDropTxt
    self.bottomGo = self.___ex.bottomGo
    self.buttonContentGo = self.___ex.buttonContentGo
    self.challenge1Spt = self.___ex.challenge1Spt
    self.moraleNumTxt = self.___ex.moraleNumTxt
    self.challenge2Spt = self.___ex.challenge2Spt
    self.powerNumTxt = self.___ex.powerNumTxt
    self.descGo = self.___ex.descGo
    self.descTxt = self.___ex.descTxt
    self.btnClose = self.___ex.btnClose
--------End_Auto_Generate----------
    self.btnWeaken = self.___ex.btnWeaken
    self.imgWeaken = self.___ex.imgWeaken
    GameObjectHelper.FastSetActive(self.disableGo, false)
end

function OpponentDialog:start()
    DialogAnimation.Appear(self.transform)
    self.challenge1Spt:regOnButtonClick(function()
        self:Challenge()
    end)
    self.challenge2Spt:regOnButtonClick(function()
        self:BuyOver()
    end)
    self.detailBtn:regOnButtonClick(function()
        self:OnBtnDetail()
    end)
    self.viewSpt:regOnButtonClick(function()
        self:OnBtnOpponentView()
    end)
    self.btnWeaken:regOnButtonClick(function()
        self:OnBtnWeaken()
    end)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    GuideManager.Show(self)
end

function OpponentDialog:EnterScene()
    EventSystem.AddEvent("DisableUpperHierarchy", self, self.DisableUpperHierarchy)
    EventSystem.AddEvent("ShowUpperHierarchy", self, self.ShowUpperHierarchy)
    EventSystem.AddEvent("GreenswardItemUse_WeakenOpponent", self, self.OnWeakenOpponent)
end

function OpponentDialog:ExitScene()
    EventSystem.RemoveEvent("DisableUpperHierarchy", self, self.DisableUpperHierarchy)
    EventSystem.RemoveEvent("ShowUpperHierarchy", self, self.ShowUpperHierarchy)
    EventSystem.RemoveEvent("GreenswardItemUse_WeakenOpponent", self, self.OnWeakenOpponent)
end

function OpponentDialog:DisableUpperHierarchy()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function OpponentDialog:ShowUpperHierarchy()
    GameObjectHelper.FastSetActive(self.gameObject, true)
end

function OpponentDialog:OnBtnOpponentView()
    if self.opponentClick then
        self.opponentClick()
    end
end

function OpponentDialog:OnBtnDetail()
    if self.detailClick then
        self.detailClick()
    end
end

function OpponentDialog:Challenge()
    if self.challengeClick then
        self.challengeClick()
    end
end

function OpponentDialog:BuyOver()
    if self.buyOverClick then
        self.buyOverClick()
    end
end

-- 削弱战力
function OpponentDialog:OnBtnWeaken()
    if self.powerWeaken then
        self.powerWeaken()
    end
end

function OpponentDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function OpponentDialog:InitView(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local isOperable = eventModel:IsOperable()
    GameObjectHelper.FastSetActive(self.buttonContentGo, isOperable)
    GameObjectHelper.FastSetActive(self.descGo, not isOperable)

    if isOperable then
        local isMorale = eventModel:ConsumeByMorale()
        local isPower = eventModel:ConsumeByPower()
        local consumeMorale, starSymbol = eventModel:GetConsumeMorale()
        self.moraleNumTxt.text = "x" .. tostring(consumeMorale or 0)
        local r, g, b = eventModel:GetConvertColor(starSymbol)
        self.moraleNumTxt.color = ColorConversionHelper.ConversionColor(r, g, b)
        self.powerNumTxt.text = "x" .. tostring(eventModel:GetConsumeFight() or 0)
        GameObjectHelper.FastSetActive(self.challenge1Spt.gameObject, isMorale)
        GameObjectHelper.FastSetActive(self.challenge2Spt.gameObject, isPower)
    end

    local opRes = eventModel:GetOpponentPic()
    local logoIndex = opRes.badge or "10001"
    local logoPic = AdventureItem[logoIndex] and AdventureItem[logoIndex].picIndex or "Logo1"
    self.iconImg.overrideSprite = greenswardResourceCache:GetLogoRes(logoPic)
    local frameIndex = opRes.frame or "20001"
    local framePic = AdventureItem[frameIndex] and AdventureItem[frameIndex].picIndex or "Head_Frame1"
    self.iconBorderImg.overrideSprite = greenswardResourceCache:GetHeadFrameRes(framePic)
end

function OpponentDialog:ShowDetail(eventModel, detailData)
    self.eventModel = eventModel
    detailData = detailData or {}
    local opponent = detailData.opponent or {}
    local info = detailData.info or {}
    local vip = tonumber(opponent.vip)
    self.nameTxt.text = opponent.name
    self.lvlTxt.text = "Lv." .. tonumber(opponent.lvl)
    self.serverTxt.text = opponent.serverName
    self.vipLvlTxt.text = tostring(vip)
    self.powerTxt.text = tostring(tonumber(opponent.power))

    local signData = CompeteSignConvert[tostring(opponent.competeSign)]
    if signData then
        self.competeSignImg.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signData.path .. ".png")
    else
        self.competeSignImg.enabled = false
    end
    local staticData = eventModel:GetStaticData()
    local flag = staticData.monsterFlag or "Flag1"
    self.flagImg.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/DialogImage/Opponent/" .. flag .. ".png")
    local weather = info.wea
    local grass = info.grass
    self.weatherImg.overrideSprite = CourtAssetFinder.GetTechnologyFixIcon(weather)
    self.grassImg.overrideSprite = CourtAssetFinder.GetTechnologyIcon(grass)
    self.weatherTxt.text = BuildingBase[weather].name
    self.grassTxt.text = BuildingBase[grass].name
    local starEffect = info.starEffect
    local starEffectDesc = lang.transstr("none")
    if starEffect then
        local hasStarEffect = false
        hasStarEffect, starEffectDesc = eventModel:GetStarEffectCondition()
    end
    self.startEffectTxt.text = lang.trans("star_effect_tip", starEffectDesc)

    local hasReward = eventModel:HasReward()
    local hasEffect = eventModel:HasEffectEvent()
    local hasWeatherEffect = eventModel:HasWeatherEffectEvent()
    local hasTips = false
    if hasReward then
        for i = 1, self.rewardContentTrans.childCount do
            Object.Destroy(self.rewardContentTrans:GetChild(i - 1).gameObject)
        end
        local rewardParams = {
            parentObj = self.rewardContentTrans,
            rewardData = eventModel:GetReward(),
            isShowName = false,
            isReceive = false,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    elseif hasEffect then
        self.effectTxt.text = eventModel:GetEffectText()
    elseif hasWeatherEffect then
        self.weatherEffectTxt.text = eventModel:GetEffectBuffText(info)
        local rise, drop = eventModel:GetTipsText(info)
        self.weatherRiseTxt.text = rise
        self.weatherDropTxt.text = drop
    else
        hasTips = true
        self.tipTxt.text = eventModel:GetChallengeText()
    end

    self.descTxt.text = tostring(eventModel:GetDescText())
    GameObjectHelper.FastSetActive(self.vipGo, tobool(vip > 0))
    GameObjectHelper.FastSetActive(self.rewardGo, hasReward)
    GameObjectHelper.FastSetActive(self.effectGo, hasEffect)
    GameObjectHelper.FastSetActive(self.tipGo, hasTips)
    GameObjectHelper.FastSetActive(self.weatherEffectGo, hasWeatherEffect)
    GameObjectHelper.FastSetActive(self.disableGo, true)

    TeamLogoCtrl.BuildTeamLogo(self.logoImg, opponent.logo)
    self:ShowWeaken()
end

-- 是否显示削弱战力
function OpponentDialog:ShowWeaken()
    local impact = tonumber(self.eventModel:GetImpactResult())
    local hasImpacted = impact > 0
    GameObjectHelper.FastSetActive(self.btnWeaken.gameObject, not hasImpacted and self.eventModel:CanImpactItemFill())
    GameObjectHelper.FastSetActive(self.imgWeaken.gameObject, hasImpacted)
    local reduceTxt = ""
    if hasImpacted then
        reduceTxt = lang.transstr("allAttribute") .. "-" .. impact .. "%"
    end
    self.reduceTxt.text = reduceTxt
end

-- 削弱战力
function OpponentDialog:OnWeakenOpponent()
    if self.onWeakenOpponent ~= nil and type(self.onWeakenOpponent) == "function" then
        self.onWeakenOpponent()
    end
end

return OpponentDialog
