local FriendsInviteMenuType = require("ui.models.friends.FriendsInviteMenuType")
local RewardStatus = require("ui.models.friends.RewardStatus")
local FriendsInviteTask = require("data.InviteNewPlayerTask")
local ReturnDiamondData = require("data.InviteNewPlayerDiamondReward")
local NewPlayerReward = require("data.NewPlayerReward")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local Model = require("ui.models.Model")
local FriendsInviteModel = class(Model)

local defaultID = "1"
local one = 1
local taskType = {
    numReturn = 1,
    lvlReturn = 2,
    chargeReturn = 3,
}
local hourSeconds = 3600
local dayHours = 24
local thousand = 1000
local ten = 10
function FriendsInviteModel:ctor()
    FriendsInviteModel.super.ctor(self)
    self.currentMenu = FriendsInviteMenuType.DIAMOND_RETURN
end

function FriendsInviteModel:InitVariables()
    self.playerInfoModel = PlayerInfoModel.new()
    self.friendsDiaRewardList = {}
    self.friendsNumRewardList = {}
    self.friendsLvlRewardList = {}
    self.friendsChargeRewardList = {}
    self.numIndexRecordList = {}
    self.sortedRecordList = {}
    self.menuTypeToTabTagMap = nil

    self:InitStaticRewardList()
end

function FriendsInviteModel:InitStaticRewardList()
    if FriendsInviteTask and type(FriendsInviteTask) == "table" then
        for k, v in pairs(FriendsInviteTask) do
            v.taskID = tonumber(k)
            v.status = RewardStatus.INCOMPLETE
            if v.taskFirstType == taskType.numReturn then
                table.insert(self.friendsNumRewardList, v)
            elseif v.taskFirstType == taskType.lvlReturn then
                table.insert(self.friendsLvlRewardList, v)
            elseif v.taskFirstType == taskType.chargeReturn then
                table.insert(self.friendsChargeRewardList, v)
            end
        end
    end

    table.sort(self.friendsNumRewardList, function(a, b) return a.taskID < b.taskID end)
    table.sort(self.friendsLvlRewardList, function(a, b) return a.taskID < b.taskID end)
    table.sort(self.friendsChargeRewardList, function(a, b) return a.taskID < b.taskID end)
end

function FriendsInviteModel:GetSelectedRewardList(menuType)
    local rewardList = {}
    if menuType == FriendsInviteMenuType.DIAMOND_RETURN then
        rewardList = self.friendsDiaRewardList-------
    elseif menuType == FriendsInviteMenuType.FRIENDS_NUM then
        rewardList = self.friendsNumRewardList
    elseif menuType == FriendsInviteMenuType.FRIENDS_LVL then
        rewardList = self.friendsLvlRewardList
    elseif menuType == FriendsInviteMenuType.FRIENDS_CHARGE then
        rewardList = self.friendsChargeRewardList
    end

    return rewardList
end

function FriendsInviteModel:InitWithProtocol(data)
    assert(data and type(data) == "table", "server data error!!!")
    self:InitVariables()

    self.data = data
    self.code = self.data.ic or ""
    self.newPlayerRewardStatus = self.data.rs or 1
    self.recordList = self.data.ilist or {}
    self.taskStatusList = self.data.tlist or {}
    self.IsTaskCollectedMap = {}
    for k, v in pairs(self.taskStatusList) do
        self.IsTaskCollectedMap[tostring(v)] = true
    end
    self:IntegrateRewardStatus()
end

function FriendsInviteModel:GetMyInvitationCode()
    return self.code
end

function FriendsInviteModel:IntegrateRewardStatus()
    self:InitTaskProgressValueOfFriendsCount()
    self:InitTaskProgressValueOfFriendsLvl()
    self:InitTaskProgressValueOfFriendsCharge()
    
    self:InitTaskStatusByProgressValue(FriendsInviteTask)
    self:RefreshTaskStatusByServerData()

    self:InitFriendsDiaRewardList()
    self:InitSortedRecordList()
end

