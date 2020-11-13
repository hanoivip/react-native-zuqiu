local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyPreView = class(unity.base)

function FancyPreView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.cardParent = self.___ex.cardParent
    self.cardGroup = self.___ex.cardGroup
    self.cardBigGroup = self.___ex.cardBigGroup
    self.active = self.___ex.active
    self.cardName = self.___ex.cardName
    self.countLabel = self.___ex.countLabel
    self.count = self.___ex.count
    self.canvasGroup = self.___ex.canvasGroup
    self.teamDetailBtn = self.___ex.teamDetailBtn
    self.countGo = self.___ex.countGo
end

function FancyPreView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.teamDetailBtn:regOnButtonClick(function()
        self:OnTeamDetailClick()
    end)
    self:PlayInAnimator()
end

function FancyPreView:InitView(_type, card)
    self.card = card
    local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
    itemObj.transform:SetParent(self.cardParent.transform, false)
    itemSpt:InitView(card)
    self.cardName.text = card:GetName()
    self.cardGroup.text = card:GetBigGroupName()
    self.cardBigGroup.text = card:GetGroupName()
    local star = card:GetStar()
    if star >= 0 then
        self.active.text = lang.trans("fancy_light", star)
    else
        self.active.text = lang.trans("fancy_unlight")
    end
    GameObjectHelper.FastSetActive(self.teamDetailBtn.gameObject, _type == 3)
    GameObjectHelper.FastSetActive(self.countGo, _type ~= 3)
    if _type == 1 then
        local count = card:GetCount()
        self.countLabel.text = lang.trans("fancyCardCountLabel")
        self.count.text = tostring(count >= 0 and count or 0) .. lang.transstr("fancy_count")
        
    elseif _type == 2 then
        self.countLabel.text = lang.trans("fancyCardGetLabel")
        self.count.text = card:GetAccess()
    end
end

function FancyPreView:OnTeamDetailClick()
    self:CloseView()
    res.PushScene('ui.controllers.fancy.fancyHome.FancyGroupCtrl', self.card:GetGroupID(), self.card:GetFancyCardsMapModel())
end

function FancyPreView:OnConfirm()
    self:Close()
end

function FancyPreView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FancyPreView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FancyPreView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FancyPreView:Close()
    self:PlayOutAnimator()
end

return FancyPreView