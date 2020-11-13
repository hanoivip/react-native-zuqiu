local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local NoticeLabelScrollView = class(LuaScrollRectExSameSize)

-- LabelScroll
function NoticeLabelScrollView:ctor()
    NoticeLabelScrollView.super.ctor(self)
    self.dropDownTip = self.___ex.dropDownTip
end

function NoticeLabelScrollView:Clear()
    self:clearData()
end

function NoticeLabelScrollView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function NoticeLabelScrollView:OnBtnLabel(index)
    if self.clickLabel then
        self.clickLabel(index)
    end
end

function NoticeLabelScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Login/NoticeLabel.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function NoticeLabelScrollView:resetItem(spt, index)
    spt.clickBack = function() self:OnBtnLabel(index) end
    spt:InitView(self.data[index])
    self:updateItemIndex(spt, index)
end

return NoticeLabelScrollView
