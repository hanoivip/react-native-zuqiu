local GuildWar = require("data.GuildWar")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")
local GuildMistWarDescView = class(unity.base)

function GuildMistWarDescView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.flowContent = self.___ex.flowContent
    self.rewardContent = self.___ex.rewardContent
    self.selfRewardContent = self.___ex.selfRewardContent
    self.playDescContent = self.___ex.playDescContent
    self.selfRewardParentTrans = self.___ex.selfRewardParentTrans
    self.closeBtn = self.___ex.closeBtn
    self.helpBtn = self.___ex.helpBtn
    self.parentRect = self.___ex.parentRect
    self.playRankContent = self.___ex.playRankContent
    DialogAnimation.Appear(self.transform, nil)
end

function GuildMistWarDescView:InitView(state, round)
    self:RegOnBtn()
    self:InitHighlightState(state, round)
    self:InitRewardData()
end

function GuildMistWarDescView:InitHighlightState(state, round)
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

function GuildMistWarDescView:InitRewardData()
    local rewardItemPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/SelfRewardItem.prefab"
    local rewardIdTable = {}
    for i, v in pairs(GuildWar) do
        if v.type == GuildWarType.Mist then
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

function GuildMistWarDescView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.helpBtn:regOnButtonClick(function()
        local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarDescBoard.prefab"
        local resDlg, dialogcomp = res.ShowDialog(prefabPath, "camera", true, true)
        local title = lang.trans("untranslated_2533")
        local content = lang.trans("mist_rule4")
        dialogcomp.contentcomp:InitView(title, content)
    end)
end

function GuildMistWarDescView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function GuildMistWarDescView:InitFlowDescView()
    self.menuGroup:selectMenuItem("flow")
    self:ShowPage("flow")
end

function GuildMistWarDescView:InitRewardDescView()
    self.menuGroup:selectMenuItem("reward")
    self:ShowPage("reward")
end

function GuildMistWarDescView:InitSelfRewardDescView()
    self.menuGroup:selectMenuItem("selfReward")
    self:ShowPage("selfReward")
end

function GuildMistWarDescView:InitPlayDescView()
    self.menuGroup:selectMenuItem("playDesc")
    self:ShowPage("playDesc")
end

function GuildMistWarDescView:InitRankRuleView()
    self.menuGroup:selectMenuItem("rankRule")
    self:ShowPage("rankRule")
end

function GuildMistWarDescView:ShowPage(tag)
    GameObjectHelper.FastSetActive(self.flowContent, tag == "flow")
    GameObjectHelper.FastSetActive(self.rewardContent, tag == "reward")
    GameObjectHelper.FastSetActive(self.selfRewardContent, tag == "selfReward")
    GameObjectHelper.FastSetActive(self.playDescContent, tag == "playDesc")
    GameObjectHelper.FastSetActive(self.playRankContent, tag == "rankRule")
end

function GuildMistWarDescView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildMistWarDescView
