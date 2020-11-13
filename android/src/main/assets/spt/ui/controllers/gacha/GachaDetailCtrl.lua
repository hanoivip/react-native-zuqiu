local WaitForSeconds = clr.UnityEngine.WaitForSeconds
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CommonConstants = require("ui.common.CommonConstants")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CustomTagModel = require("ui.models.cardDetail.CustomTagModel")

local GachaDetailCtrl = class(BaseCtrl, "GachaDetailCtrl")

GachaDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Store/GachaDetail.prefab"

GachaDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GachaDetailCtrl:Refresh(gachaModel, scrollNormalizedPosition, letterList)
    assert(gachaModel)
    self.gachaModel = gachaModel
    self.letterList = letterList
    self.curKey = nil

    self.view.OnClick = function()
        self:OnClick()
    end

    if self.gachaModel:GetLabelTag() ~= CommonConstants.GachaFriendID then
        clr.coroutine(function ()
            if self.wait then
                coroutine.yield(WaitForSeconds(0.5))
            end
            local data = req.gachaDetail(self.gachaModel:GetLabelTag())
            if api.success(data) then
                self.letterList = data.val.letterList
                self:InitScrollData(self:InitGachaData(data.val.cards), scrollNormalizedPosition, self.letterList)
            end
        end)
    else
        self:InitScrollData(self.gachaModel:GetGachaDetail(), scrollNormalizedPosition, self.letterList)
    end
    self.view:InitView(gachaModel)
end

function GachaDetailCtrl:InitGachaData(data)
    local cards = {}
    for k, v in pairs(data) do
        local cardModel = StaticCardModel.new(v)
        local card = 
        {
            cid = v,
            quality = cardModel:GetCardFixQualityNum()
        }
        table.insert(cards, card)
    end
    table.sort(cards, function (a, b)
        return a.quality > b.quality
    end)
    return cards
end

function GachaDetailCtrl:GetStatusData()
    self.wait = true
    return self.gachaModel, self.view.scrollView:GetScrollNormalizedPosition(), self.letterList
end

function GachaDetailCtrl:InitScrollData(gachaCardData, scrollNormalizedPosition, letterList)
    local customTagModel = CustomTagModel.new()
    self.view.scrollView:SetTagModel(letterList, customTagModel)
    self.view.scrollView:refresh(gachaCardData, scrollNormalizedPosition)
end

function GachaDetailCtrl:OnClick()
    self.view.scrollView:refresh()
end

return GachaDetailCtrl

