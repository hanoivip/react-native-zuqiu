-- local UseItemHelper = require("ui.controllers.greensward.item.itemAction.ItemActionUseItemHelper")
local ItemActionUseItemHelper = class()

-- 绿茵征途使用道具辅助方法
function ItemActionUseItemHelper.Use(itemId, row, col, callback)
    clr.coroutine(function()
        local response = req.greenswardAdventureUseItem(itemId, row, col)
        if api.success(response) then
            local data = response.val
            if not table.isEmpty(data) then
                local cost = nil
                if data.ret then
                    cost = data.ret.cost
                end
                if cost then
                    require("ui.models.greensward.item.GreenswardItemMapModel").new():SetItemNum(cost.id, cost.num, true)
                end
                EventSystem.SendEvent("Greensward_OnItemUsed")
                if callback ~= nil and type(callback) == "function" then
                    callback(data)
                end
            end
        end
    end)
end

return ItemActionUseItemHelper
