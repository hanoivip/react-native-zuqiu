local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local ScrollRect = UI.ScrollRect

local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local ScrollViewSameSize = class(LuaScrollRectExSameSize)

-- A common script to use with ScrollViewExSameSize

-- requires one of the following extras:
--   itemRes: Game Object of the item template, should be child of it's Content Transform
--   itemResPath: path of the item prefab

-- use ScrollViewSameSize:RegOnItemButtonClick to reg a callback for button on item

function ScrollViewSameSize:ctor()
    ScrollViewSameSize.super.ctor(self)

    self.itemResPath = self.___ex.itemResPath
    self.itemRes = self.___ex.itemRes

    assert(self.itemResPath or self.itemRes)
    assert(not (self.itemResPath and self.itemRes))

    GameObjectHelper.FastSetActive(self.itemRes, false)

    self.onItemButtonClicks = {}
end

function ScrollViewSameSize:GetItemRes()
    if not self.itemRes and self.itemResPath then
        self.itemRes = res.LoadRes(self.itemResPath)
    end
    return self.itemRes
end

function ScrollViewSameSize:createItem(index)
    local itemRes = self:GetItemRes()
    local obj
    if index == 1 and itemRes.transform.parent then
        -- use the template if it's already in the view hierarchy
        obj = itemRes
    else
        obj = Object.Instantiate(itemRes)
    end

    local spt = res.GetLuaScript(obj)

    GameObjectHelper.FastSetActive(obj, true)

    if spt then
        self:resetItem(spt, index)
    end
    return obj
end

function ScrollViewSameSize:resetItem(spt, index)
    local data = self.data[index]
    for name, func in pairs(self.onItemButtonClicks) do
        if spt[name] then
            spt[name]:regOnButtonClick(function() func(data) end)
        else
            dump("Button [" .. name .. "] is not exist in scroll item", "ScrollViewSameSize:resetItem")
        end
    end
    spt:InitView(data, unpack(self.args, 1, self.argc))
    self:updateItemIndex(spt, index)
end

function ScrollViewSameSize:InitView(model, ...)
    self.data = model
    self.args = {...}
    self.argc = select("#", ...)
    self:refresh(self.data)
end

function ScrollViewSameSize:RegOnItemButtonClick(buttonName, func)
    -- save func to table
    self.onItemButtonClicks[buttonName] = func
end

function ScrollViewSameSize:UpdateItem(index, itemModel)
    self.data[index] = itemModel
    local spt = self:getItem(index)
    if spt ~= nil then
        self:resetItem(spt, index)
    end
end

function ScrollViewSameSize:GetScrollRect()
    return self:GetComponent(ScrollRect)
end

function ScrollViewSameSize:GetScrollNormalizedPosition()
    local scrollRect = self:GetScrollRect()
    assert(scrollRect.horizontal ~= scrollRect.vertical)

    if scrollRect.horizontal then
        return scrollRect.horizontalNormalizedPosition
    elseif scrollRect.vertical then
        return scrollRect.verticalNormalizedPosition
    end
end

function ScrollViewSameSize:SetScrollNormalizedPosition(scrollNormalizedPosition)
    local scrollRect = self:GetScrollRect()
    assert(scrollRect.horizontal ~= scrollRect.vertical)

    if scrollRect.horizontal then
        scrollRect.horizontalNormalizedPosition = scrollNormalizedPosition
    elseif scrollRect.vertical then
        scrollRect.verticalNormalizedPosition = scrollNormalizedPosition
    end
end

return ScrollViewSameSize
