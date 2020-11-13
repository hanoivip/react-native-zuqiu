local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtScoutPlayerBarView = class(unity.base)

function CourtScoutPlayerBarView:ctor()
    self.content = self.___ex.content
    self.playersMap = {}
end

function CourtScoutPlayerBarView:OnBtnCard(cid, sortIndex)
    if self.clickCard then 
        self.clickCard(cid, sortIndex)
    end
end

function CourtScoutPlayerBarView:InitView(index, playerModelMap, playerRes, cardRes, cardResourceCache)
    for i, model in ipairs(playerModelMap) do
        if not self.playersMap[i] then 
            local cardObject = Object.Instantiate(playerRes)
            local cardView = res.GetLuaScript(cardObject)
            cardObject.transform:SetParent(self.content.transform, false)
            cardView:InitView(model, cardRes, cardResourceCache, index)
            table.insert(self.playersMap, cardView)
            self.playersMap[i] = cardView
        else
            self.playersMap[i]:InitView(model, cardRes, cardResourceCache, index)
            GameObjectHelper.FastSetActive(self.playersMap[i].gameObject, true)
        end
        self.playersMap[i].clickCard = function(cid, sortIndex) self:OnBtnCard(cid, sortIndex) end
    end

    for i = #playerModelMap + 1, #self.playersMap do
        GameObjectHelper.FastSetActive(self.playersMap[i].gameObject, false)
    end
end

return CourtScoutPlayerBarView
