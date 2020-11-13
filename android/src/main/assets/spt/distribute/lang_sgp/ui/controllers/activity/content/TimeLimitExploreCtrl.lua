local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local CardBuilder = require("ui.common.card.CardBuilder")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local DialogManager = require("ui.control.manager.DialogManager")
local TimeLimitExploreCtrl = class(ActivityContentBaseCtrl)

function TimeLimitExploreCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view.tabGroup:BindMenuItem("rank", function() self:SwitchToRank() end)
    self.view.tabGroup:BindMenuItem("reward", function() self:SwitchToReward() end)
    self.view.tabGroup:selectMenuItem("rank")

    self.view.onRefreshClick = function() self:SwitchToRank() end
    self.view.onRuleClick = function() self:ClickRuleButton() end
    self.view.onGachaOne = function() self:ClickGachaButton("oneGacha") end
    self.view.onGachaTen = function() self:ClickGachaButton("tenGacha") end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.RefreshContent = function() self:RefreshContent() end
    self:SwitchToRank()
    self.view.clickCard = function(cid) self:ClickCard(cid) end
    self.view:InitView(self.activityModel)
    self:InitPointRewardView()
end

function TimeLimitExploreCtrl:InitPointRewardView()
    self.view.pointScroll:RegOnItemButtonClick(function(isGetReward, rewardId)
        self:OpenRewardBoard(isGetReward, rewardId)
    end)
    self.view.pointScroll:InitView(self.activityModel:GetPointRewardList())
end

function TimeLimitExploreCtrl:ClickGachaButton(type)
    local ticketNum = 0
    local itemsMapModel = ItemsMapModel.new()
    if type == "oneGacha" then
        ticketNum = itemsMapModel:GetItemNum(16)
    else
        ticketNum = itemsMapModel:GetItemNum(17)
    end
    local m_freeTime = self.activityModel:GetGachaFreeInfo()
    local gachaFunc = function()
        clr.coroutine(function()
            local response = req.visitGacha(tostring(self.activityModel:GetPeriodID()), type)
            if api.success(response) then
                local data = response.val
                local buyInfo = ""
                if type == "oneGacha" then
                    buyInfo = lang.trans("visit_gachaSucceed", "1")
                    local freeTime = self.activityModel:GetGachaFreeInfo()
                    if freeTime > 0 then
                        self.activityModel:SetGachaFreeTime(freeTime - 1)
                    end
                elseif type == "tenGacha" then
                    buyInfo = lang.trans("visit_gachaSucceed", "10")
                end
                if data.cost and data.cost.type == "d" then
                    local playerInfoModel = PlayerInfoModel.new()
                    playerInfoModel:SetDiamond(data.cost.curr_num)
                    local mInfo = {}
                    mInfo.phylum = "activity"
                    mInfo.classfield = "timeLimit"
                    mInfo.genus = ""
                    CustomEvent.ConsumeDiamond("6", response.val.cost.num, mInfo)
                end
                if data.cost then
                    itemsMapModel:UpdateFromReward(data.cost)
                end
                CongratulationsPageCtrl.new(data.gift, nil, buyInfo)
            end
        end)
    end

    if m_freeTime > 0 and type == "oneGacha" then
        -- ????????????
        gachaFunc()
    elseif ticketNum > 0 then
        -- ??,???????
        local tipText;
        if type == "oneGacha" then
            tipText = lang.trans("explore_one_enough_tips")
        else
            tipText = lang.trans("explore_ten_enough_tips")
        end
        DialogManager.ShowConfirmPop(lang.trans("tips"), tipText, 
        function() 
            gachaFunc() 
        end)
    else  -- ???,????
        local tipText
        if type == "oneGacha" then
            local price = self.activityModel:GetGachaOnePrice()
            tipText = lang.transstr("explore_one_tips", price)
        else
            local price = self.activityModel:GetGachaTenPrice()
            tipText = lang.transstr("explore_ten_tips", price)
        end
        DialogManager.ShowConfirmPop(lang.trans("tips"), tipText, 
        function() 
            gachaFunc() 
        end)
    end
end

-- self:ResetCousume????,??????????????
function TimeLimitExploreCtrl:RefreshContent()
    if self.isRankPage then
        self:SwitchToRank()
    else
        self.view.pointScroll:InitView(self.activityModel:GetPointRewardList())
        self.activityModel:SendUpdatePointRewardInfoEvent()
    end
end

function TimeLimitExploreCtrl:SwitchToRank()
    clr.coroutine(function()
        local response = req.visitRank()
        if api.success(response) then
            local data = response.val
            self.view.rewardPage:SetActive(false)
            self.view.rankPage:SetActive(true)
            self.isRankPage = true
            self.activityModel:UpdateRankInfo(data)
            self.view.pointScroll:InitView(self.activityModel:GetPointRewardList())
            self.view.rankScroll:InitView(self.activityModel:GetRankList())
            self.activityModel:SendUpdateRankInfoEvent()
            self.activityModel:SendUpdatePointRewardInfoEvent()
        end
    end)
end

function TimeLimitExploreCtrl:OpenRewardBoard(isGetReward, rewardId)
    if isGetReward then
        clr.coroutine(function()
            local response = req.visitReceiveChestReward(tostring(self.activityModel:GetPeriodID()), rewardId)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.gift)
                self.activityModel:UpdatePointRewardInfo(rewardId)
                self.view.pointScroll:InitView(self.activityModel:GetPointRewardList())
                self.activityModel:SendUpdatePointRewardInfoEvent()
            end
        end)
    else
        res.PushDialog("ui.controllers.timeLimitExplore.TimeLimitExplorePointRewardCtrl", self.activityModel:GetPointRewardList(), function(isGetReward, rewardId)
            self:OpenRewardBoard(isGetReward, rewardId)
        end)
    end
end

function TimeLimitExploreCtrl:SwitchToReward()
    self.view.rewardPage:SetActive(true)
    self.view.rankPage:SetActive(false)
    self.isRankPage = false
    self.view.rewardScroll:InitView(self.activityModel:GetRankRewardList())
end

function TimeLimitExploreCtrl:ClickCard(cid)
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
end

function TimeLimitExploreCtrl:ClickRuleButton()
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/Explore/ExploreRuleBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:InitText(self.activityModel:GetRule())
end

function TimeLimitExploreCtrl:OnRefresh()
    self.view:OnRefresh()
end

function TimeLimitExploreCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function TimeLimitExploreCtrl:OnExitScene()
    self.view:OnExitScene()
end

return TimeLimitExploreCtrl
