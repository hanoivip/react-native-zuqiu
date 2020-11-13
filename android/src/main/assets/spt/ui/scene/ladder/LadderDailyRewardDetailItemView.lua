local GameObjectHelper = require("ui.common.GameObjectHelper")

local LadderDailyRewardDetailItemView = class(unity.base)

function LadderDailyRewardDetailItemView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.txtNormalRank = self.___ex.txtNormalRank
    self.txtHonorPoint = self.___ex.txtHonorPoint
end

function LadderDailyRewardDetailItemView:InitView(data)
    if data.rankLow == 1 and data.rankHigh == 1 then
        self:SetRankShowStatus(true, false, false)
    elseif data.rankLow == 2 and data.rankHigh == 2 then
        self:SetRankShowStatus(false, true, false)
    elseif data.rankLow == 3 and data.rankHigh == 3 then
        self:SetRankShowStatus(false, false, true)
    else
        self:SetRankShowStatus(false, false, false)
        if data.rankLow ~= data.rankHigh then
            self.txtNormalRank.text = lang.trans("ladder_rewardDetail_rank", tostring(data.rankHigh), tostring(data.rankLow))
        else
            self.txtNormalRank.text = lang.trans("ladder_rank", tostring(data.rankHigh))
        end
    end
    self.txtHonorPoint.text = "x" .. tostring(data.reward * 12)
end

function LadderDailyRewardDetailItemView:SetRankShowStatus(isFirstRank, isSecondRank, isThirdRank)
    GameObjectHelper.FastSetActive(self.firstRank, isFirstRank)
    GameObjectHelper.FastSetActive(self.secondRank, isSecondRank)
    GameObjectHelper.FastSetActive(self.thirdRank, isThirdRank)
    GameObjectHelper.FastSetActive(self.normalRank, not (isFirstRank or isSecondRank or isThirdRank))
end

return LadderDailyRewardDetailItemView