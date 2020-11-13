local Model = require("ui.models.Model")
local LegendRoadImproveModel = require("ui.models.legendRoad.LegendRoadImproveModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")
local LegendRoadImprove = require("data.LegendRoadImprove")
local LegendRoadConsume = require("data.LegendRoadConsume")
local LegendRoadUnlock = require("data.LegendRoadUnlock")
local LegendSkillModel = require("ui.models.common.LegendSkillModel")
local Skills = require("data.Skills")
local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
local LegendRoadModel = class(Model, "LegendRoadModel")

function LegendRoadModel:ctor(playerCardModel, legendCardsMapModel)
    self.cardModel = playerCardModel
    self.currChapterId = nil
    self.currStageId = nil
    self.configPlayer = nil -- 静态配置，LegendRoadPlayer

    self.baseId = nil
    self.qualitySuffix = nil -- 球员品质的后缀，详见CardHelper.ConfigQuality的key

    self.legendCardsMapModel = legendCardsMapModel or LegendCardsMapModel.new()
    LegendRoadModel.super.ctor(self)
end

function LegendRoadModel:Init()
    self.baseId = tostring(self.cardModel:GetBaseID())
    self.qualitySuffix = CardHelper.GetQualityConfigFixed(self.cardModel:GetCardQuality(), self.cardModel:GetCardQualitySpecial())
    self.configPlayer = LegendRoadImproveModel.GetConfigPlayer(self.baseId)
end

function LegendRoadModel:InitWithProtocol()
    self:ParseConfig()
    self:SetCurrChapterId(1)
end

function LegendRoadModel:ParseConfig(cacheData)
end

function LegendRoadModel:GetStatusData()
    return self:GetCurrBtnGroup()
end

-- 是否有该球员的传奇之路配置
function LegendRoadModel:HasLegendRoad()
    return self.cardModel:HasLegendRoad()
end

-- 获得卡牌model
function LegendRoadModel:GetCardModel()
    return self.cardModel
end

-- 当前所在章节id
function LegendRoadModel:GetCurrChapterId()
    return tonumber(self.currChapterId)
end

function LegendRoadModel:SetCurrChapterId(chapter)
    if chapter <= 0 then --未解锁是为0
        chapter = 1
    end
    self.currChapterId = chapter
    -- 设置章节后，将关卡切换回本章已解锁的最大关卡
    -- 未解锁即第一关
    local stage = 1
    self:SetCurrStageId(stage)
end

-- 当前所在关卡id
function LegendRoadModel:GetCurrStageId()
    return tonumber(self.currStageId)
end

function LegendRoadModel:SetCurrStageId(stage)
    if stage <= 0 then --未解锁是为0
        stage = 1
    end
    self.currStageId = stage
end

-- 获得所有章节的数据，用于上方显示用
function LegendRoadModel:GetChapterDatas()
    return LegendRoadImprove or {}
end

-- 当前章节中所有关卡的数据，用于显示道路
function LegendRoadModel:GetCurrStageDatas()
    local chapterDatas = self:GetChapterDatas()
    local stageDatas = chapterDatas[tostring(self:GetCurrChapterId())] or {}
    return stageDatas
end

-- 当前章节选择下关卡的资源
function LegendRoadModel:GetCurrStageResPath()
    return "Assets/CapstonesRes/Game/UI/Scene/LegendRoad/Prefabs/Common/LegendRoadChapterRoad_1.prefab"
end

-- 获得的当前章节标题
function LegendRoadModel:GetCurrChapterTitle()
    local currChapterId = self:GetCurrChapterId()
    return self:GetChapterTitle(currChapterId)
end

function LegendRoadModel:GetChapterTitle(currChapterId)
    local title = self.configPlayer.title
    local chapterTitle = title[tostring(currChapterId)] or title[tonumber(currChapterId)]
    return chapterTitle
end

