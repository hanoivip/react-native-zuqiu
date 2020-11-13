local Timer = require("ui.common.Timer")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Application = UnityEngine.Application
local BayernLuckyDrawView = class(unity.base)

function BayernLuckyDrawView:ctor()
    self.activityDes = self.___ex.activityDes
    self.freeDrawBtn = self.___ex.freeDrawBtn
    self.freeDrawText = self.___ex.freeDrawText
    self.showRemainTime = self.___ex.showRemainTime
    self.remainTime = self.___ex.remainTime
    self.clickGoBtn = self.___ex.clickGoBtn
    self.openRewardTimeObj = self.___ex.openRewardTimeObj
    self.rewardIDList = self.___ex.rewardIDList
    self.clickGetRewardBtn = self.___ex.clickGetRewardBtn
    self.partiRewardObj = self.___ex.partiRewardObj
    self.rewardMessage = self.___ex.rewardMessage
    self.freeDrawButton = self.___ex.freeDrawButton
    self.firstIDList = self.___ex.firstIDList
    self.secondIDList = self.___ex.secondIDList
    self.thirdIDList = self.___ex.thirdIDList
    self.finishReward = self.___ex.finishReward
    self.reward = self.___ex.reward
    self.remaingShow = self.___ex.remaingShow
    self.residualTimer = nil
    self.residualTimerRemain = nil 
end

function BayernLuckyDrawView:start()
end

function BayernLuckyDrawView:InitView(bayernLuckyDrawModel)
    self.bayernLuckyDrawModel = bayernLuckyDrawModel
    self.freeDrawBtn:regOnButtonClick(function()
        if self.freeDrawButton.interactable then 
            if type(self.clickFreeDraw) == "function" then
                self:clickFreeDraw()
            end
        end
    end)
    self.clickGetRewardBtn:regOnButtonClick(function()
        clr.coroutine(function()
            local response = req.activityBayernLuckyDrawReceive(self.bayernLuckyDrawModel:GetActivityType(), self.bayernLuckyDrawModel:GetRwardItemSubIDByIndex(4))
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                self:InitRewardButtonState(1)
            end
        end)
    end)
    self:RefreshContent()
end


function BayernLuckyDrawView:RefreshContent()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if self.residualTimerRemain ~= nil then
        self.residualTimerRemain:Destroy()
    end
    self.activityDes.text = self.bayernLuckyDrawModel:GetActivityDesc()
    if tonumber(self.bayernLuckyDrawModel:GetRemainTime()) > 0 then
        self.residualTimerRemain = Timer.new(self.bayernLuckyDrawModel:GetRemainTime(), function(time)
            self.remainTime.text = string.convertSecondToTime(time)
        end)
    end
    if self.bayernLuckyDrawModel:GetRewardData()[1].wetherLink == 1 then
        self.clickGoBtn.gameObject:SetActive(true)
        self.clickGoBtn:regOnButtonClick(function()
            clr.coroutine(function()
                local response = req.activityBayernLuckyDrawRedirectLink(self.bayernLuckyDrawModel:GetActivityType(), self.bayernLuckyDrawModel:GetActivityId())
                if api.success(response) then
                    local data = response.val
                    Application.OpenURL(data.link)
                end
            end)
        end)
    else
        self.clickGoBtn.gameObject:SetActive(false)
    end
    self:InitFreeDrawButtonState(false)
    self:InitRightAreaView()
    self:InitAllRewardItem(self.bayernLuckyDrawModel:GetRewardData())
end

function BayernLuckyDrawView:InitRightAreaView()
    if tonumber(self.bayernLuckyDrawModel:GetShowRemainTime()) > 0 then
        self.residualTimer = Timer.new(self.bayernLuckyDrawModel:GetShowRemainTime(), function(time)
            self.showRemainTime.text = string.convertSecondToTime(time)
            if time < 0 then
                self:RequestOpenReward()
            end
        end)
    else           
        self:RequestOpenReward()
    end
end


function BayernLuckyDrawView:InitAllRewardItem(list)
    for i = 1, #list do
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/BayernReward/RewardItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        obj.transform:SetParent(self.reward.transform, false)
        spt:InitView(list[i])
    end
end


