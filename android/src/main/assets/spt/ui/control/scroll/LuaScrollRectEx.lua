local ScrollRectEx = clr.UnityEngine.UI.ScrollRectEx
local Direction = ScrollRectEx.Direction
local LuaScrollRectEx = class(unity.base)

function LuaScrollRectEx:ctor()
    self.cScrollRect = self:GetComponent(clr.UnityEngine.UI.ScrollRectEx)
    self.itemDatas = {}
    self.onItemIndexChangedCallback = nil
    self.onScrollPositionChangedCallback = nil
end

function LuaScrollRectEx:refresh(data)
    if type(data) == "table" then
        self.itemDatas = data
    end
    self.cScrollRect:RefreshWithItemCount(#self.itemDatas)  --Lua assist checked flag
end

function LuaScrollRectEx:scrollToCell(index)
    self.cScrollRect:ScrollToCell(index - 1)  --Lua assist checked flag
end

function LuaScrollRectEx:scrollToCellImmediate(index)
    self.cScrollRect:ScrollToCellImmediate(index - 1);  --Lua assist checked flag
end

function LuaScrollRectEx:scrollToPreviousGroup()
    self.cScrollRect:ScrollToPreviousGroup();  --Lua assist checked flag
end

function LuaScrollRectEx:scrollToNextGroup()
    self.cScrollRect:ScrollToNextGroup()  --Lua assist checked flag
end

function LuaScrollRectEx:getItem(index)
    return self.cScrollRect:GetItem(index - 1)  --Lua assist checked flag
end

function LuaScrollRectEx:getStartVisibleItemIndex()
    return self.cScrollRect:GetStartVisibleItemIndex()  --Lua assist checked flag
end

function LuaScrollRectEx:getEndVisibleItemIndex()
    return self.cScrollRect:GetEndVisibleItemIndex()  --Lua assist checked flag
end

function LuaScrollRectEx:getVisibleItems()
    return clr.table(self.GetVisibleItems())
end

function LuaScrollRectEx:addItem(data, index, width, height)
    if not index then index = #self.itemDatas + 1 end
    if type(index) ~= "number" or index < 1 or index > #self.itemDatas + 1 then 
        dump(format("Invalid index: %s", index))
        return
    end

    table.insert(self.itemDatas, index, data)
    if type(width) == "number" and width > 0 and type(height) == "number" and height > 0 then
        self.cScrollRect:AddItem(index - 1, width, height)  --Lua assist checked flag
    else
        self.cScrollRect:AddItem(index - 1)  --Lua assist checked flag
    end
end

function LuaScrollRectEx:addItems(datas, index, width, height)
    if type(datas) ~= "table" then
        dump(format("Invalid data types: %s, should be table", type(datas)))
        return
    end
    if not index then index = #self.itemDatas + 1 end
    if type(index) ~= "number" or index < 1 or index > #self.itemDatas + 1 then 
        dump(format("Invalid index: %s", index))
        return
    end

    for i = 1, #datas do
        table.insert(self.itemDatas, index + i - 1, datas[i])
    end
    
    if type(width) == "number" and width > 0 and type(height) == "number" and height > 0 then
        self.cScrollRect:AddItems(index - 1, #datas, width, height)  --Lua assist checked flag
    else
        self.cScrollRect:AddItems(index - 1, #datas)  --Lua assist checked flag
    end
end

function LuaScrollRectEx:removeItem(index)
    if not index then index = #self.itemDatas end
    if type(index) ~= "number" or index < 1 or index > #self.itemDatas then 
        dump(format("Invalid index: %s", index))
        return
    end

    table.remove(self.itemDatas, index)
    self.cScrollRect:RemoveItem(index - 1)  --Lua assist checked flag
end

function LuaScrollRectEx:removeItems(index, count)
    if not index then index = #self.itemDatas end
    if type(index) ~= "number" or index < 1 or index > #self.itemDatas + 1 then 
        dump(format("Invalid index: %s", index))
        return
    end
    if type(count) ~= "number" then
        count = #self.itemDatas
    end
    if index + count - 1 > #self.itemDatas then
        dump("There is not enough items to remove, remove to end instead")
        count = #self.itemDatas - index + 1
    end

    for i = index + count - 1, index, -1 do
        table.remove(self.itemDatas, i)
    end
    
    self.cScrollRect:RemoveItems(index - 1, count)  --Lua assist checked flag
end

function LuaScrollRectEx:removeAll()
    self:removeItems(1)
end

function LuaScrollRectEx:getItemTag(index)
    return "Default"
end

function LuaScrollRectEx:resetItem(spt, index)
    local tag = self:getItemTag(index)
    local resetItemByTagFunc = self[format("resetItemByTag%s", tag)]
    if type(resetItemByTagFunc) ~= "function" then
        dump(format("Wrong Tag: %s!", tag))
        return
    end
    resetItemByTagFunc(self, spt, index)
    self:updateItemIndex(spt, index)
end

function LuaScrollRectEx:createItem(index)
    local tag = self:getItemTag(index)
    local createItemByTagFunc = self[format("createItemByTag%s", tag)]
    if type(createItemByTagFunc) ~= "function" then
        dump(format("Wrong Tag: %s!", tag))
        return
    end
    local item = createItemByTagFunc(self, index)
    self:resetItem(item:GetComponent(clr.CapsUnityLuaBehav), index)
    return item
end

function LuaScrollRectEx:createLine(index)
    local direction = self.direction
    local obj
    if direction == Direction.Horizontal then
        obj = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Template/Line/V_Line.prefab")
    elseif direction == Direction.Vertical then
        obj = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Template/Line/H_Line.prefab")
    end
    return obj
end

function LuaScrollRectEx:updateItemIndex(spt, index)
    spt.getIndex = function (self)
        return index
    end
end

function LuaScrollRectEx:regOnItemIndexChanged(func)
    if type(func) == "function" then
        self.onItemIndexChangedCallback = func
    end
end

function LuaScrollRectEx:unregOnItemIndexChanged()
    self.onItemIndexChangedCallback = nil
end

function LuaScrollRectEx:onItemIndexChanged(index)
    if type(self.onItemIndexChangedCallback) == "function" then
        self.onItemIndexChangedCallback(index)
    end
end

function LuaScrollRectEx:regOnScrollPositionChanged(func)
    if type(func) == "function" then
        self.onScrollPositionChangedCallback = func
    end
end

function LuaScrollRectEx:unregOnScrollPositionChanged()
    self.onScrollPositionChangedCallback = nil
end

function LuaScrollRectEx:onScrollPositionChanged(position)
    if type(self.onScrollPositionChangedCallback) == "function" then
        self.onScrollPositionChangedCallback(position)
    end
end

return LuaScrollRectEx
