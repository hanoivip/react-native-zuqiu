local BaseCtrl = require("ui.controllers.BaseCtrl")
local ChatTipDialogModel = require("ui.models.chat.ChatTipDialogModel")
local DialogManager = require("ui.control.manager.DialogManager")

local UnityEngine = clr.UnityEngine

local ChatTipDialogCtrl = class(BaseCtrl)

ChatTipDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Chat/Prefab/ChatTipDialog.prefab"

function ChatTipDialogCtrl:Init(model)
    self.model = model

    self.view.clickChat = function()
        EventSystem.SendEvent("ChatTipDialog_SideChat", self.model)
        self.view:Close()
    end

    self.view.clickAdd = function()
        clr.coroutine(function()
            local data = { self.model:GetPid() }
            local respone = req.friendsRequest(data)
            if api.success(respone) then
                local data = respone.val
                if data["ok"] then
                    self.view:Close()                    
                    DialogManager.ShowToastByLang("friends_applySendHint")
                end
            end
        end)
    end

    self.view.clickGuild = function()

    end
end

function ChatTipDialogCtrl:Refresh()
    self.view:InitView(self.model)

end



return ChatTipDialogCtrl
