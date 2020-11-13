local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local ScrollRectExSameSize = clr.ScrollRectExSameSize
local Direction = ScrollRectExSameSize.Direction

local ScrollViewSameSizeExample2 = class(unity.base)

function ScrollViewSameSizeExample2:ctor()
    self.scroll = self.___ex.scroll
end

function ScrollViewSameSizeExample2:start()
    --[[
    self.scroll:regOnItemIndexChanged(function (index)
        dump(format("current index: %d", index))
    end)
    --]]
    --[[
    self.scroll:regOnScrollPositionChanged(function (position)
        dump(format("current position: %.2f", position))
    end)
    --]]
    self.scroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Common/Template/Scroll/ScrollItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scroll:regOnResetItem(function (scrollSelf, spt, index)
        spt:init(scrollSelf.itemDatas[index].text)
        scrollSelf:updateItemIndex(spt, index)
    end)
    local oldCreateLineFunc = self.scroll.createLine
    self.scroll:regOnCreateLine(function (scrollSelf, index)
        local obj = oldCreateLineFunc(scrollSelf, index)
        local image = obj:GetComponent(Image)
        image.color = Color(150 / 255, 150 / 255, 150 / 255)
        return obj
    end)

    local data = {}
    for i = 1, 500 do
        data[i] = {text = i}
    end
    self.scroll:refresh(data)

    local newIndex = 0
    self.___ex.addButton:regOnButtonClick(function (eventData)
        newIndex = newIndex + 1
        self.scroll:addItem({text = format("new%d", newIndex)}, 1)
    end)
    self.___ex.removeButton:regOnButtonClick(function (eventData)
        self.scroll:removeItem(1)
    end)
    self.___ex.scrollButton:regOnButtonClick(function (eventData)
        self.scroll:scrollToCell(40);
    end)
    self.___ex.scrollToPreviousButton:regOnButtonClick(function (eventData)
        self.scroll:scrollToPreviousGroup();
    end)
    self.___ex.scrollToNextButton:regOnButtonClick(function (eventData)
        self.scroll:scrollToNextGroup();
    end)
    self.___ex.getItem:regOnButtonClick(function (eventData)
        local index = tonumber(self.___ex.itemIndex.text)
        local spt = self.scroll:getItem(index)
        if spt then
            dump(spt.data)
        end
    end)
    --]]
end

return ScrollViewSameSizeExample2

