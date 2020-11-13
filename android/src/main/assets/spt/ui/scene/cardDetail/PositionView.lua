local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PositionView = class(unity.base)

function PositionView:ctor()
    self.positionMap = self.___ex.positionMap
end

function PositionView:InitView(cardModel)
    local pos = cardModel:GetBriefPosition()
    local posNum = #pos
    for i = 1, 4 do
        if posNum ~= i then
            local object = self.positionMap["layout" .. tostring(i)]["obj"]
            GameObjectHelper.FastSetActive(object, false)
        end
    end

    local currentLayout = self.positionMap["layout" .. tostring(posNum)]
    local currentObject = currentLayout["obj"]
    GameObjectHelper.FastSetActive(currentObject, true)

    for i, v in ipairs(pos) do
        local posIcon = currentLayout["e" .. tostring(i)]
        posIcon.overrideSprite = AssetFinder.GetPositionIcon(v)
    end
end

return PositionView
