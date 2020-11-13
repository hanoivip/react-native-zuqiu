local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2

local DreamHallHistoryItemFixTitleItemView = class(unity.base, "DreamHallHistoryItemFixTitleItemView")

function DreamHallHistoryItemFixTitleItemView:ctor()
    self.title = self.___ex.title
    self.imgBack = self.___ex.imgBack
    self.rct = self.___ex.rct
end

function DreamHallHistoryItemFixTitleItemView:InitView(text, isShowBackImage, width)
    self.title.text = text
    self.imgBack.enabled = isShowBackImage
    if width then
        self.rct.sizeDelta = Vector2(width, 80)
    end
end

return DreamHallHistoryItemFixTitleItemView