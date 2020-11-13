local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local CardBuilder = require("ui.common.card.CardBuilder")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CourtScoutExtraPlayerListScrollView = class(LuaScrollRectExSameSize)

function CourtScoutExtraPlayerListScrollView:ctor()
    CourtScoutExtraPlayerListScrollView.super.ctor(self)
end

function CourtScoutExtraPlayerListScrollView:start()
end

function CourtScoutExtraPlayerListScrollView:GetPlayerRes()
    if not self.playerRes then 
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ScoutPlayer.prefab")
    end
    return self.playerRes
end

function CourtScoutExtraPlayerListScrollView:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function CourtScoutExtraPlayerListScrollView:OnBtnCard(cid, sortIndex)
    self.courtBuildModel:SetScoutExtraPlayerScrollPos(self:getScrollNormalizedPos())
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
end

function CourtScoutExtraPlayerListScrollView:createItem(index)
    local obj = Object.Instantiate(self:GetPlayerRes())
    local spt = res.GetLuaScript(obj)
    spt.clickCard = function(cid, sortIndex) self:OnBtnCard(cid, sortIndex) end
    self:resetItem(spt, index)
    return obj
end

function CourtScoutExtraPlayerListScrollView:resetItem(spt, index)
    local model = self.cardModelMap[index]
    local cardRes = self:GetCardRes()
    spt:InitView(model, cardRes, self.cardResourceCache)
    self:updateItemIndex(spt, index)
end

local function sortQualityAsc(aModel, bModel)
    return aModel:GetCardQuality() > bModel:GetCardQuality()
end

function CourtScoutExtraPlayerListScrollView:InitView(data, cardResourceCache, courtBuildModel)
    self.cardResourceCache = cardResourceCache
    self.data = data
    self.cardModelMap = { }
    for i, cid in ipairs(self.data) do
        local playerCardStaticModel = StaticCardModel.new(cid)
        table.insert(self.cardModelMap, playerCardStaticModel)
    end
    table.sort(self.cardModelMap, sortQualityAsc)
    self.courtBuildModel = courtBuildModel
    local scrollPos = self.courtBuildModel:GetScoutExtraPlayerScrollPos()
    self:refresh(self.cardModelMap, scrollPos)
end

return CourtScoutExtraPlayerListScrollView
