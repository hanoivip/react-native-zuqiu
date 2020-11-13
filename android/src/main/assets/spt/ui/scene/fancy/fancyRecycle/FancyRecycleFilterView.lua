local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local FancySort = require("data.FancySort")
local FancyGroup = require("data.FancyGroup")

local FancyRecycleFilterView = class()

function FancyRecycleFilterView:ctor()
--------Start_Auto_Generate--------
    self.sortBtnGroupSpt = self.___ex.sortBtnGroupSpt
    self.groupBtnGroupSpt = self.___ex.groupBtnGroupSpt
    self.confirmBtn = self.___ex.confirmBtn
    self.resetBtn = self.___ex.resetBtn
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.tabPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyRecycle/FancyFilterTabItem.prefab"
end

function FancyRecycleFilterView:start()
    self:BindButtonHandler()
end

function FancyRecycleFilterView:BindButtonHandler()
    self.confirmBtn:regOnButtonClick(function()
        self:OnConfirmClick()
    end)

    self.resetBtn:regOnButtonClick(function()
        self:OnResetClick()
    end)

    self.closeBtn:regOnButtonClick(function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function FancyRecycleFilterView:InitView(groupIds)
    self:InitSort(groupIds)
end

function FancyRecycleFilterView:InitSort(groupIds)
    local tabRes = res.LoadRes(self.tabPath)
    self.sortBtnGroupSpt.menu = {}
    for i, v in pairs(FancySort) do
        local searchObject = Object.Instantiate(tabRes)
        local spt = res.GetLuaScript(searchObject)
        searchObject.transform:SetParent(self.sortBtnGroupSpt.transform, false)
        self.sortBtnGroupSpt.menu[i] = spt
        spt:InitView(v.sortName)
        self.sortBtnGroupSpt:BindMenuItem(i, function()
            self:OnSortTabClick(i)
        end)
    end
    if groupIds then
        local index, gid = next(groupIds)
        if gid then
            gid = tostring(gid)
            local defaultSortId = tostring(FancyGroup[gid].sortID)
            self.sortBtnGroupSpt:selectMenuItem(defaultSortId)
            self:InitGroup(defaultSortId)
            local t = {}
            for i, v in pairs(groupIds) do
                t[v] = true
            end
            self.groupBtnGroupSpt:SetMultipleDefaultSelectTags(t)
        end
    end
end

function FancyRecycleFilterView:InitGroup(sortId)
    res.ClearChildren(self.groupBtnGroupSpt.transform)
    local tabRes = res.LoadRes(self.tabPath)
    local groups = FancySort[sortId].groupID
    self.groupBtnGroupSpt.menu = {}
    for i, v in pairs(groups) do
        local gData = FancyGroup[v]
        local searchObject = Object.Instantiate(tabRes)
        local spt = res.GetLuaScript(searchObject)
        searchObject.transform:SetParent(self.groupBtnGroupSpt.transform, false)
        self.groupBtnGroupSpt.menu[v] = spt
        spt:InitView(gData.groupName)
        self.groupBtnGroupSpt:BindMenuItem(v, function()
            self:OnGroupTabClick(v)
        end)
    end
    self.groupBtnGroupSpt:CanMultipleSelect(true)
end

function FancyRecycleFilterView:OnSortTabClick(sortTag)
    self.sortTag = sortTag
    res.ClearChildren(self.groupBtnGroupSpt.transform)
    self:InitGroup(sortTag)
end

-- 回调 必要
function FancyRecycleFilterView:OnGroupTabClick(groupTag)
end

function FancyRecycleFilterView:OnConfirmClick()
    local tags = self.groupBtnGroupSpt:GetMultipleSelectTags()
    local groupIds = {}
    if  tags and next(tags) then
        for i, v in pairs(tags) do
            table.insert(groupIds, tostring(i))
        end
    else
        if self.sortTag then
            for i, v in pairs(FancySort[self.sortTag].groupID) do
                table.insert(groupIds, tostring(v))
            end
        end
    end
    EventSystem.SendEvent("FancyRecycleFilter_Confirm", groupIds)
    self:Close()
end

function FancyRecycleFilterView:OnResetClick()
    self.sortTag = nil
    EventSystem.SendEvent("FancyRecycleFilter_Reset")
    self:Close()
end

function FancyRecycleFilterView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return FancyRecycleFilterView
