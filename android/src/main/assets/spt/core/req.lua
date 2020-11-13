local UnityEngine = clr.UnityEngine
local Canvas = UnityEngine.Canvas

req = { }
url = { }

reqDefaultListeners = { }
reqDefaultErrorListeners = { }
reqEventListeners = { }
reqResultPrepareListeners = { }
reqResultPrepareEventListeners = { }

local reqEventListenersStacks = cache.setValueWithHistoryAndCategory()
function reqEventListenersStacks.onGetValue(cate)
    return reqEventListeners[cate]
end
function reqEventListenersStacks.onSetValue(cate, val)
    reqEventListeners[cate] = val
end
req.getEventListener = reqEventListenersStacks.getValue
req.regEventListener = reqEventListenersStacks.pushValue
req.popEventListener = reqEventListenersStacks.popValue

local reqResultPrepareListenersStacks = cache.setValueWithHistoryAndCategory()
function reqResultPrepareListenersStacks.onGetValue(cate)
    return reqResultPrepareListeners[cate]
end
function reqResultPrepareListenersStacks.onSetValue(cate, val)
    reqResultPrepareListeners[cate] = val
end
req.getResultPrepareListener = reqResultPrepareListenersStacks.getValue
req.regResultPrepareListener = reqResultPrepareListenersStacks.pushValue
req.popResultPrepareListener = reqResultPrepareListenersStacks.popValue

local reqResultPrepareEventListenersStacks = cache.setValueWithHistoryAndCategory()
function reqResultPrepareEventListenersStacks.onGetValue(cate)
    return reqResultPrepareEventListeners[cate]
end
function reqResultPrepareEventListenersStacks.onSetValue(cate, val)
    reqResultPrepareEventListeners[cate] = val
end
req.getResultPrepareEventListener = reqResultPrepareEventListenersStacks.getValue
req.regResultPrepareEventListener = reqResultPrepareEventListenersStacks.pushValue
req.popResultPrepareEventListener = reqResultPrepareEventListenersStacks.popValue

local function reqPrepareResult(www)
    local rv = nil
    for k, v in pairs(reqResultPrepareListeners) do
        if type(v) == 'function' then
            rv = v(www)
        end
    end
    if www.event ~= "none" then
        for k, v in pairs(reqResultPrepareEventListeners) do
            if type(v) == 'function' then
                rv = v(www)
            end
        end
    end
    return rv
end

local function reqHandleEventData(event)
    if type(event) == 'table' then
        local rv = nil
        for k, v in pairs(event) do
            if type(reqEventListeners[k]) == 'function' then
                rv = reqEventListeners[k](v)
            end
        end
        return rv
    end
end

function req.defaultOnFailed(www)
    local resDlg, dlgccomp
    local failedWait = { }
    if www.failed == 'network' or www.failed == 'timedout' then
        resDlg = require("ui.control.manager.DialogManager").ShowRetryPop(lang.trans("tips"), www.msg, function()
            failedWait.done = true
            failedWait.retry = true
        end)
    else
        resDlg = require("ui.control.manager.DialogManager").ShowAlertPop(lang.trans("tips"), www.msg, function()
            failedWait.done = true
        end)
    end

    local canvas = resDlg:GetComponent(Canvas)
    canvas.sortingOrder = 20010
    return failedWait
end

