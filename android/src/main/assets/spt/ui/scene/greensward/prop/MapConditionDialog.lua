local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardResourceCache = require("ui.scene.greensward.GreenswardResourceCache")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MapConditionDialog = class(unity.base, "MapConditionDialog")

function MapConditionDialog:ctor()
    self.txtTitle = self.___ex.txtTitle
    self.txtFloor = self.___ex.txtFloor
    self.btnClose = self.___ex.btnClose
    self.areaMap = self.___ex.areaMap
    self.labelMap = self.___ex.labelMap
    self.main = self.___ex.main
    -- 宝藏预览
    self.btnRewardPreview = self.___ex.btnRewardPreview

    self.greenswardResourceCache = GreenswardResourceCache.Create()
end

function MapConditionDialog:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnRewardPreview:regOnButtonClick(function()
        self:OnBtnRewardPreview()
    end)
end

function MapConditionDialog:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.main.gameObject, isShow)
end

-- 3*3的区域
local StandGrid = 3
local function GenerateGridBuildData(appointGridRow, appointGridCol, maxRow, maxCol)
    appointGridRow = math.clamp(appointGridRow, 0, maxRow - StandGrid)
    appointGridCol = math.clamp(appointGridCol, 0, maxCol - StandGrid)
    local gridData = {}
    for i = appointGridRow, appointGridRow + StandGrid - 1 do
        for j = appointGridCol, appointGridCol + StandGrid - 1 do
            table.insert(gridData, {row = i, col = j})
        end
    end
    return gridData
end

local function toId(idx)
    return "s" .. tostring(idx)
end

-- 根据服务器传递的格子数据生成3*3的数据
-- 服务器发送的为3*3个字的左上角
-- 若服务器数据超过6_12，左上延申
local GridAreaNum = 6
function MapConditionDialog:InitView(buildModel, mapModel, treasureMapModel)
    self.txtFloor.text = lang.trans("floor_order", buildModel:GetCurrentFloor())
    local row = buildModel:GetGridRow()
    local col = buildModel:GetGridCol()
    local objRes = self:GetMapRes()
    local gridDatas = {}
    local conditionData = treasureMapModel:GetConditionMapData()
    for k, v in ipairs(conditionData) do
        gridDatas[toId(k)] = GenerateGridBuildData(v.row, v.col, row, col)
    end
    local eventModelsMap = buildModel:GetEventModels()
    for i = 1, GridAreaNum do
        local rctMapPiece = self.areaMap[toId(i)]
        local gridData = gridDatas[toId(i)]
        if gridData then
            GameObjectHelper.FastSetActive(rctMapPiece.gameObject, true)
            for i = 1, table.nums(gridData) do
                local singleData = gridData[i]
                local rowIndex = singleData.row
                local colIndex = singleData.col
                local obj = Object.Instantiate(objRes)
                local script = res.GetLuaScript(obj)
                local key = tostring(rowIndex) .. "_" .. tostring(colIndex)
                script:InitView(rowIndex, colIndex, eventModelsMap[key], self.greenswardResourceCache)
                obj.transform:SetParent(rctMapPiece, false)
            end
            self.labelMap[toId(i)].text = tostring(i)
        else
            GameObjectHelper.FastSetActive(rctMapPiece.gameObject, false)
        end
    end
end

function MapConditionDialog:GetMapRes()
    if not self.mapRes then
        self.mapRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/MapFrame.prefab")
    end
    return self.mapRes
end

function MapConditionDialog:onDestroy()
    self.mapRes = nil
    self.greenswardResourceCache:Release()
end

function MapConditionDialog:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 点击宝藏预览
function MapConditionDialog:OnBtnRewardPreview()
    if self.onBtnRewardPreview and type(self.onBtnRewardPreview) == "function" then
        self.onBtnRewardPreview()
    end
end

return MapConditionDialog
