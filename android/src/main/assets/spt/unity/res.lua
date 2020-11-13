local UnityEngine = clr.UnityEngine
local LightmapData = UnityEngine.LightmapData
local LightmapSettings = UnityEngine.LightmapSettings
local ResManager = clr.Capstones.UnityFramework.ResManager
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Canvas = UnityEngine.Canvas
local Camera = UnityEngine.Camera
local RenderMode = UnityEngine.RenderMode
local RapidBlurEffect = clr.RapidBlurEffect
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

luaevt.reg("LowMemory", function()
    res.CollectGarbageDeep()
end)

res = {}
res.LoadType = {
    Change = "change",
    Push = "push",
    Pop = "pop",
}

res.sceneSeq = 0
res.sceneCache = {}
--[[
{
    path = {
        obj = xxx,
        view = xxx
        seq = 0,
        ctrl = xxx,
    },
    ...
}
--]]
res.ctrlStack = {}
--[[
{
    {
        path = xxx,
        args = xxx,
        argc = xxx,
        blur = true,
        dialogs = {
            {
                path = nil,
                order = xxx,
                args = xxx,
                argc = xxx,
            },
            {
                path = nil,
                order = xxx,
                args = xxx,
                argc = xxx,
            },
            {
                path = nil,
                order = xxx,
                args = xxx,
                argc = xxx,
            },
        },
    },
}
--]]
--[[
res.curSceneInfo = {
    view = nil,
    ctrl = nil,
    path = nil,
    blur = true,
    dialogs = {
        {
            view = nil,
            ctrl = nil,
            path = nil,
            order = xxx,
        },
        {
            view = nil,
            ctrl = nil,
            path = nil,
            order = xxx,
        },
        {
            view = nil,
            ctrl = nil,
            path = nil,
            order = xxx,
        },
    },
}
--]]

local function GetSceneSeq()
    res.sceneSeq = res.sceneSeq + 1
    return res.sceneSeq
end

res.perfLevel = 100
if device.level == "low" then
    res.perfLevel = 25
elseif device.level == "middle" then
    res.perfLevel = 50
else
    res.perfLevel = 75
end
if clr.UnityEngine.SystemInfo.systemMemorySize <= 1024 then
    res.perfLevel = 25
end
luaevt.trig("___EVENT__SET_PERF_LEVEL")

local sceneCacheMax = 5
if res.perfLevel < 50 then
    sceneCacheMax = 0
end

function res.SetSceneCacheMax(cnt)
    if type(cnt) ~= "number" or cnt < 1 then
        cnt = 1
    end
    sceneStackMax = cnt
end

function res.GetSceneCacheMax()
    return sceneCacheMax
end

local function TrimSceneCache()
    if table.nums(res.sceneCache) > sceneCacheMax then
        local sceneTable = {}
        for k, v in pairs(res.sceneCache) do
            local sceneInfo = v
            sceneInfo.path = k
            table.insert(sceneTable, sceneInfo)
        end
        table.sort(sceneTable, function(a, b) return a.seq > b.seq end)
        res.sceneCache = {}
        for i, v in ipairs(sceneTable) do
            if i <= sceneCacheMax then
                local path = v.path
                v.path = nil
                res.sceneCache[path] = v
            else
                Object.Destroy(v.obj)
            end
        end
    end
end

local ctrlStackMax = math.max_int32 

function res.SetCtrlStackMax(cnt)
    if type(cnt) ~= "number" or cnt < 1 then
        cnt = 1
    end
    ctrlStackMax = cnt
end

function res.GetCtrlStackMax()
    return ctrlStackMax
end

local function TrimCtrlStack()
    if #res.ctrlStack > ctrlStackMax then
        for i = ctrlStackMax + 1, #res.ctrlStack do
            res.ctrlStack[i] = nil
        end
    end
end

local function SaveCurrentSceneInfo()
    local dialogObjs = {}
    if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" then
        for i, v in ipairs(res.curSceneInfo.dialogs) do
            table.insert(dialogObjs, v.view.dialog.gameObject)
            res.RestoreDialogOrder(v.view.dialog.currentOrder)
        end
    end
    local dialogObjsArr = clr.array(dialogObjs, GameObject)
    local packs = ResManager.PackSceneAndDialogs(dialogObjsArr)
    local sgo = packs.sceneObj
    local dgos = clr.table(packs.dialogObjs)
    local dgosDisable = {}
    local sgoDisable = true
    if type(res.curSceneInfo) == "table" and res.curSceneInfo.view ~= clr.null then
        -- sgo:SetActive(false)
        -- pack场景中的对象
        if not res.sceneCache[res.curSceneInfo.path] then
            local sceneInfo = {
                obj = sgo,
                view = res.curSceneInfo.view,
                seq = GetSceneSeq(),
                ctrl = res.curSceneInfo.ctrl,
            }
            res.sceneCache[res.curSceneInfo.path] = sceneInfo

            TrimSceneCache()
        else
            res.sceneCache[res.curSceneInfo.path].seq = GetSceneSeq()
            if res.sceneCache[res.curSceneInfo.path].obj == clr.null then
                res.sceneCache[res.curSceneInfo.path].obj = sgo
                res.sceneCache[res.curSceneInfo.path].ctrl = res.curSceneInfo.ctrl
            end
        end
        if res.curSceneInfo.ctrl and type(res.curSceneInfo.ctrl.OnExitScene) == "function" then
            res.curSceneInfo.ctrl:OnExitScene()
        end
    else
        -- Object.Destroy(sgo)
        sgoDisable = false
    end

    for i, dgo in ipairs(dgos) do
        if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" then
            local curDialogInfo = res.curSceneInfo.dialogs[i]
            if type(curDialogInfo) == "table" and curDialogInfo.view ~= clr.null then
                -- dgo:SetActive(false)
                table.insert(dgosDisable, true)
                -- pack场景中的对象
                if not res.sceneCache[curDialogInfo.path] then
                    local sceneInfo = {
                        obj = dgo,
                        view = curDialogInfo.view,
                        seq = GetSceneSeq(),
                        ctrl = curDialogInfo.ctrl,
                        order = curDialogInfo.order,
                    }
                    res.sceneCache[curDialogInfo.path] = sceneInfo

                    TrimSceneCache()
                else
                    res.sceneCache[curDialogInfo.path].seq = GetSceneSeq()
                    if res.sceneCache[curDialogInfo.path].obj == clr.null then
                        res.sceneCache[curDialogInfo.path].obj = dgo
                        res.sceneCache[curDialogInfo.path].ctrl = curDialogInfo.ctrl
                    end
                end
                if curDialogInfo.ctrl and type(curDialogInfo.ctrl.OnExitScene) == "function" then
                    curDialogInfo.ctrl:OnExitScene()
                end
            else
                -- Object.Destroy(dgo)
                table.insert(dgosDisable, false)
            end
        else
            -- Object.Destroy(dgo)
            table.insert(dgosDisable, false)
        end
    end

    local function DisableOrDestroyCurrentSceneObj()
        if sgo ~= clr.null then
            if sgoDisable then
                sgo:SetActive(false)
            else
                Object.Destroy(sgo)
            end
        end
        if type(dgos) == "table" then
            for i, dgo in ipairs(dgos) do
                if dgo ~= clr.null then
                    if dgosDisable[i] then
                        dgo:SetActive(false)
                    else
                        Object.Destroy(dgo)
                    end
                end
            end
        end
    end

    return DisableOrDestroyCurrentSceneObj
