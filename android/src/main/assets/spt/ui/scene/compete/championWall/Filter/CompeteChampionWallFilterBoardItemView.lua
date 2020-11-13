local SingleSelectFilterBoardItemView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoardItemView")

local CompeteChampionWallFilterBoardItemView = class(SingleSelectFilterBoardItemView, "CompeteChampionWallFilterBoardItemView")

function CompeteChampionWallFilterBoardItemView:ctor()
    CompeteChampionWallFilterBoardItemView.super.ctor(self)
end

-- @parameter competeChampionWallModel: get from CompeteChampionWallView
-- @parameter filterDatas: defined in file: CompeteChampionWallFilterModel
-- @parameter filterType: defined in file: CompeteChampionWallFilterModel
function CompeteChampionWallFilterBoardItemView:InitView(competeChampionWallModel, filterDatas, filterType)
    CompeteChampionWallFilterBoardItemView.super.InitView(self, competeChampionWallModel, filterDatas, filterType)
end

function CompeteChampionWallFilterBoardItemView:SetName()
    if table.nums(self.filterDatas) > 0 then
        local name = self.filterDatas[tonumber(self.currChooseID)].name
        self.txt.text = name
        self.txtShadow.text = name
    end
end

return CompeteChampionWallFilterBoardItemView
