local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardEventActionEffectHelper = require("ui.models.greensward.event.GreenswardEventActionEffectHelper")
local BuffExpandView = class(unity.base)

function BuffExpandView:ctor()
--------Start_Auto_Generate--------
    self.floorTrans = self.___ex.floorTrans
    self.floorContentTrans = self.___ex.floorContentTrans
    self.expandGo = self.___ex.expandGo
    self.expandArrowTrans = self.___ex.expandArrowTrans
    self.expandTxt = self.___ex.expandTxt
--------End_Auto_Generate----------
    self.layout =self.___ex.layout
    self.btnExpand = self.___ex.btnExpand
    self.btnExtraArea = self.___ex.btnExtraArea
end

function BuffExpandView:start()
    self.btnExpand:regOnButtonClick(function()
        self:OnRetract()
    end)
    self.btnExtraArea:regOnButtonClick(function()
        self:OnRetract()
    end)
end

function BuffExpandView:GetFloorRes()
    if not self.floorRes then
        self.floorRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/FloorBuff.prefab")
    end
    return self.floorRes
end

function BuffExpandView:GetTotalFloorRes()
    if not self.totalFloorRes then
        self.totalFloorRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/TotalFloorBuff.prefab")
    end
    return self.totalFloorRes
end

local MoveTime = 0.6
local MaxColNum = 5
local InitWidth = 108
local InitHeight = 110
function BuffExpandView:InitView(greenswardBuildModel, greenswardResourceCache)
    self.greenswardBuildModel = greenswardBuildModel
    self.greenswardResourceCache = greenswardResourceCache
    local buff = self.greenswardBuildModel:GetBuff()
    local floorBuff = buff.floor
    local currentFloor = self.greenswardBuildModel:GetCurrentFloor()
    local buffNum = 0
    if floorBuff then
        local sortFloor ={}
        for floor, v in pairs(floorBuff) do
            local floorIndex = floor
            local data = clone(v)
            data.floorIndex = tonumber(floorIndex)
            table.insert(sortFloor, data)
        end
        table.sort(sortFloor, function(a, b) return a.floorIndex < b.floorIndex end)
        local totalObjRes = self:GetTotalFloorRes()
        local objTotal = Object.Instantiate(totalObjRes)
        local totalSpt = res.GetLuaScript(objTotal)
        objTotal.transform:SetParent(self.floorContentTrans, false)
        totalSpt:InitView(currentFloor, floorBuff, self.greenswardResourceCache)
        buffNum = buffNum + 1
        for i, v in ipairs(sortFloor) do
            floor = v.floorIndex
            if floor <= currentFloor then
                local objRes = self:GetFloorRes()
                local obj = Object.Instantiate(objRes)
                local script = res.GetLuaScript(obj)
                obj.transform:SetParent(self.floorContentTrans, false)
                script:InitView(floor, floorBuff[tostring(floor)], self.greenswardResourceCache)
                buffNum = buffNum + 1
            else
                break
            end
        end
    end

    local col, row = 1, 1
    local width, height = InitWidth, InitHeight
    if buffNum > MaxColNum then
        col = MaxColNum
    else
        col = buffNum
    end

    row = math.ceil(buffNum / MaxColNum)
    width = col * self.layout.cellSize.x + (col - 1) * self.layout.spacing.x + self.layout.padding.left + self.layout.padding.right
    height = row * self.layout.cellSize.y + (row - 1) * self.layout.spacing.y + self.layout.padding.top + self.layout.padding.bottom
    local vec2 = Vector2(width, height)
    local callback = function()
        GameObjectHelper.FastSetActive(self.expandGo, true)
    end
    GreenswardEventActionEffectHelper.CreateSizeMoveExtensions(self.floorTrans, vec2, MoveTime, callback)
end

local RetractTime = 0.4
function BuffExpandView:OnRetract()
    local vec2 = Vector2(InitWidth, InitHeight)
    local callback = function()
        EventSystem.SendEvent("GreenswardBuffRetract")
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    GreenswardEventActionEffectHelper.CreateSizeMoveExtensions(self.floorTrans, vec2, RetractTime, callback)
end

function BuffExpandView:onDestroy()
    self.floorRes = nil
    self.totalFloorRes = nil
end

return BuffExpandView
