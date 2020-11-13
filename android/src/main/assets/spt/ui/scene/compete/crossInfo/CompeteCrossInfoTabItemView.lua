local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteCrossInfoTabItemView = class(LuaButton, "CompeteCrossInfoTabItemView")

function CompeteCrossInfoTabItemView:ctor()
    CompeteCrossInfoTabItemView.super.ctor(self)
    self.btnUpGo = self.___ex.btnUpGo
    self.btnDownGo = self.___ex.btnDownGo
    self.txtTabUp = self.___ex.txtTabUp
    self.txtTabDown = self.___ex.txtTabDown
    self.isSelect = false
end

function CompeteCrossInfoTabItemView:start()
end

function CompeteCrossInfoTabItemView:InitView(data, index)
    self:InitButtonState()
    self.data = data
    self.index = index
    self.isSelect = false

    local name = ""
    local seasonTag = data.seasonName
    if index == 1 then
        name = lang.trans("peak_curSeasonRank")
    else
        name = seasonTag .. lang.transstr("dream_season_rank")
    end

    self.txtTabUp.text = name
    self.txtTabDown.text = name
end

function CompeteCrossInfoTabItemView:SetSelect(isSelect)
    if isSelect then
        cache.setSelectedCrossInfoTabID(tostring(self.data.tag))
    end
    self.isSelect = isSelect
    GameObjectHelper.FastSetActive(self.btnUpGo, not isSelect)
    GameObjectHelper.FastSetActive(self.btnDownGo, isSelect)
end

function CompeteCrossInfoTabItemView:InitButtonState()
    self:unselectBtn()
    self:onPointEventHandle(true)
end

return CompeteCrossInfoTabItemView