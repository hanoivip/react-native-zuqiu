local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AssetFinder = require("ui.common.AssetFinder")

local GuildSettingView = class(unity.base)

function GuildSettingView:ctor()
    self.close = self.___ex.close
    self.scrollerView = self.___ex.scrollerView
    self.nameInput = self.___ex.nameInput
    self.iconImg = self.___ex.iconImg
    self.iconClick = self.___ex.iconClick
    self.noticeInput = self.___ex.noticeInput
    self.reqTypeText = self.___ex.reqTypeText
    self.reqTypeLeftBtn = self.___ex.reqTypeLeftBtn
    self.reqTypeRightBtn = self.___ex.reqTypeRightBtn
    self.inviteTypeLeftBtn = self.___ex.inviteTypeLeftBtn
    self.inviteTypeRightBtn = self.___ex.inviteTypeRightBtn
    self.inviteTypeText = self.___ex.inviteTypeText
    self.reqLevelText = self.___ex.reqLevelText
    self.reqLevelLeftBtn = self.___ex.reqLevelLeftBtn
    self.reqLevelRightBtn = self.___ex.reqLevelRightBtn
    self.logoArea = self.___ex.logoArea
    self.btnComfirm = self.___ex.btnComfirm
    self.btnCancel = self.___ex.btnCancel
    self.reqTypeLeftBtnIcon = self.___ex.reqTypeLeftBtnIcon
    self.reqTypeRightBtnIcon = self.___ex.reqTypeRightBtnIcon
    self.inviteTypeLeftBtnIcon = self.___ex.inviteTypeLeftBtnIcon
    self.inviteTypeRightBtnIcon = self.___ex.inviteTypeRightBtnIcon
    self.reqLevelLeftBtnIcon = self.___ex.reqLevelLeftBtnIcon
    self.reqLevelRightBtnIcon = self.___ex.reqLevelRightBtnIcon
    self.btnSetting = self.___ex.btnSetting
    self.btnChangeName = self.___ex.btnChangeName
    self.animator = self.___ex.animator
    self.buttonSetting = self.___ex.buttonSetting
end


function GuildSettingView:start()
    DialogAnimation.Appear(self.transform)

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

    self.btnSetting:regOnButtonClick(function() 
        if type(self.onBtnSettingClick) == "function" and self.buttonSetting.interactable then
            self.onBtnSettingClick()
        end
    end)

    self.reqTypeLeftBtn:regOnButtonClick(function()
        if type(self.onBtnChooseLeftType) == "function" then
            self.onBtnChooseLeftType()
        end
    end)

    self.reqTypeRightBtn:regOnButtonClick(function()
        if type(self.onBtnChooseRightType) == "function" then
            self.onBtnChooseRightType()
        end
    end)

    self.inviteTypeLeftBtn:regOnButtonClick(function()
        if type(self.isInvitationNewPlayer) == "function" then
            self.isInvitationNewPlayer(true)
        end
    end)

    self.inviteTypeRightBtn:regOnButtonClick(function()
        if type(self.isInvitationNewPlayer) == "function" then
            self.isInvitationNewPlayer(false)
        end
    end)
    self.btnChangeName:regOnButtonClick(function()
        if type(self.onBtnChangeNameClick) == "function" then
            self.onBtnChangeNameClick()
        end
    end)

    self.noticeInput.onValueChanged:AddListener(function(value)
        if type(self.onNoticeInputValueChanged) == "function" then
            self.onNoticeInputValueChanged(value)
        end
    end)

    local pressAddData = {
        acceleration = 1,
        clickCallback = function()
            self:AddRequestLevel()
        end,
        durationCallback = function(count)
            self:AddRequestLevel()
        end,
    }

    local pressMinusData = {
        acceleration = 1,
        clickCallback = function()
            self:MinusRequestLevel()
        end,
        durationCallback = function(count)
            self:MinusRequestLevel()
        end,
    }

    self.reqLevelLeftBtn:regOnButtonPressing(pressMinusData)
    self.reqLevelRightBtn:regOnButtonPressing(pressAddData)
end

function GuildSettingView:PlayShowAnimation()
    self.animator:Play("GuildSetting")
end

function GuildSettingView:PlayLeaveAnimation()
    self.animator:Play("GuildSettingLeave")
end

function GuildSettingView:SetReqBtnIcon(btnIcon, isgrey)
    if isgrey then
        btnIcon.color = Color(100/255.0, 100/255.0, 100/255.0)
    else
        btnIcon.color = Color(1, 1, 1)
    end
end

function GuildSettingView:InitGuildName(text)
    self.nameInput.text = text
end

function GuildSettingView:InitGuildNotice(text)
    self.noticeInput.text = text
end

function GuildSettingView:GetNameText()
    return self.nameInput.text
end

function GuildSettingView:GetNoticeText()
    return self.noticeInput.text
end

function GuildSettingView:SetReqLevelText(text)
    self.reqLevelText.text = text
end

function GuildSettingView:SetReqTypeText(text)
    self.reqTypeText.text = text
end

function GuildSettingView:SetInviteTypeText(text)
    self.inviteTypeText.text = text
end

function GuildSettingView:InitIconImg(index)
    self.iconImg.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. index)
end

function GuildSettingView:InitScrollerView(data)
    self:SetLogoAreaState(true)
    self.scrollerView:InitView(data)
end

function GuildSettingView:ClearScrollerView()
    self.scrollerView:Clear()
end

function GuildSettingView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function GuildSettingView:SetLogoAreaState(state)
    self.logoArea:SetActive(state)
end

function GuildSettingView:SetSettingButtonState(state)
    self.buttonSetting.interactable = state
end

return GuildSettingView
