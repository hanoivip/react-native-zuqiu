local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local TweenExtensions = Tweening.TweenExtensions
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local PowerEffect = class(unity.base)

-- 影子系数
local ShadowStartRatio = 0.3 -- @param ShadowStartRatio 影子起始系数
local ShadowEndRatio = 0.7 -- @param ShadowEndRatio 影子结束系数
local ShadowStartValue = 0.1 -- @param ShadowStartRatio 影子在起始系数时所处大小
local ShadowEndValue = 1 -- @param ShadowEndValue 影子在结束系数时所处大小

local ShadowColorStartRatio = 0.3 -- @param ShadowColorStartRatio 影子起始系数
local ShadowColorEndRatio = 0.7 -- @param ShadowColorEndRatio 影子结束系数
local ShadowColorStartValue = 0.1 -- @param ShadowColorStartValue 影子在起始系数时所处大小
local ShadowColorEndValue = 1 -- @param ShadowColorEndValue 影子在结束系数时所处大小
local function GetShadowRatio(startValue, endValue, startRatio, endRatio)
    local ratioA, ratioB
    ratioA = (startValue - endValue) / (startRatio - endRatio) 
    ratioB = endValue - endRatio * ratioA
    return ratioA, ratioB
end

function PowerEffect:ctor()
    self.nextValue = self.___ex.nextValue
    self.midValue = self.___ex.midValue
    self.topValue = self.___ex.topValue
    self.shadow = self.___ex.shadow
    self.moveObject = self.___ex.moveObject
    self.shadowHeight = self.shadow and self.shadow.transform.rect.height
    self.shadowRatioA, self.shadowRatioB = GetShadowRatio(ShadowStartValue, ShadowEndValue, ShadowStartRatio, ShadowEndRatio)
    self.shadowColorRatioA, self.shadowColorRatioB = GetShadowRatio(ShadowColorStartValue, ShadowColorEndValue, ShadowColorStartRatio, ShadowColorEndRatio)
end

function PowerEffect:InitWithProtocol(intervalValue, maxValue, crossTime, powerNumberCache, isShowShadow)
    self.intervalValue = intervalValue
    self.maxValue = maxValue
    self.crossTime = crossTime
    self.powerNumberCache = powerNumberCache
    self.isShowShadow = isShowShadow
end

local function KillEffect(tweener)
    if tweener then 
        TweenExtensions.Kill(tweener)
    end
end

-- 得到每翻一次的时间起点(使用tween计算公式)
local function GetIntervalTimeByCirc(startTime, endTime, ratio)
    local time = - (endTime - startTime) * (math.sqrt(1 - ratio * ratio) - 1) + startTime
    return time
end

local function GetIntervalTimeByQuad(startTime, endTime, ratio)
    endTime = endTime - startTime
    local time = endTime * ratio * ratio + startTime
    return time
end

local function GetIntervalTimeByCubic(startTime, endTime, ratio)
    endTime = endTime - startTime
    local time = endTime * ratio * ratio * ratio + startTime
    return time
end

local function GetIntervalTimeByQuart(startTime, endTime, ratio)
    endTime = endTime - startTime
    local time = endTime * ratio * ratio * ratio * ratio + startTime
    return time
end

local function GetIntervalTimeByQuint(startTime, endTime, ratio)
    endTime = endTime - startTime
    local time = endTime * ratio * ratio * ratio * ratio * ratio + startTime
    return time
end

local function GetIntervalTimeBySine(startTime, endTime, ratio)
    endTime = endTime - startTime
    local time = - endTime * math.cos(ratio *(math.pi * 0.5)) + endTime + startTime
    return time
end

local function GetIntervalTimeByBack(startTime, endTime, ratio)
    endTime = endTime - startTime
    local s = 1.70158
    local time = endTime * ratio * ratio *((s + 1) * ratio - s) + startTime
    return time
end

-- 得到每翻一次的时间系数
local function GetIntervalRatio(index, totalValue)
    local ratio = (index - 1) / totalValue 
    return ratio
