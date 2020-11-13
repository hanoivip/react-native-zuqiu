local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local Timer = require('ui.common.Timer')
local TrainRankConstants = require("ui.scene.training.rank.TrainRankConstants")
local TrainType = require("training.TrainType")

local TrainRankView = class(unity.base)

function TrainRankView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.scrollView = self.___ex.scrollView
    self.tabGroup = self.___ex.tabGroup
    self.brainDetail = self.___ex.brainDetail
    self.otherDetail = self.___ex.otherDetail
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.ThirdRank = self.___ex.ThirdRank
    self.normalRank = self.___ex.normalRank
    self.teamLogo = self.___ex.teamLogo
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.detailTitle = self.___ex.detailTitle
    self.detailCount = self.___ex.detailCount
    self.brainCountTitle = self.___ex.brainCountTitle
    self.brainTimeTitle = self.___ex.brainTimeTitle
    self.brainCount = self.___ex.brainCount
    self.brainTime = self.___ex.brainTime
    self.refreshTime = self.___ex.refreshTime
    self.residualTimer = nil
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function TrainRankView:InitView(rankModel)
    self.rankModel = rankModel
    self:BuildPlayerInfoArea()
    self:BuildRefreshTimeArea()
end

function TrainRankView:BuildPlayerInfoArea()
    GameObjectHelper.FastSetActive(self.brainDetail, self.rankModel:GetTrainType() == TrainType.BRAIN)
    GameObjectHelper.FastSetActive(self.otherDetail, self.rankModel:GetTrainType() ~= TrainType.BRAIN)

    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, self.playerInfoModel:GetTeamLogo())
    GameObjectHelper.FastSetActive(self.firstRank, self.rankModel:GetSelfRank() == 1)
    GameObjectHelper.FastSetActive(self.secondRank, self.rankModel:GetSelfRank() == 2)
    GameObjectHelper.FastSetActive(self.ThirdRank, self.rankModel:GetSelfRank() == 3)
    local isEnter = self.rankModel:GetSelfRank() > -1
    if not isEnter then
        self.normalRank.text = lang.trans("train_rankOut")
    elseif self.rankModel:GetSelfRank() > 3 then
        self.normalRank.text = lang.trans("ladder_rank", tostring(self.rankModel:GetSelfRank()))
    else 
        self.normalRank.text = ""
    end
    self.nameTxt.text = self.playerInfoModel:GetName()
    self.level.text = "lv " .. tostring(self.playerInfoModel:GetLevel())
    if self.rankModel:GetTrainType() == TrainType.BRAIN then
        self.brainCount.text = isEnter and tostring(self.rankModel:GetSelfInfo().result) or "--"
        self.brainTime.text = isEnter and string.convertSecondToTimeString(self.rankModel:GetSelfInfo().useTime) or "--"
    else
        self.detailTitle.text = TrainRankConstants.DetailTitle[self.rankModel:GetTrainType()]
        if self.rankModel:GetTrainType() == TrainType.DRIBBLE and isEnter then
            self.detailCount.text = string.convertSecondToTimeString(self.rankModel:GetSelfInfo().result)
        else
            self.detailCount.text = isEnter and tostring(self.rankModel:GetSelfInfo().result) or "--"
        end

    end
end

function TrainRankView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function TrainRankView:RegOnLeave(func)
    self.onLeaveCallBack = func
end

function TrainRankView:OnLeave()
    if type(self.onLeaveCallBack) == "function" then
        self.onLeaveCallBack()
    end
end

function TrainRankView:BuildRefreshTimeArea()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    self.residualTimer = Timer.new(self.rankModel:GetRefreshTime(), function(time)
        self.refreshTime.text = string.convertSecondToTimeTrans(time)
    end)
end

function TrainRankView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return TrainRankView