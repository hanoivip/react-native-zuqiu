local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PeakRuleSeasonRewardScrollView = class(LuaScrollRectExSameSize)

function PeakRuleSeasonRewardScrollView:ctor()
    self.super.ctor(self)
    self.scrollRectParent = self.___ex.scrollRectParent
end

function PeakRuleSeasonRewardScrollView:start()
end

function PeakRuleSeasonRewardScrollView:InitView(data)
    self.itemDatas = data
    self:refresh()
end

function PeakRuleSeasonRewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakRuleSeasonRewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function PeakRuleSeasonRewardScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data, self.scrollRectParent)
end

return PeakRuleSeasonRewardScrollView