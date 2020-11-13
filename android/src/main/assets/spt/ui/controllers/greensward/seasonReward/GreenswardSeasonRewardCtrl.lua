local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GreenswardSeasonRewardModel = require("ui.models.greensward.seasonReward.GreenswardSeasonRewardModel")

local GreenswardSeasonRewardCtrl = class(BaseCtrl, "GreenswardSeasonRewardCtrl")

GreenswardSeasonRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/SeasonReward/GreenswardSeasonRewardView.prefab"
GreenswardSeasonRewardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardSeasonRewardCtrl:AheadRequest(greenswardBuildModel, introduceTab, regionTag)
    local response = req.greenswardAdventureFullStageRewardInfo()
    if api.success(response) then
        local data = response.val
        if not table.isEmpty(data) then
            self.greenswardSeasonRewardModel = GreenswardSeasonRewardModel.new()
            self.greenswardSeasonRewardModel:SetGreenswardBuildModel(greenswardBuildModel)
            self.greenswardSeasonRewardModel:InitWithProtocol(data)
            self.greenswardSeasonRewardModel:SetTabAndRegion(introduceTab, regionTag)
        end
    end
end

function GreenswardSeasonRewardCtrl:Init(greenswardBuildModel, introduceTab, regionTag)
    GreenswardSeasonRewardCtrl.super.Init(self)
    self.view.receiveReward = function(data) self:OnReceiveClick(data) end
    self.view:InitView(self.greenswardSeasonRewardModel)
end

function GreenswardSeasonRewardCtrl:Refresh(greenswardBuildModel, introduceTab, regionTag)
    GreenswardSeasonRewardCtrl.super.Refresh(self)
    self.view:RefreshView()
end

function GreenswardSeasonRewardCtrl:GetStatusData()
    self.greenswardSeasonRewardModel:GetStatusData()
end

function GreenswardSeasonRewardCtrl:OnReceiveClick(floorData)
    self.view:coroutine(function()
        local response = req.greenswardAdventureReceiveFullStageReward(floorData.floorID)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            self.greenswardSeasonRewardModel:RefreshData(data)
        end
    end)
end

function GreenswardSeasonRewardCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function GreenswardSeasonRewardCtrl:OnExitScene()
    self.view:OnExitScene()
end

return GreenswardSeasonRewardCtrl
