local LegendRoadImproveModel = require("ui.models.legendRoad.LegendRoadImproveModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local LegendSkillModel = require("ui.models.common.LegendSkillModel")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")
local Model = require("ui.models.Model")
local LegendCardsMapModel = class(Model, "LegendCardsMapModel")

function LegendCardsMapModel:ctor()
    LegendCardsMapModel.super.ctor(self)
    self.maxStageNum = 10 -- 最大关卡数
end

function LegendCardsMapModel:Init(data)
    if not data then
        data = cache.getPlayerLegendCardsMap() or {}
    end
    self.data = data
    self.playerCardsMapModel = require("ui.models.PlayerCardsMapModel").new()
end

function LegendCardsMapModel:InitWithProtocol(data)
    local legendCardsMap = {}
    legendCardsMap.legendCard = data or {}
    legendCardsMap.skillImprove = {}
    cache.setPlayerLegendCardsMap(legendCardsMap)
    self:Init(legendCardsMap)
    self:InitImproveMap()
end

function LegendCardsMapModel:InitImproveMap()
    for pcid, v in pairs(self.data.legendCard) do
        self.data.legendCard[tostring(pcid)].combineImproveMap = self:GetCombineImproveMap(pcid, v)
    end
end

function LegendCardsMapModel:GetCombineImproveMap(pcid, data)
    local combineImproveMap = {allAttr = 0, potent = 0, attr = {}, skill = {}, allSkill = 0, changeExSkill = 0, legendSkill = {}}
    --ascend字段标记了传奇之路是否生效  如果有助阵卡牌可能本卡没有base有useData 有useData useData必定生效
    if data.base and data.base.ascend or data.useData then
        combineImproveMap = self:GetActiveChapterImprove(pcid)
    end
    return combineImproveMap
end

-- 获取当前章节提升属性
function LegendCardsMapModel:GetCurrentChapterImprove(pcid, chapterProgress, stageProgress, chapterId)
    local openStageNum = 0
    if tonumber(chapterId) < chapterProgress then
        openStageNum = self.maxStageNum
    elseif tonumber(chapterId) == chapterProgress and stageProgress > 0 then
        openStageNum = stageProgress
    end
    local data = self:GetCardData(pcid)
    local improveMap = {}
    if not data.base then
        return improveMap
    end
    local cid = data.base.cid
    --这里用于计算潜力点是否生效
    local meChapterProgress, meStageProgress = self:GetLegendCardProgressChapterAndStage(pcid, true)
    for i = 1, openStageNum do
        local improveData = LegendRoadImproveModel.GetImproveConfig(cid, chapterId, i)
        if improveData  then
            local improveType = improveData.improveType
            local detailImprove = improveData.detailImprove
            local improveUseData = improveMap[tostring(improveType)]
            if not improveUseData then
                improveUseData = {allAttr = 0, potent = 0, attr = {}, skill = {}, allSkill = 0, changeExSkill = 0, legendSkill = {}}
                improveUseData.improveType = improveType
                improveMap[tostring(improveType)] = improveUseData
            end

            if improveType == ImproveType.Attr_All then
                improveUseData.allAttr = tonumber(improveUseData.allAttr) + tonumber(detailImprove[1])
            elseif improveType == ImproveType.Attr_Train then
                if chapterId * 100 + i <= meChapterProgress * 100 + meStageProgress then
                    improveUseData.potent = tonumber(improveUseData.potent) + tonumber(detailImprove[1])
                end
            elseif improveType == ImproveType.Skill_All then
                improveUseData.allSkill = tonumber(improveUseData.allSkill) + tonumber(detailImprove[1])
            elseif improveType == ImproveType.Attr_Single then
                local value = detailImprove[1] or 0
                local attrListMap = LegendRoadImproveModel.GetImproveAttr(cid)
                local attrList = attrListMap[tostring(chapterId)]
                local selectIndex = self:GetAppointStageActiveIndex(pcid, chapterId, i) or 0
                local attrkey = attrList[tonumber(selectIndex) + 1]
                improveUseData.attr[attrkey] = tonumber(improveUseData.attr[attrkey]) + value
            elseif improveType == ImproveType.Skill_Single then
                local selectIndex = self:GetAppointStageActiveIndex(pcid, chapterId, i) or 1
                local skillImprove = detailImprove[tostring(selectIndex)] or 0
                improveUseData.skill[tostring(selectIndex)] = tonumber(improveUseData.skill[tostring(selectIndex)]) + skillImprove
            elseif improveType == ImproveType.Paster_EX then
                improveUseData.changeExSkill = tonumber(improveUseData.changeExSkill) + 1
            elseif improveType == ImproveType.Skill_New then
                local configPlayer = LegendRoadImproveModel.GetConfigPlayerByCid(cid)
                local skillKey = detailImprove[1]
                local sid = configPlayer[tostring(skillKey)]
                improveUseData.legendSkill[tostring(sid)] = true
            end
        end
    end
    return improveMap
