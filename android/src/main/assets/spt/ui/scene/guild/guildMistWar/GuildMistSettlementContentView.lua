local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistSettlementContentView = class(unity.base)

function GuildMistSettlementContentView:ctor()
    self.atk1Name = self.___ex.atk1Name
    self.atk2Name = self.___ex.atk2Name
    self.atkSeizeCnt = self.___ex.atkSeizeCnt
    self.atkCaptureCnt = self.___ex.atkCaptureCnt
    self.atkWin = self.___ex.atkWin
    self.atkLose = self.___ex.atkLose
    self.atk1Buff = self.___ex.atk1Buff
    self.atk2Buff = self.___ex.atk2Buff
    self.def1Name = self.___ex.def1Name
    self.def2Name = self.___ex.def2Name
    self.defSeizeCnt = self.___ex.defSeizeCnt
    self.defCaptureCnt = self.___ex.defCaptureCnt
    self.defWin = self.___ex.defWin
    self.defLose = self.___ex.defLose
    self.def1Buff = self.___ex.def1Buff
    self.def2Buff = self.___ex.def2Buff
end

function GuildMistSettlementContentView:start()
end

function GuildMistSettlementContentView:InitView(model)
    self.model = model
    local atkData = self.model:GetAtkData()
    local defData = self.model:GetDefData()
    local atk1GuildInfo = self.model:GetGuildInfo(atkData.atkGid)
    local atk2GuildInfo = self.model:GetGuildInfo(atkData.defGid)
    local def1GuildInfo = self.model:GetGuildInfo(defData.atkGid)
    local def2GuildInfo = self.model:GetGuildInfo(defData.defGid)
    local atk1AtkScore = atkData.atkScore or 0
    local atk1DefScore = atkData.defScore or 0
    local atk2AtkScore = defData.atkScore or 0
    local atk2DefScore = atkData.defScore or 0

    self.atk1Name.text = atk1GuildInfo.name
    self.atk2Name.text = atk2GuildInfo.name
    self.atkSeizeCnt.text = lang.transstr("mist_attack_score") .. ":" .. atk1AtkScore
    self.atkCaptureCnt.text = lang.transstr("mist_defender_score") .. ":" .. atk1DefScore
    if atkData.atkBuff then
        GameObjectHelper.FastSetActive(self.atk1Buff.gameObject, true)
        self.atk1Buff.val.text = lang.transstr("guildwar_atkBuff", string.sub(atkData.atkBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.atk1Buff.gameObject, false)
    end
    if atkData.defBuff then
        GameObjectHelper.FastSetActive(self.atk2Buff.gameObject, true)
        self.atk2Buff.val.text = lang.transstr("guildwar_defBuff", string.sub(atkData.defBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.atk2Buff.gameObject, false)
    end

    GameObjectHelper.FastSetActive(self.atkWin.gameObject, false)
    GameObjectHelper.FastSetActive(self.atkLose.gameObject, false)

    self.def1Name.text = def1GuildInfo.name
    self.def2Name.text = def2GuildInfo.name
    self.defSeizeCnt.text = lang.transstr("mist_attack_score") .. ":" .. atk2AtkScore
    self.defCaptureCnt.text = lang.transstr("mist_defender_score") .. ":" .. atk2DefScore
    if defData.atkBuff then
        GameObjectHelper.FastSetActive(self.def1Buff.gameObject, true)
        self.def1Buff.val.text = lang.transstr("guildwar_atkBuff", string.sub(defData.atkBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.def1Buff.gameObject, false)
    end
    if defData.defBuff then
        GameObjectHelper.FastSetActive(self.def2Buff.gameObject, true)
        self.def2Buff.val.text = lang.transstr("guildwar_defBuff", string.sub(defData.defBuff, -2))
    else
        GameObjectHelper.FastSetActive(self.def2Buff.gameObject, false)
    end

    GameObjectHelper.FastSetActive(self.defWin.gameObject, false)
    GameObjectHelper.FastSetActive(self.defLose.gameObject, false)
end

return GuildMistSettlementContentView
