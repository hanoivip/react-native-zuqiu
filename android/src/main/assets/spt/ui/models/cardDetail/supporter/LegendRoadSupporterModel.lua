local Model = require("ui.models.Model")
local SupporterType = require("ui.models.cardDetail.supporter.SupporterType")
local SlrType = SupporterType.SlrType
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local LegendRoadModel = require("ui.models.legendRoad.LegendRoadModel")
local LegendRoadSupporterModel = class(Model, "LegendRoadSupporterModel")

function LegendRoadSupporterModel:ctor(supporterModel)
    LegendRoadSupporterModel.super.ctor(self)
    self.supporterModel = supporterModel
    self.selectType = nil
end

function LegendRoadSupporterModel:Init()

end

function LegendRoadSupporterModel:GetCardModel()
	return self.supporterModel:GetCardModel()
end

function LegendRoadSupporterModel:GetSupportCardModel()
	return self.supporterModel:GetSupportCardModel()
end

function LegendRoadSupporterModel:GetCurTrainingInfo()
	return self.supporterModel:GetCurTrainingInfo()
end

function LegendRoadSupporterModel:GetSelectTrainingType()
	return self.supporterModel:GetSelectTrainingType()
end

function LegendRoadSupporterModel:SetSelectLegendRoadType(selectType)
	self.selectType = selectType
end

function LegendRoadSupporterModel:GetSelectLegendRoadType()
	if self.selectType == nil then
		self.selectType = self:GetDefSelectIndex()
	end
	return self.selectType
end

local function CheckZero(legendRoad, chapterProgress, stageProgress)
	if stageProgress == 0 and chapterProgress ~= 1 then
		return chapterProgress - 1, legendRoad:GetStageNum(chapterProgress - 1)
	end
	return chapterProgress, stageProgress
end

function LegendRoadSupporterModel:GetData()
	local data = {}
	local supportCard = self:GetSupportCardModel()
	if not supportCard then
		--没助阵卡
		data.noSupportCard = true
		return data
	end
	local cardModel = self:GetCardModel()
	local cardLegendRoad = LegendRoadModel.new(cardModel)
	local supportCardLegendRoad = LegendRoadModel.new(supportCard)
	if not cardModel:IsOpenLegendRoad() then
		--本卡没开传奇之路
		data.noOpen = true
		return data
	end
	data.chapterProgress, data.stageProgress = CheckZero(cardLegendRoad, cardLegendRoad:GetCardLegendProgress(true))
	if not supportCard:IsOpenLegendRoad() then
		--助阵卡没开传奇之路
		data.noSupportOpen = true
		return data
	end
	data.supportChapterProgress, data.supportStageProgress = CheckZero(supportCardLegendRoad, supportCardLegendRoad:GetCardLegendProgress())	
	if not supportCardLegendRoad:CanSupporting() then
		--助阵卡传奇之路被使用了
		data.isSupportOther = true
		return data
	end
    if data.supportChapterProgress * 100 + data.supportStageProgress <= data.chapterProgress * 100 + data.stageProgress then
    	--助阵卡进度低于本卡
    	data.curSupportChapterProgress = data.supportChapterProgress
    	data.curSupportStageProgress = data.supportStageProgress
    else
    	data.lockChapter = 0
	    data.unLockData = nil
	    local trainningInfo = self:GetCurTrainingInfo()
		if trainningInfo == {} then
			trainningInfo = {chapter = -1}
		end
	    for i = data.chapterProgress + 1, data.supportChapterProgress do
	    	data.unLockData = supportCardLegendRoad:GetUnlockChapterData(i)
	    	if data.unLockData.unlockType == "TrainingBase" then
	    		if data.unLockData.unlockDetail > trainningInfo.chapter then
	    			data.lockChapter = i
	    			break
	    		end
	    	end
	    end
	    if data.lockChapter ~= 0 then
	    	--锁了
	    	data.curSupportChapterProgress = data.lockChapter - 1
	    	if data.curSupportChapterProgress < data.supportChapterProgress then
	    		data.curSupportStageProgress = supportCardLegendRoad:GetStageNum(data.curSupportChapterProgress)
	    	else
	    		data.curSupportStageProgress = data.supportStageProgress
	    	end
	    	data.lockStage = data.lockChapter == data.supportChapterProgress and data.supportStageProgress or supportCardLegendRoad:GetStageNum(data.lockChapter)
	    	local selectTrainingType = self:GetSelectTrainingType()
	    	local lockCardModel = selectTrainingType == SupporterType.StType.SupportCard and supporterCard or cardModel
	    	local quality = lockCardModel:GetCardQuality()
		    local QualitySpecial = lockCardModel:GetCardQualitySpecial()
		    local fixQuality = CardHelper.GetQualityFixed(quality, QualitySpecial)
		    local qualitySign = CardHelper.GetQualitySign(fixQuality)
		    local name = lockCardModel:GetName()
	    	data.lockConditionStr = lang.trans("support_legend_lockCondition", qualitySign .. name, data.unLockData.unlockDetail)
	    else
	    	--全开
	    	data.curSupportChapterProgress = data.supportChapterProgress
    		data.curSupportStageProgress = data.supportStageProgress
	    end
    end
    return data
end

--这里是第一次获取的时候给一个默认选择
function LegendRoadSupporterModel:GetDefSelectIndex()
	local data = self:GetData()
	if data.noOpen or data.noSupportCard or data.noSupportOpen or data.isSupportOther then
		return SlrType.SelfCard
	end
	if data.curSupportChapterProgress * 100 + data.curSupportStageProgress > data.chapterProgress * 100 + data.stageProgress then
		return SlrType.SupportCard
	else
		return SlrType.SelfCard
	end
end

function LegendRoadSupporterModel:IsLowerSelect(selectType)
	local data = self:GetData()
	if data.noOpen or data.noSupportCard or data.noSupportOpen or data.isSupportOther then
		return false
	end
	local curSupport = data.curSupportChapterProgress * 100 + data.curSupportStageProgress
	local myself = data.chapterProgress * 100 + data.stageProgress
	if curSupport == myself then
		return false
	elseif curSupport > myself then
		return SlrType.SupportCard ~= selectType
	else
		return SlrType.SelfCard ~= selectType
	end
end

return LegendRoadSupporterModel
