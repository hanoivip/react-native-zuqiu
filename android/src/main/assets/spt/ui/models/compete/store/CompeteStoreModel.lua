local Model = require("ui.models.Model")

local CompeteStoreModel = class(Model, "CompeteStoreModel")

function CompeteStoreModel:ctor()
end

function CompeteStoreModel:InitWithProtocol(data)
    self.data = data
end

function CompeteStoreModel:GetScrollViewData()
    return self.data.goodsList
end

return CompeteStoreModel