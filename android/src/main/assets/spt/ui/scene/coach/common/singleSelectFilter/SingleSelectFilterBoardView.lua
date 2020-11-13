local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")

local SingleSelectFilterBoardView = class(unity.base, "SingleSelectFilterBoardView")

function SingleSelectFilterBoardView:ctor()
    -- 处于界面所有物体之上，本filterBoard之下，用于点击空白收起筛选框
    self.filterClickMask = self.___ex.filterClickMask
    -- board item的prefab
    self.boardItemPath = self.___ex.boardItemPath

    self.itemRes = nil
    self.spts = {} -- {filterType=spt}

    self.onFilterItemChoosed = nil -- Set in parent
end

function SingleSelectFilterBoardView:start()
    if self.filterClickMask ~= nil then
        self.filterClickMask:regOnButtonClick(function()
            self:OnMaskClick()
        end)
    end
end

-- @param [singleSelectFilterModel] see AssistCoachFilterModel as an example
function SingleSelectFilterBoardView:InitView(parentModel, parentView, singleSelectFilterModel)
    self.parentModel = assistCoachInformationModel
    self.parentView = assistCoachInformationView
    self.filterModel = singleSelectFilterModel
    self.hasTitle = self.filterModel.HasTitle
    if self.hasTitle == nil then self.hasTitle = true end

    if self.filterModel == nil then
        return
    end

    res.ClearChildren(self.transform)
    self.spts = {}

    local itemRes = self:GetItemBoardRes()
    if itemRes == nil then
        dump("please fill boardItemPath")
        return
    end
    for k, filterType in pairs(self.filterModel.FilterType) do
        local obj, spt
        obj = Object.Instantiate(itemRes)
        if obj ~= nil then
            spt = res.GetLuaScript(obj)
            if spt ~= nil then
                obj.transform:SetParent(self.transform, false)
                obj.transform.localScale = Vector3.one
                spt:SetHasTitle(self.hasTitle)
                if self.filterModel.Style then
                    spt:SetStyle(self.filterModel.Style[filterType])
                end
                spt:InitView(self.parentModel, self.filterModel[filterType], filterType)
                spt.onBoardItemClick = function(filterType, isOpen) self:OnBoardItemClick(filterType, isOpen) end
                spt.onFilterBoxItemClick = function(id, filterType) self:OnFilterBoxItemClick(id, filterType) end
                self.spts[filterType] = spt
            end
        end
    end
    -- 排序
    for filterType, spt in pairs(self.spts) do
        spt.transform:SetSiblingIndex(self.filterModel.FilterTypeSiblingIndex[filterType] - 1)
    end
end

function SingleSelectFilterBoardView:GetItemBoardRes()
    if self.boardItemPath == nil then
        return nil
    end
    if self.itemRes == nil then
        self.itemRes = res.LoadRes(self.boardItemPath)
    end
    return self.itemRes
end

function SingleSelectFilterBoardView:OnEnterScene()
end

function SingleSelectFilterBoardView:OnExitScene()
end

-- 调用此函数在父view中注册点击筛选项的回调
function SingleSelectFilterBoardView:RegOnFilterItemChoosed(func)
    if func ~= nil and type(func) == "function" then
        self.onFilterItemChoosed = func
    end
end

-- 点击打开或关闭筛选盒子
function SingleSelectFilterBoardView:OnBoardItemClick(filterType, isOpen)
    if table.nums(self.spts or {}) > 0 then
        for k, spt in pairs(self.spts) do
            spt:SetBoxState(false)
        end
        if filterType ~= nil then
            self.spts[filterType]:SetBoxState(isOpen)
            self:ActiveFilterMask(isOpen)
        end
    end
end

function SingleSelectFilterBoardView:OnMaskClick()
    self:ActiveFilterMask(false)
    self:SetAllBoxClose()
end

function SingleSelectFilterBoardView:ActiveFilterMask(isActive)
    GameObjectHelper.FastSetActive(self.filterClickMask.gameObject, isActive)
end

function SingleSelectFilterBoardView:SetAllBoxClose()
    for filterType, spt in pairs(self.spts or {}) do
        spt:SetBoxState(false)
    end
end

-- 点击筛选盒子中某项
function SingleSelectFilterBoardView:OnFilterBoxItemClick(id, filterType)
    self:ActiveFilterMask(false)
    if self.onFilterItemChoosed and type(self.onFilterItemChoosed) == "function" then
        self.onFilterItemChoosed(id, filterType)
    end
end

-- 选中某个筛选项
function SingleSelectFilterBoardView:SelectFilterItem(id, filterType)
    self:OnMaskClick()
    if filterType ~= nil then
        local spt = self.spts[filterType]
        if spt then
            spt:SelectFilterItem(id)
        end
    end
end

return SingleSelectFilterBoardView
