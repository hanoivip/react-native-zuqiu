local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local FeatureAdditionScrollView = class(LuaScrollRectExSameSize)

function FeatureAdditionScrollView:ctor()
    FeatureAdditionScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.featureItemMap = {}
end

function FeatureAdditionScrollView:GetItemRes()
    if not self.itemRes then
        self.itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/FeatureAddition.prefab")
    end
    return self.itemRes
end

function FeatureAdditionScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetItemRes())
    local spt = res.GetLuaScript(obj)
    self:resetItem(spt, index)
    return obj
end

function FeatureAdditionScrollView:resetItem(spt, index)
    local featureAdditionModel = self.itemDatas[index]
    spt:InitView(self.cardModel, self.featureAdditionDetailModel, featureAdditionModel)
end

function FeatureAdditionScrollView:InitView(cardModel, featureAdditionDetailModel, featureAdditionModelMap)
	self.cardModel = cardModel
	self.featureAdditionDetailModel = featureAdditionDetailModel
    self:refresh(featureAdditionModelMap)
end

function FeatureAdditionScrollView:OnDestroy()
    self.itemRes = nil
end

return FeatureAdditionScrollView
