local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local TextAnchor = UnityEngine.TextAnchor

local ChatTipDialogView = class(unity.base)

function ChatTipDialogView:ctor()
    self.teamLogo = self.___ex.teamlogo
    self.nameText = self.___ex.nameText
    self.levelText = self.___ex.levelText
    self.ChatBtn = self.___ex.ChatBtn
    self.AddBtn = self.___ex.AddBtn
    self.GuildBtn = self.___ex.GuildBtn
    self.close = self.___ex.close
end

function ChatTipDialogView:start()
    DialogAnimation.Appear(self.transform)
    self.close:regOnButtonClick(function()
        self:Close()
    end)

    self.ChatBtn:regOnButtonClick(function() 
        if type(self.clickChat) == "function" then
            self.clickChat()
        end
    end)

    self.AddBtn:regOnButtonClick(function() 
        if type(self.clickAdd) == "function" then
            self.clickAdd()
        end
    end)

    self.GuildBtn:regOnButtonClick(function() 
        if type(self.clickGuild) == "function" then
            self.clickGuild()
        end
    end)

end

function ChatTipDialogView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function ChatTipDialogView:InitView(chatTipDialogModel)
    self.levelText.text = "Lv" .. chatTipDialogModel:GetLevel()
    self.nameText.text = chatTipDialogModel:GetName()
    local logoTable = chatTipDialogModel:GetTeamLogoInfo()
    TeamLogoCtrl.BuildTeamLogo(self.teamLogo, logoTable)
end

return ChatTipDialogView