local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Mathf = UnityEngine.Mathf
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachLibraryView = class(unity.base, "AssistantCoachLibraryView")

-- 助理教练教练头像prefab
local PortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/AssistantCoachPortrait.prefab"

-- 进度条最大宽度
local PROGRESS_MAX_WIDTH = 195

function AssistantCoachLibraryView:ctor()
    -- 资源框
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 中间面板
    self.mainView = self.___ex.mainView
    -- 页签
    self.tabs = self.___ex.tabs
    -- 助理教练列表
    self.coachScrollView = self.___ex.coachScrollView
    -- 头像
    self.rctPortrait = self.___ex.rctPortrait
    -- 教练团队属性
    self.txtAttr = self.___ex.txtAttr
    -- 助教属性成长
    self.sptGrowthes = self.___ex.sptGrowthes
    -- 当前属性加成
    self.sptAttrs = self.___ex.sptAttrs
    -- 技能滑动
    self.skillScrollView = self.___ex.skillScrollView
    self.btnSkillLeft = self.___ex.btnSkillLeft
    self.btnSkillRight = self.___ex.btnSkillRight
    -- 出售按钮
    self.btnSell = self.___ex.btnSell
    self.buttonSell = self.___ex.buttonSell
    -- 更换按钮
    self.btnSwitch = self.___ex.btnSwitch
    self.txtSwitch = self.___ex.txtSwitch
    -- 解雇按钮
    self.btnFire = self.___ex.btnFire
    self.buttonFire = self.___ex.buttonFire
    -- 升级按钮
    self.btnUpdate = self.___ex.btnUpdate
    self.buttonUpdate = self.___ex.buttonUpdate
    -- 右侧面板选中相关
    self.objRightBoard = self.___ex.objRightBoard
    self.txtNotChoosed = self.___ex.txtNotChoosed
    -- 去情报库界面
    self.btnRecruit = self.___ex.btnRecruit

    -- 教练头像控制脚本
    self.portraitSpt = nil
end

function AssistantCoachLibraryView:start()
    self:RegBtnEvent()
end

function AssistantCoachLibraryView:InitView(assistantCoachLibraryModel)
    self.model = assistantCoachLibraryModel

    self:InitTabsView()
    self:BuildView()
end

-- 页签初始化
function AssistantCoachLibraryView:InitTabsView()
    self.tabs:BindMenuItem(self.model.TabTags.star, function()
        self:OnClickTab(self.model.TabTags.star)
    end)
    self.tabs:BindMenuItem(self.model.TabTags.date, function()
        self:OnClickTab(self.model.TabTags.date)
    end)
    self.tabs:BindMenuItem(self.model.TabTags.level, function()
        self:OnClickTab(self.model.TabTags.level)
    end)
    self.tabs:InitView(self.model)
end

function AssistantCoachLibraryView:BuildView()
    -- 初始化助理教练列表
    self.coachScrollView:RegOnItemButtonClick("btnClick", function(acModel)
        self:OnAssistantCoachLibraryItemClick(acModel)
    end)
    self:UpdateCoachScrollView()
    -- 初始化右侧面板教练信息
    self:InitRightBoard()
end

function AssistantCoachLibraryView:UpdateCoachScrollView()
    self.coachScrollView:InitView(self.model:GetAssistantCoachModels(), self.model)
end

function AssistantCoachLibraryView:UpdateCoachScrollViewItem(index, itemModel)
    self.coachScrollView:UpdateItem(index, itemModel)
end

function AssistantCoachLibraryView:InitRightBoard()
    local acModel = self.model:GetCurrAcModel()
    if acModel == nil then
        self:DisplayRightBoard(false)
        return
    end
    self:DisplayRightBoard(true)
    -- 初始化助理教练头像
    self:InitPortrait(acModel)
    -- 助教团队属性
    local attrs = acModel:GetAttrs()
    local text = ""
    for k, attr in pairs(attrs) do
        text = text .. lang.transstr(attr.type) .. "/"
    end
    text = string.sub(text, 1, -2)
    self.txtAttr.text = text
    -- 助教属性成长
    self.sptGrowthes:InitView(attrs)
    -- 当前属性加成
    self.sptAttrs:InitView(attrs)
    -- 技能
    local skills = acModel:GetSkills()
    self.skillNum = table.nums(skills)
    self.skillScrollView:InitView(skills)
    -- 出售按钮状态
    self.buttonSell.interactable = self.model:GetMarketOpenState() and not acModel:IsInTeam()
    -- 解雇按钮状态
    self.buttonFire.interactable = not acModel:IsInTeam()
    -- 升级按钮状态
    self.buttonUpdate.interactable = not acModel:IsMax()
end

function AssistantCoachLibraryView:DisplayRightBoard(hasChoosed)
    GameObjectHelper.FastSetActive(self.objRightBoard.gameObject, hasChoosed)
    GameObjectHelper.FastSetActive(self.txtNotChoosed.gameObject, not hasChoosed)
    GameObjectHelper.FastSetActive(self.btnRecruit.gameObject, not hasChoosed)
end

