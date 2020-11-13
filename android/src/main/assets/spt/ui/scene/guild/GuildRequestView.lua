local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildRequestView = class(unity.base)

function GuildRequestView:ctor()
    self.close = self.___ex.close
    self.scrollerView = self.___ex.scrollerView
end


function GuildRequestView:start()
    DialogAnimation.Appear(self.transform)

    self.close:regOnButtonClick(function()
        self:Close()
    end)

    self.scrollerView.onBtnComfirmClick = function(pid)
        if type(self.onItemComfirmClick) == "function" then
            self.onItemComfirmClick(pid)
        end
    end

    self.scrollerView.onBtnCancelClick = function(pid)
        if type(self.onItemCancelClick) == "function" then
            self.onItemCancelClick(pid)
        end
    end
end

function GuildRequestView:InitView(data)
    self.scrollerView:InitView(data)
end

function GuildRequestView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GuildRequestView