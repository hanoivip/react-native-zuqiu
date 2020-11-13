local MenuType = require("ui.controllers.itemList.MenuType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ItemListMainView = class(unity.base)

local MenuMap = {
    [MenuType.EQUIP] = "equip",
    [MenuType.EQUIPPIECE] = "equipPiece",
    [MenuType.ITEM] = "item",
    [MenuType.TACTIC] = "coach",
}

function ItemListMainView:ctor()
    self.btnFilter = self.___ex.btnFilter
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.scrollView = self.___ex.scrollView
    self.infoBarDynParent = self.___ex.infoBar
    self.itemListSortView = self.___ex.itemListSortView
    self.txtFilter = self.___ex.txtFilter
    self.itemRedPoint = self.___ex.itemRedPoint
    self.pasterBoardArea = self.___ex.pasterBoardArea
    self.itemBoardArea = self.___ex.itemBoardArea
    self.pasterView = self.___ex.pasterView
    -- 教练阵型/战术升级道具
    self.sptCoachView  = self.___ex.sptCoachView
    -- 教练道具界面背景
    self.imgCoachViewBg  = self.___ex.imgCoachViewBg
end

function ItemListMainView:start()
    local menuTransform = self.menuButtonGroup.transform
    for menuType, tag in pairs(MenuMap) do
        self.menuButtonGroup:BindMenuItem(tag, function()
            self:OnMenuClick(menuType)
        end)
        if luaevt.trig("__BR__VERSION__") and tag == "coach" then
            GameObjectHelper.FastSetActive(self.menuButtonGroup.menu.coach.gameObject, false)
        end
    end

    self.btnFilter:regOnButtonClick(function()
        self:OnBtnFilterClick()
    end)

    self:UpdateItemRedPoint()
    EventSystem.AddEvent("ReqEventModel_item", self, self.UpdateItemRedPoint)
end

function ItemListMainView:onDestroy()
    EventSystem.RemoveEvent("ReqEventModel_item", self, self.UpdateItemRedPoint)
end

function ItemListMainView:UpdateItemRedPoint()
    GameObjectHelper.FastSetActive(self.itemRedPoint, tonumber(ReqEventModel.GetInfo("item")) > 0)
end

function ItemListMainView:InitView(menuType)
    self.menuButtonGroup:selectMenuItem(MenuMap[menuType])
    self:OnMenuClick(menuType)
    GameObjectHelper.FastSetActive(self.imgCoachViewBg, menuType == MenuType.TACTIC)
end

function ItemListMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function ItemListMainView:OnMenuClick(menuType)
    self:SwitchContentArea(menuType)
    if self.clickMenu then
        self.clickMenu(menuType)
    end
end

function ItemListMainView:SwitchContentArea(menuType)
    GameObjectHelper.FastSetActive(self.itemBoardArea, menuType ~= MenuType.PASTER and menuType ~= MenuType.TACTIC)
    GameObjectHelper.FastSetActive(self.sptCoachView.gameObject, menuType == MenuType.TACTIC)
    GameObjectHelper.FastSetActive(self.pasterBoardArea, menuType == MenuType.PASTER)
end

function ItemListMainView:OnBtnFilterClick()
    if self.clickFilter then
        self.clickFilter()
    end
end

function ItemListMainView:ShowOrHideFilterButton(currentMenu)
    GameObjectHelper.FastSetActive(self.btnFilter.gameObject, currentMenu == MenuType.EQUIP or currentMenu == MenuType.EQUIPPIECE)
end

function ItemListMainView:SwitchFilterButtonState(isHasFilter)
    if isHasFilter then
        self.txtFilter.text = lang.trans("pos_be_selected_title")
    else
        self.txtFilter.text = lang.trans("itemList_kindFilter")
    end
end

-- 教练道具界面
function ItemListMainView:RefreshCoachView(coachItemListModel, coachItemType)
    self.sptCoachView:InitView(coachItemListModel, coachItemType)
end

return ItemListMainView