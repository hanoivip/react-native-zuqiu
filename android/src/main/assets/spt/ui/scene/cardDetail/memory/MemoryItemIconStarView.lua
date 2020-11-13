local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MemoryItemIconStarView = class(unity.base, "MemoryItemIconStarView")

local maxNum = 5

local Map = {
    {"1"},
    {"6", "7"},
    {"1", "2", "3"},
    {"6", "7", "8", "9"},
    {"1", "2", "3", "4", "5"}
}

function MemoryItemIconStarView:ctor()
    self.stars = self.___ex.stars
end

function MemoryItemIconStarView:start()
end

function MemoryItemIconStarView:InitView(num)
    self.num = math.clamp(num, 0, maxNum)
    for k, star in pairs(self.stars) do
        GameObjectHelper.FastSetActive(star.gameObject, false)
    end
    for k, id in ipairs(Map[self.num]) do
        GameObjectHelper.FastSetActive(self.stars[id].gameObject, true)
    end
end

return MemoryItemIconStarView