-- 获得当前章节、当前关卡下的关卡详细数据
function LegendRoadModel:GetCurrStageDetailData()
    local currChapterId = self:GetCurrChapterId()
    local currStageId = self:GetCurrStageId()
    local res = {}
    -- 关卡标题
    local stageTitleKey = "title" .. tostring(currChapterId)
    res.stageTitle = self.configPlayer[stageTitleKey] ~= nil and self.configPlayer[stageTitleKey][tostring(currStageId)] or ""
    -- 关卡描述
    local stageDescKey = "desc" .. tostring(currChapterId)
    res.stageDesc = self.configPlayer[stageDescKey] ~= nil and self.configPlayer[stageDescKey][tostring(currStageId)] or ""
    -- 当前关卡增益的配置
    res.improveConfig = self:GetCurrStageImprove()
    return res
end

-- 获取本卡当前章节、当前关卡是否激活
function LegendRoadModel:IsActiveCurrStage()
    local chapterProgress, stageProgress = self:GetCardLegendProgress(true)
    local currChapterId = self:GetCurrChapterId()
    local currStageId = self:GetCurrStageId()
    return chapterProgress * 100 + stageProgress >= currChapterId * 100 + currStageId
end

function LegendRoadModel:GetCurrStageImprove()
    local cid = self.cardModel:GetCid()
    return LegendRoadImproveModel.GetImproveConfig(cid, self:GetCurrChapterId(), self:GetCurrStageId())
end

function LegendRoadModel:GetStageImprove(chapterId, stageId)
    local cid = self.cardModel:GetCid()
    return LegendRoadImproveModel.GetImproveConfig(cid, chapterId, stageId)
end

-- 获得头像
function LegendRoadModel:GetPicIndex()
    return self:HasLegendRoad() and self.configPlayer.picIndex or ""
end

-- 获得当前关卡该球员若是improveType = 3时所加成的属性key列表
-- LegendRoadImproveItemToggleSelView调用
function LegendRoadModel:GetImproveAttrTypeList(chapterId)
    if not self:HasLegendRoad() then
        return {}
    end

    local currChapterId = chapterId or self:GetCurrChapterId()
    local attrListMap = LegendRoadImproveModel.GetImproveAttr(self.cardModel:GetCid())
    local attrList = attrListMap[tostring(currChapterId)]

    local detailTypeList = {}
    for i, attrKey in ipairs(attrList) do
        local data = {}
        data.name = lang.transstr(attrKey)
        data.slot = i - 1 -- 服务器是从0开始
        table.insert(detailTypeList, data)
    end
    return detailTypeList
end

-- 获得当前关卡该球员若是improveType = 4时所加成的技能名称及槽位列表
-- LegendRoadImproveItemToggleSelView调用
-- @param detailImprove: LegendRoadImprove中配置的improve = 4的detailImprove
function LegendRoadModel:GetImproveSkillNameList(detailImprove)
    local res = {}
    if not self:HasLegendRoad() or table.isEmpty(detailImprove) then
        return res
    end

    for slot, v in pairs(detailImprove) do
        local skillItemModel = self.cardModel:GetSkillModel(tonumber(slot))
        if skillItemModel ~= nil and not skillItemModel:IsPasterSkill() then
            table.insert(res, {
                slot = slot,
                name = skillItemModel:GetName()
            })
        end
    end
    table.sort(res, function(a, b)  return tonumber(a.slot) < tonumber(b.slot) end)
    return res
end

--技能是否是锁定状态
function LegendRoadModel:IsLockSkill(detailImprove)
    local skillKey = detailImprove[1]
    local skillId = self:GetSkillId(skillKey)
    return self:IsLockSkillBySkillId(skillId)
end

--技能是否是锁定状态
function LegendRoadModel:IsLockSkillBySkillId(skillId)
    return Skills[skillId].openValue == 0
end

