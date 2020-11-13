local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local UISoundManager = require("ui.control.manager.UISoundManager")

local MessageTipsBox = class(unity.base)

function MessageTipsBox:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.contentTxt = self.___ex.contentTxt
    self.tip1Txt = self.___ex.tip1Txt
    self.tip2Go = self.___ex.tip2Go
    self.tip2Txt = self.___ex.tip2Txt
    self.tip3Go = self.___ex.tip3Go
    self.tip3Txt = self.___ex.tip3Txt
    self.cancelBtn = self.___ex.cancelBtn
    self.cancelTxt = self.___ex.cancelTxt
    self.confirmBtn = self.___ex.confirmBtn
    self.confirmTxt = self.___ex.confirmTxt
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
end

--[[
local testData = {
    title = '服务器错误',
    content = '发生了一些问题的样子，请求失败啦',
    tip1 = "提示1"
    tip1 = "提示2"
    tip1 = "提示3"
    button1Text = "重试",
    onButton1Clicked = function () end,
    button2Text = "确定",
    onButton2Clicked = function () end,
    autoCloseTime = 3,
    hasCloseIcon = false,
}
--]]
function MessageTipsBox:initData(data)
    local onBack, onBackFunc
    if type(data) == 'table' then
        self.data = data
        if type(data.title) == 'string' or type(data.title) == "userdata" then
            self.titleTxt.text = data.title
        end
        if type(data.content) == 'string' or type(data.content) == "userdata" then
            self.contentTxt.text = data.content
        end
        if type(data.button1Text) == "string" or type(data.button1Text) == "userdata" then
            self.onButton1Clicked = data.onButton1Clicked
            self.cancelTxt.text = data.button1Text
            onBack = true
            onBackFunc = self.onButton1Clicked
        else
            self.cancelBtn.gameObject:SetActive(false)
        end
        if type(data.button2Text) == "string" or type(data.button2Text) == "userdata" then
            self.onButton2Clicked = data.onButton2Clicked
            self.confirmTxt.text = data.button2Text
            if not onBack then
                onBack = true
                onBackFunc = self.onButton2Clicked
            else
                onBack = false
            end
        else
            self.confirmBtn.gameObject:SetActive(false)
        end
        if data.hideCloseIcon then
            self.closeBtn.gameObject:SetActive(false)
        end
        -- 提示信息（至少一个）
        if type(data.tip1) == "string" or type(data.tip1) == "userdata" then
            self.tip1Txt.text = data.tip1
        end
        local hasTip2 = type(data.tip2) == "string" or type(data.tip2) == "userdata"
        if hasTip2 then
            self.tip2Txt.text = data.tip2
        end
        self.tip2Go:SetActive(hasTip2)
        local hasTip3 = type(data.tip3) == "string" or type(data.tip3) == "userdata"
        if hasTip3 then
            self.tip3Txt.text = data.tip3
        end
        self.tip3Go:SetActive(hasTip3)
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

function MessageTipsBox:Close(callback)
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
        if type(callback) == "function" then
            callback()
        end
    end)
end

function MessageTipsBox:start()
    self.cancelBtn:regOnButtonClick(function (eventData)
        self:Close(function()
            if type(self.onButton1Clicked) == "function" then
                self.onButton1Clicked()
            end
        end)
    end)
    self.confirmBtn:regOnButtonClick(function (eventData)
        self:Close(function()
            if type(self.onButton2Clicked) == "function" then
                self.onButton2Clicked()
            end
        end)
    end)
    self.closeBtn:regOnButtonClick(function (eventData)
        self:Close()
    end)

    DialogAnimation.Appear(self.transform, self.canvasGroup)
    UISoundManager.play('promptWindow', 1)
end

return MessageTipsBox
