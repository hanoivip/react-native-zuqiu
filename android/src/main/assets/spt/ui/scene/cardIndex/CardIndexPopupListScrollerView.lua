local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CardIndexConstants = require("ui.scene.cardIndex.CardIndexConstants")

local CardIndexPopupListScrollerView = class(LuaScrollRectExSameSize)

function CardIndexPopupListScrollerView:ctor()
    -- 视图模型
    self.cardIndexViewModel = nil
    -- 列表类型
    self.listType = nil
    self.super.ctor(self)
end

function CardIndexPopupListScrollerView:InitView(cardIndexViewModel, listType)
    self.cardIndexViewModel = cardIndexViewModel
    self.listType = listType
    local cardIndexModel = self.cardIndexViewModel:GetModel()
    if listType == CardIndexConstants.ListType.POSITION then
        self.itemDatas = cardIndexModel:GetPosList()
    elseif listType == CardIndexConstants.ListType.NATIONALITY then
        self.itemDatas = cardIndexModel:GetNationalityList()
    end
end

function CardIndexPopupListScrollerView:start()
    self:refresh()
end

function CardIndexPopupListScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/CardIndex/TextItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    spt:InitView(self.itemDatas[index], self.listType)
    return obj
end

function CardIndexPopupListScrollerView:resetItem(spt, index)
    spt:InitView(self.itemDatas[index], self.listType)
    spt:BuildPage()
end

return CardIndexPopupListScrollerView