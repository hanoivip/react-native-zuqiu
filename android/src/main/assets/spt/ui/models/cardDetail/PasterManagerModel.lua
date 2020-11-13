local PasterConfig = require("ui.controllers.cardDetail.PasterConfig")
local Model = require("ui.models.Model")
local PasterManagerModel = class(Model, "PasterManagerModel")

function PasterManagerModel:ctor()
    PasterManagerModel.super.ctor(self)
    self.pasterMap = {}
    self:InitGeneralPaster()
    self:InitBasePageConfig()
    self:InitChemicalPageConfig()
    self:InitTrainPageConfig()
    self:InitAscendPageConfig()
end

function PasterManagerModel:InitGeneralPaster()
    PasterConfig.SetGeneralConfig(self.pasterMap)
end

function PasterManagerModel:InitBasePageConfig()
    PasterConfig.SetBasePageConfig(self.pasterMap)
end

function PasterManagerModel:InitChemicalPageConfig()
    PasterConfig.SetChemicalPageConfig(self.pasterMap)
end

function PasterManagerModel:InitTrainPageConfig()
    PasterConfig.SetTrainPageConfig(self.pasterMap)
end

function PasterManagerModel:InitAscendPageConfig()
    PasterConfig.SetAscendPageConfig(self.pasterMap)
end

function PasterManagerModel:GetImageRes(key, pasterType)
    local pasterModel = self.pasterMap[key]
    assert(pasterModel)
    return pasterModel:GetImageRes(pasterType)
end

function PasterManagerModel:GetTextColor(key, pasterType)
    local pasterModel = self.pasterMap[key]
    assert(pasterModel)
    return pasterModel:GetTextColor(pasterType)
end

return PasterManagerModel