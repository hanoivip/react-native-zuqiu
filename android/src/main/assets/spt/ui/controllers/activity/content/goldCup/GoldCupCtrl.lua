local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local ActivityRes = require("ui.scene.activity.ActivityRes")
local GoldCupCtrl = class(ActivityContentBaseCtrl)

function GoldCupCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.clickContributeRecord = function() self:OnContributeRecord() end
    self.view.clickRuleBtn = function() self:OnRuleBtn() end

    self.view:InitView(self.activityModel)
end

function GoldCupCtrl:OnRefresh()
    self:RefreshPage()
end

function GoldCupCtrl:OnRuleBtn()
    local actType = self.activityModel:GetActivityType() or "TimeLimitGoldCup"
    local actIntroduceID = 8
    local introduceModel = SimpleIntroduceModel.new()
    introduceModel:InitModel(actIntroduceID, actType)
    introduceModel:SetBoardSize(700, 400)
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", introduceModel)
end

function GoldCupCtrl:OnContributeRecord()
    res.PushDialog("ui.controllers.activity.content.goldCup.ContributeRecordCtrl", self.activityModel)
end

function GoldCupCtrl:RefreshPage()
    self:InitGoldCupView()
    local actType = self.activityModel:GetActivityType() or "TimeLimitGoldCup"
    self.view:coroutine(function()
        local response = req.careerRaceInfo(actType, nil, nil, true)
        if api.success(response) then
            local data = response.val
            if type(data) == "table" and next(data) then
                local actID = tostring(self.activityModel:GetActivityId())
                assert(type(data[actID]) == "table" and next(data[actID]), "data error!!!")
                self.activityModel:RefreshData(data[actID])
                local effectMaskPosition = self.activityModel:GetEffectMaskPosition()
                self.activityModel:SetLastEffetMaskPosition(effectMaskPosition)
                self.view:InitView(self.activityModel)
            end
        end
    end)
end

function GoldCupCtrl:InitGoldCupView()
    local effectMaskPosition = self.activityModel:GetEffectMaskPosition()
    self.view.cupMaskAnimator:Play("SilverCupMaskAnimation", 0, effectMaskPosition)  --Lua assist checked flag
    self.view:ShowOrHideParticleEffect(self.activityModel)
end

function GoldCupCtrl:OnEnterScene()
end

function GoldCupCtrl:OnExitScene()
end

return GoldCupCtrl
