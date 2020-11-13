local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local SortType = require("ui.controllers.playerList.SortType")
local CardBuilder = require("ui.common.card.CardBuilder")
local LockTypeFilter = require("ui.common.lock.LockTypeFilter")
local LegendRoadModel = require("ui.models.legendRoad.LegendRoadModel")
local PlayerListModel = require("ui.models.playerList.PlayerListModel")
local SupporterSelectModel = class(PlayerListModel, "SupporterSelectModel")

-- 按贴纸数量排序（不可助阵的放在最后）
local function PasterNumCompWithFall(aModel, bModel)
    local aNum = aModel:GetWeekPasterNum() + aModel:GetHonorPasterNum() + aModel:GetAnnualPasterNum() + aModel:GetMonthPasterNum()
    local bNum = bModel:GetWeekPasterNum() + bModel:GetHonorPasterNum() + bModel:GetAnnualPasterNum() + bModel:GetMonthPasterNum()
    local aQuality = aModel:GetIsCardPlusQuality()
    local bQuality = bModel:GetIsCardPlusQuality()
    local aCanSupport = not aModel:IsInUse(LockTypeFilter.AllTeam) and not aModel:IsInSupporterLock()
    local bCanSupport = not bModel:IsInUse(LockTypeFilter.AllTeam) and not bModel:IsInSupporterLock()
    if not aCanSupport and bCanSupport then
        return false
    elseif aCanSupport and not bCanSupport then
        return true
    end
    if aNum == bNum then
        return aQuality > bQuality
    else
        return aNum > bNum
    end
end

local function PasterNumCompWithRise(aModel, bModel)
    local aNum = aModel:GetWeekPasterNum() + aModel:GetHonorPasterNum() + aModel:GetAnnualPasterNum() + aModel:GetMonthPasterNum()
    local bNum = bModel:GetWeekPasterNum() + bModel:GetHonorPasterNum() + bModel:GetAnnualPasterNum() + bModel:GetMonthPasterNum()
    local aQuality = aModel:GetIsCardPlusQuality()
    local bQuality = bModel:GetIsCardPlusQuality()
    local aCanSupport = not aModel:IsInUse(LockTypeFilter.AllTeam) and not aModel:IsInSupporterLock()
    local bCanSupport = not bModel:IsInUse(LockTypeFilter.AllTeam) and not bModel:IsInSupporterLock()
    if not aCanSupport and bCanSupport then
        return false
    elseif aCanSupport and not bCanSupport then
        return true
    end
    if aNum == bNum then
        return aQuality > bQuality
    else
        return aNum < bNum
    end
end

-- 按特训进度排序（不可助阵的放在最后）
local function TrainProgressCompWithFall(aModel, bModel)
    local aTrain = aModel:GetTrainingBaseData()
    local bTrain = bModel:GetTrainingBaseData()
    local aTrainProgress = tonumber(aTrain.chapter) * 10 + tonumber(aTrain.stage)
    local bTrainProgress = tonumber(bTrain.chapter) * 10 + tonumber(bTrain.stage)
    local aQuality = aModel:GetIsCardPlusQuality()
    local bQuality = bModel:GetIsCardPlusQuality()
    local aCanSupport = not aModel:IsInUse(LockTypeFilter.AllTeam) and not aModel:IsInSupporterLock()
    local bCanSupport = not bModel:IsInUse(LockTypeFilter.AllTeam) and not bModel:IsInSupporterLock()
    if not aCanSupport and bCanSupport then
        return false
    elseif aCanSupport and not bCanSupport then
        return true
    end
    if aTrainProgress == bTrainProgress then
        return aQuality > bQuality
    else
        return aTrainProgress > bTrainProgress
    end
end

local function TrainProgressCompWithRise(aModel, bModel)
    local aTrain = aModel:GetTrainingBaseData()
    local bTrain = bModel:GetTrainingBaseData()
    local aTrainProgress = tonumber(aTrain.chapter) * 10 + tonumber(aTrain.stage)
    local bTrainProgress = tonumber(bTrain.chapter) * 10 + tonumber(bTrain.stage)
    local aQuality = aModel:GetIsCardPlusQuality()
    local bQuality = bModel:GetIsCardPlusQuality()
    local aCanSupport = not aModel:IsInUse(LockTypeFilter.AllTeam) and not aModel:IsInSupporterLock()
    local bCanSupport = not bModel:IsInUse(LockTypeFilter.AllTeam) and not bModel:IsInSupporterLock()
    if not aCanSupport and bCanSupport then
        return false
    elseif aCanSupport and not bCanSupport then
        return true
    end
    if aTrainProgress == bTrainProgress then
        return aQuality > bQuality
    else
        return aTrainProgress < bTrainProgress
    end
