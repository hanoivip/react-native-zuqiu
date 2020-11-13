local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local EventSystems = UnityEngine.EventSystems
local ExecuteEvents = EventSystems.ExecuteEvents
local IPointerClickHandler = EventSystems.IPointerClickHandler
local UI = UnityEngine.UI
local Text = UI.Text
local Shadow = UI.Shadow
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3
local UISoundManager = require("ui.control.manager.UISoundManager")

local LuaEventTriggerPointerDown = clr.LuaEventTriggerPointerDown
local LuaEventTriggerPointerUp = clr.LuaEventTriggerPointerUp
local LuaEventTriggerPointerClick = clr.LuaEventTriggerPointerClick

local ClickHandler = class(unity.base)
local DefaultScaleRatio = 1
ClickHandler.clickingItems = { }
ClickHandler.frameCount = 0

function ClickHandler:ctor()
    self.down = self.___ex.down
    self.up = self.___ex.up
    self.select = self.___ex.select
    self.scale = self.___ex.scale
    self.scalerRatio = self.___ex.scalerRatio or DefaultScaleRatio
	self.scalerMaxRatio = self.___ex.scalerMaxRatio or DefaultScaleRatio
    self.txt = self.___ex.txt
    self.default_click = self.___ex.click
    self.clicksnd = self.___ex.snd
    self.clickSndVolume = self.___ex.sndVolume

    if type(self.down) ~= 'table' then
        self.down = { }
    end
    if type(self.up) ~= 'table' then
        self.up = { }
    end
    if type(self.scale) ~= 'table' then
        self.scale = { }
    end
    if type(self.txt) ~= 'table' then
        self.txt = { }
    end
    if type(self.default_click) ~= 'table' then
        self.default_click = { }
    end

    self.onButtonClickCallBack = { }
    self.onButtonDownCallBack = { }
    self.onButtonUpCallBack = { }
    self.onButtonBeginDragCallBack = { }
    self.onButtonDragCallBack = { }
    self.onButtonEndDragCallBack = { }
    self.buttonClickTag = 1
    self.buttonUpTag = 1
    self.buttonDownTag = 1
    self.buttonBeginDragTag = 1
    self.buttonDragTag = 1
    self.buttonEndDragTag = 1
    self:touchDown(false)
    if type(self.select) == 'table' and not clr.isobj(self.select) then
        for k, v in pairs(self.select) do
            v.gameObject:SetActive(false)
        end
    end
end

function ClickHandler:onPointEventHandle(bool)
    if self.gameObject:GetComponent(LuaEventTriggerPointerClick) then
        self.gameObject:GetComponent(LuaEventTriggerPointerClick).enabled = bool or false
    end
    if self.gameObject:GetComponent(LuaEventTriggerPointerDown) then
        self.gameObject:GetComponent(LuaEventTriggerPointerDown).enabled = bool or false
    end
    if self.gameObject:GetComponent(LuaEventTriggerPointerUp) then
        self.gameObject:GetComponent(LuaEventTriggerPointerUp).enabled = bool or false
    end
end

-- 当连续点击按钮时，可以持续触发某个操作，注意使用这个方法时最好不用Click事件，因为这时的Click会由Up处理
-- data是一个table，格式如下
--[[
local data = {
    clickThreshold = 0.5,   -- 识别点击还是连续按下的时间阈值
    startSpeed = 10,    -- 一开始的时候每秒钟的调用次数
    acceleration = 0,   -- 加速度，执行的越来越快
    step = true,    -- 当速度很大的时候是否通过降低速度让count连续增长，为false的时候count会跳跃增长
    clickCallback = function () end,    -- 点击执行的回调方法
    durationCallback = function (count) end,    -- 连续按下执行的回调方法，count为当前的执行次数
}
--]]
function ClickHandler:regOnButtonPressing(data)
    if type(data) == 'table' then
        -- 设置默认值
        if type(data.clickThreshold) ~= 'number' then
            data.clickThreshold = 0.5
        end
        if type(data.startSpeed) ~= 'number' then
            data.startSpeed = 10
        end
        if type(data.acceleration) ~= 'number' then
            data.acceleration = 0
        end
        if type(data.step) ~= 'bool' then
            data.step = true
        end
        if type(data.clickCallback) ~= 'function' then
            data.clickCallback = function() end
        end
        if type(data.durationCallback) ~= 'function' then
            data.durationCallback = function(count) end
        end

        -- 确保包含Down和Up脚本
        local downScript = self:GetComponent(LuaEventTriggerPointerDown)
        if not downScript then
            self.gameObject:AddComponent(LuaEventTriggerPointerDown)
        end
        local upScript = self:GetComponent(LuaEventTriggerPointerUp)
        if not upScript then
            self.gameObject:AddComponent(LuaEventTriggerPointerUp)
        end

        -- down和up中用到的外部变量
        local isDown = false
        local downStartTime = 0
        local count = 0

        -- 注册down和up事件
        self:regOnButtonDown('pressing', function(eventData)
            if not isDown then
                isDown = true
                downStartTime = Time.time
                self:coroutine( function()
                    local lastCallTime = false
                    while isDown do
                        -- TODO:暂未考虑加速度的问题
                        local downDurationTime = Time.time - downStartTime
                        local pressDurationTime = downDurationTime - data.clickThreshold
                        local speed = data.startSpeed + pressDurationTime * data.acceleration
                        if pressDurationTime >= 0 and(not lastCallTime or math.floor((Time.time - lastCallTime) * speed) > 0) then
                            local steps = type(lastCallTime) == 'number' and math.floor((Time.time - lastCallTime) * speed) or 1
                            lastCallTime = Time.time
                            if data.step then
                                steps = 1
                            end
                            count = count + steps
                            data.durationCallback(count)
                        end
                        coroutine.yield()
                    end
                end )
            end
        end )

        self:regOnButtonUp('pressing', function(eventData)
            local downDurationTime = Time.time - downStartTime
            if downDurationTime < data.clickThreshold then
                data.clickCallback()
            end
            isDown = false
            count = 0
        end )
    end
