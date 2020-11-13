local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildWarRoundSettlementView = class(unity.base)

function GuildWarRoundSettlementView:ctor()
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

function GuildWarRoundSettlementView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:Close()
    end)
    self.btnNext:regOnButtonClick(function()
        if type(self.OnBtnNextClick) == "function" then
            self.OnBtnNextClick()
        end
    end)
end

function GuildWarRoundSettlementView:InitAttackView(model)
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
    self.seizeText.text = lang.transstr("guildwar_allSeize", atkData.seizeCnt)
    self.captureText.text = lang.transstr("guildwar_allCapture", atkData.captureCnt)
    self.guildItemName1.color = Color(255/255.0, 246/255.0, 161/255.0)
    self.guildItemName2.color = Color(1, 1, 1)
    if atkData.atkBuff then
        self.buff1:SetActive(true)
        self.buff1.val.text = lang.transstr("guildwar_atkBuff", string.sub(atkData.atkBuff, -2))
    else
        self.buff1:SetActive(false)
    end
    if atkData.defBuff then
        self.buff2:SetActive(true)
        self.buff2.val.text = lang.transstr("guildwar_defBuff", string.sub(atkData.defBuff, -2))
    else
        self.buff2:SetActive(false)
    end
    self.win:SetActive(atkData.ret > 0)
    self.lose:SetActive(atkData.ret <= 0)
    self.btnConfirm.gameObject:SetActive(false)
    self.btnNext.gameObject:SetActive(true)
    self.atkColor:SetActive(true)
    self.defColor:SetActive(false)
end

function GuildWarRoundSettlementView:InitDefenceView(model)
    self.model = model
    local defData = self.model:GetDefData()
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
    self.seizeText.text = lang.transstr("guildwar_beSeize", defData.seizeCnt)
    self.captureText.text = lang.transstr("guildwar_beCapture", defData.captureCnt)
    self.guildItemName1.color = Color(1, 1, 1)
    self.guildItemName2.color = Color(255/255.0, 246/255.0, 161/255.0)

    if defData.atkBuff then
        self.buff1:SetActive(true)
        self.buff1.val.text = lang.transstr("guildwar_atkBuff", string.sub(defData.atkBuff, -2))
    else
        self.buff1:SetActive(false)
    end
    if defData.defBuff then
        self.buff2:SetActive(true)
        self.buff2.val.text = lang.transstr("guildwar_defBuff", string.sub(defData.defBuff, -2))
    else
        self.buff2:SetActive(false)
    end
    self.win:SetActive(defData.ret <= 0)
    self.lose:SetActive(defData.ret > 0)
    self.btnConfirm.gameObject:SetActive(true)
    self.btnNext.gameObject:SetActive(false)
    self.atkColor:SetActive(false)
    self.defColor:SetActive(true)
end

function GuildWarRoundSettlementView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GuildWarRoundSettlementView
