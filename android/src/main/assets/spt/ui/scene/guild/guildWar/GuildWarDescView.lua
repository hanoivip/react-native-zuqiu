local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildWar = require("data.GuildWar")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")
local GuildWarDescView = class(unity.base)

function GuildWarDescView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.flowContent = self.___ex.flowContent
    self.rewardContent = self.___ex.rewardContent
    self.selfRewardContent = self.___ex.selfRewardContent
    self.playDescContent = self.___ex.playDescContent
    self.selfRewardParentTrans = self.___ex.selfRewardParentTrans
    self.closeBtn = self.___ex.closeBtn
    self.helpBtn = self.___ex.helpBtn
    self.parentRect = self.___ex.parentRect

    DialogAnimation.Appear(self.transform, nil)
end

function GuildWarDescView:InitView(state, round)
    self:RegOnBtn()
    self:InitHighlightState(state, round)
    self:InitRewardData()
end

function GuildWarDescView:InitHighlightState(state, round)
    local status = "none"
    if state == GUILDWAR_STATE.NOTSIGN then
        status = "first"
    elseif state == GUILDWAR_STATE.GROUPING or state == GUILDWAR_STATE.PREPARE or state == GUILDWAR_STATE.SIGNED then
        status = "second"
    elseif state == GUILDWAR_STATE.FIGHTING then
        if tonumber(round) == 1 then
            status = "third"
        elseif tonumber(round) == 2 then
            status = "forth"
        elseif tonumber(round) == 3 then
            status = "fifth"
        elseif tonumber(round) == 4 then
            status = "sixth"
        elseif tonumber(round) == 5 then
            status = "seventh"
        elseif tonumber(round) == 6 then
            status = "eighth"
        end
    end
    for k, v in pairs(self.___ex.light) do
        if k == tostring(status) then
            for k1, v1 in pairs(v) do
                GameObjectHelper.FastSetActive(v1, true)
            end
        else
            for k1, v1 in pairs(v) do
                GameObjectHelper.FastSetActive(v1, false)
            end
        end
    end
end

function GuildWarDescView:InitRewardData()
    local rewardItemPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/SelfRewardItem.prefab"
    local rewardIdTable = {}
    for i, v in pairs(GuildWar) do
        if v.type == GuildWarType.Common then
            local t = clone(v)
            t.id = i
            table.insert(rewardIdTable, t)
        end
    end
    table.sort(rewardIdTable, function(a, b) return a.id < b.id end)
    for i,v in ipairs(rewardIdTable) do
        local obj, spt = res.Instantiate(rewardItemPath)
        spt:InitView(v, self.selfRewardParentTrans, self.parentRect)
    end
end

function GuildWarDescView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.helpBtn:regOnButtonClick(function ()
        res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWarDescBoard.prefab", "camera", true, true)
    end)
end

function GuildWarDescView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function GuildWarDescView:InitFlowDescView()
    self.menuGroup:selectMenuItem("flow")
    GameObjectHelper.FastSetActive(self.flowContent, true)
    GameObjectHelper.FastSetActive(self.rewardContent, false)
    GameObjectHelper.FastSetActive(self.selfRewardContent, false)
    GameObjectHelper.FastSetActive(self.playDescContent, false)
end

function GuildWarDescView:InitRewardDescView()
    self.menuGroup:selectMenuItem("reward")
    GameObjectHelper.FastSetActive(self.flowContent, false)
    GameObjectHelper.FastSetActive(self.rewardContent, true)
    GameObjectHelper.FastSetActive(self.selfRewardContent, false)
    GameObjectHelper.FastSetActive(self.playDescContent, false)
end

function GuildWarDescView:InitSelfRewardDescView()
    self.menuGroup:selectMenuItem("selfReward")
    GameObjectHelper.FastSetActive(self.flowContent, false)
    GameObjectHelper.FastSetActive(self.rewardContent, false)
    GameObjectHelper.FastSetActive(self.selfRewardContent, true)
    GameObjectHelper.FastSetActive(self.playDescContent, false)
end

function GuildWarDescView:InitPlayDescView()
    self.menuGroup:selectMenuItem("playDesc")
    GameObjectHelper.FastSetActive(self.flowContent, false)
    GameObjectHelper.FastSetActive(self.rewardContent, false)
    GameObjectHelper.FastSetActive(self.selfRewardContent, false)
    GameObjectHelper.FastSetActive(self.playDescContent, true)
end

function GuildWarDescView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildWarDescView