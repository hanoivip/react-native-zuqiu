local UnityEngine = clr.UnityEngine
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local GreenswardEvnetEnum = require("ui.scene.greensward.GreenswardEvnetEnum")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GreenswardBuildModel = require("ui.models.greensward.build.GreenswardBuildModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GridGuideView = class(unity.base, "GridGuideView")

local frame_size = 256
local map_rows = 9 -- 9行
local map_cols = 15 -- 15列
local align = 8 -- 洞和光亮区域调整对齐的参数

function GridGuideView:ctor()
    self.rctHole = self.___ex.rctHole
    self.rctLight = self.___ex.rctLight
    self.imgDark = self.___ex.imgDark
    self.rctSelectLight = self.___ex.rctSelectLight
    self.canvasFlash = self.___ex.canvasFlash
    self.hand = self.___ex.hand
    self.graphic = self.___ex.graphic
    self.size = nil
end

function GridGuideView:start()
    self.canvasFlash.worldCamera = GameObject.Find("WorldCamera"):GetComponent("Camera")
    EventSystem.SendEvent("GreenswardGraphicRaySwitch", self.step, true)
end

function GridGuideView:onDestroy()
    EventSystem.SendEvent("GreenswardGraphicRaySwitch", self.step, false)
end

function GridGuideView:InitView()
    local step = GuideManager.guideModel:GetCurStep()
    self.step = step
    if tonumber(step) == 70200 then
        self:FocusOn(4, 12)
        EventSystem.SendEvent("Greensward_GridMove", 4, 12, 1)
    elseif tonumber(step) == 70300 then
        self:FocusOn(4, 13)
        EventSystem.SendEvent("Greensward_GridMove", 4, 13, 1)
    elseif tonumber(step) == 70400 then
        EventSystem.SendEvent("Greensward_GridMove", 4, 0)
        self:FocusOn(4, 0)
    elseif tonumber(step) == 70700 then
        local model = GreenswardBuildModel.Instance:GetEventModel(GreenswardEvnetEnum.Treasure_Boss2)
        local row = model:GetRow()
        local col = model:GetCol()
        EventSystem.SendEvent("Greensward_GridMove", row, col)
        self:FocusOn(row, col)
        GameObjectHelper.FastSetActive(self.hand.gameObject, true)
        GameObjectHelper.FastSetActive(self.graphic.gameObject, false)
    elseif tonumber(step) == 71000 then
        local model = GreenswardBuildModel.Instance:GetEventModel(GreenswardEvnetEnum.Leader1)
        if not model then
            model = GreenswardBuildModel.Instance:GetEventModel(GreenswardEvnetEnum.Leader2)
        end
        local row = model:GetRow()
        local col = model:GetCol()
        EventSystem.SendEvent("Greensward_GridMove", row, col)
        self:FocusOn(row, col)
    end
end

-- 设置光亮的位置
-- @param x&y [float]: 左上角的数值位置
function GridGuideView:SetLightPos(x, y)
    if x == nil or y == nil then
        x = -2000
        y = 2000
    end
    self.rctHole.anchoredPosition = Vector2(x, y)
    self.rctLight.anchoredPosition = Vector2(x - align, y + align)
end

-- 设置被点击的地块发光的光亮的位置
-- @param x&y [float]: 被点击地块数值位置
function GridGuideView:SetSelectLightPos(x, y)
    if x == nil or y == nil then
        x = -2000
        y = 2000
    end
    self.rctSelectLight.anchoredPosition = Vector2(x, y)
end

function GridGuideView:FocusOn(row, col)
    local lightPos_x, lightPos_y = self:MapToPos(row, col)
    self:SetLightPos(lightPos_x, lightPos_y)
    self:SetSelectLightPos(self:MapToPos(row, col))
    --self:SetFlashBangVfxPos(self:CalcVfxPos(lightPos_x, lightPos_y, size_x, size_y))
end

-- 将地图位置转换成数值位置
function GridGuideView:MapToPos(row, col)
    return col * frame_size, -row * frame_size
end

-- 计算特效播放的位置，整个选区的中间
-- @param x&y: 选区左上角格子的数值位置
-- @param size_x&size_y: 选区的大小
function GridGuideView:CalcVfxPos(x, y, size_x, size_y)
    return x + frame_size * (size_x - 1) / 2, y - frame_size * (size_y - 1) / 2
end

return GridGuideView
