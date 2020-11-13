local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GreenswardFlashBangView = class(unity.base, "GreenswardFlashBangView")

local frame_size = 256
local map_rows = 9 -- 9行
local map_cols = 15 -- 15列
local align = 8 -- 洞和光亮区域调整对齐的参数

function GreenswardFlashBangView:ctor()
    self.rctHole = self.___ex.rctHole
    self.rctLight = self.___ex.rctLight
    self.rctOperate = self.___ex.rctOperate
    self.imgDark = self.___ex.imgDark
    self.btnConfirm = self.___ex.btnConfirm
    self.btnCancel = self.___ex.btnCancel
    self.rctSelectLight = self.___ex.rctSelectLight
    self.rctVfx = self.___ex.rctVfx

    self.size = nil
    self.eventModel = nil
end

function GreenswardFlashBangView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.btnCancel:regOnButtonClick(function()
        self:OnBtnCancel()
    end)
    self:StopVfx()
end

-- @ param size [int]: 光亮区域的格子数，规定为正方形
function GreenswardFlashBangView:InitView(size)
    self.size = size
    if self.size == nil then self.size = 3 end
    self:SetLightSize(self.size, self.size)
end

-- 被点击的事件的eventModel
function GreenswardFlashBangView:SetEventModel(eventModel)
    self.eventModel = eventModel
end

-- 进入选择区域阶段
function GreenswardFlashBangView:EnterSelectStep()
    self:SetDark(false)
    self:SetLightPos()
    self:SetSelectLightPos()
    self:SetFlashBangVfxPos()
end

-- 进入确认阶段
function GreenswardFlashBangView:EnterConfirmStep(row, col)
    self:FocusOn(row, col)
end

-- 进入特效阶段
function GreenswardFlashBangView:EnterViewStep(leftup_row, leftup_col, size_x, size_y)
end

-- 黑色遮罩的黑暗程度
function GreenswardFlashBangView:SetDark(isShow)
    self.imgDark.color = isShow and Color(0, 0, 0, 120 /255) or Color(0, 0, 0, 64 /255)
end

-- 设置光亮的大小
-- @param x&y [int]: 大小x表横向格子数，y表纵向格子数
function GreenswardFlashBangView:SetLightSize(x, y)
    local width = x * frame_size
    local height = y * frame_size
    self.rctHole.sizeDelta = Vector2(width, height)
    self.rctOperate.sizeDelta = Vector2(width, height)
    self.rctLight.sizeDelta = Vector2(width + 2 * align, height + 2 * align)
end

-- 设置光亮的位置
-- @param x&y [float]: 左上角的数值位置
function GreenswardFlashBangView:SetLightPos(x, y)
    if x == nil or y == nil then
        x = -2000
        y = 2000
    end
    self.rctHole.anchoredPosition = Vector2(x, y)
    self.rctOperate.anchoredPosition = Vector2(x, y)
    self.rctLight.anchoredPosition = Vector2(x - align, y + align)
end

-- 设置被点击的地块发光的光亮的位置
-- @param x&y [float]: 被点击地块数值位置
function GreenswardFlashBangView:SetSelectLightPos(x, y)
    if x == nil or y == nil then
        x = -2000
        y = 2000
    end
    self.rctSelectLight.anchoredPosition = Vector2(x, y)
end

-- 设置特效播放的位置
function GreenswardFlashBangView:SetFlashBangVfxPos(x, y)
    if x == nil or y == nil then
        x = -2000
        y = 2000
    end
    self.rctVfx.anchoredPosition = Vector2(x, y)
end

-- 选中某个格子，照亮以该格子为中心的区域
-- row、col为需照亮区域的逻辑中心，从0计数
-- 若触碰到地图边缘，缩小光亮区域适应边缘
function GreenswardFlashBangView:FocusOn(row, col)
    self:SetDark(true)
    local leftup_offset = math.floor((self.size - 1) / 2)
    local rightbottom_offset = self.size - leftup_offset - 1
    -- 计算左上角方格的位置
    local leftup_row = math.clamp(row - leftup_offset, 0, row)
    local leftup_col = math.clamp(col - leftup_offset, 0, col)
    -- 计算右下角方格的位置
    local rightbottom_row = math.clamp(row + rightbottom_offset, row, map_rows - 1)
    local rightbottom_col = math.clamp(col + rightbottom_offset, col, map_cols - 1)
    -- 重新计算实际的光亮的大小，超越边缘被截取
    local size_x = math.min(self.size, rightbottom_col - leftup_col + 1)
    local size_y = math.min(self.size, rightbottom_row - leftup_row + 1)
    self.leftup_row = leftup_row
    self.leftup_col = leftup_col
    self.size_x = size_x
    self.size_y = size_y
    self:SetLightSize(size_x, size_y)
    local lightPos_x, lightPos_y = self:MapToPos(leftup_row, leftup_col)
    self:SetLightPos(lightPos_x, lightPos_y)
    self:SetSelectLightPos(self:MapToPos(row, col))
    self:SetFlashBangVfxPos(self:CalcVfxPos(lightPos_x, lightPos_y, size_x, size_y))
end

-- 将地图位置转换成数值位置
function GreenswardFlashBangView:MapToPos(row, col)
    return col * frame_size, -row * frame_size
end

-- 计算特效播放的位置，整个选区的中间
-- @param x&y: 选区左上角格子的数值位置
-- @param size_x&size_y: 选区的大小
function GreenswardFlashBangView:CalcVfxPos(x, y, size_x, size_y)
    return x + frame_size * (size_x - 1) / 2, y - frame_size * (size_y - 1) / 2
end

-- 点击确认
function GreenswardFlashBangView:OnBtnConfirm()
    if self.onBtnConfirm ~= nil and type(self.onBtnConfirm) == "function" then
        self.onBtnConfirm(self.leftup_row, self.leftup_col, self.size_x, self.size_y)
    end
end

-- 点击取消
function GreenswardFlashBangView:OnBtnCancel()
    if self.onBtnCancel ~= nil and type(self.onBtnCancel) == "function" then
        self.onBtnCancel()
    end
end

-- 播放特效
function GreenswardFlashBangView:PlayVfx(callback)
    GameObjectHelper.FastSetActive(self.imgDark.gameObject, false)
    self:SetLightPos()
    self:SetSelectLightPos()
    GameObjectHelper.FastSetActive(self.rctVfx.gameObject, true)
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(0.6))
        if callback ~= nil and type(callback) == "function" then
            callback()
        end
        coroutine.yield(WaitForSeconds(0.3))
        self:StopVfx()
        EventSystem.SendEvent("GreenswardFlashBang_QuitFlashBang")
    end)
end

-- 停止播放特效
function GreenswardFlashBangView:StopVfx()
    GameObjectHelper.FastSetActive(self.rctVfx.gameObject, false)
end

return GreenswardFlashBangView
