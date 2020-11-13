local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerSearchCtrl = class(BaseCtrl)

PlayerSearchCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

PlayerSearchCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardIndex/PlayerSearchBoard.prefab"

function PlayerSearchCtrl:GetStatusData()
    return self.playerListModel, self.cardIndexViewModel
end

function PlayerSearchCtrl:Init(playerListModel, cardIndexViewModel)
    self.playerListModel = playerListModel
    self.cardIndexViewModel = cardIndexViewModel
    self.view.clickConfirm = function(pos, quality, nationality, name, skill) self:OnBtnConfirm(pos, quality, nationality, name, skill) end
    self.view.clickReset = function() self:OnBtnReset() end
end

function PlayerSearchCtrl:Refresh(playerListModel, cardIndexViewModel)
    PlayerSearchCtrl.super.Refresh(self)
    self.cardIndexViewModel:InitViewData(playerListModel)
    self.view:InitView(playerListModel, cardIndexViewModel)
    self:CreateSkillItemList()
end

function PlayerSearchCtrl:CreateSkillItemList()
    self.view.skillScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardIndex/SkillItemListButton.prefab")
        return obj, spt
    end
    self.view.skillScrollView.onScrollResetItem = function(spt, index)
        local itemData = self.view.skillScrollView.itemDatas[index]
        spt:InitView(self.view, 2, itemData)
        self.view.skillScrollView:updateItemIndex(spt, index)
    end
    self:RefreshSkillList()
end

function PlayerSearchCtrl:RefreshSkillList()
    local skills = self.cardIndexViewModel:GetSkillList()
    self.view.skillScrollView:clearData()
    for i = 1, #skills do
        table.insert(self.view.skillScrollView.itemDatas, skills[i])
    end
    self.view.skillScrollView:refresh()
end

function PlayerSearchCtrl:OnBtnConfirm(pos, quality, nationality, name, skill)
    local typeIndex = self.playerListModel:GetSelectTypeIndex()
    self.playerListModel:SortCardList(typeIndex, pos, quality, nationality, name, skill)
end

function PlayerSearchCtrl:OnBtnReset()
    self.view:OnReset()
end

return PlayerSearchCtrl
