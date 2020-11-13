local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local CanvasGroup = UnityEngine.CanvasGroup
local Time = UnityEngine.Time
local RectTransformUtility = UnityEngine.RectTransformUtility
local RollRing = class(unity.base)

local function GetNextIndex(fromRightToLeft, i, ratio, objectCount)
    local nextIndex
    local ratio = ratio % objectCount
    if fromRightToLeft then
        nextIndex = i - ratio
        if nextIndex <= 0 then
            nextIndex = nextIndex + objectCount
        end
    else
        nextIndex = i + ratio
        if nextIndex > objectCount then
            nextIndex = nextIndex % objectCount
        end
    end
    return nextIndex
end

local function GetIntegerPart(x)
    if x < 0 then
        return math.ceil(x)
    else
        return math.floor(x)
    end
end

local function SortWeightAsc(aWeightData, bWeightData)
    if tonumber(aWeightData.scale) == tonumber(bWeightData.scale) then
        return tonumber(aWeightData.positionX) < tonumber(bWeightData.positionX)
    else
        return tonumber(aWeightData.order) < tonumber(bWeightData.order)
    end
end

local function GetRemainPart(x, ratio)
    local value = x % ratio
    if x < 0 then 
        value = value - ratio
    end 
    return value 
end

function RollRing:ctor()
    self.isAutoRolling = false
    self.totalUnitOffset = 0 -- 总偏移单位
    self.originData = { } -- 初始元素数据
    self.rollingData = { } -- 可控元素数据
    self.objectCount = 0 -- 可见元素数量
    self.integer = 0 -- 与初始值对比总偏移整数单位（可变）
    self.intervalTime = 0 -- 每次复位总时间（可变）
    self.totalTime = 0 -- 每次复位总时间
    self.intervalOffset = 0 -- 每次移动单位差值
    self.totalOffset = 0 -- 每次复位总差值   
    self.size = 0 -- 可见元素两边对象数量
    self.distRat = 1
    self.moveMode = "linear"
    self.custonSpeed = self.___ex.custonSpeed or 1000 -- 自定义速度（滑动速度超过则产生惯性）
    self.inertiaRatio = self.___ex.inertiaRatio or 0.5 -- 惯性系数
    self.inertiaTime = self.___ex.inertiaTime or 0.4 -- 惯性时间
    self.disappearRatio = self.___ex.disappearRatio or 0.5 -- 消失线系数
    self.moveTime = self.___ex.moveTime or 0.5 -- 每次复位时间比例
    self.elementCount = self.___ex.elementCount -- 总元素数量
    self.isHorizontal = self.___ex.isHorizontal or true -- 暂时没有竖直方向
end

function RollRing:AddRollRingData(rollRingData)
    table.insert(self.originData, rollRingData)
    table.insert(self.rollingData, clone(rollRingData))
    self.objectCount = self.objectCount + 1
end

function RollRing:ResetItem(script, externalId)
    
end

function RollRing:FaceItemExternalId(externalId) -- 更新面向Item 索引
    
end

function RollRing:start()
end

function RollRing:Init(isInitialize)
    assert(table.nums(self.originData) > 0)
    if self.objectCount % 2 == 0 then 
        self.size = self.objectCount / 2 + 1
    else
        self.size = (self.objectCount + 1) / 2
    end
    -- 设置初始内部ID与外部ID索引
    for i, v in ipairs(self.originData) do
        v.internalId = i
        local externalId = i
        if i > self.size then 
            externalId = self.elementCount - self.objectCount + i
        end
        v.externalId = externalId
        self.rollingData[i].internalId = i
    end
    self:MoveOffset(0, isInitialize) -- 初始化偏移
end

function RollRing:onBeginDrag(eventData)
    local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
    if success then
        self.touchPreLocation = pt
    end
    self.isAutoRolling = false

    self.beginTouch = pt
    self.beginTime = Time.realtimeSinceStartup
end

