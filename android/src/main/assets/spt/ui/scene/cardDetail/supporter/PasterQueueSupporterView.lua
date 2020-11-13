local PasterQueueView = require("ui.scene.paster.PasterQueueView")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterQueueSupporterView = class(PasterQueueView, "PasterQueueSupporterView")

function PasterQueueSupporterView:ctor()
    PasterQueueSupporterView.super.ctor(self)
    self.noPaster = self.___ex.noPaster
end

function PasterQueueSupporterView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform)
end

function PasterQueueSupporterView:InitView(pasterQueueModel)
    self.pasterQueueModel = pasterQueueModel
    self.cardModel = pasterQueueModel:GetCardModel()
    self.selectCardAppendPasterModel = pasterQueueModel:GetSelectCardAppendPasterModel()
    self.scrollView:InitView(self.pasterQueueModel, true)
    GameObjectHelper.FastSetActive(self.noPaster, #pasterQueueModel:GetPasterModelList() == 0)
end

return PasterQueueSupporterView
