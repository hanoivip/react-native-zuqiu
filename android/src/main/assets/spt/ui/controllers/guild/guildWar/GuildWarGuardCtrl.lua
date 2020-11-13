local GuildWarGuardCtrl = class()
local GuildWarGuardModel = require("ui.models.guild.guildWar.GuildWarGuardModel")

function GuildWarGuardCtrl:ctor()
    self.guildWarGuardModel = GuildWarGuardModel.new()
end

function GuildWarGuardCtrl:Init(view, itemClickFunc, ctrl)
    self:AddEventSystem()
    self.view = view
    self.view.GuardItemClick = function(index)
        itemClickFunc(ctrl, index)
    end
end

function GuildWarGuardCtrl:HideGuardPosition()
    self.view:HideGuardPosition()
end

function GuildWarGuardCtrl:PlayPosSeizeAnim()
    self.view:PlayPosSeizeAnim()
end

function GuildWarGuardCtrl:SetGuardPosition()
    self.view:SetGuardPosition(self.guildWarGuardModel)
end

function GuildWarGuardCtrl:AddEventSystem()
    EventSystem.AddEvent("GuildWarGuardModel_RefreshGuardPosition", self, self.SetGuardPosition)
    EventSystem.AddEvent("GuildWarGuardPos_Turned", self, self.PlayPosSeizeAnim)
end

function GuildWarGuardCtrl:RemoveEventSystem()
    EventSystem.RemoveEvent("GuildWarGuardModel_RefreshGuardPosition", self, self.SetGuardPosition)
    EventSystem.RemoveEvent("GuildWarGuardPos_Turned", self, self.PlayPosSeizeAnim)
end

return GuildWarGuardCtrl