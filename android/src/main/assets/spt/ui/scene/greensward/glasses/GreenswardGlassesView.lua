local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardFlashBangView = require("ui.scene.greensward.flashBang.GreenswardFlashBangView")

local GreenswardGlassesView = class(GreenswardFlashBangView, "GreenswardGlassesView")

function GreenswardGlassesView:ctor()
    GreenswardGlassesView.super.ctor(self)
    -- 结束查看
    self.btnOver = self.___ex.btnOver
    -- 特效的网格
    self.gridVfx = self.___ex.gridVfx
    self.imgClouds = self.___ex.imgClouds

    self.cloudResCache = {}
end

function GreenswardGlassesView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.btnCancel:regOnButtonClick(function()
        self:OnBtnCancel()
    end)
    self.btnOver:regOnButtonClick(function()
        self:OnBtnOver()
    end)
    self:StopVfx()
end

-- @ param size [int]: 光亮区域的格子数，规定为正方形
function GreenswardGlassesView:InitView(size)
    GreenswardGlassesView.super.InitView(self, size)
    GameObjectHelper.FastSetActive(self.btnConfirm.gameObject, true)
    GameObjectHelper.FastSetActive(self.btnCancel.gameObject, true)
    GameObjectHelper.FastSetActive(self.btnOver.gameObject, false)
end

-- 计算特效播放的位置，透视镜模拟原来的云彩，直接返回左上角位置
-- @param x&y: 选区左上角格子的数值位置
-- @param size_x&size_y: 选区的大小
function GreenswardGlassesView:CalcVfxPos(x, y, size_x, size_y)
    return x, y
end

-- 点击结束查看
function GreenswardGlassesView:OnBtnOver()
    if self.onBtnOver ~= nil and type(self.onBtnOver) == "function" then
        self.onBtnOver()
    end
end

-- 设置云彩和地图上一致
function GreenswardGlassesView:SetClouds(stus)
    if self.eventModel == nil then
        return
    end
    self.gridVfx.constraintCount = tonumber(self.size_x)
    local capicity = table.nums(self.imgClouds)
    local count = self.size_x * self.size_y
    for i = 1, capicity do
        local isActive = (i <= count)
        GameObjectHelper.FastSetActive(self.imgClouds[tostring(i)].gameObject, isActive)
        self.imgClouds[tostring(i)].enabled = isActive
    end

    for k, st in ipairs(stus) do
        local resPathName = nil
        if st == self.eventModel.EventStatus.Lock then -- 白云
            resPathName = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Terrain/Cloud1.png"
        elseif st == self.eventModel.EventStatus.Lock_Effect then -- 雷云
            resPathName = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Terrain/Cloud2.png"
        elseif st == self.eventModel.EventStatus.Unlock then -- 红云
            resPathName = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectFog.prefab"
        end
        local cloudKey = tostring(k)
        local resKey = tostring(st)
        local cloudRes = self.cloudResCache[resKey]
        if cloudRes == nil and resPathName ~= nil then
            cloudRes = res.LoadRes(resPathName)
        end
        if cloudRes ~= nil then
            if st == self.eventModel.EventStatus.Unlock then -- 红云需要实例化prefab
                self.imgClouds[cloudKey].enabled = false
                local obj = Object.Instantiate(cloudRes)
                obj.transform:SetParent(self.imgClouds[cloudKey].transform, false)
            else -- 图片即可
                self.imgClouds[cloudKey].overrideSprite = cloudRes
            end
            self.cloudResCache[resKey] = cloudRes
        else
            self.imgClouds[cloudKey].enabled = false
        end
    end
end

-- 播放特效
function GreenswardGlassesView:PlayVfx(callback)
    GameObjectHelper.FastSetActive(self.btnConfirm.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnCancel.gameObject, false)
    GameObjectHelper.FastSetActive(self.btnOver.gameObject, true)

    GameObjectHelper.FastSetActive(self.rctSelectLight.gameObject, false)
    GameObjectHelper.FastSetActive(self.rctVfx.gameObject, true)
    self:coroutine(function()
        if callback ~= nil and type(callback) == "function" then
            callback()
        end
        GameObjectHelper.FastSetActive(self.rctVfx.gameObject, true)
    end)
end

return GreenswardGlassesView
