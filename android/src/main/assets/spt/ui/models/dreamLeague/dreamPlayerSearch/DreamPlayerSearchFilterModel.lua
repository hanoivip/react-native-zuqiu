local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local Model = require("ui.models.Model")
local DreamPlayerSearchFilterModel = class(Model, "DreamPlayerSearchFilterModel")

function DreamPlayerSearchFilterModel:ctor(dcids, dreamLeagueListModel)
    self.dreamLeagueListModel = dreamLeagueListModel
    self.models = {}
    for k,v in pairs(dcids) do
        local model = DreamLeagueCardModel.new(v)
        table.insert(self.models, model)
    end
end

function DreamPlayerSearchFilterModel:GetFilterDcids(selectPos, selectQuality, selectLock)
    local posModel = self:FilterPosition(selectPos, self.models)
    local resultFilter = {}
    if next(selectPos) then
        resultFilter = self:FilterQuality(selectQuality, posModel)
    else
        resultFilter = self:FilterQuality(selectQuality, self.models)
    end
    if (not next(selectPos)) and (not next(selectQuality)) then
        resultFilter = self.models
    end
    return resultFilter
end

function DreamPlayerSearchFilterModel:FilterPosition(selectPos, models)
    local posModel = {}
    for k, v in pairs(models) do
        local mPos = v:GetPositionType()
        for key, posType in pairs(selectPos) do
            if posType == mPos then
                table.insert(posModel, v)
            end
        end
    end
    return posModel
end

function DreamPlayerSearchFilterModel:FilterQuality(selectQuality, models)
    local qualityModel = {}
    if next(selectQuality) then
        for k,v in pairs(models) do
            local mQuality = v:GetQuality()
            for key, qualityType in pairs(selectQuality) do
                if qualityType == mQuality then
                    table.insert(qualityModel, v)
                end
            end
        end
    else
        qualityModel = models
    end
    return qualityModel
end

function DreamPlayerSearchFilterModel:GetDreamLeagueListModel()
    return self.dreamLeagueListModel
end

return DreamPlayerSearchFilterModel
