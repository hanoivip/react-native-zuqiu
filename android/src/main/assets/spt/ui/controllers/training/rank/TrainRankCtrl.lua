local BaseCtrl = require("ui.controllers.BaseCtrl")
local TrainRankModel = require("ui.models.train.rank.TrainRankModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local TrainType = require("training.TrainType")

local TrainRankCtrl = class(BaseCtrl,"TrainRankCtrl")

TrainRankCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Training/Rank/TrainingRankBoard.prefab"

function TrainRankCtrl:Init(isOpenBrain)
    self.view:RegOnInfoBarDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.rankModel = TrainRankModel.new()
    self.rankModel:SetIsOpenBrain(isOpenBrain)
    self:ClickRankTab(TrainType.DEFAULT, true)
end

function TrainRankCtrl:Refresh()
    TrainRankCtrl.super:Refresh(self)
end

function TrainRankCtrl:InitView()
    self:BindAll()
    self.view:InitView(self.rankModel)
    self:CreateItemList()
end

function TrainRankCtrl:ClickRankTab(trainType, isInit)
    self:RequestCurrentTypeRankList(trainType, isInit)
end

function TrainRankCtrl:RequestCurrentTypeRankList(trainType, isInit)
    clr.coroutine(function()
        local respone = req.littleGameRankInfo(trainType)
        if api.success(respone) then
            local data = respone.val
            if data then
                self.rankModel:InitWithProtocol(data)
                self.rankModel:SetTrainType(trainType)
                self:InitView()
            end
        end
    end)
end

function TrainRankCtrl:BindAll()
    for k, v in pairs(self.view.tabGroup) do
        v.clickRankTab = function() self:ClickRankTab(v.trainType) end
        v:InitView(self.rankModel:IsOpenBrain())
        v:ChangeState(self.rankModel:GetTrainType() == v.trainType)
    end
end

function TrainRankCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(spt, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Training/Rank/TrainingRankItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt:InitView(rankData, index, self.rankModel:GetTrainType())
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function TrainRankCtrl:RefreshScrollView()
    local rankDataList = self.rankModel:GetCurrentGameRankList()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

function TrainRankCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return TrainRankCtrl
