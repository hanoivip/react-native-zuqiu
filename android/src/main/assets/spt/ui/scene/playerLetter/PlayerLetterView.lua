local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Object = UnityEngine.Object

local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local PlayerLetterView = class(unity.base)

function PlayerLetterView:ctor()
    -- 关闭按钮
    self.closeBtn = self.___ex.closeBtn
    -- 分类按钮组
    self.selectBtnGroup = self.___ex.selectBtnGroup
    -- 滚动视图
    self.scrollView = self.___ex.scrollView
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    -- 球员信函视图model
    self.playerLetterViewModel = nil
    -- 当前按钮标签
    self.tagType = nil
end

function PlayerLetterView:awake()
    self:RegisterEvent()
    self:BindAll()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function PlayerLetterView:InitView(playerLetterViewModel)
    self.playerLetterViewModel = playerLetterViewModel
    self.tagType = self.playerLetterViewModel:GetTagType()
end

function PlayerLetterView:OnEnterView()
    self:BuildSelectBtnGroup()
    -- GuideManager.InitCurModule("letter")
    -- GuideManager.Show()
end

function PlayerLetterView:OnExitView()
end

function PlayerLetterView:BindAll()
    -- 关闭按钮
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    -- 未回信按钮
    self.selectBtnGroup:BindMenuItem("noReply", function ()
        EventSystem.SendEvent("PlayerLetter.SwitchTag", PlayerLetterConstants.TagType.NO_REPLY)
    end)

    -- 已回信按钮
    self.selectBtnGroup:BindMenuItem("haveReply", function ()
        EventSystem.SendEvent("PlayerLetter.SwitchTag", PlayerLetterConstants.TagType.HAVE_REPLY)
    end)
end

function PlayerLetterView:RegisterEvent()
    EventSystem.AddEvent("PlayerLetter.InitView", self, self.InitView)
    EventSystem.AddEvent("PlayerLetter.OnEnterView", self, self.OnEnterView)
    EventSystem.AddEvent("PlayerLetter.OnExitView", self, self.OnExitView)
    EventSystem.AddEvent("PlayerLetter.Destroy", self, self.Destroy)
end

function PlayerLetterView:RemoveEvent()
    EventSystem.RemoveEvent("PlayerLetter.InitView", self, self.InitView)
    EventSystem.RemoveEvent("PlayerLetter.OnEnterView", self, self.OnEnterView)
    EventSystem.RemoveEvent("PlayerLetter.OnExitView", self, self.OnExitView)
    EventSystem.RemoveEvent("PlayerLetter.Destroy", self, self.Destroy)
end

--- 构建标签
function PlayerLetterView:BuildSelectBtnGroup()
    self.selectBtnGroup:selectMenuItem(self.tagType)
end

function PlayerLetterView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        self:Destroy()
        if type(self.onClose) == "function" then
            self.onClose()
        end
    end)
end

function PlayerLetterView:Destroy()
    self.playerLetterViewModel:SetTagType(PlayerLetterConstants.TagType.NO_REPLY)
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function PlayerLetterView:onDestroy()
    self:RemoveEvent()
end

return PlayerLetterView