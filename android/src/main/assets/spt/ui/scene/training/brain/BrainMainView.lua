local GameObjectHelper = require("ui.common.GameObjectHelper")

local BrainMainView = class(unity.base)

function BrainMainView:ctor()
    self.btnStart = self.___ex.btnStart
    self.ruleArea = self.___ex.ruleArea
    self.ruleTitle = self.___ex.ruleTitle
    self.ruleText = self.___ex.ruleText
    self.operateArea = self.___ex.operateArea
    self.operateView = self.___ex.operateView
    self.btnBack = self.___ex.btnBack
    self.resultPageView = self.___ex.resultPageView
    self.resultArea = self.___ex.resultArea
    self.resultView = self.___ex.resultView
    self.questionPage = self.___ex.questionPage
    self.rightCount = 0
end

function BrainMainView:InitView()
    self:SetBoardState(true)
    GameObjectHelper.FastSetActive(self.resultArea, false)    
    self:RegButtonClick()
end

function BrainMainView:RegButtonClick()
    self.btnStart:regOnButtonClick(function()
        self:OnBtnStart()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBack()
    end)
    -- 答题时屏蔽，结束时开启
    GameObjectHelper.FastSetActive(self.btnBack.gameObject, false)
end

function BrainMainView:OnBtnStart()
    if self.onStart then
        self.onStart()
    end
end

function BrainMainView:InitBrainQuestion(brainModel)
    self.brainModel = brainModel
    self:SetBoardState(false)
    self:RefreshOperateView()
    self.operateView.answerCallback = function(isRight, settlement)
        self:AnswerCallback(isRight, settlement)
    end
end

function BrainMainView:SetBoardState(isInit)
    GameObjectHelper.FastSetActive(self.questionPage, true)
    GameObjectHelper.FastSetActive(self.ruleArea, isInit)
    GameObjectHelper.FastSetActive(self.operateArea, not isInit)
end

function BrainMainView:RefreshOperateView()
    self.operateView:InitView(self.brainModel:GetCurrentQuestionData(), self.brainModel.quesIndex)
end

function BrainMainView:OnBtnBack()
    GameObjectHelper.FastSetActive(self.resultArea, false)
    self.brainModel = nil
    if self.onBack then
        self.onBack()
    end
end

function BrainMainView:AnswerCallback(isRight, settlement)
    if isRight then
        self.rightCount = self.rightCount + 1
    end
    if self.brainModel.quesIndex < 10 then
        self.brainModel:SetCurrentQuestionIndex(self.brainModel.quesIndex + 1)
        self:RefreshOperateView()
    -- 最后一题带结算信息
    elseif settlement ~= nil then
        self.brainModel:InitBrainRankData(settlement)
        -- 显示结果,开启返回按钮
        EventSystem.SendEvent("Refresh_Brain_Time")
        GameObjectHelper.FastSetActive(self.btnBack.gameObject, true)
        GameObjectHelper.FastSetActive(self.resultArea, true)
        GameObjectHelper.FastSetActive(self.questionPage, false)
        if self.onInitRankView ~= nil then
            self.scrollView = self.resultView.scrollView
            self.onInitRankView(settlement)
            self.resultView:InitView(self.brainModel:GetRankInfo())
        end
    end
end

return BrainMainView
