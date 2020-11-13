local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local UnsavedCardModel = class(SimpleCardModel)

function UnsavedCardModel:ctor(unsavedCardData)
    self:InitWithCache(unsavedCardData)
end

function UnsavedCardModel:GetTmpConsumePotent()
    return tonumber(self.cacheData.advanceTmp.consumePotent)
end

function UnsavedCardModel:GetAbilityChange(index)
    local tmpTable = self.cacheData.advanceTmp.advanceAttr[index]
    if tmpTable then
        if tmpTable[1] == "add" then
            return tmpTable[2], "add"
        elseif tmpTable[1] == "dec" then
            return -tmpTable[2], "dec"
        end
    end
    return 0
end

return UnsavedCardModel
