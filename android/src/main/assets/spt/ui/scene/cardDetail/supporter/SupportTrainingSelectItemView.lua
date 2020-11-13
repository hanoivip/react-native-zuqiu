local GameObjectHelper = require("ui.common.GameObjectHelper")
local SupportTrainingSelectItemView = class(unity.base, "SupportTrainingSelectItemView")

function SupportTrainingSelectItemView:ctor()
--------Start_Auto_Generate--------
    self.cardParentTrans = self.___ex.cardParentTrans
    self.nameTxt = self.___ex.nameTxt
    self.selectBtn = self.___ex.selectBtn
    self.selectGo = self.___ex.selectGo
--------End_Auto_Generate----------
end

function SupportTrainingSelectItemView:start()
    self.selectBtn:regOnButtonClick(function()
        self:OnSelectBtnClick()
    end)
end

function SupportTrainingSelectItemView:InitView(cardModel, callBack)
    self.cardModel = cardModel
    self.callBack = callBack
    self.index = cardModel.index
    res.ClearChildren(self.cardParentTrans)
    local cardObject, cardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    cardObject.transform:SetParent(self.cardParentTrans, false)
    cardView:InitView(cardModel)
    cardView:IsShowName(false)
    self.nameTxt.text = tostring(cardModel:GetName())
end

function SupportTrainingSelectItemView:OnSelectBtnClick()
    self.callBack(self.index)
end

function SupportTrainingSelectItemView:SetChooseState(state)
    GameObjectHelper.FastSetActive(self.selectGo, state)
end

return SupportTrainingSelectItemView