-- 初始化助理教练头像
function AssistantCoachLibraryView:InitPortrait(acModel)
    if self.portraitSpt ~= nil then
        self:UpdatePortrait(acModel)
    else
        res.ClearChildren(self.rctPortrait)
        local portraitObj, portraitSpt = res.Instantiate(PortraitPath)
        if portraitObj ~= nil and portraitSpt ~= nil then
            self.portraitSpt = portraitSpt
            portraitObj.transform:SetParent(self.rctPortrait.transform, false)
            portraitObj.transform.localScale = Vector3.one
            portraitObj.transform.localPosition = Vector3.zero
            self:UpdatePortrait(acModel)
        end
    end
end

-- 更新助理教练教练头像显示
function AssistantCoachLibraryView:UpdatePortrait(acModel)
    if self.portraitSpt ~= nil then
        self.portraitSpt:InitView(acModel)
    end
end

-- 设置上阵or更换
function AssistantCoachLibraryView:SetTxtSwitch(text)
    self.txtSwitch.text = text
end

function AssistantCoachLibraryView:OnEnterScene()
    -- 升级面板升级后事件处理
    EventSystem.AddEvent("AssistantCoach_UpdateAfterUpgrade", self, self.UpdateAfterUpgrade)
    -- 选团队面板点击确定后事件处理
    EventSystem.AddEvent("AssistantCoachLibraryTeam_OnConfirmTeam", self, self.OnConfirmTeam)
end

function AssistantCoachLibraryView:OnExitScene()
    EventSystem.RemoveEvent("AssistantCoach_UpdateAfterUpgrade", self, self.UpdateAfterUpgrade)
    EventSystem.RemoveEvent("AssistantCoachLibraryTeam_OnConfirmTeam", self, self.OnConfirmTeam)
end

function AssistantCoachLibraryView:RegBtnEvent()
    -- 出售
    self.btnSell:regOnButtonClick(function()
        if self.onBtnSellClick and type(self.onBtnSellClick) == "function" then
            self.onBtnSellClick()
        end
    end)
    -- 更换
    self.btnSwitch:regOnButtonClick(function()
        self:OnBtnSwitchClick()
    end)
    -- 解雇
    self.btnFire:regOnButtonClick(function()
        if self.onBtnFireClick and type(self.onBtnFireClick) == "function" then
            self.onBtnFireClick()
        end
    end)
    -- 升级
    self.btnUpdate:regOnButtonClick(function()
        if self.onBtnUpdateClick and type(self.onBtnUpdateClick) == "function" then
            self.onBtnUpdateClick()
        end
    end)
    -- 去情报库界面
    self.btnRecruit:regOnButtonClick(function()
        if self.onBtnRecruitClick and type(self.onBtnRecruitClick) == "function" then
            self.onBtnRecruitClick()
        end
    end)
    -- 技能列表
    self.skillScrollView:regOnItemIndexChanged(function(idx)
        self:OnSkillScrollIndexChanged(idx)
    end)
    self.btnSkillLeft:regOnButtonClick(function()
        self.skillScrollView:scrollToPreviousGroup()
    end)
    self.btnSkillRight:regOnButtonClick(function()
        self.skillScrollView:scrollToNextGroup()
    end)
end

function AssistantCoachLibraryView:OnSkillScrollIndexChanged(idx)
    if not self.skillNum then
        local acModel = self.model:GetCurrAcModel()
        if acModel then
            self.skillNum = table.nums(acModel:GetSkills())
        else
            self.skillNum = 0
        end
    end
    GameObjectHelper.FastSetActive(self.btnSkillLeft.gameObject, idx > 1)
    GameObjectHelper.FastSetActive(self.btnSkillRight.gameObject, idx <= self.skillNum - 3)
end

function AssistantCoachLibraryView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

function AssistantCoachLibraryView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

-- 点击页签
function AssistantCoachLibraryView:OnClickTab(tag)
    if self.onClickTab and type(self.onClickTab) == "function" then
        self.onClickTab(tag)
    end
end

-- 更换
function AssistantCoachLibraryView:OnBtnSwitchClick()
    if self.onBtnSwitchClick and type(self.onBtnSwitchClick) == "function" then
        self.onBtnSwitchClick()
    end
end

-- 点击某个助理教练
function AssistantCoachLibraryView:OnAssistantCoachLibraryItemClick(acModel)
    if self.onAssistantCoachLibraryItemClick and type(self.onAssistantCoachLibraryItemClick) == "function" then
        self.onAssistantCoachLibraryItemClick(acModel)
    end
end

-- 换阵后更新
function AssistantCoachLibraryView:UpdateAfterSwitch()
    local pos = self.coachScrollView:GetScrollNormalizedPosition()
    self:UpdateCoachScrollView()
    self:coroutine(function()
        unity.waitForNextEndOfFrame() -- 等一帧，防止刷新设置位置导致界面列表为空
        self.coachScrollView:SetScrollNormalizedPosition(pos)
    end)
    self:InitRightBoard()
end

-- 解雇后更新
function AssistantCoachLibraryView:UpdateAfterFire()
    self:BuildView()
end

-- 升级后更新
function AssistantCoachLibraryView:UpdateAfterUpgrade(data)
    local acModel = self.model:GetCurrAcModel()
    self:UpdateCoachScrollViewItem(acModel.idx, acModel)
    self:InitRightBoard()
end

-- 确认团队事件处理
function AssistantCoachLibraryView:OnConfirmTeam()
    self:OnBtnSwitchClick()
end

return AssistantCoachLibraryView
