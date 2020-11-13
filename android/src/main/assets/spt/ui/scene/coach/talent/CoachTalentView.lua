local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachTalentView = class(unity.base, "CoachTalentView")

CoachTalentView.treeCpacity = 20

CoachTalentView.treeParam_type1 = {
    offset_x = 40,
    offset_y = -5,
    nodeWidth = 75,
    nodeHeight = 103,
    nodeMargin_x = 44,
    nodeMargin_y = 1,
    arrowOffset_x = 0,
    arrowOffset_y = 11,
    isFix = true,
}

CoachTalentView.treeParam_type2 = {
    offset_x = 12,
    offset_y = -5,
    nodeWidth = 75,
    nodeHeight = 103,
    nodeMargin_x = 68,
    nodeMargin_y = 1,
    arrowOffset_x = 0,
    arrowOffset_y = 11,
    isFix = false,
}

function CoachTalentView:ctor()
    self.mainView = self.___ex.mainView
    -- 货币信息
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 当前执教天赋点数
    self.txtPoint = self.___ex.txtPoint
    -- 左侧滑动框，天赋类别（round/tab）
    self.scrollView = self.___ex.scrollView
    -- 右侧天赋树控制脚本
    self.treeView = self.___ex.treeView
    -- 当前round已使用天赋点
    self.txtUsedPoint = self.___ex.txtUsedPoint
    -- 解锁条件
    self.txtUnlockCondition = self.___ex.txtUnlockCondition
    -- 重置按钮
    self.btnReset = self.___ex.btnReset
    -- 指示器
    self.sptIndicators = self.___ex.sptIndicators

    -- 滑动框数据
    self.itemDatas = nil
end

function CoachTalentView:start()
    self:RegBtnEvent()
end

function CoachTalentView:RegBtnEvent()
    self.btnReset:regOnButtonClick(function()
        if self.onBtnResetClick and type(self.onBtnResetClick) == "function" then
            self.onBtnResetClick()
        end
    end)
end

function CoachTalentView:InitView(coachTalentModel)
    self.model = coachTalentModel
    self.itemDatas = self.model:GetScrollData()
    self:InitMyPoint()
    self:InitCurrUsedPoint()
    self:InitUnlockCondition()
    -- 左侧滑动框
    self.scrollView:InitView(self.itemDatas)
    self.scrollView:unregOnItemIndexChanged()
    self.scrollView:regOnItemIndexChanged(function(index)
        self:OnItemIndexChange(index)
    end)
    self:InitIndicators()
    -- 右侧技能树
    self.treeView:InitView(self.treeCpacity)
    self:RefreshTreeView()
end

-- 初始化指示点
function CoachTalentView:InitIndicators()
    if not self.itemDatas then return end

    local num = #self.itemDatas
    self.sptIndicators:InitView(num)
end

-- 我当前所拥有的天赋点
function CoachTalentView:InitMyPoint()
    self.txtPoint.text = lang.trans("coach_talent_point", self.model:GetCtp())
end

-- 当前页面所使用的天赋点
function CoachTalentView:InitCurrUsedPoint()
    self.txtUsedPoint.text = lang.trans("coach_talent_used_point", self.model:GetCurrRoundUsedPoint())
end

-- 解锁条件提示文本
function CoachTalentView:InitUnlockCondition()
    local index = self.model:GetScrollViewIndex()
    local roundData = self.itemDatas[index] or {}
    if roundData.roundUnlockCondition > 0 then
        self.txtUnlockCondition.text = lang.trans("coach_talent_round_condition", roundData.roundName, roundData.roundUnlockCondition)
    else
        self.txtUnlockCondition.text = " "
    end
end

function CoachTalentView:OnEnterScene()
    EventSystem.AddEvent("OnTreeNodeClick", self, self.OnTreeNodeClick)
    EventSystem.AddEvent("UpdateAfterUpgrade", self, self.UpdateAfterUpgrade)
end

function CoachTalentView:OnExitScene()
    EventSystem.RemoveEvent("OnTreeNodeClick", self, self.OnTreeNodeClick)
    EventSystem.RemoveEvent("UpdateAfterUpgrade", self, self.UpdateAfterUpgrade)
end

function CoachTalentView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

function CoachTalentView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function CoachTalentView:OnItemIndexChange(index)
    self.model:SetScrollViewIndex(index)
    self.sptIndicators:GotoIndex(index)
    self:InitCurrUsedPoint()
    self:InitUnlockCondition()
    self:RefreshTreeView()
end

function CoachTalentView:RefreshTreeView()
    local index = self.model:GetScrollViewIndex()
    local roundData = self.itemDatas[index]
    if roundData.roundType == self.model.RoundType.type_1 then
        self.treeView:RefreshTreeView(roundData.talentTree, self.treeParam_type1)
    else
        self.treeView:RefreshTreeView(roundData.talentTree, self.treeParam_type2)
    end
end

-- 点击技能
function CoachTalentView:OnTreeNodeClick(skillData)
    if self.onTreeNodeClick then
        self.onTreeNodeClick(skillData)
    end
end

-- 解锁后更新界面
function CoachTalentView:UpdateAfterUnlock()
    self:UpdateAfterUpgrade()
end

-- 升级后更新界面
function CoachTalentView:UpdateAfterUpgrade()
    self:InitMyPoint()
    self:InitCurrUsedPoint()
    self:RefreshTreeView()
end

-- 重置后更新界面
function CoachTalentView:UpdateAfterReset()
    self:InitView(self.model)
end

return CoachTalentView
