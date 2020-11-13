local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildRequestModel = require("ui.models.guild.GuildRequestModel")
local UnityEngine = clr.UnityEngine

local GuildRequestCtrl = class(BaseCtrl)

GuildRequestCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildRequest.prefab"

function GuildRequestCtrl:Init()
    self.guildRequestModel = GuildRequestModel.new()

    self.view.onItemComfirmClick = function(pid)
        clr.coroutine(function()
            local respone = req.guildAccept(pid)
            if api.success(respone) then
                local data = respone.val
                if data.ok == 1 then 
                    EventSystem.SendEvent("GuildHome_RefreshMember")
                    self.guildRequestModel:RemoveRequestItem(pid)
                    self:InitView(self.guildRequestModel:GetRequestList())
                end
            end
        end)
    end

    self.view.onItemCancelClick = function(pid)
        clr.coroutine(function()
            local respone = req.guildRefuse(pid)
            if api.success(respone) then
                local data = respone.val
                if data.ok == 1 then
                    self.guildRequestModel:RemoveRequestItem(pid)
                    self:InitView(self.guildRequestModel:GetRequestList())
                end
            end
        end)
    end

end

function GuildRequestCtrl:Refresh()
    GuildRequestCtrl.super.Refresh(self)            
    clr.coroutine(function()
        local respone = req.getRequestList()
        if api.success(respone) then
            local data = respone.val
            self.guildRequestModel:InitWithProtocol(data)
            self:InitView(self.guildRequestModel:GetRequestList())
        end
    end)
end

function GuildRequestCtrl:InitView(data)
    self.view:InitView(data)
end

function GuildRequestCtrl:OnEnterScene()
end

function GuildRequestCtrl:OnExitScene()
end

return GuildRequestCtrl