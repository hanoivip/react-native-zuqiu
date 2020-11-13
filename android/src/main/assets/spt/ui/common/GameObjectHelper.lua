local GameObjectHelper = {}

function GameObjectHelper.FastSetActive(obj, value)
    if obj and obj.activeSelf ~= value then 
        obj:SetActive(value)
    end
end

function GameObjectHelper.SetParent(obj, rectTransf, worldPositionStays)
    if obj then 
        obj.transform:SetParent(rectTransf, worldPositionStays)
    end
end

return GameObjectHelper