local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.AssistCoachInfoBarCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local AssistCoachInformationModel = require("ui.models.coach.assistCoachInformation.AssistCoachInformationModel")
local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local AssistCoachFilterModel = require("ui.models.coach.assistCoachInformation.AssistCoachFilterModel")
local AssistCoachJoinEffectModel = require("ui.models.coach.assistCoachInformation.AssistCoachJoinEffectModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")

local AssistCoachInformationCtrl = class(BaseCtrl, "AssistCoachInformationCtrl")

AssistCoachInformationCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistCoachInformationBoard.prefab"

-- 玩法说明id
local INTRODUCE_ID = 10

function AssistCoachInformationCtrl:ctor()
    AssistCoachInformationCtrl.super.ctor(self)
end

function AssistCoachInformationCtrl:Init(tabTag, tabOrder)
    AssistCoachInformationCtrl.super.Init(self)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child)
    end)

    self.view.onClickTab = function(tag) self:OnClickTab(tag) end
    self.view.onItemBtnOperateClick = function(aciModel) self:OnItemBtnOperateClick(aciModel) end
    self.view.onItemBtnChooseClick = function(aciModel) self:OnItemBtnChooseClick(aciModel) end
    self.view.onItemBtnViewClick = function(aciModel) self:OnItemBtnViewClick(aciModel) end
    self.view.onBtnHelpClick = function() self:OnBtnHelpClick() end
    self.view.onBtnSellClick = function() self:OnBtnSellClick() end
    self.view.onBtnDecomposeClick = function() self:OnBtnDecomposeClick() end
    self.view.onBtnRecruitClick = function() self:OnBtnRecruitClick() end
    self.view.onBtnGachaClick = function() self:OnBtnGachaClick() end
    self.view.onGrooveItemCancel = function(aciModel) self:OnGrooveItemCancel(aciModel) end
    -- 筛选相关
    self.view.onFilterItemChoosed = function(id, filterType) self:OnFilterItemChoosed(id, filterType) end
end

function AssistCoachInformationCtrl:Refresh(tabTag, tabOrder)
    AssistCoachInformationCtrl.super.Refresh(self)
    if self.model == nil then
        self.model = AssistCoachInformationModel.new()
    end
    if tabTag then
        self.model:SetTabTag(tabTag)
    end
    if tabOrder then
        self.model:SetTabOrder(tabOrder)
    end

    self.model:Init()
    self.view:InitView(self.model)

    GuideManager.Show(self)
end

function AssistCoachInformationCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function AssistCoachInformationCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function AssistCoachInformationCtrl:OnExitScene()
    self.view:OnExitScene()
end

function AssistCoachInformationCtrl:OnClickTab(tag)
    if tag ~= self.model:GetTabTag() then
        self.model:SetTabOrder(true)
    else
        self.model:SetTabOrder(not self.model:GetTabOrder())
    end
    self.model:SetTabTag(tag)
    self.model:SortAciModelList()
    self.view:UpdateInfoScrollView()
end

-- 点击左侧列表中的操作
function AssistCoachInformationCtrl:OnItemBtnOperateClick(aciModel)
    if aciModel.grooveIdx ~= nil then
        local grooveIdx = aciModel.grooveIdx
        -- 移除情报
        self.model:RemoveGrooveItem(grooveIdx, aciModel)
    else
        -- 添加情报
        local availableIdx = self.model:GetAvailableGroove()
        if availableIdx ~= nil then
            local grooveState = self.model:GetGrooveState()
            for idx, v in pairs(grooveState) do
                if v ~= nil then
                    if v:GetId() == aciModel:GetId() then
                        DialogManager.ShowToastByLang("assistant_coach_info_duplicate") -- 您已添加过该类情报
                        return
                    end
                end
            end
            self.model:PutGrooveItem(availableIdx, aciModel)
        else
            DialogManager.ShowToast(lang.transstr("assistant_coach_info_full", self.model.MaxUsedItemNum)) -- 最多添加3个
            return
        end
    end
    self.model:SortAciModelList()
    self.view:GetScrollNormalizedPosition()
    self.view:UpdateInfoScrollView()
    self.view:coroutine(function()
        unity.waitForNextEndOfFrame()
        self.view:SetScrollNormalizedPosition()
    end)
    self.view:UpdateRightBoard()
end

-- 点选左侧列表中的某项
function AssistCoachInformationCtrl:OnItemBtnChooseClick(aciModel)
    self.model:UpdateItemChoosedState(aciModel)
    self.view:InitButtonState()
    self.view:UpdateInfoScrollViewItem(aciModel.idx, aciModel)
end

-- 查看情报详细描述
function AssistCoachInformationCtrl:OnItemBtnViewClick(aciModel)
    res.PushDialog("ui.controllers.coach.assistCoachInformation.AssistCoachInformationItemDetailCtrl", aciModel)
end

-- 玩法说明
function AssistCoachInformationCtrl:OnBtnHelpClick()
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(INTRODUCE_ID, "AssistantCoachInformationLibrary")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

