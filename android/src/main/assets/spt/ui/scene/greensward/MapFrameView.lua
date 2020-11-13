local GameObjectHelper = require("ui.common.GameObjectHelper")
local MapFrameView = class(unity.base)

function MapFrameView:ctor()
    self.image = self.___ex.image
    self.pic = self.___ex.pic
    self.mark = self.___ex.mark
end

function MapFrameView:InitView(row, col, eventModel, greenswardResourceCache)
    self.row = row
    self.col = col
    self.eventModel = eventModel
    self.greenswardResourceCache = greenswardResourceCache
    self:UpdateDetails()
end

function MapFrameView:UpdateDetails()
    local basePic = self.eventModel:GetBasePic()
    self.image.overrideSprite = self.greenswardResourceCache:GetGrassRes(basePic)

    local picIndex = self.eventModel:GetPicIndex()
    local hasPic = false
    if picIndex and picIndex ~= "" then
        hasPic = true
        self.pic.overrideSprite = self.greenswardResourceCache:GetPicRes(picIndex)
    end
    GameObjectHelper.FastSetActive(self.pic.gameObject, hasPic)
end

return MapFrameView
