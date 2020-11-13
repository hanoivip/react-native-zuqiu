local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ItemType = require("ui.scene.itemList.ItemType")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionTreasureOpenCtrl = class(BaseCtrl, "ItemActionTreasureOpenCtrl")

-- 绿茵征途道具，探宝行为
function ItemActionTreasureOpenCtrl:Init(greenswardItemActionModel, greenswardBuildModel, eventModel)
    ItemActionTreasureOpenCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionTreasureOpenCtrl:DoAction()
    local itemModel = self.actionModel:GetItemModel()-- GreenswardItemModel
    if not itemModel then return end

    local eventModel = self.actionModel:GetEventModel()
    if not eventModel then return end

    local itemId = itemModel:GetId()
    local row = self.actionModel:GetRow()
    local col = self.actionModel:GetCol()
    local costType = self.actionModel:GetCostType()

    clr.coroutine(function()
        local response = req.greenswardAdventureTreasureOpen(row, col, costType)
        if api.success(response) then
            local data = response.val
            local base = data.base or {}
            local map = data.ret and data.ret.map or {}
            local cost = data.ret and data.ret.cost or {}
            local cellResult = data.ret and data.ret.cellResult or {}
            self.buildModel:RefreshBaseInfo(base)
            -- 更新地图
            self.buildModel:RefreshEventModel(map)
            -- 回调
            eventModel:HandleEvent(data)
            -- 更新道具消耗
            if cost then
                require("ui.models.greensward.item.GreenswardItemMapModel").new():UpdateItemsFromCost(cost)
            end
            if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" and #res.curSceneInfo.dialogs > 0 then
                res.PopScene()
            end

            self:DoNextAction(cellResult.contents)
        end
    end)
end

return ItemActionTreasureOpenCtrl
