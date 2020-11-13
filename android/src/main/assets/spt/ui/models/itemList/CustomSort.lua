local ItemListConstants = require("ui.models.itemList.ItemListConstants")
local CustomSort = {}
CustomSort.defaultOrder = {ItemListConstants.OrderType.RARITY, ItemListConstants.OrderType.KIND, ItemListConstants.OrderType.INITIAL_LETTER}

local function compare(model_a, model_b, order)
    if order == ItemListConstants.OrderType.RARITY then
        local quality_a = model_a:GetQuality()
        local quality_b = model_b:GetQuality()
        if quality_a == quality_b then
            return false, true
        else
            return quality_a > quality_b
        end
    elseif order == ItemListConstants.OrderType.KIND then
        local baseid_a = model_a:GetBaseId()
        local baseid_b = model_b:GetBaseId()
        if baseid_a == baseid_b then
            return false, true
        else
            return baseid_a < baseid_b
        end
    elseif order == ItemListConstants.OrderType.INITIAL_LETTER then
        local letterid_a = model_a:GetLetterId()
        local letterid_b = model_b:GetLetterId()
        if letterid_a == letterid_b then
            return false, true
        else
            return letterid_a < letterid_b
        end
    end
end

function CustomSort.sort(dataTab, modelMap, order)
    local orderTab = {}
    table.insert(orderTab, order)
    for i, v in ipairs(CustomSort.defaultOrder) do
        if v ~= order then
            table.insert(orderTab, v)
        end
    end

    table.sort(dataTab, function(a, b)
        for i, v in ipairs(orderTab) do
            local ret, isEqual = compare(modelMap[a], modelMap[b], v)
            if ret then
                return ret
            else
                if not isEqual then
                    break
                end
            end
        end
    end)
end

return CustomSort