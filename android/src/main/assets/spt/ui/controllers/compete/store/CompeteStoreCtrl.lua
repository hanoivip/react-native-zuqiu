local CompeteStoreModel = require("ui.models.compete.store.CompeteStoreModel")
local CompeteInfoBarCtrl = require("ui.controllers.common.CompeteInfoBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local CompeteStoreCtrl = class(BaseCtrl, "CompeteStoreCtrl")

CompeteStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Store/Prefab/CompeteStore.prefab"

function CompeteStoreCtrl:ctor()
end

function CompeteStoreCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = CompeteInfoBarCtrl.new(child, self)
    end)

    self.view.refreshAfterBought = function() self:RefreshAfterBought() end
end

function CompeteStoreCtrl:Refresh(competeStoreModel)
    CompeteStoreCtrl.super.Refresh(self)
    if not self.model then
        if competeStoreModel then
            self.model = competeStoreModel
        else
            self.model = CompeteStoreModel.new()
        end
    end

    clr.coroutine(function()
        local respone = req.worldTournamentShopInfo()
        if api.success(respone) then
            self.model:InitWithProtocol(respone.val)
            self:InitView()
        end
    end)
end

function CompeteStoreCtrl:GetStatusData()
    return self.model
end

function CompeteStoreCtrl:InitView()
    self.view.onClickBack = function()
        self:OnClickBack()
    end 
    self.view:InitView(self.model)
end

function CompeteStoreCtrl:OnClickBack()
    res.PopScene()
end

function CompeteStoreCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteStoreCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CompeteStoreCtrl:RefreshAfterBought()
    self.view:ClearScrollData()
    self:Refresh(self:GetStatusData())
end

return CompeteStoreCtrl