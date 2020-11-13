local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ItemType = require("ui.scene.itemList.ItemType")
local BaseCtrl = require("ui.controllers.greensward.item.itemAction.GreenswardItemActionBaseCtrl")

local ItemActionDialogRewardCtrl = class(BaseCtrl, "ItemActionDialogRewardCtrl")

-- 绿茵征途道具，奖励结果行为
function ItemActionDialogRewardCtrl:Init(greenswardItemActionModel, greenswardBuildModel, contents)
    ItemActionDialogRewardCtrl.super.Init(self, greenswardItemActionModel, greenswardBuildModel)
end

function ItemActionDialogRewardCtrl:DoAction()
    local contents = self.actionModel:GetContents()
    local continueCallback = function()
        self:DoNextAction()
    end
    -- 展示奖励
    if not table.isEmpty(contents) then
        CongratulationsPageCtrl.new(contents)
    else
        DialogManager.ShowContinuePop(self.actionModel:GetTitle(), self.actionModel:GetMsg(), continueCallback)
    end
end

return ItemActionDialogRewardCtrl
