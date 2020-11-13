local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local ActivityLabelScrollView = class(LuaScrollRectExSameSize)

function ActivityLabelScrollView:ctor()
    ActivityLabelScrollView.super.ctor(self)
    self.dropDownTip = self.___ex.dropDownTip
end

function ActivityLabelScrollView:start()

end

function ActivityLabelScrollView:Clear()
    self:clearData()
end

function ActivityLabelScrollView:InitView(data, activityRes)
    self.data = data
    self.activityRes = activityRes
    self:refresh(self.data)
end

function ActivityLabelScrollView:OnBtnLabel(index)
    if self.clickLabel then
        self.clickLabel(index)
    end
end

function ActivityLabelScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/ActivityLabel.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function ActivityLabelScrollView:resetItem(spt, index)
    spt.clickBack = function() self:OnBtnLabel(index) end
    spt:InitView(self.data[index], self.activityRes)
    self:updateItemIndex(spt, index)
end

return ActivityLabelScrollView
