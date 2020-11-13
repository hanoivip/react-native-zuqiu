local EventSystem = require("EventSystem")
local DreamStoreModel = require("ui.models.dreamLeague.dreamStore.DreamStoreModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local DreamStoreCtrl = class(BaseCtrl)

DreamStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/DreamStore.prefab"

function DreamStoreCtrl:Refresh(selectTag)
    self.selectTag = selectTag
    DreamStoreCtrl.super.Refresh(self)
    self.playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
    clr.coroutine(function()
        local response = req.dreamShopInfo()
        if api.success(response) then
            local data = response.val
            self.dreamStoreModel = DreamStoreModel.new(data)
            self.view:InitView(self.dreamStoreModel, self.selectTag)
        end
    end)

    self.view.clickBuyItem = function(itemData) self:OnClickBuyItem(itemData) end
    self.view.clickBuyCard = function(cardData) self:OnClickBuyCard(cardData) end
    self.view.changeTag = function(selectTag) self:OnClickChangeTag(selectTag) end
end

function DreamStoreCtrl:OnClickBuyItem(itemData)
    clr.coroutine(function()
        local response = req.dreamShopBuy(itemData.itemId)
        if api.success(response) then
            local data = response.val
            if data.contents then
                if data.cost.type == "dc" then
                    PlayerInfoModel.new():SetDreamCoin(data.cost.curr_num)
                end
                CongratulationsPageCtrl.new(data.contents)
                self:Refresh(self.selectTag)
            end
        end
    end)
end

function DreamStoreCtrl:OnClickBuyCard(cardData)
    clr.coroutine(function()
        local response = req.dreamShopBuy(cardData.itemId)
        if api.success(response) then
            local data = response.val
            local playerInfoModel = PlayerInfoModel.new()
            if data.cost.type == "dp" then
                playerInfoModel:SetDreamPoint(data.cost.curr_num)
            end
            if data.contents and data.contents.item then
                for k,v in pairs(data.contents.item) do
                    self:OpenCardPack(tonumber(v.id), tonumber(v.add))
                end
            end
        end
    end)
end

function DreamStoreCtrl:OpenCardPack(itemId, num)
    clr.coroutine(function()
        local response = req.useItem(itemId, num or 1)
        if api.success(response) then
            local data = response.val
            local playerInfoModel = PlayerInfoModel.new()
            if data.cost then
                playerInfoModel:UpdateFromReward(data.cost)
            end
            if data.contents then
                CongratulationsPageCtrl.new(data.contents)
            end
        end
    end)
end

function DreamStoreCtrl:OnClickChangeTag(selectTag)
   self.selectTag = selectTag
end

function DreamStoreCtrl:OnEnterScene()
    EventSystem.AddEvent("DreamMainCtrl_Refresh", self, self.Refresh)
end

function DreamStoreCtrl:OnExitScene()
    EventSystem.RemoveEvent("DreamMainCtrl_Refresh", self, self.Refresh)
end

function DreamStoreCtrl:GetStatusData()
    return self.selectTag
end

return DreamStoreCtrl
