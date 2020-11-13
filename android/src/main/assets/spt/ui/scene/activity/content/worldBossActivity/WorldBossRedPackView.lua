local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local Timer = require("ui.common.Timer")

local WorldBossRedPackView = class(unity.base)

local RedPackType = { Will = 1, Proceed = 2, Over = 3}

function WorldBossRedPackView:ctor()
    self.rewardBtn = self.___ex.rewardBtn
    self.rewardBtnText = self.___ex.rewardBtnText
    self.showDetail = self.___ex.showDetail
    self.mTip = self.___ex.mTip
    self.mTimeTip = self.___ex.mTimeTip
    self.mTipImg = self.___ex.mTipImg
    self.overTip = self.___ex.overTip
    self.mTitle = self.___ex.mTitle
    self.mNum = self.___ex.mNum
    self.helpBtn = self.___ex.helpBtn

    self.seconds = 1
    self.secondsPerMinute = 60 * self.seconds
    self.secondsPerHour = 60 * self.secondsPerMinute
end

function WorldBossRedPackView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpBtnClick()
    end)
end

function WorldBossRedPackView:InitShowState(itemData)
    self.mTimeTip.text = ""
    self.mTip.text = ""
    if itemData.state == RedPackType.Will then
        self.mTitle.text = lang.trans("worldBossActivity_redPack_title_1")
        self.rewardBtn:onPointEventHandle(false)
        self.mTip.text = lang.trans("worldBossActivity_redPack_tip_1")
        self.showDetail.text = lang.trans("worldBossActivity_redPack_detail_tip_1", itemData.playerCount)
        GameObjectHelper.FastSetActive(self.mTipImg, true)
        GameObjectHelper.FastSetActive(self.overTip, false)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
    elseif itemData.state == RedPackType.Proceed then
        self.mTitle.text = lang.trans("worldBossActivity_redPack_title_3")
        self.rewardBtn:onPointEventHandle(true)
        self.rewardBtnText.text = lang.trans("transfort_noemal_rob_1")
        self.showDetail.text = lang.trans("worldBossActivity_redPack_detail_tip_2", itemData.baseCount .. "    ", itemData.baseRank)
        GameObjectHelper.FastSetActive(self.mTipImg, false)
        GameObjectHelper.FastSetActive(self.overTip, false)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, true)
    elseif itemData.state == RedPackType.Over then
        self.mTitle.text = lang.trans("worldBossActivity_redPack_title_2")
        self.rewardBtn:onPointEventHandle(false)
        self.showDetail.text = lang.trans("worldBossActivity_redPack_detail_tip_2", itemData.baseCount .. "    ", itemData.baseRank)
        GameObjectHelper.FastSetActive(self.mTipImg, false)
        GameObjectHelper.FastSetActive(self.overTip, true)
        GameObjectHelper.FastSetActive(self.rewardBtn.gameObject, false)
    end
end

function WorldBossRedPackView:RefreshTextContentAndButtonState()
    self.diamondNumberText.text = tostring(self.cumulativeConsumeModel:GetConsumeDiamondNumberByIndex(self.index)) .. "/"
        .. tostring(self.cumulativeConsumeModel:GetRewardConditionByIndex(self.index))
    self:InitRewardButtonState(self.cumulativeConsumeModel:GetRewardStatusByIndex(self.index))
end

function WorldBossRedPackView:OnHelpBtnClick()
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossRuleBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:InitView(lang.trans("instruction"), lang.trans("worldBossAcitvity_help"))
end

function WorldBossRedPackView:OnRewardBtnClick()
    self.rewardBtn:onPointEventHandle(false)
    if self.onGrab then
        self.onGrab(function()
            self.rewardBtn:onPointEventHandle(true)
            self:RediusTimeClose()
        end,
        function()
            self.rewardBtn:onPointEventHandle(true)
        end)
    end
end

function WorldBossRedPackView:InitView(itemData)
    self.state = itemData.state
    self.itemData = itemData
    self.mNum.text = itemData.diamond
    self:InitShowState(itemData)
    if itemData.state == RedPackType.Will or itemData.state == RedPackType.Proceed then
        self:RediusTime(itemData.time)
    end
end

function WorldBossRedPackView:RediusTime(rediuTime)
    self:RediusTimeClose()
    self.timer = Timer.new(rediuTime, function(time) self:RefreshTime(time) end, nil)
end

function WorldBossRedPackView:RefreshTime(time)
    if self.state == RedPackType.Will then
        self.rewardBtnText.text = lang.trans("worldBossActivity_redPack_onRcv", self:GetTimes(time))
    else
        self.mTimeTip.text = lang.trans("worldBossActivity_redPack_tip_2", self:GetTimes(time))
    end
    if time <= 0 then
        self:OverTime(time)
    end
end

function WorldBossRedPackView:OverTime(time)
    EventSystem.SendEvent("WorldBossActivityCtrlRefreshData")
end

function WorldBossRedPackView:RediusTimeClose()
    if self.timer then
        self.timer:Destroy()
        self.timer = nil
    end
end

function WorldBossRedPackView:onDestroy()
    self:RediusTimeClose()
end

function WorldBossRedPackView:GetTimes(time)
    local hour1 = math.modf(time / self.secondsPerHour)
    time = time - hour1 * self.secondsPerHour
    local minute1 = math.modf(time / self.secondsPerMinute)
    local second = time - minute1 * self.secondsPerMinute
   
    return string.format("%02d", hour1) .. ":" .. string.format("%02d", minute1) .. ":" .. string.format("%02d", second)
end

return WorldBossRedPackView