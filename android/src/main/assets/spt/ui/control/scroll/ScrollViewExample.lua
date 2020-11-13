local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2

local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")

local ScrollViewExample = class(LuaScrollRectEx)

function ScrollViewExample:ctor()
    self.super.ctor(self)
end

function ScrollViewExample:start()
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
    --[[
    for i = 1, 3 do
        self.itemDatas[i] = {text = i, size = Vector2(math.random(1600, 1600), math.random(900, 900))}
    end
    --]]
    --[[
    for i = 1, 20 do
        self.itemDatas[i] = {text = i, size = Vector2(math.random(300, 400), math.random(700, 800))}
    end
    --]]
    ---[[
    for i = 1, 500 do
        self.itemDatas[i] = {text = i, size = Vector2(math.random(100, 200), math.random(100, 200))}
    end
    --]]
    self:refresh()
    -- self:scrollToCellImmediate(480);
    ---[[
    local newIndex = 0
    self.___ex.addButton:regOnButtonClick(function (eventData)
        local addDatas = {}
        local count = 1
        for i = 1, count do
            table.insert(addDatas, {text = format("new%d", newIndex + i), size = Vector2(math.random(100, 200), math.random(100, 200))})
        end
        newIndex = newIndex + count
        self:addItems(addDatas, 1)
    end)
    self.___ex.removeButton:regOnButtonClick(function (eventData)
        self:removeItems(1, 1)
    end)
    self.___ex.scrollButton:regOnButtonClick(function (eventData)
        self:scrollToCell(100);
    end)
    self.___ex.scrollToPreviousButton:regOnButtonClick(function (eventData)
        self:scrollToPreviousGroup();
    end)
    self.___ex.scrollToNextButton:regOnButtonClick(function (eventData)
        self:scrollToNextGroup();
    end)
    --]]
end

---[[ 为了C#回调而写的方法
function ScrollViewExample:getItemTag(index)
    return "Prefab"
end

function ScrollViewExample:createItemByTagPrefab(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Common/Template/Scroll/ScrollItem.prefab"
    local obj = res.Instantiate(prefab)
    return obj
end

function ScrollViewExample:resetItemByTagPrefab(spt, index)
    local data = self.itemDatas[index]
    spt.gameObject.transform.sizeDelta = data.size
    spt:init(data.text)
end
--]]

return ScrollViewExample
