local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local RankingListScrollView = class(LuaScrollRectExSameSize)

function RankingListScrollView:ctor()
    self.textObj = self.___ex.textObj
    self.super.ctor(self)
end

function RankingListScrollView:start()
end

function RankingListScrollView:InitView(rankingList)
    if not rankingList or not next(rankingList) then
        GameObjectHelper.FastSetActive(self.textObj, true)
    else
        GameObjectHelper.FastSetActive(self.textObj, false)
        self:refresh(rankingList)
    end
end

function RankingListScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/RecruitReward/RankingItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function RankingListScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    data.rank = index
    spt:InitView(data, index)
    self:updateItemIndex(spt, index)
end

return RankingListScrollView