-- 请求开奖数据
function BayernLuckyDrawView:RequestOpenReward()
    self.isDrawed = false
    self.nameList = {}
    self.rewardList = {}
    self.freeDrawButton.interactable = false
    clr.coroutine(function()
        local response = req.activityBayernLuckyDrawResult(self.bayernLuckyDrawModel:GetActivityType(), self.bayernLuckyDrawModel:GetActivityId())
        if api.success(response) then
            local data = response.val
            self.nameList = data.draw
            for k,v in pairs(data.list) do
                self.rewardList = v
                break
            end
            self.isDrawed = true
            if self.nameList == nil then
                self:InitFreeDrawButtonState(false)
                self.remaingShow.text = lang.trans("bayernActivity_NobodyDraw")
            elseif #self.nameList ~= 1 then
                self:InitRewardNameList()
                self:InitFreeDrawButtonState(false)
                self:InitMyRewardArea()
            end
        end
    end)
end

-- 初始化中奖列表
function BayernLuckyDrawView:InitRewardNameList()
    self.firstRewardList = {}
    self.secondRewardList = {}
    self.thirdRewardList = {}
    self.fourRewardList = {}
    self.rewardIDList:SetActive(true)    
    if self.isDrawed == true then
        local rankInfoList = {}
        for k,v in pairs(self.nameList) do
            v.subID = tonumber(k)
            table.insert(rankInfoList, v)
        end
        table.sort(rankInfoList, function(a, b)
            return tonumber(a.subID) < tonumber(b.subID)
        end)
        if rankInfoList[1] ~= nil then
            local firstData = rankInfoList[1]
            for i = 1, #firstData do
                self.firstRewardList[i] = firstData[i].serverName..firstData[i].name
                self.firstIDList.text = self.firstRewardList[i]
            end
        end
        if rankInfoList[2] ~= nil then
            local secondData = rankInfoList[2]
            local tmpString = ""
            for i = 1, #secondData do
                self.secondRewardList[i] = secondData[i].serverName..secondData[i].name
                tmpString = tmpString..self.secondRewardList[i].."\n"
            end
            self.secondIDList.text = tmpString
        end
        if rankInfoList[3] ~= nil then
            local thirdData = rankInfoList[3]
            local tmpString = ""
            for i = 1, #thirdData do
                self.thirdRewardList[i] = thirdData[i].serverName..thirdData[i].name
                tmpString = tmpString..self.thirdRewardList[i].."\n"
            end
            self.thirdIDList.text = tmpString
        end
        if rankInfoList[4] ~= nil then
            local fourData = rankInfoList[4]
            for i = 1, #fourData do
                self.fourRewardList[i] = fourData[i].serverName..fourData[i].name
            end
        end
    end
end

function BayernLuckyDrawView:InitMyRewardArea()
    self.openRewardTimeObj:SetActive(false)
    self.rewardMessage.gameObject:SetActive(true)
    self.rewardRank = self:GetRewardRank()
    if self.rewardRank == 1 then
        self.rewardMessage.text = lang.trans("bayernActivity_FirstReward")
    elseif self.rewardRank == 2 then
        self.rewardMessage.text = lang.trans("bayernActivity_SecondReward")
    elseif self.rewardRank == 3 then
        self.rewardMessage.text = lang.trans("bayernActivity_ThirdReward")
    elseif self.rewardRank == 4 then
        local status = self.rewardList.list[4] and self.rewardList.list[4].status
        self:InitRewardButtonState(status)
    else 
        self.rewardMessage.text = lang.trans("bayernActivity_NoReward")
    end
end

function BayernLuckyDrawView:GetRewardRank()
    local rank = -1
    if self.rewardList ~= nil then
        for i = 1, #self.rewardList.list do
            if self.rewardList.list[i].status ~= -1 then
                rank = i
                break
            end
        end
    end
    return rank
end

function BayernLuckyDrawView:InitFreeDrawButtonState(state)
    if self.bayernLuckyDrawModel:IsClickedFreeDraw() or state then
        self.freeDrawText.text = lang.trans("bayernActivity_Haved_Reward")
        self.freeDrawButton.interactable = false
    else
        if self.isDrawed then
            self.freeDrawText.text = lang.trans("bayernActivity_Haved_OpenDraw")
            self.freeDrawButton.interactable = false
        else
            self.freeDrawText.text = lang.trans("bayernActivity_Take_Reward")
            self.freeDrawButton.interactable = true
        end
    end
end

function BayernLuckyDrawView:InitRewardButtonState(state)
    if state == 1 then
        GameObjectHelper.FastSetActive(self.partiRewardObj, false)
        GameObjectHelper.FastSetActive(self.finishReward, true)
    elseif state == 0 then
        GameObjectHelper.FastSetActive(self.partiRewardObj, true)
        GameObjectHelper.FastSetActive(self.finishReward, false)
    end
end


function BayernLuckyDrawView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if self.residualTimerRemain ~= nil then
        self.residualTimerRemain:Destroy()
    end
end

return BayernLuckyDrawView
