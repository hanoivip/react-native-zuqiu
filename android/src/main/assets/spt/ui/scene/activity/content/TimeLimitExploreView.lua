local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Timer = require("ui.common.Timer")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")  
local TimeLimitExploreView = class(ActivityParentView)

function TimeLimitExploreView:ctor()
    self.description = self.___ex.description
    self.time1 = self.___ex.time1
    self.time2 = self.___ex.time2
    self.endInfo = self.___ex.endInfo
    self.tabGroup = self.___ex.tabGroup
    self.rankPage = self.___ex.rankPage
    self.selfRank = self.___ex.selfRank
    self.selfPoint = self.___ex.selfPoint
    self.btnRefresh = self.___ex.btnRefresh
    self.rankScroll = self.___ex.rankScroll
    self.rewardPage = self.___ex.rewardPage
    self.rewardScroll = self.___ex.rewardScroll
    self.showParentRect = self.___ex.showParentRect
    self.btnRule = self.___ex.btnRule
    self.btnGacha = self.___ex.btnGacha
    self.btnGachaTen = self.___ex.btnGachaTen
    self.rewardContent = self.___ex.rewardContent
    self.pointScroll = self.___ex.pointScroll
    self.gachaPrice = self.___ex.gachaPrice
    self.gachaTenPrice = self.___ex.gachaTenPrice
    self.gachaTenInfo = self.___ex.gachaTenInfo
    self.buyInfo = self.___ex.buyInfo
    self.rewardLayoutGroup = self.___ex.rewardLayoutGroup
    self.showView = self.___ex.showView
    self.gachaOneText = self.___ex.gachaOneText
    self.gachaOneFree = self.___ex.gachaOneFree
    self.bugInfo = self.___ex.bugInfo
    self.residualTimer = nil
    local testUpdateKR = 0
end

function TimeLimitExploreView:OnEnterScene()
    if self.onRefreshClick then
        self.btnRefresh:regOnButtonClick(function()
            self.onRefreshClick()
        end)
    end
    if self.onRuleClick then
        self.btnRule:regOnButtonClick(function()
            self.onRuleClick()
        end)
    end
    if self.onGachaOne then
        self.btnGacha:regOnButtonClick(function()
            self.onGachaOne()
        end)
    end
    if self.onGachaTen then
        self.btnGachaTen:regOnButtonClick(function()
            self.onGachaTen()
        end)
    end
    EventSystem.AddEvent("TimeLimitExplore.UpdateRankInfo", self, self.UpdateRankInfo)
    EventSystem.AddEvent("TimeLimitExplore.UpdateGachaFreeInfo", self, self.UpdateGachaFreeInfo)
    EventSystem.AddEvent("ConsumeDiamond", self, self.ResetCousume)
    self:ResetTimer()
end

function TimeLimitExploreView:InitView(model)
    self.model = model
    self:BuildPage()
    self:ResetTimer()
end

function TimeLimitExploreView:ResetTimer()
    if self.model:GetRemainTime() > 0 then
        GameObjectHelper.FastSetActive(self.time2.gameObject, true)
        GameObjectHelper.FastSetActive(self.endInfo, false)
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function TimeLimitExploreView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    -- KR不写倒计时 写结束时间和开始时间
    if luaevt.trig("__KR__VERSION__") then
        local startTime = self.model:GetBeginTime()
        local endTime = self.model:GetEndTime()
        local startTimeStr = string.convertSecondToMonth(startTime)
        local endTimeStr = string.convertSecondToMonth(endTime)

        self.time2.text =lang.transstr("activityTime") .. startTimeStr .. "-" .. endTimeStr
    else
        self.residualTimer = Timer.new(self.model:GetRemainTime(), function(time)
            if time <= 0 then
                self:SetRunOutOfTimeView()
                return
            else
                local timeStr = lang.transstr("visit_timeDesc")
                timeStr = timeStr .. string.convertSecondToTime(time)
                self.time2.text = timeStr
            end
        end)
    end
end

function TimeLimitExploreView:SetRunOutOfTimeView()
    GameObjectHelper.FastSetActive(self.time2.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnGacha.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnGachaTen.gameObject, false)
    GameObjectHelper.FastSetActive(self.buyInfo.gameObject, false)
    GameObjectHelper.FastSetActive(self.endInfo, true)
end

function TimeLimitExploreView:SetDisapperView()

end

function TimeLimitExploreView:BuildPage()
    self.description.text = self.model:GetDescription()
    -- TODO:目前只支持显示卡牌
    local cardModel = StaticCardModel.new(self.model:GetPictureID())
    local showBox = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/Explore/TimeLimitExploreShowBox.prefab")
    self.showView = showBox:GetComponent(clr.CapsUnityLuaBehav)
    showBox.transform:SetParent(self.showParentRect.transform, false)
    self.showView.clickCard = self.clickCard
    self.showView:InitView(self.model:GetPictureType(), cardModel)

    self.gachaPrice.text = "x" .. self.model:GetGachaOnePrice()
    self.gachaTenPrice.text = "x" .. self.model:GetGachaTenPrice()
    self:BuildGachaRewardPage()
    self:UpdateRankInfo()
    self:UpdateGachaFreeInfo()
end

function TimeLimitExploreView:UpdateGachaFreeInfo()
    local gachaFreeInfo = self.model:GetGachaFreeInfo()
    GameObjectHelper.FastSetActive(self.gachaOneFree, gachaFreeInfo > 0)
    GameObjectHelper.FastSetActive(self.gachaOneText, gachaFreeInfo <= 0)
end

function TimeLimitExploreView:BuildGachaRewardPage()
    local rewards = self.model:GetGachaRewardList()
    res.ClearChildren(self.rewardContent.gameObject.transform)
    local rewardKeyList = table.keys(rewards)
    table.sort(rewardKeyList, function(a, b) return a < b end)
    for index, key in ipairs(rewardKeyList) do
        local rewardParams = {
            parentObj = self.rewardContent,
            rewardData = rewards[key].contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end

    local num = self.rewardContent.gameObject.transform.childCount
    local cellSize = self.rewardLayoutGroup.cellSize
    local spacing = self.rewardLayoutGroup.spacing
    self.rewardContent.sizeDelta = Vector2(self.rewardContent.sizeDelta.x, cellSize.y * num + spacing.y * (num - 1))
end

function TimeLimitExploreView:UpdateRankInfo()
    local currentRank = self.model:GetPlayerRank()
    self.selfRank.text = (currentRank > 0 and currentRank <= 50 and self.model:GetPlayerPoint() >= self.model:GetLimitPoint(currentRank)) and tostring(self.model:GetPlayerRank()) or lang.trans("train_rankOut")
    self.selfPoint.text = lang.trans("visit_point", tostring(self.model:GetPlayerPoint()))
end

function TimeLimitExploreView:OnRefresh()

end

function TimeLimitExploreView:OnExitScene()
    EventSystem.RemoveEvent("TimeLimitExplore.UpdateRankInfo", self, self.UpdateRankInfo)
    EventSystem.RemoveEvent("TimeLimitExplore.UpdateGachaFreeInfo", self, self.UpdateGachaFreeInfo)
    EventSystem.RemoveEvent("ConsumeDiamond", self, self.ResetCousume)
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

function TimeLimitExploreView:ResetCousume()
    if type(self.resetCousume) == "function" then
        if type(self.RefreshContent) == "function" then
            self.resetCousume(function() self:RefreshContent() end)
        else
            self.resetCousume(nil)
        end
    end
end

return TimeLimitExploreView
