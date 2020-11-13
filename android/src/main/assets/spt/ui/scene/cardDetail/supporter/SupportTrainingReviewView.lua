local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TrainingUnlock = require("data.TrainingUnlock")
local SupportTrainingReviewView = class(unity.base, "SupportTrainingReviewView")

function SupportTrainingReviewView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.scrollSpt = self.___ex.scrollSpt
    self.bgImg = self.___ex.bgImg
    self.titleTxt = self.___ex.titleTxt
    self.progressTxt = self.___ex.progressTxt
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
end

function SupportTrainingReviewView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function SupportTrainingReviewView:InitView(trainingData, maxTrainingId)
    local reviewData = self:GetTrainingReviewData(trainingData, maxTrainingId)
    self.scrollSpt:InitView(reviewData)
end

function SupportTrainingReviewView:GetTrainingReviewData(trainingData, maxTrainingId)
    local reviewData = {}
    local maxChapter = tonumber(maxTrainingId.chapter)
    for i, v in pairs(TrainingUnlock) do
        local chapter = tonumber(i)
        local isOpen = trainingData[i].open and chapter <= maxChapter
        local subId = tonumber(trainingData[i].subId) - 1
        subId = math.clamp(subId, 0, 5)
        local t = {}
        t.chapter = chapter
        t.isOpen = isOpen
        t.subId = subId
        t.chapterName = v.name
        table.insert(reviewData, t)
    end
    table.sort(reviewData, function(a, b)
        return a.chapter < b.chapter
    end)
    return reviewData
end

function SupportTrainingReviewView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
            self.closeDialog()
        end)
    end
end

return SupportTrainingReviewView
