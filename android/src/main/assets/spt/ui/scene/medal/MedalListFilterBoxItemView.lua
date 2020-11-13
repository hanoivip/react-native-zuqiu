local GameObjectHelper = require("ui.common.GameObjectHelper")

local MedalListFilterBoxItemView = class(unity.base, "MedalListFilterBoxItemView")

function MedalListFilterBoxItemView:ctor()
    self.white = self.___ex.white
    self.txt = self.___ex.txt
    self.click = self.___ex.click
    self.choosed = self.___ex.choosed

    self.isChoosed = false
end

function MedalListFilterBoxItemView:start()
    self.click:regOnButtonClick(function()
        self:OnBoxItemClick()
    end)
end

function MedalListFilterBoxItemView:InitView(filterData, filterType)
    self.filterData = filterData
    self.filterType = filterType
    GameObjectHelper.FastSetActive(self.white, filterData.id % 2 == 1)
    self.txt.text = lang.trans(filterData.name)
    self:SetChoose(false)
end

function MedalListFilterBoxItemView:OnBoxItemClick()
    EventSystem.SendEvent("MedalListFilter_OnFilterBoxItemClick", self.filterData.id, self.filterType)
    EventSystem.SendEvent("MedalListFilter_OnClickFilterMask", false)  -- close all fiter boxes
end

function MedalListFilterBoxItemView:SetChoose(isChoosed)
    self.isChoosed = isChoosed
    GameObjectHelper.FastSetActive(self.choosed.gameObject, isChoosed)
end

function MedalListFilterBoxItemView:GetID()
    return self.filterData.id
end

return MedalListFilterBoxItemView
