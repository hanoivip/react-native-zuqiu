local Timer = require('ui.common.Timer')
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local PowerRankView = class(ActivityParentView)

function PowerRankView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.helpBtn = self.___ex.helpBtn
    self.myRankNumTxt = self.___ex.myRankNumTxt
    self.myPowerNumTxt = self.___ex.myPowerNumTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.rewardAreaGo = self.___ex.rewardAreaGo
    self.getRewardBtn = self.___ex.getRewardBtn
    self.boughtGo = self.___ex.boughtGo
    self.refreshBtn = self.___ex.refreshBtn
    self.disableTxt = self.___ex.disableTxt
    self.lockGo = self.___ex.lockGo
    self.selfRankGo = self.___ex.selfRankGo
    self.scrollPowerTitleTxt = self.___ex.scrollPowerTitleTxt
    self.scrollRankTitle = self.___ex.scrollRankTitle
    self.residualTimer = nil
end

function PowerRankView:start()
    self.helpBtn:regOnButtonClick(function()
        self:OnHelpClick()
    end)
    self.getRewardBtn:regOnButtonClick(function()
        self:OnRewardClick()
    end)
    self.refreshBtn:regOnButtonClick(function()
        self:OnRefreshClick()
    end)
end

function PowerRankView:OnHelpClick()
    if self.clickHelp then
        self.clickHelp()
    end
end

function PowerRankView:OnRewardClick()
    if self.clickReward then
        self.clickReward()
    end
end

function PowerRankView:OnRefreshClick()
    if self.clickRefresh then
        self.clickRefresh()
    end
end

function PowerRankView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.selfRankGo.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.lockGo.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.scrollRankTitle.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.scrollPowerTitleTxt.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.refreshBtn.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.scrollView.gameObject, isShow)
end

function PowerRankView:InitView(powerRankModel)
    self.powerRankModel = powerRankModel
    self:RefreshContent(powerRankModel)
    self:RefreshResidualTime()
end

function PowerRankView:RefreshContent(powerRankModel)
    self.powerRankModel = powerRankModel
    local timeState, timeValue = self.powerRankModel:GetTimeStateAndValue()
    local rankState = self.powerRankModel.RankState
    local rewardState = self.powerRankModel:GetRewardState()
    local activityDesc = self.powerRankModel:GetActivityDesc()
    local rankListData = self.powerRankModel:GetRankListData()
    local selfData = self.powerRankModel:GetSelfRankData()
    local selfIndex = self.powerRankModel:GetSelfRankIndex()
    self.activityDes.text = activityDesc
    self.scrollView:InitView(rankListData)
    if timeState == rankState.RANKING then
        self.scrollPowerTitleTxt.text = lang.trans("activity_power_ranking")
    else
        self.scrollPowerTitleTxt.text = lang.trans("activity_power_end")
    end
    GameObjectHelper.FastSetActive(self.bg1Go, bgState)
    GameObjectHelper.FastSetActive(self.rewardAreaGo, timeState == rankState.REWARD)
    GameObjectHelper.FastSetActive(self.getRewardBtn.gameObject, rewardState == 0)
    GameObjectHelper.FastSetActive(self.disableTxt.gameObject, rewardState == -1)
    GameObjectHelper.FastSetActive(self.boughtGo, rewardState == 1)
    GameObjectHelper.FastSetActive(self.lockGo, timeState == rankState.LOCK)
    GameObjectHelper.FastSetActive(self.selfRankGo, timeState ~= rankState.LOCK)
    GameObjectHelper.FastSetActive(self.refreshBtn.gameObject, timeState == rankState.RANKING)
    self.disableTxt.text = lang.trans("power_rank_disable")
    if timeState == rankState.LOCK then
        return
    end
    if selfData then
        self.myPowerNumTxt.text = tostring(selfData.power)
        self.myRankNumTxt.text = tostring(selfIndex)
        res.ClearChildren(self.itemAreaTrans)
        local rewardParams = {
            parentObj = self.itemAreaTrans,
            rewardData = selfData.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
        self.disableTxt.text = ""
    else
        local rankOutStr = lang.trans("train_rankOut")
        if timeState == rankState.REWARD then
            self.myPowerNumTxt.text = rankOutStr
        else
            local power = self.powerRankModel:GetSelfPower()
            self.myPowerNumTxt.text = tostring(power)
        end
        self.myRankNumTxt.text = rankOutStr
        if timeState == rankState.RANKING then
            self.disableTxt.text = lang.trans("activity_power_out")
        else
            self.disableTxt.text = lang.trans("activity_power_disreward")
        end
    end
end

function PowerRankView:RefreshResidualTime()
    local timeState, timeValue = self.powerRankModel:GetTimeStateAndValue()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end

    local rankState = self.powerRankModel.RankState
    local timeTitle = ""
    if timeState == rankState.RANKING then
        timeTitle = lang.transstr("residual_time")
    elseif timeState == rankState.REWARD then
        timeTitle = lang.transstr("power_rank_time_receive").. ": "
    elseif timeState == rankState.LOCK then
        timeTitle = lang.transstr("power_rank_lock_time").. ": "
    end
    self.residualTimer = Timer.new(timeValue, function(time)
        if time > 0 then
            self.residualTime.text = timeTitle .. string.convertSecondToTime(time)
        elseif timeState == rankState.REWARD then
            self.residualTime.text = lang.trans("time_limit_growthPlan_desc5")
        else
            if (timeState == rankState.LOCK or timeState == rankState.RANKING) and type(self.refreshContent) == "function" then
                self.refreshContent()
            end
        end
    end)
end

function PowerRankView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return PowerRankView