-- 获得当前关卡该球员若是improve = 7时所获得的技能model
function LegendRoadModel:GeImproveSkillItemModel(detailImprove)
    local skillKey = detailImprove[1]
    local skillId = self:GetSkillId(skillKey)
    return self:GetSkillModel(skillId)
end

function LegendRoadModel:GetSkillModel(skillId)
    local pcid = self.cardModel:GetPcid()
    local skillItemModel = nil
    if skillId then
        skillItemModel = LegendSkillModel.new()
        skillItemModel:InitWithCache(pcid, skillId)
    end
    return skillItemModel
end

function LegendRoadModel:GetSkillId(skillKey)
    local skillId = self.configPlayer[skillKey] or ""
    return skillId
end

function LegendRoadModel:GetUnlockedDesc(improveConfig)
    local improveType = improveConfig.improveType
    local detailImprove = improveConfig.detailImprove
    local desc = ""
    if improveType == ImproveType.Attr_All then -- 全属性增加，1
        desc = lang.trans("legend_road_effect_1", detailImprove[1])
    elseif improveType == ImproveType.Attr_Train then -- 可培养全属性增加，2
        desc = lang.trans("legend_road_effect_2", detailImprove[1])
    elseif improveType == ImproveType.Attr_Single then -- 单属性增加，3
        local attrTypeList = self:GetImproveAttrTypeList() -- 属性名称key列表
        local nums = table.nums(attrTypeList)
        local value = detailImprove[1] or 0
        for i, v in ipairs(attrTypeList) do
            local name = v.name
            desc = tobool(i > 1) and desc .. lang.transstr("connect_or") or desc
            desc = desc .. lang.transstr("legend_road_effect_3", name, value)
            desc = tobool(i < nums) and desc .. "\n" or desc
        end
    elseif improveType == ImproveType.Skill_Single then
        local skillList = self:GetImproveSkillNameList(detailImprove)
        local nums = table.nums(skillList)
        for i, skill in ipairs(skillList) do
            local slot = skill.slot
            local name = skill.name
            local plus = detailImprove[tostring(slot)] or 0
            desc = tobool(i > 1) and desc .. lang.transstr("connect_or") or desc
            desc = desc .. lang.transstr("legend_road_effect_4", name, plus)
            desc = tobool(i < nums) and desc .. "\n" or desc
        end
    elseif improveType == ImproveType.Skill_All then -- 全技能等级增加，5
        desc = lang.trans("legend_road_effect_5", detailImprove[1])
    elseif improveType == ImproveType.Paster_EX then -- EX贴纸，6
        desc = lang.trans("legend_road_effect_6")
    elseif improveType == ImproveType.Skill_New then -- 新技能，7
        local skillKey = detailImprove[1]
        local skillId = self:GetSkillId(skillKey)
        local skillData = Skills[skillId] or {}
        local name = skillData.skillName
        desc = lang.trans("legend_road_effect_7", name)
    end
    return desc
end

function LegendRoadModel:GetStageNum(chapterId)
    local chapterDatas = self:GetChapterDatas()
    local stageDatas = chapterDatas[tostring(chapterId)] or {}
    local stageNums = table.nums(stageDatas)
    return stageNums
end

