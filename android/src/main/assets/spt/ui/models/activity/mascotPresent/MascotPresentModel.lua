local ActivityModel = require("ui.models.activity.ActivityModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local MascotPresentRIViewModel = require("ui.models.activity.mascotPresent.MascotPresentRIViewModel")
local MascotPresentModel = class(ActivityModel)

function MascotPresentModel:ctor(data)
    MascotPresentModel.super.ctor(self, data)
end

function MascotPresentModel:InitWithProtocol()
    self.playerInfoModel = PlayerInfoModel.new()
end

function MascotPresentModel:InitActivityInfoData(data)
    self.actInfoData = data
    assert(self.actInfoData.task and self.actInfoData.rank and self.actInfoData.data, "server data error!!!!")
    self.newPointValue = self:GetMyGuildPointValue()
end

function MascotPresentModel:RefreshTaskRewardData(newTaskData)
    self.actInfoData.task = newTaskData
end

function MascotPresentModel:GetActivityPeriod()
    local singleData = self:GetActivitySingleData()
    return singleData.ID or 1
end

function MascotPresentModel:InitGuildRankingData(guildRankingData)
    self.guildRankingData = guildRankingData
    self.actInfoData.rank.rankMine = self.guildRankingData.rankMine --更新我的公会排行
    self:SetNewGuildPointValue(self.guildRankingData.score)
end

function MascotPresentModel:SetMyGuildMascotPoint(newValue)
    self.actInfoData.data.score = newValue
end

function MascotPresentModel:GetMyGuildPointValue()
    return self.actInfoData.data.score or 0
end

function MascotPresentModel:SetNewGuildPointValue(pointValue)
    self.newPointValue = pointValue
end

function MascotPresentModel:GetNewGuildPointValue()
    return self.newPointValue or 0
end

function MascotPresentModel:AddMyGuildMascotPoint(add)
    local newPointValue = tonumber(self:GetMyGuildPointValue()) + tonumber(add)
    self:SetNewGuildPointValue(newPointValue)
end

function MascotPresentModel:InitGuildMemberContributeRankingData(gmContributeRankingData)
    self.gmContributeRankingData = gmContributeRankingData
end

function MascotPresentModel:InitMascotPresentGiftBoxData(data, count)
    self.mpGiftBoxData = data
    self.clickProgressItemCount = count
    self:SetNewGuildPointValue(self.mpGiftBoxData.score)
end

function MascotPresentModel:GetMascotPresentGiftBoxData()
    return self.mpGiftBoxData or {}
end

function MascotPresentModel:InitOrderedOwnedGiftBoxData(data)
    self.mpOrderedOwnedGiftBoxData = data
end

function MascotPresentModel:GetOrderedOwnedGiftBoxData()
    return self.mpOrderedOwnedGiftBoxData or {}
end

function MascotPresentModel:GetClickProgressItemCount()
    return self.clickProgressItemCount
end

function MascotPresentModel:GetMascotPresentGiftBoxList()
    return self.mpGiftBoxData.data or {}
end

function MascotPresentModel:GetOrderedOwnedGiftBoxList()
    return self.mpOrderedOwnedGiftBoxData.data or {}
end

function MascotPresentModel:IsShowTaskRewardRedPoint(taskRewardIndex)
    local rewardList = self:GetGuildOrMemberRewardData(taskRewardIndex)
    if type(rewardList) == "table" then
        for k, v in pairs(rewardList) do
            local rewardItemModel = MascotPresentRIViewModel.new(v)
            if rewardItemModel:IsRewardCollectable() then
                return true
            end
        end
    end

    return false
end

function MascotPresentModel:SetProgressGiftDataCollectedByIndex(index, clickCount)
    self.mpGiftBoxData.data[index].state.pid = self.playerInfoModel:GetID()
    self.mpGiftBoxData.data[index].state.name = self.playerInfoModel:GetName()
    self:SetActInfoDataGiftStateByCount(clickCount)
end

function MascotPresentModel:SetActInfoDataGiftStateByCount(count)
    if type(self.progressList) == "table" then
        for k, v in pairs(self.progressList) do
            if tonumber(v.count) == tonumber(count) then
                v.status = 1
                return
            end
        end
    end
end

function MascotPresentModel:IsProgressRewardCollectedByCount(count)
    if type(self.progressList) == "table" then
        for k, v in pairs(self.progressList) do
            if tonumber(v.count) == tonumber(count) then
                return v.status == 1
            end
        end
    end
    return false
end

function MascotPresentModel:CheckIfMyGuildPointValueChange()
    local myGuildPoint = self:GetMyGuildPointValue()
    local newPointValue = self:GetNewGuildPointValue()
    local isChange = tonumber(newPointValue) > tonumber(myGuildPoint)
    if isChange then 
        self:SetMyGuildMascotPoint(newPointValue)   --更新我的公会亲密度值
    end

    return isChange
end

function MascotPresentModel:GetGmContributeRankingList()
    local rankingList = self.gmContributeRankingData.rankList or {}
    local rankingList = self:ConvertToNumIndexTableBySort(rankingList)
    local myContributeRank = self.gmContributeRankingData.rankMine
    if tonumber(myContributeRank) == -1 then
        self.gmContributeRankingData.score = 0
    else
        self.gmContributeRankingData.score = rankingList[tonumber(myContributeRank)].score
    end
    for k, v in pairs(rankingList) do
        v.isSelf = tostring(myContributeRank) == tostring(v.keyValue)
    end
    return rankingList
end

function MascotPresentModel:GetMyContributeRankInGuild()
    local myRank = self.gmContributeRankingData.rankMine
    if tonumber(myRank) == -1 then
        myRank = lang.transstr("train_rankOut")
    end 
    return myRank
end

function MascotPresentModel:GetMyContributePointValue()
    local myPoint = self.gmContributeRankingData.score or 0
    return myPoint
end

function MascotPresentModel:GetActDescWithComma()
    local actDesc = lang.transstr("mascotPresent_desc", ",", ",")
    return actDesc
end

function MascotPresentModel:GetRefreshTimeTipWithComma()
    local actRefeshTimeTip = lang.transstr("mascotPresent_desc6", ",")
    return actRefeshTimeTip
end

function MascotPresentModel:GetMyGuildName()
    return self.actInfoData.data.name or ""
end

function MascotPresentModel:GetMyGuildRank()
    local myRank = self.actInfoData.rank.rankMine
    if tonumber(myRank) == -1 then
        myRank = lang.transstr("train_rankOut")
    end 
    return myRank
end

function MascotPresentModel:GetGuildOrMemberRewardData(dataType)
    local rewardList = {}
    local indexRewardList = {}
    if type(self.actInfoData.task) == "table" and type(self.actInfoData.task[dataType]) == "table" then
        rewardList = self.actInfoData.task[dataType]
        indexRewardList = self:ConvertToNumIndexTableBySort(rewardList)
    end
    self:DataListPretreatment(indexRewardList, "static")
    return indexRewardList
end

function MascotPresentModel:GetProgressDataList()
    if type(self.progressList) == "table" and next(self.progressList) then
        return self.progressList
    end

    local progressDataList = self.actInfoData.data.giftState or {}
    local pdl = {}
    for k, v in pairs(progressDataList) do
        local giftBoxInfo = {}
        giftBoxInfo.status = v
        giftBoxInfo.count = tonumber(k)
        table.insert(pdl, giftBoxInfo)
    end
    table.sort(pdl, function(a, b) 
        return a.count < b.count
    end)
    local progressList = {}
    for k, v in pairs(pdl) do
        if k ~= #pdl then 
            v.nextCount  = pdl[k + 1].count
        else
            v.nextCount = 0
        end
        table.insert(progressList, v)
    end

    self.progressList = progressList --维护亲密度进度礼盒状态
    return progressList
end

function MascotPresentModel:RefreshMascotPresentGiftBoxStatus()
    local currentGuildPointValue = tonumber(self:GetMyGuildPointValue())
    if type(self.progressList) == "table" then
        for k, v in pairs(self.progressList) do
            if tonumber(v.count) <= tonumber(currentGuildPointValue) and v.status == -1 then
                v.status = 0
            end
        end
    end
end

function MascotPresentModel:IsMascotPresentGiftBoxCollect()
    local clickCount = self:GetClickProgressItemCount()
    local currentGuildPointValue = self:GetMyGuildPointValue()
    return tonumber(clickCount) <= tonumber(currentGuildPointValue)
end

function MascotPresentModel:GetCurrentProgressValue()
    return self:GetMyGuildPointValue()
end

function MascotPresentModel:GetGuildRankingList()
    local rankingList = self.guildRankingData.rankList or {}
    local rankingList = self:ConvertToNumIndexTableBySort(rankingList)
    local myGuildRank = self:GetMyGuildRank()
    for k, v in pairs(rankingList) do
        v.isSelf = tostring(myGuildRank) == tostring(v.keyValue)
    end
    return rankingList
end

function MascotPresentModel:GetGuildRankingRewardList()
    local rewardList = self.guildRankingData.static or {}
    rewardList = self:ConvertToNumIndexTableBySort(rewardList)
    self:DataListPretreatment(rewardList)
    self:MakeRankingWithPointMap(rewardList)
    return rewardList 
end

function MascotPresentModel:MakeRankingWithPointMap(rewardList)
    self.rankingWithPointMap = {}
    for k, v in pairs(rewardList) do
        for i = tonumber(v.rankHigh), tonumber(v.rankLow) do
            self.rankingWithPointMap[tostring(i)] = v.jxwLow or 0
        end
    end
end

function MascotPresentModel:GetStandardPointValueByRanking(ranking)
    assert(type(self.rankingWithPointMap) == "table", "data error!!!")
    local standardPoint = self.rankingWithPointMap[tostring(ranking)] or 0
    return standardPoint
end

function MascotPresentModel:DataListPretreatment(rewardList, coverTableName)
    for k, v in pairs(rewardList) do
        local count = 0
        local contentsTable = {}
        if not coverTableName then
            contentsTable = v.contents
        else
            contentsTable = v[coverTableName].contents
        end
        for key, value in pairs(contentsTable) do
            if type(value) == "table" then
                count = count + table.nums(value)
            else
                count = count + 1
            end
        end
        v.contentsCount = count
    end

    return rewardList
end

function MascotPresentModel:GetActivityState()
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    local endTime = tonumber(self:GetEndTime())
    local activityEndTime = tonumber(self:GetActivityEndTime())
    local startTime = tonumber(self:GetStartTime())

    if serverTimeNow > endTime or serverTimeNow < startTime then
        dump("server error!!!!")
        return false
    end
    return serverTimeNow < activityEndTime and serverTimeNow > startTime
end

--- 获取活动说明
function MascotPresentModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

--- 获取活动开始时间
function MascotPresentModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function MascotPresentModel:GetActivityEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.activityEndTime
end

--- 获取活动下架时间
function MascotPresentModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

--- 获取活动类型
function MascotPresentModel:GetActivityType()
    local singleData = self:GetActivitySingleData()
    return singleData.type or ""
end

-- 获取初始化页面需要的数据
function MascotPresentModel:GetActInfoDataFromListInfo()
    local singleData = self:GetActivitySingleData()
    return singleData.appendData or {}
end

function MascotPresentModel:ConvertToNumIndexTableBySort(list)
    local keysTable = {}
    local indexList = {}
    for k, v in pairs(list) do
        table.insert(keysTable, k)
    end
    table.sort(keysTable, function(a, b)
        return tonumber(a) < tonumber(b)
    end)
    for k, v in pairs(keysTable) do
        list[v].keyValue = v   --important
        table.insert(indexList, list[v])
    end
    return indexList
end

return MascotPresentModel