end

-- 按传奇之路进度排序（不可助阵的放在最后）
local function LegendProgressCompWithFall(aModel, bModel)
    -- 不可助阵的后置
    local aCanSupport = not aModel:IsInUse(LockTypeFilter.AllTeam) and not aModel:IsInSupporterLock()
    local bCanSupport = not bModel:IsInUse(LockTypeFilter.AllTeam) and not bModel:IsInSupporterLock()
    if not aCanSupport and bCanSupport then
        return false
    elseif aCanSupport and not bCanSupport then
        return true
    end
    -- 没开传奇之路的后置
    local aIsOpenLegendRoad = aModel:IsOpenLegendRoad()
    local bIsOpenLegendRoad = bModel:IsOpenLegendRoad()
    if not aIsOpenLegendRoad and bIsOpenLegendRoad then
        return false
    elseif aIsOpenLegendRoad and not bIsOpenLegendRoad then
        return true
    end
    -- 进度排序（降序）
    local aLegendRoad = LegendRoadModel.new(aModel)
    local aChapter, aStage = aLegendRoad:GetCardLegendProgress()
    local bLegendRoad = LegendRoadModel.new(bModel)
    local bChapter, bStage = bLegendRoad:GetCardLegendProgress()
    local aQuality = aModel:GetIsCardPlusQuality()
    local bQuality = bModel:GetIsCardPlusQuality()
    if aChapter == bChapter and aStage == bStage then
        return aQuality > bQuality
    elseif aChapter == bChapter then
        return aStage > bStage
    else
        return aChapter > bChapter
    end
end

local function LegendProgressCompWithRise(aModel, bModel)
    -- 不可助阵的后置
    local aCanSupport = not aModel:IsInUse(LockTypeFilter.AllTeam) and not aModel:IsInSupporterLock()
    local bCanSupport = not bModel:IsInUse(LockTypeFilter.AllTeam) and not bModel:IsInSupporterLock()
    if not aCanSupport and bCanSupport then
        return false
    elseif aCanSupport and not bCanSupport then
        return true
    end
    -- 没开传奇之路的前置
    local aIsOpenLegendRoad = aModel:IsOpenLegendRoad()
    local bIsOpenLegendRoad = bModel:IsOpenLegendRoad()
    if not aIsOpenLegendRoad and bIsOpenLegendRoad then
        return true
    elseif aIsOpenLegendRoad and not bIsOpenLegendRoad then
        return false
    end
    -- 进度排序（升序）
    local aLegendRoad = LegendRoadModel.new(aModel)
    local aChapter, aStage = aLegendRoad:GetCardLegendProgress()
    local bLegendRoad = LegendRoadModel.new(bModel)
    local bChapter, bStage = bLegendRoad:GetCardLegendProgress()
    local aQuality = aModel:GetIsCardPlusQuality()
    local bQuality = bModel:GetIsCardPlusQuality()
    if aChapter == bChapter and aStage == bStage then
        return aQuality > bQuality
    elseif aChapter == bChapter then
        return aStage < bStage
    else
        return aChapter < bChapter
    end
end

function SupporterSelectModel:ctor(cardModel)
    self:SetCardList(cardModel)
    SupporterSelectModel.super.ctor(self)
end

