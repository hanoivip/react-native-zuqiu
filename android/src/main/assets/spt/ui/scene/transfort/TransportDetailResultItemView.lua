local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local TransportDetailResultItemView = class(unity.base)

function TransportDetailResultItemView:ctor()
    self.loseTxt = self.___ex.loseTxt
    self.winTxt = self.___ex.winTxt
    self.normalRect = self.___ex.normalRect
    self.specialRect = self.___ex.specialRect
    self.normalCountTxt = self.___ex.normalCountTxt
    self.specialCountTxt = self.___ex.specialCountTxt
    self.win = self.___ex.win
    self.lose = self.___ex.lose
end

function TransportDetailResultItemView:InitView(data)
    if not data.win then
        self.loseTxt.text = lang.trans("transport_lose_challenge", string.formatTimestampNoYear(data.finish_t), data.name)
    else
        self.winTxt.text = lang.trans("transport_win_challenge", string.formatTimestampNoYear(data.finish_t), data.name)
        self:InitRewardContent(data.robberyReward, data.finish_t, data.name)
    end
    GameObjectHelper.FastSetActive(self.win, data.win)
    GameObjectHelper.FastSetActive(self.lose, not data.win)
end

function TransportDetailResultItemView:InitRewardContent(data, mTime, mName)
    local num
    for k, v in pairs(data.baseReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
     --金币
    if num < 1 then
        self.winTxt.text = lang.trans("transport_win_challenge_nil_reward", string.formatTimestampNoYear(mTime), mName)
        return
    end
    
    self.normalCountTxt.text = "x" .. num

    -- 基础奖励
    res.ClearChildren(self.normalRect)
    local rewardParams = {
        parentObj = self.normalRect,
        rewardData = data.baseReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)

    -- 特殊奖励
    res.ClearChildren(self.specialRect)
    if not data.specialReward then
        self.specialCountTxt.text = ""
        return
    end

    local num
    for k, v in pairs(data.specialReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.specialCountTxt.text = "x" .. num

    local rewardParams = {
        parentObj = self.specialRect,
        rewardData = data.specialReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

return TransportDetailResultItemView