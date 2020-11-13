local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local ActivityTimeLimitLetterScrollView = class(LuaScrollRectExSameSize)

function ActivityTimeLimitLetterScrollView:ctor()
    self.super.ctor(self)
    self.parentScrollRect = self.___ex.parentScrollRect
    self.itemView = {}
end

function ActivityTimeLimitLetterScrollView:start()
end

function ActivityTimeLimitLetterScrollView:UpdateRewardStates(index)
    for i, v in ipairs(self.itemView) do
        v:UpdateSelfRewardState(index)
    end
end

function ActivityTimeLimitLetterScrollView:InitView(timeLimitedLetterModel)
    self.timeLimitedLetterModel = timeLimitedLetterModel
    self.itemDatas = timeLimitedLetterModel:GetLetterList()
    self:refresh()
end

function ActivityTimeLimitLetterScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/TimeLimitLetterItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    table.insert(self.itemView, spt)
    self:resetItem(spt, index)
    return obj
end

function ActivityTimeLimitLetterScrollView:resetItem(spt, index)
    local curTag = self.timeLimitedLetterModel:GetSelectedTabTag()
    spt:InitView(self.timeLimitedLetterModel, index, curTag, self.parentScrollRect)
end


return ActivityTimeLimitLetterScrollView