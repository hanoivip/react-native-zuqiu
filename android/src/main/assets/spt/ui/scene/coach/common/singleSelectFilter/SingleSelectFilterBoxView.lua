local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local SingleSelectFilterBoxView = class(unity.base, "SingleSelectFilterBoxView")

function SingleSelectFilterBoxView:ctor()
    self.boxItemPath = self.___ex.boxItemPath

    self.spts = {}
    self.itemRes = nil
    self.currChooseID = 0
    self.hasTitle = true -- 默认有title且不再box中显示
end

function SingleSelectFilterBoxView:start()
end

function SingleSelectFilterBoxView:InitView(filterDatas, filterType)
    res.ClearChildren(self.transform)
    self.spts = {}

    local itemRes = self:GetItemBoxRes()
    if itemRes == nil then
        dump("please fill boxItemPath")
        return
    end

    -- the first one is the title, which means the player don't use this filter type
    local startIdx = self.hasTitle and 2 or 1
    for i = startIdx, table.nums(filterDatas) do
        local filterData = filterDatas[i]
        local obj, spts
        obj = Object.Instantiate(itemRes)
        if obj ~= nil then
            spt = res.GetLuaScript(obj)
            if spt ~= nil then
                obj.transform:SetParent(self.transform, false)
                obj.transform.localScale = Vector3.one
                spt:SetHasTitle(self.hasTitle)
                spt:InitView(filterData, filterType)
                spt.onFilterBoxItemClick = function(id, filterType) self:OnFilterBoxItemClick(id, filterType) end
                table.insert(self.spts, spt)
            end
        end
    end

    table.sort(self.spts, function(a, b)
        return tonumber(a:GetID()) < tonumber(b:GetID())
    end)
end

function SingleSelectFilterBoxView:SetHasTitle(hasTitle)
    self.hasTitle = hasTitle
end

-- 点击筛选盒子中某项
function SingleSelectFilterBoxView:OnFilterBoxItemClick(id, filterType)
    if self.onFilterBoxItemClick and type(self.onFilterBoxItemClick) == "function" then
        self.onFilterBoxItemClick(id, filterType)
    end
end

-- 选中某项
function SingleSelectFilterBoxView:ChooseItem(id)
    if self.hasTitle then
        id = id - 1
    end

    if self.currChooseID > 0 then
        self.spts[self.currChooseID]:SetChoose(false)
    end
    if self.currChooseID ~= id then
        self.currChooseID = id
        if self.currChooseID > 0 then
            self.spts[self.currChooseID]:SetChoose(true)
        end
    else
        self.currChooseID = 0
    end
end

function SingleSelectFilterBoxView:GetItemBoxRes()
    if self.boxItemPath == nil then
        return nil
    end
    if self.itemRes == nil then
        self.itemRes = res.LoadRes(self.boxItemPath)
    end
    return self.itemRes
end

return SingleSelectFilterBoxView
