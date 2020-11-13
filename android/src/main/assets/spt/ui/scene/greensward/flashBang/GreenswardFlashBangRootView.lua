local UnityEngine = clr.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")

local GreenswardFlashBangRootView = class(unity.base, "GreenswardFlashBangRootView")

local Step = {
    Select = 1,
    Confirm = 2,
    View = 3
}

-- 不可照明的事件id
-- 弃用，现改为根据事件状态
GreenswardFlashBangRootView.UnclickableEvent = { "1", "2", "12", "13", "14", "15" }

-- 可照明的事件状态，正常云和红云
GreenswardFlashBangRootView.ClickableEventStuKey = { "Lock", "Unlock" }
GreenswardFlashBangRootView.ClickableEventStu = {}

function GreenswardFlashBangRootView:ctor()
    self.sptCore = self.___ex.sptCore
    self.sptUI = self.___ex.sptUI
    self.canvasCore = self.___ex.canvasCore
    self.canvasUI = self.___ex.canvasUI

    self.step = nil
    self.clickedEventModel = nil
end

function GreenswardFlashBangRootView:start()
    self.canvasCore.worldCamera = GameObject.Find("WorldCamera"):GetComponent("Camera")
    self.canvasUI.worldCamera = GameObject.Find("Main Camera"):GetComponent("Camera")
end

function GreenswardFlashBangRootView:InitView(greenswardBuildModel, size)
    self.buildModel = greenswardBuildModel
    self.sptCore.onBtnConfirm = function(leftup_row, leftup_col, size_x, size_y) self:OnBtnConfirm(leftup_row, leftup_col, size_x, size_y) end
    self.sptCore.onBtnCancel = function() self:OnBtnCancel() end
    self.sptCore:InitView(size)
end

function GreenswardFlashBangRootView:OnEnterScene()
    EventSystem.AddEvent("GreenswardFlashBang_OnClickMapFrame", self, self.EnterConfirmStep)
    EventSystem.AddEvent("GreenswardFlashBang_QuitFlashBang", self, self.QuitFlashMode)
    EventSystem.AddEvent("GreenswardFlashBang_OnBtnBackClick", self, self.OnBtnBackClick)
end

function GreenswardFlashBangRootView:OnExitScene()
    EventSystem.RemoveEvent("GreenswardFlashBang_OnClickMapFrame", self, self.EnterConfirmStep)
    EventSystem.RemoveEvent("GreenswardFlashBang_QuitFlashBang", self, self.QuitFlashMode)
    EventSystem.RemoveEvent("GreenswardFlashBang_OnBtnBackClick", self, self.OnBtnBackClick)
end

-- 显示内容
function GreenswardFlashBangRootView:ShowContent(isShow)
    GameObjectHelper.FastSetActive(self.sptCore.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.sptUI.gameObject, isShow)
end

------------------------
-- 选择阶段
------------------------

-- 进入照明弹选择区域模式
function GreenswardFlashBangRootView:EnterSelectStep()
    self.step = Step.Select
    self:ShowContent(true)
    self.sptCore:EnterSelectStep()
    self.sptUI:EnterSelectStep()
    EventSystem.SendEvent("GreenswardFlashBang_SelectStep")
end

------------------------
-- 确认阶段
------------------------

-- 进入确认阶段
function GreenswardFlashBangRootView:EnterConfirmStep(mapFrame, eventModel)
    if self.step == Step.Select then
        if not self:IsClickableStu(eventModel) then
            self:ShowUnclickableTip()
            return
        end
        -- 进入下一阶段
        self.clickedEventModel = eventModel
        self.sptCore:SetEventModel(eventModel)
        self.sptCore:EnterConfirmStep(mapFrame.row, mapFrame.col)
        self.sptUI:EnterConfirmStep()
        self.step = Step.Confirm
        self:OnEnterConfirmStep(mapFrame.row, mapFrame.col)
    end
