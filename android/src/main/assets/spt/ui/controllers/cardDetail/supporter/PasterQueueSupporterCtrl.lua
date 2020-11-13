local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterQueueSupporterCtrl = class(BaseCtrl, "PasterQueueSupporterCtrl")
PasterQueueSupporterCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/SupportPasterQueue.prefab"

function PasterQueueSupporterCtrl:ctor()
	PasterQueueSupporterCtrl.super.ctor()
end

function PasterQueueSupporterCtrl:Init(pasterQueueModel)
    self.view.clickCardPaster = function(cardAppendPasterModel) self:OnClickCardPaster(cardAppendPasterModel) end
end

function PasterQueueSupporterCtrl:Refresh(pasterQueueModel)
    self.pasterQueueModel = pasterQueueModel
	self.view:InitView(self.pasterQueueModel)
end

function PasterQueueSupporterCtrl:OnClickCardPaster(cardAppendPasterModel)
    res.PushDialog("ui.controllers.paster.PasterDetailCtrl", cardAppendPasterModel, true)
end

function PasterQueueSupporterCtrl:GetStatusData()
    return self.pasterQueueModel
end

return PasterQueueSupporterCtrl
