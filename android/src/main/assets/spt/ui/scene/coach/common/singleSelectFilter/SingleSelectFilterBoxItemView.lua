local GameObjectHelper = require("ui.common.GameObjectHelper")

local SingleSelectFilterBoxItemView = class(unity.base, "SingleSelectFilterBoxItemView")

function SingleSelectFilterBoxItemView:ctor()
    -- 白色底纹
    self.white = self.___ex.white
    -- 显示文字
    self.txt = self.___ex.txt
    -- 点击mask
    self.click = self.___ex.click
    -- 选中状态
    self.choosed = self.___ex.choosed

    self.isChoosed = false
    self.hasTitle = true
end

function SingleSelectFilterBoxItemView:start()
    self.click:regOnButtonClick(function()
        self:OnFilterBoxItemClick()
    end)
end

function SingleSelectFilterBoxItemView:InitView(filterData, filterType)
    self.filterData = filterData
    self.filterType = filterType
    self:SetWhiteBg()
    self:SetName()
    self:SetChoose(false)
end

function SingleSelectFilterBoxItemView:SetHasTitle(hasTitle)
    self.hasTitle = hasTitle
end

function SingleSelectFilterBoxItemView:SetWhiteBg()
    GameObjectHelper.FastSetActive(self.white, self.filterData.id % 2 == (self.hasTitle and 1 or 0))
end

function SingleSelectFilterBoxItemView:SetName()
    self.txt.text = lang.trans(self.filterData.name)
end

function SingleSelectFilterBoxItemView:SetChoose(isChoosed)
    self.isChoosed = isChoosed
    GameObjectHelper.FastSetActive(self.choosed.gameObject, isChoosed)
end

function SingleSelectFilterBoxItemView:GetID()
    return self.filterData.id
end

-- 点击筛选盒子中某项
function SingleSelectFilterBoxItemView:OnFilterBoxItemClick()
    if self.onFilterBoxItemClick and type(self.onFilterBoxItemClick) == "function" then
        self.onFilterBoxItemClick(self.filterData.id, self.filterType)
    end
end

return SingleSelectFilterBoxItemView
