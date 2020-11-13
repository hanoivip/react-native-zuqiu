local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local Formation = require("data.Formation")

local CoachBaseInfoFormationView = class(unity.base, "CoachBaseInfoFormationView")

function CoachBaseInfoFormationView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnConfirm = self.___ex.btnConfirm
    self.selectBtnGroup = self.___ex.selectBtnGroup
end

function CoachBaseInfoFormationView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachBaseInfoFormationView:InitView(coachBaseInfoFormationModel)
    self.model = coachBaseInfoFormationModel

    self:InitSelectBtnGroup(self.model:GetCurrSelectBtnTag())
    self:BuildScroller(true)
end

function CoachBaseInfoFormationView:RegBtnEvent()
    self.btnConfirm:regOnButtonClick(function()
        if self.onClickConfirm then
            self.onClickConfirm()
        end
        self.model:SetSelectedType(self.model:GetTempSelectedType())
        local formationData = self.model:GetCurrSelectedFormationData()
        -- 切换列表后选择的可能为空
        -- 点击确定直接关闭
        if formationData then
            EventSystem.SendEvent("CoachBaseInfoUpdate_OnChangeSelectedFormation", formationData)
        end
        self:Close()
    end)

     -- 3后卫阵型按钮
    self.selectBtnGroup:BindMenuItem("category1", function ()
        self.model:SetFormationCategory(FormationConstants.FormationCategory.THREE_GUARD)
        self.model:SetTempSelectedType(self.model.SelectedType.Guard)
        self.model:FilterFormationData()
        self:BuildScroller()
    end)

    -- 4后卫阵型按钮
    self.selectBtnGroup:BindMenuItem("category2", function ()
        self.model:SetFormationCategory(FormationConstants.FormationCategory.FOUR_GUARD)
        self.model:SetTempSelectedType(self.model.SelectedType.Guard)
        self.model:FilterFormationData()
        self:BuildScroller()
    end)

    -- 5后卫阵型按钮
    self.selectBtnGroup:BindMenuItem("category3", function ()
        self.model:SetFormationCategory(FormationConstants.FormationCategory.FIVE_GUARD)
        self.model:SetTempSelectedType(self.model.SelectedType.Guard)
        self.model:FilterFormationData()
        self:BuildScroller()
    end)

    -- 1前锋阵型按钮
    self.selectBtnGroup:BindMenuItem("category4", function()
        self.model:SetFormationCategory(FormationConstants.FormationCategory.ONE_FORWARD)
        self.model:SetTempSelectedType(self.model.SelectedType.Forward)
        self.model:FilterFormationData()
        self:BuildScroller()
    end)

    -- 2前锋阵型按钮
    self.selectBtnGroup:BindMenuItem("category5", function()
        self.model:SetFormationCategory(FormationConstants.FormationCategory.TWO_FORWARD)
        self.model:SetTempSelectedType(self.model.SelectedType.Forward)
        self.model:FilterFormationData()
        self:BuildScroller()
    end)

    -- 3前锋阵型按钮
    self.selectBtnGroup:BindMenuItem("category6", function()
        self.model:SetFormationCategory(FormationConstants.FormationCategory.THREE_FORWARD)
        self.model:SetTempSelectedType(self.model.SelectedType.Forward)
        self.model:FilterFormationData()
        self:BuildScroller()
    end)
end

--- 构建选择阵型分类按钮组
function CoachBaseInfoFormationView:InitSelectBtnGroup(tag)
    self.selectBtnGroup:selectMenuItem(tag)
end

--- 构建滚动列表
function CoachBaseInfoFormationView:BuildScroller(isInit)
    self.scrollView:RegOnItemButtonClick("btnClick", function(itemData)
        self:OnItemClick(itemData)
    end)
    self.scrollView:InitView(self.model:GetScrollData())
    local idx = self.model:GetCurrFormationIdx()
    if isInit and idx then
        self.scrollView:scrollToCellImmediate(self.model:GetCurrFormationIdx())
    end
end

-- 计算选中阵型位置
-- 默认选中当前使用阵型
-- 切换列表后选择的为nil
function CoachBaseInfoFormationView:InitSelectFormationScrollerPosition()
    if self.correctPosY == 0 then
        return
    end
    local targetPos = Vector3(self.content.anchoredPosition3D.x, self.content.anchoredPosition3D.y + self.correctPosY, self.content.anchoredPosition3D.z)
    self.content.anchoredPosition3D = targetPos
    self.correctPosY = 0
end

function CoachBaseInfoFormationView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 选中一个阵型
function CoachBaseInfoFormationView:OnItemClick(itemData)
    if self.onItemClick then
        self.onItemClick(itemData)
    end
end

return CoachBaseInfoFormationView

