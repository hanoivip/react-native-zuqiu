local EventSystem = require("EventSystem")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local OldPlayerTabView = class(unity.base)

function OldPlayerTabView:ctor()
    self.selectImage = self.___ex.selectImage
    self.text = self.___ex.text
    self.text1 = self.___ex.text1
    self.btnClick = self.___ex.btnClick
    self.redPoint = self.___ex.redPoint
end

function OldPlayerTabView:start()
    self.btnClick:regOnButtonClick(function()
        self:OnBtnClick()
    end)
    EventSystem.AddEvent("ReduceRedPointCount", self, self.RefreshRedPoint)
end

function OldPlayerTabView:InitView(tagData, isSelect)
    self.tagData = tagData
    self:SetRedPointState(tagData.redPointCount > 0)
    local name = tagData.tabName
    self.text.text = lang.trans(name)
    self.text1.text = lang.trans(name)
    self:ChangeState(isSelect)
end

function OldPlayerTabView:ChangeState(isSelect)
    GameObjectHelper.FastSetActive(self.selectImage, isSelect)
end

function OldPlayerTabView:OnBtnClick()
    if self.clickTab then 
        self.clickTab()
    end
end

function OldPlayerTabView:RefreshRedPoint(menuMap)
    local flag =  menuMap[self.tagData.tabNum] and menuMap[self.tagData.tabNum].redPointCount > 0 
    self:SetRedPointState(flag)
end

function OldPlayerTabView:SetRedPointState(flag)
    local itemLookMap = cache.getIsFirstLookOldPlayerItem()
    flag = flag and (not (itemLookMap and itemLookMap[self.tagData.tabNum]))
    self.redPoint:SetActive(flag)
end

function OldPlayerTabView:OnExitScene()
    EventSystem.RemoveEvent("ReduceRedPointCount", self, self.RefreshRedPoint)
end

return OldPlayerTabView