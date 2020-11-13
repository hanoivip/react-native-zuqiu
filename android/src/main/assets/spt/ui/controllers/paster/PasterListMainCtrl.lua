local PasterListModel = require("ui.models.itemList.PasterListModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local PasterListMainCtrl = class()

function PasterListMainCtrl:ctor(view)
    self.view = view
    self.cardResourceCache = CardResourceCache.new()
    self.view.clickCardPaster = function(cardPasterModel) self:OnClickCardPaster(cardPasterModel) end
end

function PasterListMainCtrl:RefreshView()
    self.pasterListModel = PasterListModel.new()
    self.view:InitView(self.pasterListModel, self.cardResourceCache)
end

function PasterListMainCtrl:OnClickCardPaster(cardPasterModel)
    res.PushDialog("ui.controllers.paster.PasterDetailCtrl", cardPasterModel)
end

function PasterListMainCtrl:OnEnterScene()
    self.view:EnterScene()
end

function PasterListMainCtrl:OnExitScene()
    self.view:ExitScene()
end

function PasterListMainCtrl:MoveOutScene()
    self.cardResourceCache:Clear()
end

return PasterListMainCtrl