end

local function SaveCurrentStatusData()
    -- 如果之前的场景是有ctrl的prefab，则保存其信息
    if type(res.curSceneInfo) == "table" and res.curSceneInfo.ctrl then
        -- 保存ctrl恢复的数据信息
        local args = {res.curSceneInfo.ctrl:GetStatusData()}
        local argc = select("#", res.curSceneInfo.ctrl:GetStatusData())

        local ctrlInfo = {
            path = res.curSceneInfo.path,
            args = args,
            argc = argc,
            blur = res.curSceneInfo.blur,
        }

        table.insert(res.ctrlStack, ctrlInfo)
        TrimCtrlStack()
    end

    if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" and #res.curSceneInfo.dialogs > 0 then
        res.ctrlStack[#res.ctrlStack].dialogs = {}
        for i, dialogInfo in ipairs(res.curSceneInfo.dialogs) do
            local args = {dialogInfo.ctrl:GetStatusData()}
            local argc = select("#", dialogInfo.ctrl:GetStatusData())

            local ctrlInfo = {
                path = dialogInfo.path,
                args = args,
                argc = argc,
                order = dialogInfo.order,
            }

            table.insert(res.ctrlStack[#res.ctrlStack].dialogs, ctrlInfo)
        end
    end
end

local function ClearCurrentSceneInfo()
    res.curSceneInfo = nil
end

local function LoadPrefabDialog(loadType, ctrlPath, order, ...)
    cache.setGlobalTempData(true, "LoadingPrefabDialog")

    -- 记录当前窗口信息
    local dialogInfo = {}
    if type(res.curSceneInfo.dialogs) ~= "table" then
        res.curSceneInfo.dialogs = {}
    end
    table.insert(res.curSceneInfo.dialogs, dialogInfo)
    dialogInfo.path = ctrlPath

    local cachedSceneInfo = res.sceneCache[ctrlPath]
    local ctrlClass = require(ctrlPath)

    local args = {...}
    local argc = select("#", ...)

    local function CreateDialog()
        dialogInfo.ctrl = ctrlClass.new()
        dialogInfo.ctrl.__loadType = loadType
        dialogInfo.ctrl:_AheadRequest(function()
            dialogInfo.ctrl:Init(unpack(args, 1, argc))
            dialogInfo.ctrl:Refresh(unpack(args, 1, argc))
        end,
        unpack(args, 1, argc)
        )

        local viewPath = ctrlClass.viewPath
        local dialog, dialogcomp = res.ShowDialog(viewPath, "camera", ctrlClass.dialogStatus.touchClose, ctrlClass.dialogStatus.withShadow, ctrlClass.dialogStatus.unblockRaycast, true)
        dialogInfo.view = dialogcomp.contentcomp
        dialogInfo.order = dialog:GetComponent(Canvas).sortingOrder
        dialogInfo.ctrl.view = dialogInfo.view

        res.GetLuaScript(dialog).OnExitScene = function ()
            if type(dialogInfo.ctrl.OnExitScene) == "function" then
                dialogInfo.ctrl:OnExitScene()
            end
        end

        EventSystem.SendEvent("DialogInsertCurrentScene")
    end

    if type(cachedSceneInfo) == "table" then
        if cachedSceneInfo.obj ~= clr.null then
            dialogInfo.view = cachedSceneInfo.view
            dialogInfo.ctrl = cachedSceneInfo.ctrl
            dialogInfo.order = order or cachedSceneInfo.order
            dialogInfo.view.dialog:setOrder(dialogInfo.order)
            dialogInfo.ctrl.__loadType = loadType

            dialogInfo.ctrl:_AheadRequest(function()
                dialogInfo.ctrl:Refresh(unpack(args, 1, argc))
            end,
            unpack(args, 1, argc)
            )

            local scd, uds = res.GetLastSCDAndUDs(false)

            ResManager.UnpackSceneObj(cachedSceneInfo.obj)
            
            res.AdjustDialogCamera(scd, uds, dialogInfo.view.gameObject, dialogInfo.view.dialog.withShadow)
        else
            res.sceneCache[ctrlPath] = nil
            CreateDialog()
        end
    else
        CreateDialog()
    end

    cache.removeGlobalTempData("LoadingPrefabDialog")
    return dialogInfo.ctrl
end

local function LoadPrefabScene(loadType, ctrlPath, isBlur, dialogData, ...)
    require("ui.control.button.LuaButton").frameCount = clr.UnityEngine.Time.frameCount
    -- 记录当前场景信息res.curSceneInfo
    res.curSceneInfo = {
        path = ctrlPath,
    }
    local cachedSceneInfo = res.sceneCache[ctrlPath]
    local ctrlClass = require(ctrlPath)

    local args = {...}
    local argc = select("#", ...)

    local function CreateDialogs()
        if type(dialogData) == "table" then
            table.sort(dialogData, function(a, b) return a.order < b.order end)
            for i, v in ipairs(dialogData) do
                LoadPrefabDialog(loadType, v.path, v.order, unpack(v.args, 1, v.argc))
            end
        end
    end

    local function CreateScene()
        clr.coroutine(function()
            res.curSceneInfo.ctrl = ctrlClass.new()
            res.curSceneInfo.ctrl.__loadType = loadType
            res.curSceneInfo.ctrl:_AheadRequest(function()
                res.curSceneInfo.ctrl:Init(unpack(args, 1, argc))
                res.curSceneInfo.ctrl:Refresh(unpack(args, 1, argc))            
            end,
            unpack(args, 1, argc)
            )

            local viewPath = ctrlClass.viewPath
            if string.sub(viewPath, -6) == ".unity" then
                ResManager.LoadSceneImmediate(viewPath)
                local mainManager
                repeat
                    mainManager = cache.removeGlobalTempData("MainManager")
                    unity.waitForNextEndOfFrame()
                until mainManager
                res.curSceneInfo.view = mainManager
            else
                local prefab = res.LoadRes(viewPath)
                if prefab then
                    local obj = Object.Instantiate(prefab)
                    local camera = ResManager.CreateCameraAndEventSystem()
                    res.SetUICamera(obj, camera)
                    res.curSceneInfo.view = res.GetLuaScript(obj)

                    if res.perfLevel < 50 then
                        dump("low spec - do a cleanup.")
                        res.CollectGarbage()
                    end
                end
            end
            if isBlur then
                res.curSceneInfo.blur = true
                if res.NeedDialogCameraBlur() then
                    res.SetMainCameraBlur()
                end
            end

            res.curSceneInfo.ctrl.view = res.curSceneInfo.view
            CreateDialogs()

            if res.curSceneInfo.ctrl and type(res.curSceneInfo.ctrl.OnLoadComplete) == "function" then
                res.curSceneInfo.ctrl:OnLoadComplete()
            end
        end)
    end

    if type(cachedSceneInfo) == "table" then
        if cachedSceneInfo.obj ~= clr.null then
            ResManager.UnpackSceneObj(cachedSceneInfo.obj)
            res.curSceneInfo.view = cachedSceneInfo.view
            res.curSceneInfo.ctrl = cachedSceneInfo.ctrl
            res.curSceneInfo.ctrl.__loadType = loadType

            res.curSceneInfo.ctrl:_AheadRequest(function()
                res.curSceneInfo.ctrl:Refresh(unpack(args, 1, argc))
            end,
            unpack(args, 1, argc)
            )

            local scd = res.GetLastSCDAndUDs()
            if res.NeedDialogCameraBlur() then
                if not scd and (type(dialogData) ~= "table" or #dialogData == 0) then
                    res.SetMainCameraBlurOver()
                else
                    res.SetMainCameraBlur()
                end
            end
            CreateDialogs()
            if res.curSceneInfo.ctrl and type(res.curSceneInfo.ctrl.OnLoadComplete) == "function" then
                res.curSceneInfo.ctrl:OnLoadComplete()
            end
        else
            res.sceneCache[ctrlPath] = nil
            CreateScene()
        end
    else
        CreateScene()
    end

    return res.curSceneInfo.ctrl
end

local function LoadPrefabSceneAsync(loadType, ctrlPath, isBlur, dialogData, disableOrDestroySceneFunc, ...)
    require("ui.control.button.LuaButton").frameCount = math.max_int32 - 3
    -- 记录当前场景信息res.curSceneInfo
    res.curSceneInfo = {
        path = ctrlPath,
    }
    local cachedSceneInfo = res.sceneCache[ctrlPath]
    local ctrlClass = require(ctrlPath)

    local args = {...}
    local argc = select("#", ...)

    local waitHandle = {}

    local function CreateDialogs()
        if type(dialogData) == "table" then
            table.sort(dialogData, function(a, b) return a.order < b.order end)
            for i, v in ipairs(dialogData) do
                LoadPrefabDialog(loadType, v.path, v.order, unpack(v.args, 1, v.argc))
            end
        end
    end

    local function CreateScene()
        clr.coroutine(function()
            unity.waitForEndOfFrame()
            local ctrlInstance = ctrlClass.new()
            ctrlInstance.__loadType = loadType
            ctrlInstance:_AheadRequest(function()
                res.curSceneInfo.ctrl:Init(unpack(args, 1, argc))
                res.curSceneInfo.ctrl:Refresh(unpack(args, 1, argc))
            end,
            unpack(args, 1, argc)
            )
            
            local viewPath = ctrlClass.viewPath
            if string.sub(viewPath, -6) == ".unity" then
                local loadinfo = ResManager.LoadSceneAsync(viewPath)
                if loadinfo then
                    while not loadinfo.isDone do
                        unity.waitForNextEndOfFrame()
                    end
                    res.curSceneInfo.view = cache.removeGlobalTempData("MainManager")
                    res.curSceneInfo.ctrl = ctrlInstance
                    res.curSceneInfo.ctrl.view = res.curSceneInfo.view
                    waitHandle.ctrl = res.curSceneInfo.ctrl
                else
                    local mainManager
                    repeat
                        mainManager = cache.removeGlobalTempData("MainManager")
                        unity.waitForNextEndOfFrame()
                    until mainManager

                    res.curSceneInfo.view = mainManager
                    res.curSceneInfo.ctrl = ctrlInstance
                    res.curSceneInfo.ctrl.view = res.curSceneInfo.view
                    waitHandle.ctrl = res.curSceneInfo.ctrl
                end
            else
                local loadinfo = ResManager.LoadResAsync(ctrlClass.viewPath)
                if loadinfo then
                    while not loadinfo.isDone do
                        unity.waitForNextEndOfFrame()
                    end
                    local prefab = loadinfo.asset
                    if prefab then
                        local obj = Object.Instantiate(prefab)
                        local camera = ResManager.CreateCameraAndEventSystem()
                        res.SetUICamera(obj, camera)
                        res.curSceneInfo.view = res.GetLuaScript(obj)
                        res.curSceneInfo.ctrl = ctrlInstance
                        res.curSceneInfo.ctrl.view = res.curSceneInfo.view
                        waitHandle.ctrl = res.curSceneInfo.ctrl

                        if res.perfLevel < 50 then
                            dump("low spec - do a cleanup.")
                            res.CollectGarbage()
                        end
                    end
                end
            end

            if isBlur then
                res.curSceneInfo.blur = true
                if res.NeedDialogCameraBlur() then
                    res.SetMainCameraBlur()
                end
            end

            if type(disableOrDestroySceneFunc) == "function" then
                disableOrDestroySceneFunc()
            end

            CreateDialogs()

            waitHandle.done = true

            if res.curSceneInfo.ctrl and type(res.curSceneInfo.ctrl.OnLoadComplete) == "function" then
                res.curSceneInfo.ctrl:OnLoadComplete()
            end

            require("ui.control.button.LuaButton").frameCount = clr.UnityEngine.Time.frameCount
        end)
    end

    if type(cachedSceneInfo) == "table" then
        if cachedSceneInfo.obj ~= clr.null then
            ResManager.UnpackSceneObj(cachedSceneInfo.obj)
            res.curSceneInfo.view = cachedSceneInfo.view
            res.curSceneInfo.ctrl = cachedSceneInfo.ctrl
            res.curSceneInfo.ctrl.__loadType = loadType

            res.curSceneInfo.ctrl:_AheadRequest(function()
                res.curSceneInfo.ctrl:Refresh(unpack(args, 1, argc))
            end,
            unpack(args, 1, argc)
            )

            local scd = res.GetLastSCDAndUDs()
            if res.NeedDialogCameraBlur() then
                if not scd and (type(dialogData) ~= "table" or #dialogData == 0) then
                    res.SetMainCameraBlurOver()
                else
                    res.SetMainCameraBlur()
                end
            end

            if type(disableOrDestroySceneFunc) == "function" then
                disableOrDestroySceneFunc()
            end

            CreateDialogs()
            waitHandle.done = true
            waitHandle.ctrl = res.curSceneInfo.ctrl

            if res.curSceneInfo.ctrl and type(res.curSceneInfo.ctrl.OnLoadComplete) == "function" then
                res.curSceneInfo.ctrl:OnLoadComplete()
            end
        else
            res.sceneCache[ctrlPath] = nil
            CreateScene()
        end
    else
        CreateScene()
    end

    return waitHandle
end

function res.ClearSceneCache()
    for k, v in pairs(res.sceneCache) do
        if v.obj then
            Object.Destroy(v.obj)
        end
    end
    res.sceneCache = {}
    res.sceneSeq = 0
end

function res.ClearCtrlStack()
    res.ctrlStack = {}
end

function res.CacheHandle()
    SaveCurrentStatusData()
    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    disableOrDestroySceneFunc()
    ClearCurrentSceneInfo()
end

function res.LoadSceneImmediate(name, ...)
    SaveCurrentStatusData()
    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    disableOrDestroySceneFunc()
    ClearCurrentSceneInfo()

    if string.sub(name, -6) == ".unity" then
        ResManager.LoadSceneImmediate(name)
    else
        local prefab = res.LoadRes(name)
        if prefab then
            local obj = Object.Instantiate(prefab)
            local camera = ResManager.CreateCameraAndEventSystem()
            res.SetUICamera(obj, camera)
            return res.GetLuaScript(obj)
        end
    end
end

function res.LoadSceneAsync(name, ...)
    SaveCurrentStatusData()
    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    ClearCurrentSceneInfo()

    local waitHandle = {}
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        if string.sub(name, -6) == ".unity" then
            local loadinfo = ResManager.LoadSceneAsync(name)
            if loadinfo then
                while not loadinfo.isDone do
                    unity.waitForNextEndOfFrame()
                end
            end
        else
            local prefab
            local loadinfo = ResManager.LoadResAsync(name)
            if loadinfo then
                while not loadinfo.isDone do
                    unity.waitForNextEndOfFrame()
                end
                prefab = loadinfo.asset
            end
            if prefab then
                local obj = Object.Instantiate(prefab)
                local camera = ResManager.CreateCameraAndEventSystem()
                res.SetUICamera(obj, camera)
            end
        end
        disableOrDestroySceneFunc()
        waitHandle.done = true
    end)
    return waitHandle
end

function res.LoadScene(name, ...)
    local args = {...}
    local argc = select("#", ...)
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        res.LoadSceneImmediate(name, unpack(args, 1, argc))
    end)
end

function res.PushSceneImmediate(ctrlPath, ...)
    SaveCurrentStatusData()
    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    disableOrDestroySceneFunc()
    ClearCurrentSceneInfo()

    return LoadPrefabScene(res.LoadType.Push, ctrlPath, nil, nil, ...)
end

function res.PushSceneAsync(ctrlPath, ...)
    SaveCurrentStatusData()
    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    ClearCurrentSceneInfo()

    return LoadPrefabSceneAsync(res.LoadType.Push, ctrlPath, nil, nil, disableOrDestroySceneFunc, ...)
end

function res.PushScene(ctrlPath, ...)
    local args = {...}
    local argc = select("#", ...)
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        res.PushSceneImmediate(ctrlPath, unpack(args, 1, argc))
    end)
end

local unmanagedDialogs = {}
local unmanagedBlockDialogs =
{
    ["Assets/CapstonesRes/Game/UI/Common/Template/Loading/WaitForPost.prefab"] = true,
}

local function CloseDialog()
    if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" and #res.curSceneInfo.dialogs > 0 then
        local maxIndex = 0
        local maxOrder = -1
        for i, v in ipairs(res.curSceneInfo.dialogs) do
            local order = v.order
            if maxOrder < order then
                maxOrder = order
                maxIndex = i
            end
        end
        if maxIndex > 0 then
            local dialog = res.curSceneInfo.dialogs[maxIndex]
            if type(dialog) == "table" and dialog.view and dialog.view ~= clr.null and type(dialog.view.closeDialog) == "function" then
                dialog.view:closeDialog()
                return true
            end
        end
    end
end

function res.CommonOnBackDialog()
    for i = #unmanagedDialogs, 1, -1 do
        local dialog = unmanagedDialogs[i].dialog
        if not dialog or dialog == clr.null or not dialog.isActiveAndEnabled then
            unmanagedDialogs[i] = nil
        else
            if not unmanagedDialogs[i].block then
                local ccomp = dialog.contentcomp
                if ccomp and ccomp ~= clr.null and type(ccomp.OnBack) == "function" then
                    ccomp.OnBack()
                else
                    dialog.closeDialog()
                end
            end
            return true
        end
    end

    if CloseDialog() then
        return true
    else
        return false
    end
end

function res.CommonOnBack()
    if res.CommonOnBackDialog() then
        return true
    else
        return res.PopSceneWithoutCurrentImmediate()
    end
end

-- 如果当前最上层的是一个窗口，则只关闭这个窗口，否则关闭整个场景
function res.PopSceneImmediate(...)
    if not CloseDialog() then
        return res.PopSceneWithCurrentSceneImmediate(...)
    end
end

function res.PopAppointSceneImmediate(alongIndex, ...)
    if not CloseDialog() then
		res.PopAppointSceneWithCurrentSceneImmediate(alongIndex, ...)
    end
end

-- 跳转至缓存的前某个场景，找不到则以最后一个场景跳转
function res.PopAppointSceneWithCurrentSceneImmediate(alongIndex, ...)
	local stackNum = #res.ctrlStack
	if stackNum == 0 then return end
	if alongIndex > stackNum then alongIndex = stackNum end
	local ctrlPath, argc, args, isBlur, dialogData, ctrlInfo
	local loadType = res.LoadType.Pop
	argc = select("#", ...)
	args = { ...}
	local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
	disableOrDestroySceneFunc()
	ClearCurrentSceneInfo()
	for i = 1, alongIndex do
		ctrlInfo = table.remove(res.ctrlStack)
		ctrlPath = ctrlInfo.path
		isBlur = ctrlInfo.blur
		dialogData = ctrlInfo.dialogs
	end

	if argc == 0 then
		args = ctrlInfo.args
		argc = ctrlInfo.argc
	end
	return LoadPrefabScene(loadType, ctrlPath, isBlur, dialogData, unpack(args, 1, argc))
end

function res.PopSceneAsync(...)
    if not CloseDialog() then
        return res.PopSceneWithCurrentSceneAsync(...)
    end
end

function res.PopScene(...)
    if not CloseDialog() then
        return res.PopSceneWithCurrentScene(...)
    end
end

function res.PopSceneWithCurrentSceneImmediate(...)
    if #res.ctrlStack == 0 then return end

    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    disableOrDestroySceneFunc()

    ClearCurrentSceneInfo()

    -- restore old info
    local ctrlInfo = table.remove(res.ctrlStack)
    local ctrlPath = ctrlInfo.path
    local argc = select("#", ...)
    local args = {...}
    if argc == 0 then
        args = ctrlInfo.args
        argc = ctrlInfo.argc
    end
    local isBlur = ctrlInfo.blur

    return LoadPrefabScene(res.LoadType.Pop, ctrlPath, isBlur, ctrlInfo.dialogs, unpack(args, 1, argc))
end

function res.PopSceneWithCurrentSceneAsync(...)
    if #res.ctrlStack == 0 then return end

    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()

    ClearCurrentSceneInfo()

    -- restore old info
    local ctrlInfo = table.remove(res.ctrlStack)
    local ctrlPath = ctrlInfo.path
    local argc = select("#", ...)
    local args = {...}
    if argc == 0 then
        args = ctrlInfo.args
        argc = ctrlInfo.argc
    end
    local isBlur = ctrlInfo.blur

    return LoadPrefabSceneAsync(res.LoadType.Pop, ctrlPath, isBlur, ctrlInfo.dialogs, disableOrDestroySceneFunc, unpack(args, 1, argc))
end

function res.PopSceneWithCurrentScene(...)
    local args = {...}
    local argc = select("#", ...)
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        res.PopSceneWithCurrentSceneImmediate(unpack(args, 1, argc))
    end)
end

function res.PopSceneWithoutCurrentImmediate(...)
    if #res.ctrlStack == 0 then return end

    local sgo = ResManager.PackSceneObj()
    Object.Destroy(sgo)

    -- restore old info
    local ctrlInfo = table.remove(res.ctrlStack)
    local ctrlPath = ctrlInfo.path
    local argc = select("#", ...)
    local args = {...}
    if argc == 0 then
        args = ctrlInfo.args
        argc = ctrlInfo.argc
    end
    local isBlur = ctrlInfo.blur

    return LoadPrefabScene(res.LoadType.Pop, ctrlPath, isBlur, ctrlInfo.dialogs, unpack(args, 1, argc))
end

function res.PopSceneWithoutCurrentAsync(...)
    if #res.ctrlStack == 0 then return end

    local sgo = ResManager.PackSceneObj()

    local disableOrDestroySceneFunc = function ()
        Object.Destroy(sgo)
    end

    -- restore old info
    local ctrlInfo = table.remove(res.ctrlStack)
    local ctrlPath = ctrlInfo.path
    local argc = select("#", ...)
    local args = {...}
    if argc == 0 then
        args = ctrlInfo.args
        argc = ctrlInfo.argc
    end
    local isBlur = ctrlInfo.blur

    return LoadPrefabSceneAsync(res.LoadType.Pop, ctrlPath, isBlur, ctrlInfo.dialogs, disableOrDestroySceneFunc, unpack(args, 1, argc))
end

function res.PopSceneWithoutCurrent(...)
    local args = {...}
    local argc = select("#", ...)
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        res.PopSceneWithoutCurrentImmediate(unpack(args, 1, argc))
    end)
