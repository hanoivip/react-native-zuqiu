local LadderShopItemCtrl = require("ui.controllers.ladder.LadderShopItemCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local LadderShopRefreshDialogCtrl = require("ui.controllers.ladder.LadderShopRefreshDialogCtrl")

local LadderShopMainCtrl = class(BaseCtrl)

LadderShopMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderShopBoard.prefab"

function LadderShopMainCtrl:Init(ladderModel)
end

function LadderShopMainCtrl:Refresh(ladderModel)
    self.ladderModel = ladderModel
    LadderShopMainCtrl.super.Refresh(self)
    clr.coroutine(function()
        local respone = req.ladderStore()
        if api.success(respone) then
            local data = respone.val
            if data.hour then
                self.ladderModel:SetShopAutoRefreshTime(data.hour)
            end
            if data.count then
                self.ladderModel:SetShopCostRefreshRemainTimes(data.count)
            end
            if data.goods then
                self.ladderModel:SetShopList(data.goods)
            end
            self:InitView()
        end
    end)
end

function LadderShopMainCtrl:GetStatusData(ladderModel)
    return self.ladderModel
end

function LadderShopMainCtrl:OnEnterScene()
    EventSystem.AddEvent("LadderShopMainCtrl.RefreshShopItems", self, self.RefreshShopItems)
    EventSystem.AddEvent("LadderShopMainCtrl.RefreshMyCurHonorPoint", self, self.RefreshMyCurHonorPoint)
end

function LadderShopMainCtrl:OnExitScene()
    EventSystem.RemoveEvent("LadderShopMainCtrl.RefreshShopItems", self, self.RefreshShopItems)
    EventSystem.RemoveEvent("LadderShopMainCtrl.RefreshMyCurHonorPoint", self, self.RefreshMyCurHonorPoint)
end

function LadderShopMainCtrl:InitView()
    self.view.onBack = function() self:OnBack() end
    self.view.onRefresh = function() self:OnRefresh() end
    self.view.refreshShopItems = function() self:RefreshShopItems() end
    self.view:InitView(self.ladderModel)
end

function LadderShopMainCtrl:OnBack()
    res.PopScene()
end

function LadderShopMainCtrl:OnRefresh()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderShopRefreshDialog.prefab", "camera", true, true)
    local ladderShopRefreshDialogCtrl = LadderShopRefreshDialogCtrl.new(dialogcomp.contentcomp)
    ladderShopRefreshDialogCtrl:InitView(self.ladderModel)
end

function LadderShopMainCtrl:RefreshShopItems()
    local shopList = self.ladderModel:GetShopList()
    self.view:ClearShopItems()
    for index, shopItemData in ipairs(shopList) do
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderShopItem.prefab")
        self.view:AddShopItem(obj)
        local ladderShopItemCtrl = LadderShopItemCtrl.new(spt)
        ladderShopItemCtrl:InitView(self.ladderModel, shopItemData)
    end
end

function LadderShopMainCtrl:RefreshMyCurHonorPoint()
    self.view:RefreshMyCurHonorPoint()
end

return LadderShopMainCtrl