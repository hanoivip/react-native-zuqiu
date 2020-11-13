local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LadderRewardDetailItemMoneyRewardView = class(unity.base, "LadderRewardDetailItemMoneyRewardView")


function LadderRewardDetailItemMoneyRewardView:ctor()
    self.number = self.___ex.number
end

function LadderRewardDetailItemMoneyRewardView:InitView(moneyData)
    if moneyData then
        self.number.text = "x" .. string.formatNumWithUnit(tostring(moneyData))
    end
end

return LadderRewardDetailItemMoneyRewardView