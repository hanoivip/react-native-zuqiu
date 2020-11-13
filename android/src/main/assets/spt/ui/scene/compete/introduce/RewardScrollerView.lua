local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local RewardScrollerItemModel = require("ui.models.compete.introduce.RewardScrollerItemModel")
local RewardScrollerView = class(LuaScrollRectExSameSize)

function RewardScrollerView:ctor()
    RewardScrollerView.super.ctor(self)
end

function RewardScrollerView:start()
end

function RewardScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/Introduce/RewardItemBar.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function RewardScrollerView:resetItem(spt, index)
    local itemModel = RewardScrollerItemModel.new(self.data[index])
    spt:InitView(itemModel)
end

function RewardScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

return RewardScrollerView
