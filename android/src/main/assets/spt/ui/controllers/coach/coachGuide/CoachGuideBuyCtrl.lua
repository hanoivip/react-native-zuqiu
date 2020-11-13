local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachGuidePrice = require("data.CoachGuidePrice")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CommonConstants = require("ui.common.CommonConstants")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CoachGuideBuyCtrl = class(BaseCtrl)

CoachGuideBuyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachGuide/CoachGuideBuyBoard.prefab"

function CoachGuideBuyCtrl:Init()
    self.view.onConfirmClick = function() self:OnClickConfirm() end
    self.playerInfoModel = PlayerInfoModel.new()
    self.pasterPiecesMapModel = PasterPiecesMapModel.new()
end

function CoachGuideBuyCtrl:Refresh(guideItemData)
    CoachGuideBuyCtrl.super.Refresh(self)
    self.guideItemData = guideItemData

    local slotId = tostring(guideItemData.id)
    local priceData = CoachGuidePrice[slotId]
    local priceCost = priceData.cost
    local weekCount, monthCount = 0

    -- 获取配表中的月贴和周贴的数量
    -- {
    --  贴纸类型id = 贴纸数量
    --  pasterPiece = {[1] = {15}, [2] = {15}}
    -- }
    for k,v in pairs(priceCost.pasterPiece) do
        if tonumber(k) == CommonConstants.PieceWeek then
           weekCount = tonumber(v)
        else
           monthCount = tonumber(v)
        end
    end

    self.guideItemData.dCount = priceCost.d or 0
    self.guideItemData.mCount = priceCost.m or 0
    self.guideItemData.weekCount = weekCount
    self.guideItemData.monthCount = monthCount

    self.view:InitView(self.guideItemData)
end

function CoachGuideBuyCtrl:OnClickConfirm()
    local dCount = self.guideItemData.dCount
    local mCount = self.guideItemData.mCount
    local weekCount = self.guideItemData.weekCount
    local monthCount = self.guideItemData.monthCount
    local nowMCount = self.playerInfoModel:GetMoney()
    if nowMCount < mCount then
        DialogManager.ShowToastByLang("euro_not_enough")
        return
    end

    local mowWeekCount = self.pasterPiecesMapModel:GetPieceNum(CommonConstants.PieceWeek)
    if mowWeekCount < weekCount then
        DialogManager.ShowToastByLang("coach_guide_piece_lack")
        return
    end

    local mowMonthCount = self.pasterPiecesMapModel:GetPieceNum(CommonConstants.PieceMonth)
    if mowMonthCount < monthCount then
        DialogManager.ShowToastByLang("coach_guide_piece_lack")
        return
    end

    CostDiamondHelper.CostDiamond(dCount, self.view, function() self:BuySlot() end)
end

function CoachGuideBuyCtrl:BuySlot()
    self.view:coroutine(function()
        local response = req.coachGuideUnlock()
        if api.success(response) then
            local data = response.val
            local cost = data.cost
            self.playerInfoModel:CostDetail(cost.d or {})
            self.playerInfoModel:CostDetail(cost.m or {})
            self.pasterPiecesMapModel:UpdateFromReward(cost)
            EventSystem.SendEvent("CoachGuideCtrl_SlotPlayerChange", data.coach)
            self.view:Close()
            --可能要触发引导
            EventSystem.SendEvent("CoachGuideCtrl_GuideToPlayerChoice")
        end
    end)
end

return CoachGuideBuyCtrl
