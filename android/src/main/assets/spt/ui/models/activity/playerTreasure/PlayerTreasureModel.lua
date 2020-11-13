local ActivityModel = require("ui.models.activity.ActivityModel")
local LoginModel = require("ui.models.login.LoginModel")
local PlayerTreasureModel = class(ActivityModel)

PlayerTreasureModel.MAX_BOX_COUNT = 6
PlayerTreasureModel.MAX_OPEN_COUNT = 3

function PlayerTreasureModel:ctor(data)
    PlayerTreasureModel.super.ctor(self, data)
    self.singleData = self:GetActivitySingleData()
end

function PlayerTreasureModel:InitWithProtocol()
    self.singleData = self:GetActivitySingleData()
end

-- 当前持有的钥匙数量
function PlayerTreasureModel:GetKeysCount()
    return self.singleData.p_data.keysCount
end

-- 刷新持有的钥匙数量
function PlayerTreasureModel:SetKeysCount(count)
    if type(count) == "number" then
        self.singleData.p_data.keysCount = count
    end
end

-- 钥匙单价
function PlayerTreasureModel:GetKeysPrice()
    return self.singleData.keyPrice
end

-- 当前活动的期数
function PlayerTreasureModel:GetPeriod()
    return self.singleData.p_data.period
end

-- 最大刷新次数
function PlayerTreasureModel:GetMaxRefreshCount()
    return self.singleData.refreshCount
end

-- 刷新价格
function PlayerTreasureModel:GetRefreshPrice()
    return self.singleData.refreshPrice
end

-- 当前领取的次数
function PlayerTreasureModel:GetBoxOpenCount()
    return self.singleData.p_data.value
end

-- 显示箱子的最大数量
function PlayerTreasureModel:GetMaxBoxCount()
    return PlayerTreasureModel.MAX_BOX_COUNT
end

-- 显示所有可能的奖励
function PlayerTreasureModel:GetAllTreasureBonus()
    sortTable = {}
    for k,v in pairs(self.singleData.cfgBonus) do
        local  temp = {}
        temp.value = v
        temp.sortId = tonumber(k)
        table.insert(sortTable, temp)
    end
    table.sort(sortTable, function(a, b) return a.sortId < b.sortId end)
    local cfgBonus = {}
    for i,v in ipairs(sortTable) do
        table.insert(cfgBonus, v.value)
    end
    return cfgBonus
end

-- 显示一键开启所需的钥匙数量
function PlayerTreasureModel:GetNeedOpenCount()
    local treasureRedeemed = self.singleData.p_data.treasureRedeemed
    local nowOpenCount = #treasureRedeemed
    return PlayerTreasureModel.MAX_OPEN_COUNT - nowOpenCount
end

-- 显示一键开启所需的钥匙数量
function PlayerTreasureModel:ResetAvtivityData(refreshData)
    self.singleData.p_data.treasureRedeemed = refreshData.treasureRedeemed
    self.singleData.p_data.treasures = refreshData.treasures

    if refreshData.dayTipsRedeem ~= nil then
        self.singleData.p_data.dayTipsRedeem = refreshData.dayTipsRedeem
    end

    if refreshData.dayTipsRefresh ~= nil then
        self.singleData.p_data.dayTipsRefresh = refreshData.dayTipsRefresh
    end

    if type(refreshData.keysCount) == "number" then
        self.singleData.p_data.keysCount = refreshData.keysCount
    end
    if type(refreshData.value) == "number" then
        self.singleData.p_data.value = refreshData.value
    end
    self.singleData.taskRedPoint = refreshData.taskRedPoint
end

-- 通过两次已领取数据的对比来获得这次的领取奖励
function PlayerTreasureModel:GetReward(newTreasureRedeemed)
    local oldTreasureRedeemed = {}
    for i,v in ipairs(self.singleData.p_data.treasureRedeemed) do
        local rewardID = v.rewardID
        oldTreasureRedeemed[rewardID] = v
    end
    local reward = {}
    for i,v in ipairs(newTreasureRedeemed) do
        local rewardID = v.rewardID
        if not oldTreasureRedeemed[rewardID] then
            for k,v in pairs(v.contents) do
                if type(v) == "number" then
                    reward[k] = tonumber(reward[k]) + v
                else
                    if not reward[k] then
                        reward[k] = {}
                    end
                    for key,value in ipairs(v) do
                        table.insert(reward[k], value)
                    end
                end
            end
        end
    end
    return reward
end