-- 功能未开启
function AssistCoachInformationCtrl:ShowNotOpenTip()
    DialogManager.ShowToastByLang("functionNotOpen")
end

-- 出售情报
function AssistCoachInformationCtrl:OnBtnSellClick()
    if self.model:GetMarketOpenState() then
        local chooseState = self.model:GetChooseState()
        local chooseNum = table.nums(chooseState)
        if chooseNum <= 0 then
            DialogManager.ShowToastByLang("assistant_coach_info_item_3")
            return
        end
        -- 点击确定回调
        local confirmCallback = function()
            -- self.view:coroutine(function()
            -- end)
        end

        local title = lang.transstr("information") .. lang.transstr("sell") -- 情报出售
        local msg = lang.transstr("assistant_coach_info_sell", chooseNum) -- 是否出售所有选中的num个情报
        DialogManager.ShowConfirmPop(title, msg, confirmCallback)
    else
        self:ShowNotOpenTip()
    end
end

-- 分解
function AssistCoachInformationCtrl:OnBtnDecomposeClick()
    local chooseState = self.model:GetChooseState()
    local chooseNum = table.nums(chooseState)
    if chooseNum <= 0 then
        DialogManager.ShowToastByLang("assistant_coach_info_item_3")
        return
    end

    local aceReturnNum = 0
    for k, aciModel in pairs(chooseState) do
        aceReturnNum = aceReturnNum + tonumber(aciModel:GetAssistantInfoSplitAmount())
    end

    -- 点击确定回调
    local confirmCallback = function()
        self.view:coroutine(function()
            local items = self.model:GetDecomposeItems()
            local respone = req.assistantCoachInfoDecompose(items)
            if api.success(respone) then
                local data = respone.val
                if type(data) == "table" and next(data) then
                    self.model:UpdateAfterDecompose(data)
                    self.view:UpdateAfterDecompose()
                    CongratulationsPageCtrl.new(data.contents)
                end
            end
        end)
    end

    local title = lang.transstr("information") .. lang.transstr("decompose") -- 情报分解
    local msg = lang.transstr("assistant_coach_info_decompose", chooseNum, lang.transstr(CurrencyNameMap.ace), aceReturnNum) -- 是否分解所有选中的num个情报
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

-- 招募
function AssistCoachInformationCtrl:OnBtnRecruitClick()
    local items = self.model:GetComposeItems()
    if table.nums(items) <= 0 then
        DialogManager.ShowToastByLang("assistant_coach_info_compose")
        return
    end

    -- 点击确定回调
    local confirmCallback = function()
        self.view:coroutine(function()
            local respone = req.assistantCoachInfoCompose(items)
            if api.success(respone) then
                local data = respone.val
                if type(data) == "table" and next(data) then
                    local acModel = AssistantCoachModel.new()
                    acModel:InitWithProtocol(data.ac_info)
                    local assistCoachJoinEffectModel = AssistCoachJoinEffectModel.new()
                    assistCoachJoinEffectModel:SetCostItemIds(items)
                    assistCoachJoinEffectModel:InitWithProtocol(data)
                    res.PushDialog("ui.controllers.coach.assistCoachInformation.AssistCoachJoinEffectCtrl", assistCoachJoinEffectModel)
                    self.model:UpdateAfterRecruit(data)
                    self.view:UpdateAfterRecruit()
                end
            end
        end)
    end

    local title = lang.transstr("assistant_coach_info_hire") -- 助教招募
    local msg = lang.transstr("assistant_coach_info_recruit", table.nums(items)) -- 是否消耗情报书来招募助教？
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

-- 去往情报搜集界面
function AssistCoachInformationCtrl:OnBtnGachaClick()
    res.PushScene("ui.controllers.coach.assistCoachGacha.AssistCoachGachaCtrl")
end

-- 点击槽位中情报取消放置
function AssistCoachInformationCtrl:OnGrooveItemCancel(aciModel)
    local grooveIdx = aciModel.grooveIdx
    if grooveIdx ~= nil then
        -- 移除情报
        self.model:RemoveGrooveItem(grooveIdx, aciModel)
        self.model:SortAciModelList()
        self.view:GetScrollNormalizedPosition()
        self.view:UpdateInfoScrollView()
        self.view:coroutine(function()
            unity.waitForNextEndOfFrame()
            self.view:SetScrollNormalizedPosition()
        end)
        self.view:UpdateRightBoard()
    end
end

-- 筛选相关
function AssistCoachInformationCtrl:OnFilterItemChoosed(id, filterType)
    local fiQuality, fiType, fiRarity = self.model:GetCurrFilterState()
    local filterVar = AssistCoachFilterModel[filterType][id].filterVar
    -- 筛选
    if filterType == AssistCoachFilterModel.FilterType.Quality then
        fiQuality = filterVar
    elseif filterType == AssistCoachFilterModel.FilterType.Type then
        fiType = filterVar
    elseif filterType == AssistCoachFilterModel.FilterType.Rarity then
        fiRarity = filterVar
    end
    self.model:Filter(fiQuality, fiType, fiRarity)
    self.view:UpdateInfoScrollView()
end

return AssistCoachInformationCtrl
