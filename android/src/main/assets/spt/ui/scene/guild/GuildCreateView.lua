local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AssetFinder = require("ui.common.AssetFinder")

local GuildCreateView = class(unity.base)

function GuildCreateView:ctor()
    self.createBtn = self.___ex.createBtn
    self.iconImg = self.___ex.iconImg
    self.inputField = self.___ex.inputField
    self.close = self.___ex.close
    self.iconClick = self.___ex.iconClick
    self.logoArea = self.___ex.logoArea
    self.scrollerView = self.___ex.scrollerView
    self.btnCancel = self.___ex.btnCancel
    self.btnComfirm = self.___ex.btnComfirm
    self.animator = self.___ex.animator
end

function GuildCreateView:start()
    DialogAnimation.Appear(self.transform)
    self.createBtn:regOnButtonClick(function() 
        if type(self.createGuildFunc) == "function" then
            self.createGuildFunc()
        end
    end)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.iconClick:regOnButtonClick(function()
        if type(self.chooseIconFunc) == "function" then
            self.chooseIconFunc()
        end 
    end)
    self.btnCancel:regOnButtonClick(function()
        if type(self.onBtnCancelClick) == "function" then
            self.onBtnCancelClick()
        end
    end)
    self.btnComfirm:regOnButtonClick(function()
        if type(self.onBtnComfirmClick) == "function" then
            self.onBtnComfirmClick()
        end
    end)
end

function GuildCreateView:PlayShowAnimation()
    self.animator:Play("GuildCreate")
end

function GuildCreateView:PlayLeaveAnimation()
    self.animator:Play("GuildCreateLeave")
end

function GuildCreateView:GetInputText()
    return self.inputField.text
end

function GuildCreateView:InitIconImg(index)
    self.iconImg.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. index)
end

function GuildCreateView:InitScrollerView(data)
    self:SetLogoAreaState(true)
    self.scrollerView:InitView(data)
end

function GuildCreateView:SetLogoAreaState(state)
    self.logoArea:SetActive(state)
end

function GuildCreateView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GuildCreateView
