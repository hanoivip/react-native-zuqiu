local GuildWar = require("data.GuildWar")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local AssetFinder = require("ui.common.AssetFinder")

local GuildMistWarMyDataView = class(unity.base)

function GuildMistWarMyDataView:ctor()
    self.scrollerView1 = self.___ex.scrollerView1
    self.scrollerView2 = self.___ex.scrollerView2
    self.close = self.___ex.close
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.content = self.___ex.content
    self.btnDate1 = self.___ex.btnDate1
    self.btnDate2 = self.___ex.btnDate2
    self.btnDate1Text1 = self.___ex.btnDate1Text1
    self.btnDate1Text2 = self.___ex.btnDate1Text2
    self.btnDate2Text1 = self.___ex.btnDate2Text1
    self.btnDate2Text2 = self.___ex.btnDate2Text2
    self.guildLogo = self.___ex.guildLogo
    self.guildName = self.___ex.guildName
    self.rankText = self.___ex.rankText
    self.rewardText = self.___ex.rewardText
    self.titleText = self.___ex.titleText
    self.tipText = self.___ex.tipText
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.third = self.___ex.third
    self.rankList = {self.first, self.second, self.third}
    self.normal = self.___ex.normal
    self.content1 = self.___ex.content1
    self.content2 = self.___ex.content2
end

function GuildMistWarMyDataView:start()
    DialogAnimation.Appear(self.transform)
    self.close:regOnButtonClick(function()
        self:Close()
    end)

    local menu = self.menuButtonGroup.menu
    for k, v in pairs(menu) do
        local i = tonumber(string.sub(k, 5, 5))
        v:regOnButtonClick(function()
            self:OnMenuTypeClick(i)
        end)
    end

    self.menuButtonGroup.gameObject:SetActive(false)
    self.content:SetActive(false)
end

function GuildMistWarMyDataView:OnMenuTypeClick(index)
    if type(self.onMenuItemClick) == "function" then
        self.onMenuItemClick(index)
    end
end

function GuildMistWarMyDataView:SwitchMenu(index)
    self.menuButtonGroup:selectMenuItem("date" .. index)
end

function GuildMistWarMyDataView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

local MaxChallengeLevel = 7
function GuildMistWarMyDataView:InitView(model)
    local index = model:GetCurrentDate()
    local data = model:GetData()
    if #data.list <= 0 then return end            
    local guildInfo = model:GetGuildInfoByGid(index, PlayerInfoModel.new():GetGuild().gid)
    local rank = data.list[index].reward.rank
    local level = data.list[index].level

    self.menuButtonGroup.gameObject:SetActive(true)
    self.content:SetActive(true)
    if #data.list < 2 then
        self.btnDate2:SetActive(false)
        self.btnDate1Text1.text = lang.transstr("guildwar_period2", data.list[1].period) 
        self.btnDate1Text2.text = lang.transstr("guildwar_period2", data.list[1].period)
    else
        self.btnDate1Text1.text = lang.transstr("guildwar_period2", data.list[1].period) 
        self.btnDate1Text2.text = lang.transstr("guildwar_period2", data.list[1].period)
        self.btnDate2Text1.text = lang.transstr("guildwar_period2", data.list[2].period) 
        self.btnDate2Text2.text = lang.transstr("guildwar_period2", data.list[2].period)
    end

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

    local minLevel = GuildWar[tostring(level)].minLevel

    self.guildName.text = guildInfo.name
    self.tipText.text = lang.transstr("guildwar_rewardText", math.min(level, MaxChallengeLevel))
    self.guildLogo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. guildInfo.eid)
    self.rankText.text = lang.transstr("guildwar_rank", lang.transstr("number_" .. rank))
    self.titleText.text = lang.transstr("mist_period3", data.list[index].period, lang.transstr("number_" .. minLevel))
    self.rewardText.text = lang.transstr("guildwar_rewardDate" .. rank)

    if index == 1 then
        self.content1:SetActive(true)
        self.content2:SetActive(false)
        self.scrollerView1:InitView(model:GetScheduleList(index))
    else
        self.content1:SetActive(false)
        self.content2:SetActive(true)
        self.scrollerView2:InitView(model:GetScheduleList(index))
    end
    self:SwitchMenu(index)
end

return GuildMistWarMyDataView
