local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CardSymbolModel = require("ui.models.cardDetail.CardSymbolModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local GachaDetailScrollView = class(LuaScrollRectExSameSize)

function GachaDetailScrollView:ctor()
    GachaDetailScrollView.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
    self.cardSymbolModel = CardSymbolModel.new()
    self.cardSymbolModel:InitAboutOtherFlag(true, true, true, true)
end

---[[ 为了C#回调而写的方法
function GachaDetailScrollView:createItem(index)
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/Card.prefab")
    self:resetItem(spt, index)
    return obj
end

function GachaDetailScrollView:resetItem(spt, index)
    local cid = self.itemDatas[index].cid
    local cardModel = StaticCardModel.new(cid)
    local baseId = cardModel:GetBaseID()
    self.itemDatas[index].flagData = self.cardSymbolModel:GetShowSymbolData(cid, baseId, self.letterList)
    spt:Init(self.itemDatas[index], self.customTagModel)
end

function GachaDetailScrollView:SetTagModel(letterList, customTagModel)
    self.letterList = letterList
    self.customTagModel = customTagModel
end

function GachaDetailScrollView:GetScrollNormalizedPosition()
    return self:getScrollNormalizedPos()
end

return GachaDetailScrollView

