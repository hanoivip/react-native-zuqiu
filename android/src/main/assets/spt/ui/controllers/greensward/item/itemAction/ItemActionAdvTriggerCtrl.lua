local DialogManager = require("ui.control.manager.DialogManager")
local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ItemType = require("ui.scene.itemList.ItemType")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionAdvTriggerCtrl = class(BaseCtrl, "ItemActionAdvTriggerCtrl")

-- 绿茵征途道具，修改地图事件行为
-- 目前包括鰓囊草、通行证、挖掘机
function ItemActionAdvTriggerCtrl:Init(greenswardItemActionModel, greenswardBuildModel, eventModel)
    ItemActionAdvTriggerCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionAdvTriggerCtrl:DoAction()
    local itemModel = self.actionModel:GetItemModel()-- GreenswardItemModel
    if not itemModel then return end

    local eventModel = self.actionModel:GetEventModel()
    if not eventModel then return end

    local itemId = itemModel:GetId()
    local row = self.actionModel:GetRow()
    local col = self.actionModel:GetCol()
    local costType = self.actionModel:GetCostType()

    clr.coroutine(function()
        local response = req.greenswardAdventureTrigger(row, col, costType)
        if api.success(response) then
            local data = response.val
            local base = data.base or {}
            local map = data.ret and data.ret.map or {}
            local cost = data.ret and data.ret.cost or {}
            local cellResult = data.ret and data.ret.cellResult or {}
            -- 更新道具消耗
            if cost then
                require("ui.models.greensward.item.GreenswardItemMapModel").new():UpdateItemsFromCost(cost)
            end
            self.buildModel:RefreshBaseInfo(base)
            -- 更新地图
            self.buildModel:RefreshEventData(map)
            -- 回调
            eventModel:HandleEvent(data)
            if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" and #res.curSceneInfo.dialogs > 0 then
                res.PopScene()
            end
            local tip = eventModel:GetTip()
            if next(cellResult) then
                CongratulationsPageCtrl.new(cellResult.contents)
            elseif tip and tip ~= "" then
                DialogManager.ShowToast(lang.trans(tip))
            end

            self:DoNextAction()
        end
    end)
end

return ItemActionAdvTriggerCtrl
