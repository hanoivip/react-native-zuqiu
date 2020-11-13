local AdventureFloor = require("data.AdventureFloor")
local AdventureRewardBase = require("data.AdventureRewardBase")

local CompleteRewardIntroduceItemView = class(unity.base, "CompleteRewardIntroduceItemView")

function CompleteRewardIntroduceItemView:ctor()
--------Start_Auto_Generate--------
    self.rangeTxt = self.___ex.rangeTxt
    self.moraleTxt = self.___ex.moraleTxt
--------End_Auto_Generate----------
end

function CompleteRewardIntroduceItemView:InitView(idx, rewardMorale)
    self.idx = idx
    self.data = rewardMorale
    local range = ""
    if rewardMorale.high ~= nil then
        range = tostring(math.clamp(rewardMorale.low, 0, rewardMorale.low)) .. "% - " .. tostring(rewardMorale.high) .. "%"
    else
        range = lang.transstr("higher_than", rewardMorale.low .. "%")
    end
    self.rangeTxt.text = range
    self.moraleTxt.text = tostring(rewardMorale.morale)
end

return CompleteRewardIntroduceItemView
