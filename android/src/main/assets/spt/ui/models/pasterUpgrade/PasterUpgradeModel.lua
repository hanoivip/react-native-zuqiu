local Model = require("ui.models.Model")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local WorldTournamentPasterCompose = require("data.WorldTournamentPasterCompose")
local PasterUpgradeModel = class(Model)

local MAX__ADD_PASTER = 3

function PasterUpgradeModel:ctor(cardPasterModel)
    PasterUpgradeModel.super.ctor(self)
    self.cardPasterModel = cardPasterModel
    self.cardPastersMapModel = CardPastersMapModel.new()
    self:InitData()
    self:InitSelectedMap()
end

function PasterUpgradeModel:InitData()
    self.competePasterListModel = {}
    self.pasterModelMap = {}
    local pasters = self.cardPastersMapModel:GetPasterMap()
    local originCardPasterModel = self:GetCardPasterModel()
    local originPtid = originCardPasterModel:GetId()
    for ptid, v in pairs(pasters) do
        if v.num ~= 0 and v.type == PasterMainType.Compete then
            if ptid ~= originPtid then  -- 去除要升级的贴纸
                local pasterModel = CardPasterModel.new(ptid, PasterStateType.CanUse)
                local cache = self.cardPastersMapModel:GetPasterData(ptid)
                pasterModel:InitWithCache(cache)
                table.insert(self.competePasterListModel, pasterModel)
                self.pasterModelMap[tostring(ptid)] = pasterModel
            end
        end
    end
    self:SortPasterList()
end

function PasterUpgradeModel:SortPasterList()
    table.sort(self.competePasterListModel, function(aModel, bModel)
        if aModel:GetPasterType() == bModel:GetPasterType() then
            if aModel:GetPasterQuality() == bModel:GetPasterQuality() then
                return tonumber(aModel:GetPasterId()) < tonumber(bModel:GetPasterId())
            else
                return aModel:GetPasterQuality() > bModel:GetPasterQuality()
            end
        else
            return aModel:GetPasterType() > bModel:GetPasterType()
        end
    end)
end

function PasterUpgradeModel:RemovePasterModel(ptid)
    local ptid = tostring(ptid)
    local listModel = self:GetListModel()
    for i,v in ipairs(listModel) do
        local tempPtid = v:GetId()
        if tostring(tempPtid) == ptid then
            table.remove(listModel, i)
            self:SetListModel(listModel)
            break
        end
    end
    self.pasterModelMap[ptid] = nil
end

function PasterUpgradeModel:InitSelectedMap()
    self.selectedMap = {}
    for i=1, MAX__ADD_PASTER do
        self.selectedMap[i] = false
    end
end

function PasterUpgradeModel:GetListModel()
    return self.competePasterListModel
end

function PasterUpgradeModel:SetListModel(competePasterListModel)
    self.competePasterListModel = competePasterListModel
end

function PasterUpgradeModel:GetSelectedMap()
    return self.selectedMap
end

function PasterUpgradeModel:GetFilterMap()
    return self.filterMap
end

function PasterUpgradeModel:SetFilterMap(filterMap)
    self.filterMap = filterMap
    self.competePasterListModel = {}
    local qualityMap = filterMap and filterMap.quality
    local skill = filterMap and filterMap.skill
    for ptid, v in pairs(self.pasterModelMap) do
        local pasterModel = v
        local pasterType = v:GetPasterType()
        local quality = v:GetPasterQuality()
        local pasterSkill = v:GetCompetePasterSkill()
        local isQuality = true
        local isSkill = true
        if type(qualityMap) == "table" and next(qualityMap) and (not qualityMap[quality]) then
            isQuality = false
        end
        if skill and skill ~= pasterSkill then
            isSkill = false
        end
        if pasterType == PasterMainType.Compete and isQuality and isSkill then
            table.insert(self.competePasterListModel, pasterModel)
        end
    end
    self:SortPasterList()
end

function PasterUpgradeModel:AddSelectedMap(ptid)
    for i,v in ipairs(self.selectedMap) do
        if not v then
            self.selectedMap[i] = ptid
            return i
        end
    end
end

function PasterUpgradeModel:RemoveSelectedMap(ptid)
    for k,v in pairs(self.selectedMap) do
        if ptid == v then
            self.selectedMap[k] = false
            return k
        end
    end
end

function PasterUpgradeModel:GetCardPasterModel()
    return self.cardPasterModel
end

function PasterUpgradeModel:SetCardPasterData(pasterData)
    local pasterModel = CardPasterModel.new(nil, PasterStateType.CanUse)
    pasterModel:InitWithCache(pasterData)
    self.cardPasterModel = pasterModel
end

function PasterUpgradeModel:GetSuccessRate()
    local selectedMap = self:GetSelectedMap()
    local originPasterModel = self:GetCardPasterModel()
    local originQuality = originPasterModel:GetPasterQuality()
    local originRateTable = {}
    for k,v in pairs(WorldTournamentPasterCompose) do
        if v.corePasterQuailty == originQuality then
            local accessPasterQuailty = v.accessPasterQuailty
            originRateTable[accessPasterQuailty] = v
        end
    end
    local successRate = 0
    for i,v in ipairs(selectedMap) do
        if v then
            local ptid = v
            local pasterModel = CardPasterModel.new(ptid, PasterStateType.CanUse)
            local cache = self.cardPastersMapModel:GetPasterData(ptid)
            pasterModel:InitWithCache(cache)
            local quality = pasterModel:GetPasterQuality()
            if originRateTable[quality] then
                successRate = successRate + originRateTable[quality].pasterComposeProbability
            end
        end
    end
    successRate = successRate * 0.0001
    return successRate
end

function PasterUpgradeModel:GetQualitySortList(sortState)
    table.sort(self.competePasterListModel, function(aModel, bModel)
        if aModel:GetPasterType() == bModel:GetPasterType() then
            if aModel:GetPasterQuality() == bModel:GetPasterQuality() then
                return tonumber(aModel:GetPasterId()) < tonumber(bModel:GetPasterId())
            else
                if sortState then
                    return aModel:GetPasterQuality() > bModel:GetPasterQuality()
                else
                    return aModel:GetPasterQuality() < bModel:GetPasterQuality()
                end
            end
        else
            return aModel:GetPasterType() > bModel:GetPasterType()
        end
    end)
    return self.competePasterListModel
end

function PasterUpgradeModel:GetSkillSortList(sortState)
    table.sort(self.competePasterListModel, function(aModel, bModel)
        if aModel:GetPasterType() == bModel:GetPasterType() then
            local aSkillId = aModel:GetCompetePasterSkill()
            local bSkillId = bModel:GetCompetePasterSkill()
            if aSkillId == bSkillId then
                return tonumber(aModel:GetPasterId()) < tonumber(bModel:GetPasterId())
            else
                if sortState then
                    return aSkillId > bSkillId
                else
                    return aSkillId < bSkillId
                end
            end
        else
            return aModel:GetPasterType() > bModel:GetPasterType()
        end
    end)
    return self.competePasterListModel
end

function PasterUpgradeModel:GetOriginPtid()
    local cardPasterModel = self:GetCardPasterModel()
    local ptid = cardPasterModel:GetId()
    return tonumber(ptid)
end

function PasterUpgradeModel:GetCostPtids()
    local selectedMap = self:GetSelectedMap()
    local costPtids = {}
    for k,v in pairs(selectedMap) do
        if v then
            table.insert(costPtids, tonumber(v))
        end
    end
    return costPtids
end

return PasterUpgradeModel