end

function PowerEffect:InitView(number, time)
    self.time = time
    local startNumber = number - self.intervalValue
    if startNumber < 0 then 
        startNumber = startNumber + self.maxValue
    end
    
    self.startIndex = 1
    self:SetAppointValue(startNumber, number)
end

-- 得到每翻一次的使用时间
function PowerEffect:GetUseTime(startIndex)
    local preTime, nextTime, useTime
    local preRatio = GetIntervalRatio(startIndex, self.intervalValue)
    preTime = GetIntervalTimeByBack(0, self.time, preRatio)

    local nextIndex = startIndex + 1
    if nextIndex > self.intervalValue then 
        nextTime = self.time
    else
        local nextRatio = GetIntervalRatio(nextIndex, self.intervalValue)
        nextTime = GetIntervalTimeByBack(0, self.time, nextRatio) 
    end

    useTime = nextTime - preTime
    return useTime
end

function PowerEffect:SetAppointValue(number, appointNumber)
    local time = self:GetUseTime(self.startIndex)
    self:SetRotateEffect(number, appointNumber, time, true)
    self.startIndex = self.startIndex + 1
end

-- 战力翻动效果
function PowerEffect:SetRotateEffect(number, appointNumber, time, isAppoint)
    local nextValue = number 
    self:SetDefaultValue(number)
    self.rotateInTweener = ShortcutExtensions.DOAnchorPosX(self.moveObject, 1, time)
    TweenSettingsExtensions.SetEase(self.rotateInTweener, Ease.Linear)
    TweenSettingsExtensions.SetAutoKill(self.rotateInTweener, false)
    TweenSettingsExtensions.OnUpdate(self.rotateInTweener, function ()  --Lua assist checked flag
        self.topValue.progress = self.moveObject.anchoredPosition.x
        if self.topValue.progress >= ShadowStartRatio then -- 设置影子
            self:SetShadow(self.topValue.progress)
        end
    end)
    TweenSettingsExtensions.OnComplete(self.rotateInTweener, function()  --Lua assist checked flag
        nextValue = number + 1
        if nextValue >= self.maxValue then
            nextValue = 0
        end
        if nextValue ~= appointNumber then
            if isAppoint then
                self:SetAppointValue(nextValue, appointNumber)
            else
                self:SetRotateEffect(nextValue, appointNumber, time)
            end
        end
    end)
end

-- 设置影子进度
function PowerEffect:SetShadow(progress)
    if not self.isShowShadow then return end
    local colorRatio = progress >ShadowColorStartRatio and progress * self.shadowColorRatioA + self.shadowColorRatioB or 0
    local maxAplha = colorRatio > ShadowColorEndValue and ShadowColorEndValue or colorRatio
    local ratio = progress > ShadowStartRatio and progress * self.shadowRatioA + self.shadowRatioB or 0
    local maxHeight = ratio * self.shadowHeight > self.shadowHeight and self.shadowHeight or ratio * self.shadowHeight 
    local shadowColor = self.shadow.color 
    self.shadow.color = Color(shadowColor.r, shadowColor.g, shadowColor.b, maxAplha)
    self.shadow.transform.sizeDelta = Vector2(self.shadow.transform.sizeDelta.x, maxHeight)
end

-- 设置默认初始值
function PowerEffect:SetDefaultValue(number)
    KillEffect(self.rotateInTweener)
    local nextValue = number + 1
    if nextValue >= self.maxValue then 
        nextValue = 0
    end
    self.moveObject.anchoredPosition = Vector2.zero
    self.nextValue.overrideSprite = self.powerNumberCache:GetNumberRes(nextValue)
    self.midValue.overrideSprite = self.powerNumberCache:GetNumberRes(number)
    self.topValue.progress = 0
    self:SetShadow(self.topValue.progress)
end

function PowerEffect:PlayCrossAnimation(number)
    self:SetRotateEffect(number, -1, self.crossTime)
end

return PowerEffect
