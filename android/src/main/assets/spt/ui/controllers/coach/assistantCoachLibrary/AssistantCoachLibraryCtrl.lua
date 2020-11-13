local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.AssistCoachInfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local AssistantCoachLibraryModel = require("ui.models.coach.assistantCoachLibrary.AssistantCoachLibraryModel")
local AssistantCoachUpdateModel = require("ui.models.coach.assistantSystem.AssistantCoachUpdateModel")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local AssistantCoachLibraryCtrl = class(BaseCtrl, "AssistantCoachLibraryCtrl")

AssistantCoachLibraryCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantCoachLibrary/AssistantCoachLibrary.prefab"

function AssistantCoachLibraryCtrl:AheadRequest()
    if self.view then
        self.view:ShowDisplayArea(false)
    end
    local response = req.assistantCoachList()
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = AssistantCoachLibraryModel.new()
        end
        if type(data) == "table" and next(data) then
            self.model:InitWithProtocol(data)
        end
        self.view:ShowDisplayArea(true)
    end
end

function AssistantCoachLibraryCtrl:ctor(choosedTeamIdx, tabTag, tabOrder, choosedAcid)
    AssistantCoachLibraryCtrl.super.ctor(self)

    self.needConfirmTeam = nil -- 是否需要弹板确定更换的助教团队
end

function AssistantCoachLibraryCtrl:Init(choosedTeamIdx, tabTag, tabOrder, choosedAcid)
    AssistantCoachLibraryCtrl.super.Init(self)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child)
    end)

    self.view.onClickTab = function(tag) self:OnClickTab(tag) end
    self.view.onBtnSellClick = function() self:OnBtnSellClick() end
    self.view.onBtnSwitchClick = function() self:OnBtnSwitchClick() end
    self.view.onBtnFireClick = function() self:OnBtnFireClick() end
    self.view.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
    self.view.onBtnRecruitClick = function() self:OnBtnRecruitClick() end
    -- 点击左侧助教列表中item
    self.view.onAssistantCoachLibraryItemClick = function(acModel) self:OnAssistantCoachLibraryItemClick(acModel) end
end

function AssistantCoachLibraryCtrl:Refresh(choosedTeamIdx, tabTag, tabOrder, choosedAcid)
    AssistantCoachLibraryCtrl.super.Refresh(self)
    if not self.model then
        self.model = AssistantCoachLibraryModel.new()
    end
    -- AssistantCoachSystem传下来需要更换的team的idx
    if choosedTeamIdx then
        self.needConfirmTeam = false
        self.model:SetChoosedTeamIdx(choosedTeamIdx)
        if self.model:GetAcidByTeamIdx(choosedTeamIdx) ~= nil then
            self.view:SetTxtSwitch(lang.trans("guildwar_change2")) -- 更换
        else
            self.view:SetTxtSwitch(lang.trans("guildwar_place")) -- 上阵
        end
    else
        self.needConfirmTeam = true
        self.view:SetTxtSwitch(lang.trans("guildwar_place")) -- 上阵
    end
    if tabTag then
        self.model:SetTabTag(tabTag)
    end
    if tabOrder then
        self.model:SetTabOrder(tabOrder)
    end
    if choosedAcid then
        self.model:SetChoosedAcid(choosedAcid)
    end
    self.model:SortAcModels()
    self.view:InitView(self.model)
end

function AssistantCoachLibraryCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function AssistantCoachLibraryCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistantCoachLibraryCtrl:OnExitScene()
    self.view:OnExitScene()
end

function AssistantCoachLibraryCtrl:OnClickTab(tag)
    if tag ~= self.model:GetTabTag() then
        self.model:SetTabOrder(true)
    else
        self.model:SetTabOrder(not self.model:GetTabOrder())
    end
    self.model:SetTabTag(tag)
    self.model:SortAcModels()
    self.view:UpdateCoachScrollView()
end

-- 点击列表中的助理教练
function AssistantCoachLibraryCtrl:OnAssistantCoachLibraryItemClick(acModel)
    local oldAcModel = self.model:GetCurrAcModel()
    local oldChoosedAcid = self.model:GetChoosedAcid()
    local oldIndex = oldAcModel.idx
    local newChoosedAcid = acModel:GetId()
    local newIndex = acModel.idx
    if tonumber(newChoosedAcid) ~= tonumber(oldChoosedAcid) then
        self.model:SetChoosedAcid(newChoosedAcid)
        self.view:UpdateCoachScrollViewItem(oldIndex, oldAcModel)
        self.view:UpdateCoachScrollViewItem(newIndex, acModel)
        self.view:InitRightBoard()
    end
