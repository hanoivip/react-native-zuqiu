local QuestInfoModel = require("ui.models.quest.QuestInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")

local QuestConditionItemView = class(unity.base)

function QuestConditionItemView:ctor()
    -- 标题
    self.title = self.___ex.title
    -- 完成标志
    self.doneIcon = self.___ex.doneIcon
    -- 内容框按钮
    self.contentBtn = self.___ex.contentBtn
    -- 条件数据
    self.conditionData = nil
    -- 主线副本数据模型
    self.questInfoModel = nil
end

function QuestConditionItemView:InitView(conditionData)
    self.conditionData = conditionData
    self.questInfoModel = QuestInfoModel.new()
    
    self:BuildPage()
end

function QuestConditionItemView:start()
    self:BindAll()
end

function QuestConditionItemView:BindAll()
    self.contentBtn:regOnButtonClick(function ()
        if not self.conditionData.isFinished then
            -- 如果是章节
            if self.conditionData.isChapter then
                if self.questInfoModel:CheckChapterOpenedById(self.conditionData.id) then
                    EventSystem.SendEvent("PlayerLetterDetail.Destroy")
                    EventSystem.SendEvent("PlayerLetter.Destroy")
                    EventSystem.SendEvent("QuestPageView.GoToChapter", self.conditionData.id)
                else
                    DialogManager.ShowToastByLang("quest_chapterNoCleared")
                end
            -- 如果是关卡
            else
                if self.questInfoModel:CheckStageOpenedById(self.conditionData.id) then
                    EventSystem.SendEvent("PlayerLetterDetail.Destroy")
                    EventSystem.SendEvent("PlayerLetter.Destroy")
                    EventSystem.SendEvent("QuestPageView.GoToStage", self.conditionData.id)
                else
                    DialogManager.ShowToastByLang("quest_stageNotOpened")
                end
            end
        end
    end)
end

function QuestConditionItemView:BuildPage()
    -- 如果是章节
    if self.conditionData.isChapter then
        local chapterIndex = tonumber(string.sub(self.conditionData.id, 2))
        local chapterTitle = lang.transstr("quest_chapterIndex", chapterIndex) .. self.conditionData.staticData.title
        self.title.text = lang.trans("playerMail_clear", chapterTitle)
    -- 如果是关卡
    else
        self.title.text = lang.trans("playerMail_clear", self.conditionData.staticData.questNumber .. " " .. self.conditionData.staticData.questName)
    end

    -- 如果条件已完成
    if self.conditionData.isFinished then
        self.doneIcon:SetActive(true)
    else
        self.doneIcon:SetActive(false)
    end
end

return QuestConditionItemView
