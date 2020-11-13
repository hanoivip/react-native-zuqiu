local Model = require("ui.models.Model")
local Guide = require("data.Guide")

local GuideModel = class(Model)
local GuideState = { NotTrigger = 0, OnGoing = 1, Completed = 2 }

function GuideModel:ctor()
end

-- 模块类型
function GuideModel:GetModuleType(step)
    return Guide[tostring(step)].type
end

-- 断线重连step
function GuideModel:GetReturnPoint(step)
    return Guide[tostring(step)].returnPoint
end

-- 断线重连场景
function GuideModel:GetPage(step)
    return Guide[tostring(step)].page
end

-- 文本类型
function GuideModel:GetTextType(step)
    return Guide[tostring(step)].textType
end

-- 对话文本
function GuideModel:GetDialogText(step)
    return Guide[tostring(step)].text
end

function GuideModel:GetEmoji(step)
    return Guide[tostring(step)].emoji
end

-- 强制引导prefab
function GuideModel:GetGuidance(step)
    return Guide[tostring(step)].guidance
end

-- 当前正在引导的module
function GuideModel:GetCurModule()
    local playerGuide = cache.getPlayerGuide()
    return playerGuide["curModule"]
end

-- 断线重新登录时正在引导的module
function GuideModel:GetRturnPointModule()
    local playerGuide = cache.getPlayerGuide()
    if next(playerGuide) then
        for k, v in pairs(playerGuide) do
            if k ~= "curModule" and v ~= self:GetModuleMaxStep(k) then
                return k
            end
        end
    end
    return nil
end

-- 模块类型和其最大keypoint的map
function GuideModel:GetModuleMaxStepMap()
    local moduleMaxStepMap = { }
    for k, v in pairs(Guide) do
        if not moduleMaxStepMap[v.type] then
            moduleMaxStepMap[v.type] = tonumber(k)
        else
            if tonumber(k) > moduleMaxStepMap[v.type] then
                moduleMaxStepMap[v.type] = tonumber(k)
            end
        end
    end
    return moduleMaxStepMap
end

-- 获得模块类型对应的最大keypoint
function GuideModel:GetModuleMaxStep(moduleType)
    local moduleMaxStepMap = self:GetModuleMaxStepMap()
    return moduleMaxStepMap[moduleType]
end

-- 状态
function GuideModel:GetGuideState(moduleType)
    local playerGuide = cache.getPlayerGuide()
    if playerGuide[moduleType] then
        if playerGuide[moduleType] == self:GetModuleMaxStep(moduleType) then
            return GuideState.Completed
        else
            return GuideState.OnGoing
        end
    else
        return GuideState.NotTrigger
    end
end

-- 引导是否正在进行
function GuideModel:GuideIsOnGoing(moduleType)
    return self:GetGuideState(moduleType) == GuideState.OnGoing
end

-- 初始化，第一次触发时调用
function GuideModel:InitCurModule(moduleType)
    local playerGuide = cache.getPlayerGuide()
    if self:GetGuideState(moduleType) == GuideState.NotTrigger then
        playerGuide[moduleType] = 0
    end
    if self:GetGuideState(moduleType) == GuideState.OnGoing then
        playerGuide["curModule"] = moduleType
    elseif self:GetGuideState(moduleType) == GuideState.Completed then
        playerGuide["curModule"] = ""
    end
    cache.setPlayerGuide(playerGuide)
end

-- 设置模块的当前step
function GuideModel:SetCurStepWithModule()
    local modelType = self:GetCurModule()
    local playerGuide = cache.getPlayerGuide()
    if playerGuide[modelType] == 0 then
        playerGuide[modelType] = self:GetMinStep()
    else
        playerGuide[modelType] = self:GetNextStep()
    end
    cache.setPlayerGuide(playerGuide)
end

-- 最后一步时设置当前引导模块
function GuideModel:SetCurModuleWithMaxStep()
    local curModule = self:GetCurModule()
    if self:GetGuideState(curModule) == GuideState.Completed then
        local playerGuide = cache.getPlayerGuide()
        playerGuide["curModule"] = ""
        cache.setPlayerGuide(playerGuide)

        -- 新手引導完成
        if curModule == "main" then
            luaevt.trig("SDK_Report", "guide_done")
        end
    end    
end

-- 当前keypoint
function GuideModel:GetCurStep()
    local moduleType = self:GetCurModule()
    local playerGuide = cache.getPlayerGuide()
    return playerGuide[moduleType]
end

-- 最小keyPoint
function GuideModel:GetMinStep()
    local moduleType = self:GetCurModule()
    local initStep = false
    local minStep = 0
    for k, v in pairs(Guide) do
        if v.type == moduleType then
            if not initStep then
                initStep = true
                minStep = tonumber(k)
            end
            if tonumber(k) < minStep then
                minStep = tonumber(k)
            end
        end
    end
    return minStep
end

-- 最大keyPoint
function GuideModel:GetMaxStep()
    local moduleType = self:GetCurModule()
    local maxStep = 0
    for k, v in pairs(Guide) do
        if v.type == moduleType then
            if tonumber(k) > maxStep then
                maxStep = tonumber(k)
            end
        end
    end
    return maxStep
end

-- 下一个keyPoint
function GuideModel:GetNextStep()
    local curStep = self:GetCurStep()
    local maxStep = self:GetMaxStep()
    if curStep < maxStep then
        local stepTable = { }
        for k, v in pairs(Guide) do
            table.insert(stepTable, tonumber(k))
        end
        table.sort(stepTable, function(a, b) return a < b end)
        local nextStepIndex = 0
        for i, v in ipairs(stepTable) do
            if v == curStep then
                nextStepIndex = i + 1
                break
            end
        end
        return stepTable[nextStepIndex]
    else
        return maxStep
    end
end

-- 前一个keyPoint
function GuideModel:GetPreStep()
    local curStep = self:GetCurStep()
    local minStep = self:GetMinStep()
    if curStep > minStep then
        local stepTable = { }
        for k, v in pairs(Guide) do
            table.insert(stepTable, tonumber(k))
        end
        table.sort(stepTable, function(a, b) return a > b end)
        local preStepIndex = 0
        for i, v in ipairs(stepTable) do
            if v == curStep then
                preStepIndex = i + 1
                break
            end
        end
        return stepTable[preStepIndex]
    else
        return 0
    end
end

-- 引导结束
function GuideModel:IsGuideEnd()
    if self:GetCurStep() == self:GetMaxStep() then
        return true
    end
    return false
end

-- 缓存keypoint
function GuideModel:CacheStep(step)
    local moduleType = self:GetCurModule()
    local playerGuide = cache.getPlayerGuide()
    playerGuide[moduleType] = step
    cache.setPlayerGuide(playerGuide)
end

return GuideModel