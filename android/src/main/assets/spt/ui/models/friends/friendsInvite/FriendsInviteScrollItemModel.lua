local RewardStatus = require("ui.models.friends.RewardStatus")
local RewardItemViewModel = require("ui.models.quest.RewardItemViewModel")

local FriendsInviteScrollItemModel = class(RewardItemViewModel)

function FriendsInviteScrollItemModel:ctor(data)
    assert(type(data) == "table", "data error!!!")
    self.itemData = data
    FriendsInviteScrollItemModel.super.ctor(self, data)
end

function FriendsInviteScrollItemModel:Init()
end

function FriendsInviteScrollItemModel:GetTaskType()
    return self.itemData.taskFirstType
end

function FriendsInviteScrollItemModel:GetTaskDesc()
    return self.itemData.taskDesc
end

function FriendsInviteScrollItemModel:GetTaskFirstParam()
    return self.itemData.taskParam1
end

function FriendsInviteScrollItemModel:GetTaskSecondParam()
    return self.itemData.taskParam2
end

function FriendsInviteScrollItemModel:GetProgressValue()
    return self.itemData.progressValue
end

function FriendsInviteScrollItemModel:IsDiamondCollected()
    return self.itemData.rd > RewardStatus.COLLECTED
end

function FriendsInviteScrollItemModel:IsDiamondCollectable()
    local serverTimeNow = self:GetServerTimeNow()
    return self.itemData.collectTime <= serverTimeNow
end

function FriendsInviteScrollItemModel:IsDiamondLessThanOne()
    local one = 1
    return self.itemData.rtnDia < one
end

function FriendsInviteScrollItemModel:GetCountDownTime()
    local serverTimeNow = self:GetServerTimeNow()
    return self.itemData.collectTime - serverTimeNow
end

function FriendsInviteScrollItemModel:GetLogoData()
    return self.itemData.logo
end

function FriendsInviteScrollItemModel:GetPlayerName()
    return self.itemData.name or ""
end

function FriendsInviteScrollItemModel:GetPlayerLvl()
    return self.itemData.lvl or 0
end

function FriendsInviteScrollItemModel:GetConsumeDia()
    return self.itemData.cd or 0
end

function FriendsInviteScrollItemModel:GetRtnDia()
    return self.itemData.rtnDia
end

function FriendsInviteScrollItemModel:GetServerTimeNow()
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = os.time() + tonumber(deltaTimeValue)
    return serverTimeNow
end

function FriendsInviteScrollItemModel:GetTaskID()
    return self.itemData.taskID
end

function FriendsInviteScrollItemModel:GetOtherPlayerPID()
    return self.itemData.pid
end

function FriendsInviteScrollItemModel:SetOtherTaskRewardStatus(newStatus)
    self.itemData.status = newStatus
end

function FriendsInviteScrollItemModel:SetDiaTaskRewardStatus(collectTime)
    self.itemData.rd = collectTime
    self.itemData.status = RewardStatus.COLLECTED
end

return FriendsInviteScrollItemModel