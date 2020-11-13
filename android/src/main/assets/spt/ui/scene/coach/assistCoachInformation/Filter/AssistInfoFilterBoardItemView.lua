local SingleSelectFilterBoardItemView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoardItemView")

local AssistInfoFilterBoardItemView = class(SingleSelectFilterBoardItemView, "SingleSelectFilterBoardItemView")

function AssistInfoFilterBoardItemView:ctor()
    AssistInfoFilterBoardItemView.super.ctor(self)
end

-- @parameter assistCoachInformationModel: get from AssistCoachInformationView
-- @parameter filterDatas: defined in file: AssistCoachFilterModel
-- @parameter filterType: defined in file: AssistCoachFilterModel
function AssistInfoFilterBoardItemView:InitView(assistCoachInformationModel, filterDatas, filterType)
    AssistInfoFilterBoardItemView.super.InitView(self, assistCoachInformationModel, filterDatas, filterType)
end

return AssistInfoFilterBoardItemView
