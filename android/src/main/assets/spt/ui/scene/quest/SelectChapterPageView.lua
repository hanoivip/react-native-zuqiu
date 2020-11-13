local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Color = UnityEngine.Color
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object

local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local SelectChapterPageView = class(unity.base)

function SelectChapterPageView:ctor()
    -- 滚动视图
    self.scrollView = self.___ex.scrollView
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    -- 左切换按钮
    self.leftSwitchBtn = self.___ex.leftSwitchBtn
    -- 右切换按钮
    self.rightSwitchBtn = self.___ex.rightSwitchBtn
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
end

function SelectChapterPageView:InitView(questInfoModel)
    self.questInfoModel = questInfoModel
    self.nowChapterIndex = self.questInfoModel:GetLastChapterIndex()
    self.scrollView:InitView(self.questInfoModel, self.nowChapterIndex)
end

function SelectChapterPageView:start()
    self:RegisterEvent()
    self:BindAll()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function SelectChapterPageView:BindAll()
    -- 左切换按钮
    self.leftSwitchBtn:regOnButtonClick(function ()
        self.scrollView:scrollToPreviousGroup()
    end)

    -- 右切换按钮
    self.rightSwitchBtn:regOnButtonClick(function ()
        self.scrollView:scrollToNextGroup()
    end)
end

--- 注册事件
function SelectChapterPageView:RegisterEvent()
    EventSystem.AddEvent("SelectChapter.Destroy", self, self.Close)
end

--- 移除事件
function SelectChapterPageView:RemoveEvent()
    EventSystem.RemoveEvent("SelectChapter.Destroy", self, self.Close)
end

function SelectChapterPageView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function SelectChapterPageView:onDestroy()
    self:RemoveEvent()
end

return SelectChapterPageView