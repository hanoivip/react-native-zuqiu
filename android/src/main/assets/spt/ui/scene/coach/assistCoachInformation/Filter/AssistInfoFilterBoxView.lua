local SingleSelectFilterBoxView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoxView")

local AssistInfoFilterBoxView = class(SingleSelectFilterBoxView, "AssistInfoFilterBoxView")

local MedalListFilterBoxItemPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistInfoFilterBoxItem.prefab"

function AssistInfoFilterBoxView:ctor()
    AssistInfoFilterBoxView.super.ctor(self)
end

function AssistInfoFilterBoxView:InitView(filterDatas, filterType)
    self.boxItemPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistInfoFilterBoxItem.prefab"
    AssistInfoFilterBoxView.super.InitView(self, filterDatas, filterType)
end

return AssistInfoFilterBoxView
