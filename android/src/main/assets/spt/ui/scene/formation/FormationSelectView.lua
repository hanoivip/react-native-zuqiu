local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local RectTransform = UnityEngine.RectTransform

local EventSystem = require("EventSystem")
local Formation = require("data.Formation")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FormationSelectView = class(unity.base)

local SelectedType = {
    Guard = 1,
    Forward = 2,
}
local FormationSelectedOffset = 3
local FormationItemHeight = 308
local FormationItemCountPerLine = 5

function FormationSelectView:ctor()
    -- 关闭按钮
    self.closeBtn = self.___ex.closeBtn
    -- 选择阵型分类按钮组
    self.selectBtnGroup = self.___ex.selectBtnGroup
    -- 确定按钮
    self.confirmBtn = self.___ex.confirmBtn
    -- 阵型名称
    self.formationStringName = self.___ex.formationStringName
    self.formationNumberName = self.___ex.formationNumberName
    -- 滚动列表
    self.scrollView = self.___ex.scrollView
    self.canvasGroup = self.___ex.canvasGroup
    -- 球员队伍模型
    self.playerTeamsModel = nil
    -- 当前选择阵型Id
    self.nowSelectFormationId = nil
    -- 当前阵型分类
    self.nowFormationCategory = nil
    -- 阵型数据
    self.formationListData = nil
    -- 1: 按后卫 2：按前锋
    self.selectedType = nil
    -- 滚动区域
    self.content = self.___ex.content
    -- 自动定位距离
    self.correctPosY = 0
end

function FormationSelectView:InitView(playerTeamsModel, nowFormationId)
    self.playerTeamsModel = playerTeamsModel
    self.nowSelectFormationId = tonumber(nowFormationId)
    self.selectedType = self.playerTeamsModel:GetSelectedType()  

    self:SetFormationCategory()
    self:BuildPage()
end

function FormationSelectView:start()
    self:BindAll()
    self:RegisterEvent()
    self:PlayInAnimator()
end

function FormationSelectView:BuildPage()
    self:FilterFormationData()
    self:SetFormationCategory()
    self:BuildSelectBtnGroup("category" .. self.nowFormationCategory)
    self:BuildScroller()
    self:BuildName()
end

-- 为所有的按钮绑定事件
function FormationSelectView:BindAll()
    -- 关闭按钮
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    -- 3后卫阵型按钮
    self.selectBtnGroup:BindMenuItem("category1", function ()
        self.nowFormationCategory = FormationConstants.FormationCategory.THREE_GUARD
        self.tempSelectedType = SelectedType.Guard
        self:FilterFormationData()
        self:BuildScroller()
    end)

    -- 4后卫阵型按钮
    self.selectBtnGroup:BindMenuItem("category2", function ()
        self.nowFormationCategory = FormationConstants.FormationCategory.FOUR_GUARD
        self.tempSelectedType = SelectedType.Guard
        self:FilterFormationData()
        self:BuildScroller()
    end)

    -- 5后卫阵型按钮
    self.selectBtnGroup:BindMenuItem("category3", function ()
        self.nowFormationCategory = FormationConstants.FormationCategory.FIVE_GUARD
        self.tempSelectedType = SelectedType.Guard
        self:FilterFormationData()
        self:BuildScroller()
    end)

    -- 1前锋阵型按钮
    self.selectBtnGroup:BindMenuItem("category4", function()
        self.nowFormationCategory = FormationConstants.FormationCategory.ONE_FORWARD
        self.tempSelectedType = SelectedType.Forward
        self:FilterFormationData()
        self:BuildScroller()
    end)

    -- 2前锋阵型按钮
    self.selectBtnGroup:BindMenuItem("category5", function()
        self.nowFormationCategory = FormationConstants.FormationCategory.TWO_FORWARD
        self.tempSelectedType = SelectedType.Forward
        self:FilterFormationData()
        self:BuildScroller()
    end)

    -- 3前锋阵型按钮
    self.selectBtnGroup:BindMenuItem("category6", function()
        self.nowFormationCategory = FormationConstants.FormationCategory.THREE_FORWARD
        self.tempSelectedType = SelectedType.Forward
        self:FilterFormationData()
        self:BuildScroller()
    end)

    -- 确定按钮
    self.confirmBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("FormationPageView.ChangeFormation", self.nowSelectFormationId)
        EventSystem.SendEvent("FormationPageView.ChangeFormationSelectedType", self.selectedType)
        self:Close()
    end)
