api = {}

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

function api.setToken(token)
    api.token = token
end

function api.normalizeUrl(uri)
    -- TODO:
    -- 1. make lower;
    -- 2. if starts with "http://" check starts with url.baseUrl;
    -- 3. the part with out "http://", change // to /
    -- 4. the part relative to url.baseUrl, remove starting /
    if string.sub(uri, 1, string.len("http://")) ~= "http://" and 
        string.sub(uri, 1, string.len("https://")) ~= "https://" then
        uri = tostring(___CONFIG__BASE_URL or "")..uri
    end
    return uri
end

local nextRequestSeq = 1
local nextRealSeq = 1
local repostReq -- function
local restartReq -- function

local function createRequest(uri, data, seq)
    local datamt = getmetatable(data)
    local www
    if datamt and datamt.rawpost then
        -- TODO:是对外部服务器的请求
        local rawdata = data
        local form = clr.Capstones.UnityFramework.HttpRequest.HttpRequestDataJson()
        local headers = clr.Capstones.UnityFramework.HttpRequest.HttpRequestData()
        www = clr.Capstones.UnityFramework.HttpRequest(uri, headers, form, nil)
        www.Timeout = api.timeout * 1000
        for k, v in pairs(data) do
            if type(v) == "table" then
                if #v == table.nums(v) then
                    form:Add(k, clr.array(v))
                else
                    form:Add(k, clr.dict(v))
                end
            elseif type(v) == "number" then
                if math.isInt(v) then
                    form:Add(k, clr.as(v, clr.System.Int32))
                else
                    form:Add(k, clr.as(v, clr.System.Double))
                end
            else
                form:Add(k, v)
            end
        end

        www:StartRequest()
        www.uri = uri
        www.pdata = rawdata
        www.token = api.token
        www.seq = seq
        www.repost = repostReq
        www.restart = restartReq
    else
        if type(seq) ~= 'number' then
            seq = nextRequestSeq
            nextRequestSeq = nextRequestSeq + 1
        end
        local rseq = nextRealSeq
        nextRealSeq = nextRealSeq + 1

        local rawdata = data
        local fulldata = { d = data }
        data = json.encode(data)
        local form = clr.Capstones.UnityFramework.HttpRequest.HttpRequestData()
        local headers = clr.Capstones.UnityFramework.HttpRequest.HttpRequestData()

        form:Add('d', data)
        headers:Add("Accept-Encoding", "gzip")

        if api.token then
            fulldata.t = tostring(api.token)
            form:Add('t', fulldata.t)
            headers:Add("UserToken", fulldata.t)
        end

        fulldata.seq = tostring(seq)
        form:Add('seq', fulldata.seq)
        headers:Add("Seq", fulldata.seq)

        fulldata.rseq = tostring(rseq)
        form:Add('rseq', fulldata.rseq)
        headers:Add("RSeq", fulldata.rseq)

        fulldata = json.encode(fulldata)

        www = clr.Capstones.UnityFramework.HttpRequest(uri, headers, form, nil)
        www.Timeout = api.timeout * 1000
        local encrypted = nil
        if type(clr.encrypt) == 'function' then
            encrypted = clr.encrypt(fulldata, api.token, seq)
        end
        if encrypted then
            headers:Add("Encrypted", "Y")
            form.Encoded = encrypted
        else
        end

        www:StartRequest()
        www.uri = uri
        www.pdata = rawdata
        www.token = api.token
        www.seq = seq
        www.repost = repostReq
        www.restart = restartReq
    end

    clr.coroutine(function()
        coroutine.yield()
        local error, done
        while not done do
            local startTime = UnityEngine.Time.realtimeSinceStartup
            while true do
                if www.IsDone then
                    break
                end
                unity.waitForNextEndOfFrame()
            end
        
            api.result(www)
            if www.failed then
                error = true
                done = true
            else
                error = nil
                done = true
            end
        end

        if type(www.doneFuncs) == 'table' then
            if error then
                if type(www.doneFuncs.onFailed) == 'function' then
                    www.doneFuncs.onFailed(www)
                end
            else
                if type(www.doneFuncs.onComplete) == 'function' then
                    www.doneFuncs.onComplete(www)
                end
            end
            if type(www.doneFuncs.onDone) == 'function' then
                www.doneFuncs.onDone(www)
            end
        end
    end)

    return www
end

function restartReq(www) -- local
    www:StopRequest()
    local www2 = createRequest(www.uri, www.pdata, www.seq)
    www2.quiet = www.quiet
    www2.blockdlg = www.blockdlg
    www2.doneFuncs = www.doneFuncs

    return www2
