local BaseCtrl = require("ui.controllers.BaseCtrl")

local CompeteChampionWallOverviewCtrl = class(BaseCtrl, "CompeteChampionWallOverviewCtrl")

CompeteChampionWallOverviewCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/ChampionWall/Prefabs/CompeteChampionWallOverview.prefab"

CompeteChampionWallOverviewCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CompeteChampionWallOverviewCtrl:ctor()
    CompeteChampionWallOverviewCtrl.super.ctor(self)
end

function CompeteChampionWallOverviewCtrl:Init()
    self.view.onClickBtnClose = function() self:OnClickBtnClose() end
end

function CompeteChampionWallOverviewCtrl:Refresh(competeChampionWallOverviewModel)
    CompeteChampionWallOverviewCtrl.super.Refresh(self)
    if competeChampionWallOverviewModel ~= nil then
        self.model = competeChampionWallOverviewModel
        self.view:InitView(self.model)
    end
end

function CompeteChampionWallOverviewCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteChampionWallOverviewCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CompeteChampionWallOverviewCtrl:OnClickBtnClose()
    self.view:Close()
end

return CompeteChampionWallOverviewCtrl
