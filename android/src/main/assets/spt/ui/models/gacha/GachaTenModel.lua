local Model = require("ui.models.Model")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")

local GachaTenModel = class(Model, "GachaTenModel")

function GachaTenModel:ctor()
    GachaTenModel.super.ctor(self)
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.selectdCardList = {}
    self.cardModelMap = {}
    self.isAllSelect = false 
end

function GachaTenModel:GetCardModel(pcid)
    return self.cardModelMap[tostring(pcid)]
end

function GachaTenModel:ClearSelectedCardList()
    self.selectdCardList = {}
end

function GachaTenModel:IsCardSelected(pcid)
    for k, v in pairs(self.selectdCardList) do
        if tostring(pcid) == tostring(k) and v == true then
            return true
        end
    end
end

function GachaTenModel:GetSelectedCardList()
    local list = {}
    for pcid, v in pairs(self.selectdCardList) do
        if v == true then
            table.insert(list, pcid)
        end
    end
    return list
end

function GachaTenModel:ToggleSelectCard(pcid)
    self.selectdCardList[tostring(pcid)] = not tobool(self.selectdCardList[tostring(pcid)])
end

function GachaTenModel:SetAllSelect()
    self.isAllSelect = not self.isAllSelect
    return self.isAllSelect
end

function GachaTenModel:AddAllToSelectedList()
    for k, v in pairs(self.cardModelMap) do
        if not self:IsCardSelected(k) then
            self:ToggleSelectCard(k)
        end	
    end
end

function GachaTenModel:AddCard(cid,pcid)
    local cardModel = StaticCardModel.new(cid)
    self.cardModelMap[tostring(pcid)] = cardModel
end

function GachaTenModel:GetSelectedCardValue()
    local value = 0
    local selectedList = self:GetSelectedCardList()
    for i, pcid in ipairs(selectedList) do
        value = value + self:GetCardModel(pcid):GetValue()
    end
    return value
end

function GachaTenModel:RemoveCardModel(removePcid)
    self.cardModelMap[tostring(removePcid)] = nil
end

function GachaTenModel:RemoveCards(pcids)
    assert(pcids)
    self.playerCardsMapModel:RemoveCardData(pcids)
    
    for i, pcid in ipairs(pcids) do
        self:RemoveCardModel(pcid)
    end
end

return GachaTenModel