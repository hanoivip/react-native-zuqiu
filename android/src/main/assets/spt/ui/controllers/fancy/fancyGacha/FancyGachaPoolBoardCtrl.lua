local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FancyGachaPoolBoardCtrl = class(BaseCtrl)

FancyGachaPoolBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyGacha/FancyGachaPoolBoard.prefab"

function FancyGachaPoolBoardCtrl:AheadRequest(groupId)
    local response = req.fancyCardGachaPool(groupId)
    if api.success(response) then
        local data = response.val
        self.cardModelList = self:InitCardData(data)
    end
end

function FancyGachaPoolBoardCtrl:Refresh(groupId, fancyCardResourceCache)
    FancyGachaPoolBoardCtrl.super.Refresh(self)
    self.view:InitView(self.cardModelList, fancyCardResourceCache)
end

function FancyGachaPoolBoardCtrl:InitCardData(cardList)
    local cardModelList = {}
    for i, v in pairs(cardList) do
        local fancyCardModel = FancyCardModel.new()
        fancyCardModel:InitData(v)
        table.insert(cardModelList, fancyCardModel)
    end
    table.sort(cardModelList, function (a, b)
        local quality_a = a:GetQuality()
        local quality_b = b:GetQuality()
        local result_Group = a.staticData.groupID > b.staticData.groupID
        local result = false
        if quality_a > quality_b then 
            result = true 
        elseif quality_a == quality_b and result_Group then 
            result = true 
        end
        return result
    end)
    return cardModelList
end

return FancyGachaPoolBoardCtrl