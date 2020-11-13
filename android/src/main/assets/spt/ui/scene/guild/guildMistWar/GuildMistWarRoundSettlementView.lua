local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildMistWarRoundSettlementView = class(unity.base)

function GuildMistWarRoundSettlementView:ctor()
    self.guild1Logo = self.___ex.guild1Logo
    self.guild1Name = self.___ex.guild1Name
    self.guild2Logo = self.___ex.guild2Logo
    self.guild2Name = self.___ex.guild2Name
    self.titleText = self.___ex.titleText
    self.dateText = self.___ex.dateText
    self.stateText = self.___ex.stateText
    self.guildItemName1 = self.___ex.guildItemName1
    self.guildItemName2 = self.___ex.guildItemName2
    self.buff1 = self.___ex.buff1
    self.buff2 = self.___ex.buff2
    self.tipText = self.___ex.tipText
    self.seizeText = self.___ex.seizeText
    self.captureText = self.___ex.captureText
    self.btnNext = self.___ex.btnNext
    self.btnConfirm = self.___ex.btnConfirm
    self.win = self.___ex.win
    self.lose = self.___ex.lose
    self.atkColor = self.___ex.atkColor
    self.defColor = self.___ex.defColor
end

function GuildMistWarRoundSettlementView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:Close()
    end)
    self.btnNext:regOnButtonClick(function()
        if type(self.OnBtnNextClick) == "function" then
            self.OnBtnNextClick()
        end
    end)
end

function GuildMistWarRoundSettlementView:InitAttackView(model)
    self.model = model
    local atkData = self.model:GetAtkData()
    local atkGuildInfo = self.model:GetGuildInfo(atkData.atkGid)
    local defGuildInfo = self.model:GetGuildInfo(atkData.defGid)
    local period = self.model:GetPeriod()
    local round = self.model:GetRound()
    local date = self.model:GetDate()
    local month = string.sub(date, 5, 6)
    local day = string.sub(date, 7, 8)

    self.guild1Logo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. atkGuildInfo.eid)
    self.guild1Name.text = atkGuildInfo.name
    self.guild2Logo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. defGuildInfo.eid)
    self.guild2Name.text = defGuildInfo.name
    self.titleText.text = lang.transstr("guildwar_period", period)
    self.dateText.text = lang.transstr("guildwar_round3", lang.transstr("number_" .. round), month, day)
    self.stateText.text = lang.transstr("guildwar_atkState")
    self.guildItemName1.text = atkGuildInfo.name
    self.guildItemName2.text = defGuildInfo.name
    self.tipText.text = lang.trans("mist_settle_atk")

    self.seizeText.text = lang.transstr("mist_attack_score") .. ":" .. atkData.atkScore
    self.captureText.text = lang.transstr("mist_defender_score") .. ":" .. atkData.defScore
    self.guildItemName1.color = Color(255/255.0, 246/255.0, 161/255.0)
    self.guildItemName2.color = Color(1, 1, 1)
    if atkData.atkBuff then
        self.buff1:SetActive(true)
        GameObjectHelper.FastSetActive(self.buff1, true)
        self.buff1.val.text = lang.transstr("guildwar_atkBuff", string.sub(atkData.atkBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.buff1, false)
    end
    if atkData.defBuff then
        GameObjectHelper.FastSetActive(self.buff2, true)
        self.buff2.val.text = lang.transstr("guildwar_defBuff", string.sub(atkData.defBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.buff2, false)
    end

    GameObjectHelper.FastSetActive(self.win, false)
    GameObjectHelper.FastSetActive(self.lose, false)
    GameObjectHelper.FastSetActive(self.seizeText.gameObject, true)
    GameObjectHelper.FastSetActive(self.captureText.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnConfirm.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnNext.gameObject, true)
    GameObjectHelper.FastSetActive(self.atkColor, true)
    GameObjectHelper.FastSetActive(self.defColor, false)
end

function GuildMistWarRoundSettlementView:InitDefenceView(model)
    self.model = model
    local defData = self.model:GetDefData()
    local atkData = self.model:GetAtkData()
    local atkGuildInfo = self.model:GetGuildInfo(defData.atkGid)
    local defGuildInfo = self.model:GetGuildInfo(defData.defGid)
    local period = self.model:GetPeriod()
    local round = self.model:GetRound()
    local date = self.model:GetDate()
    local month = string.sub(date, 5, 6)
    local day = string.sub(date, 7, 8)

    self.guild1Logo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. defGuildInfo.eid)
    self.guild1Name.text = defGuildInfo.name
    self.guild2Logo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. atkGuildInfo.eid)
    self.guild2Name.text = atkGuildInfo.name
    self.titleText.text = lang.transstr("guildwar_period", period)
    self.dateText.text = lang.transstr("guildwar_round3", lang.transstr("number_" .. round), month, day)
    self.stateText.text = lang.transstr("guildwar_defState")
    self.guildItemName1.text = atkGuildInfo.name
    self.guildItemName2.text = defGuildInfo.name
    self.seizeText.text = lang.transstr("mist_attack_score") .. ":" .. defData.atkScore
    self.captureText.text = lang.transstr("mist_defender_score") .. ":" .. atkData.defScore
    self.guildItemName1.color = Color(1, 1, 1)
    self.guildItemName2.color = Color(255/255.0, 246/255.0, 161/255.0)
    self.tipText.text = lang.trans("mist_settle_def")

    if defData.atkBuff then
        GameObjectHelper.FastSetActive(self.buff1, true)
        self.buff1.val.text = lang.transstr("guildwar_atkBuff", string.sub(defData.atkBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.buff1, false)
    end
    if defData.defBuff then
        GameObjectHelper.FastSetActive(self.buff2, true)
        self.buff2.val.text = lang.transstr("guildwar_defBuff", string.sub(defData.defBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.buff2, false)
    end

    GameObjectHelper.FastSetActive(self.win, false)
    GameObjectHelper.FastSetActive(self.lose, false)
    GameObjectHelper.FastSetActive(self.seizeText.gameObject, false)
    GameObjectHelper.FastSetActive(self.captureText.gameObject, true)
    GameObjectHelper.FastSetActive(self.btnConfirm.gameObject, true)
    GameObjectHelper.FastSetActive(self.btnNext.gameObject, false)
    GameObjectHelper.FastSetActive(self.atkColor, false)
    GameObjectHelper.FastSetActive(self.defColor, true)
end

function GuildMistWarRoundSettlementView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GuildMistWarRoundSettlementView
