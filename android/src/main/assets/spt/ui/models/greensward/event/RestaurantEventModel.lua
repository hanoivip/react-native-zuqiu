local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local RestaurantEventModel = class(GeneralEventModel, "RestaurantEventModel")

function RestaurantEventModel:ctor()
    RestaurantEventModel.super.ctor(self)
end

function RestaurantEventModel:InitWithProtocolReward(data)
    self.restaurantEffect = data
end

function RestaurantEventModel:GetRestaurantEffectDisplay()
    local display = {}
    local curFloor = self.buildModel:GetCurrentFloor()
    curFloor = tostring(curFloor)
    local restaurantEffect = self.restaurantEffect
    for k, v in ipairs(restaurantEffect) do
        local t = {}
        local num = tonumber(v)
        t.state = num > 0
        t.realNum = num
        t.contents = {}
        t.contents.morale = math.abs(num)
        table.insert(display, t)
    end
    table.sort(display, function(a, b)
            return a.realNum > b.realNum
    end)
    return display
end

function RestaurantEventModel:GetBottomBoardName()
    return "Restaurant_Dlog"
end

return RestaurantEventModel
