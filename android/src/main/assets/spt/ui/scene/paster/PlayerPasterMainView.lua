local UnityEngine = clr.UnityEngine
local AssetFinder = require("ui.common.AssetFinder")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerPasterMainView = class(unity.base)

function PlayerPasterMainView:ctor()
    self.scrollView = self.___ex.scrollView
    self.scrollView.clickCardPaster = function(cardPasterModel) self:OnClickCardPaster(cardPasterModel) end
end

function PlayerPasterMainView:start()
end

function PlayerPasterMainView:OnClickCardPaster(cardPasterModel)
    self.cardPasterModel = cardPasterModel
    if self.clickCardPaster then 
        self.clickCardPaster(cardPasterModel)
    end
end

function PlayerPasterMainView:InitView(pasterListModel, cardResourceCache)
    self.pasterListModel = pasterListModel
    self.pasterListSortModel = self.pasterListModel:GetListModel()
    self.scrollView:InitView(self.pasterListSortModel, cardResourceCache)
end

function PlayerPasterMainView:EventRemovePaster(ptid)
    local index
    for i, v in ipairs(self.scrollView.itemDatas) do
        if tostring(v:GetId()) == tostring(ptid) then
            index = i
            break
        end
    end
    self.scrollView:removeItem(index)
end

function PlayerPasterMainView:EnterScene()
    EventSystem.AddEvent("CardPastersMapModel_RemovePasterData", self, self.EventRemovePaster)
end

function PlayerPasterMainView:ExitScene()
    EventSystem.RemoveEvent("CardPastersMapModel_RemovePasterData", self, self.EventRemovePaster)
end

return PlayerPasterMainView
