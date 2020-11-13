local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local AssetFinder = require("ui.common.AssetFinder")

local GuildWarSettlementView = class(unity.base)

function GuildWarSettlementView:ctor()
    self.scrollerView = self.___ex.scrollerView
    self.guildLogo = self.___ex.guildLogo
    self.guildName = self.___ex.guildName
    self.rankText = self.___ex.rankText
    self.rewardText = self.___ex.rewardText
    self.titleText = self.___ex.titleText
    self.tipText = self.___ex.tipText
    self.btnConfirm = self.___ex.btnConfirm
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.third = self.___ex.third
    self.rankList = {self.first, self.second, self.third}
    self.normal = self.___ex.normal
end

function GuildWarSettlementView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:Close()
    end)
end

local MaxChallengeLevel = 7
function GuildWarSettlementView:InitView(model)
    local guildInfo = model:GetGuildInfoByGid(PlayerInfoModel.new():GetGuild().gid)
    local rank = model:GetRank()
    local period = model:GetPeriod()
    local level = model:GetLevel()

    self.guildName.text = guildInfo.name
    self.guildLogo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. guildInfo.eid)
    self.rankText.text = lang.transstr("guildwar_rank", lang.transstr("number_" .. rank))
    self.titleText.text = lang.transstr("guildwar_period3", period, lang.transstr("number_" .. level))
    self.scrollerView:InitView(model:GetScheduleList())
    self.tipText.text = lang.transstr("guildwar_rewardText", math.min(level, MaxChallengeLevel))
    self.rewardText.text = lang.transstr("guildwar_rewardDate" .. rank)
    if rank < 4 then
        for i = 1, 3 do
            if rank == i then
                self.rankList[i]:SetActive(true)
            else
                self.rankList[i]:SetActive(false)
            end
        end
        self.normal.gameObject:SetActive(false)
    else
        for i = 1, 3 do
            self.rankList[i]:SetActive(false)
        end
        self.normal.gameObject:SetActive(true)
        self.normal.text = tostring(rank)
    end
end

function GuildWarSettlementView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GuildWarSettlementView