end

-- 获取当前章节提升潜力值(真实的潜力值要重新计算)
function LegendCardsMapModel:GetCurrentChapterPotent(pcid, chapterProgress, stageProgress, chapterId)
    local openStageNum = 0
    if tonumber(chapterId) < chapterProgress then
        openStageNum = self.maxStageNum
    elseif tonumber(chapterId) == chapterProgress and stageProgress > 0 then
        openStageNum = stageProgress
    end
    local potent = 0
    local data = self:GetCardData(pcid)
    if not data.base then
        return potent
    end
    local cid = data.base.cid
    for i = 1, openStageNum do
        local improveData = LegendRoadImproveModel.GetImproveConfig(cid, chapterId, i)
        if improveData  then
            local improveType = improveData.improveType
            if improveType == ImproveType.Attr_Train then
                local detailImprove = improveData.detailImprove
                potent = tonumber(potent) + tonumber(detailImprove[1])
            end
        end
    end
    return potent
end

-- 获取所有激活章节提升属性
function LegendCardsMapModel:GetActiveChapterImprove(pcid)
    local chapterProgress, stageProgress = self:GetLegendCardProgressChapterAndStage(pcid)
    local combineImproveMap = {allAttr = 0, potent = 0, attr = {}, skill = {}, allSkill = 0, changeExSkill = 0, legendSkill = {}}
    for i = 1, chapterProgress do
        local improveMap = self:GetCurrentChapterImprove(pcid, chapterProgress, stageProgress, i)
        for improveType, v in pairs(improveMap) do
            -- 属性
            local attr = v.attr
            if next(attr) then
                for attrKey, value in pairs(attr) do
                    combineImproveMap.attr[attrKey] = tonumber(combineImproveMap.attr[attrKey]) + tonumber(value)
                end
            end
            -- 技能
            local skillList = v.skill
            if next(skillList) then
                for slot, value in pairs(skillList) do
                    combineImproveMap.skill[tostring(slot)] = tonumber(combineImproveMap.skill[tostring(slot)]) + tonumber(value)
                end
            end

            -- 传奇技能sid
            local legendSkill = v.legendSkill
            if next(legendSkill) then
                for sid, value in pairs(legendSkill) do
                    combineImproveMap.legendSkill[tostring(sid)] = true
                end
            end

            combineImproveMap.allAttr = tonumber(combineImproveMap.allAttr) + tonumber(v.allAttr)
            combineImproveMap.allSkill = tonumber(combineImproveMap.allSkill) + tonumber(v.allSkill)
            combineImproveMap.changeExSkill = tonumber(combineImproveMap.changeExSkill) + tonumber(v.changeExSkill)
        end
    end

    --潜力点需要用我自己真实的进度重新计算
    local chapterProgress, stageProgress = self:GetLegendCardProgressChapterAndStage(pcid, true)
    for i = 1, chapterProgress do
        local potent = self:GetCurrentChapterPotent(pcid, chapterProgress, stageProgress, i)
        combineImproveMap.potent = tonumber(combineImproveMap.potent) + tonumber(potent)
    end
    return combineImproveMap
end

-- 重置传奇之路球员数据
function LegendCardsMapModel:ResetLegendCardData(pcid, data, teamModel)
    assert(type(data) == "table")
    self.data.legendCard[tostring(pcid)] = data
    if table.nums(data) ~= 0 then
        data.combineImproveMap = self:GetCombineImproveMap(pcid, data)
    else
        self.data.legendCard[tostring(pcid)] = nil
    end
    self:BuildTeamLegendInfo(teamModel, self.playerCardsMapModel)
    EventSystem.SendEvent("LegendCards_ResetLegendCard", pcid)
end

function LegendCardsMapModel:SetLegendAscend(pcid, bTrue)
    local legendData = self.data.legendCard[tostring(pcid)]
    if not legendData then
        return
    end
    legendData.base.ascend = bTrue
    legendData.combineImproveMap = self:GetCombineImproveMap(pcid, legendData)
end

function LegendCardsMapModel:GetCardData(pcid, bOnlySelf)
    local data = self.data.legendCard[tostring(pcid)] or {}
    if bOnlySelf then
        return data
    end
    if data.useData then
        return data.useData
    else
        return data
    end
end

--* 服务器属性是从0开始，技能是从1开始
function LegendCardsMapModel:GetAppointStageActiveIndex(pcid, chapterId, stageId)
    local cardData = self:GetCardData(pcid)
    local data = cardData.data or {}
    local chapterData = data[tostring(chapterId)]
    local selectIndex

    if chapterData then
        local stageData = chapterData[tostring(stageId)] or {}
        selectIndex = stageData.select
    end
    return selectIndex
