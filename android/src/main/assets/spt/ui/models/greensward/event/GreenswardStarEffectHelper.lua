-- local GreenswardStarEffectHelper = require("ui.models.greensward.event.GreenswardStarEffectHelper")
local AdventureStarEffect = require("data.AdventureStarEffect")

local GreenswardStarEffectHelper = {}

--- 根据 AdventureStarEffect 的类型 进行转换数值
--- @param value[number] 转换前的值  根据param大小进行取整 <0 floor >0 ceil
function GreenswardStarEffectHelper.ConvertStartEffect(starID, value)
    local starData = AdventureStarEffect[starID]
    local effectNum, starSymbol = 0, 0
    if starData then
        local param = starData.param / 1000
        effectNum = value * (1 + param)
        if param > 0 then
            effectNum = math.ceil(effectNum)
            starSymbol = 1
        else
            effectNum = math.floor(effectNum)
            starSymbol = -1
        end
    end
    return effectNum, starSymbol
end

return GreenswardStarEffectHelper
