local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local ScrollRectExSameSize = clr.ScrollRectExSameSize
local Direction = ScrollRectExSameSize.Direction

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local ScrollViewSameSizeExample = class(LuaScrollRectExSameSize)

function ScrollViewSameSizeExample:ctor()
    self.super.ctor(self)
end

function ScrollViewSameSizeExample:start()
    --[[
    self:regOnItemIndexChanged(function (index)
        dump(format("current index: %d", index))
    end)
    --]]
    --[[
    self:regOnScrollPositionChanged(function (position)
        dump(format("current position: %.2f", position))
    end)
    --]]
    for i = 1, 500 do
        self.itemDatas[i] = {text = i}
    end
    self:refresh()

    local newIndex = 0
    self.___ex.addButton:regOnButtonClick(function (eventData)
        newIndex = newIndex + 1
        self:addItem({text = format("new%d", newIndex)}, 1)
    end)
    self.___ex.removeButton:regOnButtonClick(function (eventData)
        self:removeItem(1)
    end)
    self.___ex.scrollButton:regOnButtonClick(function (eventData)
        self:scrollToCell(40);
    end)
    self.___ex.scrollToPreviousButton:regOnButtonClick(function (eventData)
        self:scrollToPreviousGroup();
    end)
    self.___ex.scrollToNextButton:regOnButtonClick(function (eventData)
        self:scrollToNextGroup();
    end)
    self.___ex.getItem:regOnButtonClick(function (eventData)
        local index = tonumber(self.___ex.itemIndex.text)
        local spt = self:getItem(index)
        if spt then
            dump(spt.data)
        end
    end)
    --]]
end

---[[ 为了C#回调而写的方法
function ScrollViewSameSizeExample:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Common/Template/Scroll/ScrollItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function ScrollViewSameSizeExample:resetItem(spt, index)
    spt:init(self.itemDatas[index].text)
    self:updateItemIndex(spt, index)
end

function ScrollViewSameSizeExample:createLine(index)
    local obj = self.super.createLine(self, index)
    local image = obj:GetComponent(Image)
    image.color = Color(150 / 255, 150 / 255, 150 / 255)
    return obj
end
--]]

return ScrollViewSameSizeExample