end

function res.ChangeSceneImmediate(ctrlPath, ...)
    SaveCurrentStatusData()
    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    disableOrDestroySceneFunc()
    res.ClearSceneCache()
    ClearCurrentSceneInfo()

    return LoadPrefabScene(res.LoadType.Change, ctrlPath, nil, nil, ...)
end

function res.ChangeSceneAsync(ctrlPath, ...)
    SaveCurrentStatusData()
    local disableOrDestroySceneFunc = SaveCurrentSceneInfo()
    res.ClearSceneCache()
    ClearCurrentSceneInfo()

    return LoadPrefabSceneAsync(res.LoadType.Change, ctrlPath, nil, nil, disableOrDestroySceneFunc, ...)
end

function res.ChangeScene(ctrlPath, ...)
    local args = {...}
    local argc = select("#", ...)
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        res.ChangeSceneImmediate(ctrlPath, unpack(args, 1, argc))
    end)
end

function res.PushDialogImmediate(ctrlPath, ...)
    return LoadPrefabDialog(res.LoadType.Push, ctrlPath, nil, ...)
end

function res.PushDialog(ctrlPath, ...)
    local args = {...}
    local argc = select("#", ...)
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        res.PushDialogImmediate(ctrlPath, unpack(args, 1, argc))
    end)
