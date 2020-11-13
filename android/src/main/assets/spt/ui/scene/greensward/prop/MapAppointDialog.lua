local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardResourceCache = require("ui.scene.greensward.GreenswardResourceCache")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MapAppointDialog = class(unity.base, "MapAppointDialog")

function MapAppointDialog:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.txtFloor = self.___ex.txtFloor
    self.btnClose = self.___ex.btnClose
    self.rctMap = self.___ex.rctMap
    self.main = self.___ex.main
    -- 宝藏预览
    self.btnRewardPreview = self.___ex.btnRewardPreview

    self.greenswardResourceCache = GreenswardResourceCache.Create()
end

function MapAppointDialog:start()
    DialogAnimation.Appear(self.transform)
    self:ShowDisplayArea(false)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnRewardPreview:regOnButtonClick(function()
        self:OnBtnRewardPreview()
    end)
end

function MapAppointDialog:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.main.gameObject, isShow)
end

function MapAppointDialog:InitView(buildModel, mapModel, treasureMapModel)
    self.txtFloor.text = lang.trans("floor_order", buildModel:GetCurrentFloor())
    local col = buildModel:GetGridCol()
    local row = buildModel:GetGridRow()
    local mapRes = self:GetMapRes()
    local circleRes = self:GetCircleRes()
    for i = 1, row do
        for j = 1, col do
            local rowIndex, colIndex = i - 1, j - 1
            local key = tostring(rowIndex) .. "_" .. tostring(colIndex)
            local obj = Object.Instantiate(mapRes)
            local spt = res.GetLuaScript(obj)
            obj.transform:SetParent(self.rctMap, false)
            local eventModelsMap = buildModel:GetEventModels()
            spt:InitView(rowIndex, colIndex, eventModelsMap[key], self.greenswardResourceCache)
            -- 添加圆圈
            if treasureMapModel:IsTreasure(key) then
                local circleObj = Object.Instantiate(circleRes)
                circleObj.transform:SetParent(obj.transform, false)
            end
        end
    end
end

function MapAppointDialog:GetMapRes()
    if not self.mapRes then
        self.mapRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/MapFrame.prefab")
    end
    return self.mapRes
end

function MapAppointDialog:GetCircleRes()
    if not self.circleRes then
        self.circleRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/TreasureMapCircle.prefab")
    end
    return self.circleRes
end

function MapAppointDialog:onDestroy()
    self.mapRes = nil
    self.circleRes = nil
    self.greenswardResourceCache:Release()
end

function MapAppointDialog:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 点击宝藏预览
function MapAppointDialog:OnBtnRewardPreview()
    if self.onBtnRewardPreview and type(self.onBtnRewardPreview) == "function" then
        self.onBtnRewardPreview()
    end
end

return MapAppointDialog
