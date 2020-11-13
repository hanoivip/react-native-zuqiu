local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local FancyCardAvatarItemView = class(unity.base)

function FancyCardAvatarItemView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
end

function FancyCardAvatarItemView:InitView(cardData, fancyCardResourceCache)
    local _param =
        {
            isShowName = true,
            nameSize = 18/0.75,
        }
    if not self.itemObj then
        if self.contentTrans.childCount > 0 then
            self.itemObj = self.contentTrans.GetChild(0).gameObject
            self.itemSpt = self.itemObj:GetComponent("CapsUnityLuaBehav")
        else
            self.itemObj, self.itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
            self.itemObj.transform:SetParent(self.contentTrans, false)
        end
    end
    
    self.itemSpt:SetResourceCache(fancyCardResourceCache)
    self.itemSpt:InitView(cardData, _param)
    self.itemSpt.OnBtnClick = function ()
        local cardsMap = FancyCardsMapModel.new()
        local fancyCardModel = FancyCardModel.new()
        fancyCardModel:InitData(cardData:GetID(), cardsMap)
        res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyPreviewCtrl", 1, fancyCardModel)
    end
end

return FancyCardAvatarItemView
