local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteArenaRankLabelItemView = class(LuaButton, "CompeteArenaRankLabelItemView")

local AZMAP = require("ui.models.compete.arenaRank.CompeteArenaRankConstants")

function CompeteArenaRankLabelItemView:ctor()
    CompeteArenaRankLabelItemView.super.ctor(self)
    self.btnUpGo = self.___ex.btnUpGo
    self.btnDownGo = self.___ex.btnDownGo
    self.txtLabel = self.___ex.txtLabel
    self.isSelect = false
end

function CompeteArenaRankLabelItemView:start()
end

function CompeteArenaRankLabelItemView:InitView(data)
    self:InitButtonState()
    self.data = data
    self.isSelect = false
    
    if self.data.matchType == "11" and self.data.group ~= 0 then
        self.txtLabel.text = lang.transstr(self.data.nameLoc) .. AZMAP[tostring(self.data.group)]
    else
        self.txtLabel.text = lang.trans(self.data.nameLoc)
    end
end

function CompeteArenaRankLabelItemView:InitButtonState()
    self:unselectBtn()
    self:onPointEventHandle(true)
end

function CompeteArenaRankLabelItemView:SetSelect(isSelect)
    self.isSelect = isSelect
    GameObjectHelper.FastSetActive(self.btnUpGo, not isSelect)
    GameObjectHelper.FastSetActive(self.btnDownGo, isSelect)
end

function CompeteArenaRankLabelItemView:GetMatchType()
    return self.data.matchType
end

return CompeteArenaRankLabelItemView