-- 获取一键开启索引
function PlayerTreasureModel:GetOpenAllIndex()
    local treasures = self:GetTreasureList()
    local treasureRedeemed = {}
    local redeemedCount = 0
    for i,v in ipairs(self.singleData.p_data.treasureRedeemed) do
        local index = v.index
        treasureRedeemed[index] = v
        redeemedCount = redeemedCount + 1
    end
    local indexTable = {}
    for i, v in ipairs(treasures) do
        if not treasureRedeemed[i] then
            local tempIndex = {}
            tempIndex.index = i
            tempIndex.randomId = math.random(123)   -- 随机一下索引
            table.insert(indexTable, tempIndex)
        end
    end
    table.sort(indexTable, function(a, b) return a.randomId > b.randomId end)
    local openedCount = self:GetNeedOpenCount()
    local indexs = {}
    for i,v in ipairs(indexTable) do
        if i <= openedCount then
            table.insert(indexs, v.index)
        end
    end
    return indexs
end

-- 根据箱子的index返回箱子是否已经被打开
function PlayerTreasureModel:GetBoxState(index)
    local treasureRedeemed = self.singleData.p_data.treasureRedeemed
    if treasureRedeemed then
        for i,v in ipairs(treasureRedeemed) do
            if v.index == index then
                return true
            end
        end
        return false
    else
        return false
    end
end

-- 抽取次数奖励列表（包含奖励内容和已领取没领取的奖励）
function PlayerTreasureModel:GetCountList()
    local cfgCount = self:GetConfigCount()
    local countRedeemed = self:GetRedeemedCount()
    local nowCount = self:GetBoxOpenCount()
    local sortCount = {}
    for k,v in pairs(cfgCount) do
        local tempCount = v
        tempCount.count = tonumber(k)
        if countRedeemed[k] then
            tempCount.status = 1
        else
            if tempCount.count <= nowCount then
                tempCount.status = 0
            else
                tempCount.status = -1
            end
        end
        table.insert(sortCount, tempCount)
    end
    table.sort(sortCount, function(a, b) return tonumber(a.count) < tonumber(b.count) end)
    return sortCount
end

-- 箱子内容列表(会标记 receiveStatus)
function PlayerTreasureModel:GetTreasureList()
    local treasures = self.singleData.p_data.treasures
    local redeemed = {}
    local treasureRedeemed = self.singleData.p_data.treasureRedeemed
    for i,v in ipairs(treasureRedeemed) do
        local rewardID = v.rewardID
        redeemed[rewardID] = v
    end
    local treasuresList = {}
    for k,v in pairs(treasures) do
        local receiveStatus = false
        local rewardID = v.rewardID
        if redeemed[rewardID] then
            receiveStatus = true
        end
        local tempData = v
        v.receiveStatus = receiveStatus
        table.insert(treasuresList, tempData)
    end
    table.sort(treasuresList, function(a, b) return tonumber(a.treasureType) < tonumber(b.treasureType) end)
    return treasuresList
end

-- 抽取次数奖励配置列表
function PlayerTreasureModel:GetConfigCount()
    return self.singleData.cfgCount
end

-- 已经抽取次数奖励列表
function PlayerTreasureModel:GetRedeemedCount()
    return self.singleData.p_data.countRedeemed
end

-- 将抽取次数宝箱根据id进行重置
function PlayerTreasureModel:RefreshRedeemed(countRedeemed)
    if type(countRedeemed) == "table" then
        self.singleData.p_data.countRedeemed = countRedeemed
    end
end

-- 获取任务红点状态
function PlayerTreasureModel:GetTaskRedPointState()
    return self.singleData.taskRedPoint
end

-- 设置任务红点状态
function PlayerTreasureModel:SetTaskRedPointState(taskRedPointState)
    self.singleData.taskRedPoint = taskRedPointState
end

function PlayerTreasureModel:GetResidualTime()
    return self.singleData.residualTime
end

function PlayerTreasureModel:GetActivityEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.activityEndTime
end

-- 获取活动说明
function PlayerTreasureModel:GetDesc()
    local singleData = self:GetActivitySingleData()
    return singleData.desc
end

-- 获取活动开始时间
function PlayerTreasureModel:GetStartTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

-- 获取活动结束时间
function PlayerTreasureModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

-- 获取活动剩余时间
function PlayerTreasureModel:GetRemainTime()
    local endTime = self:GetEndTime()
    local serverDeltaTime = cache.getServerDeltaTimeValue() or 0
    local osTime = os.time() + serverDeltaTime
    local remainTime = endTime - osTime
    if remainTime > 0 then
        return remainTime
    else
        return 0
    end
end

-- 获取每日提示的状态
function PlayerTreasureModel:GetDayTipsState(tipsKey)
    local singleData = self:GetActivitySingleData()
    return singleData.p_data[tipsKey]
end

return PlayerTreasureModel
