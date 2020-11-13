local BaseCtrl = require("ui.controllers.BaseCtrl")
local GreenswardRankModel = require("ui.models.greensward.rank.GreenswardRankModel")
local GreenswardRankCtrl = class(BaseCtrl, "GreenswardRankCtrl")

GreenswardRankCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Rank/GreenswardRankView.prefab"

function GreenswardRankCtrl:AheadRequest(greenswardBuildModel)
    self.greenswardRankModel = GreenswardRankModel.new()
    self.greenswardRankModel:SetGreenswardBuildModel(greenswardBuildModel)
    local response = req.greenswardAdventureRankView()
    if api.success(response) then
        local data = response.val
        self.greenswardRankModel:InitWithProtocol(data)
    end
end

function GreenswardRankCtrl:Init(greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    self.greenswardRankModel:SetGreenswardBuildModel(greenswardBuildModel)
    self.view.switchTag = function(seasonTag, regionTag)  self:OnSwitchTag(seasonTag, regionTag) end
end

function GreenswardRankCtrl:Refresh(greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    self.greenswardRankModel:SetGreenswardBuildModel(greenswardBuildModel)
    GreenswardRankCtrl.super.Refresh(self)
    self.view:InitView(self.greenswardRankModel)
end

function GreenswardRankCtrl:OnSwitchTag(seasonTag, regionTag)
    local tagData = self.greenswardRankModel:GetDataByTag(seasonTag, regionTag)
    if not tagData then
        self.view:coroutine(function()
            local response = req.greenswardAdventureRankBoard(seasonTag, regionTag)
            if api.success(response) then
                local data = response.val
                self.greenswardRankModel:SetRegionData(seasonTag, regionTag, data.list or data)
                tagData = self.greenswardRankModel:GetDataByTag(seasonTag, regionTag)
                self.view:RefreshScroll(tagData)
            end
        end)
    else
        self.view:RefreshScroll(tagData)
    end
end

function GreenswardRankCtrl:GetStatusData()
    return self.greenswardBuildModel
end

return GreenswardRankCtrl
