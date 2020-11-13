local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2

local GuildSettlementContentView = class(unity.base)

function GuildSettlementContentView:ctor()
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

function GuildSettlementContentView:start()
end

function GuildSettlementContentView:InitView(model)
    self.model = model
    local atkData = self.model:GetAtkData()
    local defData = self.model:GetDefData()
    local atk1GuildInfo = self.model:GetGuildInfo(atkData.atkGid)
    local atk2GuildInfo = self.model:GetGuildInfo(atkData.defGid)
    local def1GuildInfo = self.model:GetGuildInfo(defData.atkGid)
    local def2GuildInfo = self.model:GetGuildInfo(defData.defGid)

    self.atk1Name.text = atk1GuildInfo.name
    self.atk2Name.text = atk2GuildInfo.name
    self.atkSeizeCnt.text = lang.transstr("guildwar_allSeize", atkData.seizeCnt)
    self.atkCaptureCnt.text = lang.transstr("guildwar_allCapture", atkData.captureCnt)
    if atkData.atkBuff then
        self.atk1Buff:SetActive(true)
        self.atk1Buff.val.text = lang.transstr("guildwar_atkBuff", string.sub(atkData.atkBuff, -2))
    else
        self.atk1Buff:SetActive(false)
    end
    if atkData.defBuff then
        self.atk2Buff:SetActive(true)
        self.atk2Buff.val.text = lang.transstr("guildwar_defBuff", string.sub(atkData.defBuff, -2))
    else
        self.atk2Buff:SetActive(false)
    end
    self.atkWin:SetActive(atkData.ret > 0)
    self.atkLose:SetActive(atkData.ret <= 0)

    self.def1Name.text = def1GuildInfo.name
    self.def2Name.text = def2GuildInfo.name
    self.defSeizeCnt.text = lang.transstr("guildwar_beSeize", defData.seizeCnt)
    self.defCaptureCnt.text = lang.transstr("guildwar_beCapture", defData.captureCnt)
    if defData.atkBuff then
        self.def1Buff:SetActive(true)
        self.def1Buff.val.text = lang.transstr("guildwar_atkBuff", string.sub(defData.atkBuff, -2))
    else
        self.def1Buff:SetActive(false)
    end
    if defData.defBuff then
        self.def2Buff:SetActive(true)
        self.def2Buff.val.text = lang.transstr("guildwar_defBuff", string.sub(defData.defBuff, -2))
    else
        self.def2Buff:SetActive(false)
    end
    self.defWin:SetActive(defData.ret <= 0)
    self.defLose:SetActive(defData.ret > 0)
end

return GuildSettlementContentView
