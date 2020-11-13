local BaseCtrl = require("ui.controllers.BaseCtrl")
local ItemListModel = require("ui.models.itemList.ItemListModel")
local EquipListModel = require("ui.models.itemList.EquipListModel")
local EquipPieceListModel = require("ui.models.itemList.EquipPieceListModel")
local MenuType = require("ui.controllers.itemList.MenuType")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")
local EventSystem = require("EventSystem")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local PasterListMainCtrl = require("ui.controllers.paster.PasterListMainCtrl")
local CoachItemListModel = require("ui.models.itemList.CoachItemListModel")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")

local ItemListMainCtrl = class(BaseCtrl)
ItemListMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/ItemList.prefab"

function ItemListMainCtrl:Init()
    self.itemListModel = ItemListModel.new()
    self.equipListModel = EquipListModel.new()
    self.equipPieceListModel = EquipPieceListModel.new()
    self.coachItemListModel = CoachItemListModel.new()
    self.pasterListMainCtrl = PasterListMainCtrl.new(self.view.pasterView)
    self.menuModelMap = 
    {
        [MenuType.ITEM] = self.itemListModel,
        [MenuType.EQUIP] = self.equipListModel,
        [MenuType.EQUIPPIECE] = self.equipPieceListModel,
        [MenuType.TACTIC] = self.coachItemListModel,
    }
    self.kindMap = {}
    self:InitKindMap()
end

function ItemListMainCtrl:Refresh(currentMenu, currentKinds, currentOrder, currentSelectId, isShowAllKinds)
    ItemListMainCtrl.super.Refresh(self)
    self.currentMenu = currentMenu
    self.currentKinds = currentKinds
    self.currentOrder = currentOrder
    self.currentSelectId = currentSelectId
    self.isShowAllKinds = isShowAllKinds
    self.menuModelMap[self.currentMenu]:InitData(self.currentOrder, self.isShowAllKinds, self.currentKinds)
    self:InitView()
    self:ScrollToCurrentSelect()
    self:ResetKindMap()
end

function ItemListMainCtrl:GetStatusData()
    return self.currentMenu, self.currentKinds, self.currentOrder, self.currentSelectId, self.isShowAllKinds
end

function ItemListMainCtrl:OnEnterScene()
    EventSystem.AddEvent("EquipsMapModel_ResetEquipNum", self, self.EquipNumChanged)
    EventSystem.AddEvent("EquipPieceMapModel_ResetItemNum", self, self.EquipPieceNumChanged)
    EventSystem.AddEvent("ItemsMapModel_ResetItemNum", self, self.ItemNumChanged)
    EventSystem.AddEvent("ItemListMainCtrl_OnCurrentOrderChanged", self, self.OnCurrentOrderChanged)
    self.pasterListMainCtrl:OnEnterScene()
end

function ItemListMainCtrl:OnExitScene()
    EventSystem.RemoveEvent("EquipsMapModel_ResetEquipNum", self, self.EquipNumChanged)
    EventSystem.RemoveEvent("EquipPieceMapModel_ResetItemNum", self, self.EquipPieceNumChanged)
    EventSystem.RemoveEvent("ItemsMapModel_ResetItemNum", self, self.ItemNumChanged)
    EventSystem.RemoveEvent("ItemListMainCtrl_OnCurrentOrderChanged", self, self.OnCurrentOrderChanged)
    self.pasterListMainCtrl:OnExitScene()
end

function ItemListMainCtrl:InitKindMap()
    table.insert(self.kindMap, {id = ItemListConstants.KindId.CLOTH, name = "itemList_clothKindItem", state = ItemListConstants.KindState.UNSELECTED})
    table.insert(self.kindMap, {id = ItemListConstants.KindId.FOOD, name = "itemList_foodKindItem", state = ItemListConstants.KindState.UNSELECTED})
    table.insert(self.kindMap, {id = ItemListConstants.KindId.SHOE, name = "itemList_shoeKindItem", state = ItemListConstants.KindState.UNSELECTED})
    table.insert(self.kindMap, {id = ItemListConstants.KindId.BADGE, name = "itemList_badgeKindItem", state = ItemListConstants.KindState.UNSELECTED})
