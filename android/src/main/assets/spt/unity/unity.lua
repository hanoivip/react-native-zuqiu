local UnityEngine = clr.UnityEngine
local GameObject = UnityEngine.GameObject
local Component = UnityEngine.Component
local Application = UnityEngine.Application
local Time = UnityEngine.Time
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

function setIndexHierarchical(table, indexmeta)
    local meta
    if type(table) == 'userdata' then
        meta = clr.ex(table)
        if type(meta) == 'table' then
            local mmeta = getmetatable(meta)
            if not mmeta then
                mmeta = { __index = indexmeta }
                setmetatable(meta, mmeta)
                return table
            end
            meta = mmeta
        else
            return table
        end
    else
        meta = getmetatable(table)
        if not meta then
            return setmetatable(table, { __index = indexmeta })
        end
    end

    if not meta.__index then
        meta.__index = indexmeta
        return table
    else
        if type(meta.__index) == 'function' then
            local oldmeta = meta.__index
            meta.__index = function(table, key)
                local rv = oldmeta(table, key)
                if rv ~= nil then
                    return rv
                else
                    if type(indexmeta) == 'function' then
                        return indexmeta(table, key)
                    elseif type(indexmeta) == 'table' or type(indexmeta) == 'userdata' then
                        return indexmeta[key]
                    end
                end
            end
            return table
        elseif type(meta.__index) == 'table' or type(meta.__index) == 'userdata' then
            setIndexHierarchical(meta.__index, indexmeta)
            return table
        else
            meta.__index = indexmeta
            return table
        end
    end

    return table
end

function setNewIndexHierarchical(table, indexmeta)
    local meta
    if type(table) == 'userdata' then
        meta = clr.ex(table)
        if type(meta) == 'table' then
            local mmeta = getmetatable(meta)
            if not mmeta then
                mmeta = { __newindex = indexmeta }
                setmetatable(meta, mmeta)
                return table
            end
            meta = mmeta
        else
            return table
        end
    else
        meta = getmetatable(table)
        if not meta then
            return setmetatable(table, { __newindex = indexmeta })
        end
    end

    if not meta.__newindex then
        meta.__newindex = indexmeta
        return table
    else
        if type(meta.__newindex) == 'function' then
            -- ??
            meta.__newindex = indexmeta
            return table
        elseif type(meta.__newindex) == 'table' or type(meta.__newindex) == 'userdata' then
            setIndexHierarchical(meta.__newindex, indexmeta)
            return table
        else
            meta.__newindex = indexmeta
            return table
        end
    end

    return table
end

unity = {}

function unity.waitForEndOfFrame()
    local curFrame = UnityEngine.Time.frameCount
    if unity.waitForEndOfFrameIndex ~= curFrame then
        coroutine.yield(UnityEngine.WaitForEndOfFrame())
        unity.waitForEndOfFrameIndex = curFrame
    end
end

function unity.waitForNextEndOfFrame()
    coroutine.yield(UnityEngine.WaitForEndOfFrame())
    local curFrame = UnityEngine.Time.frameCount
    unity.waitForEndOfFrameIndex = curFrame
end

function unity.waitForSeconds(seconds)
    assert(type(seconds) == "number", "please input number type.")
    coroutine.yield(UnityEngine.WaitForSeconds(seconds))
end

function unity.updateCanvases()
    UnityEngine.Canvas.ForceUpdateCanvases()
end

function unity.alloc()
    local go = GameObject()
    local behav = go:AddComponent(CapsUnityLuaBehav)
    return behav
end

unity.base = class(unity.alloc)

unity.base.coroutine = clr.bcoroutine

unity.base.destroySelf = function(self)
    UnityEngine.Object.Destroy(self.gameObject)
end

unity.base.destroyRoot = function(self)
    UnityEngine.Object.Destroy(self.transform.root.gameObject)
end

function unity.create(prefab)
    local go = GameObject.Instantiate(prefab)
    if go then
        local behav = go:GetComponent(CapsUnityLuaBehav)
        if not behav then
            local behav = go:AddComponent(CapsUnityLuaBehav)
        end
        behav.coroutine = clr.bcoroutine
        return behav
    end
end

function unity.component(go, comp)
    if clr.is(go, Component) then
        go = go.gameObject
    elseif not clr.is(go, GameObject) then
        go = GameObject()
    end
    go:AddComponent(comp)
    local behav = go:GetComponent(CapsUnityLuaBehav)
    if not behav then
        behav = go:AddComponent(CapsUnityLuaBehav)
        behav.coroutine = clr.bcoroutine
    end
    return behav
