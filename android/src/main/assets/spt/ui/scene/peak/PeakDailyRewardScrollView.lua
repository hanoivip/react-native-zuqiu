local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PeakDailyRewardScrollView = class(LuaScrollRectExSameSize)

function PeakDailyRewardScrollView:start()
end

function PeakDailyRewardScrollView:InitView(data)
    self.itemDatas = data
    self:refresh()
end

function PeakDailyRewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakDailyRewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function PeakDailyRewardScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data)
end

return PeakDailyRewardScrollView