end

--- 注册事件
function FormationSelectView:RegisterEvent()
    EventSystem.AddEvent("FormationSelectView.OnSelectFormation", self, self.OnSelectFormation)
end

--- 移除事件
function FormationSelectView:RemoveEvent()
    EventSystem.RemoveEvent("FormationSelectView.OnSelectFormation", self, self.OnSelectFormation)
end

--- 筛选阵型数据
function FormationSelectView:FilterFormationData()
    self.formationListData = {}

    for formationId, formationData in pairs(Formation) do
        local filterCondition = self.nowFormationCategory <= FormationSelectedOffset and formationData.formationCategory == self.nowFormationCategory or formationData.formationCategory2 == self.nowFormationCategory - FormationSelectedOffset
        if filterCondition then
            local data = {
                formationId = formationId,
                formationData = formationData,
            }
            table.insert(self.formationListData, data)
        end
    end
end

--- 构建选择阵型分类按钮组
function FormationSelectView:BuildSelectBtnGroup(tag)
    self.selectBtnGroup:selectMenuItem(tag)
end

-- 计算选中阵型位置
function FormationSelectView:InitSelectFormationScrollerPosition()
    if self.correctPosY == 0 then
        return
    end
    local targetPos = Vector3(self.content.anchoredPosition3D.x, self.content.anchoredPosition3D.y + self.correctPosY, self.content.anchoredPosition3D.z)
    self.content.anchoredPosition3D = targetPos
    self.correctPosY = 0
end

--- 构建滚动列表
function FormationSelectView:BuildScroller()
    self.scrollView:InitView(self.nowSelectFormationId, self.formationListData)
    self.scrollView:BuildView()
    for i, v in ipairs(self.formationListData) do
        if self.nowSelectFormationId == tonumber(v.formationId) and i > FormationItemCountPerLine then
            self.correctPosY = FormationItemHeight * (i - i % FormationItemCountPerLine) / FormationItemCountPerLine
        end
    end
    self:InitSelectFormationScrollerPosition()
end

--- 构建名称
function FormationSelectView:BuildName()
    local formationName = Formation[tostring(self.nowSelectFormationId)].name
    if not string.find(formationName, "%d") then
        self.formationStringName.text = formationName
        self.formationNumberName.text = ""
        self.formationStringName.transform.localPosition = Vector3(self.formationStringName.transform.localPosition.x, 5, self.formationStringName.transform.localPosition.z)
    else
        local i, _ = string.find(formationName, "%d")
        if i == 1 then
            self.formationStringName.text = ""
            self.formationNumberName.transform.localPosition = Vector3(self.formationNumberName.transform.localPosition.x, 5, self.formationNumberName.transform.localPosition.z)
        else
            self.formationStringName.text = string.sub(formationName, 1, i-1)
            self.formationNumberName.transform.localPosition = Vector3(self.formationNumberName.transform.localPosition.x, -10, self.formationNumberName.transform.localPosition.z)
        end
        self.formationNumberName.text = string.sub(formationName, i, -1)
        self.formationStringName.transform.localPosition = Vector3(self.formationStringName.transform.localPosition.x, 25, self.formationStringName.transform.localPosition.z)
    end
end

function FormationSelectView:SetFormationCategory()
    self.nowFormationCategory = self.selectedType ~= SelectedType.Forward and Formation[tostring(self.nowSelectFormationId)].formationCategory or Formation[tostring(self.nowSelectFormationId)].formationCategory2 + FormationSelectedOffset
end

--- 当选中了一个阵型时
function FormationSelectView:OnSelectFormation(formationId)
    self.nowSelectFormationId = formationId
    self.selectedType = self.tempSelectedType
    self.scrollView:InitView(self.nowSelectFormationId, self.formationListData)
    self:BuildName()
end

function FormationSelectView:onDestroy()
    self:RemoveEvent()
end

function FormationSelectView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FormationSelectView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FormationSelectView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FormationSelectView:Close()
    self:PlayOutAnimator()
end

return FormationSelectView