function RollRing:onDrag(eventData)
    local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
    if success then
        local moveDelta = pt
        local offset = 0
        if self.isHorizontal then 
            offset = (self.touchPreLocation.x - moveDelta.x) * self.distRat
        else
            offset = (self.touchPreLocation.y - moveDelta.y) * self.distRat
        end
        self:SetOffset(offset)
        self.touchPreLocation = pt
    end
end

function RollRing:onEndDrag(eventData)
    local endPos
    local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
    if success then
        endPos = pt
    end
    local useTime = Time.realtimeSinceStartup - self.beginTime
    local distance
    if self.isHorizontal then
        distance = (endPos.x - self.beginTouch.x) * self.distRat
    else
        distance = (endPos.y - self.beginTouch.y) * self.distRat
    end
    local speed = distance / useTime

    if math.abs(speed) > self.custonSpeed then
        local offset = self.totalUnitOffset - speed / self.custonSpeed * self.inertiaRatio
        local finalUnit = math.round(offset)
        self:AutoRollByInertia(finalUnit, self.inertiaTime)
    else
        local finalUnit = math.round(self.totalUnitOffset)
        if finalUnit ~= self.totalUnitOffset then
            self:AutoRollByOffset(finalUnit)
        end
    end
end

------------
-- 滑动速度超过自定义速度时产生惯性
------------
function RollRing:AutoRollByInertia(finalUnit, customTime)
    self.intervalOffset = finalUnit - self.totalUnitOffset
    self.totalOffset = self.intervalOffset 
    self.intervalTime = customTime
    self.totalTime = self.intervalTime
    self.isAutoRolling = true
    self:UpdateOffset()
end

function RollRing:AutoRollByOffset(finalUnit, customTime)
    self.intervalOffset = finalUnit - self.totalUnitOffset
    self.totalOffset = self.intervalOffset % self.elementCount
    if math.abs(self.totalOffset) > self.elementCount / 2 then
        self.totalOffset = self.totalOffset - self.elementCount
    end
    if customTime then 
        self.intervalTime = customTime
    else
        self.intervalTime = math.abs(self.totalOffset * self.moveTime)
    end
    self.totalTime = self.intervalTime
    self.isAutoRolling = true
    self:UpdateOffset()
end

function RollRing:RollNextItem()
    local nextUnitOffset = math.round(self.totalUnitOffset + 1)
    self:AutoRollByOffset(nextUnitOffset)
end

function RollRing:RollPreItem()
    local preUnitOffset = math.round(self.totalUnitOffset - 1)
    self:AutoRollByOffset(preUnitOffset)
end

function RollRing:RollToItemImmediately(externalIndex)
    assert(externalIndex <= self.elementCount and externalIndex > 0, "Invalid index = " .. externalIndex)
    local unitOffset = math.floor(externalIndex - 1)
    local offset = unitOffset - self.totalUnitOffset
    self:MoveOffset(offset)
    self.isAutoRolling = false
end

function RollRing:RollToItem(externalIndex, customTime)
    assert(externalIndex <= self.elementCount and externalIndex > 0, "Invalid index = " .. externalIndex)
    self:AutoRollByOffset(externalIndex - 1, customTime)
end

------------
-- 滑动坐标差值转化成单位区间向量
------------
function RollRing:SetOffset(offset)
    if offset == 0 then return end
    local distance = self.isHorizontal and self.transform.rect.width or self.transform.rect.height
    local percent = offset / distance
    local unit = percent * self.elementCount
    self:MoveOffset(unit)
end