function FriendsInviteModel:InitFriendsDiaRewardList()
    self.friendsDiaRewardList = clone(self.numIndexRecordList)
    local rtnDiaCollectDeltaTime = ReturnDiamondData[defaultID].duration * hourSeconds
    for k, v in pairs(self.friendsDiaRewardList) do
        v.rtnDia = math.floor(v.cd * ReturnDiamondData[defaultID].diamondRewardRate / thousand)
        local maxReturnDiamond = ReturnDiamondData[defaultID].diamondRewardHigh
        v.rtnDia = v.rtnDia > maxReturnDiamond and maxReturnDiamond or v.rtnDia
        v.collectTime = v.c_t + rtnDiaCollectDeltaTime
    end

    table.sort(self.friendsDiaRewardList, function(a, b)
        local serverTimeNow = self:GetServerTimeNow()
        local isaNoDiaToCollect = self:IsInvitedPlayerNoDiaReturn(a, serverTimeNow)
        if isaNoDiaToCollect then
            a.rd = RewardStatus.COLLECTED
        end
        local isbNoDiaToCollect = self:IsInvitedPlayerNoDiaReturn(b, serverTimeNow)
        if isbNoDiaToCollect then
            b.rd = RewardStatus.COLLECTED
        end

        if a.rd ~= b.rd then
            return a.rd < b.rd
        elseif a.rd == RewardStatus.COLLECTABLE or a.rd == RewardStatus.COLLECTED then
            return a.c_t < b.c_t
        else
            return false
        end
    end)
end

function FriendsInviteModel:IsInvitedPlayerNoDiaReturn(playerInfo, serverTimeNow)
    local isDiaNotCollected = playerInfo.rd == RewardStatus.COLLECTABLE
    local isTimeToCollect = playerInfo.collectTime <= serverTimeNow
    local isRtnDiaLessThanOne = playerInfo.rtnDia < one
    local isNoDiaRtn = isDiaNotCollected and isTimeToCollect and isRtnDiaLessThanOne
    return isNoDiaRtn
end

function FriendsInviteModel:InitSortedRecordList()
    self.sortedRecordList = clone(self.numIndexRecordList)
    table.sort(self.sortedRecordList, function(a, b)
        return a.c_t < b.c_t
    end)
end

--邀请好友数 的任务
function FriendsInviteModel:InitTaskProgressValueOfFriendsCount()
    local invitedCount = table.nums(self.recordList)
    local taskList = self:GetSelectedRewardList(FriendsInviteMenuType.FRIENDS_NUM)
    for k, v in pairs(taskList) do
        v.progressValue = invitedCount
    end
end

