local UnityEngine = clr.UnityEngine
local Text = UnityEngine.UI.Text
local Button = UnityEngine.UI.Button

local TrainingUnlock = require("data.TrainingUnlock")
local CardTrainingConditionView = class(unity.base)

function CardTrainingConditionView:ctor()
    self.confirmBtn = self.___ex.confirmBtn
    self.toggleList = self.___ex.toggleList
    self.tipTxt = self.___ex.tipTxt
end

function CardTrainingConditionView:start()
    self.confirmBtn:regOnButtonClick(function ()
        if self.confirmBtnClick then
            self.confirmBtnClick()
        end
    end)
end

function CardTrainingConditionView:InitView(cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel or self.cardTrainingMainModel
    self.tipTxt.text = lang.trans("card_training_letter", self.cardTrainingMainModel:GetName())
    local tag = self.cardTrainingMainModel:GetCurrLevelSelected()
    local lockInfo = self.cardTrainingMainModel:GetConditionInfoByTag(tag)
    local correlationName1, correlationName2 = self.cardTrainingMainModel:GetLockPageCorrelationName()

    local isFinish = true

    local index = 1
    for k, v in pairs(lockInfo) do
        
        -- 是否完成，用于按钮的可否点击
        if not v then isFinish = false end
        self.toggleList[tostring(index)].gameObject:SetActive(true)
        if k == "correlationCondition" then
            local c1Text = ""
            local c2Text = ""

            if v.correlationCard1Condition == -1 then
                c1Text = lang.transstr("playerMail_noHave")
            end
            if v.correlationCard1Condition == -2 then
                c1Text = lang.transstr("unfinished")
            end
            if v.correlationCard1Condition == true then
                c1Text = lang.transstr("finished_cumulative_login")
            end
            if v.correlationCard2Condition == -1 then
                c2Text = lang.transstr("playerMail_noHave")
            end
            if v.correlationCard2Condition == -2 then
                c2Text = lang.transstr("unfinished")
            end
            if v.correlationCard2Condition == true then
                c2Text = lang.transstr("finished_cumulative_login")
            end
            if v.correlationCondition == true then
                c1Text = lang.transstr("finished_cumulative_login")
                c2Text = lang.transstr("finished_cumulative_login")
            end
            if v.correlationCondition == true or (v.correlationCard1Condition == true and v.correlationCard2Condition == true) then
                v = true
                isFinish = true
            else
                v = false
                isFinish = false
            end
            correlationName1 = correlationName1 .. "(" .. c1Text .. ")"
            correlationName2 = correlationName2 .. "(" .. c2Text .. ")"
            self.toggleList[tostring(index)]:GetComponentInChildren(Text).text = string.format(TrainingUnlock[tostring(tag)][k .. "Text"], correlationName1, correlationName2)
        else
            self.toggleList[tostring(index)]:GetComponentInChildren(Text).text = TrainingUnlock[tostring(tag)][k .. "Text"]
        end
        self.toggleList[tostring(index)].isOn = v
        index = index + 1
    end

    if index <= 4 then
        for i = 4, index, -1 do
            self.toggleList[tostring(i)].gameObject:SetActive(false)
        end
    end

    self.confirmBtn:onPointEventHandle(isFinish)
    self.confirmBtn.gameObject:GetComponent(Button).interactable = isFinish
end

return CardTrainingConditionView