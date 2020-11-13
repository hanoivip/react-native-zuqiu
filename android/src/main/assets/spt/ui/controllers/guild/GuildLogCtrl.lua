local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildLogModel = require("ui.models.guild.GuildLogModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GUILD_LOGTYPE = require("ui.controllers.guild.GUILD_LOGTYPE")
local UnityEngine = clr.UnityEngine

local GuildLogCtrl = class(BaseCtrl)

GuildLogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildLog.prefab"

function GuildLogCtrl:Init()
    self.guildLogModel = GuildLogModel.new()

    self.view.clickLogType = function(logType)
        if logType == self.currentLogType then return end
        self.currentLogType = logType
        self:InitView()
    end
end

function GuildLogCtrl:Refresh(logType)
    self.currentLogType = logType    
    GuildLogCtrl.super.Refresh(self)
    clr.coroutine(function()
        local respone = req.GetGuildRecord()
        if api.success(respone) then
            local data = respone.val
            self.guildLogModel:InitWithProtocol(data)
            self:InitView()
        end
    end)
           
end

function GuildLogCtrl:InitView()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.view:InitView(self.guildLogModel, self.currentLogType)
end

function GuildLogCtrl:GetStatusData()
    return self.currentLogType
end

function GuildLogCtrl:OnEnterScene()
end

function GuildLogCtrl:OnExitScene()
end

return GuildLogCtrl