local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")

local GuildSettlementItemView = class(unity.base)

function GuildSettlementItemView:ctor()
    self.upArrow = self.___ex.upArrow
    self.downArrow = self.___ex.downArrow
    self.clickArea = self.___ex.clickArea
    self.round = self.___ex.round
    self.atkLogo = self.___ex.atkLogo
    self.atkName = self.___ex.atkName
    self.atkWin = self.___ex.atkWin
    self.atkLose = self.___ex.atkLose
    self.defLogo = self.___ex.defLogo
    self.defName = self.___ex.defName
    self.defWin = self.___ex.defWin
    self.defLose = self.___ex.defLose
end

function GuildSettlementItemView:start()
    self.clickArea:regOnButtonClick(function()
        if type(self.ItemClickFunc) == "function" then
            self.ItemClickFunc()
        end
    end)
end

function GuildSettlementItemView:InitView(model)
    self.model = model
    local atkData = self.model:GetAtkData()
    local defData = self.model:GetDefData()
    local atkGuildInfo = self.model:GetGuildInfo(atkData.defGid)
    local defGuildInfo = self.model:GetGuildInfo(defData.atkGid)

    self.round.text = lang.transstr("guildwar_round", lang.transstr("number_" .. model:GetIndex()))
    self.atkLogo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. atkGuildInfo.eid)
    self.atkName.text = atkGuildInfo.name
    self.atkWin:SetActive(atkData.ret > 0)
    self.atkLose:SetActive(atkData.ret <= 0)
    self.defLogo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. defGuildInfo.eid)
    self.defName.text = defGuildInfo.name
    self.defWin:SetActive(defData.ret <= 0)
    self.defLose:SetActive(defData.ret > 0)
    self:RefreshSpreadArrow(model:GetIsSpread())
end

function GuildSettlementItemView:RefreshSpreadArrow(isspread)
    if isspread == true then
        self.upArrow:SetActive(true)
        self.downArrow:SetActive(false)
    else
        self.upArrow:SetActive(false)
        self.downArrow:SetActive(true)
    end
    
end

function GuildSettlementItemView:onDestroy()
end

return GuildSettlementItemView
