local CouponInfoBarCtrl = require("ui.controllers.activity.content.CouponInfoBarCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

-- 刷新商店需要花费的钻石
local ConstRefreshCostDiamond = 100

-- 钻石不够的充值提示
local function ShowChargeTips()
    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_gacha_tip"), function()
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    end, nil)
end

local DiscountStoreCtrl = class(BaseCtrl, "DiscountStoreCtrl")

DiscountStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheel/DiscountStore.prefab"

function DiscountStoreCtrl:Init(luckyWheelModel)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = CouponInfoBarCtrl.new(child, self, luckyWheelModel)
    end)
    self.view.onBtnBuy = function(cid, originPrice, couponID)
        self:BuyCard(cid, originPrice, couponID)
    end
    self.view.onCardClick = function(cid)
        local currentModel = CardBuilder.GetBaseCardModel(cid)
        res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
    end
    self.view.onBtnRefresh = function()
        local restRefreshTimes = self.luckyWheelModel:GetRestRefreshTimes()
        if restRefreshTimes <= 0 then
            return
        end

        local diamond = self.playerInfoModel:GetDiamond()
        if diamond < ConstRefreshCostDiamond then
            ShowChargeTips()
            return
        end

        local content = lang.trans("refresh_player_content", 100)
        DialogManager.ShowConfirmPop(lang.trans("tips"), content, function()
            clr.coroutine(function()
                local response = req.luckWheelRefresh()
                if api.success(response) then
                    local data = response.val
                    self.luckyWheelModel:SetRestRefreshTimes(data.restRefreshTimes)
                    self.luckyWheelModel:SetDiscountStore(data.store)
                    self.playerInfoModel:SetDiamond(data.d)
                end
            end)
        end)

    end

    if not self.playerInfoModel then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    self.view:InitView(luckyWheelModel)
end

function DiscountStoreCtrl:Refresh(luckyWheelModel)
    DiscountStoreCtrl.super.Refresh(self)
    self.luckyWheelModel = luckyWheelModel
    self.view:Refresh(luckyWheelModel)
    if self.infoBarCtrl then
        self.infoBarCtrl:InitView(luckyWheelModel)
    end
end

function DiscountStoreCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function DiscountStoreCtrl:OnExitScene()
    self.view:OnExitScene()
end

local function showTipsDialog(msg, btnText, callback)
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab", "overlay", true, true, nil, nil, 10000)
    local content = { }
    content.title = lang.trans("tips")
    content.content = msg
    content.button1Text = btnText
    content.button2Text = lang.trans("cancel")
    content.onButton1Clicked = callback

    dialogcomp.contentcomp:initData(content)
end

function DiscountStoreCtrl:BuyCard(cid, originPrice, couponID)
    -- 缺少折扣券
    local couponModel = self.luckyWheelModel:GetCouponModel(couponID)
    if couponModel:GetNum(couponID) <= 0 then
        local msg = lang.trans("discountStore_couponNotEnoughTips", couponModel:GetName())
        local btnText = lang.trans("discountStore_gotoLuckyWheelTips")
        local callback = function()
            res.PopScene()
        end
        showTipsDialog(msg, btnText, callback)
        return
    end
    -- 缺少钻石
    local discountPirce = couponModel:GetDiscount() * originPrice / 10
    if self.playerInfoModel:GetDiamond() < discountPirce then
        ShowChargeTips()
        return
    end

    local cardModel = CardBuilder.GetBaseCardModel(cid)
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/LuckyWheel/DiscountDetailBoard.prefab", "camera", true, true)
    local detailBoardView = dialogcomp.contentcomp
    detailBoardView:InitView(cardModel, discountPirce, couponModel)
    detailBoardView.onBtnBuy = function(completeCallback)
        clr.coroutine(function()
            local response = req.luckWheelBuy(cid, couponID)
            if api.success(response) then
                local data = response.val
                self.luckyWheelModel:SetTreasure(data.treasure)
                self.playerInfoModel:SetDiamond(data.d)
                CongratulationsPageCtrl.new(data.contents)

                if type(completeCallback) == "function" then
                    completeCallback()
                end
            end
        end)
    end
end

function DiscountStoreCtrl:GetStatusData()
    return self.luckyWheelModel
end

return DiscountStoreCtrl
