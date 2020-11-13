local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds

-- 计时器
local Timer = class(nil, "Timer")
local TimerIndex = 0

--- 实例化Timer
-- @param time 时间，类型number
-- @param updateCallback 每次更新时间的回调函数，类型function
-- @param countDownOverCallBack 倒计时结束的一个回调函数
function Timer:ctor(time, updateCallback, countDownOverCallBack)
    self.time = tonumber(time)
    -- 每次更新时间的回调函数
    self.updateCallback = updateCallback
    self.countDownOverCallBack = countDownOverCallBack
    -- 上一次记录的游戏时间
    self.lastRealTime = nil
    -- 当前游戏时间
    self.nowRealTime = nil
    -- 计时器Id
    self.timerId = nil
    -- 是否结束(主动调用结束)
    self.isOver = false

    self:Init()
end

--- 初始化
function Timer:Init()
    self.timerId = Timer.GetTimerId()
    self.lastRealTime = Time.realtimeSinceStartup
    self.nowRealTime = self.lastRealTime

    clr.coroutine(function()
        -- 开始计时循环
        repeat
            self.nowRealTime = Time.realtimeSinceStartup
            self.time = self.time + (self.lastRealTime - self.nowRealTime)
            self.lastRealTime = self.nowRealTime

            self:ExecuteCallback()

            if self.time < 0 then
                self.time = 0
            end
            coroutine.yield(WaitForSeconds(1))
        until self.isOver or self.time == 0

        if type(self.countDownOverCallBack) == "function" then
            self.countDownOverCallBack(self.isOver)
        end
    end)
end

--- 执行回调
function Timer:ExecuteCallback()
    if type(self.updateCallback) == 'function' then
        self.updateCallback(self.time)
    end
end

--- 设置时间
-- @param time 时间，类型number
function Timer:SetTime(time)
    self.time = tonumber(time)
end

--- 获取时间
-- @return number
function Timer:GetTime()
    return self.time
end

--- 销毁计时器
function Timer:Destroy()
    self.isOver = true
    self.updateCallback = nil
    self.timerId = nil
end

function Timer.GetTimerId()
    TimerIndex = TimerIndex + 1
    return "Timer" .. TimerIndex
end

return Timer