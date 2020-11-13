local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local MedalListModel = require("ui.models.medal.MedalListModel")
local MedalListFilterModel = require("ui.models.medal.MedalListFilterModel")
local MedalListSkillSearchModel = require('ui.models.medal.MedalListSkillSearchModel')
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local MedalListCtrl = class(BaseCtrl, "MedalListCtrl")

MedalListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalListCanvas.prefab"

function MedalListCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
    end)
    self.view.clickSplit = function(medalModel) self:OnClickSplit(medalModel) end
    self.view.clickStrengthin = function(medalModel) self:OnClickStrengthin(medalModel) end
    self.view.clickStrengthin = function(medalModel) self:OnClickStrengthin(medalModel) end
    self.view.clickMenu = function() self:ClickMenu() end
    self.view.clickAutoSplit = function() self:ClickAutoSplit() end
    self.view.clickSearch = function() self:ClickSearch() end
    self.view.clickHelp = function() self:ClickHelp() end
    self.view.onClickMedalItem = function(medalModel) self:OnClickMedalItem(medalModel) end
    local medalNum = tonumber(ReqEventModel.GetInfo("medal"))
    if medalNum > 0 then 
        -- Mark 勋章取消红点,等接口
        clr.coroutine(function() dump("cancel redPoint") end)
    end
    -- 新筛选相关
    self.view.onFilterItemChoosed = function(id, filterType) self:OnFilterItemChoosed(id, filterType) end
    if not self.playerMedalsMapModel then
        self.playerMedalsMapModel = PlayerMedalsMapModel.new()
    end
end

function MedalListCtrl:Refresh()
    MedalListCtrl.super.Refresh(self)
    self.medalListModel = MedalListModel.new()
    self.medalListSkillSearchModel = MedalListSkillSearchModel.new()
    self.medalListSkillSearchModel:InitSkillDatas()
    self.view:InitView(self.medalListModel)
end

function MedalListCtrl:ClickMenu()
    res.PushDialog("ui.controllers.medal.MedalMenuCtrl")
end

function MedalListCtrl:ClickAutoSplit()
    local selectModels = self.medalListModel:GetCurrList()
    -- 列表无勋章
    if table.nums(selectModels) <= 0 then
        DialogManager.ShowToastByLang("medal_new_autosplit_none")
        return
    end
    local hasSsMedalSplit = false
    local ssQualityValue = self.medalListModel:GetSsQualityValue()
    local pmids = {}
    for i, model in pairs(selectModels) do
        local pmid = model:GetPmid()
        if not model:HasEquiped() then
            local medalQulity = model:GetQuality()
            if tonumber(medalQulity) >= tonumber(ssQualityValue) then
                hasSsMedalSplit = true
            end
            table.insert(pmids, pmid)
        end
    end
    -- 均已装备
    if table.nums(pmids) <= 0 then
        DialogManager.ShowToastByLang("medal_new_autosplit_allequiped")
        return
    end
    local confirmCallback = function()
        clr.coroutine(function()
            local respone = req.decompositionAll(pmids)
            if api.success(respone) then
                local data = respone.val
                CongratulationsPageCtrl.new(data.contents)
                if data.cost and next(data.cost) then
                    self.playerMedalsMapModel:RemoveMedalsData(data.cost.pmid)
                end
            end
        end)
    end

    local title = lang.transstr("split_auto")
    local confirmContent = lang.transstr("medal_new_autosplit_tip")
    local confirmContentForSs = lang.transstr("medalSplit_ssTip")
    local noticeConfirmCallback = function()
        if hasSsMedalSplit then
            DialogManager.ShowConfirmPop(title, confirmContentForSs, confirmCallback)
        else
            confirmCallback()
        end
    end
    DialogManager.ShowConfirmPop(title, confirmContent, noticeConfirmCallback)
end

function MedalListCtrl:ClickSearch()
    res.PushDialog("ui.controllers.medal.MedalSearchCtrl", self.medalListModel, self.medalListSkillSearchModel)
end

function MedalListCtrl:ClickHelp()
    res.PushScene("ui.controllers.medal.MedalRuleCtrl")
end

function MedalListCtrl:OnClickSplit(medalModel)
    if medalModel:HasEquiped() then
        return
    end
    local callback = function()
        clr.coroutine(function()
            local pmid = medalModel:GetPmid()
            local respone = req.medalDecomposition(pmid)
            if api.success(respone) then
                local data = respone.val
                CongratulationsPageCtrl.new(data.contents)
                if data.cost and next(data.cost) then 
                    self.playerMedalsMapModel:RemoveMedalData(data.cost.pmid)
                end
            end
        end)
    end
    local tipTitle = lang.trans("split_medal")
    local tipContent = lang.trans("split_medal_content")
    self:OnMessageBox(tipTitle, tipContent, callback) 
end

function MedalListCtrl:OnMessageBox(titleText, contentText, callback) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = lang.trans("cancel")
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = function()
        callback()
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', 'overlay', true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

function MedalListCtrl:OnClickStrengthin(medalModel)
    local showflag = medalModel:GetState(1) or medalModel:GetState(2) or medalModel:GetState(3)
    if showflag then
        res.PushDialog("ui.controllers.medal.MedalStrengthinPageCtrl", medalModel)
    else
        DialogManager.ShowAlertAlignmentPop(lang.trans("instruction"), lang.trans("medal_upgrade_fail_tip"), 3)
    end
end

function MedalListCtrl:OnClickMedalItem(medalModel)
    if medalModel:IsNew() then
        self.playerMedalsMapModel:SetMedalNew(medalModel:GetPmid(), false)
    end
end

function MedalListCtrl:OnEnterScene()
    self.view:EnterScene()
end

function MedalListCtrl:OnExitScene()
    self.view:ExitScene()
    -- 退出勋章界面时取消所有new标记
    self.medalListModel:CancelAllNewMedal()
end

-- 新筛选相关
function MedalListCtrl:OnFilterItemChoosed(id, filterType)
    local selectAttr, selectSkill, selectEquip, selectState, selectQuality, selectShape = self.medalListModel:GetCurrSearchState()
    -- 筛选
    if filterType == MedalListFilterModel.FilterType.Equip then
        selectEquip = MedalListFilterModel[filterType][id].filterVar
    elseif filterType == MedalListFilterModel.FilterType.State then
        selectState = MedalListFilterModel[filterType][id].filterVar
    elseif filterType == MedalListFilterModel.FilterType.Quality then
        selectQuality = MedalListFilterModel[filterType][id].filterVar
    elseif filterType == MedalListFilterModel.FilterType.Shape then
        selectShape = MedalListFilterModel[filterType][id].filterVar
    end

    self.medalListModel:Filter(selectEquip, selectState, selectQuality, selectShape)
end

return MedalListCtrl
