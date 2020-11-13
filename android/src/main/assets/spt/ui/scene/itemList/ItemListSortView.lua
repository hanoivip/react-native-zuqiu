local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")

local ItemListSortView = class(unity.base)

function ItemListSortView:ctor()
    self.btnQualitySort = self.___ex.btnQualitySort
    self.btnKindSort = self.___ex.btnKindSort
    self.qualityAscendIcon = self.___ex.qualityAscendIcon
    self.qualityDscendIcon = self.___ex.qualityDscendIcon
    self.kindAscendIcon = self.___ex.kindAscendIcon
    self.kindDscendIcon = self.___ex.kindDscendIcon

    self.sortIndex = nil
    self.sortTarget = nil
end

function ItemListSortView:start()
    self.btnQualitySort:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.qualityIndex then  
            sortIndex = (self.qualityIndex == ItemListConstants.SortType.QUALITY_ASCEND) and ItemListConstants.SortType.QUALITY_DSCEND or ItemListConstants.SortType.QUALITY_ASCEND
        else    
            sortIndex = self.qualityIndex
        end
        self:OnSortClick(sortIndex)
    end)
    self.btnKindSort:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.kindIndex then 
            sortIndex = (self.kindIndex == ItemListConstants.SortType.KIND_ASCEND) and ItemListConstants.SortType.KIND_DSCEND or ItemListConstants.SortType.KIND_ASCEND
        else
            sortIndex = self.kindIndex
        end
        self:OnSortClick(sortIndex)
    end)
end

function ItemListSortView:SetButtonState(buttonScript, isSelect)
    local select = buttonScript.select
    for k, v in pairs(select) do
        GameObjectHelper.FastSetActive(v, isSelect)
    end
end

function ItemListSortView:OnSelectSortItem(index)
    self.sortIndex = index
    if self.sortTarget then
        self:SetButtonState(self.sortTarget, false)
    end

    if index == ItemListConstants.SortType.QUALITY_DSCEND then
        self.sortTarget = self.btnQualitySort
        self:SetQualitySortIcon(true)
    elseif index == ItemListConstants.SortType.QUALITY_ASCEND then
        self.sortTarget = self.btnQualitySort
        self:SetQualitySortIcon(false)
    elseif index == ItemListConstants.SortType.KIND_DSCEND then
        self.sortTarget = self.btnKindSort
        self:SetKindSortIcon(true)
    elseif index == ItemListConstants.SortType.KIND_ASCEND then
        self.sortTarget = self.btnKindSort
        self:SetKindSortIcon(false)
    end
    if self.sortTarget then
        self:SetButtonState(self.sortTarget, true)
    end
end

function ItemListSortView:SetQualitySortIcon(isDscend)
    GameObjectHelper.FastSetActive(self.qualityDscendIcon, isDscend)
    GameObjectHelper.FastSetActive(self.qualityAscendIcon, not isDscend)
    GameObjectHelper.FastSetActive(self.kindDscendIcon, false)
    GameObjectHelper.FastSetActive(self.kindAscendIcon, false)
    self.qualityIndex = isDscend and ItemListConstants.SortType.QUALITY_DSCEND or ItemListConstants.SortType.QUALITY_ASCEND
end

function ItemListSortView:SetKindSortIcon(isDscend)
    GameObjectHelper.FastSetActive(self.kindDscendIcon, isDscend)
    GameObjectHelper.FastSetActive(self.kindAscendIcon, not isDscend)
    GameObjectHelper.FastSetActive(self.qualityDscendIcon, false)
    GameObjectHelper.FastSetActive(self.qualityAscendIcon, false)
    GameObjectHelper.FastSetActive(self.btnKindSort.select.img, false)
    self.kindIndex = isDscend and ItemListConstants.SortType.KIND_DSCEND or ItemListConstants.SortType.KIND_ASCEND
end

function ItemListSortView:InitView(index)
    self.sortIndex = nil
    self.sortTarget = nil
    self:SetQualitySortIcon(true)
    self:SetKindSortIcon(true)
    self:OnSelectSortItem(index)
    self:InitButtonState()
end

function ItemListSortView:InitButtonState()
    GameObjectHelper.FastSetActive(self.qualityAscendIcon, false)
    GameObjectHelper.FastSetActive(self.qualityDscendIcon, false)
    GameObjectHelper.FastSetActive(self.kindAscendIcon, false)
    GameObjectHelper.FastSetActive(self.kindDscendIcon, false)
end

function ItemListSortView:OnSortClick(index)
    self:OnSelectSortItem(index)
    if self.clickSort then
        self.clickSort(index)
    end
end

return ItemListSortView
