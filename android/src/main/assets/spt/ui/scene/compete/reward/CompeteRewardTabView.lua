local ScrollViewSameSize = require("ui.control.scroll.ScrollViewSameSize")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteRewardTabView = class(ScrollViewSameSize, "CompeteRewardTabView")

function CompeteRewardTabView:ctor()
    CompeteRewardTabView.super.ctor(self)
    self.menuSpt = {}
end

function CompeteRewardTabView:resetItem(spt, index)
    local model = self.data[index]
    model:SetMailIndex(index)
    self.menuSpt[index] = spt
    spt:InitView(model, index)
    spt:regOnButtonClick(function()
        if self.onItemClick and type(self.onItemClick) == "function" then
            self.onItemClick(spt, index)
        end
    end)
    self:updateItemIndex(spt, index)

    local mailID = model:GetMailID()
    if cache.getSelectedMailID() and tostring(cache.getSelectedMailID()) == tostring(mailID) then
        spt:SetSelect(true)
    else
        spt:SetSelect(false)
    end
end

function CompeteRewardTabView:ChangeSelectItem(spt, index)
    for k, v in pairs(self.menuSpt) do
        v:SetSelect(false)
    end
    spt:SetSelect(true)
end

return CompeteRewardTabView