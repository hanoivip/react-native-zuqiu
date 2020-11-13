local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LadderRewardDetailItemCardRewardView = class(unity.base, "LadderRewardDetailItemCardRewardView")

function LadderRewardDetailItemCardRewardView:ctor()
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
    self.number = self.___ex.number
end

function LadderRewardDetailItemCardRewardView:InitView(cardData)
    if cardData then
        self.cardData = cardData
        self.number.text = "x" .. cardData.num
    end
end

return LadderRewardDetailItemCardRewardView