end

-- 功能未开启
function AssistantCoachLibraryCtrl:ShowNotOpenTip()
    DialogManager.ShowToastByLang("functionNotOpen")
end

-- 助理教练已上阵
function AssistantCoachLibraryCtrl:ShowInTeamTip()
    DialogManager.ShowToastByLang("assistant_coach_library_inteam")
end

-- 出售
function AssistantCoachLibraryCtrl:OnBtnSellClick()
    if not self.model:GetMarketOpenState() then
        self:ShowNotOpenTip()
    else
        if not self.model:CheckCurrACInTeam() then
        else
            self:ShowInTeamTip()
        end
    end
end

-- 更换
function AssistantCoachLibraryCtrl:OnBtnSwitchClick()
    local teamIdx = self.model:GetChoosedTeamIdx()
    local oldAcid = self.model:GetAcidByTeamIdx(teamIdx)
    local currAcModel = self.model:GetCurrAcModel()
    local currAcid = currAcModel:GetId()
    local currAcname = currAcModel:GetName()
    -- 是否是同一个
    if oldAcid ~= nil then
        if tonumber(oldAcid) == tonumber(currAcid) then
            local tip = lang.transstr("assistant_coach_library_switch_tip_1", currAcname)
            DialogManager.ShowToast(tip)
            return
        end
    end
     -- 是否已经上阵
    if currAcModel:IsInTeam() then
        local tip = lang.transstr("assistant_coach_library_switch_tip_1", currAcname)
        DialogManager.ShowToast(tip)
        return
    end
    if self.needConfirmTeam and teamIdx == nil then
        -- 选择团队编号
        res.PushDialog("ui.controllers.coach.assistantCoachLibrary.AssistantCoachLibraryTeamCtrl", self.model)
    else
        -- 点击确定回调
        local confirmCallback = function()
            self.view:coroutine(function()
                local response = req.assistantCoachChangeTeam(teamIdx, currAcid)
                if api.success(response) then
                    local data = response.val
                    self.model:UpdateAfterSwitch(data)
                    self.view:UpdateAfterSwitch()
                    -- 更换成功
                    DialogManager.ShowToast(lang.transstr("guildwar_change2") .. lang.transstr("match_success"))
                end
                if self.needConfirmTeam then
                    self.model:SetChoosedTeamIdx(nil)
                else
                    res.PopScene()
                end
            end)
        end
        -- 点击取消回调
        local cancelCallback = function()
            if self.needConfirmTeam then
                self.model:SetChoosedTeamIdx(nil)
            end
        end

        local title = lang.transstr("coach_team") .. lang.transstr("guildwar_change2") -- 助理教练更换
        -- 确定将团队X的助理教练[name]更换成[name]
        local msg = lang.transstr("assistant_coach_library_switch_tip", teamIdx, oldAcid ~= nil and self.model:GetAcnameByTeamIdx(teamIdx) or "", currAcname)
        DialogManager.ShowConfirmPop(title, msg, confirmCallback, cancelCallback)
    end
end

-- 解雇
function AssistantCoachLibraryCtrl:OnBtnFireClick()
    if not self.model:CheckCurrACInTeam() then
        local currAcModel = self.model:GetCurrAcModel()
        local acid = currAcModel:GetId()
        -- 点击确定回调
        local confirmCallback = function()
            self.view:coroutine(function()
                local response = req.assistantCoachDecompose(acid)
                if api.success(response) then
                    local data = response.val
                    self.model:UpdateAfterFire(data)
                    self.view:UpdateAfterFire()
                    CongratulationsPageCtrl.new(data.contents)
                end
            end)
        end

        local title = lang.transstr("coach_team") .. lang.transstr("fire") -- 助理教练解雇
        -- 确定解雇助理教练[名字]并获得[数量]的ace
        local msg = lang.transstr("assistant_coach_library_fire_tip", currAcModel:GetName(), lang.transstr(CurrencyNameMap.ace), tostring(currAcModel:GetSplitReturnNum()))
        DialogManager.ShowConfirmPop(title, msg, confirmCallback)
    else
        self:ShowInTeamTip()
    end
end

-- 升级
function AssistantCoachLibraryCtrl:OnBtnUpdateClick()
    local acModel = self.model:GetCurrAcModel()
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

-- 去情报界面
function AssistantCoachLibraryCtrl:OnBtnRecruitClick()
    res.PushScene("ui.controllers.coach.assistCoachInformation.AssistCoachInformationCtrl")
end

return AssistantCoachLibraryCtrl
