local Model = require("ui.models.Model")
local Honor = require("data.Honor")

local HonorPalaceItemModel = class(Model)

function HonorPalaceItemModel:ctor(data)
    HonorPalaceItemModel.super.ctor(self)
    if data then
        self.data = data
        self.staticData = Honor[tostring(data.ID)]
    end
end

function HonorPalaceItemModel:GetNameByID(id)
    return Honor[tostring(id)].name
end

function HonorPalaceItemModel:GetID()
    return self.data.ID
end

function HonorPalaceItemModel:GetState()
    return self.data.state
end

function HonorPalaceItemModel:SetItemCollected()
    self.data.state = 1
end

function HonorPalaceItemModel:GetValue()
    if type(self.data.value) == "table" then
        return table.nums(self.data.value)
    else
        return self.data.value
    end
end

function HonorPalaceItemModel:GetTime()
    return os.date("%x", self.data.r_t)
end

function HonorPalaceItemModel:GetName()
    return self.staticData.name
end

function HonorPalaceItemModel:GetDesc()
    return self.staticData.desc
end

function HonorPalaceItemModel:GetOrder()
    return self.staticData.order
end

function HonorPalaceItemModel:GetCondition()
    if type(self.staticData.condition) == "table" then
        return table.nums(self.staticData.condition)
    else
        return self.staticData.condition
    end
end

function HonorPalaceItemModel:GetIsLastHonor()
    return self.staticData and tonumber(self.staticData.lastHonor) == 1
end

function HonorPalaceItemModel:IsTrophyBeShowed()
    return self.data.honor and true or false
end

function HonorPalaceItemModel:GetEffortValue()
    return self.staticData.honorPoint
end

return HonorPalaceItemModel