end

function ClickHandler:unRegOnButtonPressing()
    self:unRegOnButtonDown('pressing')
    self:unRegOnButtonUp('pressing')
end

function ClickHandler:regOnButtonClick(func, real)
    if type(func) == 'string' or type(func) == 'number' then
        key = func
    else
        key = self.buttonClickTag
    end
    self.onButtonClickCallBack[key] = real or func
end

function ClickHandler:unRegOnButtonClick(funcOrTag)
    funcOrTag = funcOrTag or self.buttonClickTag
    self.onButtonClickCallBack[funcOrTag] = nil
end

function ClickHandler:setMultiClickEnabled(enabled)
    self.multiClickEnabled = enabled
end

function ClickHandler:onPointerClick(eventData)
    local clickOther = false
    if next(ClickHandler.clickingItems) then
        local cloneofclicking = shallowClone(ClickHandler.clickingItems)
        for k, v in pairs(cloneofclicking) do
            if k ~= nil and k ~= clr.null then
                if type(k.onPointerUp) == 'function' then
                    k:onPointerUp(eventData)
                end
                if k ~= self then
                    clickOther = true
                end
            end
        end
        ClickHandler.clickingItems = { }
    end
    if clickOther then
        return
    end
    if self:clickSpeedValid() then
        ClickHandler.frameCount = Time.frameCount
        self:coroutine( function()
            unity.waitForEndOfFrame()
            self:handleDefaultClick()
            -- changeState是为了配合ButtonGroup的，如果注册的方法中的任何一个返回了true，则按钮的选中状态就不应该切换
            local changeStateFunc = self.onButtonClickCallBack['changeState']
            if type(changeStateFunc) == 'function' then
                self.onButtonClickCallBack['changeState'] = nil
            end
            local failed = false
            for k, v in pairs(self.onButtonClickCallBack) do
                if type(v) == 'function' then
                    local result = v(eventData)
                    if not failed and result then
                        failed = true
                    end
                end
            end
            if type(changeStateFunc) == 'function' then
                if failed then
                    self:touchDown(false)
                    self:exchangeTextColor()
                else
                    changeStateFunc(eventData)
                end
                self.onButtonClickCallBack['changeState'] = changeStateFunc
            end
        end )
    end
end

function ClickHandler:regOnButtonUp(func, real)
    if type(func) == 'string' or type(func) == 'number' then
        key = func
    else
        key = self.buttonUpTag
    end
    self.onButtonUpCallBack[key] = real or func
end

function ClickHandler:unRegOnButtonUp(funcOrTag)
    self.onButtonUpCallBack[funcOrTag] = nil
end

function ClickHandler:clickSpeedValid()
    return Time.frameCount > ClickHandler.frameCount + 1
end

local function isClick(eventData)
    local currentOverGo = eventData.pointerCurrentRaycast.gameObject
    local pointerUpHandler = ExecuteEvents.GetEventHandler[IPointerClickHandler](currentOverGo)
    return eventData.pointerPress == pointerUpHandler and eventData.eligibleForClick
end

function ClickHandler:onPointerUp(eventData)
    if ClickHandler.clickingItems[self] then
        ClickHandler.clickingItems[self] = nil
        if not(isClick(eventData) and self.isSelectType and self:clickSpeedValid() and not eventData.dragging) then
            self:touchDown(false)
            self:exchangeTextColor()
        end
        for k, v in pairs(self.onButtonUpCallBack) do
            if type(v) == 'function' then
                v(eventData)
            end
        end
    end
end

function ClickHandler:regOnButtonDown(func, real)
    local key
    if type(func) == 'string' or type(func) == 'number' then
        key = func
    else
        key = self.buttonDownTag
    end
    self.onButtonDownCallBack[key] = real or func
end

function ClickHandler:unRegOnButtonDown(funcOrTag)
    self.onButtonDownCallBack[funcOrTag] = nil
end

function ClickHandler:clearDestroyedItemRecord()
    for k, v in pairs(ClickHandler.clickingItems) do
        if k == clr.null then
            ClickHandler.clickingItems[k] = nil
        end
    end