end

function repostReq(www) -- local
    local www2 = restartReq(www)
    local quiet = www.quiet

    if www2.blockdlg then
        local block = www2.blockdlg
        www2.blockdlg = nil
        clr.coroutine(function()
            coroutine.yield()
            unity.waitForNextEndOfFrame()
            Object.Destroy(block)
        end)
    end
    if not quiet then
        www2.blockdlg = res.ShowDialog('Assets/CapstonesRes/Game/UI/Common/Template/Loading/WaitForPost.prefab', "overlay", false)
    end

    return www2
end

function api.post(uri, data, quiet)
    uri = api.normalizeUrl(uri)
    print(nextRequestSeq..': '..uri)
    dump(data)

    local www = createRequest(uri, data)
    www.quiet = quiet

    if not quiet then
        www.blockdlg = res.ShowDialog('Assets/CapstonesRes/Game/UI/Common/Template/Loading/WaitForPost.prefab', "overlay", false)
    end

    return www
end

api.timeout = 20
-- TODO: 1、转菊花的prefab
function api.wait(www, onComplete, onFailed)
    local done = nil
    www.doneFuncs = {
        onFailed = onFailed,
        onComplete = onComplete,
        onDone = function(wwwreal) done = wwwreal end,
    }

    while not done do
        unity.waitForNextEndOfFrame()
    end

    return done
end

function api.postwait(uri, data, onComplete, onFailed, quiet)
    return api.wait(api.post(uri, data, quiet), onComplete, onFailed)
end

function api.waitany(...)
    local done = nil

    local tab = cache.totable(...)
    for k, v in pairs(tab) do
        if type(v.doneFuncs) ~= 'table' then
            v.doneFuncs = {}
        end
        v.doneFuncs.onDone = function(wwwreal) done = wwwreal end
    end

    while not done do
        unity.waitForNextEndOfFrame()
    end

    return done
end

function api.waitall(...)
    local undone = {}
    local done = {}
    local tab = cache.totable(...)
    for k, v in pairs(tab) do
        undone[k] = v
        if type(v.doneFuncs) ~= 'table' then
            v.doneFuncs = {}
        end
        v.doneFuncs.onDone = function(wwwreal)
            undone[k] = nil
            done[k] = wwwreal
        end
    end

    while next(undone) do
        unity.waitForNextEndOfFrame()
    end

    if tab == select(1, ...) then
        return done
    else
        return unpack(done, 1, select('#', ...))
    end
end

function api.bool(val)
    return val and val ~= '' and val ~= 0
end

function api.result(www)
    if www.IsDone or www.timedout then
        if not www.done then
            www.done = true
            local failed, msg = false, nil
            local error = www.Error
            if www.timedout or error == 'timedout' then
                failed = 'timedout'
                msg = lang.trans('timedOut')
            elseif api.bool(error) then
                failed = 'network'
                msg = lang.trans('networkError')
            else
                msg = clr.resp(www, www.token, www.seq)
                local tab = json.decode(msg)
                if type(tab) ~= 'table' then
                    failed = true
                    msg = lang.trans(msg)
                else
                    dump(tab)
                    local datamt = getmetatable(www.pdata)
                    if datamt and datamt.rawpost then
                        www.val = tab
                        msg = tab and lang.trans(tab) or lang.trans('server refuse', failed)
                    else
                        if api.bool(tab.r) then
                            failed = tab.r
                            msg = tab.d and lang.trans(tab.d) or lang.trans('server refuse', failed)
                        end
                        www.val = tab.d
                        www.event = tab.e
                    end
                end
            end
            www.msg = msg
            if failed then
                dump(msg)
                www.failed = failed
                www.success = false
            else
                www.failed = false
                www.success = true
            end
            www:StopRequest()
            if www.blockdlg then
                local block = www.blockdlg
                www.blockdlg = nil
                clr.coroutine(function()
                    coroutine.yield()
                    unity.waitForEndOfFrame()
                    Object.Destroy(block)
                end)
            end
        end 
    end
    return www
end

local function success(www)
    return www and www.done and www.success
end

function api.success(...)
    local s = true
    cache.foreach(function(www)
        if not success(www) then
            s = false
            return 'break'
        end
    end, ...)
    return s
end

function api.failed(...)
    local failed
    cache.foreach(function(www)
        if not success(www) then
            failed = www
            return 'break'
        end
    end, ...)
    return failed
end

function api.msg(www)
    if not www.done then
        return lang.trans('request not completed')
    end
    return www.msg
end

return api
