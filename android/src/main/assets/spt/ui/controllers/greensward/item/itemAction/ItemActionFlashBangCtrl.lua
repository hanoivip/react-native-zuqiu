local Object = clr.UnityEngine.Object
local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionFlashBangCtrl = class(BaseCtrl, "ItemActionFlashBangCtrl")

local FLASH_BANG_PATH = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/FlashBang.prefab"

-- 绿茵征途道具，使用照明弹行为
function ItemActionFlashBangCtrl:Init(greenswardItemActionModel, greenswardBuildModel, flashBang)
    ItemActionFlashBangCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
    self.flashBang = flashBang
end

function ItemActionFlashBangCtrl:DoAction()
    if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" and #res.curSceneInfo.dialogs > 0 then
        res.PopScene() -- 弹出背包
    end
    local obj, spt = res.Instantiate(FLASH_BANG_PATH)
    if obj and spt then
        self.flashBang = spt
        self.flashBang.onEnterConfirmStep = function(row, col) self:OnEnterConfirmStep(row, col) end
        self.flashBang.onEnterViewStep = function(leftup_row, leftup_col, size_x, size_y) self:OnEnterViewStep(leftup_row, leftup_col, size_x, size_y) end
        self.flashBang.onBtnConfirm = function(leftup_row, leftup_col, size_x, size_y) self:OnBtnConfirm(leftup_row, leftup_col, size_x, size_y) end
        self.flashBang.onBtnCancel = function() self:OnBtnCancel() end
        self.flashBang.onQuitFlashMode = function() self:OnQuitFlashMode() end
        self.flashBang:InitView(self.buildModel, self.actionModel:GetSize())
        self.flashBang:OnEnterScene()
        self.flashBang:EnterSelectStep() -- all start from here
    end
end

function ItemActionFlashBangCtrl:OnEnterConfirmStep(row, col)
    self.row = row
    self.col = col
end

function ItemActionFlashBangCtrl:OnEnterViewStep(leftup_row, leftup_col, size_x, size_y)
    self.leftup_row = leftup_row
    self.leftup_col = leftup_col
    self.size_x = size_x
    self.size_y = size_y
end

-- 点击选中区域的确认按钮，确认后进入特效阶段
function ItemActionFlashBangCtrl:OnBtnConfirm(leftup_row, leftup_col, size_x, size_y)
    local onConfirmCallback = function()
        self.flashBang:EnterViewStep(leftup_row, leftup_col, size_x, size_y)
        self:OnLighArea()
    end
    local title = self.actionModel:GetTitle()
    local msg = self.actionModel:GetMsg()
    local unlockCount = 0
    for row = leftup_row, leftup_row + size_y - 1 do
        for col = leftup_col, leftup_col + size_x - 1 do
            local eventModel = self.buildModel:GetGirdModel(row .. "_" .. col)
            if eventModel then
                local st = eventModel:GetCurrentState()
                if st == eventModel.EventStatus.Lock or st == eventModel.EventStatus.LockWithSign then
                    unlockCount = unlockCount + 1
                end
            end
        end
    end
    if unlockCount > 0 then
        msg = msg .. lang.transstr("flash_bang_light_tip", unlockCount)
    else
        msg = msg .. lang.transstr("flash_bang_light_tip_none")
    end

    DialogManager.ShowConfirmPop(title, msg, onConfirmCallback)
end

-- 点击选中区域的取消按钮，再次进入选择阶段
function ItemActionFlashBangCtrl:OnBtnCancel()
    self.flashBang:EnterSelectStep()
end

-- 退出照明弹模式
function ItemActionFlashBangCtrl:OnQuitFlashMode()
    self.flashBang:OnExitScene()
    Object.Destroy(self.flashBang.gameObject)
end

function ItemActionFlashBangCtrl:OnLighArea()
    local itemModel = self.actionModel:GetItemModel()
    if itemModel then
        local itemId = itemModel:GetId()
        local callback = function(data)
            local base = data.base
            local ret = data.ret
            local map = {}
            local cost = nil
            if ret then
                map = ret.map
                cost = ret.cost
            end
            self:DoNextAction()
            self.flashBang:PlayVfx(function()
                self.buildModel:RefreshBaseInfo(base)
                -- 更新地图
                self.buildModel:RefreshEventData(map)
            end)
        end
        UseItemHelper.Use(itemId, self.row, self.col, callback)
    end
end

return ItemActionFlashBangCtrl