end

function unity.restart()
    res.DestroyAllHard()
    clr.reset()
    for k,v in pairs(package.loaded) do
        package.loaded[k] = nil
    end
	luaevt.trig('SDK_Logout')
    luaevt.reset()
    Application.LoadLevel("EntryScene")
    Time.timeScale = 1
end

function unity.changeServerTo(url)
    res.DestroyAllHard()
	clr.reset()
	for k,v in pairs(package.loaded) do
	    package.loaded[k] = nil
	end
    if clr.plat == "WindowsEditor" then
        luaevt.reset()
        luaevt.trig('SDK_Logout')
        ___CONFIG__CHANGESERVER_URL = url
        require('config')
        ___CONFIG__ACCOUNT_URL = url
        ___CONFIG__BASE_URL = url
        Application.LoadLevel("EntryScene")
    else
        ___CONFIG__CHANGESERVER_URL = url
        require('config')
        ___CONFIG__ACCOUNT_URL = url
        ___CONFIG__BASE_URL = url
        luaevt.trig('SDK_Logout')
        luaevt.reset()
        Application.LoadLevel("EntryScene")
    end
end

local luacomp = class()
unity.luacomp = luacomp

function luacomp:ctor(parent)
    self:addto(parent)
end

function luacomp:addto(parent)
    self.__parent = parent
    if parent then
        local comps = parent.__comps
        if type(comps) ~= 'table' then
            comps = {}
            parent.__comps = comps
        end
        local name = parent.__cname
        if type(name) ~= 'string' then
            name = tostring(self)
        end
        comps[name] = self
    end
end

function luacomp:coroutine(...)
    return self.__parent:coroutine(...)
end

luacomp.__index = function(tab, key)
    local parent = rawget(tab, '__parent')
    if parent then
        local rv = parent[key]
        if rv ~= nil then
            return rv
        end
    end
    local rv = rawget(getmetatable(tab), key)
    if rv ~= nil then
        return rv
    end
    return rawget(tab, key)
end

local composed = class(unity.base)
unity.composed = composed

function composed:ctor()
    setIndexHierarchical(self, function(table, key)
        if type(key) == 'string' then
            local key2 = string.upper(string.sub(key, 1, 1))
            if key2 ~= string.sub(key, 1, 1) then
                if type(self.__comps) == 'table' then
                    for k, v in pairs(self.__comps) do
                        local func = rawget(v, key) or (v.class and rawget(v.class, key))
                        if type(func) == 'function' then
                            return function(table, ...)
                                self:callcomps(key, ...)
                            end
                        end
                    end
                end
            end
            return nil
        end
    end)
end

function composed:callcomps(funcname, ...)
    if type(self.__comps) == 'table' then
        local cnt = table.nums(self.__comps)
        for k, v in pairs(self.__comps) do
            cnt = cnt - 1
            local func = rawget(v, funcname) or (v.class and rawget(v.class, funcname))
            if type(func) == 'function' then
                if cnt == 0 then
                    return func(v, ...)
                else
                    func(v, ...)
                end
            end
        end
    end
end

local secomp = class(unity.base)
unity.secomp = secomp

function secomp:start()
    self.se_started = true
    if type(self.onStarted) == 'function' then
        self:onStarted()
    end
    if self.se_enabled then
        self:callEnabled()
    end
end

function secomp:onEnable()
    self.se_enabled = true
    if self.se_started then
        self:callEnabled()
    end
end

function secomp:callEnabled()
    if type(self.onEnabled) == 'function' then
        self:onEnabled()
    end
    if not self.se_fenabled then
        self.se_fenabled = true
        if type(self.onFirstEnabled) == 'function' then
            self:onFirstEnabled()
        end
    end
end

local uscene = class(secomp)
unity.scene = uscene

function uscene:ctor()
    if type(res.curSceneInfo) == 'table' then
        if type(res.curSceneInfo.args) == 'table' then
            self:init(unpack(res.curSceneInfo.args, 1, res.curSceneInfo.argc))
            return
        end
    end
    self:init()
end

function uscene:onEnabled()
    if type(res.curSceneInfo) == 'table' then
        if type(res.curSceneInfo.args) == 'table' then
            self:refresh(unpack(res.curSceneInfo.args, 1, res.curSceneInfo.argc))
            return
        end
    end
    self:refresh()
end

function uscene:init(...)
end

function uscene:refresh(...)
end

local newuscene = class(secomp)
unity.newscene = newuscene

function newuscene:ctor()
    cache.setGlobalTempData(self, "MainManager")
end

return unity