function SupporterSelectModel:Init(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    SupporterSelectModel.super.Init(self, selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
    self.sortFuncMap[SortType.PASTER_NUM_FALL] = PasterNumCompWithFall
    self.sortFuncMap[SortType.PASTER_NUM_RISE] = PasterNumCompWithRise
    self.sortFuncMap[SortType.TRAIN_PROGRESS_FALL] = TrainProgressCompWithFall
    self.sortFuncMap[SortType.TRAIN_PROGRESS_RISE] = TrainProgressCompWithRise
    self.sortFuncMap[SortType.LEGEND_PROGRESS_FALL] = LegendProgressCompWithFall
    self.sortFuncMap[SortType.LEGEND_PROGRESS_RISE] = LegendProgressCompWithRise
end

function SupporterSelectModel:GetCardList()
    return self.supporterList
end

function SupporterSelectModel:SetCardList(playerCardModel)
    local selfQuality = playerCardModel:GetCardQuality()
    local selfIsGKPlyaer = playerCardModel:IsGKPlayer()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.playerTeamsModel = PlayerTeamsModel.new()
    self.equipPieceMapModel = EquipPieceMapModel.new()
    self.equipsMapModel = EquipsMapModel.new()

    local cardList = self.playerCardsMapModel:GetCardList()
    self.tempModelMap = {}
    self.supporterList = {}
    for i, pcid in ipairs(cardList) do
        local cardModel = CardBuilder.GetOwnCardModel(pcid, self.playerTeamsModel, self.playerCardsMapModel, self.equipPieceMapModel, self.equipsMapModel)
        while true do
            -- 助阵球员要求
            -- 0.排除自己
            if playerCardModel:GetPcid() == tonumber(pcid) then break end
            -- 2.被助阵的球员不显示在列表中
            if cardModel:IsHasSupportCard() then break end
            -- 3.必须为符合品质的球员：EX、传奇、SSS品质间球员可互相助阵；典藏、周年庆、SS+、SS品质间球员可互相助阵
            local supporterQuality = cardModel:GetQualityConfigFixed()
            local qualityDemand = playerCardModel:IsSupporterQualityFulfill(supporterQuality)
            if not qualityDemand then break end
            -- 4.位置要求：门将位置球员只能选择门将球员来助阵，其他位置球员间可互相助阵
            local supporterIsGKPlayer = cardModel:IsGKPlayer()
            if selfIsGKPlyaer ~= supporterIsGKPlayer then break end
            -- 5.必须为满级满进阶的球员
            if not cardModel:CanUseSupporter() then break end
            -- 6.如果一个满级满进阶的球员，既没携带普通周贴、全能周贴、纪念贴纸、荣耀贴纸，又没有开启特训，又没开启传奇之路，则不显示在内
            local weekPasterNum = cardModel:GetWeekPasterNum()
            local honorPasterNum = cardModel:GetHonorPasterNum()
            local annualPasterNum = cardModel:GetAnnualPasterNum()
            local hasPaster = (weekPasterNum + honorPasterNum + annualPasterNum) > 0 or cardModel:HasMonthPaster()
            local hasTrained = tobool(cardModel:GetTrainingBase() > 0)
            local hasLegendRoad = cardModel:IsOpenLegendRoad()
            if not hasPaster and not hasTrained and not hasLegendRoad then break end

            self.tempModelMap[tostring(pcid)] = cardModel
            table.insert(self.supporterList, pcid)
            break
        end
    end
end

function SupporterSelectModel:GetSortAsc(typeIndex, cardModelArray)
    local sortCardModelArray = {}
    if typeIndex == SortType.DEFAULT then
        sortCardModelArray = self:SpecialSortDefaultAsc(typeIndex, cardModelArray)
    elseif typeIndex == SortType.PASTER_NUM_FALL or typeIndex == SortType.PASTER_NUM_RISE then
        table.sort(cardModelArray, self.sortFuncMap[typeIndex])
        sortCardModelArray = cardModelArray
    elseif typeIndex == SortType.TRAIN_PROGRESS_FALL or typeIndex == SortType.TRAIN_PROGRESS_RISE then
        table.sort(cardModelArray, self.sortFuncMap[typeIndex])
        sortCardModelArray = cardModelArray
    elseif typeIndex == SortType.LEGEND_PROGRESS_FALL or typeIndex == SortType.LEGEND_PROGRESS_RISE then
        table.sort(cardModelArray, self.sortFuncMap[typeIndex])
        sortCardModelArray = cardModelArray
    end
    return sortCardModelArray
end

-- 默认排序顺序（不可助阵的放在最后）
function SupporterSelectModel:SpecialSortDefaultAsc(typeIndex, cardModelArray)
    local sortArray = {}
    local canSupportArray = {}
    local canNotSupportArray = {}
    for i, v in pairs(cardModelArray) do
        if v:IsInUse(LockTypeFilter.AllTeam) or v:IsInSupporterLock() then
            table.insert(canNotSupportArray, v)
        else
            table.insert(canSupportArray, v)
        end
    end
    canSupportArray = self:SortDefaultAsc(typeIndex, canSupportArray)
    canNotSupportArray = self:SortDefaultAsc(typeIndex, canNotSupportArray)
    sortArray = canSupportArray + canNotSupportArray
    return sortArray
end

return SupporterSelectModel
