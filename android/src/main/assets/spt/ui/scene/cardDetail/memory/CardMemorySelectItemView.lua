local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardMemorySelectItemView = class(unity.base, "CardMemorySelectItemView")

function CardMemorySelectItemView:ctor()
    self.cardParent = self.___ex.cardParent
    self.txtName = self.___ex.txtName
    self.btnClick = self.___ex.btnClick
    self.imgSelected = self.___ex.imgSelected
end

function CardMemorySelectItemView:start()
end

function CardMemorySelectItemView:InitView(cardModel, cardMemorySelectModel)
    self.cardMemorySelectModel = cardMemorySelectModel
    self.cardModel = cardModel

    local selectedPcid = self.cardMemorySelectModel:GetSelectedPcid()
    -- 实例化卡牌
    if not self.cardView then
        res.ClearChildren(self.cardParent.transform)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        self.cardView = spt
        self.cardView:IsShowName(false)
        obj.transform:SetParent(self.cardParent.transform, false)
    end
    self.cardView:InitView(cardModel)
    self.txtName.text = tostring(cardModel:GetName())
    -- 是否被选中
    GameObjectHelper.FastSetActive(self.imgSelected.gameObject, selectedPcid and selectedPcid == self.cardModel:GetPcid() or false)
end

return CardMemorySelectItemView
