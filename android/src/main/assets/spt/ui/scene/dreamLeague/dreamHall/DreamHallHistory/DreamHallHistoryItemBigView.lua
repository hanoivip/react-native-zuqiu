local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamHallHistoryItemBigView = class(unity.base, "DreamHallHistoryItemBigView")

function DreamHallHistoryItemBigView:ctor()
    self.playerTitle = self.___ex.playerTitle
    self.playerScoreObj = self.___ex.playerScoreObj
    self.parentTrans = self.___ex.parentTrans
end

function DreamHallHistoryItemBigView:InitView(data)
    self.playerTitle:InitView()
    local index = 1
    local itemWidth = 1100 / table.nums(data.members)
    for i,v in ipairs(data.members) do
        local t1, t2 = math.modf(index / 2);
        v.isShowBackImage = (t2 == 0)
        local textObj = Object.Instantiate(self.playerScoreObj)
        textObj.transform:SetParent(self.parentTrans, false)
        local spt = textObj:GetComponent(CapsUnityLuaBehav)
        spt:InitView(v, itemWidth)
        index = index + 1
    end
    GameObjectHelper.FastSetActive(self.playerScoreObj, false)
end

return DreamHallHistoryItemBigView
