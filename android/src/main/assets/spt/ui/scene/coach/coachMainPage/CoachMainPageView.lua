local DialogManager = require("ui.control.manager.DialogManager")
local CoachHelper = require("ui.scene.coach.common.CoachHelper")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local OpenState = CoachMainPageConfig.OpenState
local GetOpenStateByTag = CoachMainPageConfig.GetOpenStateByTag
local Tag = CoachMainPageConfig.Tag
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local CoachMainPageView = class(unity.base, "CoachMainPageView")

-- 教练头像prefab
local CoachPortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachPortrait.prefab"
-- 教练星级和等级的prefab
local CoachLevelPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachLevel.prefab"

function CoachMainPageView:ctor()
    -- 帮助
    self.introBtn = self.___ex.introBtn
    -- 返回
    self.backBtn = self.___ex.backBtn
    -- 中间的大图标
    self.coachPortraitTrans = self.___ex.coachPortraitTrans
    -- 上面的教练等级图标
    self.coachLevelTrans = self.___ex.coachLevelTrans
    -- 顶部信息条框
    self.infoBarBox = self.___ex.infoBarBox

    --主页上的按钮
    self.coachMissionSpt = self.___ex.coachMissionSpt
    self.marketSpt = self.___ex.marketSpt
    self.assistantCoachInfomationGachaSpt = self.___ex.assistantCoachInfomationGachaSpt  
    self.assistantCoachInfomationLibrarySpt = self.___ex.assistantCoachInfomationLibrarySpt
    self.assistantCoachLibrarySpt = self.___ex.assistantCoachLibrarySpt
    self.coachBaseInfoSpt = self.___ex.coachBaseInfoSpt
    self.coachNationSpt = self.___ex.coachNationSpt
    self.coachTalentSkillSpt = self.___ex.coachTalentSkillSpt
    self.coachGuideSpt = self.___ex.coachGuideSpt
    self.assistantCoachSystemSpt = self.___ex.assistantCoachSystemSpt
    self.coachBtns = {
        self.coachMissionSpt,
        self.marketSpt,
        self.assistantCoachInfomationGachaSpt,  
        self.assistantCoachInfomationLibrarySpt,
        self.assistantCoachLibrarySpt,
        self.coachBaseInfoSpt,
        self.coachNationSpt,
        self.coachTalentSkillSpt,
        self.coachGuideSpt,
        self.assistantCoachSystemSpt,
    }
end

function CoachMainPageView:start()
    self:RegBtnEvent()
end

function CoachMainPageView:RegOnDynamicLoad(func)
    self.infoBarBox:RegOnDynamicLoad(func)
end

function CoachMainPageView:RegBtnEvent()
    self.backBtn:regOnButtonClick(function()
        self:OnBackClick()
    end)

    -- 执教任务
    self.coachMissionSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.CoachMission) then
            res.PushScene("ui.controllers.coach.coachTask.CoachTaskCtrl")
        else
            self:ShowNotOpenTip()
        end
    end)

    -- 交易所
    self.marketSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.Market) then
            -- TODO
        else
            self:ShowNotOpenTip()
        end 
    end)
    
    -- 助教合约库
    self.assistantCoachInfomationGachaSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.AssistantCoachInfomationGacha) then
            res.PushScene("ui.controllers.coach.assistCoachGacha.AssistCoachGachaCtrl")
        else
            self:ShowNotOpenTip()
        end
    end)
    
    -- 助教情报库
    self.assistantCoachInfomationLibrarySpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.AssistantCoachInfomationLibrary) then
            res.PushScene("ui.controllers.coach.assistCoachInformation.AssistCoachInformationCtrl")
        else
            self:ShowNotOpenTip()
        end
    end)
    
    -- 教练经理人
    self.assistantCoachLibrarySpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.AssistantCoachLibrary) then
            res.PushScene("ui.controllers.coach.assistantCoachLibrary.AssistantCoachLibraryCtrl")
        else
            self:ShowNotOpenTip()
        end
    end)
    
    -- 基础信息
    self.coachBaseInfoSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.CoachBaseInfo) then
            res.PushScene("ui.controllers.coach.baseInfo.CoachBaseInfoCtrl", self.coachMainPageModel:GetBaseInfo())
        else
            self:ShowNotOpenTip()
        end
    end)
    
    -- 执教经历
    self.coachNationSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.CoachNation) then
            -- TODO
        else
            self:ShowNotOpenTip()
        end
    end)
    
    -- 执教特点
    self.coachTalentSkillSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.CoachTalentSkill) then
            res.PushScene("ui.controllers.coach.talent.CoachTalentCtrl", self.coachMainPageModel:GetTalentData(), self.coachMainPageModel)
        else
            self:ShowNotOpenTip()
        end
    end)
    
    -- 教练指导
    self.coachGuideSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.CoachGuide) then
            res.PushScene("ui.controllers.coach.coachGuide.CoachGuideCtrl")
        else
            self:ShowNotOpenTip()
        end
    end)
    
    -- 助教团队
    self.assistantCoachSystemSpt:regOnButtonClick(function()
        if GetOpenStateByTag(Tag.AssistantCoachSystem) then
            res.PushScene("ui.controllers.coach.assistantSystem.AssistantCoachSystemCtrl", self.coachMainPageModel:GetAssistantCoachData())
        else
            self:ShowNotOpenTip()
        end
    end)

    -- 帮助
    self.introBtn:regOnButtonClick(function()
        local config = CoachHelper.Explain.CaochMainPage
        local simpleIntroduceModel = SimpleIntroduceModel.new()
        simpleIntroduceModel:InitModel(config.id, config.descID)
        res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
    end)
end

function CoachMainPageView:ShowNotOpenTip()
    DialogManager.ShowToastByLang("functionNotOpen")
end

function CoachMainPageView:InitView(coachMainPageModel)
    self.coachMainPageModel = coachMainPageModel
    if not self.portraitSpt then
        local portraitObj, portraitSpt = res.Instantiate(CoachPortraitPath)
        self.portraitSpt = portraitSpt
        portraitObj.transform:SetParent(self.coachPortraitTrans, false)
    end

    -- 暂时不需要显示星级
    -- if not self.coachLevelSpt then
    --     local coachLevelObj, coachLevelSpt = res.Instantiate(CoachLevelPath)
    --     self.coachLevelSpt = coachLevelSpt
    --     coachLevelObj.transform:SetParent(self.coachLevelTrans, false)
    -- end

    self:RefreshCoachLevelAndStar()
    self:RefreshButtonState()
end

function CoachMainPageView:RefreshCoachLevelAndStar()
    local credentialLevel = self.coachMainPageModel:GetCredentialLevel()
    local starLevel = self.coachMainPageModel:GetStarLevel()
    self.portraitSpt:InitView(credentialLevel, starLevel, true)

    -- 暂时不需要显示星级
    -- self.coachLevelSpt:InitView(credentialLevel, starLevel)
end

function CoachMainPageView:RefreshButtonState()
    for i,v in ipairs(self.coachBtns) do
        v:SetButtonState()
    end
end

function CoachMainPageView:OnEnterScene()
end

function CoachMainPageView:OnExitScene()
end

function CoachMainPageView:OnBackClick()
    res.PopSceneImmediate()
end

return CoachMainPageView