end

function ItemListMainCtrl:ResetKindMap()
    for index, kindData in ipairs(self.kindMap) do
        kindData.state = ItemListConstants.KindState.UNSELECTED
    end
end

function ItemListMainCtrl:InitView()
    self.view.clickMenu = function(index) self:OnMenuClick(index) end
    self.view.clickFilter = function() self:OnFilterClick() end
    self.view.itemListSortView.clickSort = function(sortType) self:OnSortClick(sortType) end
    self.view:InitView(self.currentMenu)
    self.view.itemListSortView:InitView(self.currentOrder)
    self.view:ShowOrHideFilterButton(self.currentMenu)
    self.view:SwitchFilterButtonState(not self.isShowAllKinds)
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.pasterListMainCtrl:MoveOutScene()
            res.PopScene()
        end)
    end)
    self:SetCurrentKinds()
    self:CreateItemList()
end

function ItemListMainCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ItemList/Item.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local model = self.view.scrollView.itemDatas[index]
        spt:InitView(model, self.currentMenu)
        spt.onClick = function() self:OnClick(model, self.currentMenu) end
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function ItemListMainCtrl:RefreshScrollView()
    if self.currentMenu == MenuType.TACTIC then
        self.view:RefreshCoachView(self.coachItemListModel, self.currentOrder)
        return
    end
    local listData = self.menuModelMap[self.currentMenu]:GetListData()
    self.view.scrollView:clearData()
    for i, id in ipairs(listData) do
        local model = self.menuModelMap[self.currentMenu]:GetModel(id)
        table.insert(self.view.scrollView.itemDatas, model)
    end
    self.view.scrollView:refresh()
end

function ItemListMainCtrl:OnMenuClick(index)
    if index == self.currentMenu then return end
    self.currentMenu = index

    if index == MenuType.PASTER then
        self.pasterListMainCtrl:RefreshView()
    elseif index == MenuType.TACTIC then
        self.coachItemListModel:InitData()
        self.view:RefreshCoachView(self.coachItemListModel, self.currentOrder)
    else
        if index == MenuType.ITEM then 
            local itemNum = tonumber(ReqEventModel.GetInfo("item"))
            if itemNum > 0 then 
                clr.coroutine(function() local respone = req.viewItem() end)
            end
        end
        self:RefreshItemList()
        self.view:ShowOrHideFilterButton(self.currentMenu)
    end
end

function ItemListMainCtrl:OnFilterClick()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/ItemList/ItemFilter.prefab", "camera", true, true)
    self.itemFilterView = dialogcomp.contentcomp
    self.itemFilterView.clickConfirm = function() self:OnConfirmClick() end
    self.itemFilterView.clickReset = function() self:OnResetClick() end
    self.itemFilterView:InitView(self.kindMap)
end

function ItemListMainCtrl:OnSortClick(sortType)
    self.currentOrder = sortType
    self:RefreshItemList()
end

function ItemListMainCtrl:OnConfirmClick()
    if not self:CheckKindChange() then
        return
    end
    local hasKindSelected = false
    for index, kindData in ipairs(self.kindMap) do
        if kindData.script:GetState() == ItemListConstants.KindState.SELECTED then
            hasKindSelected = true
            break
        end
    end
    if hasKindSelected then
        self.isShowAllKinds = false
    else
        self.isShowAllKinds = true
    end
    self:SetKindMapStates()
    self:SetCurrentKinds()
    self:RefreshItemList()

    self.view:SwitchFilterButtonState(not self.isShowAllKinds)
end

function ItemListMainCtrl:SetKindMapStates()
    for index, kindData in ipairs(self.kindMap) do
        kindData.state = kindData.script:GetState()
    end
end

function ItemListMainCtrl:OnResetClick()
    self.isShowAllKinds = true
    for index, kindData in ipairs(self.kindMap) do
        kindData.script:SetState(ItemListConstants.KindState.UNSELECTED)
    end

    if not self:CheckKindChange() then
        return
    end

    self:SetKindMapStates()
    self:SetCurrentKinds()
    self:RefreshItemList()

    self.view:SwitchFilterButtonState(not self.isShowAllKinds)
