local BaseCtrl = require("ui.controllers.BaseCtrl")
local GreenswardIntroduceModel = require("ui.models.greensward.introduce.GreenswardIntroduceModel")

local GreenswardIntroduceCtrl = class(BaseCtrl, "GreenswardIntroduceCtrl")

GreenswardIntroduceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/GreenswardIntroduceView.prefab"

GreenswardIntroduceCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardIntroduceCtrl:AheadRequest(greenswardBuildModel, introduceTab, regionTag, tabStates)
    local response = req.greenswardAdventureRewardInfo()
    if api.success(response) then
        local data = response.val
        if not table.isEmpty(data) then
            self.greenswardIntroduceModel = GreenswardIntroduceModel.new()
            self.greenswardIntroduceModel:SetGreenswardBuildModel(greenswardBuildModel)
            self.greenswardIntroduceModel:InitWithProtocol(data)
            self.greenswardIntroduceModel:SetTabAndRegion(introduceTab, regionTag)
            self.greenswardIntroduceModel:SetTabStates(tabStates)
        end
    end
end

function GreenswardIntroduceCtrl:Init()
    GreenswardIntroduceCtrl.super.Init(self)
    self.view:InitView(self.greenswardIntroduceModel)
end

function GreenswardIntroduceCtrl:Refresh()
    GreenswardIntroduceCtrl.super.Refresh(self)
    self.view:RefreshView()
end

function GreenswardIntroduceCtrl:GetStatusData()
    return self.model:GetStatusData()
end

return GreenswardIntroduceCtrl
