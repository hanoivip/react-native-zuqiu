local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ArenaStoreModel = require("ui.models.arena.store.ArenaStoreModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local ProbabilityType = require("ui.scene.itemList.ProbabilityType")
local DialogManager = require("ui.control.manager.DialogManager")
local MailRewardType = require("ui.scene.mail.MailRewardType")
local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")

local GiftBoxDetailCtrl = class(BaseCtrl, "GiftBoxDetailCtrl")

GiftBoxDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/GiftBoxDetail.prefab"

GiftBoxDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function GiftBoxDetailCtrl:Init(itemModel, notShowBtn, isShowCounter)
    self.view.buyStoreItem = function (id, num) self:BuyStoreItem(id, num) end
    self.view.buyStoreItemMulti = function () self:BuyStoreItemMulti() end
end

function GiftBoxDetailCtrl:Refresh(itemModel, notShowBtn, isShowCounter)
    self.itemModel = itemModel
    self.notShowBtn = notShowBtn
    if isShowCounter == nil then
        self.isShowCounter = true
    else
        self.isShowCounter = isShowCounter
    end
    self.view:InitView(itemModel, notShowBtn)
    self.view:SetCounterViewVisible(self.isShowCounter)
end

function GiftBoxDetailCtrl:GetStatusData(itemModel, notShowBtn)
    return self.itemModel, self.notShowBtn
end

function GiftBoxDetailCtrl:BuyStoreItem(id ,num)
    if self.view.itemType == ProbabilityType.Options then
        res.PushDialog("ui.controllers.itemList.OptionRewardCtrl", self.view.itemModel, num)
        self.view:Close()
        return
    end
    local rewardType = self.itemModel:GetRewardType()
    if rewardType == MailRewardType.AdvItem then
        local callback = function(data)
            local base = data.base
            local ret = data.ret
            local cost = nil
            local contents = nil
            if ret then
                cost = ret.cost
                contents = ret.contents
            end
            if not table.isEmpty(contents) then
                CongratulationsPageCtrl.new(contents)
            end
            EventSystem.SendEvent("Greensward_RefreshBaseInfo", base)
            self.view:RefreshItemCount(cost.id, cost.num)
            if tonumber(cost.num) == 0 then
                self.view:Close()
            end
        end
        UseItemHelper.Use(id, nil, nil, callback)
    else
        clr.coroutine(function()
            local response = req.useItem(id, num)
            if api.success(response) then
                local data = response.val
                self:ShowCongratulationsPage(data)
                ItemsMapModel.new():ResetItemNum(data.item.id, data.item.num)
                self.view:RefreshItemCount(data.item.id, data.item.num)
                if tonumber(data.item.num) == 0 then
                    self.view:Close()
                end
            end
        end)
    end
end

function GiftBoxDetailCtrl:BuyStoreItemMulti()
    if self.view.itemType == ProbabilityType.Options then
        res.PushDialog("ui.controllers.itemList.OptionRewardCtrl", self.view.itemModel, self.view.itemModel:GetItemNum())
        self.view:Close()
        return
    end
    self.view:Close()
    clr.coroutine(function ()
        local response = req.multiUseItem(self.view.itemModel:GetId())
        if api.success(response) then
            local data = response.val
            self:ShowCongratulationsPage(data)
            ItemsMapModel.new():ResetItemNum(data.item.id, data.item.num)
        end
    end)
end

function GiftBoxDetailCtrl:ShowCongratulationsPage(data)
    -- 使用语音包礼盒是特殊情况 不弹出奖励界面
    --local VoicePack = require("data.VoicePack")
    -- local isVoicePack = (VoicePack[data.item.id] and true)
    -- if isVoicePack then
    --     DialogManager.ShowToastByLang("comment_use_success")
    -- else
        CongratulationsPageCtrl.new(data.contents)
    -- end
end

return GiftBoxDetailCtrl