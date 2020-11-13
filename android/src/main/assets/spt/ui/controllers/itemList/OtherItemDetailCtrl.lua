local BaseCtrl = require("ui.controllers.BaseCtrl")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local MenuType = require("ui.controllers.itemList.MenuType")
local QuestJumpNodeCtrl = require("ui.controllers.quest.QuestJumpNodeCtrl")
local UISoundManager = require("ui.control.manager.UISoundManager")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")

local OtherItemDetailCtrl = class(BaseCtrl)
OtherItemDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/ItemDetail.prefab"
OtherItemDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function OtherItemDetailCtrl:Init(itemType, model)
    self.itemType = itemType
    self.model = model
    self.playerTeamsModel = PlayerTeamsModel.new()
    self.playerTeamsModel:Init()
end

function OtherItemDetailCtrl:Refresh()
    OtherItemDetailCtrl.super.Refresh(self)
    self:InitView()
end

function OtherItemDetailCtrl:GetStatusData()
    return self.itemType, self.model
end

function OtherItemDetailCtrl:OnEnterScene()
    self.view:EnterScene()
end

function OtherItemDetailCtrl:OnExitScene()
    self.view:ExitScene()
end

function OtherItemDetailCtrl:InitView()
    self.view.onComposite = function()self:OnComposite() end
    self.view.equipNumChangedCallBack = function(eid, num)self:EquipNumChangedCallBack(eid, num) end
    self.view.equipPieceNumChangedCallBack = function(pid, num)self:EquipPieceNumChangedCallBack(pid, num) end
    self.view.itemNumChangedCallBack = function(pid, num)self:ItemNumChangedCallBack(id, num) end
    self.view.onFillCommonSourceContent = function(content)self:OnFillCommonSourceContent(content) end
    self.view:InitView(self.itemType, self.model, ItemOriginType.OTHER)
    if self.itemType ~= MenuType.ITEM then
        self.playerModelList = {}
        self.cardList = {}
        local initPlayerData = self.playerTeamsModel:GetInitPlayersData(self.playerTeamsModel:GetNowTeamId())
        local index = 0
        for k, pcid in pairs(initPlayerData) do
            local playerModel = CardBuilder.GetStarterModel(pcid)
            playerModel:InitEquipsAndSkills()
            local id = nil
            if self.itemType == MenuType.EQUIPPIECE then
                id = self.model:GetPid()
            elseif self.itemType == MenuType.EQUIP then
                id = self.model:GetEid()
            end
            index = index + 1
            playerModel.index = index
            if playerModel:HasNeedEquip(id) then
                table.insert(self.playerModelList, playerModel)
                table.insert(self.cardList, pcid)
            end
        end
        if #self.playerModelList == 0 then
            self.view:ShowOrHidePlayerBoard(false)
        else
            self.view:ShowOrHidePlayerBoard(true)
            self:CreateItemList()
        end
    else
        self.view:ShowOrHidePlayerBoard(false)
    end
end

function OtherItemDetailCtrl:OnComposite()
    local id = nil
    if self.itemType == MenuType.EQUIPPIECE then
        id = self.model:GetPid()
    elseif self.itemType == MenuType.EQUIP then
        id = self.model:GetEid()
    end
    clr.coroutine(function()
        local respone = req.equipIncorporate(id)
        if api.success(respone) then
            UISoundManager.play('Card/synthesis')
            local data = respone.val
            EquipsMapModel.new():ResetEquipNum(data.add_equip.eid, data.add_equip.num)
            EquipPieceMapModel.new():ResetEquipPieceNum(data.del_piece.pid, data.del_piece.num)
        end
    end)
end

function OtherItemDetailCtrl:EquipNumChangedCallBack(eid, num)
    if self.itemType == MenuType.EQUIP then
        if tonumber(self.model:GetEid()) == tonumber(eid) then
            self.view:SetEquipNum(num)
        end
    end
end

function OtherItemDetailCtrl:EquipPieceNumChangedCallBack(pid, num)
    if self.itemType == MenuType.EQUIPPIECE then
        if tonumber(self.model:GetPid()) == tonumber(pid) then
            self.view:SetEquipPieceNum(num)
        end
    end
    if self.itemType == MenuType.EQUIP then
        if tonumber(self.model:GetEid()) == tonumber(pid) then
            self.view:SetEquipPieceNum(num)
        end
    end
end

function OtherItemDetailCtrl:ItemNumChangedCallBack(id, num)
    if self.itemType == MenuType.ITEM then
        if tonumber(self.model:GetId()) == tonumber(id) then
            self.view:SetItemNum(num)
        end
    end
end

function OtherItemDetailCtrl:OnFillCommonSourceContent(content)
    local fromQuest = self.model:GetFromQuest()
    if fromQuest then
        for i = 1, #fromQuest do
            QuestJumpNodeCtrl.new(fromQuest[i].questID, content, false, true)
        end
    end
end

function OtherItemDetailCtrl:CreateItemList()
    self.view.playerBoardScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ItemList/ItemDetailPlayer.prefab")
        return obj, spt
    end
    self.view.playerBoardScrollView.onScrollResetItem = function(spt, index)
        local playerCardModel = self.view.playerBoardScrollView.itemDatas[index]
        spt.onClickCard = function() self:OnClickCard(playerCardModel) end
        spt:InitView(playerCardModel)
        spt:ClearPlayerObject()
        local playerCardObject, playerCardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        spt:AddPlayerCard(playerCardObject)
        playerCardView:InitView(playerCardModel)
        playerCardView:IsShowName(false)
        self.view.playerBoardScrollView:updateItemIndex(spt, index)
    end
    self:RefreshScrollView()
end

function OtherItemDetailCtrl:RefreshScrollView()
    self.view.playerBoardScrollView:clearData()
    for i = 1, #self.playerModelList do
        table.insert(self.view.playerBoardScrollView.itemDatas, self.playerModelList[i])
    end
    self.view.playerBoardScrollView:refresh()
end

function OtherItemDetailCtrl:OnClickCard(playerCardModel)
    -- 先屏蔽
    -- res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", self.cardList, playerCardModel.index, playerCardModel)
end

return OtherItemDetailCtrl
