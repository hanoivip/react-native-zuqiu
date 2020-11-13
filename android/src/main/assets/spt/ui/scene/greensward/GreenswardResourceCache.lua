local AssetFinder = require("ui.common.AssetFinder")
local CardConfig = require("ui.common.card.CardConfig")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local GreenswardResourceCache = class()

local Instance = nil

--- 获取对象（与release对应）
function GreenswardResourceCache.Create()
    if Instance == nil then
        Instance = GreenswardResourceCache.new()
    else
        Instance:Retain()
    end

    return Instance
end

function GreenswardResourceCache:ctor()
    self.instanceCount = 1
    self:Reset()
end

function GreenswardResourceCache:Reset()
    self.grassCache = {}
    self.picCache = {}
    self.cloudCache = {}
    self.logoCache = {}
    self.headFrameCache = {}
    self.arrowCache = {}
    self.nameBorderCache = {}
end

function GreenswardResourceCache:GetGrassCache()
    return self.grassCache
end

function GreenswardResourceCache:Retain()
    self.instanceCount = self.instanceCount + 1
end

--（与create对应）
function GreenswardResourceCache:Release()
    self.instanceCount = self.instanceCount - 1
    if self.instanceCount <= 0 then
        self:Reset()
        Instance = nil
    end
end

function GreenswardResourceCache:Clear()
    self:Reset()
end

-- 草皮
function GreenswardResourceCache:GetGrassRes(basePic)
    if not self.grassCache[basePic] then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Terrain/".. basePic .. ".png"
        local icon = res.LoadRes(path)
        self.grassCache[basePic] = icon
    end
    return self.grassCache[basePic]
end

-- 上层地形
function GreenswardResourceCache:GetPicRes(picIndex)
    if not self.picCache[picIndex] then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Terrain/".. picIndex .. ".png"
        local icon = res.LoadRes(path)
        self.picCache[picIndex] = icon
    end
    return self.picCache[picIndex]
end

-- 迷雾
function GreenswardResourceCache:GetCloudRes(cloudIndex)
    if not self.cloudCache[cloudIndex] then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Terrain/".. cloudIndex .. ".png"
        local icon = res.LoadRes(path)
        self.cloudCache[cloudIndex] = icon
    end
    return self.cloudCache[cloudIndex]
end

-- logo资源
function GreenswardResourceCache:GetLogoRes(logoIndex)
    if not self.logoCache[logoIndex] then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/EventIcon/".. logoIndex .. ".png"
        local icon = res.LoadRes(path)
        self.logoCache[logoIndex] = icon
    end
    return self.logoCache[logoIndex]
end

-- 头像资源
function GreenswardResourceCache:GetHeadFrameRes(frameIndex)
    if not self.headFrameCache[frameIndex] then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/EventIcon/".. frameIndex .. ".png"
        local icon = res.LoadRes(path)
        self.headFrameCache[frameIndex] = icon
    end
    return self.headFrameCache[frameIndex]
end

-- 名字资源
function GreenswardResourceCache:GetNameBorderRes(name)
    if not self.nameBorderCache[name] then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Common/".. name .. ".png"
        local icon = res.LoadRes(path)
        self.nameBorderCache[name] = icon
    end
    return self.nameBorderCache[name]
end

local UpArrow = 1
local DownArrow = 2
-- 箭头指示
function GreenswardResourceCache:GetArrowRes(buffValue)
    local path = ""
    local index = 1
    if tonumber(buffValue) > 0 then
        path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Common/BuffArrowUp.png"
        index = UpArrow
    else
        path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Common/BuffArrowDown.png"
        index = DownArrow
    end

    if not self.arrowCache[index] then
        local icon = res.LoadRes(path)
        self.arrowCache[index] = icon
    end
    return self.arrowCache[index]
end

return GreenswardResourceCache