end

function ClickHandler:onPointerDown(eventData)
    self:clearDestroyedItemRecord()
    if self.multiClickEnabled or (self:clickSpeedValid() and not next(ClickHandler.clickingItems)) then
        ClickHandler.clickingItems[self] = true
        self:touchDown(true)
        self:exchangeTextColor()
        for k, v in pairs(self.onButtonDownCallBack) do
            if type(v) == 'function' then
                v(eventData)
            end
        end
    end
end

function ClickHandler:regOnBeginDrag(func, real)
    local key
    if type(func) == 'string' or type(func) == 'number' then
        key = func
    else
        key = self.buttonBeginDragTag
    end
    self.onButtonBeginDragCallBack[key] = real or func
end

function ClickHandler:unRegOnBeginDrag(funcOrTag)
    self.onButtonBeginDragCallBack[funcOrTag] = nil
end

function ClickHandler:onBeginDrag(eventData)
    for k, v in pairs(self.onButtonBeginDragCallBack) do
        if type(v) == 'function' then
            v(eventData)
        end
    end
end

function ClickHandler:regOnDrag(func, real)
    local key
    if type(func) == 'string' or type(func) == 'number' then
        key = func
    else
        key = self.buttonDragTag
    end
    self.onButtonDragCallBack[key] = real or func
end

function ClickHandler:unRegOnDrag(funcOrTag)
    self.onButtonDragCallBack[funcOrTag] = nil
end

function ClickHandler:onDrag(eventData)
    for k, v in pairs(self.onButtonDragCallBack) do
        if type(v) == 'function' then
            v(eventData)
        end
    end
end

function ClickHandler:regOnEndDrag(func, real)
    if type(func) == 'string' or type(func) == 'number' then
        key = func
    else
        key = self.buttonEndDragTag
    end
    self.onButtonEndDragCallBack[key] = real or func
end

function ClickHandler:unRegOnEndDrag(funcOrTag)
    self.onButtonEndDragCallBack[funcOrTag] = nil
end

function ClickHandler:onEndDrag(eventData)
    for k, v in pairs(self.onButtonEndDragCallBack) do
        if type(v) == 'function' then
            v(eventData)
        end
    end
end

function ClickHandler:touchDown(isDown)
    if isDown then
        if type(self.up) == 'table' then
            for k, v in pairs(self.up) do
                v:SetActive(false)
            end
        end
        if type(self.down) == 'table' then
            for k, v in pairs(self.down) do
                v:SetActive(true)
            end
        end
        if type(self.scale) == 'table' then
            local scalerRatio = self.scalerRatio
            for k, v in pairs(self.scale) do
                v.transform.localScale = Vector3(scalerRatio, scalerRatio, scalerRatio)
            end
        end
    else
        if type(self.up) == 'table' then
            for k, v in pairs(self.up) do
                v:SetActive(true)
            end
        end
        if type(self.down) == 'table' then
            for k, v in pairs(self.down) do
                v:SetActive(false)
            end
        end
        if type(self.scale) == 'table' then
            for k, v in pairs(self.scale) do
                v.transform.localScale = Vector3(self.scalerMaxRatio, self.scalerMaxRatio, self.scalerMaxRatio)
            end
        end
    end
end

function ClickHandler:exchangeTextColor()
    for k, v in pairs(self.txt) do
        ClickHandler.exchangeTextColorWithShadowColor(v)
    end
end

function ClickHandler:handleDefaultClick()
    local snd = 'click'
    if type(self.clicksnd) == 'string' then
        snd = self.clicksnd
    elseif self.clicksnd == false then
        snd = nil
    end
    if snd then
        UISoundManager.play(snd, self.clickSndVolume)
    end
    for k, v in pairs(self.default_click) do
        local func = cache.getGlobalTempData(v)
        if type(func) == 'function' then
            func(self)
        end
    end
end

function ClickHandler.exchangeTextColorWithShadowColor(obj)
    if type(obj) == 'userdata' and obj ~= clr.null then
        local txt = obj:GetComponent(Text)
        local shadow = obj:GetComponent(Shadow)
        if txt and shadow then
            local c1 = txt.color
            txt.color = Color(shadow.effectColor.r, shadow.effectColor.g, shadow.effectColor.b, txt.color.a)
            shadow.effectColor = Color(c1.r, c1.g, c1.b, shadow.effectColor.a)
        end
    end
end

function ClickHandler:selectBtn()
    self:touchDown(true)
    if type(self.select) == 'table' then
        if type(self.down) == 'table' then
            for k, v in pairs(self.down) do
                v:SetActive(false)
            end
        end
        for k, v in pairs(self.select) do
            v:SetActive(true)
        end
    end
    self:exchangeTextColor()
end

function ClickHandler:unselectBtn()
    self:touchDown(false)
    if type(self.select) == 'table' then
        for k, v in pairs(self.select) do
            v:SetActive(false)
        end
    end
    self:exchangeTextColor()
end

function ClickHandler:selectWhenClick()
    self.isSelectType = true
end

return ClickHandler