end

function res.GetLastCtrlPath()
    if #res.ctrlStack > 0 then
        return res.ctrlStack[#res.ctrlStack].path
    end
end

function res.RemoveLastSceneData()
    if #res.ctrlStack > 0 then
        res.ctrlStack[#res.ctrlStack] = nil
    end
end

function res.RemoveCurrentSceneDialogsInfo()
    if type(res.curSceneInfo) == "table" then		
		if type(res.curSceneInfo.dialogs) == "table" then 
			for k, v in pairs(res.curSceneInfo.dialogs) do
                if type(v.ctrl.OnExitScene) == "function" then
                    v.ctrl:OnExitScene()
                end
			end
		end
		res.curSceneInfo.dialogs = nil
		res.curSceneInfo.blur = nil
        EventSystem.SendEvent("AllDialogBeDestroy")
    end
end

function res.SetUICamera(obj, camera)
    if obj then
        local canvas = obj:GetComponent(Canvas)
        if canvas and canvas ~= clr.null then
            canvas.worldCamera = camera
        end
    end
end

function res.ChangeGameObjectLayer(dialog, layer)
    ResManager.ChangeGameObjectLayer(dialog, layer)
end

function res.GetDialogCamera()
    return ResManager.GetDialogCamera()
end

function res.GetTopCtrl()
    if type(res.curSceneInfo) == "table" then
        if type(res.curSceneInfo.dialogs) == "table" then
            if #res.curSceneInfo.dialogs > 0 then
                return res.curSceneInfo.dialogs[#res.curSceneInfo.dialogs].ctrl
            end
        end
        return res.curSceneInfo.ctrl
    end
end

function res.GetLuaScript(obj)
    if obj and obj ~= clr.null then
        return obj:GetComponent(CapsUnityLuaBehav)
    end
end

function res.Instantiate(name)
    local prefab = ResManager.LoadRes(name)
    if prefab then
        local obj = Object.Instantiate(prefab)
        if obj then
            local canvas = obj:GetComponent(Canvas)
            if canvas and canvas ~= clr.null then
                res.SetUICamera(obj, ResManager.FindUICamera())
            end
            return obj, res.GetLuaScript(obj)
        end
    end
end

function res.AddChild(parent, name)
    local child = res.Instantiate(name)
    if child then
        if parent then
            child.transform:SetParent(parent.transform, false)
        end
    end
    return child
end

function res.ClearChildren(parentTrans)
    if parentTrans and parentTrans.childCount > 0 then
        for i = 1, parentTrans.childCount do
            Object.Destroy(parentTrans:GetChild(i - 1).gameObject)
        end
    end
end

function res.ClearChildrenImmediate(parentTrans)
    if parentTrans and parentTrans.childCount > 0 then
        for i = 1, parentTrans.childCount do
            Object.DestroyImmediate(parentTrans:GetChild(i - 1).gameObject)
        end
    end
end

-- 是否需要开启弹出窗口背景模糊效果
function res.NeedDialogCameraBlur()
    return device.level ~= "low"
end

-- 设置由MainCamera渲染的UI界面模糊
function res.SetMainCameraBlur()
    local loadingType = cache.getGlobalTempData("LoadingPrefabDialog")
    if loadingType then
        if type(res.curSceneInfo) == "table" then
            res.curSceneInfo.blur = true
        end
    end
    return res.SetCameraBlur(Camera.main)
end
function res.SetCameraBlur(camera)
    if not camera then return end
    local rapidBlurEffect = camera.gameObject:GetComponent(RapidBlurEffect)
    if not rapidBlurEffect then
        rapidBlurEffect = camera.gameObject:AddComponent(RapidBlurEffect)
    end
    rapidBlurEffect.DownSampleNum = 1
    rapidBlurEffect.BlurSpreadSize = 2
    rapidBlurEffect.BlurIterations = 2
    local blurColor = require("ui.common.EffectConstants").CameraBlurColor
    rapidBlurEffect.color = UnityEngine.Color(blurColor[1], blurColor[2], blurColor[3], blurColor[4])
    rapidBlurEffect.enabled = true
end
-- 关闭模糊特效
function res.SetMainCameraBlurOver()
    if type(res.curSceneInfo) == "table" then
        res.curSceneInfo.blur = nil
    end
    return res.SetCameraBlurOver(Camera.main)
end
function res.SetCameraBlurOver(camera)
    assert(camera)
    local rapidBlurEffect = camera.gameObject:GetComponent(RapidBlurEffect)
    if not rapidBlurEffect then
        return
    end

    rapidBlurEffect.enabled = false
end

-- 获取最上层的带有shadow的camera dialog及其上面的所有不带shadow的camera dialog，并且不带shadow的camera dialog是按照order从小到大排好序的
-- withoutCurrent代表是否不包括当前最顶层CameraDialog
-- 这个方法应该只在顶层是带有shadow的camera dialog是调用才有意义
function res.GetLastSCDAndUDs(withoutCurrent)
    local canvases = clr.table(Object.FindObjectsOfType(Canvas))
    local cameraCanvas = {}
    for i, v in ipairs(canvases) do
        if (v.transform.parent == nil or v.transform.parent == clr.null) and v.renderMode == RenderMode.ScreenSpaceCamera and v.sortingLayerName == "Dialog" then
            table.insert(cameraCanvas, v)
        end
    end

    table.sort(cameraCanvas, function(a, b) return a.sortingOrder > b.sortingOrder end)

    local scd = nil
    local uds = {}
    local startIndex = withoutCurrent and 2 or 1
    for i = startIndex, #cameraCanvas do
        local v = cameraCanvas[i]
        if res.GetLuaScript(v).withShadow then
            scd = v.gameObject
            break
        else
            table.insert(uds, 1, v.gameObject)
        end
    end

    return scd, uds
end

function res.ChangeCameraDialogToUI(dialog)
    res.SetUICamera(dialog, ResManager.FindUICamera())
    res.ChangeGameObjectLayer(dialog, 5)
end

function res.ChangeCameraDialogToDialog(dialog)
    res.SetUICamera(dialog, res.GetDialogCamera())
    res.ChangeGameObjectLayer(dialog, 19)
end

function res.JudgeShowDialog(withCtrl)
    local canvases = clr.table(Object.FindObjectsOfType(Canvas))
    for i, v in ipairs(canvases) do
        if (v.transform.parent == nil or v.transform.parent == clr.null) and v.renderMode == RenderMode.ScreenSpaceCamera and v.sortingLayerName == "Dialog" then
            if res.GetLuaScript(v).withCtrl ~= withCtrl then
                return false
            end
        end
    end
    return true
end

function res.AdjustDialogCamera(scd, uds, dialog, withShadow)
    if withShadow then
        res.ChangeCameraDialogToDialog(dialog)
        if scd and scd ~= clr.null then
            res.ChangeCameraDialogToUI(scd)
        end
        for i, v in ipairs(uds) do
            if v and v ~= clr.null then
                res.ChangeCameraDialogToUI(v)
            end
        end
    else
        if scd and scd ~= clr.null then
            res.ChangeCameraDialogToDialog(dialog)
        else
            res.ChangeCameraDialogToUI(dialog)
        end
    end
end

res.InstanceCache = {}
function res.AddCache(cachePath)
    if not res.InstanceCache[cachePath] then
        res.InstanceCache[cachePath] = ResManager.LoadRes(cachePath)
    end
end

function res.RemoveCache(cachePath)
    if res.InstanceCache[cachePath] then 
        res.InstanceCache[cachePath] = nil
    end
end

function res.ShowDialog(content, renderMode, touchClose, withShadow, unblockRaycast, withCtrl, overlaySortingOrder)
    local loadingType = cache.getGlobalTempData("LoadingPrefabDialog")
    local loadingInfo = { dialog = {} }
    if not loadingType then
        if unmanagedBlockDialogs[content] then
            loadingInfo.block = true
        end
        for i = #unmanagedDialogs, 1, -1 do
            local dialog = unmanagedDialogs[i].dialog
            if not dialog or dialog == clr.null then
                table.remove(unmanagedDialogs, i)
            end
        end

        unmanagedDialogs[#unmanagedDialogs + 1] = loadingInfo
    end

    local dialog, dummydialog, blockdialog, diagcomp, dummycomp, scd, uds

    if renderMode and renderMode ~= "overlay" then
        --[[
        if not res.JudgeShowDialog(withCtrl) then
            dump("Camera dialogs of different type can't be opened together!")
            return
        end
        --]]
        scd, uds = res.GetLastSCDAndUDs(false)
        dialog = res.Instantiate("Assets/CapstonesRes/Game/UI/Control/Dialog/CameraDialog.prefab")

        cache.setGlobalTempData(true, "isDummyDialog")
        dummydialog = res.Instantiate("Assets/CapstonesRes/Game/UI/Control/Dialog/OverlayDialog.prefab")
        cache.removeGlobalTempData("isDummyDialog")
        local dummycanvas = dummydialog:GetComponent(Canvas)
        dummycanvas:GetComponent(CapsUnityLuaBehav):setShadow(withShadow)
        diagcomp = dialog:GetComponent(CapsUnityLuaBehav)
        dummycomp = dummydialog:GetComponent(CapsUnityLuaBehav)
        diagcomp.withCtrl = withCtrl
        if withShadow then
            diagcomp:setShadow(true)
            if res.NeedDialogCameraBlur() then
                res.SetMainCameraBlur()
            else
                dummycanvas:GetComponent(CapsUnityLuaBehav):enableShadow()
                diagcomp:enableShadow()
            end
        else
            diagcomp:setShadow(false)
        end
    else
        if overlaySortingOrder then
            cache.setGlobalTempData(overlaySortingOrder, "overlaySortingOrder")
        end
        dialog = res.Instantiate("Assets/CapstonesRes/Game/UI/Control/Dialog/OverlayDialog.prefab")
        cache.removeGlobalTempData("overlaySortingOrder")
        diagcomp = dialog:GetComponent(CapsUnityLuaBehav)
        diagcomp.withCtrl = withCtrl
        if withShadow then
            diagcomp:setShadow(true)
            diagcomp:enableShadow()
        else
            diagcomp:setShadow(false)
        end
    end

    local objcontent
    if type(content) == "string" then
        objcontent = res.InstanceCache[content]

        if objcontent and objcontent ~= clr.null then
            objcontent = Object.Instantiate(objcontent)
        else
            objcontent = res.Instantiate(content)
        end

        objcontent.transform:SetParent(dummydialog and dummydialog.transform or dialog and dialog.transform, false)
        if objcontent then
            diagcomp.content = objcontent
            local compcontent = objcontent:GetComponent(CapsUnityLuaBehav)
            if compcontent then
                diagcomp.contentcomp = compcontent
                compcontent.dialog = diagcomp
                compcontent.closeDialog = diagcomp.closeDialog
            end
        end
    end

    if dummydialog then
        dummycomp:coroutine(function()
            unity.waitForNextEndOfFrame()
            if dialog ~= nil and dialog ~= clr.null then
                if objcontent then
                    objcontent.transform:SetParent(dialog.transform, false)
                    res.AdjustDialogCamera(scd, uds, dialog, withShadow)
                end
            else
                Object.Destroy(objcontent)
            end
            Object.Destroy(dummydialog)
        end)
    end

    if touchClose then
        -- 点击之后关闭当前dialog
        if type(diagcomp.contentcomp.Close) == "function" then
            diagcomp:regOnButtonClick(function ()
                diagcomp.contentcomp:Close()
            end)
        else
            diagcomp:regOnButtonClick(diagcomp.closeDialog)
        end
    end
    if unblockRaycast then
        diagcomp.___ex.canvasGroup.blocksRaycasts = false
    end

    if not loadingType then
        for i = #unmanagedDialogs, 1, -1 do
            local dialog = unmanagedDialogs[i].dialog
            if not dialog or dialog == clr.null then
                table.remove(unmanagedDialogs, i)
            end
        end

        loadingInfo.dialog = diagcomp
    end

    return dialog, diagcomp
end

local usedOrder = {}
local currentOrder = 0

function res.SetDialogOrder(order)
    usedOrder[order] = 1
    if order > currentOrder then
        currentOrder = order
    end
end

function res.ApplyDialogOrder()
    currentOrder = currentOrder + 100
    usedOrder[currentOrder] = 1
    return currentOrder
end

function res.GetCurrentDialogOrder()
    return currentOrder
end

-- Dialog 在实例化和销毁时触发事件
function res.RestoreDialogOrder(order)
    usedOrder[order] = nil
    if order == currentOrder then
        currentOrder = 0
        for k, v in pairs(usedOrder) do
            if k > currentOrder then
                currentOrder = k
            end
        end
    end

	local dialogs = res.curSceneInfo and res.curSceneInfo.dialogs
	if not dialogs or (dialogs and table.nums(dialogs) <= 0) then 
		EventSystem.SendEvent("AllDialogBeDestroy")
	end
end

function res.SetSceneLightmaps(paths)
    local lightmapTable = {}
    for i, path in ipairs(paths) do
        local lightmapData = LightmapData()
        lightmapData.lightmapLight = res.LoadRes(path)
        table.insert(lightmapTable, lightmapData)
    end
    local lightmaps = clr.array(lightmapTable, LightmapData)
    LightmapSettings.lightmaps = lightmaps
end

function res.ShowDebugInfo(data)
    local result = vardump(data)
    local str = table.concat(result, "\n")
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Control/Dialog/DebugDialog.prefab", "overlay", false, true)
    dialogcomp.contentcomp:setText(str)
end

function res.DontDestroyOnLoad(obj)
    ResManager.DontDestroyOnLoad(obj)
    ResManager.CanDestroyAll(obj)
end
function res.DontDestroyOnLoadAndDestroyAll(obj)
    ResManager.DontDestroyOnLoad(obj)
end
function res.DestroyAll()
    ResManager.DestroyAll()

    luaevt.trig("res_destroyAll")
end
function res.DestroyAllHard()
    ResManager.DestroyAllHard()
end
function res.SaveCurObjects()
    ResManager.SaveCurObjects()
end
function res.DestroyAllExceptSaved()
    ResManager.DestroyAllExceptSaved()
end

function res.LoadRes(name, type)
    return ResManager.LoadRes(name, type)
end

function res.LoadResAsync(name, type)
    return ResManager.LoadResAsync(name, type)
end

function res.UnloadAllRes(keepReferencedAssets)
    ResManager.UnloadAllRes(not not keepReferencedAssets)
end

function res.UnloadUnusedRes()
    UnityEngine.Resources.UnloadUnusedAssets();
    ResManager.UnloadUnusedRes()
end

function res.UnloadUnusedResAsync()
    local op = UnityEngine.Resources.UnloadUnusedAssets();
    coroutine.yield(op)
    ResManager.UnloadUnusedRes()
end

function res.UnloadAllBundleSoft()
    --ResManager.UnloadAllBundleSoft()
end

function res.UnloadUnusedResDeep(funcDone)
    clr.coroutine(function()
        for i = 1, 3 do
            collectgarbage()
            clr.System.GC.Collect()
            res.UnloadUnusedResAsync()
            coroutine.yield()
        end

        if type(funcDone) == "function" then
            unity.waitForEndOfFrame()
            funcDone()
        end
    end)
end

function res.CollectGarbageDeep(funcDone)
    clr.coroutine(function()
        for i = 1, 3 do
            collectgarbage()
            clr.System.GC.Collect()
            local op = UnityEngine.Resources.UnloadUnusedAssets();
            coroutine.yield(op)
            unity.waitForNextEndOfFrame()
        end

        if type(funcDone) == "function" then
            unity.waitForEndOfFrame()
            funcDone()
        end
    end)
end

function res.CollectGarbage()
    clr.coroutine(function()
        collectgarbage()
        clr.System.GC.Collect()
        local op = UnityEngine.Resources.UnloadUnusedAssets()
        coroutine.yield(op)
    end)
end

local ResCache = {}

function res.CacheRes(name)
	local handle = ResCache[name]
	if handle then
		handle.AddRef()  --Lua assist checked flag
	else
		local ai = ResManager.PreloadRes(name)
		if ai then
			local handle = {}
			ResCache[name] = handle

			local RefCnt = 1
			handle.AddRef = function()
				RefCnt = RefCnt + 1
			end
			handle.Release = function()
				RefCnt = RefCnt - 1
				if RefCnt <= 0 then
					handle.Destroy()  --Lua assist checked flag
				end
			end
			handle.Destroy = function()
				ai:Release()
				ResCache[name] = nil
			end
		end
    end
end

function res.UncacheRes(name)
    local handle = ResCache[name]
    if handle then
        handle.Release()  --Lua assist checked flag
    end
end

function res.ClearResCache()
	local handles = {}
	for k, v in pairs(ResCache) do
		handles[#handles + 1] = v
	end
	for i, v in ipairs(handles) do
		v.Destroy()  --Lua assist checked flag
	end
end

function res.GetMobcastUserAgentAppendStr()
    local appName = luaevt.trig("SDK_GetAppName")
    if appName then
        return format("[CMM_IAB/%s;]", appName)
    end
end

return res
