local GameObjectHelper = require("ui.common.GameObjectHelper")
local TimeLimitExploreShowBoxView = class(unity.base)

function TimeLimitExploreShowBoxView:ctor()
    self.cardParent = self.___ex.cardParent
    self.btnClickDetail = self.___ex.btnClickDetail
end

--- 活动页展示信息
function TimeLimitExploreShowBoxView:InitView(type, model)
    self.model = model
    -- 球员
    if type == 1 then
        self:BuildCardView(self.model)
        self.btnClickDetail:regOnButtonClick(function()
            if self.clickCard then
                self.clickCard(self.model:GetCid())
            end
        end)
    end
end

function TimeLimitExploreShowBoxView:BuildCardView(cardModel)
    local cardObject = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
    cardObject.transform:SetParent(self.cardParent.transform, false)
    self.cardView:InitView(cardModel)
    self.cardView:IsShowName(false)
end

return TimeLimitExploreShowBoxView
