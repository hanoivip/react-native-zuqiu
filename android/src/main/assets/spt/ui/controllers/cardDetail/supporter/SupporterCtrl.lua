local CardSupporter = require("data.CardSupporter")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local SupporterModel = require("ui.models.cardDetail.supporter.SupporterModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LegendRoadModel = require("ui.models.legendRoad.LegendRoadModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local SupporterCtrl = class(BaseCtrl, "SupporterCtrl")

SupporterCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/SupporterBoard.prefab"

function SupporterCtrl:AheadRequest(playerCardModel)
    self.playerCardModel = playerCardModel
    self.model = SupporterModel.new(playerCardModel)
    local supportCardModel = self.model:GetSupportCardModel()
    if supportCardModel then
        local sPcid = supportCardModel:GetPcid()
        local mPcid = playerCardModel:GetPcid()
        sPcid = tostring(sPcid)
        mPcid = tostring(mPcid)
        local response = req.cardTrainingInfoList({sPcid, mPcid})
        if api.success(response) then
            local data = response.val
            local supportTraining = data[sPcid].training
            local selfTraining = data[mPcid].training
            self.model:SetTrainingData(supportTraining, selfTraining)
        end
    end
end

function SupporterCtrl:Init(playerCardModel)
    SupporterCtrl.super.Init(self)
    self.playerCardsMapModel = PlayerCardsMapModel:new()
    self.view.onBtnSwitchCard = function() self:OnBtnSwitchCard() end
    self.view.onBtnActive = function() self:OnBtnActive() end
    self.view.onClose = function () self:OnClose() end
    self.view.onSwitchState = function () self:OnSwitchState() end
    self.view.onBtnQuestion = function () self:OnBtnQuestion() end
end

function SupporterCtrl:Refresh(playerCardModel, model)
    if model then
        self.model = model
    end
    SupporterCtrl.super.Refresh(self)
    self.view:InitView(self.model)
end

function SupporterCtrl:GetStatusData()
    return self.playerCardModel, self.model
end

function SupporterCtrl:OnBtnSwitchCard()
    res.PushDialog("ui.controllers.cardDetail.supporter.SupporterSelectCtrl", nil, nil, nil, true, nil, nil, nil, nil, self.playerCardModel, self.model)
end

function SupporterCtrl:OnBtnQuestion()
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(23, "CardSupporter")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function SupporterCtrl:OnBtnActive()
    local pcid = self.playerCardModel:GetPcid()
    local supporterCardModel = self.model:GetSupportCardModel()
    local selfSpcid = self.playerCardModel:GetSpcid()
    if not supporterCardModel then return end
    if selfSpcid == 0 then
        -- 确认助阵
        local function CallBack()
            local spcid = supporterCardModel:GetPcid()
            local trainingType = self.model:GetSelectTrainingType()
            local legendType = self.model:GetSelectLegendRoadType()

            clr.coroutine(function()
                local response = req.cardEquipSupporter(pcid, spcid, trainingType, legendType)
                if api.success(response) then
                    local data = response.val
                    for i, v in pairs(data.cost) do
                        PlayerInfoModel.new():CostDetail(v)
                    end
                    self:RefreshRequestData(data)
                    EventSystem.SendEvent("Supporter_Select")
                    DialogManager.ShowToast(lang.trans("support_success"))
                end
            end)
        end
        local costInfo = CardSupporter[CardHelper.GetQualityConfigFixed(self.playerCardModel:GetCardQuality(), self.playerCardModel:GetCardQualitySpecial())]
        local cost = costInfo.price or 0
        local currencyType = costInfo.currencytype or "d"
        local currencytypeName = lang.transstr(CurrencyNameMap[currencyType] or "")
        local function CostCallBack()
            CostDiamondHelper.CostCurrency(cost, self.view, function() CallBack() end, currencyType)
        end
        local supporterName = supporterCardModel:GetName()
        local selfName = self.playerCardModel:GetName()
        local title = lang.trans("tips")
        local msg = lang.trans("support_tip_2", cost, currencytypeName, supporterName, selfName)
        local cancelTxt = lang.trans("support_abandon")
        local confirmTxt = lang.trans("support_confirm")
        local tip1 = lang.trans("support_tip_3")
        local tip2 = lang.trans("support_tip_4")
        DialogManager.ShowMessageTipsBox(title, msg, function() CostCallBack() end, cancelTxt, confirmTxt, tip1, tip2, nil,
            function ()
            self.model:SetSupportCardModel(nil)
            EventSystem.SendEvent("Supporter_Select")
        end)
    else
        -- 取消助阵
        local function CallBack() 
            clr.coroutine(function()
                local response = req.cardUnEquipSupporter(pcid)
                if api.success(response) then
                    local data = response.val
                    self:RefreshRequestData(data)
                    self.model:SetSupportCardModel(nil)
                    EventSystem.SendEvent("Supporter_Select")
                end
            end)
        end
        local title = lang.trans("tips")
        local msg = lang.trans("support_tip_5")
        DialogManager.ShowConfirmPop(title, msg, function() CallBack()  end)
    end

end

function SupporterCtrl:OnClose()
    local scid = self.playerCardModel:GetSpcid()
    local supporterCardModel = self.model:GetSupportCardModel()
    if scid == 0 and tobool(supporterCardModel) then
        local title = lang.trans("tips")
        local msg = lang.trans("support_tip_6")
        local exitTxt = lang.trans("untranslated_2467")
        DialogManager.ShowMessageBox(title, msg, function() self.view:Close() end, nil, exitTxt)
    else
        self.view:Close()
    end
end

-- 助阵成功+stType/slrType状态有改变 申请一次数据保存
function SupporterCtrl:OnSwitchState()
    local trainingType = self.model:GetSelectTrainingType()
    local legendType = self.model:GetSelectLegendRoadType()
    local pcid = self.playerCardModel:GetPcid()
    clr.coroutine(function()
        local response = req.cardSupporterProgress(pcid, trainingType, legendType)
        if api.success(response) then
            local data = response.val
            self:RefreshRequestData(data)
        end
    end)
end

function SupporterCtrl:RefreshRequestData(data)
    if data.card and data.card.pcid then
        self.playerCardsMapModel:ResetCardData(data.card.pcid, data.card, true)
    end
    if data.supporterCard and data.supporterCard.pcid then
        self.playerCardsMapModel:ResetCardData(data.supporterCard.pcid, data.supporterCard, true)
    end
    if data.supporterData then
        local cardLegendRoad = LegendRoadModel.new(self.playerCardModel)
        cardLegendRoad:RefreshLegendMapModel(data.supporterData)
    end
    EventSystem.SendEvent("PlayerCardsMapModel_ResetCardModel", pcid)
end

function SupporterCtrl:OnEnterScene()
    self.view:EnterScene()
end

function SupporterCtrl:OnExitScene()
    self.view:ExitScene()

end

return SupporterCtrl
