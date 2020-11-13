local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CoachTalentModel = require("ui.models.coach.talent.CoachTalentModel")
local CoachTalentUpdateModel = require("ui.models.coach.talent.CoachTalentUpdateModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local CoachTalentCtrl = class(BaseCtrl, "CoachTalentCtrl")

CoachTalentCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Talent/Prefabs/CoachTalent.prefab"

function CoachTalentCtrl:ctor(cacheData, coachMainPageModel)
    CoachTalentCtrl.super.ctor(self)
end

function CoachTalentCtrl:Init(cacheData, coachMainPageModel)
    CoachTalentCtrl.super.Init(self)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self, false, false)
    end)

    self.view.onTreeNodeClick = function(skillData) self:OnTreeNodeClick(skillData) end
    self.view.onBtnResetClick = function() self:OnBtnResetClick() end
end

function CoachTalentCtrl:Refresh(cacheData, coachMainPageModel)
    CoachTalentCtrl.super.Refresh(self)
    if not self.model then
        self.model = CoachTalentModel.new()
    end
    self.coachMainPageModel = coachMainPageModel
    self.model:SetResetTalentPointCost(coachMainPageModel:GetResetTalentPointCost())
    self.model:InitWithProtocol(cacheData)
    self.view:InitView(self.model)
    GuideManager.Show(self)
end

function CoachTalentCtrl:GetStatusData()
    return self.model:GetStatusData(), self.coachMainPageModel
end

function CoachTalentCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CoachTalentCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 点击一个技能
function CoachTalentCtrl:OnTreeNodeClick(skillData)
    local coachTalentUpdateModel = CoachTalentUpdateModel.new()
    coachTalentUpdateModel:InitWithParent(skillData, self.model)
    res.PushDialog("ui.controllers.coach.talent.CoachTalentUpdateCtrl", coachTalentUpdateModel)
end

-- 重置当前页面技能点
function CoachTalentCtrl:OnBtnResetClick()
    local usedPoint = self.model:GetSumUsedPoint()
    if usedPoint <= 0 then
        DialogManager.ShowToastByLang("coach_talent_no_used_point") -- 无天赋点可重置
        return
    end

    local confirmCallback = function()
        self.view:coroutine(function()
            local response = req.coachTalentReset()
            if api.success(response) then
                local data = response.val
                local talent = data.coach.talent
                local cost = data.cost -- 消耗
                local contents = data.contents -- 返还的教练天赋点
                self.model:UpdateAfterReset(talent, cost, contents)
                self.view:UpdateAfterReset()
                DialogManager.ShowToast(lang.transstr("reset") .. lang.transstr("match_success")) -- 重置成功
            else
                DialogManager.ShowToast(lang.transstr("reset") .. lang.transstr("match_lose")) -- 重置失败
            end
        end)
    end

    local title = lang.transstr("talent") .. lang.transstr("reset") -- 天赋解锁
    local msg = lang.transstr("coach_talent_reset_confirm", self.model:GetResetTalentPointCost())  -- 确认消耗500钻石重置所有技能点？
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

return CoachTalentCtrl

