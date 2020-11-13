local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Quaternion = UnityEngine.Quaternion
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TipLineItemView = class(unity.base)

function TipLineItemView:ctor()
    self.connet = self.___ex.connet
    self.moveLine = self.___ex.moveLine
    self.skillBoard = self.___ex.skillBoard
    self.equipBoard = self.___ex.equipBoard
end

function TipLineItemView:InitView(index, equipNum, nextOpenIndex, maxSkill)
    self.nextOpenIndex = nextOpenIndex
    if index < nextOpenIndex then 
        self.connet.transform.anchoredPosition = Vector2(-self.connet.transform.rect.width / 2, 0)
        self.connet.transform.localRotation = Quaternion.Euler(0, 0, 90)
    elseif index > nextOpenIndex then 
        self.connet.transform.anchoredPosition = Vector2(self.connet.transform.rect.width / 2, 0)
        self.connet.transform.localRotation = Quaternion.Euler(0, 0, 270)
    end
    local isPoint = tobool((nextOpenIndex <= maxSkill) and (index == nextOpenIndex))
    GameObjectHelper.FastSetActive(self.connet, not isPoint)
    GameObjectHelper.FastSetActive(self.moveLine, isPoint)
    GameObjectHelper.FastSetActive(self.skillBoard, isPoint)
end

return TipLineItemView