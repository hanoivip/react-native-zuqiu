local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local Model = require("ui.models.Model")
local DreamPlayerSearchDecomposeModel = class(Model, "DreamPlayerSearchDecomposeModel")

function DreamPlayerSearchDecomposeModel:ctor(dcids, dreamLeagueListModel)
    self.dreamLeagueListModel = dreamLeagueListModel
    self.models = {}
    for k,v in pairs(dcids) do
        local model = DreamLeagueCardModel.new(v)
        if not model:IsLocked() then
            table.insert(self.models, model)
        end
    end
end

function DreamPlayerSearchDecomposeModel:GetFilterDcids(selectPos, selectQuality, selectLock)
    local posModel = self:FilterPosition(selectPos, self.models)
    local resultFilter = {}
    if next(posModel) or next(selectPos) then
        resultFilter = self:FilterQuality(selectQuality, posModel)
    else
        resultFilter = self:FilterQuality(selectQuality, self.models)
    end
    -- 选择非锁定卡牌 并且 位置和品质都没有选 那么就选择所有的非锁定卡牌
    if next(selectLock) and (not next(resultFilter)) then
        resultFilter = self.models
    end
    return resultFilter
end

function DreamPlayerSearchDecomposeModel:FilterPosition(selectPos, models)
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

function DreamPlayerSearchDecomposeModel:FilterQuality(selectQuality, models)
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

function DreamPlayerSearchDecomposeModel:GetDreamLeagueListModel()
    return self.dreamLeagueListModel
end

return DreamPlayerSearchDecomposeModel
