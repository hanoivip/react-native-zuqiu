local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local ScrollRect = UI.ScrollRect
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachItemListModel = require("ui.models.itemList.CoachItemListModel")
local ScrollViewSameSize = require("ui.control.scroll.ScrollViewSameSize")

local CoachItemListScrollView = class(ScrollViewSameSize, "CoachItemListScrollView")

function CoachItemListScrollView:ctor()
    CoachItemListScrollView.super.ctor(self)
    self.itemResList = {}
end

function CoachItemListScrollView:start()
end

function CoachItemListScrollView:GetItemRes(index)
    local coachItemModel = self.data[index]
    local itemId = coachItemModel:GetId()
    local coachItemType = self.coachItemType or tostring(self.coachItemListModel:GetItemType(itemId))
    local objPath = self.coachItemListModel:GetItemBoxPrefabPathByType(coachItemType)
    if not self.itemResList[coachItemType] then
        self.itemResList[coachItemType] = res.LoadRes(objPath)
    end
    return self.itemResList[coachItemType]
end

function CoachItemListScrollView:createItem(index)
    local itemRes = self:GetItemRes(index)
    local obj
    if index == 1 and itemRes.transform.parent then
        -- use the template if it's already in the view hierarchy
        obj = itemRes
    else
        obj = Object.Instantiate(itemRes)
    end

    local spt = res.GetLuaScript(obj)

    GameObjectHelper.FastSetActive(obj, true)

    if spt then
        self:resetItem(spt, index)
    end
    return obj
end

function CoachItemListScrollView:resetItem(spt, index)
    local data = self.data[index]
    for name, func in pairs(self.onItemButtonClicks) do
        if spt[name] then
            spt[name]:regOnButtonClick(function() func(data) end)
        else
            dump("Button [" .. name .. "] is not exist in scroll item", "ScrollViewSameSize:resetItem")
        end
    end
    spt.onClick = function() self.onClick(data) end  
    spt:InitView(data, unpack(self.args, 1, self.argc))
    if spt.SetNameColor then
        spt:SetNameColor(Color.white, Color.black)
    end
    self:updateItemIndex(spt, index)
end

function CoachItemListScrollView:SetCoachItemListModel(coachItemListModel)
    self.coachItemListModel = coachItemListModel
end

function CoachItemListScrollView:SetCoachItemListType(coachItemType)
    self.coachItemType = coachItemType
end

return CoachItemListScrollView
