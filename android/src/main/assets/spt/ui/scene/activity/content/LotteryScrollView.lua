local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local LotteryScrollView = class(LuaScrollRectExSameSize)

function LotteryScrollView:ctor()
    LotteryScrollView.super.ctor(self)
    self.itemResPath = self.___ex.itemResPath
    self.onItemButtonClicks = {}
end

function LotteryScrollView:GetItemRes()
    if not self.itemRes and self.itemResPath then 
        self.itemRes = res.LoadRes(self.itemResPath)
    end
    return self.itemRes
end

function LotteryScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetItemRes())
    local spt = res.GetLuaScript(obj)

    self:resetItem(spt, index)
    return obj
end

function LotteryScrollView:resetItem(spt, index)
    local data = self.data[index]
    for name, func in pairs(self.onItemButtonClicks) do
        spt[name]:regOnButtonClick(function()
            func(data)
        end)
    end
    spt:InitView(data)
    self:updateItemIndex(spt, index)
end

function LotteryScrollView:InitView(model)
    self.data = model
    self:refresh(self.data)
end

function LotteryScrollView:RegOnItemButtonClick(buttonName, func)
    -- save func to table
    self.onItemButtonClicks[buttonName] = func
end

function LotteryScrollView:UpdateItem(index, itemModel)
    self.data[index] = itemModel
    local spt = self:getItem(index)
    self:resetItem(spt, index)
end

return LotteryScrollView
