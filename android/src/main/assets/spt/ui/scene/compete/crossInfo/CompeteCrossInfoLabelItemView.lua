local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteCrossInfoLabelItemView = class(LuaButton, "CompeteCrossInfoLabelItemView")

function CompeteCrossInfoLabelItemView:ctor()
    CompeteCrossInfoLabelItemView.super.ctor(self)
    self.btnUpGo = self.___ex.btnUpGo
    self.btnDownGo = self.___ex.btnDownGo
    self.txtLabel = self.___ex.txtLabel
    self.isSelect = false
end

function CompeteCrossInfoLabelItemView:start()
end

function CompeteCrossInfoLabelItemView:InitView(data)
    self:InitButtonState()
    self.data = data
    self.isSelect = false

    self.txtLabel.text = lang.trans(self.data.nameLoc)
end

function CompeteCrossInfoLabelItemView:InitButtonState()
    self:unselectBtn()
    self:onPointEventHandle(true)
end

function CompeteCrossInfoLabelItemView:SetSelect(isSelect)
    self.isSelect = isSelect
    GameObjectHelper.FastSetActive(self.btnUpGo, not isSelect)
    GameObjectHelper.FastSetActive(self.btnDownGo, isSelect)
end

function CompeteCrossInfoLabelItemView:GetMatchType()
    return self.data.matchType
end

return CompeteCrossInfoLabelItemView