local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local UISoundManager = require("ui.control.manager.UISoundManager")

local MessageToggleBox = class(unity.base)

function MessageToggleBox:ctor()
    self.title = self.___ex.title
    self.content = self.___ex.content
    self.button1 = self.___ex.button1
    self.button1Text = self.___ex.button1Text
    self.button2 = self.___ex.button2
    self.button2Text = self.___ex.button2Text
    self.close = self.___ex.close
    self.canvasGroup = self.___ex.canvasGroup
    self.toggleText = self.___ex.toggleText
    self.toggleSelect = self.___ex.toggleSelect
    self.toggle = self.___ex.toggle
end

--[[
local testData = {
    title = '服务器错误',
    content = '发生了一些问题的样子，请求失败啦',
    button1Text = "重试",
    onButton1Clicked = function () end,
    button2Text = "确定",
    onButton2Clicked = function () end,
    toggleTxt = "勾选后下次不再提示",
    onToggleClicked = function (selectState) end,
    autoCloseTime = 3,
    hasCloseIcon = false,
}
--]]
function MessageToggleBox:initData(data)
    local onBack, onBackFunc
    if type(data) == 'table' then
        self.data = data
        if type(data.title) == 'string' or clr.is(data.title, clr.System.String) then
            self.title.text = data.title
        end
        if type(data.content) == 'string' or clr.is(data.title, clr.System.String) then
            self.content.text = data.content
        end
        if type(data.button1Text) == "string" or clr.is(data.title, clr.System.String) then
            self.onButton1Clicked = data.onButton1Clicked
            self.button1Text.text = data.button1Text
            onBack = true
            onBackFunc = self.onButton1Clicked
        else
            GameObjectHelper.FastSetActive(self.button1.gameObject, false)
        end
        if type(data.button2Text) == "string" or clr.is(data.title, clr.System.String) then
            self.onButton2Clicked = data.onButton2Clicked
            self.button2Text.text = data.button2Text
            if not onBack then
                onBack = true
                onBackFunc = self.onButton2Clicked
            else
                onBack = false
            end
        else
            GameObjectHelper.FastSetActive(self.button2.gameObject, false)
        end
        if data.hideCloseIcon then
            GameObjectHelper.FastSetActive(self.close.gameObject, false)
        end
        if type(data.toggleTxt) == "string" or clr.is(data.title, clr.System.String) then
            self.toggleText.text = data.toggleTxt
            self.onToggleClicked =data.onToggleClicked
            self.selectState = false
            GameObjectHelper.FastSetActive(self.toggleSelect.gameObject, self.selectState)
        else
            GameObjectHelper.FastSetActive(self.toggle.gameObject, false)
        end
        if data.textAlignment then 
            self.content.alignment = data.textAlignment
        end
        
        if type(self.data.autoCloseTime) == "number" then
            self:coroutine(function ()
                coroutine.yield(WaitForSeconds(self.data.autoCloseTime))
                self:Close()
            end)
        end
    end
    if onBack then
        self.OnBack = function()
            if type(onBackFunc) == "function" then
                onBackFunc()
            end
            self.closeDialog()
        end
    end
end

function MessageToggleBox:Close(callback)
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
        if type(callback) == "function" then
            callback()
        end
    end)
end

function MessageToggleBox:start()
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
    self.toggle:regOnButtonClick(function (eventData)
        if type(self.onToggleClicked) == "function" then
            self.selectState = not self.selectState
            GameObjectHelper.FastSetActive(self.toggleSelect.gameObject, self.selectState)
            self.onToggleClicked(self.selectState)
        end
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    UISoundManager.play('promptWindow', 1)
end

return MessageToggleBox
