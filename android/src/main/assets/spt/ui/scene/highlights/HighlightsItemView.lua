local GameObjectHelper = require("ui.common.GameObjectHelper")

local HighlightsItemView = class(unity.base)

function HighlightsItemView:ctor()
    self.opposedContent = self.___ex.opposedContent
    self.selfContent = self.___ex.selfContent
end

function HighlightsItemView:InitView(data, index)
    self.data = data
    self.index = index
    self:BulidPage()
end

function HighlightsItemView:BulidPage()
    GameObjectHelper.FastSetActive(self.selfContent.gameObject, self.data.isSelf)
    GameObjectHelper.FastSetActive(self.opposedContent.gameObject, not self.data.isSelf)
    self.view = self.data.isSelf and self.selfContent or self.opposedContent
    self.view:InitView(self.data, self.index)
    self.view.onItemClick = function() self:OnItemClick() end
end

function HighlightsItemView:OnItemClick()
    self.data.isSelected = not self.data.isSelected
end

return HighlightsItemView