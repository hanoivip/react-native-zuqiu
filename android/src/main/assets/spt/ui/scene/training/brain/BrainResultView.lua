local GameObjectHelper = require("ui.common.GameObjectHelper")

local BrainResultView = class(unity.base)

local SuccessLevel = {
    Success = 4,
    BigSuccess = 8,
}

function BrainResultView:ctor()
    self.scrollView = self.___ex.scrollView
    self.resultCount = self.___ex.resultCount
    self.resultTime = self.___ex.resultTime
    self.success = self.___ex.success
    self.bigSuccess = self.___ex.bigSuccess
end

function BrainResultView:Start()

end

function BrainResultView:InitView(rankInfo)
    local count = rankInfo.count
    self.resultCount.text = lang.trans("brain_selfCount", count)
    self.resultTime.text = lang.trans("brain_selfTime", rankInfo.useTime)
    GameObjectHelper.FastSetActive(self.success, count >= SuccessLevel.Success and count < SuccessLevel.BigSuccess)
    GameObjectHelper.FastSetActive(self.bigSuccess, count >= SuccessLevel.BigSuccess)
end


return BrainResultView