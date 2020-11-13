local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local GuildMistSettlementItemView = class(unity.base)

function GuildMistSettlementItemView:ctor()
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

function GuildMistSettlementItemView:start()
    self.clickArea:regOnButtonClick(function()
        if type(self.ItemClickFunc) == "function" then
            self.ItemClickFunc()
        end
    end)
end

function GuildMistSettlementItemView:InitView(model)
    self.model = model
    local atkData = self.model:GetAtkData()
    local defData = self.model:GetDefData()
    local atkGuildInfo = self.model:GetGuildInfo(atkData.defGid)
    local defGuildInfo = self.model:GetGuildInfo(defData.atkGid)

    self.round.text = lang.transstr("guildwar_round", lang.transstr("number_" .. model:GetIndex()))
    self.atkLogo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. atkGuildInfo.eid)
    self.atkName.text = atkGuildInfo.name
    self.defLogo.sprite = AssetFinder.GetGuildIcon("GuildLogo" .. defGuildInfo.eid)
    self.defName.text = defGuildInfo.name
    GameObjectHelper.FastSetActive(self.atkWin.gameObject, false)
    GameObjectHelper.FastSetActive(self.atkLose.gameObject, false)
    GameObjectHelper.FastSetActive(self.defWin.gameObject, false)
    GameObjectHelper.FastSetActive(self.defLose.gameObject, false)
    self:RefreshSpreadArrow(model:GetIsSpread())
end

function GuildMistSettlementItemView:RefreshSpreadArrow(isSpread)
    GameObjectHelper.FastSetActive(self.upArrow.gameObject, isSpread == true)
    GameObjectHelper.FastSetActive(self.downArrow.gameObject, isSpread ~= true)
end

function GuildMistSettlementItemView:onDestroy()
end

return GuildMistSettlementItemView
