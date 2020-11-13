local Object = clr.UnityEngine.Object
local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionGlassesCtrl = class(BaseCtrl, "ItemActionGlassesCtrl")

local GLASSES_PATH = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/Glasses.prefab"

-- 绿茵征途道具，使用透视镜行为
function ItemActionGlassesCtrl:Init(greenswardItemActionModel, greenswardBuildModel, sptGlasses)
    ItemActionGlassesCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
    self.sptGlasses = sptGlasses
end

function ItemActionGlassesCtrl:DoAction()
    if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" and #res.curSceneInfo.dialogs > 0 then
        res.PopScene() -- 弹出背包
    end
    local obj, spt = res.Instantiate(GLASSES_PATH)
    if obj and spt then
        self.sptGlasses = spt
        self.sptGlasses.onEnterConfirmStep = function(row, col) self:OnEnterConfirmStep(row, col) end
        self.sptGlasses.onEnterViewStep = function(leftup_row, leftup_col, size_x, size_y) self:OnEnterViewStep(leftup_row, leftup_col, size_x, size_y) end
        self.sptGlasses.onBtnConfirm = function(leftup_row, leftup_col, size_x, size_y) self:OnBtnConfirm(leftup_row, leftup_col, size_x, size_y) end
        self.sptGlasses.onBtnCancel = function() self:OnBtnCancel() end
        self.sptGlasses.onBtnOver = function() self:OnBtnOver() end -- 查看阶段结束查看事件
        self.sptGlasses.onQuitFlashMode = function() self:OnQuitFlashMode() end
        self.sptGlasses:InitView(self.buildModel, self.actionModel:GetSize())
        self.sptGlasses:OnEnterScene()
        self.sptGlasses:EnterSelectStep() -- all start from here
    end
end

function ItemActionGlassesCtrl:OnEnterConfirmStep(row, col)
    self.row = row
    self.col = col
end

-- 进入查看阶段，生成云覆盖区域，以便之后播放特效
function ItemActionGlassesCtrl:OnEnterViewStep(leftup_row, leftup_col, size_x, size_y)
    self.leftup_row = leftup_row
    self.leftup_col = leftup_col
    self.size_x = size_x
    self.size_y = size_y
    local stus = {}
    for row = leftup_row, leftup_row + size_y - 1 do
        for col = leftup_col, leftup_col + size_x - 1 do
            local eventModel = self.buildModel:GetGirdModel(row .. "_" .. col)
            if eventModel then
                local st = eventModel:GetCurrentState()
                table.insert(stus, st)
            end
        end
    end
    self.sptGlasses:SetClouds(stus)
end

-- 点击选中区域的确认按钮，确认后进入特效阶段
function ItemActionGlassesCtrl:OnBtnConfirm(leftup_row, leftup_col, size_x, size_y)
    local onConfirmCallback = function()
        self.sptGlasses:EnterViewStep(leftup_row, leftup_col, size_x, size_y)
        self:OnLighArea()
    end
    local title = self.actionModel:GetTitle()
    local msg = self.actionModel:GetMsg()

    DialogManager.ShowConfirmPop(title, msg, onConfirmCallback)
end

-- 点击选中区域的取消按钮，再次进入选择阶段
function ItemActionGlassesCtrl:OnBtnCancel()
    self.sptGlasses:EnterSelectStep()
end

-- 查看阶段点击查看结束按钮，确认后退出模式
function ItemActionGlassesCtrl:OnBtnOver()
    local onConfirmCallback = function()
        EventSystem.SendEvent("GreenswardFlashBang_QuitFlashBang")
    end
    local title = self.actionModel:GetTitleOver()
    local msg = self.actionModel:GetMsgOver()
    DialogManager.ShowMessageBox(title, msg, onConfirmCallback, lang.transstr("view_continue"), lang.transstr("view_over"))
end

function ItemActionGlassesCtrl:OnQuitFlashMode()
    self.sptGlasses:OnExitScene()
    Object.Destroy(self.sptGlasses.gameObject)
    -- 恢复所有地形
    self.buildModel:RefreshEventDataBack()
end

function ItemActionGlassesCtrl:OnLighArea()
    local itemModel = self.actionModel:GetItemModel()
    if itemModel then
        local itemId = itemModel:GetId()
        local callback = function(data)
            local base = data.base
            local ret = data.ret
            local map = {}
            local glassMap = {}
            local cost = nil
            if ret then
                map = ret.map
                cost = ret.cost
                glassMap = ret.glassMap
            end
            self:DoNextAction()
            self.sptGlasses:PlayVfx(function()
                self.buildModel:RefreshBaseInfo(base)
                -- 临时更新地图
                self.buildModel:RefreshEventDataTemp(glassMap)
            end)
        end
        UseItemHelper.Use(itemId, self.row, self.col, callback)
    end
end

return ItemActionGlassesCtrl
