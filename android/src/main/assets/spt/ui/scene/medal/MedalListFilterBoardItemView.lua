local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require ("EventSystem")

local MedalListFilterBoardItemView = class(unity.base, "MedalListFilterBoardItemView")

function MedalListFilterBoardItemView:ctor()
    self.opened = self.___ex.opened
    self.txt = self.___ex.txt
    self.rctArrow = self.___ex.rctArrow
    self.box = self.___ex.box
    self.click = self.___ex.click

    self.filterDatas = nil
    self.filterType = nil
    self.medalListModel = nil
    self.currChooseID = 1
    self.isOpen = false
end

function MedalListFilterBoardItemView:start()
    self.click:regOnButtonClick(function()
        self:OnItemClick()
    end)
end

-- @parameter medalListModel: get from MedalListFilterBoardView
-- @parameter filterDatas: defined in file: MedalListFilterModel
-- @parameter filterType: defined in file: MedalListFilterModel
function MedalListFilterBoardItemView:InitView(medalListModel, filterDatas, filterType)
    self.filterDatas = filterDatas
    self.filterType = filterType
    self.medalListModel = medalListModel
    self.currChooseID = 1

    local name = lang.trans(filterDatas[1].name)
    self.txt.text = name
    self.box:InitView(filterDatas, filterType)

    self.isOpen = false
    GameObjectHelper.FastSetActive(self.opened.gameObject, self.isOpen)
    GameObjectHelper.FastSetActive(self.box.gameObject, self.isOpen)
end

function MedalListFilterBoardItemView:EnterScene()
    EventSystem.AddEvent("MedalListFilter_OnClickFilterMask", self, self.SetBoxState)
    EventSystem.AddEvent("MedalListFilter_OnFilterBoxItemClick", self, self.OnFilterBoxItemClick)
end

function MedalListFilterBoardItemView:ExitScene()
    EventSystem.RemoveEvent("MedalListFilter_OnClickFilterMask", self, self.SetBoxState)
    EventSystem.RemoveEvent("MedalListFilter_OnFilterBoxItemClick", self, self.OnFilterBoxItemClick)
end

function MedalListFilterBoardItemView:OnItemClick()
    if not self.isOpen then
        EventSystem.SendEvent("MedalListFilter_OnClickFilterMask", false) -- close other filter boxes
    end
    self:SetBoxState(not self.isOpen)
    EventSystem.SendEvent("MedalListFilter_OnFilterTitleClick", self.isOpen)
end

function MedalListFilterBoardItemView:OnFilterBoxItemClick(id, filterType)
    if filterType ~= self.filterType then return end

    if self.currChooseID == id then -- click itself, cancel filter
        self.currChooseID = 1
    else
        self.currChooseID = id
    end

    local name = lang.trans(self.filterDatas[tonumber(self.currChooseID)].name)
    self.txt.text = name

    self.box:ChooseItem(self.currChooseID)
    EventSystem.SendEvent("MedalListFilter_OnFilterItemChoosed", self.currChooseID, filterType)
end

function MedalListFilterBoardItemView:SetBoxState(isOpen)
    if self.isOpen == isOpen then return end

    self.isOpen = isOpen
    GameObjectHelper.FastSetActive(self.opened.gameObject, isOpen)
    GameObjectHelper.FastSetActive(self.box.gameObject, isOpen)
end

return MedalListFilterBoardItemView
