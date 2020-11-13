local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TrainType = require("training.TrainType")
local TrainRankConstants = require("ui.scene.training.rank.TrainRankConstants")

local TrainRankItemView = class(unity.base)

function TrainRankItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.bgNormal = self.___ex.bgNormal
    self.detailText = self.___ex.detailText
    self.detailCount = self.___ex.detailCount
    self.brainCount = self.___ex.brainCount
    self.brainTime = self.___ex.brainTime
    self.otherDetailObject = self.___ex.otherDetailObject
    self.brainDetailObject = self.___ex.brainDetailObject
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function TrainRankItemView:InitView(rankData, index, currentType)
    GameObjectHelper.FastSetActive(brainDetailObject,currentType == TrainType.BRAIN)
    GameObjectHelper.FastSetActive(otherDetailObject,currentType ~= TrainType.BRAIN)

    self.nameTxt.text = rankData.name
    self.nameTxt.color = self.playerInfoModel:GetID() == rankData._id and Color(0.98, 0.92, 0.275, 1) or Color.white
    self.level.text = "Lv " .. tostring(rankData.lvl)

    if currentType ~= TrainType.BRAIN then
        self.detailText.text = TrainRankConstants.DetailTitle[currentType]
        self.detailCount.text = currentType == TrainType.DRIBBLE and string.convertSecondToTimeString(rankData.result) or tostring(rankData.result)
    else
        self.brainCount.text = tostring(rankData.result)
        self.brainTime.text = string.convertSecondToTimeString(rankData.useTime)
    end
    self:InitTeamLogo()
    self:InitRankShowState(rankData.rank)
end

function TrainRankItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function TrainRankItemView:GetTeamLogo()
    return self.teamLogo
end

function TrainRankItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    self.normalRank.text = lang.trans("ladder_rank", tostring(rank))
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

return TrainRankItemView