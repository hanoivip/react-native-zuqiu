local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Time = UnityEngine.Time
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local PowerNumberCache = require("ui.scene.cardDetail.PowerNumberCache")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PowerView = class(unity.base)

function PowerView:ctor()
    self.powerParent = self.___ex.powerParent
    self.powerMap = {}
    self.count = 0
    self.prePower = nil
    self.powerNumberCache = PowerNumberCache.new()
end

function PowerView:InitWithProtocol(time, intervalTime)
    self.time = time
    self.intervalTime = intervalTime
end

function PowerView:InitPowerEffect(powerNums, intervalValue, maxValue, crossTime, time, intervalTime)
    local powerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/PowerEffect.prefab")
    for i = powerNums, 1, -1 do
        if not self.powerMap[i] then
            local obj = Object.Instantiate(powerRes)
            obj.transform:SetParent(self.powerParent, false)
            obj.transform:SetSiblingIndex(powerNums - i + 1)
            local effectScript = res.GetLuaScript(obj)
            effectScript:InitWithProtocol(intervalValue, maxValue, crossTime, self.powerNumberCache, true)
            self.powerMap[i] = effectScript
        else
            local obj = self.powerMap[i].gameObject
            obj.transform:SetSiblingIndex(powerNums - i + 1)
            GameObjectHelper.FastSetActive(obj, true)
        end
    end

    for i = powerNums + 1, table.nums(self.powerMap), 1 do
        GameObjectHelper.FastSetActive(self.powerMap[i].gameObject, false)
    end
    self:InitWithProtocol(time, intervalTime)
end

function PowerView:InitPower(power, isInit)
    self.valueMap = {}
    local powerValue = power
    while powerValue > 0 do
        local value = powerValue % 10
        table.insert(self.valueMap, value)
        powerValue = math.floor(powerValue / 10)
    end
    
    if not isInit and self.prePower and self.prePower ~= power then 
        self:InitChangePower(self.valueMap)
    else
        self:InitFirstPower(self.valueMap)
    end
    self.prePower = power
end

-- 战斗力改变保持翻牌状态
function PowerView:InitChangePower(valueMap)
    local count = table.nums(valueMap)
    for index, v in pairs(self.powerMap) do
        local number = 0
        if index <= count then 
            number = valueMap[index]
            v:PlayCrossAnimation(number)
        else
            v:SetDefaultValue(number)
        end
    end
    local maxCount = #self.powerMap
    self.count = count > maxCount and maxCount or count
    self.startTime = 0
end

-- 首次设置战斗力保持静止状态
function PowerView:InitFirstPower(valueMap)
    local count = table.nums(valueMap)
    for index, v in pairs(self.powerMap) do
        local number = 0
        if index <= count then 
            number = valueMap[index]
        end
        v:SetDefaultValue(number)
    end
end

-- * Dotween 与 协程有隐患，会在不确定时刻终止协程 改用update
function PowerView:update() 
    if self.count > 0 then
        if Time.realtimeSinceStartup - self.startTime >= self.intervalTime then
            local value = self.valueMap[self.count]
            self.powerMap[self.count]:InitView(value, self.time)
            self.count = self.count - 1
            self.startTime = Time.realtimeSinceStartup
        end
    end
end

return PowerView
