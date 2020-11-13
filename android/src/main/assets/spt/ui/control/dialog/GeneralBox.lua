local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local UISoundManager = require("ui.control.manager.UISoundManager")

local GeneralBox = class(unity.base)

function GeneralBox:ctor()
    self.title = self.___ex.title
    self.content = self.___ex.content
    self.button1 = self.___ex.button1
    self.button1Text = self.___ex.button1Text
    self.button2 = self.___ex.button2
    self.button2Text = self.___ex.button2Text
    self.close = self.___ex.close
    self.canvasGroup = self.___ex.canvasGroup
    self.contentRect = self.___ex.contentRect
    self.infoLayout = self.___ex.infoLayout
end

--[[
local testData = {
    title = '服务器错误',
    content = '发生了一些问题的样子，请求失败啦',
    button1Text = "重试",
    onButton1Clicked = function () end,
    button2Text = "确定",
    onButton2Clicked = function () end,
    autoCloseTime = 3,
    hasCloseIcon = false,
    width = 0, 宽
    textAlignment,文字对齐方式
}
--]]
function GeneralBox:initData(data)
    if type(data) == 'table' then
        self.data = data
        if type(data.title) == 'string' or clr.is(data.title, clr.System.String) then
            self.title.text = data.title
        end
        if type(data.content) == 'string' or clr.is(data.content, clr.System.String) then
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
        if data.hideCloseIcon then
            GameObjectHelper.FastSetActive(self.close.gameObject, false)
        end

        local fixWidth = data.width
        if fixWidth then 
            self.infoLayout.preferredWidth = fixWidth + self.infoLayout.preferredWidth - self.contentRect.sizeDelta.x
            self.contentRect.sizeDelta = Vector2(fixWidth, self.contentRect.sizeDelta.y)
        end
        local textAlignment = data.textAlignment
        if textAlignment then 
            self.content.alignment = textAlignment
        end
        
        if type(self.data.autoCloseTime) == "number" then
            self:coroutine(function ()
                coroutine.yield(WaitForSeconds(self.data.autoCloseTime))
                self:Close()
            end)
        end
    end
end

function GeneralBox:Close(callback)
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
        if type(callback) == "function" then
            callback()
        end
    end)
end

function GeneralBox:start()
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
    UISoundManager.play('promptWindow', 1)
end

return GeneralBox
