local GuildAuthority = require("data.GuildAuthority")
local DialogManager = require("ui.control.manager.DialogManager")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildDataShowModel = require("ui.models.guild.guildWar.GuildDataShowModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local GuildMistDataShowCtrl = class(BaseCtrl, "GuildMistDataShowCtrl")

GuildMistDataShowCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistDataShow.prefab"

GuildMistDataShowCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildMistDataShowCtrl:Init(guildMistWarMainModel, data)
    local model = GuildDataShowModel.new()
    model:InitWithProtocol(data)
    self.guildMistWarMainModel = guildMistWarMainModel
    self.model = model
    self:RegOnMenuGroup()

    self.view.changeMapClick = function(itemData) self:OnChanceMap(itemData) end
end

function GuildMistDataShowCtrl:RegOnMenuGroup()
    self.view:RegOnMenuGroup(GuildDataShowModel.MenuTags.GUILDWAR, function ()
        self:SwitchMenu(GuildDataShowModel.MenuTags.GUILDWAR)
    end)
    self.view:RegOnMenuGroup(GuildDataShowModel.MenuTags.MYWAR, function ()
        self:SwitchMenu(GuildDataShowModel.MenuTags.MYWAR)
    end)
    self.view:RegOnMenuGroup(GuildDataShowModel.MenuTags.GUILDWARRANK, function ()
        self:SwitchMenu(GuildDataShowModel.MenuTags.GUILDWARRANK)
    end)
end

function GuildMistDataShowCtrl:Refresh()
    GuildMistDataShowCtrl.super.Refresh(self)
    local tag = GuildDataShowModel.MenuTags.GUILDWARRANK
    self.view:InitView(self.model, self.guildMistWarMainModel)
    self:SwitchMenu(tag)
end

function GuildMistDataShowCtrl:SwitchMenu(tag)
    if tag == GuildDataShowModel.MenuTags.GUILDWAR then
        self.view:InitGuildWarView()
    elseif tag == GuildDataShowModel.MenuTags.MYWAR then
        self.view:InitMyWarView()
    elseif tag == GuildDataShowModel.MenuTags.GUILDWARRANK then
        self.view:InitRankView()
    end
end

function GuildMistDataShowCtrl:OnChanceMap(itemData)
    local authority = self.guildMistWarMainModel:GetAuthority()
    authority = tostring(authority)
    local authorityState = GuildAuthority[authority].selectMistMap == 1
    if not authorityState then
        DialogManager.ShowToastByLang("mist_authority_none")
        return
    end
    local round = itemData.round
    local state = self.guildMistWarMainModel:GetWarState()
    local currRound = self.guildMistWarMainModel:GetRound()
    if state == GUILDWAR_STATE.PREPARE then
        currRound = 0
    end
    self.view:coroutine(function ()
        local response = req.guildWarGuardsInfoMistByRound(round)
        if api.success(response) then
            local data = response.val
            EventSystem.SendEvent("GuildWarMist_RefreshDefenderMap", data, currRound)
            EventSystem.SendEvent("GuildWarMist_EditorMap", true)
            self.view.closeDialog()
        end
    end)
end

return GuildMistDataShowCtrl
