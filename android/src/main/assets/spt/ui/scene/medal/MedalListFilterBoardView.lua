local GameObjectHelper = require("ui.common.GameObjectHelper")
local MedalListFilterModel = require("ui.models.medal.MedalListFilterModel")

local MedalListFilterBoardView = class(unity.base, "MedalListFilterBoardView")

function MedalListFilterBoardView:ctor()
    self.filterEquip = self.___ex.filterEquip
    self.filterState = self.___ex.filterState
    self.filterQuality = self.___ex.filterQuality
    self.filterShape = self.___ex.filterShape
end

function MedalListFilterBoardView:start()
end

function MedalListFilterBoardView:InitView(medalListModel)
    self.filterEquip:InitView(medalListModel, MedalListFilterModel.Equip, MedalListFilterModel.FilterType.Equip)
    self.filterState:InitView(medalListModel, MedalListFilterModel.State, MedalListFilterModel.FilterType.State)
    self.filterQuality:InitView(medalListModel, MedalListFilterModel.Quality, MedalListFilterModel.FilterType.Quality)
    self.filterShape:InitView(medalListModel, MedalListFilterModel.Shape, MedalListFilterModel.FilterType.Shape)
    -- 装备状态栏   未携带优先
    EventSystem.SendEvent("MedalListFilter_OnFilterBoxItemClick", MedalListFilterModel.FirstStyle.Equip, MedalListFilterModel.FilterType.Equip)
end

function MedalListFilterBoardView:EnterScene()
    self.filterEquip:EnterScene()
    self.filterState:EnterScene()
    self.filterQuality:EnterScene()
    self.filterShape:EnterScene()
end

function MedalListFilterBoardView:ExitScene()
    self.filterEquip:ExitScene()
    self.filterState:ExitScene()
    self.filterQuality:ExitScene()
    self.filterShape:ExitScene()
end

return MedalListFilterBoardView
