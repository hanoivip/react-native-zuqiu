local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local CoachTalentView = require("ui.scene.coach.talent.CoachTalentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local OtherCoachTalentView = class(CoachTalentView, "OtherCoachTalentView")

function OtherCoachTalentView:ctor()
    self.mainView = self.___ex.mainView
    -- 左侧滑动框，天赋类别（round/tab）
    self.scrollView = self.___ex.scrollView
    -- 右侧天赋树控制脚本
    self.treeView = self.___ex.treeView
    -- 当前round已使用天赋点
    self.txtUsedPoint = self.___ex.txtUsedPoint
    -- 解锁条件
    self.txtUnlockCondition = self.___ex.txtUnlockCondition
    -- 指示器
    self.sptIndicators = self.___ex.sptIndicators
    -- 返回按钮
    self.btnBack = self.___ex.btnBack

    -- 滑动框数据
    self.itemDatas = nil
end

function OtherCoachTalentView:start()
    self:RegBtnEvent()
end

function OtherCoachTalentView:RegBtnEvent()
    self.btnBack:regOnButtonClick(function()
        if self.onBtnBackClick and type(self.onBtnBackClick) == "function" then
            self.onBtnBackClick()
        end
    end)
end

function OtherCoachTalentView:InitView(otherCoachTalentModel)
    self.model = otherCoachTalentModel
    self.itemDatas = self.model:GetScrollData()
    self:InitIndicators()
    -- 右侧技能树
    self.treeView:InitView(self.treeCpacity)
end

function OtherCoachTalentView:RefreshView()
    if not self.model then
        self:ShowDisplayArea(false)
        return
    end

    self:InitCurrUsedPoint()
    self:InitUnlockCondition()
    -- 左侧滑动框
    self.scrollView:unregOnItemIndexChanged()
    self.scrollView:regOnItemIndexChanged(function(index)
        self:OnItemIndexChange(index)
    end)
    self.scrollView:InitView(self.itemDatas)

    self:RefreshTreeView()
end

function OtherCoachTalentView:OnEnterScene()
end

function OtherCoachTalentView:OnExitScene()
end

return OtherCoachTalentView
