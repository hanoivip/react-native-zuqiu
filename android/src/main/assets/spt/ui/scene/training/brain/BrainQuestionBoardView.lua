local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local BrainQuestionBoardView = class(unity.base)

local ChooseTime = 10
local TimeState = {
    [10] = "green",
    [5] = "orange",
    [3] = "red",
}

function BrainQuestionBoardView:ctor()
    self.question = self.___ex.question
    self.btnGroup = self.___ex.btn
    self.cutDownGroupTrans = self.___ex.cutDownGroup
    self.time = self.___ex.time
    self.remainTime = 0
    self.timeBarList = {}
    self.btn = {}
    self.isChosen = false
end

function BrainQuestionBoardView:InitView(data, index)
    if self.timer then
        self:StopCoroutine(self.timer)
        self.timer = nil
    end
    for k, v in pairs(self.btnGroup) do
        self.btn[v.answerIndex + 1] = v
    end
    self:RefreshBoardView(data, index)
    self:InitCutDownGroup(index)
end

function BrainQuestionBoardView:InitCutDownGroup(index)
    if #self.timeBarList <= 0 then
        if index == 1 then
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/Training/Brain/TimeBar.prefab"
            for i = 1, ChooseTime do
                local obj, spt = res.Instantiate(prefab)
                obj.transform:SetParent(self.cutDownGroupTrans, false)
                table.insert(self.timeBarList, spt)
            end
        end
    end
    self:RefreshTime()
end

function BrainQuestionBoardView:RefreshBoardView(data, index)
    self.quesData = data
    self.curIndex = index - 1 -- 服务器从0开始
    self.remainTime = ChooseTime
    self.isChosen = false
    self:InitButtonList(data)
    self:StartWaitForAnswer()
end

function BrainQuestionBoardView:StartWaitForAnswer()
    if self.timer then
        self:StopCoroutine(self.timer)
        self.timer = nil
    end
    self.timer = self:coroutine(function()
        coroutine.yield(WaitForSeconds(1))
        self.remainTime = self.remainTime - 1
        self:RefreshTime()
        if self.remainTime > 0 then
            if not isChosen then
                self:StartWaitForAnswer()
            end
        else
            self:OnAnswerQuestion() -- 未选择判为错
        end
    end)
end

function BrainQuestionBoardView:InitButtonList(data)
    self.startTime = Time.unscaledTime
    self.question.text = lang.trans("brain_questionDesc", tostring(self.curIndex + 1), data.desc)
    for i = 1, #data.option do
        self:SetBtnView(self.btn[i], data.option[i])
    end
end

function BrainQuestionBoardView:SetBtnView(btn, text)
    btn:InitButton()
    btn:regOnButtonClick(function()
        self:OnAnswerQuestion(btn)
    end)
    for k, v in pairs(btn.text) do
        v.text = text
    end
end

function BrainQuestionBoardView:OnAnswerQuestion(btn)
    if self.isChosen then
        return
    end
    if self.timer then
        self:StopCoroutine(self.timer)
        self.timer = nil
    end
    clr.coroutine(function()
        local curUseTime = tonumber(string.format("%.2f", Time.unscaledTime - self.startTime))
        local chooseIndex = btn ~= nil and btn.answerIndex or 5
        local response = req.littleGameAnswer(self.curIndex, chooseIndex, curUseTime)
        if api.success(response) then
            local data = response.val
            if data.settlement ~= nil then
                self.settlement = data.settlement
            end
            --断网，当作未选择答案处理
            if (not data.isCorrect) and chooseIndex == data.answer then
                btn = nil
            end  
            self.rightIndex = data.answer
            if btn ~= nil then
                btn:SetButtonChosenView(data.isCorrect)
            end
            self:OnButtonChosen(data.isCorrect)
        end
    end)
end

function BrainQuestionBoardView:OnButtonChosen(isRightAnswer)
    self.isChosen = true
    if not isRightAnswer then
        self:ShowRightAnswer()
    end
    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(1))
        if self.answerCallback then
            self.answerCallback(isRightAnswer, self.settlement)
        end
    end)
end

function BrainQuestionBoardView:ShowRightAnswer()
    for k, v in pairs(self.btn) do
        if v.answerIndex == self.rightIndex then
            v:SetButtonCorrectView()
        end
    end
end

function BrainQuestionBoardView:RefreshTime()
    if self.remainTime == ChooseTime then
        for i = 1, self.remainTime do
            GameObjectHelper.FastSetActive(self.timeBarList[i].gameObject, true)
        end
    else
        if self.remainTime > 0 then
            GameObjectHelper.FastSetActive(self.timeBarList[self.remainTime].gameObject, false)
        else
            GameObjectHelper.FastSetActive(self.timeBarList[ChooseTime].gameObject, false)
        end
    end
    self.time.text = lang.trans("time_second", self.remainTime)
    self:RefreshTimeBarListState(self.remainTime)
end

function BrainQuestionBoardView:RefreshTimeBarListState(remainTime)
    local stateColor = ""
    for k, v in pairs(TimeState) do
        if remainTime == tonumber(k) then
            stateColor = v
        end
    end
    if stateColor ~= "" then
        for i = 1, ChooseTime do
            self.timeBarList[i]:SetTimerView(stateColor)
        end
    end
end

return BrainQuestionBoardView
