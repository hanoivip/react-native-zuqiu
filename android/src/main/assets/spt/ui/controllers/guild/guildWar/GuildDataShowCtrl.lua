local GuildDataShowModel = require("ui.models.guild.guildWar.GuildDataShowModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local GuildDataShowCtrl = class(BaseCtrl, "GuildDataShowCtrl")

GuildDataShowCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildDataShow.prefab"

GuildDataShowCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildDataShowCtrl:Init(attackOrDefenseModel, data)
    local guildDataShowModel = GuildDataShowModel.new()
    guildDataShowModel:InitWithProtocol(data)
    self.view:InitView(guildDataShowModel, attackOrDefenseModel)
    self:RegOnMenuGroup()
end

function GuildDataShowCtrl:RegOnMenuGroup()
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

function GuildDataShowCtrl:Refresh()
    GuildDataShowCtrl.super.Refresh(self)
    local tag = GuildDataShowModel.MenuTags.GUILDWARRANK
    self:SwitchMenu(tag)
end

function GuildDataShowCtrl:SwitchMenu(tag)
    if tag == GuildDataShowModel.MenuTags.GUILDWAR then
        self.view:InitGuildWarView()
    elseif tag == GuildDataShowModel.MenuTags.MYWAR then
        self.view:InitMyWarView()
    elseif tag == GuildDataShowModel.MenuTags.GUILDWARRANK then
        self.view:InitRankView()
    end
end

return GuildDataShowCtrl