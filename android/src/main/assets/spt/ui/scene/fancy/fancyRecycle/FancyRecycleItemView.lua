local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local FancyRecycleItemView = class(unity.base)

function FancyRecycleItemView:ctor()
--------Start_Auto_Generate--------
    self.cardTrans = self.___ex.cardTrans
    self.maskGo = self.___ex.maskGo
    self.lockGo = self.___ex.lockGo
    self.selectBtn = self.___ex.selectBtn
    self.selectGo = self.___ex.selectGo
--------End_Auto_Generate----------
    self.fancyCardsMapModel = FancyCardsMapModel.new()
end

function FancyRecycleItemView:start()
    self.selectBtn:regOnButtonClick(function()
        self:OnSelectClick()
    end)
end

function FancyRecycleItemView:InitView(fancyCard, onSelectCallBack, fancyCardResourceCache)
    self.fancyCard = fancyCard
    self.onSelectCallBack = onSelectCallBack
    self.fancyCardResourceCache = fancyCardResourceCache
    self:InitFancyCardArea()
end

function FancyRecycleItemView:InitFancyCardArea()
    local fid =  self.fancyCard.fid
    local state = tobool( self.fancyCard.selected)
    local fancyCardModel = FancyCardModel.new()
    fancyCardModel:InitData(fid, self.fancyCardsMapModel)
    if not self.cardSpt then
        res.ClearChildren(self.cardTrans)
        local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
        itemObj.transform:SetParent(self.cardTrans, false)
        self.cardSpt = itemSpt
    end
    self.cardSpt:SetResourceCache(self.fancyCardResourceCache)
    self.cardSpt:InitView(fancyCardModel)
    self:SetSelectState(state)
    local quality = self.fancyCard.quality
    local lockState = quality >= 3 and (not self.fancyCard.lock)
    GameObjectHelper.FastSetActive(self.lockGo, lockState)
    GameObjectHelper.FastSetActive(self.maskGo, lockState)
end

function FancyRecycleItemView:OnSelectClick()
    if self.fancyCard.quality >= 3 and (not self.fancyCard.lock) then
        local title = lang.trans("tips")
        local content = lang.trans("fancy_confirm_unlock")
        DialogManager.ShowConfirmPop(title, content, function()
            self.fancyCard.lock = true
            GameObjectHelper.FastSetActive(self.lockGo, false)
            GameObjectHelper.FastSetActive(self.maskGo, false)
        end)
        return
    end
    if self.onSelectCallBack then
        self.onSelectCallBack(self.fancyCard)
    end
end

function FancyRecycleItemView:ChangeSelect()
    local state = tobool(self.fancyCard.selected)
    GameObjectHelper.FastSetActive(self.lockGo, false)
    self.fancyCard.selected = not state
    self:SetSelectState(state)
end

function FancyRecycleItemView:SetSelectState(state)
    GameObjectHelper.FastSetActive(self.selectGo, state)
    GameObjectHelper.FastSetActive(self.maskGo, state)
end

return FancyRecycleItemView