end

function LegendCardsMapModel:GetLegendCardProgress(pcid, bOnlySelf)
    local cardData = self:GetCardData(pcid, bOnlySelf)
    local base = cardData.base or {}
    local progress = base.progress or {}
    return progress
end

function LegendCardsMapModel:GetLegendCardProgressChapterAndStage(pcid, bOnlySelf)
    local progress = self:GetLegendCardProgress(pcid, bOnlySelf)
    local k, v = next(progress)
    local chapter, stage = 1, 0
    if k then
        chapter = tonumber(k)
        stage = tonumber(v.upgrade)
    end
    return chapter, stage
end

function LegendCardsMapModel:GetLegendSkillImproveInfo(activeLegendSkill, cardModel, teamModel)
    local combineImproveMap = {allAttr = 0, attr = {}, skill = {}, allSkill = 0, baseSkill = 0, allAttrPercent = 0, attrPercent = {}, skillPercent = 0}
    local improveMap = {}

    for pcid, v in pairs(activeLegendSkill) do
        for i, n in ipairs(v) do
            local legendSkillModel = LegendSkillModel.new()
            legendSkillModel:InitWithCache(pcid, n.sid)
            local improve = legendSkillModel:GetSkillEffectAddition(cardModel, teamModel)
            table.insert(improveMap, improve)
        end
    end

    for i, v in ipairs(improveMap) do
        -- 属性
        local attr = v.attr
        if next(attr) then
            for attrKey, value in pairs(attr) do
                combineImproveMap.attr[attrKey] = tonumber(combineImproveMap.attr[attrKey]) + tonumber(value)
            end
        end
        -- 技能
        local skillList = v.skill
        if next(skillList) then
            for slot, value in pairs(skillList) do
                combineImproveMap.skill[tostring(slot)] = tonumber(combineImproveMap.skill[tostring(slot)]) + tonumber(value)
            end
        end
        -- 属性百分比
        local attrPercent = v.attrPercent
        if next(attrPercent) then
            for attrKey, value in pairs(attrPercent) do
                combineImproveMap.attrPercent[attrKey] = tonumber(combineImproveMap.attrPercent[attrKey]) + tonumber(value)
            end
        end
        combineImproveMap.allAttr = tonumber(combineImproveMap.allAttr) + tonumber(v.allAttr)
        combineImproveMap.allSkill = tonumber(combineImproveMap.allSkill) + tonumber(v.allSkill)
        combineImproveMap.baseSkill = tonumber(combineImproveMap.baseSkill) + tonumber(v.baseSkill)
        combineImproveMap.skillPercent = tonumber(combineImproveMap.skillPercent) + tonumber(v.skillPercent)
        combineImproveMap.allAttrPercent = tonumber(combineImproveMap.allAttrPercent) + tonumber(v.allAttrPercent)
    end
    return combineImproveMap
end

function LegendCardsMapModel:BuildTeamLegendInfo(teamModel, cardsMapModel)
    if not teamModel then
        return
    end
    local startePcidsMap = teamModel:GetInitPlayerCacheData()
    self.data.skillImprove = {}
    local legendSkillMap = {}
    for legendPcid, v in pairs(self.data.legendCard) do
        local combineImproveMap = v.combineImproveMap
        local legendSkill = combineImproveMap.legendSkill
        for sid, value in pairs(legendSkill) do
            if not legendSkillMap[legendPcid] then
                legendSkillMap[legendPcid] = {}
            end
            table.insert(legendSkillMap[legendPcid], {sid = sid})
        end
    end
    local activeLegendSkill = {}
    if next(legendSkillMap) then
        for pos, pcid in pairs(startePcidsMap) do
            if tonumber(pcid) ~= 0 then
                local legendSkill = legendSkillMap[tostring(pcid)]
                if legendSkill then
                    activeLegendSkill[tostring(pcid)] = legendSkill
                end
            end
        end
    end
    if next(activeLegendSkill) then
        for pos, pcid in pairs(startePcidsMap) do
            if tonumber(pcid) ~= 0 then
                local cardModel = SimpleCardModel.new(pcid, cardsMapModel)
                self.data.skillImprove[tostring(pcid)] = self:GetLegendSkillImproveInfo(activeLegendSkill, cardModel, teamModel)
            end
        end
    end
end

-- 传奇之路技能影响的加成
function LegendCardsMapModel:GetLegendSkillImprove(cardModel)
    local pcid = cardModel:GetPcid()
    return self.data.skillImprove[tostring(pcid)] or {}
end

-- 球员带的传奇之路给自身加成
function LegendCardsMapModel:GetLegendCardImprove(pcid)
    local improve = self:GetCardData(pcid, true)
    local combineImproveMap = improve.combineImproveMap
    return combineImproveMap or {}
end

return LegendCardsMapModel