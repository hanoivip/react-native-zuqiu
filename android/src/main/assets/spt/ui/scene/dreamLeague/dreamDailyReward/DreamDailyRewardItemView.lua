local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local DreamDailyRewardItemView = class(unity.base, "DreamDailyRewardItemView")

function DreamDailyRewardItemView:ctor()
    self.specialNumObj = self.___ex.specialNumObj
    self.normalNumObj = self.___ex.normalNumObj
    self.rankTxt = self.___ex.rankTxt
    self.rankObj = self.___ex.rankObj
    self.rewardParent = self.___ex.rewardParent
end

function DreamDailyRewardItemView:InitView(data)
    self.itemData = data

    res.ClearChildren(self.rewardParent.gameObject.transform)

    if self:IsSpecialNum() then
        GameObjectHelper.FastSetActive(self.specialNumObj, true)
        GameObjectHelper.FastSetActive(self.normalNumObj, false)

        GameObjectHelper.FastSetActive(self.rankObj[tostring(self.itemData.topLimit)], true)
    else
        GameObjectHelper.FastSetActive(self.specialNumObj, false)
        GameObjectHelper.FastSetActive(self.normalNumObj, true)

        if self:IsInterval() then
            if self:IsIntervalInfinity() then
            self.rankTxt.text = self:GetRankTextIntervalInfinity()
            else
                self.rankTxt.text = self:GetRankTextInterval()
            end
        else
            self.rankTxt.text = self:GetRankTextNormal()
        end
    end

    local rewardParams = {
        parentObj = self.rewardParent,
        rewardData = self.itemData.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

-- 判断本item是否显示为特殊排名123，需要特殊icon
function DreamDailyRewardItemView:IsSpecialNum()
    if (self.itemData.topLimit == 1 or self.itemData.topLimit == 2 or self.itemData.topLimit == 3) and not self:IsInterval() then
        return true
    else
        return false
    end
end

-- 判断本item是否显示为排名区间
function DreamDailyRewardItemView:IsInterval()
    if self.itemData.downLimit - self.itemData.topLimit ~= 0 then
        return true
    else
        return false
    end
end

-- 判断本item是否为最后一个无穷区间
function DreamDailyRewardItemView:IsIntervalInfinity()
    if self.itemData.downLimit == 0 then
        return true
    else
        return false
    end
end

-- 获取最后一个无穷区间文本
function DreamDailyRewardItemView:GetRankTextIntervalInfinity()
    -- 第{1}位后
    return lang.trans("peak_rank_range_1", tostring(self.itemData.topLimit))
end

-- 获取正常区间的文本
function DreamDailyRewardItemView:GetRankTextInterval()
    -- 第{1}-{2}位
    return lang.trans("ladder_rewardDetail_rank", tostring(self.itemData.topLimit), tostring(self.itemData.downLimit))
end

-- 获取单名次文本
function DreamDailyRewardItemView:GetRankTextNormal()
    -- 第{1}位
    return lang.trans("ladder_rewardDetail_rank2", tostring(self.itemData.topLimit))
end

return DreamDailyRewardItemView