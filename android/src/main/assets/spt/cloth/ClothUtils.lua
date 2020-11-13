local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local ShirtMask = require("data.ShirtMask")

local ClothUtils = { }

ClothUtils.homeBaseCloth = nil
ClothUtils.homeBackNumColor = nil
ClothUtils.homeTrouNumColor = nil
ClothUtils.gkBaseCloth = nil
ClothUtils.gkBackNumColor = nil
ClothUtils.gkTrouNumColor = nil

function ClothUtils.destoryClothes()
    Object.Destroy(ClothUtils.homeBaseCloth)
    Object.Destroy(ClothUtils.gkBaseCloth)
    ClothUtils.homeBaseCloth = nil
    ClothUtils.gkBaseCloth = nil
end

function ClothUtils.parseColorString(colorString)
    local nums = string.split(colorString, ',')
    return Color(tonumber(nums[1]), tonumber(nums[2]), tonumber(nums[3]), tonumber(nums[4]))
end

function ClothUtils.getHsvFromRgb(color)
    local maxV = math.max(math.max(color.r, color.g), color.b)
    local minV = math.min(math.min(color.r, color.g), color.b)
    local saturation = math.cmpf(maxV, 0) == 0 and 0 or (1 - minV / maxV)
    if math.cmpf(maxV, minV) == 0 then
        return 0, saturation, maxV
    elseif math.cmpf(maxV, color.r) == 0 and math.cmpf(color.g, color.b) >= 0 then
        return 60 * (color.g - color.b) / (maxV - minV), saturation, maxV
    elseif math.cmpf(maxV, color.r) == 0 and math.cmpf(color.g, color.b) < 0 then
        return 60 * (color.g - color.b) / (maxV - minV) + 360, saturation, maxV
    elseif math.cmpf(maxV, color.g) == 0 then
        return 60 * (color.b - color.r) / (maxV - minV) + 120, saturation, maxV
    else
        return 60 * (color.r - color.g) / (maxV - minV) + 240, saturation, maxV
    end
end

function ClothUtils.isCloseColor(color1, color2)
    -- local hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(color1)
    -- local hue2, saturation2, value2 = ClothUtils.getHsvFromRgb(color2)
    
    -- if math.cmpf(math.abs(hue1 - hue2), 40) >= 0 and math.cmpf(math.abs(hue1 - hue2), 320) <= 0 then
    --     return false
    -- elseif math.cmpf(math.abs(saturation1 - saturation2), 0.8) >= 0 or math.cmpf(math.abs(value1 - value2), 0.8) >= 0 then
    --     return false
    -- end
    
    -- return true
    -- ndump(color1, color2, (1 - math.abs(color1.r - color2.r) * 0.297 - math.abs(color1.g - color2.g) * 0.593 - math.abs(color1.b - color2.b) * 0.11))

    -- wtf, another magic number
    return (1 - math.abs(color1.r - color2.r) * 0.297 - math.abs(color1.g - color2.g) * 0.593 - math.abs(color1.b - color2.b) * 0.11) > 0.804
end

function ClothUtils.destroyMatchClothes()
    if ClothUtils.playerGkKit ~= nil then
        Object.Destroy(ClothUtils.playerGkKit)
        ClothUtils.playerGkKit = nil
    end
    if ClothUtils.playerKit ~= nil then
        Object.Destroy(ClothUtils.playerKit)
        ClothUtils.playerKit = nil
    end
    if ClothUtils.opponentGkKit ~= nil then
        Object.Destroy(ClothUtils.opponentGkKit)
        ClothUtils.opponentGkKit = nil
    end
    if ClothUtils.opponentKit ~= nil then
        Object.Destroy(ClothUtils.opponentKit)
        ClothUtils.opponentKit = nil
    end
end

-- 判断mask遮罩是否为大辅色
function ClothUtils.IsMaskBigAssistColor(mask)
    assert(type(mask) == "string")
    local maskTable = ShirtMask[mask]
    return maskTable and (tonumber(maskTable.assistColour) == 1) or false
end

return ClothUtils