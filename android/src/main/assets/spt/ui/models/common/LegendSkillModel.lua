local Skills = require("data.Skills")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local SkillType = require("ui.common.enum.SkillType")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local LegendSkillCondition = require("ui.models.common.LegendSkillCondition")
local LegendSkillModel = class(SkillItemModel, "LegendSkillModel")

LegendSkillModel.SkillType = {
    NonEventType = 1,
    EventType = 2
}

function LegendSkillModel:ctor()
    LegendSkillModel.super.ctor(self)
end

function LegendSkillModel:InitWithCache(pcid, sid)
    self.pcid = pcid
    self.sid = sid
    self.staticData = Skills[tostring(sid)] or {}
end

function LegendSkillModel:GetImproveTxt()
    return self.staticData.desc2
end

-- 当前球员受到其它球员的影响加成（在ownSelf为1的时候包括自身）
function LegendSkillModel:GetPlayerImproveCondition()
    return self.staticData.playerImproveCondition
end

function LegendSkillModel:GetPlayerImproveType()
    return self.staticData.playerImproveType
end

function LegendSkillModel:GetPlayerImproveDetail()
    return self.staticData.playerImproveDetail
end

function LegendSkillModel:GetPlayerImproveDetailCondition()
    return self.staticData.playerImproveDetailCondition
end

-- 当前球员赋予其它球员的影响加成
function LegendSkillModel:GetTeamImproveCondition()
    return self.staticData.teamImproveCondition
end

function LegendSkillModel:GetTeamImproveDetailCondition()
    return self.staticData.teamImproveDetailCondition
end

function LegendSkillModel:GetTeamImproveType()
    return self.staticData.teamImproveType
end

function LegendSkillModel:GetTeamImproveDetail()
    return self.staticData.teamImproveDetail
end

function LegendSkillModel:GetImproveValueMap()
    return self.staticData.lvlBase
end

function LegendSkillModel:GetPowerBase()
    return self.staticData.powerBase
end

-- 在startplayer中包含自身时，如果ownSelf为1，则需要加入加成判断
function LegendSkillModel:IsContainSelf()
    return tonumber(self.staticData.ownSelf) == 1
end

-- 获取传奇技能影响加成
function LegendSkillModel:GetSkillEffectAddition(playerCardModel, teamModel)
    self.playerCardModel = playerCardModel
    local pcid = playerCardModel:GetPcid()
    self.improve = {allAttr = 0, attr = {}, skill = {}, allSkill = 0, baseSkill = 0, allAttrPercent = 0, attrPercent = {}, skillPercent = 0, legendSkillId = self.sid}
    if tostring(pcid) == self.pcid then
        self:ConfigPlayerImprove(playerCardModel, teamModel)
    else
        self:ConfigTeamImprove(playerCardModel, teamModel)
    end
    return self.improve
end

local function GetPlayerValid(pcids)
    local num = 0
    for pos, pcid in pairs(pcids) do
        if tonumber(pcid) ~= 0 then
            num = num + 1
        end
    end
    return num
end

-- 涉及到非自身卡牌（查看其它玩家卡牌）
function LegendSkillModel:GetPlayerCondition(playerId, pcids, improveCondition, improveDetailCondition)
    local num = 0
    local isContainSelf = self:IsContainSelf()
    for rolePos, pcid in pairs(pcids) do
        local isValidContidion = isContainSelf and true or tobool(tonumber(playerId) ~= tonumber(pcid))
        if tonumber(pcid) ~= 0 and isValidContidion then -- 阵型格子为空数据设置为0
            local cardModel = SimpleCardModel.new(pcid, self.playerCardModel:GetCardsMapModel())
            if improveCondition == LegendSkillCondition.PlayerImproveCondition.Nation or
                    improveCondition == LegendSkillCondition.PlayerImproveCondition.Starter_Nation or
                    improveCondition == LegendSkillCondition.PlayerImproveCondition.Rep_Nation then
                local nation = cardModel:GetNation()
                for i, v in ipairs(improveDetailCondition) do
                    if nation == v then
                        num = num + 1
                        break
                    end
                end
            elseif improveCondition == LegendSkillCondition.PlayerImproveCondition.Player_All or
                    improveCondition == LegendSkillCondition.PlayerImproveCondition.Starter_Player or
                    improveCondition == LegendSkillCondition.PlayerImproveCondition.Rep_Player then
                local cid = cardModel:GetCid()
                for i, v in ipairs(improveDetailCondition) do
                    if cid == v then
                        num = num + 1
                        break
                    end
                end
            elseif improveCondition == LegendSkillCondition.PlayerImproveCondition.Starter_Pos then
                for i, pos in ipairs(improveDetailCondition) do
                    if tonumber(rolePos) == tonumber(pos) then
                        num = num + 1
                        break
                    end
                end
            end
        end
    end
    return num
end