end

function ItemListMainCtrl:CheckKindChange()
    local isChanged = false
    for index, kindData in ipairs(self.kindMap) do
        if kindData.state ~= kindData.script:GetState() then
            isChanged = true
            break
        end
    end
    return isChanged
end

function ItemListMainCtrl:SetCurrentKinds()
    self.currentKinds = {}
    for index, kindData in ipairs(self.kindMap) do
        if kindData.state == ItemListConstants.KindState.SELECTED then
            table.insert(self.currentKinds, kindData.id)
        end
    end
end

function ItemListMainCtrl:RefreshItemList()
    self.menuModelMap[self.currentMenu]:InitData(self.currentOrder, self.isShowAllKinds, self.currentKinds)
    self:RefreshScrollView()
end

function ItemListMainCtrl:OnClick(model, currentMenu)
    if currentMenu == MenuType.EQUIP then
        self.currentSelectId = model:GetEid()
    elseif currentMenu == MenuType.EQUIPPIECE then
        self.currentSelectId = model:GetPid()
    elseif currentMenu == MenuType.ITEM then
        self.currentSelectId = model:GetId()
        local usage = model:GetUsage()
        if tonumber(usage) == 1 then
            res.PushDialog("ui.controllers.itemList.GiftBoxDetailCtrl", model)
            return
        end
    end

    -- 暂时关闭详情功能
    res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", currentMenu, model, ItemOriginType.ITEMLIST)
end

function ItemListMainCtrl:EquipNumChanged(eid, num)
    if self.currentMenu == MenuType.EQUIP then
        if num == 0 then
            local index = self:FindEquipIndex(eid)
            if index then
                self.view.scrollView:removeItem(index)
            end
        end
    end
end

function ItemListMainCtrl:EquipPieceNumChanged(pid, num)
    if self.currentMenu == MenuType.EQUIPPIECE then
        if num == 0 then
            local index = self:FindEquipPieceIndex(pid)
            if index then
                self.view.scrollView:removeItem(index)
            end
        end
    end
end

function ItemListMainCtrl:ItemNumChanged(id, num)
    if self.currentMenu == MenuType.ITEM then
        if num == 0 then
            local index = self:FindItemIndex(id)
            if index then
                self.view.scrollView:removeItem(index)
            end
        end
    end
    self:RefreshItemList()
end

function ItemListMainCtrl:FindEquipIndex(eid)
    local itemDatas = self.view.scrollView.itemDatas
    for i = 1, #itemDatas do
        if itemDatas[i]:GetEid() == tostring(eid) then
            return i
        end
    end
    return nil
end

function ItemListMainCtrl:FindEquipPieceIndex(pid)
    local itemDatas = self.view.scrollView.itemDatas
    for i = 1, #itemDatas do
        if itemDatas[i]:GetPid() == tostring(pid) then
            return i
        end
    end
    return nil
end

function ItemListMainCtrl:FindItemIndex(id)
    local itemDatas = self.view.scrollView.itemDatas
    for i = 1, #itemDatas do
        if itemDatas[i]:GetId() == tostring(id) then
            return i
        end
    end
    return nil
end

function ItemListMainCtrl:ScrollToCurrentSelect()
    if self.currentSelectId then
        local index = nil
        if self.currentMenu == MenuType.EQUIP then
            index = self:FindEquipIndex(self.currentSelectId)
        elseif self.currentMenu == MenuType.EQUIPPIECE then
            index = self:FindEquipPieceIndex(self.currentSelectId)
        elseif self.currentMenu == MenuType.ITEM then
            index = self:FindItemIndex(self.currentSelectId)
        end
        if index then
            self.view.scrollView:scrollToCellImmediate(index)
        end
    end
end

function ItemListMainCtrl:OnCurrentOrderChanged(currentOrder)
    if currentOrder then
        self.currentOrder = currentOrder
    end
end

return ItemListMainCtrl
