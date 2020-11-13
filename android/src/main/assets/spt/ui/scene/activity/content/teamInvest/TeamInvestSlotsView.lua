local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local RectTransformUtility = UnityEngine.RectTransformUtility
local TeamInvestSlotsView = class(unity.base)

function TeamInvestSlotsView:ctor()
    self.rollObjects = self.___ex.rollObjects
    self.maxSpeed = 60 -- 转轮的最大速度
    self.speed = 0 -- 转轮的当前速度
    self.acceleration = 0.1 -- 加速度
    self.stopSpeed = 15 -- 减速到的目标速度
    self.stopDis = 20 -- 减速到的目标距离
    self.timeRate = 10000 -- 每帧的时间（deltaTime）乘以这个常量保证单位时间内的距离是一样的
end

local RollData =
{
    { key = "p6", positionX = 0, positionY = 586, scale = 0.95, order = 1 },
    { key = "p7", positionX = 0, positionY = 442, scale = 0.95, order = 2 },
    { key = "p8", positionX = 0, positionY = 298, scale = 0.95, order = 3 },
    { key = "p9", positionX = 0, positionY = 154, scale = 0.95, order = 4 },
    { key = "p0", positionX = 0, positionY = 10, scale = 1, order = 5 },
    { key = "p1", positionX = 0, positionY = -134, scale = 0.95, order = 6 },
    { key = "p2", positionX = 0, positionY = -278, scale = 0.95, order = 7 },
    { key = "p3", positionX = 0, positionY = -422, scale = 0.95, order = 8},
    { key = "p4", positionX = 0, positionY = -566, scale = 0.95, order = 9 },
    { key = "p5", positionX = 0, positionY = -710, scale = 0.95, order = 10 },
}

function TeamInvestSlotsView:Init(index)
    self.rolling = false
    self.dataCount = #RollData
    if type(index) == "number" then
        index = index + 1
        self.interData = self:GetPosTable(index)
    else
        index = 1
        self.interData = clone(RollData)
    end
    for i,v in ipairs(self.interData) do
        local obj = self.rollObjects[v.key]
        obj.transform.anchoredPosition = Vector2(v.positionX, v.positionY)
    end
    self.currentIndex = index
end

function TeamInvestSlotsView:Stop(index, callBack)
    local index = index or 1
    self:StopRolling(index, callBack)
end

function TeamInvestSlotsView:StartRolling()
    self.rolling = true
    self.speed = 0
    local isSpeeding = true
    self.autoRollingCoroutine = self:coroutine(function()
        while self.rolling do
            if isSpeeding and self.speed < self.maxSpeed then
                self.speed = math.clamp(self.speed + self.acceleration * Time.deltaTime * self.timeRate, 0, self.maxSpeed)
            else
                isSpeeding = false
            end
            self:Rolling()
            coroutine.yield()
        end
    end)
end

function TeamInvestSlotsView:StopRolling(index, callBack)
    index = index + 1
    local endPosTable = self:GetPosTable(index)
    local endY = endPosTable[index].positionY
    local key = endPosTable[index].key
    if self.autoRollingCoroutine then
        self:StopCoroutine(self.autoRollingCoroutine)
    end
    self.autoStopCoroutine = self:coroutine(function()
        while self.rolling do
            self.speed = math.clamp(self.speed - self.acceleration * Time.deltaTime * self.timeRate, self.stopSpeed, self.speed)
            local nowY = self.rollObjects[key].transform.anchoredPosition.y
            local dis = math.abs(nowY - endY)
            if dis <= self.stopDis then
                self.rolling = false
                for i,v in ipairs(endPosTable) do
                    local obj = self.rollObjects[v.key]
                    obj.transform.anchoredPosition = Vector2(v.positionX, v.positionY)
                end
                self.interData = endPosTable
                if type(callBack) == "function" then
                    callBack()
                end
            else
                self:Rolling()
                coroutine.yield()
            end
        end
        self.speed = 0
    end)
end

function TeamInvestSlotsView:GetPosTable(index)
    local posData = {}
    for i = 1, self.dataCount, 1 do
        local dataIndex = (i + index - 1) % self.dataCount
        if dataIndex == 0 then
            dataIndex = self.dataCount
        end
        local tempData = {}
        tempData.key = RollData[dataIndex].key
        tempData.positionX = RollData[i].positionX
        tempData.positionY = RollData[i].positionY
        tempData.scale = RollData[i].scale
        tempData.order = RollData[i].order
        posData[dataIndex] = tempData
    end
    return posData
end

function TeamInvestSlotsView:RollingToIndexImmediately(index)
    self.rolling = false
    if self.autoRollingCoroutine then
        self:StopCoroutine(self.autoRollingCoroutine)
    end
end

function TeamInvestSlotsView:ChangeScrollText()
    self.scorllRandomIndex = math.random(1, self.rollRingCtrl.elementCount)
    self.scrollButton.transform:GetChild(0):GetComponent(Text).text = 'ScrollTo' .. self.scorllRandomIndex
end

function TeamInvestSlotsView:StopAllRollingCoroutine()
    if self.autoRollingCoroutine then
        self:StopCoroutine(self.autoRollingCoroutine)
    end
    if self.autoStopCoroutine then
        self:StopCoroutine(self.autoStopCoroutine)
    end
end

function TeamInvestSlotsView:Rolling()
    for i = 1, self.dataCount do
        local pY = self.interData[i].positionY - self.speed
        if pY <= RollData[self.dataCount].positionY then
            local key = self.interData[i].key
            local detlaY = self.rollObjects[key].transform.sizeDelta.y
            pY = RollData[1].positionY + detlaY
        end
        self.interData[i].positionY = pY
    end
    for i,v in ipairs(self.interData) do
        local obj = self.rollObjects[v.key]
        obj.transform.anchoredPosition = Vector2(v.positionX, v.positionY)
    end
end

return TeamInvestSlotsView