function LegendRoadModel:GetPreviewData(chapterId)
    local stageNums = self:GetStageNum(chapterId)
    local skillIdMap = {}
    local markMap, previewMap = {}, {}
    for i = 1, stageNums do
        local improveConfig = self:GetStageImprove(chapterId, i)
        local improveType = improveConfig.improveType
        local detailImprove = improveConfig.detailImprove
        local data = {}
        data.isUnlock = true
        data.index = improveType
        if improveType == ImproveType.Attr_All then -- 全属性增加，1
            if not markMap[improveType] then
                data.improve = detailImprove[1]
                data.desc = lang.trans("legend_road_effect_1", "")
                table.insert(previewMap, data)
            end
        elseif improveType == ImproveType.Attr_Train then -- 可培养全属性增加，2
            if not markMap[improveType] then
                data.improve = detailImprove[1]
                data.desc = lang.trans("legend_road_effect_2", "")
                table.insert(previewMap, data)
            end
        elseif improveType == ImproveType.Attr_Single then -- 单属性增加，3
            if not markMap[improveType] then
                data.desc = lang.trans("legend_road_effect_8")
                table.insert(previewMap, data)
            end
        elseif improveType == ImproveType.Skill_Single then
            if not markMap[improveType] then
                data.desc = lang.trans("legend_road_effect_9")
                table.insert(previewMap, data)
            end
        elseif improveType == ImproveType.Skill_All then -- 全技能等级增加，5
            if not markMap[improveType] then
                data.improve = detailImprove[1]
                data.desc = lang.trans("legend_road_effect_10")
                table.insert(previewMap, data)
            end
        elseif improveType == ImproveType.Paster_EX then -- EX贴纸，6
            if not markMap[improveType] then
                data.desc = lang.trans("legend_road_effect_6")
                table.insert(previewMap, data)
            end
        elseif improveType == ImproveType.Skill_New then -- 新技能，7
            local skillKey = detailImprove[1]
            local skillId = self:GetSkillId(skillKey)
            table.insert(skillIdMap, skillId)
            if not markMap[improveType] then
                data.desc = lang.trans("legend_road_effect_11")
                table.insert(previewMap, data)
            end
        end
        markMap[improveType] = true
    end
    table.sort(previewMap, function(a, b) return a.index < b.index end)
    return previewMap, skillIdMap
end

-- 效果总览分为左右两边（有顺序）
function LegendRoadModel:AllotImproveOrder(improveMap)
    local leftOrderMap = {}
    local rightOrderMap = {}
    for improveType, data in pairs(improveMap) do
        local v = clone(data)
        improveType = tonumber(improveType)
        if improveType == ImproveType.Attr_All then
            v.index = 1
            table.insert(leftOrderMap, v)
        elseif improveType == ImproveType.Attr_Train then
            v.index = 1
            table.insert(rightOrderMap, v)
        elseif improveType == ImproveType.Paster_EX then
            v.index = 2
            table.insert(leftOrderMap, v)
        elseif improveType == ImproveType.Skill_All then
            v.index = 2
            table.insert(rightOrderMap, v)
        elseif improveType == ImproveType.Attr_Single then
            local attrList = v.attr
            local index = 3
            for key, value in pairs(attrList) do
                local data = {attr = {}}
                data.index = index + 0.1
                data.attr.key = key
                data.attr.value = value
                data.improveType = improveType
                table.insert(leftOrderMap, data)
            end
        elseif improveType == ImproveType.Skill_Single then
            local skillList = v.skill
            local index = 3
            for slot, value in pairs(skillList) do
                local data = {skill = {}}
                data.index = index + 0.1
                data.skill.slot = slot
                data.skill.value = value
                data.improveType = improveType
                table.insert(rightOrderMap, data)
            end
        elseif improveType == ImproveType.Skill_New then
            v.index = 4
            table.insert(leftOrderMap, v)
        end
    end
    table.sort(leftOrderMap, function (a, b) return a.index < b.index end)
    table.sort(rightOrderMap, function (a, b) return a.index < b.index end)
    return leftOrderMap, rightOrderMap
end

-- 获取当前章节提升属性
function LegendRoadModel:GetCurrentChapterImprove(chapterId)
    local pcid = self.cardModel:GetPcid()
    local chapterProgress, stageProgress = self:GetCardLegendProgress()
    local improveMap = self.legendCardsMapModel:GetCurrentChapterImprove(pcid, chapterProgress, stageProgress, chapterId)
    return improveMap
end

