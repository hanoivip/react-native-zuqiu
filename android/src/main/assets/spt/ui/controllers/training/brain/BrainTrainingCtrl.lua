local BaseCtrl = require("ui.controllers.BaseCtrl")
local BrainTrainingModel = require("ui.models.train.brain.BrainTrainingModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CoreResultCtrl = require("ui.controllers.training.brain.BrainResultCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")

local BrainTrainingCtrl = class(BaseCtrl)

BrainTrainingCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Training/Brain/BrainTrainingCanvas.prefab"

function BrainTrainingCtrl:Init(trainData)
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.trainData = trainData
end

function BrainTrainingCtrl:InitView()
    self.view.onStart = function() self:OnStart() end
    self.view.onBack = function() self:OnBack() end
    self.view.onInitRankView = function(settlement) 
        self:CreateItemList()
        self:InitGameOverPanel("501", settlement)
    end            
    self.view:InitView()
end

function BrainTrainingCtrl:OnStart()
    clr.coroutine(function()
        local response = req.littleGameBeginAnswer(self.trainData.pcid)
        if api.success(response) then
            local data = response.val
            self.brainTrainingModel = BrainTrainingModel.new()
            self.brainTrainingModel:InitQuestionData(data)
            self.view:InitBrainQuestion(self.brainTrainingModel)
        end
    end)
end

function BrainTrainingCtrl:Refresh()
    self.brainTrainingModel = nil
    self:InitView()
end

function BrainTrainingCtrl:InitGameOverPanel(gameID, settlement)
    -- 答题结算请求
    local result = settlement.result
    CustomEvent.Training()
    luaevt.trig("HoolaiBISendCounterCoregame", 5, gameID, true)
    self.playerCardsMapModel:ResetCardData(result.pcid, result.cardInfo)
    -- 进入结算页面
    local coreResultCtrl = CoreResultCtrl.new(result.maxTimes, result.times, self.view.transform)
    coreResultCtrl:InitView(PlayerCardModel.new(result.pcid), result.reward, result.score)
end

function BrainTrainingCtrl:OnBack()
    res.PopScene()
end

function BrainTrainingCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(spt, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Training/Brain/BrainRankItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt:InitView(rankData, index)
        self.view.scrollView:updateItemIndex(spt, index)             
    end

    self:RefreshScrollView()
end

function BrainTrainingCtrl:RefreshScrollView()
    local rankDataList = self.brainTrainingModel:GetRankList()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

function BrainTrainingCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return BrainTrainingCtrl