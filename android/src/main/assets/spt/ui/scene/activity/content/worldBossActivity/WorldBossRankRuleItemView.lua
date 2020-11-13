local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CommonConstants = require("ui.common.CommonConstants")
local WorldBossRankRuleItemView = class(unity.base)

function WorldBossRankRuleItemView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.desc = self.___ex.desc
end

function WorldBossRankRuleItemView:InitView(data)
    local rankData = (data.rankTop == data.rankDown) and tostring(data.rankTop) or (data.rankTop .. " - " .. (data.rankDown == 0 and "..." or data.rankDown)) 
    self.normalRank.text = rankData
    self.desc.text = data.desc
end

return WorldBossRankRuleItemView