local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CareerRaceScrollView = class(LuaScrollRectExSameSize)

function CareerRaceScrollView:ctor()
    CareerRaceScrollView.super.ctor(self)

    self.scrollRect = self.___ex.scrollRect
end

function CareerRaceScrollView:start()
end

function CareerRaceScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Quest/RewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function CareerRaceScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt:InitView(data, self.scrollRect, self.activityModel)  
    self:updateItemIndex(spt, index)
end

function CareerRaceScrollView:InitView(rewardList, activityModel)
    self.activityModel = activityModel
    self:refresh(rewardList)
end

return CareerRaceScrollView
