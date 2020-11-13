local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local FancyRecycleItemView = class(unity.base)

function FancyRecycleItemView:ctor()
--------Start_Auto_Generate--------
    self.cardTrans = self.___ex.cardTrans
    self.detailBtn = self.___ex.detailBtn
--------End_Auto_Generate----------
    self.fancyCardsMapModel = FancyCardsMapModel.new()
end

function FancyRecycleItemView:start()
    self.detailBtn:regOnButtonClick(function()
        self:OnDetailClick()
    end)
end

function FancyRecycleItemView:InitView(cardData, fancyCardResourceCache)
    self.fancyCardModel = FancyCardModel.new()
    self.fancyCardModel:InitData(cardData.fid, self.fancyCardsMapModel)
    if not self.cardSpt then
        res.ClearChildren(self.cardTrans)
        local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
        itemObj.transform:SetParent(self.cardTrans, false)
        self.cardSpt = itemSpt
    end
    local _param =
    {
        isShowName = true,
        nameSize = 18/0.8,
    }
    self.cardSpt:SetResourceCache(fancyCardResourceCache)
    self.cardSpt:InitView(self.fancyCardModel, _param)
end

function FancyRecycleItemView:OnDetailClick()
    res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyPreviewCtrl", 3, self.fancyCardModel)
end

return FancyRecycleItemView
