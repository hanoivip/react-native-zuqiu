local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerPasterListModel = require("ui.models.pasterBag.PlayerPasterListModel")
local CompetePasterListModel = require("ui.models.pasterBag.CompetePasterListModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local PasterBagMainCtrl = class(BaseCtrl)

PasterBagMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PasterBag/PasterBagMain.prefab"

function PasterBagMainCtrl:Refresh(menuType)
    PasterBagMainCtrl.super.Refresh(self)
    self:InitView(menuType)
end

function PasterBagMainCtrl:InitView(menuType)
    self.cardResourceCache = CardResourceCache.new()
    self.competePasterListModel = CompetePasterListModel.new()
    self.playerPasterListModel = PlayerPasterListModel.new()
    self.view:InitView(menuType, self.playerPasterListModel, self.competePasterListModel, self.cardResourceCache)
    self.view.pasterView.clickCardPaster = function(cardPasterModel) self:OnClickCardPaster(cardPasterModel) end
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.cardResourceCache:Clear()
            res.PopScene()
        end)
    end)
end

function PasterBagMainCtrl:OnClickCardPaster(cardPasterModel)
    res.PushDialog("ui.controllers.paster.PasterDetailCtrl", cardPasterModel)
end

function PasterBagMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function PasterBagMainCtrl:OnExitScene()
    self.view:OnExitScene()
    self.cardResourceCache:Clear()
end

return PasterBagMainCtrl