-- 获取所有激活章节提升属性
function LegendRoadModel:GetActiveChapterImprove()
    local pcid = self.cardModel:GetPcid()
    local activeImproveMap = self.legendCardsMapModel:GetActiveChapterImprove(pcid)
    return activeImproveMap
end

function LegendRoadModel:GetConsumePieceModel()
    local consumePieceModels = {}
    local chapter = self:GetCurrChapterId()
    local stage = self:GetCurrStageId()
    local chapterData = LegendRoadConsume[tostring(chapter)]
    if chapterData then
        local stageData = chapterData[tostring(stage)]
        if stageData then
            local memoryPieceData = stageData["memoryPiece" .. self.qualitySuffix]
            local pasterPieceData = stageData["pasterPiece" .. self.qualitySuffix]
            if memoryPieceData then
                local cardPieceModel = CardPieceModel.new()
                cardPieceModel:InitWithStatic(self.baseId, tonumber(memoryPieceData[1]))
                table.insert(consumePieceModels, cardPieceModel)
            end
            if pasterPieceData and pasterPieceData ~= "" then
                local cardPasterPieceModel = CardPasterPieceModel.new()
                cardPasterPieceModel:InitWithStatic(pasterPieceData[1], tonumber(pasterPieceData[2]))
                table.insert(consumePieceModels, cardPasterPieceModel)
            end
        end
    end
    return consumePieceModels
end

function LegendRoadModel:GetPieceMapModel()
    if not self.playerPiecesMapModel then
        self.playerPiecesMapModel = PlayerPiecesMapModel.new()
    end
    return self.playerPiecesMapModel
end

function LegendRoadModel:GetPasterMapModel()
    if not self.pasterPiecesMapModel then
        self.pasterPiecesMapModel = PasterPiecesMapModel.new()
    end
    return self.pasterPiecesMapModel
end

function LegendRoadModel:GetBagPieceNum(pieceModel)
    local num = 0
    if pieceModel:IsPasterPiece() then
        local pasterPiecesMapModel = self:GetPasterMapModel()
        local pieceData = pasterPiecesMapModel:GetPieceData(pieceModel:GetId()) or {}
        num = tonumber(pieceData.num)
    else
        local playerPiecesMapModel = self:GetPieceMapModel()
        local pieceData = playerPiecesMapModel:GetPieceData(pieceModel:GetId()) or {}
        num = tonumber(pieceData.num)
    end
    return num
end

function LegendRoadModel:GetCardLegendProgress(bOnlySelf)
    return self.legendCardsMapModel:GetLegendCardProgressChapterAndStage(self.cardModel:GetPcid(), bOnlySelf)
end

function LegendRoadModel:HandelPartnerAscend()
    local chemicalCid = self.configPlayer.partner
    local sameCardList = self.cardModel:GetChemicalPlayersPcids(chemicalCid)
    local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
    for pcid, v in pairs(sameCardList) do
        local playerModel = SimpleCardModel.new(pcid)
        local isMaxAscend = playerModel:IsMaxAscend()
        if isMaxAscend then
            return true
        end
    end
    return false
end

function LegendRoadModel:HandelTrainingBase(unlockData)
    local unlockDetail = unlockData.unlockDetail
    local trainningBaseData = self.cardModel:GetTrainingBaseData()
    local chapter = trainningBaseData.chapter
    if tonumber(chapter) >= tonumber(unlockDetail) then
        return true
    end
    return false
end

function LegendRoadModel:IsUnlockChapter(chapterId)
    local chapter, stage = self:GetCardLegendProgress()
    local currChapterId = chapterId or self:GetCurrChapterId()
    local isUnlock = false

    if currChapterId == chapter + 1 then
        local nums = self:GetStageNum(currChapterId)
        if stage == nums then
            local unlockData = self:GetUnlockChapterData(chapterId)
            local unlockType = unlockData.unlockType
            if unlockType == "TrainingBase" then
                isUnlock = self:HandelTrainingBase(unlockData)
            elseif unlockType == "PartnerAscendMax" then
                isUnlock = self:HandelPartnerAscend(unlockData)
            elseif unlockType == "" then
                isUnlock = true
            end
        end
    end
    return isUnlock
