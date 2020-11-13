local BaseCtrl = require("ui.controllers.BaseCtrl")

local GuildWarDescCtrl = class(BaseCtrl, "GuildWarDescCtrl")

GuildWarDescCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWarDesc.prefab"

GuildWarDescCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildWarDescCtrl:Init(state, round)
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
end

function GuildWarDescCtrl:Refresh()
    GuildWarDescCtrl.super.Refresh(self)
    self:SwitchMenu("selfReward")
end

function GuildWarDescCtrl:SwitchMenu(tag)
    if tag == "flow" then
        self.view:InitFlowDescView()
    elseif tag == "reward" then
        self.view:InitRewardDescView()
    elseif tag == "selfReward" then
        self.view:InitSelfRewardDescView()
    elseif tag == "playDesc" then
        self.view:InitPlayDescView()
    end
end

return GuildWarDescCtrl