end

-- 进入确认阶段回调
function GreenswardFlashBangRootView:OnEnterConfirmStep(row, col)
    if self.onEnterConfirmStep and type(self.onEnterConfirmStep) == "function" then
        self.onEnterConfirmStep(row, col)
    end
end

-- 点击选中区域的确认按钮，确认后进入特效阶段
function GreenswardFlashBangRootView:OnBtnConfirm(leftup_row, leftup_col, size_x, size_y)
    if self.step == Step.Confirm then
        if self.onBtnConfirm and type(self.onBtnConfirm) == "function" then
            self.onBtnConfirm(leftup_row, leftup_col, size_x, size_y)
        end
    end
end

-- 点击选中区域的取消按钮
function GreenswardFlashBangRootView:OnBtnCancel()
    if self.onBtnCancel and type(self.onBtnCancel) == "function" then
        self.onBtnCancel()
    end
end

-- 判断点击的事件是否是可以被照明
-- @return: 不可照明返回true，可照明返回false
-- 弃用
function GreenswardFlashBangRootView:IsUnclickable(eventId)
    eventId = tostring(eventId)
    for k, id in ipairs(self.UnclickableEvent) do
        if eventId == id then
            return true
        end
    end
    return false
end

-- 判断点击的事件状态是否满足条件
-- @return: 可照明返回true，不可照明返回false
function GreenswardFlashBangRootView:IsClickableStu(eventModel)
    self:InitClickableEventStu(eventModel)
    local currStu = tonumber(eventModel:GetCurrentState())
    for k, stu in ipairs(self.ClickableEventStu or {}) do
        if currStu == tonumber(stu) then
            return true
        end
    end
    return false
end

-- 使用eventModel中的定义事件状态的值判断，防止修改状态值后导致判断出错
function GreenswardFlashBangRootView:InitClickableEventStu(eventModel)
    if table.isEmpty(self.ClickableEventStu) then
        self.ClickableEventStu = {}
        for k, stuKey in ipairs(self.ClickableEventStuKey or {}) do
            if eventModel.EventStatus[stuKey] ~= nil then
                table.insert(self.ClickableEventStu, eventModel.EventStatus[stuKey])
            end
        end
    end
end

function GreenswardFlashBangRootView:ShowUnclickableTip()
    DialogManager.ShowToastByLang("greensward_flashbang_unclickable_1")
end

------------------------
-- 特效阶段
------------------------

-- 进入特效阶段
function GreenswardFlashBangRootView:EnterViewStep(leftup_row, leftup_col, size_x, size_y)
    if self.step == Step.Confirm then
        self.step = Step.View
        self.sptCore:EnterViewStep(leftup_row, leftup_col, size_x, size_y)
        self:OnEnterViewStep(leftup_row, leftup_col, size_x, size_y)
    end
end

-- 进入查看阶段回调
function GreenswardFlashBangRootView:OnEnterViewStep(leftup_row, leftup_col, size_x, size_y)
    if self.onEnterViewStep and type(self.onEnterViewStep) == "function" then
        self.onEnterViewStep(leftup_row, leftup_col, size_x, size_y)
    end
end

-- 播放特效
function GreenswardFlashBangRootView:PlayVfx(callback)
    self.sptCore:PlayVfx(callback)
end

-- 退出照明弹模式
function GreenswardFlashBangRootView:QuitFlashMode()
    self:ShowContent(false)
    if self.onQuitFlashMode and type(self.onQuitFlashMode) == "function" then
        self.onQuitFlashMode()
    end
end

-- 返回按钮事件
function GreenswardFlashBangRootView:OnBtnBackClick()
    if self.step == Step.Select then
        EventSystem.SendEvent("GreenswardFlashBang_QuitFlashBang")
    elseif self.step == Step.Confirm then
        self.sptCore:OnBtnCancel()
    end
end

return GreenswardFlashBangRootView
