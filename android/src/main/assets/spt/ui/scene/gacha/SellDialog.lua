local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local UISoundManager = require("ui.control.manager.UISoundManager")

local SellDialog = class(unity.base)

function SellDialog:ctor()
    self.title = self.___ex.title
    self.content = self.___ex.content
    self.button1 = self.___ex.button1
    self.button1Text = self.___ex.button1Text
    self.button2 = self.___ex.button2
    self.button2Text = self.___ex.button2Text
    self.close = self.___ex.close
    self.canvasGroup = self.___ex.canvasGroup
end

function SellDialog:initData(data)
    if type(data) == "table" then
        self.data = data
        if type(data.title) == "string" or clr.is(data.title, clr.System.String) then
            self.title.text = data.title
        end
        if type(data.content) == "string" or clr.is(data.content, clr.System.String) then
            self.content.text = data.content
        end
        if type(data.button1Text) == "string" or clr.is(data.button1Text, clr.System.String) then
            self.onButton1Clicked = data.onButton1Clicked
            self.button1Text.text = data.button1Text
        else
            GameObjectHelper.FastSetActive(self.button1.gameObject, false)
        end
        if type(data.button2Text) == "string" or clr.is(data.button2Text, clr.System.String) then
            self.onButton2Clicked = data.onButton2Clicked
            self.button2Text.text = data.button2Text
        else
            GameObjectHelper.FastSetActive(self.button2.gameObject, false)
        end
    end
end

function SellDialog:Close(callback)
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
        if type(callback) == "function" then
            callback()
        end
    end)
end

function SellDialog:start()
    self.button1:regOnButtonClick(function (eventData)
        self:Close(function()
            if type(self.onButton1Clicked) == "function" then
                self.onButton1Clicked()
            end
        end)
    end)
    self.button2:regOnButtonClick(function (eventData)
        self:Close(function()
            if type(self.onButton2Clicked) == "function" then
                self.onButton2Clicked()
            end
        end)
    end)
    self.close:regOnButtonClick(function (eventData)
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    UISoundManager.play("promptWindow", 1)
end

return SellDialog
