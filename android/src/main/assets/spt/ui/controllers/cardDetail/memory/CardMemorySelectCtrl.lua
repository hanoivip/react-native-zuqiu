local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardMemorySelectModel = require("ui.models.cardDetail.memory.CardMemorySelectModel")

local CardMemorySelectCtrl = class(BaseCtrl, "CardMemorySelectCtrl")

CardMemorySelectCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Memory/CardMemorySelect.prefab"

CardMemorySelectCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CardMemorySelectCtrl:ctor(memoryItemModel)
    CardMemorySelectCtrl.super.ctor(self, memoryItemModel)
end

function CardMemorySelectCtrl:Init(memoryItemModel)
    CardMemorySelectCtrl.super.Init(self, memoryItemModel)

    self.memoryItemModel = memoryItemModel

    local cid = self.memoryItemModel:GetFillableCid()
    local filledCard = self.memoryItemModel:GetFilledCard()
    local filledPcid = filledCard and filledCard:GetPcid() or nil
    self.model = CardMemorySelectModel.new(cid, filledPcid)
    self.model:SetMemoryItemModel(memoryItemModel)

    self.view.onSortClick = function(sortType) self:OnSortClick(sortType) end
    self.view.onScrollItemClick = function(cardModel) self:OnScrollItemClick(cardModel) end
    self.view.onBtnConfirm = function() self:OnBtnConfirm() end
end

function CardMemorySelectCtrl:Refresh(memoryItemModel)
    CardMemorySelectCtrl.super.Refresh(self, memoryItemModel)

    self.view:InitView(self.model)
end

-- 点击排序按钮
function CardMemorySelectCtrl:OnSortClick(sortType)
    self.model:SetCurrSortType(sortType)
    self.model:SortCardModels()
    self.view:RefreshScrollView()
end

-- 点击列表中球员
function CardMemorySelectCtrl:OnScrollItemClick(cardModel)
    local idx = self.model:GetIdxByPcid(cardModel:GetPcid())

    local oldCard = self.model:GetSelectedCard()
    local oldIdx = nil
    if oldCard then
        oldIdx = self.model:GetIdxByPcid(oldCard:GetPcid())
    end
    if idx == oldIdx then return end

    self.model:SetSelectedCard(cardModel)

    if oldIdx then
        self.view:UpdateScrollItem(oldIdx, oldCard)
    end
    self.view:UpdateScrollItem(idx, cardModel)
    self.view:UpdateBtnConfirm()
end

-- 点击确定
function CardMemorySelectCtrl:OnBtnConfirm()
    local selectedCard = self.model:GetSelectedCard() -- 被记忆的
    if not selectedCard then
        DialogManager.ShowToastByLang("coach_guide_select_card") -- 请选择球员
        return
    end

    local targetCard = self.memoryItemModel:GetTargetCardModel() -- 记忆别人的球员
    local pcid = targetCard:GetPcid()
    local mPcid = selectedCard:GetPcid()
    local filledPcid = self.model:GetFilledPcid()
    if filledPcid and filledPcid == mPcid then
        DialogManager.ShowToastByLang("memory_select_filled") -- 您已添加该球员
        return
    end

    local confirmCallback = function()
        local qualityKey = CardHelper.GetQualityConfigFixed(selectedCard:GetCardQuality(), selectedCard:GetCardQualitySpecial())
        self.view:coroutine(function()
            local response = req.cardActiveMemory(qualityKey, pcid, mPcid)
            if api.success(response) then
                local data = response.val
                self.model:UpdateAfterConfirm(data)
                self.view:UpdateAfterConfirm()
                self.view:Close()
            end
        end)
    end

    local title = lang.trans("tips")
    local quality = targetCard:GetCardQuality()
    local qualitySpecial = targetCard:GetCardQualitySpecial()
    local qualityStr = lang.transstr(CardHelper.QualitySign[CardHelper.GetQualityFixed(quality, qualitySpecial)])
    local cardName = targetCard:GetName()
    local attrAdd = self.model:GetAttrImprove(selectedCard)
    local msg = lang.trans("memory_select_confirm", qualityStr, cardName, lang.transstr("card_training_rule_allAttr", attrAdd))
    -- 二次确认
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

return CardMemorySelectCtrl
