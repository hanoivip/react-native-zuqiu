local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local LockHelper = require("ui.common.lock.LockHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LockTypeFilter = require("ui.common.lock.LockTypeFilter")
local SupporterPlayerView = class(unity.base)

function SupporterPlayerView:ctor()
    SupporterPlayerView.super.ctor(self)
--------Start_Auto_Generate--------
    self.cardParentTrans = self.___ex.cardParentTrans
    self.nameTxt = self.___ex.nameTxt
    self.selectBtn = self.___ex.selectBtn
    self.selectGo = self.___ex.selectGo
    self.maskGo = self.___ex.maskGo
    self.questionBtn = self.___ex.questionBtn
--------End_Auto_Generate----------
    self.cardBtn = self.___ex.cardBtn
end

function SupporterPlayerView:start()
    self.cardBtn:regOnButtonClick(function()
        self:OnCardClick()
    end)
    self.selectBtn:regOnButtonClick(function()
        self:OnBtnSelect()
    end)
    self.questionBtn:regOnButtonClick(function()
        self:OnBtnQuest()
    end)
end

function SupporterPlayerView:OnCardClick()
    if self.clickCard then
        self.clickCard()
    end
end

-- 点击球员勾选框
function SupporterPlayerView:OnBtnSelect()
    if self.supporterModel:GetSupportCardModel() then
        if self.selected then
            self:SetSelected(false)
            self.supporterModel:SetSupportCardModel(nil)
            self.playerListModel.selectedView = nil
        else
            if self.playerListModel.selectedView then
                self.playerListModel.selectedView:SetUnselected()
            end
            self:SetSelected(true)
            self.supporterModel:SetSupportCardModel(self.cardModel)
        end
    elseif not self.supporterModel:GetSupportCardModel() and not self.selected then
        self:SetSelected(true)
        self.supporterModel:SetSupportCardModel(self.cardModel)
    end
end

-- 设置选择状态
function SupporterPlayerView:SetSelected(selected)
    self.selected = selected
    GameObjectHelper.FastSetActive(self.selectGo, selected)
    if selected then
        self.playerListModel.selectedView = self
    end
end

-- 不能助阵时的提示
function SupporterPlayerView:OnBtnQuest()
    local tips = {}
    if self.cardModel:IsSupportOtherCard() then
        local sppcid = self.cardModel:GetSppcid()
        local sppcidCardModel = PlayerCardModel.new(sppcid)
        local name = sppcidCardModel:GetName()
        local quality = sppcidCardModel:GetCardQuality()
        local QualitySpecial = sppcidCardModel:GetCardQualitySpecial()
        local fixQuality = CardHelper.GetQualityFixed(quality, QualitySpecial)
        local qualitySign = CardHelper.GetQualitySign(fixQuality)
        tips[1] = lang.transstr("support_tip_11", qualitySign, name)
    else
        local lockNum = self.cardModel.cacheData.lock
        local tempTips = LockHelper:GetDetailDesByLockNum(lockNum, LockTypeFilter.AllTeam)
        for i, v in pairs(tempTips) do
            tips[i] = v.stringDesc
        end
    end
    res.PushDialog("ui.controllers.cardDetail.supporter.SupporterTipBoxCtrl", tips)
end

-- 选择了其他球员
function SupporterPlayerView:SetUnselected()
    self:SetSelected(false)
end

function SupporterPlayerView:InitView(cardModel, playerListModel, supporterModel, cardResourceCache, parentCtrl)
    self.playerListModel = playerListModel
    self.supporterModel = supporterModel
    self.cardModel = cardModel
    -- Card
    if not self.cardView then
        local cardObject = Object.Instantiate(parentCtrl:GetCardRes())
        self.cardView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardParentTrans, false)
        self.cardView:SetCardResourceCache(cardResourceCache)
        self.cardView:IsShowName(false)
    end
    self.cardView:InitView(cardModel)
    self.nameTxt.text = tostring(cardModel:GetName())
    local supporterPcid = nil
    if supporterModel:GetSupportCardModel() then
        supporterPcid = supporterModel:GetSupportCardModel():GetPcid()
    end
    local selfPcid = cardModel:GetPcid()
    self:SetSelected(supporterPcid == selfPcid)

    -- 1. 必须为未上阵，而且也不在替补阵容的球员
    -- 2. 正在助阵他人，和正在接收他人助阵的球员，不能选择
    local canSelect = not cardModel:IsInUse(LockTypeFilter.AllTeam) and not cardModel:IsInSupporterLock()
    GameObjectHelper.FastSetActive(self.maskGo, not canSelect)
    GameObjectHelper.FastSetActive(self.selectBtn.gameObject, canSelect)
end

return SupporterPlayerView
