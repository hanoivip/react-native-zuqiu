local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Timer = require("ui.common.Timer")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CarnivalPageView = class(unity.base)

local CorrectPositionDayIndex = 4
local LabelTopPositionY = 0
local LabelBottomPositionY = 170
function CarnivalPageView:ctor()
    self.btnClose = self.___ex.btnClose
    self.labelRect = self.___ex.labelRect
    self.detailRect = self.___ex.detailRect
    self.progressRect = self.___ex.progressRect
    self.labelScrollView = self.___ex.labelScroll
    self.detailScrollView = self.___ex.detailScroll
    self.progressScrollView = self.___ex.progressScroll
    self.tab1 = self.___ex.tab1
    self.tab2 = self.___ex.tab2
    self.time = self.___ex.time
    self.itemParentScrollRect = self.___ex.itemParentScrollRect
    self.progressNum = self.___ex.progressNum
    self.residualTimer = nil
    DialogAnimation.Appear(self.transform, nil)
end

function CarnivalPageView:start()
    EventSystem.AddEvent("CarnivalPageView.InitTabsState", self, self.InitTabsState)
    self:BindAll()
end

function CarnivalPageView:InitView(model)
    self.carnivalModel = model
    self:RefreshTimer()
    self.progressNum.text = tostring(self.carnivalModel:GetCurrentProgressNumber())
    self:InitLabelsPosition()
end

-- 活动后几天时页面左侧Label位置处理
function CarnivalPageView:InitLabelsPosition()
    local correctPosY = self.carnivalModel:GetTodayIndex() > CorrectPositionDayIndex and LabelBottomPositionY or LabelTopPositionY
    local targetPos = Vector3(self.labelRect.anchoredPosition3D.x, self.labelRect.anchoredPosition3D.y + correctPosY, self.labelRect.anchoredPosition3D.z)
    self.labelRect.anchoredPosition3D = targetPos
end

function CarnivalPageView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    self.residualTimer = Timer.new(self.carnivalModel:GetRemainTime(), function(time)
        if time <= 0 then
            cache.setIsOpenBeginnerCarnival(false)
        end
        self.time.text = lang.transstr("carnival_residualTime") .. string.convertSecondToTime(time)
    end)
end

function CarnivalPageView:InitTabsView(data1, data2)
    self.tab1:InitView(data1)
    self.tab2:InitView(data2)
end

function CarnivalPageView:BindAll()
    self.btnClose:regOnButtonClick(function()
        if self.onCloseClick then
            self.onCloseClick()
        end
    end)
    self.tab1:regOnButtonClick(function()
        if self.onTab1Click then
            self.onTab1Click()
            self.tab1:ChangeButtonState(true)
            self.tab2:ChangeButtonState(false)
        end
    end)
    self.tab2:regOnButtonClick(function()
        if self.onTab2Click then
            self.onTab2Click()
            self.tab1:ChangeButtonState(false)
            self.tab2:ChangeButtonState(true)
        end
    end)
end

function CarnivalPageView:InitTabsState(isGetReward)
    if not isGetReward then
        self.tab1:ChangeButtonState(true)
        self.tab2:ChangeButtonState(false)
    end
end

function CarnivalPageView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function CarnivalPageView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    EventSystem.RemoveEvent("CarnivalPageView.InitTabsState", self, self.InitTabsState)
end

return CarnivalPageView