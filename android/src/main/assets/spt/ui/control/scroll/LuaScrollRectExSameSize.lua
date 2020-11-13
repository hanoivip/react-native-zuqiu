local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local ScrollRectExSameSize = clr.ScrollRectExSameSize
local Direction = ScrollRectExSameSize.Direction

local LuaScrollRectExSameSize = class(unity.base)

function LuaScrollRectExSameSize:ctor()
    self.cScroll = self:GetComponent(ScrollRectExSameSize)
    self.itemDatas = {}
    self.onItemIndexChangedCallback = nil
    self.onScrollPositionChangedCallback = nil
end

-- scrollPos 滑动到指定位置不用刷新之前位置数据
function LuaScrollRectExSameSize:refresh(data, scrollPos)
    if type(data) ~= "table" then
        data = self.itemDatas
    end
    self:clearData()
    self.itemDatas = data
    if scrollPos then 
        self.cScroll:RefreshWithItemCountByScrollPos(#self.itemDatas, scrollPos)
    else
        self.cScroll:RefreshWithItemCount(#self.itemDatas)
    end
end

function LuaScrollRectExSameSize:calcCellCount()
    self.cScroll:CalcCellCount()
end

function LuaScrollRectExSameSize:recalcCellCountWithViewSize(width, height)
    self.cScroll:RecalcCellCountWithViewSize(width, height)
end

function LuaScrollRectExSameSize:scrollToCell(index)
    self.cScroll:ScrollToCell(index - 1)
end

function LuaScrollRectExSameSize:scrollToCellEx(index)
    self.cScroll:ScrollToCellEx(index - 1)
end

function LuaScrollRectExSameSize:scrollToCellImmediate(index)
    self.cScroll:ScrollToCellImmediate(index - 1);
end

function LuaScrollRectExSameSize:scrollToPreviousGroup()
    self.cScroll:ScrollToPreviousGroup();
end

function LuaScrollRectExSameSize:scrollToNextGroup()
    self.cScroll:ScrollToNextGroup()
end

function LuaScrollRectExSameSize:scrollToPosImmediate(normalizedPos)
    self.cScroll:ScrollToPosImmediate(normalizedPos)
end

function LuaScrollRectExSameSize:getScrollNormalizedPos()
    return self.cScroll:GetScrollToPosNormalizedPos()
end

function LuaScrollRectExSameSize:getItem(index)
    local item = self.cScroll:GetSelectItem(index)
    return item and item:GetComponent(clr.CapsUnityLuaBehav)   
end

function LuaScrollRectExSameSize:addItem(data, index)
    if not index then index = #self.itemDatas + 1 end
    if type(index) ~= "number" or index < 1 or index > #self.itemDatas + 1 then 
        dump(format("Invalid index: %s", index))
        return
    end

    table.insert(self.itemDatas, index, data)
    self.cScroll:AddItem(index - 1)
end

function LuaScrollRectExSameSize:removeItem(index)
    if not index then index = #self.itemDatas end
    if type(index) ~= "number" or index < 1 or index > #self.itemDatas then 
        dump(format("Invalid index: %s", index))
        return
    end

    table.remove(self.itemDatas, index)
    self.cScroll:RemoveItem(index - 1)
end

function LuaScrollRectExSameSize:removeAll()
    self.cScroll:RemoveAllItem()
    self.itemDatas = {}
end

function LuaScrollRectExSameSize:clearData()
    self.cScroll:ClearData()
    self.itemDatas = {}
end

function LuaScrollRectExSameSize:getMaxPerLine()
    return self.cScroll:GetMaxPerLine()
end

function LuaScrollRectExSameSize:createLine(index)
    local direction = self.cScroll:GetDirection()
    local obj
    if direction == Direction.Horizontal then
        obj = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Template/Line/V_Line.prefab")
        obj.transform.sizeDelta = Vector2(self.cScroll:GetLineSpace(), self.transform.rect.height)
    elseif direction == Direction.Vertical then
        obj = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Template/Line/H_Line.prefab")
        obj.transform.sizeDelta = Vector2(self.transform.rect.width, self.cScroll:GetLineSpace())
    end
    return obj
end

function LuaScrollRectExSameSize:regOnCreateLine(func)
    if type(func) == "function" then
        self.createLine = func
    end
end

function LuaScrollRectExSameSize:unregOnCreateLine()
    self.createLine = nil
end

function LuaScrollRectExSameSize:regOnCreateItem(func)
    if type(func) == "function" then
        self.createItem = func
    end
end

function LuaScrollRectExSameSize:unregOnCreateItem()
    self.createItem = nil
end

function LuaScrollRectExSameSize:regOnResetItem(func)
    if type(func) == "function" then
        self.resetItem = func
    end
end

function LuaScrollRectExSameSize:unregOnResetItem()
    self.resetItem = nil
end

function LuaScrollRectExSameSize:updateItemIndex(spt, index)
    spt.getIndex = function (self)
        return index
    end
end

function LuaScrollRectExSameSize:regOnItemIndexChanged(func)
    if type(func) == "function" then
        self.onItemIndexChangedCallback = func
    end
end

function LuaScrollRectExSameSize:unregOnItemIndexChanged()
    self.onItemIndexChangedCallback = nil
end

function LuaScrollRectExSameSize:onItemIndexChanged(index)
    if type(self.onItemIndexChangedCallback) == "function" then
        self.onItemIndexChangedCallback(index)
    end
end

function LuaScrollRectExSameSize:regOnScrollPositionChanged(func)
    if type(func) == "function" then
        self.onScrollPositionChangedCallback = func
    end
end

function LuaScrollRectExSameSize:unregOnScrollPositionChanged()
    self.onScrollPositionChangedCallback = nil
end

function LuaScrollRectExSameSize:onScrollPositionChanged(position)
    if type(self.onScrollPositionChangedCallback) == "function" then
        self.onScrollPositionChangedCallback(position)
    end
end

function LuaScrollRectExSameSize:ResetWithCellSize(width, height)
    self.cScroll:ResetWithCellSize(width, height)
end

function LuaScrollRectExSameSize:ResetWithViewSize(width, height)
    self.cScroll:ResetWithViewSize(width, height)
end

function LuaScrollRectExSameSize:ResetWithCellSpace(width, height)
    self.cScroll:ResetWithCellSpace(width, height)
end

function LuaScrollRectExSameSize:destroyItem(index)
end

return LuaScrollRectExSameSize

