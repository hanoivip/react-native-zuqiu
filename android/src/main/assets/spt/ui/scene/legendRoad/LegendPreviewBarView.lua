local GameObjectHelper = require("ui.common.GameObjectHelper")
local LegendPreviewBarView = class(unity.base, "LegendPreviewBarView")

function LegendPreviewBarView:ctor()
    self.bg = self.___ex.bg
    self.lableTxt = self.___ex.lableTxt
    self.mark = self.___ex.mark
end

function LegendPreviewBarView:InitView(data)
    self.lableTxt.text = data.desc
    GameObjectHelper.FastSetActive(self.mark, data.isUnlock)
end

function LegendPreviewBarView:SetBgColor(color)
    self.bg.color = color
end

function LegendPreviewBarView:SetTxtColor(color)
    self.lableTxt.color = color
end

return LegendPreviewBarView