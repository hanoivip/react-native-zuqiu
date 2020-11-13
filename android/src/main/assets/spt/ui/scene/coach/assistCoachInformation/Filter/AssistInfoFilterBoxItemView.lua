local SingleSelectFilterBoxItemView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoxItemView")

local AssistInfoFilterBoxItemView = class(SingleSelectFilterBoxItemView, "AssistInfoFilterBoxItemView")

function AssistInfoFilterBoxItemView:ctor()
    AssistInfoFilterBoxItemView.super.ctor(self)
end

function AssistInfoFilterBoxItemView:InitView(filterData, filterType)
    AssistInfoFilterBoxItemView.super.InitView(self, filterData, filterType)
end

return AssistInfoFilterBoxItemView
