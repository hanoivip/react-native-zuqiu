local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local CoachBaseInfoSuccessView = class(unity.base, "CoachBaseInfoSuccessView")

-- 教练头像prefab
local CoachPortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachPortrait.prefab"

function CoachBaseInfoSuccessView:ctor()
    self.rctPortrait = self.___ex.rctPortrait
    self.btnConfirm = self.___ex.btnConfirm
    self.txtDesc = self.___ex.txtDesc
end

function CoachBaseInfoSuccessView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachBaseInfoSuccessView:InitView(coachBaseInfoModel)
    self.model = coachBaseInfoModel
    -- 教练头像
    local portraitObj, portraitSpt = res.Instantiate(CoachPortraitPath)
    if portraitObj ~= nil and portraitSpt ~= nil then
        portraitObj.transform:SetParent(self.rctPortrait.transform, false)
        portraitObj.transform.localScale = Vector3.one
        portraitObj.transform.localPosition = Vector3.zero
        portraitSpt:InitView(self.model:GetCredentialLevel(), self.model:GetStarLevel(), true)
    end
    local descs = self.model:GetCoachUpgradeDesc()
    self.txtDesc.text = descs
end

function CoachBaseInfoSuccessView:RegBtnEvent()
    self.btnConfirm:regOnButtonClick(function()
        self:Close()
    end)
end

function CoachBaseInfoSuccessView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            -- 新手引导
            self:CheckGuide()
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function CoachBaseInfoSuccessView:CheckGuide()
    local coachLevel = tonumber(self.model:GetCurrCoachLvl())
    local tallentOpenState = CoachMainPageConfig.GetOpenStateByTag(CoachMainPageConfig.Tag.CoachTalentSkill)
    if tallentOpenState then
        GuideManager.InitCurModule("coachtalent")
        GuideManager.Show(self)
    end
    local coachGuideOpenState = CoachMainPageConfig.GetOpenStateByTag(CoachMainPageConfig.Tag.CoachGuide)
    if coachGuideOpenState then
        GuideManager.InitCurModule("coachguide1")
        GuideManager.Show(self)
    end
    local gachaOpenState = CoachMainPageConfig.GetOpenStateByTag(CoachMainPageConfig.Tag.AssistantCoachInfomationGacha)
    if gachaOpenState then
        GuideManager.InitCurModule("assistantcoach1")
        GuideManager.Show(self)
    end
end

return CoachBaseInfoSuccessView