end

function LegendRoadModel:GetUnlockChapterData(chapterId)
    local currChapterId = chapterId or self:GetCurrChapterId()
    local data = LegendRoadUnlock[tostring(currChapterId)]
    return data
end

-- 预览解锁信息
function LegendRoadModel:GetPreviewUnlockData(chapterId)
    local chapter, stage = self:GetCardLegendProgress()
    local previewMap = {}
    local data = {}
    if chapterId == chapter + 1 then
        local nums = self:GetStageNum(chapterId)
        if stage == nums then
            data.isUnlock = true
        end
    end
    data.desc = lang.transstr("legend_road_unlock_pre")
    table.insert(previewMap, data)

    local unlockData = self:GetUnlockChapterData(chapterId)
    local unlockType = unlockData.unlockType
    if unlockType == "TrainingBase" then
        data = {}
        data.isUnlock = self:HandelTrainingBase(unlockData)
        data.desc = unlockData.desc
        table.insert(previewMap, data)
    elseif unlockType == "PartnerAscendMax" then
        data = {}
        data.isUnlock = self:HandelPartnerAscend(unlockData)
        local chemicalCid = self.configPlayer.partner
        local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
        local playerModel = StaticCardModel.new(chemicalCid)
        local name = playerModel:GetName()
        local qualitySuffix = CardHelper.GetQualityNameConfigFixed(playerModel:GetCardQuality(), playerModel:GetCardQualitySpecial())
        name = "·" .. qualitySuffix .. name .. "·"
        data.desc = string.gsub(unlockData.desc, "#partnerplayer#", name)
        table.insert(previewMap, data)
    end
    return previewMap
end

function LegendRoadModel:IsUnlockStage()
    local chapter, stage = self:GetCardLegendProgress()
    local currChapterId = self:GetCurrChapterId()
    local currStageId = self:GetCurrStageId()

    local isUnlock, isNextUnlock = false, false
    if currChapterId < chapter then
        isUnlock = true
        isNextUnlock = true
    elseif currChapterId == chapter then
        isUnlock = tobool(currStageId <= stage)
        isNextUnlock = tobool(currStageId == stage + 1)
    end
    return isUnlock, isNextUnlock
end

function LegendRoadModel:RefreshLegendMapModel(data)
    for pcid, legendCardData in pairs(data) do
        local teamModel = self.cardModel:GetTeamModel()
        self.legendCardsMapModel:ResetLegendCardData(pcid, legendCardData, teamModel)
    end
end

function LegendRoadModel:UnlockLegendRoadChapter(data)
    self:RefreshLegendMapModel(data)
    EventSystem.SendEvent("LegendCards_UnlockChapter")
end

function LegendRoadModel:CostPiece(costData)
    local cardPiece = costData.cardPiece
    if cardPiece then
        local cid = cardPiece.cid
        local num = cardPiece.num
        local data = {}
        data.cid = cid
        data.num = num
        self.playerPiecesMapModel:ResetPieceData(cid, data)
    end
    local pasterPiece = costData.pasterPiece
    if pasterPiece then
        local id = pasterPiece.type
        local num = pasterPiece.num
        local data = {}
        data.type = id
        data.num = num
        self.pasterPiecesMapModel:ResetPieceData(id, data)
    end
end

function LegendRoadModel:GetAppointStageActiveIndex(pcid, chapterId, stageId)
    return self.legendCardsMapModel:GetAppointStageActiveIndex(pcid, chapterId, stageId)
end

-- 本卡的传奇之路是否可用于当前助阵卡
function LegendRoadModel:CanSupporting()
    return self.cardModel:LegendRoadIsCanSupporting()
end

return LegendRoadModel