function req.post(uri, data, oncomplete, onfailed, quiet)
    local ret
    local postdone = nil

    local function realOnComplete(www)
        local prepareWait = reqPrepareResult(www)
        if prepareWait then
            while not prepareWait.done do
                coroutine.yield()
            end
            unity.waitForEndOfFrame()
        end

        local defaultListener = reqDefaultListeners[uri]
        if type(defaultListener) == 'function' then
            -- defaultListener(www)
            xpcall(function() defaultListener(www) end, function(err) dump(err) end)
        end

        local eventWait = reqHandleEventData(www.event)
        if eventWait then
            while not eventWait.done do
                coroutine.yield()
            end
            unity.waitForEndOfFrame()
        end

        postdone = 'complete'
    end

    local function realOnFailed(www)
        local prepareWait = reqPrepareResult(www)
        if prepareWait then
            while not prepareWait.done do
                coroutine.yield()
            end
            unity.waitForEndOfFrame()
        end

        if www.event ~= "none" then
            local eventWait = reqHandleEventData(www.event)
            if eventWait then
                while not eventWait.done do
                    coroutine.yield()
                end
                unity.waitForEndOfFrame()
            end
        end

        if type(onfailed) == 'table' and type(onfailed.weakhandler) == "function" then
            onfailed.weakhandler(www)
        end

        if type(onfailed) == 'function' then
            postdone = 'failed'
            -- failedWait = onfailed(www)
        elseif type(onfailed) == 'table' and onfailed[www.failed] then
            postdone = 'failed'
            --            if type(onfailed[www.failed]) == 'function' then
            --                failedWait = onfailed[www.failed](www)
            --            end
        else
            if quiet then
                postdone = 'failed'
            else
                local failedWait = nil
                if type(reqDefaultErrorListeners[www.failed]) == 'function' then
                    failedWait = reqDefaultErrorListeners[www.failed](www)
                else
                    failedWait = req.defaultOnFailed(www)
                end

                if failedWait then
                    while not failedWait.done do
                        coroutine.yield()
                    end
                    unity.waitForEndOfFrame()

                    if failedWait.retry then
                        ret = ret:repost()
                    else
                        postdone = 'failed'
                    end
                else
                    postdone = 'failed'
                end
            end
        end
    end

    ret = api.post(uri, data, quiet)
    ret.doneFuncs = {
        onFailed = realOnFailed,
        onComplete = realOnComplete,
    }

    local alldone = nil
    while not alldone do
        while not postdone do
            coroutine.yield()
        end
        unity.waitForEndOfFrame()

        if postdone == 'complete' then
            if type(oncomplete) == 'function' then
                oncomplete(ret)
            end
            alldone = true
        elseif postdone == 'failed' then
            local failedWait = nil
            if type(onfailed) == 'function' then
                failedWait = onfailed(ret)
            elseif type(onfailed) == 'table' and onfailed[ret.failed] then
                if type(onfailed[ret.failed]) == 'function' then
                    failedWait = onfailed[ret.failed](ret)
                end
            end
            if failedWait then
                while not failedWait.done do
                    coroutine.yield()
                end
                unity.waitForEndOfFrame()

                if failedWait.retry then
                    postdone = nil
                    ret = ret:repost()
                else
                    alldone = true
                end
            else
                alldone = true
            end
        end
    end

    return ret
end


------------
-- default eventListener:
------------

function reqEventListeners.restart(data)
    local waitHandle = { }
    if data then
        local msg  = type(data) == 'string' and data or lang.trans("loginExpire")
        require("ui.control.manager.DialogManager").ShowAlertPop(lang.trans("tips"), msg, function()
            waitHandle.done = true
            unity.restart()
        end)
    end
    return waitHandle
end

------------
-- categoried error listeners:
------------

reqDefaultErrorListeners[1002] = function(www)
    if www and type(www.val) == 'string' then
        unity.changeServerTo(www.val)
    end
end

------------
-- requests:
------------

function req.checkVersion(oncomplete, onfailed)
    local data = {
        capid = clr.capid(),
        plat = clr.plat,
        ver = _G["___resver"],
        flags = clr.table(clr.Capstones.UnityFramework.ResManager.GetDistributeFlags()),
        udid = luaevt.trig('GetUDID'),
        mac = luaevt.trig('GetMacAddr'),
        imei = luaevt.trig('GetImei'),
        adId = luaevt.trig('GetAdvertisingId'),
        bichannel = luaevt.trig('SDK_GetChannel'),
        app = luaevt.trig('SDK_GetAppId'),
        appver = luaevt.trig('SDK_GetAppVerCode'),
    }
    return req.post(tostring(___CONFIG__ACCOUNT_URL) .. 'device/version', data, oncomplete, onfailed)
end

function req.checkCheat(oncomplete, onfailed)
    local data = {
        capid = clr.capid(),
        plat = clr.plat,
        ver = _G["___resver"],
        flags = clr.table(clr.Capstones.UnityFramework.ResManager.GetDistributeFlags()),
        udid = luaevt.trig('GetUDID'),
        mac = luaevt.trig('GetMacAddr'),
        imei = luaevt.trig('GetImei'),
        bichannel = luaevt.trig('SDK_GetChannel'),
    }
    return req.post(tostring(___CONFIG__ACCOUNT_URL) .. 'device/cheat', data, oncomplete, onfailed, true)
end

return req