-- 球员自身属性加成的条件(受到团队首发和替补影响)
function LegendSkillModel:ConfigPlayerImprove(playerCardModel, teamModel)
    if playerCardModel:IsMaxAscend() then
        if self:IsEventSkill() then
            local powerBase = self:GetPowerBase()
            self.improve.skillPercent = powerBase
        else
            local pcid = playerCardModel:GetPcid()
            local playerImproveCondition = self:GetPlayerImproveCondition()
            local startePcidsMap = teamModel:GetInitPlayerCacheData()
            local repPcidsMap = teamModel:GetReplacePlayerCacheData()
            local playerImproveDetailCondition = self:GetPlayerImproveDetailCondition()
            local starters = GetPlayerValid(startePcidsMap)
            local reps = GetPlayerValid(repPcidsMap)
            if playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.All then
                local ratio = starters + reps
                self:BuildImprovePlayer(ratio)
            elseif playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Nation or
                    playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Player_All then
                local startNum = self:GetPlayerCondition(pcid, startePcidsMap, playerImproveCondition, playerImproveDetailCondition)
                local repNum = self:GetPlayerCondition(pcid, repPcidsMap, playerImproveCondition, playerImproveDetailCondition)
                local ratio = startNum + repNum
                self:BuildImprovePlayer(ratio)
            elseif playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Starter_All then
                self:BuildImprovePlayer(starters)
            elseif playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Starter_Nation or
                    playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Starter_Pos or
                    playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Starter_Player then
                local startNum = self:GetPlayerCondition(pcid, startePcidsMap, playerImproveCondition, playerImproveDetailCondition)
                self:BuildImprovePlayer(startNum)
            elseif playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Rep_All then
                self:BuildImprovePlayer(reps)
            elseif playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Rep_Nation or
                    playerImproveCondition == LegendSkillCondition.PlayerImproveCondition.Rep_Player then
                local repNum = self:GetPlayerCondition(pcid, repPcidsMap, playerImproveCondition, playerImproveDetailCondition)
                self:BuildImprovePlayer(repNum)
            end
        end
    end
end

-- playerCardModel 都是首发球员数据
function LegendSkillModel:ConfigTeamImprove(playerCardModel, teamModel)
    local isQualified = false
    local teamImproveCondition = self:GetTeamImproveCondition()
    if teamImproveCondition == LegendSkillCondition.TeamImproveCondition.Starter_All then
        isQualified = true
    elseif teamImproveCondition == LegendSkillCondition.TeamImproveCondition.Starter_Nation then
        local teamImproveDetailCondition = self:GetTeamImproveDetailCondition()
        local nation = playerCardModel:GetNation()
        for i, v in ipairs(teamImproveDetailCondition) do
            if nation == v then
                isQualified = true
                break
            end
        end
    elseif teamImproveCondition == LegendSkillCondition.TeamImproveCondition.Starter_Pos then
        local teamImproveDetailCondition = self:GetTeamImproveDetailCondition()
        local pcid = playerCardModel:GetPcid()
        local rolePos = teamModel:GetStarterPlayerInTeamPos(pcid)
        for i, pos in ipairs(teamImproveDetailCondition) do
            if tonumber(pos) == tonumber(rolePos) then
                isQualified = true
                break
            end
        end
    elseif teamImproveCondition == LegendSkillCondition.TeamImproveCondition.Starter_Player then
        local teamImproveDetailCondition = self:GetTeamImproveDetailCondition()
        local cid = playerCardModel:GetCid()
        for i, v in ipairs(teamImproveDetailCondition) do
            if cid == v then
                isQualified = true
                break
            end
        end
    end

    if isQualified then
        self:BuildImproveTeam(1)
    end
end

function LegendSkillModel:BuildImprovePlayer(ratio)
    local playerImproveType = self:GetPlayerImproveType()
    local playerImproveDetail = self:GetPlayerImproveDetail()
    local valueMap = self:GetImproveValueMap()
    local improveValue = valueMap[2]
    self:AllotImproveWay(playerImproveType, playerImproveDetail, improveValue, ratio)
end

function LegendSkillModel:BuildImproveTeam(ratio)
    local teamImproveType = self:GetTeamImproveType()
    local teamImproveDetail = self:GetTeamImproveDetail()
    local valueMap = self:GetImproveValueMap()
    local improveValue = valueMap[1]
    self:AllotImproveWay(teamImproveType, teamImproveDetail, improveValue, ratio)
end

-- 生成传奇技能加成属性
function LegendSkillModel:AllotImproveWay(improveType, improveDetail, improveValue, ratio)
    if ratio <= 0 then
        return
    end

    if improveType == LegendSkillCondition.LegendSkillImproveType.Attr_All then
        self.improve.allAttr = tonumber(improveValue) * ratio
    elseif improveType == LegendSkillCondition.LegendSkillImproveType.Attr_Single then
        for i, single_attr in ipairs(improveDetail) do
            self.improve.attr[single_attr] = tonumber(improveValue) * ratio
        end
    elseif improveType == LegendSkillCondition.LegendSkillImproveType.Skill_Single then
        for i, slot in ipairs(improveDetail) do
            self.improve.skill[tostring(slot)] = tonumber(improveValue) * ratio
        end
    elseif improveType == LegendSkillCondition.LegendSkillImproveType.Skill_Base then
        self.improve.baseSkill = tonumber(improveValue) * ratio
    elseif improveType == LegendSkillCondition.LegendSkillImproveType.Skill_All then
        self.improve.allSkill = tonumber(improveValue) * ratio
    elseif improveType == LegendSkillCondition.LegendSkillImproveType.AttrPercent_All then
        self.improve.allAttrPercent = tonumber(improveValue) * ratio
    elseif improveType == LegendSkillCondition.LegendSkillImproveType.AttrPercent_Single then
        for i, attr in ipairs(improveDetail) do
            self.improve.attrPercent[tostring(attr)] = tonumber(improveValue) * ratio
        end
    end
end

return LegendSkillModel