------------
-- 顺时针为正方向
------------
function RollRing:MoveOffset(unit, isInitialize)
    self.totalUnitOffset = self.totalUnitOffset + unit
    self.integer = GetIntegerPart(self.totalUnitOffset)
    local positiveInteger = math.abs(self.integer)
    local fromRightToLeft = self.totalUnitOffset > 0 and true or false
    for i, v in ipairs(self.rollingData) do
        -- 计算整数部分
        local nextIndex = GetNextIndex(fromRightToLeft, v.internalId, positiveInteger, self.objectCount)
        v.positionX = self.originData[nextIndex].positionX
        v.positionY = self.originData[nextIndex].positionY
        v.alpha = self.originData[nextIndex].alpha
        v.scale = self.originData[nextIndex].scale
        v.order = self.originData[nextIndex].order
        if self.additionIntegerDataFunc then
            self.additionIntegerDataFunc(v, nextIndex, self.originData)
        end
    end

    local decimal = math.abs(self.totalUnitOffset - self.integer)
    if self.moveMode == "linear" then
        local t = decimal
        local cacheRollingData = clone(self.rollingData)
        for i, v in ipairs(self.rollingData) do
            -- 小数部分采用两个相邻对象之间比例值
            local nextIndex = GetNextIndex(fromRightToLeft, i, 1, self.objectCount)
            v.positionX = cacheRollingData[i].positionX * (1 - t) + cacheRollingData[nextIndex].positionX * t
            v.positionY = cacheRollingData[i].positionY * (1 - t) + cacheRollingData[nextIndex].positionY * t
            v.alpha = cacheRollingData[i].alpha * (1 - t) + cacheRollingData[nextIndex].alpha * t
            v.scale = cacheRollingData[i].scale * (1 - t) + cacheRollingData[nextIndex].scale * t
            v.order = cacheRollingData[i].order * (1 - decimal) + cacheRollingData[nextIndex].order * decimal
            if self.additionDecimalDataFunc then
                self.additionDecimalDataFunc(i, nextIndex, t, v, cacheRollingData)
            end
        end
    elseif self.moveMode == "arc" then
        local t = decimal / math.sqrt(math.pow(decimal, 2) + math.pow(1 - decimal, 2)) -- 映射到圆轨迹上更加平滑
        local cacheRollingData = clone(self.rollingData)
        for i, v in ipairs(self.rollingData) do
            local nextIndex = GetNextIndex(fromRightToLeft, i, 1, self.objectCount)

            local x1 = cacheRollingData[i].positionX - self.centerPos.x
            local y1 = cacheRollingData[i].positionY - self.centerPos.y
            local x2 = cacheRollingData[nextIndex].positionX - self.centerPos.x
            local y2 = cacheRollingData[nextIndex].positionY - - self.centerPos.y
            
            if math.abs(x1) == math.abs(x2) or math.abs(y1) == math.abs(y2) then
                v.positionX = cacheRollingData[i].positionX * (1 - t) + cacheRollingData[nextIndex].positionX * t
                v.positionY = cacheRollingData[i].positionY * (1 - t) + cacheRollingData[nextIndex].positionY * t
                dump("Error: the same x or y found in adjacent nodes : index = " .. i)
            else
                local a, b
                local theta1, theta2, tempTheta

                local deltaXY = math.pow(x1 * y2, 2) - math.pow(x2 * y1, 2)
                local a = math.sqrt(deltaXY / (math.pow(y2, 2) - math.pow(y1, 2)))
                local b = math.sqrt(deltaXY / (math.pow(x1, 2) - math.pow(x2, 2)))

                if y1 >= 0 then theta1 = math.acos(x1 / a) else theta1 = -math.acos(x1 / a) + 2 * math.pi end
                if y2 >= 0 then theta2 = math.acos(x2 / a) else theta2 = -math.acos(x2 / a) + 2 * math.pi end
                if theta2 - theta1 > math.pi then
                    theta2 = theta2 - math.pi * 2
                end

                if theta1 - theta2 > math.pi then
                    theta1 = theta1 - math.pi * 2
                end
                tempTheta = math.lerp(theta1, theta2, decimal)

                v.positionX = a * math.cos(tempTheta) + self.centerPos.x
                v.positionY = b * math.sin(tempTheta) + self.centerPos.y
            end

            v.alpha = cacheRollingData[i].alpha * (1 - t) + cacheRollingData[nextIndex].alpha * t
            v.scale = cacheRollingData[i].scale * (1 - t) + cacheRollingData[nextIndex].scale * t
            v.order = cacheRollingData[i].order * (1 - decimal) + cacheRollingData[nextIndex].order * decimal
            if self.additionDecimalDataFunc then
                self.additionDecimalDataFunc(i, nextIndex, t, v, cacheRollingData)
            end
        end
    end

    self:DrawEffects(self.rollingData)
    self:RefreshItem(isInitialize)
