local UnityEngine = clr.UnityEngine
local GameObject = UnityEngine.GameObject
local RectTransform = UnityEngine.RectTransform
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Vector2 = UnityEngine.Vector2

local TrainView = class(unity.base)

local DialogManager = require("ui.control.manager.DialogManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local SwitchLength = -300
local ButtonIndex = {
    Left = 0,
    Right = 1,
}

local function ShowCommonDialog()
    DialogManager.ShowAlertPopByLang("tips", "functionNotOpen", function() end)
end

function TrainView:ctor()
    TrainView.super.ctor(self)
    self.shoot = self.___ex.shoot
    self.steal = self.___ex.steal
    self.dribble = self.___ex.dribble
    self.save = self.___ex.save
    self.theory = self.___ex.theory
    self.remainingTimes = self.___ex.remainingTimes
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.menuBarDynParent = self.___ex.menuBarDynParent
    self.animator  = self.___ex.animator
    self.theoryObj = self.___ex.theoryObj
    self.leftSwitchBtn = self.___ex.leftSwitchBtn
    self.rightSwitchBtn = self.___ex.rightSwitchBtn
    self.contentTrans = self.___ex.contentTrans
    self.leftHideObj = self.___ex.leftHideObj
    self.rightHideObj = self.___ex.rightHideObj
    self.extraObj = self.___ex.extraObj
    self.extraInfo = self.___ex.extraInfo
    self.theoryDisable = self.___ex.theoryDisable
    self.btnRank = self.___ex.btnRank
    EventSystem.AddEvent("Refresh_Skill_Time", self, self.RefreshSkillTime)
    EventSystem.AddEvent("Refresh_Brain_Time", self, self.RefreshBrainTimes)
end

function TrainView:start()
    GuideManager.InitCurModule("training")
    GuideManager.Show()
    self.shoot:regOnButtonClick(function()
        if type(self.clickShoot) == "function" then
            self.clickShoot()
        end
    end)
    self.steal:regOnButtonClick(function()
        if type(self.clickDefend) == "function" then
            self.clickDefend()
        end
    end)
    self.dribble:regOnButtonClick(function()
        if type(self.clickDribble) == "function" then
            self.clickDribble()
        end
    end)
    self.save:regOnButtonClick(function()
        if type(self.clickSave) == "function" then
            self.clickSave()
        end
    end)
    self.theory:regOnButtonClick(function()
        if type(self.clickTheory) == "function" then
            self.clickTheory()
        end
    end)
    self.btnRank:regOnButtonClick(function()
        if type(self.clickRank) == "function" then
            self.clickRank()
        end
    end)    
    self.leftSwitchBtn:regOnButtonClick(function()
        self:OnSwitchButtonClick(ButtonIndex.Left)
    end)
    self.rightSwitchBtn:regOnButtonClick(function()
        self:OnSwitchButtonClick(ButtonIndex.Right)
    end)
    self:OnSwitchButtonClick(ButtonIndex.Left)
end

function TrainView:InitView(trainModel)
    assert(trainModel)
    self.trainModel = trainModel
    self.remainingTimes.text = tostring(trainModel:GetRemainingTimes())
    self:BuildPageView()
end


function TrainView:BuildPageView()
    local isOpenBrainTraining = self.trainModel:GetQuestionOpenState()
    GameObjectHelper.FastSetActive(self.theoryObj, isOpenBrainTraining)
    GameObjectHelper.FastSetActive(self.leftSwitchBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.rightSwitchBtn.gameObject, isOpenBrainTraining)
    GameObjectHelper.FastSetActive(self.rightHideObj, not isOpenBrainTraining)
    self.contentTrans.anchoredPosition = isOpenBrainTraining and Vector2(0, self.contentTrans.anchoredPosition.y) or Vector2(SwitchLength, self.contentTrans.anchoredPosition.y)
    if isOpenBrainTraining then
        GameObjectHelper.FastSetActive(self.theoryDisable, self.trainModel:GetQuestionRemainTimes() <= 0)
        self.extraInfo.text = lang.trans("brainTraining_extraTimes", self.trainModel:GetQuestionRemainTimes())
    end
end

function TrainView:OnSwitchButtonClick(buttonIndex)
    local isLeftSwitchClick = buttonIndex == ButtonIndex.Left
    GameObjectHelper.FastSetActive(self.leftSwitchBtn.gameObject, not isLeftSwitchClick)
    GameObjectHelper.FastSetActive(self.rightSwitchBtn.gameObject, isLeftSwitchClick)
    GameObjectHelper.FastSetActive(self.leftHideObj, isLeftSwitchClick)
    GameObjectHelper.FastSetActive(self.rightHideObj, not isLeftSwitchClick)
    self.contentTrans.anchoredPosition = buttonIndex == ButtonIndex.Left and Vector2(0, self.contentTrans.anchoredPosition.y) or Vector2(SwitchLength, self.contentTrans.anchoredPosition.y)
end

function TrainView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function TrainView:RegOnMenuBarDynamicLoad(func)
    self.menuBarDynParent:RegOnDynamicLoad(func)
end

function TrainView:RegOnLeave(func)
    self.onLeaveCallBack = func
end

function TrainView:OnLeave()
    if type(self.onLeaveCallBack) == "function" then
        self.onLeaveCallBack()
    end
end

function TrainView:RefreshSkillTime(skillTime)
    self.remainingTimes.text = tostring(skillTime)
    self.trainModel:SetRemaingTimes(skillTime)
end

function TrainView:RefreshBrainTimes()
    self.trainModel:SetQuestionUsedTimes()
    self.extraInfo.text = lang.trans("brainTraining_extraTimes", self.trainModel:GetQuestionRemainTimes())
    GameObjectHelper.FastSetActive(self.theoryDisable, self.trainModel:GetQuestionRemainTimes() <= 0)
end

function TrainView:PlayLeaveAnimation()
    self.animator:Play("TrainingContentLeaveAnimation")
end

function TrainView:onDestroy()
    EventSystem.RemoveEvent("Refresh_Skill_Time", self, self.RefreshSkillTime)
    EventSystem.RemoveEvent("Refresh_Brain_Time", self, self.RefreshBrainTimes)
end

return TrainView
