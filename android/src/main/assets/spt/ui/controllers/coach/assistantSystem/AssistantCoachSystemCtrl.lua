local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.AssistCoachInfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local AssistantCoachSystemModel = require("ui.models.coach.assistantSystem.AssistantCoachSystemModel")
local AssistantCoachUpdateModel = require("ui.models.coach.assistantSystem.AssistantCoachUpdateModel")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local GetOpenStateByTag = CoachMainPageConfig.GetOpenStateByTag
local Tag = CoachMainPageConfig.Tag

local AssistantCoachSystemCtrl = class(BaseCtrl, "AssistantCoachSystemCtrl")

AssistantCoachSystemCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSystem.prefab"

function AssistantCoachSystemCtrl:AheadRequest(mainCoachData, currTeamIndex)
    if self.view then
        self.view:ShowDisplayArea(false)
    end
    local response = req.assistantCoachTeamInfo()
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = AssistantCoachSystemModel.new()
        end
        if type(data) == "table" then
            self.model:InitWithProtocol(data, mainCoachData)
            self.view:ShowDisplayArea(true)
        end
    end
end

function AssistantCoachSystemCtrl:ctor()
    AssistantCoachSystemCtrl.super.ctor(self)
end

function AssistantCoachSystemCtrl:Init(mainCoachData, currTeamIndex)
    AssistantCoachSystemCtrl.super.Init(self)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child)
    end)

    self.view.onMenuClick = function(index, data) self:OnMenuClick(index, data) end
    self.view.onBtnSwitchTeam = function() self:OnBtnSwitchTeam() end
    self.view.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
    self.view.onBtnHire = function() self:OnBtnHire() end
    self.view.onBtnSelect = function() self:OnBtnSelect() end

    if not self.model then
        self.model = AssistantCoachSystemModel.new()
    end
    self.view:InitView(self.model)
end

function AssistantCoachSystemCtrl:Refresh(mainCoachData, currTeamIndex)
    AssistantCoachSystemCtrl.super.Refresh(self)
    if not currTeamIndex then
        currTeamIndex = self.model:GetCurrTeamIndex()
    end
    self.model:SetCurrTeamIndex(currTeamIndex)
    self.view:RefreshView()
end

function AssistantCoachSystemCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function AssistantCoachSystemCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistantCoachSystemCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 切换书页
function AssistantCoachSystemCtrl:OnMenuClick(index, data)
    if data.isLocked then
        DialogManager.ShowToast(lang.transstr("assistant_coach_unlock_info", data.unlockInfo.coachName, data.idx)) -- 升级至XX的教练，开启第X助理教练
    else
        local oldTeamIdx = self.model:GetCurrTeamIndex()
        self.model:SetCurrTeamIndex(index)
        self.view:GoToTeamByIndex(index, false, math.abs(index - oldTeamIdx) <= 1)
    end
end

-- 更换团队
function AssistantCoachSystemCtrl:OnBtnSwitchTeam()
    if GetOpenStateByTag(Tag.AssistantCoachLibrary) then
        local choosedTeamIdx = self.model:GetCurrTeamIndex()
        local currAcModel = self.model:GetCurrAssistantCoachModel()
        local choosedAcid = nil
        if currAcModel then
            choosedAcid = currAcModel:GetId()
        end
        res.PushScene("ui.controllers.coach.assistantCoachLibrary.AssistantCoachLibraryCtrl", choosedTeamIdx, nil, nil, choosedAcid)
    else
        self:ShowNotOpenTip()
    end
end

-- 助理教练升级
function AssistantCoachSystemCtrl:OnBtnUpdateClick()
    local acModel = self.model:GetCurrAssistantCoachModel()
    local isMax = acModel:IsMax()
    local isCoachMax = acModel:IsCoachMax()
    if isCoachMax and isMax then
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level") -- 已满级
    elseif isCoachMax and not isMax then
        DialogManager.ShowToastByLang("coach_baseInfo_coach_max_hint") -- 请升级教练解锁更高等级
    elseif not isCoachMax and not isMax then
        local assistantCoachUpdateModel = AssistantCoachUpdateModel.new()
        assistantCoachUpdateModel:InitWithParent(acModel, self.model)
        res.PushDialog("ui.controllers.coach.assistantSystem.AssistantCoachUpdateCtrl", assistantCoachUpdateModel)
    else
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level")
    end
end

-- 雇用助理教练
function AssistantCoachSystemCtrl:OnBtnHire()
    if GetOpenStateByTag(Tag.AssistantCoachInfomationLibrary) then
        res.PushScene("ui.controllers.coach.assistCoachInformation.AssistCoachInformationCtrl")
    else
        self:ShowNotOpenTip()
    end
end

-- 助理教练上阵
function AssistantCoachSystemCtrl:OnBtnSelect()
    self:OnBtnSwitchTeam()
end

-- 功能未开启
function AssistantCoachSystemCtrl:ShowNotOpenTip()
    DialogManager.ShowToastByLang("functionNotOpen")
end

return AssistantCoachSystemCtrl
