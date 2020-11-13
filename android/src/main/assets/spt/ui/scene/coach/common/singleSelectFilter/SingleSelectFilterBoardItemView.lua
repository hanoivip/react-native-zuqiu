local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require ("EventSystem")

local SingleSelectFilterBoardItemView = class(unity.base, "SingleSelectFilterBoardItemView")

function SingleSelectFilterBoardItemView:ctor()
    -- 显示文字
    self.txt = self.___ex.txt
    self.txtShadow = self.___ex.txtShadow
    -- 箭头
    self.rctArrow = self.___ex.rctArrow
    -- 盒子脚本
    self.box = self.___ex.box
    -- 点击mask
    self.click = self.___ex.click
    -- item样式相关
    self.imgNormal = self.___ex.imgNormal
    self.imgOpened = self.___ex.imgOpened
    self.imgIcon = self.___ex.imgIcon
    self.imgArrowNor = self.___ex.imgArrowNor
    self.imgArrowSel = self.___ex.imgArrowSel
    self.imgBox = self.___ex.imgBox

    self.styleConfig = nil -- 样式配置
    self.txtColorNor = nil
    self.txtColorSel = nil
    self.parentModel = nil
    self.filterDatas = nil
    self.filterType = nil
    self.currChooseID = 1 -- 默认选择id第一个，通常是title
    self.isOpen = false
end

function SingleSelectFilterBoardItemView:start()
    self.click:regOnButtonClick(function()
        self:OnBoardItemClick()
    end)
end

-- @parameter parentModel: get from parent
-- @parameter filterDatas: defined in file: SingleSelectFilterModel
-- @parameter filterType: defined in file: SingleSelectFilterModel
function SingleSelectFilterBoardItemView:InitView(parentModel, filterDatas, filterType)
    self.parentModel = parentModel
    self.filterDatas = filterDatas
    self.filterType = filterType
    self.currChooseID = 1

    self:SetName()
    self.box:SetHasTitle(self.hasTitle)
    self.box:InitView(filterDatas, filterType)
    self.box.onFilterBoxItemClick = function(id, filterType) self:OnFilterBoxItemClick(id, filterType) end

    self:SetBoxState(false)
end

function SingleSelectFilterBoardItemView:SetHasTitle(hasTitle)
    self.hasTitle = hasTitle
end

-- 继承以设置筛选面板每个item的样式
function SingleSelectFilterBoardItemView:SetStyle(styleConfig)
    if not styleConfig then return end
    self.styleConfig = styleConfig

    if styleConfig.normal ~= nil then
        self.imgNormal.overrideSprite = res.LoadRes(styleConfig.normal)
    end

    if styleConfig.opened ~= nil then
        self.imgOpened.overrideSprite = res.LoadRes(styleConfig.opened)
    end

    if styleConfig.icon ~= nil then
        self.imgIcon.overrideSprite = res.LoadRes(styleConfig.icon)
    end

    if styleConfig.arrow_nor ~= nil then
        self.imgArrowNor.overrideSprite = res.LoadRes(styleConfig.arrow_nor)
    end

    if styleConfig.arrow_sel ~= nil then
        self.imgArrowSel.overrideSprite = res.LoadRes(styleConfig.arrow_sel)
    end

    if styleConfig.box ~= nil then
        self.imgBox.overrideSprite = res.LoadRes(styleConfig.box)
    end

    if styleConfig.txt_nor ~= nil then
        self.txtColorNor = Color(styleConfig.txt_nor.r, styleConfig.txt_nor.g, styleConfig.txt_nor.b, styleConfig.txt_nor.a)
        self.txt.color = self.txtColorNor
    end

    if styleConfig.txt_sel ~= nil then
        self.txtColorSel = Color(styleConfig.txt_sel.r, styleConfig.txt_sel.g, styleConfig.txt_sel.b, styleConfig.txt_sel.a)
    end
end

-- 继承函数以设置筛选项名称的显示
function SingleSelectFilterBoardItemView:SetName()
    if table.nums(self.filterDatas) > 0 then
        local name = lang.trans(self.filterDatas[tonumber(self.currChooseID)].name)
        self.txt.text = name
        self.txtShadow.text = name
    end
end

-- 点击打开或关闭筛选盒子回调函数
function SingleSelectFilterBoardItemView:OnBoardItemClick()
    if self.onBoardItemClick and type(self.onBoardItemClick) == "function" then
        self.onBoardItemClick(self.filterType, not self.isOpen)
    end
end

-- 点击筛选盒子中某项
function SingleSelectFilterBoardItemView:OnFilterBoxItemClick(id, filterType)
    if filterType == self.filterType then
        self:SelectFilterItem(id)
    end

    if self.onFilterBoxItemClick and type(self.onFilterBoxItemClick) == "function" then
        self.onFilterBoxItemClick(self.currChooseID, filterType)
    end
end

-- 设置盒子显示状态及其他样式显示
function SingleSelectFilterBoardItemView:SetBoxState(isOpen)
    if self.isOpen == isOpen then return end

    self.isOpen = isOpen
    GameObjectHelper.FastSetActive(self.box.gameObject, isOpen)
    -- 样式显示
    if self.styleConfig then
        GameObjectHelper.FastSetActive(self.imgNormal.gameObject, not isOpen)
        GameObjectHelper.FastSetActive(self.imgOpened.gameObject, isOpen)
        GameObjectHelper.FastSetActive(self.imgArrowNor.gameObject, not isOpen)
        GameObjectHelper.FastSetActive(self.imgArrowSel.gameObject, isOpen)
        if isOpen then
            if self.txtColorSel then
                self.txt.color = self.txtColorSel
            end
        else
            if self.txtColorNor then
                self.txt.color = self.txtColorNor
            end
        end
    end
end

function SingleSelectFilterBoardItemView:SelectFilterItem(id)
    self.box:ChooseItem(id)
    if self.currChooseID == id and self.hasTitle then -- click itself, cancel filter
        self.currChooseID = 1 -- 默认选择第一个title
    else
        self.currChooseID = id
    end
    self:SetName()
    self:SetBoxState(false)
end

return SingleSelectFilterBoardItemView
