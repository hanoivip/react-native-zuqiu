local UnityEngine = clr.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardFlashBangRootView = require("ui.scene.greensward.flashBang.GreenswardFlashBangRootView")

local GreenswardGlassesRootView = class(GreenswardFlashBangRootView, "GreenswardGlassesRootView")

local Step = {
    Select = 1,
    Confirm = 2,
    View = 3
}

-- 不可照明的事件id
-- 弃用，现改为根据事件状态
GreenswardGlassesRootView.UnclickableEvent = {}

-- 可照明的事件状态，正常云、雷云、红云
GreenswardGlassesRootView.ClickableEventStuKey = { "Lock", "Lock_Effect", "Unlock" }
GreenswardGlassesRootView.ClickableEventStu = {}

function GreenswardGlassesRootView:ctor()
    GreenswardGlassesRootView.super.ctor(self)
end

function GreenswardGlassesRootView:start()
    self.canvasCore.worldCamera = GameObject.Find("WorldCamera"):GetComponent("Camera")
    self.canvasUI.worldCamera = GameObject.Find("Main Camera"):GetComponent("Camera")
end

function GreenswardGlassesRootView:InitView(greenswardBuildModel, size)
    self.buildModel = greenswardBuildModel
    self.sptCore.onBtnConfirm = function(leftup_row, leftup_col, size_x, size_y) self:OnBtnConfirm(leftup_row, leftup_col, size_x, size_y) end
    self.sptCore.onBtnCancel = function() self:OnBtnCancel() end
    self.sptCore.onBtnOver = function() self:OnBtnOver() end -- 透视镜有结束按钮
    self.sptCore:InitView(size)
end

function GreenswardGlassesRootView:IsUnclickable(eventId)
    return false
end

function GreenswardGlassesRootView:ShowUnclickableTip()
    DialogManager.ShowToastByLang("greensward_flashbang_unclickable_2")
end

------------------------
-- 特效阶段
------------------------

-- 点击结束查看
function GreenswardGlassesRootView:OnBtnOver()
    if self.onBtnOver and type(self.onBtnOver) == "function" then
        self.onBtnOver()
    end
end

-- 设置云彩和地图上一致
function GreenswardGlassesRootView:SetClouds(stus)
    self.sptCore:SetClouds(stus)
end

-- 返回按钮事件
function GreenswardGlassesRootView:OnBtnBackClick()
    if self.step == Step.Select then
        EventSystem.SendEvent("GreenswardFlashBang_QuitFlashBang")
    elseif self.step == Step.Confirm then
        self.sptCore:OnBtnCancel()
    elseif self.step == Step.View then
        self.sptCore:OnBtnOver()
    end
end

return GreenswardGlassesRootView