--邀请好友等级达到标准 的任务
function FriendsInviteModel:InitTaskProgressValueOfFriendsLvl()
    for k, v in pairs(self.recordList) do
        v.pid = k
        table.insert(self.numIndexRecordList, v)
    end
    table.sort(self.numIndexRecordList, function(a, b) return a.lvl > b.lvl end)

    local taskList = self:GetSelectedRewardList(FriendsInviteMenuType.FRIENDS_LVL)
    local lvlCountTable = {}
    local lvlValueTable = {}
    for k, v in pairs(taskList) do
        lvlCountTable[v.taskParam2] = 0
        table.insert(lvlValueTable, v.taskParam2)
    end
    table.sort(lvlValueTable, function(a, b) return a > b end)
    local lvlValueTableIndex = 1
    local isLoopOver = false
    for k, v in pairs(self.numIndexRecordList) do
        while (v.lvl < lvlValueTable[lvlValueTableIndex]) do
            lvlValueTableIndex = lvlValueTableIndex + 1
            if lvlValueTableIndex > #lvlValueTable then
                isLoopOver = true
                break
            end
            local preLvl = lvlValueTable[lvlValueTableIndex - 1]
            local currentLvl = lvlValueTable[lvlValueTableIndex]
            lvlCountTable[currentLvl] = lvlCountTable[preLvl]
        end
        if not isLoopOver then
            local calculateLvl = lvlValueTable[lvlValueTableIndex]
            lvlCountTable[calculateLvl] = lvlCountTable[calculateLvl] + 1
        else
            break
        end
    end

    while (lvlValueTableIndex < #lvlValueTable) do
        lvlValueTableIndex = lvlValueTableIndex + 1
        local currentLvl = lvlValueTable[lvlValueTableIndex]
        local preLvl = lvlValueTable[lvlValueTableIndex - 1]
        lvlCountTable[currentLvl] = lvlCountTable[preLvl]
    end

    for k, v in pairs(taskList) do
        v.progressValue = lvlCountTable[v.taskParam2]
    end
end

--邀请好友充值总和 的任务
function FriendsInviteModel:InitTaskProgressValueOfFriendsCharge()
    local chargeValue = 0
    for k, v in pairs(self.numIndexRecordList) do
        chargeValue = chargeValue + v.ar
    end

    local taskList = self:GetSelectedRewardList(FriendsInviteMenuType.FRIENDS_CHARGE)
    for k, v in pairs(taskList) do
        v.progressValue = chargeValue
    end
end

function FriendsInviteModel:InitTaskStatusByProgressValue(taskList)
    if type(taskType) == "table" and next(taskList) then
        for k, v in pairs(taskList) do
            if v.taskParam1 <= v.progressValue then
                v.status = RewardStatus.COLLECTABLE
            else
                v.status = RewardStatus.INCOMPLETE
            end
        end
    end
end

function FriendsInviteModel:RefreshTaskStatusByServerData()
    for k, v in pairs(FriendsInviteTask) do
        if self.IsTaskCollectedMap[tostring(v.taskID)] then
            v.status = RewardStatus.COLLECTED
        end
    end
end

function FriendsInviteModel:HasRewardNotCollected(menuType)
    local rewardList = self:GetSelectedRewardList(menuType)
    local serverTimeNow = self:GetServerTimeNow()
    for k, v in pairs(rewardList) do
        if menuType == FriendsInviteMenuType.DIAMOND_RETURN then
            if v.rd == RewardStatus.COLLECTABLE and v.collectTime <= serverTimeNow and v.rtnDia > 0 then
                return true
            end
        elseif v.status == RewardStatus.COLLECTABLE then
            return true
        end
    end
    return false
end

function FriendsInviteModel:GetServerTimeNow()
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = os.time() + tonumber(deltaTimeValue)
    return serverTimeNow
end

function FriendsInviteModel:SetCurrentMenu(menuType)
    self.currentMenu = menuType
end

function FriendsInviteModel:GetCurrentMenu()
    return self.currentMenu
end

function FriendsInviteModel:SetMenuTypeToTabTagMap(map)
    self.menuTypeToTabTagMap = map
end

function FriendsInviteModel:GetMenuTypeToTabTagMap()
    return self.menuTypeToTabTagMap or {}
end

function FriendsInviteModel:GetCurrentTabTag()
    local menuType = self:GetCurrentMenu()
    local menuTypeToTabTagMap = self:GetMenuTypeToTabTagMap()
    return menuTypeToTabTagMap[menuType]
end

function FriendsInviteModel:IsDiaReturnTab()
    local currentMenu = self:GetCurrentMenu()
    return currentMenu == FriendsInviteMenuType.DIAMOND_RETURN
end

function FriendsInviteModel:GetNewPlayerRewardTip(isShowInput)
    local daysDuration = NewPlayerReward[defaultID].duration / dayHours
    local lvlLimit = NewPlayerReward[defaultID].levelHigh
    local descStr = ""
    if isShowInput then
        descStr = lang.transstr("friendsInvite_desc14", daysDuration, lvlLimit)
    else
        descStr = lang.transstr("friendsInvite_desc2", daysDuration, lvlLimit)
    end
    return descStr or ""
end

function FriendsInviteModel:GetReturnDiamondTip()
    local daysDuration = ReturnDiamondData[defaultID].duration / dayHours
    local percentValue = ReturnDiamondData[defaultID].diamondRewardRate / 10
    local lvlLimit = ReturnDiamondData[defaultID].level
    local diamondLimit = ReturnDiamondData[defaultID].diamondRewardHigh
    local descStr = lang.transstr("friendsInvite_desc4", daysDuration, percentValue, lvlLimit, diamondLimit)
    return descStr or ""
end

function FriendsInviteModel:SetNewPlayerRewardStatusCollected()
    self.newPlayerRewardStatus = RewardStatus.COLLECTED
end

function FriendsInviteModel:IsNewPlayerRewardCollected()
    return tonumber(self.newPlayerRewardStatus) ==  RewardStatus.COLLECTED
end

function FriendsInviteModel:GetPlayerInfoModel()
    return self.playerInfoModel or PlayerInfoModel.new()
end

function FriendsInviteModel:IsShowInputCodeView()
    local playerInfoModel = self:GetPlayerInfoModel()
    local playerLvl = playerInfoModel:GetLevel()
    local playerCreateTime = playerInfoModel:GetCreateTime()
    local collectLimitTime = playerCreateTime + NewPlayerReward[defaultID].duration * hourSeconds
    local serverTimeNow = self:GetServerTimeNow()

    local isNewPlayerRewardCollected = self:IsNewPlayerRewardCollected()
    local isPlayerLvlQualified = playerLvl <= NewPlayerReward[defaultID].levelHigh
    local isCreateTimeQualified = serverTimeNow < collectLimitTime

    local isShowInputCodeView = not isNewPlayerRewardCollected and isPlayerLvlQualified and isCreateTimeQualified
    return isShowInputCodeView
end

function FriendsInviteModel:GetNewPlayerReward()
    return NewPlayerReward[defaultID].contents
end

function FriendsInviteModel:GetInviteRecordList()
    return  self.sortedRecordList or {}
end

function FriendsInviteModel:HasPlayerBeenInvited()
    local hasPlayerBeenInvited = next(self.friendsDiaRewardList)
    return hasPlayerBeenInvited
end

return FriendsInviteModel