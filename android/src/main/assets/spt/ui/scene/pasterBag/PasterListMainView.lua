local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local PasterMenuType = require("ui.scene.pasterBag.PasterMenuType")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local PasterListMainView = class(unity.base)

function PasterListMainView:ctor()
    self.playerScrollView = self.___ex.playerScrollView
    self.competeScrollView = self.___ex.competeScrollView
    self.playerScrollView.clickCardPaster = function(cardPasterModel) self:OnClickCardPaster(cardPasterModel) end
    self.competeScrollView.clickCardPaster = function(cardPasterModel) self:OnClickCardPaster(cardPasterModel) end
    self.cardPastersMapModel = CardPastersMapModel.new()
end

function PasterListMainView:OnClickCardPaster(cardPasterModel)
    self.cardPasterModel = cardPasterModel
    if self.clickCardPaster then 
        self.clickCardPaster(cardPasterModel)
    end
end

function PasterListMainView:InitView(playerPasterListModel, competePasterListModel, cardResourceCache)
    self.playerPasterListModel = playerPasterListModel
    self.competePasterListModel = competePasterListModel
    self.playerpasterListSortModel = self.playerPasterListModel:GetListModel()
    self.competePasterListSortModel = self.competePasterListModel:GetListModel()
    self.playerScrollView:InitView(self.playerpasterListSortModel, cardResourceCache)
    self.competeScrollView:InitView(self.competePasterListSortModel, cardResourceCache)
end

function PasterListMainView:EventRemovePaster(ptid)
    for i, v in ipairs(self.playerScrollView.itemDatas) do
        if tostring(v:GetId()) == tostring(ptid) then
            self.playerScrollView:removeItem(i)
            break
        end
    end

    for i, v in ipairs(self.competeScrollView.itemDatas) do
        if tostring(v:GetId()) == tostring(ptid) then
            self.competeScrollView:removeItem(i)
            break
        end
    end
end

function PasterListMainView:EventAddPaster(ptid)
    local pasterModel = CardPasterModel.new(ptid, PasterStateType.CanUse)
    local cache = self.cardPastersMapModel:GetPasterData(ptid)
    pasterModel:InitWithCache(cache)
    local isCompetePaster = pasterModel:IsCompetePaster()
    if isCompetePaster then
        self.competeScrollView:addItem(pasterModel, 1)
    else
        self.playerScrollView:addItem(pasterModel, 1)
    end
end

function PasterListMainView:ClickMenu(tag)
    GameObjectHelper.FastSetActive(self.playerScrollView.gameObject, tag == PasterMenuType.PLAYER)
    GameObjectHelper.FastSetActive(self.competeScrollView.gameObject, tag == PasterMenuType.COMPETE)
end

function PasterListMainView:EnterScene()
    EventSystem.AddEvent("CardPastersMapModel_RemovePasterData", self, self.EventRemovePaster)
    EventSystem.AddEvent("CardPastersMapModel_AddPasterData", self, self.EventAddPaster)
end

function PasterListMainView:ExitScene()
    EventSystem.RemoveEvent("CardPastersMapModel_RemovePasterData", self, self.EventRemovePaster)
    EventSystem.RemoveEvent("CardPastersMapModel_AddPasterData", self, self.EventAddPaster)
end

return PasterListMainView