end

function RollRing:RefreshItem(isInitialize)
    local baseId = math.floor(self.totalUnitOffset + self.disappearRatio) 
    local frontId = baseId % self.elementCount 
    local offsetIndex = baseId % self.objectCount
    for i, v in ipairs(self.rollingData) do
        v.sortId = v.internalId - offsetIndex
        if v.sortId <= 0 then 
            v.sortId = v.sortId + self.objectCount
        end 
    end
    table.sort(self.rollingData, function(a, b) return a.sortId < b.sortId end)
    for i, v in ipairs(self.rollingData) do
        local newExternalId 
        if i > self.size then 
            newExternalId = frontId - (self.objectCount - i)
        else
            newExternalId = frontId + i 
        end

        if newExternalId <= 0 then
            newExternalId = newExternalId + self.elementCount
        elseif newExternalId > self.elementCount then 
            newExternalId = newExternalId % self.elementCount
        end 

        if v.externalId ~= newExternalId or isInitialize then 
            v.externalId = newExternalId
            self:ResetItem(v.script, newExternalId)
        end
    end
    self:FaceItemExternalId(frontId + 1)
end

function RollRing:DrawEffects(rollingData) -- 更新效果
    table.sort(rollingData, SortWeightAsc)
    for i, v in ipairs(rollingData) do
        local obj = v.object
        local scale = v.scale
        local alpha = v.alpha
        if obj.transform:GetSiblingIndex() ~= i - 1 then 
            obj.transform:SetSiblingIndex(i - 1)
        end
        obj.transform.localScale = Vector3(scale, scale, scale)
        obj.transform.anchoredPosition = Vector2(v.positionX, v.positionY)
        if obj and obj:GetComponent(CanvasGroup) and obj:GetComponent(CanvasGroup) ~= clr.null then
            obj:GetComponent(CanvasGroup).alpha = alpha
        end
        if self.additionDrawFunc then
            self.additionDrawFunc(v, obj)
        end
    end
end

function RollRing:UpdateOffset()
    if self.autoRollingCoroutine then
        self:StopCoroutine(self.autoRollingCoroutine)
    end
    self.autoRollingCoroutine = self:coroutine(function()
        while self.isAutoRolling do 
            if self.intervalTime <= 0 then 
                self.isAutoRolling = false
                self.totalOffset = 0
            else
                if self.intervalTime < Time.unscaledDeltaTime then
                    self:MoveOffset(self.intervalOffset)
                    self.totalOffset = 0
                else
                    local offset = self.totalOffset / self.totalTime * (2 * self.intervalTime - Time.unscaledDeltaTime) / self.totalTime * Time.unscaledDeltaTime
                    self:MoveOffset(offset)
                    self.intervalOffset = self.intervalOffset - offset
                end
                self.intervalTime = self.intervalTime - Time.unscaledDeltaTime
            end
            coroutine.yield()
        end
    end)
end

function RollRing:AddIntegerDataFunc(func)
    if type(func) == "function" then
        self.additionIntegerDataFunc = func
    end
end

function RollRing:AddDecimalDataFunc(func)
    if type(func) == "function" then
        self.additionDecimalDataFunc = func
    end
end

function RollRing:AddDrawFunc(func)
    if type(func) == "function" then
        self.additionDrawFunc = func
    end
end

function RollRing:SetDistRat(ratio)
    self.distRat = ratio
end

function RollRing:SetMoveMode(mode, centerPos)
    if mode == "linear" or mode == "arc" then
        self.moveMode = mode
        self.centerPos = centerPos
        return true
    end
    return false
end

return RollRing
