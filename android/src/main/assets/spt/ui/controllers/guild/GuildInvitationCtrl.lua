local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildInvitationModel = require("ui.models.guild.GuildInvitationModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildInvitationCtrl = class(BaseCtrl)


GuildInvitationCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildInvatationBoard.prefab"

GuildInvitationCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildInvitationCtrl:Init(data)
    self.guildInvitationModel = GuildInvitationModel.new()
    self.guildInvitationModel:InitWithProtrol(data)
    self.view.clickReceive = function(itemData) self:Receive(itemData) end
    self.view:InitView(self.guildInvitationModel:GetItemListData())
end

function GuildInvitationCtrl:Refresh()
end

function GuildInvitationCtrl:Receive(itemData)
    clr.coroutine(function()
        local respone = req.sendGuildRequest(itemData.gid)
        if api.success(respone) then
            local data = respone.val
            local isAuto = tonumber(itemData.requestAcceptType) == 1
            if isAuto then
                local respone2 = req.guildIndex()
                if api.success(respone2) then
                    local data2 = respone2.val
                    if data2.base.isExsit == true then
                        res.PushScene("ui.controllers.guild.GuildHomeCtrl", data2) 
                    end
                end
            else
                DialogManager.ShowToastByLang("guild_joinSuccess")
            end
        end
    end)
end

return GuildInvitationCtrl