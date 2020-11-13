local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local PasterUpgradeModel = require("ui.models.pasterUpgrade.PasterUpgradeModel")
local PasterUpgradeFilterModel = require("ui.models.pasterUpgrade.PasterUpgradeFilterModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PasterUpgradeCtrl = class(BaseCtrl)


PasterUpgradeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PasterUpgrade/PasterUpgrade.prefab"

function PasterUpgradeCtrl:Init(cardPasterModel)
    self.cardPasterModel = cardPasterModel
    self.view.clickFilter = function() self:OnBtnFilter() end
    self.view.clickConfirm = function() self:OnBtnConfirm() end
end

function PasterUpgradeCtrl:Refresh(cardPasterModel)
    PasterUpgradeCtrl.super.Refresh(self)
    self.cardPasterModel = cardPasterModel
    if not self.pasterUpgradeModel then
        self.pasterUpgradeModel = PasterUpgradeModel.new(cardPasterModel)
    end
    self:InitView()
end

function PasterUpgradeCtrl:InitView()
    self.cardResourceCache = CardResourceCache.new()
    self.view:InitView(self.pasterUpgradeModel, self.cardResourceCache)
end

function PasterUpgradeCtrl:OnClickCardPaster(cardPasterModel)
    res.PushDialog("ui.controllers.paster.PasterDetailCtrl", cardPasterModel)
end

function PasterUpgradeCtrl:OnBtnFilter()
    local filterMap = self.pasterUpgradeModel:GetFilterMap()
    local pasterUpgradeFilterModel = PasterUpgradeFilterModel.new(filterMap)
    res.PushDialog("ui.controllers.pasterUpgrade.PasterUpgradeFilterCtrl", pasterUpgradeFilterModel)
end

function PasterUpgradeCtrl:OnBtnConfirm()
    local originPtid = self.pasterUpgradeModel:GetOriginPtid()
    local costPtids = self.pasterUpgradeModel:GetCostPtids()
    if costPtids and next(costPtids) then
        self.view:coroutine(function ()
            local response = req.pasterUpgrade(originPtid, costPtids)
            if api.success(response) then
                local data = response.val
                local originPasterModel = self.pasterUpgradeModel:GetCardPasterModel()
                res.PushDialog("ui.controllers.pasterUpgrade.PasterUpgradeResultBoardCtrl", data, originPasterModel, self.cardResourceCache)
            end
        end)
    else
        DialogManager.ShowToastByLang("paster_upgrade_empty")
    end
end

function PasterUpgradeCtrl:GetStatusData()
    return self.cardPasterModel
end

function PasterUpgradeCtrl:OnEnterScene()
    
end

function PasterUpgradeCtrl:OnExitScene()
    self.cardResourceCache:Clear()
end

return PasterUpgradeCtrl
