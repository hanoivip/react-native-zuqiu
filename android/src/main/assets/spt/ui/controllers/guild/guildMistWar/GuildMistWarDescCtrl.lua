local BaseCtrl = require("ui.controllers.BaseCtrl")

local GuildMistWarDescCtrl = class(BaseCtrl, "GuildMistWarDescCtrl")

GuildMistWarDescCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarDesc.prefab"

GuildMistWarDescCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildMistWarDescCtrl:Init(state, round)
    self.view:InitView(state, round)

    self.view:RegOnMenuGroup("flow", function ()
        self:SwitchMenu("flow")
    end)

    self.view:RegOnMenuGroup("reward", function ()
        self:SwitchMenu("reward")
    end)

    self.view:RegOnMenuGroup("selfReward", function ()
        self:SwitchMenu("selfReward")
    end)

    self.view:RegOnMenuGroup("playDesc", function ()
        self:SwitchMenu("playDesc")
    end)

    self.view:RegOnMenuGroup("rankRule", function ()
        self:SwitchMenu("rankRule")
    end)
end

function GuildMistWarDescCtrl:Refresh()
    GuildMistWarDescCtrl.super.Refresh(self)
    self:SwitchMenu("selfReward")
end

function GuildMistWarDescCtrl:SwitchMenu(tag)
    if tag == "flow" then
        self.view:InitFlowDescView()
    elseif tag == "reward" then
        self.view:InitRewardDescView()
    elseif tag == "selfReward" then
        self.view:InitSelfRewardDescView()
    elseif tag == "playDesc" then
        self.view:InitPlayDescView()
    elseif tag == "rankRule" then
        self.view:InitRankRuleView()
    end
end

return GuildMistWarDescCtrl
