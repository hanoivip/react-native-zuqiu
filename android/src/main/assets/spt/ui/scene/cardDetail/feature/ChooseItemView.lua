local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ChooseItemView = class(unity.base)

function ChooseItemView:ctor()
    self.selectBorder = self.___ex.selectBorder
	self.itemArea = self.___ex.itemArea
    self.btnItem = self.___ex.btnItem

    self.btnItem:regOnButtonClick(function() self:OnClickItem() end)
end

function ChooseItemView:OnClickItem()
    if self.clickItem then
        self.clickItem(self.itemModel, self.index)
    end
end

function ChooseItemView:InitView(coachItemMapModel, itemModel, index, selectItemIndex, objectRes)
    self.itemModel = itemModel
    self.index = index
    local isSelect = tobool(index == selectItemIndex)
    self:IsSelect(isSelect)
	if not self.objectLuaSpt then 
		self:InstantiateObject(objectRes)
	end
	self.objectLuaSpt:InitView(itemModel, true, true)
end

function ChooseItemView:InstantiateObject(objectRes)
	local obj = Object.Instantiate(objectRes)
	obj.transform:SetParent(self.itemArea, false)
	local spt = res.GetLuaScript(obj)
	self.objectLuaSpt = spt
end

function ChooseItemView:IsSelect(isSelect)
    if self.selectBorder then 
        GameObjectHelper.FastSetActive(self.selectBorder.gameObject, isSelect)
    end
end

function ChooseItemView:ClearName()
    self.name.text = ""
end

function ChooseItemView:UpdateItemIndex(index)
    self.index = index
end

return ChooseItemView
