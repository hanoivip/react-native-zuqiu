local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local Vector2 = clr.UnityEngine.Vector2

local GiftBoxScrollView = class(LuaScrollRectExSameSize)

function GiftBoxScrollView:ctor()
    self.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.itemView = {}
end

function GiftBoxScrollView:start()
end

function GiftBoxScrollView:GetScrollPos()
    return self:getScrollNormalizedPos()
end

function GiftBoxScrollView:InitView(giftboxModel, pos)
    self.giftboxModel = giftboxModel
    local data = giftboxModel:GetGiftBoxInfo()
    self:refresh(data, pos)
end

function GiftBoxScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/GiftBoxItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GiftBoxScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    data.vip = data.minVip

    spt:InitView(data)

    local function callback(num)
        clr.coroutine(function ()
            local response = req.buyGiftBag(data.idBox, num)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.gift)
                local cost = data.cost
                if cost.type == "d" then
                    PlayerInfoModel.new():SetDiamond(cost.curr_num)
                    local mInfo = {}
                    mInfo.phylum = "activity"
                    mInfo.classfield = "timeLimit"
                    mInfo.genus = self.itemDatas[index].idBox
                    CustomEvent.ConsumeDiamond("nil", tonumber(data.cost.num), mInfo)
                elseif cost.type == "m" then
                    PlayerInfoModel.new():SetMoney(cost.curr_num)
                elseif cost.type == "bkd" then
                    PlayerInfoModel.new():SetBlackDiamond(cost.curr_num)
                end
            end
        end)
    end

    local id = nil
    local itemType = nil
    for k, v in pairs(data.contents) do
        itemType = k
        id = v[1].id
    end

    local args = {
        boughtTime = data.buyCount,
        limitAmount = data.limitAmount,
        itemId = id,
        currencyType = data.currencytype,
        price = data.price,
        limitType = data.limitType,
        plateType = tonumber(data.plate),
        itemType = itemType,
        vip = data.vip,
    }

    spt.onClickBuy = (function ()
        if data.limitAmount - data.buyCount <= 0 and data.limitType ~= 0 then
            DialogManager.ShowToast(lang.trans("can_buy_is_full"))
            return
        end
        res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args,
            function (num)
                callback(num)
            end)
    end)
end

return GiftBoxScrollView
