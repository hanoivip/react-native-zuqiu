local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteArenaRankTabItemView = class(LuaButton, "CompeteArenaRankTabItemView")

function CompeteArenaRankTabItemView:ctor()
    CompeteArenaRankTabItemView.super.ctor(self)
    self.btnUpGo = self.___ex.btnUpGo
    self.btnDownGo = self.___ex.btnDownGo
    self.txtTabUp = self.___ex.txtTabUp
    self.txtTabDown = self.___ex.txtTabDown
    self.isSelect = false
end

function CompeteArenaRankTabItemView:start()
end

function CompeteArenaRankTabItemView:InitView(data, index)
    self:InitButtonState()
    self.data = data
    self.index = index
    self.isSelect = false

    local seasonTag = data.seasonName
    local name = ""
    if index == 1 then 
        name = lang.trans("peak_curSeasonRank")
    else
        name = seasonTag .. lang.transstr("dream_season_rank")
    end

    self.txtTabUp.text = name
    self.txtTabDown.text = name
end

function CompeteArenaRankTabItemView:SetSelect(isSelect)
    if isSelect then
        cache.setSelectedArenaRabkTabID(tostring(self.data.tag))
    end
    self.isSelect = isSelect
    GameObjectHelper.FastSetActive(self.btnUpGo, not isSelect)
    GameObjectHelper.FastSetActive(self.btnDownGo, isSelect)
end

function CompeteArenaRankTabItemView:InitButtonState()
    self:unselectBtn()
    self:onPointEventHandle(true)
end

return CompeteArenaRankTabItemView