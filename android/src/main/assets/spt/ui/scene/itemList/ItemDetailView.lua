local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local MenuType = require("ui.controllers.itemList.MenuType")
local AssetFinder = require("ui.common.AssetFinder")
local EventSystem = require("EventSystem")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UISoundManager = require("ui.control.manager.UISoundManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local ItemDetailView = class(unity.base)

function ItemDetailView:ctor()
    self.itemName = self.___ex.itemName
    self.itemNumForItemList = self.___ex.itemNumForItemList
    self.itemIcon = self.___ex.itemIcon
    self.itemQualityBoard = self.___ex.itemQualityBoard
    self.pieceSign = self.___ex.pieceSign
    self.itemDesc = self.___ex.itemDesc
    self.pieceNumber = self.___ex.pieceNumber
    self.commonSource = self.___ex.commonSource
    self.commonSourceContent = self.___ex.commonSourceContent
    self.noneSource = self.___ex.noneSource
    self.itemObtainWay = self.___ex.itemObtainWay
    self.pieceCompositeInfoArea = self.___ex.pieceCompositeInfoArea
    self.btnPieceComposite = self.___ex.btnPieceComposite
    self.btnPieceCompositeAll = self.___ex.btnPieceCompositeAll
    self.pieceCompositeButton = self.___ex.pieceCompositeButton
    self.pieceCompositeAllButton = self.___ex.pieceCompositeAllButton
    self.pieceCompositeButtonNormalText = self.___ex.pieceCompositeButtonNormalText
    self.pieceCompositeButtonDisableText = self.___ex.pieceCompositeButtonDisableText
    self.pieceCompositeAllButtonNormalText = self.___ex.pieceCompositeAllButtonNormalText
    self.pieceCompositeAllButtonDisableText = self.___ex.pieceCompositeAllButtonDisableText
    self.btnClose = self.___ex.btnClose
    self.canvasGroup = self.___ex.canvasGroup
    self.playerBoardScrollView = self.___ex.playerBoardScrollView
    self.itemBoardArea = self.___ex.itemBoardArea
    self.playerBoard = self.___ex.playerBoard
    self.itemNumAreaForOther = self.___ex.itemNumAreaForOther
    self.itemNumAreaForItemList = self.___ex.itemNumAreaForItemList
    self.itemNumForOther = self.___ex.itemNumForOther
    self.itemSourceArea = self.___ex.itemSourceArea
    self.pieceIcon = self.___ex.pieceIcon
    self.giftboxContentRect = self.___ex.giftboxContentRect
    self.giftboxScrolView = self.___ex.giftboxScrolView
    self.giftboxContent = self.___ex.giftboxContent
    self.arrow = self.___ex.arrow
end

function ItemDetailView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnPieceComposite:regOnButtonClick(function()
        if self.onComposite then
            UISoundManager.play('Player/encourageSound', 1)
            self.onComposite(1)
        end
    end)
    self.btnPieceCompositeAll:regOnButtonClick(function()
        if self.onComposite then
            UISoundManager.play('Player/encourageSound', 1)
            self.onComposite(math.floor(self.model:GetEquipPieceNum() / self.pieceLimit))
        end
    end)
    self:PlayInAnimator()
end

function ItemDetailView:InitView(itemType, model, itemOriginType)
    self.model = model
    self.itemType = itemType
    self.itemOriginType = itemOriginType
    local name = model:GetName() or lang.trans("retry_login")
    self.itemName.text = name
    
    self.itemQualityBoard.overrideSprite = AssetFinder.GetItemQualityBoard(model:GetQuality())
    local desc = model:GetDesc() or lang.trans("retry_login_desc")
    self.itemDesc.text = desc
    if self.itemOriginType == ItemOriginType.ITEMLIST then
        self.itemBoardArea.sizeDelta = Vector2(self.itemBoardArea.sizeDelta.x, 587)
        GameObjectHelper.FastSetActive(self.itemSourceArea.gameObject, true)
        GameObjectHelper.FastSetActive(self.itemNumAreaForItemList.gameObject, true)
        GameObjectHelper.FastSetActive(self.itemNumAreaForOther.gameObject, false)
        self.itemNumForItemList.text = "x" .. tostring(model:GetAddNum())
    elseif self.itemOriginType == ItemOriginType.OTHER then
        self.itemBoardArea.sizeDelta = Vector2(self.itemBoardArea.sizeDelta.x, 385)
        GameObjectHelper.FastSetActive(self.itemSourceArea.gameObject, false)
        GameObjectHelper.FastSetActive(self.itemNumAreaForItemList.gameObject, false)
        GameObjectHelper.FastSetActive(self.itemNumAreaForOther.gameObject, true)
        local mascotIntimacyId = 26 --吉祥物亲密度道具详情不显示“拥有XX件”
        if type(self.model) == "table" and type(self.model.GetId) == "function" and tonumber(self.model:GetId()) == mascotIntimacyId then
            GameObjectHelper.FastSetActive(self.itemNumAreaForOther.gameObject, false)
        end
        self.itemNumForOther.text = lang.trans("itemDetail_number",tostring(model:GetAddNum()))
        local fsId = 33 -- 获取球魂数量
        if type(self.model) == "table" and type(self.model.GetId) == "function" and tonumber(self.model:GetId()) == fsId then
            local playerInfoModel = require("ui.models.PlayerInfoModel"):new()
            self.itemNumForOther.text = lang.trans("itemDetail_number",tostring(playerInfoModel:GetFS()))
        end
    end

    if itemType == MenuType.EQUIP then
        self:InitEquipView()
    elseif itemType == MenuType.EQUIPPIECE then
        self:InitEquipPieceView()
    elseif itemType == MenuType.ITEM then
        self:InitItemView()
    elseif itemType == MenuType.TACTIC then
        self:InitTacticView()
    elseif itemType == MenuType.ADVITEM then
        self:InitAdvItemView()
    end

    local isPiece = false
    if self.itemType == MenuType.EQUIPPIECE then
        isPiece = true
        self.pieceIcon.overrideSprite = AssetFinder.GetEquipIcon(self.model:GetIconIndex())
    end

    if self.itemType == MenuType.EQUIP or self.itemType == MenuType.EQUIPPIECE then
        self.itemIcon.overrideSprite = AssetFinder.GetEquipIcon(self.model:GetIconIndex())
    elseif self.itemType == MenuType.ITEM then
        self.itemIcon.overrideSprite = AssetFinder.GetItemIcon(self.model:GetIconIndex())
    end

    GameObjectHelper.FastSetActive(self.pieceSign.gameObject, isPiece)
    GameObjectHelper.FastSetActive(self.itemIcon.gameObject, not isPiece)
end

function ItemDetailView:InitEquipView()
    if self.itemOriginType == ItemOriginType.ITEMLIST then
        GameObjectHelper.FastSetActive(self.noneSource.gameObject, false)
        GameObjectHelper.FastSetActive(self.commonSource.gameObject, true)
        if self.model:GetPieceNum() == 1 then
            GameObjectHelper.FastSetActive(self.pieceCompositeInfoArea.gameObject, false)
        else
            GameObjectHelper.FastSetActive(self.pieceCompositeInfoArea.gameObject, true)
            self.pieceLimit = self.model:GetPieceNum()
            self.pieceNum = self.model:GetEquipPieceNum()
            self.pieceNumber.text = tostring(self.pieceNum) .. "/" .. tostring(self.pieceLimit)
            self:SetPieceCompositeBtnState(self.pieceNum)
        end
        if self.onFillCommonSourceContent then
            res.ClearChildren(self.commonSourceContent)
            self.onFillCommonSourceContent(self.commonSourceContent)
        end
    elseif self.itemOriginType == ItemOriginType.OTHER then
        GameObjectHelper.FastSetActive(self.pieceCompositeInfoArea.gameObject, false)
    end
end

function ItemDetailView:InitEquipPieceView()
    if self.itemOriginType == ItemOriginType.ITEMLIST then
        GameObjectHelper.FastSetActive(self.commonSource.gameObject, true)
        GameObjectHelper.FastSetActive(self.noneSource.gameObject, false)
        GameObjectHelper.FastSetActive(self.pieceCompositeInfoArea.gameObject, true)
        self.pieceLimit = self.model:GetPieceNum()
        self.pieceNum = self.model:GetAddNum()
        self.pieceNumber.text = tostring(self.pieceNum) .. "/" .. tostring(self.pieceLimit)
        self:SetPieceCompositeBtnState(self.pieceNum)
        if self.onFillCommonSourceContent then
            res.ClearChildren(self.commonSourceContent)
            self.onFillCommonSourceContent(self.commonSourceContent)
        end 
    elseif self.itemOriginType == ItemOriginType.OTHER then
        GameObjectHelper.FastSetActive(self.pieceCompositeInfoArea.gameObject, false)
    end
end

function ItemDetailView:InitItemView()
    GameObjectHelper.FastSetActive(self.pieceCompositeInfoArea.gameObject, false)
    if self.itemOriginType == ItemOriginType.ITEMLIST then
        GameObjectHelper.FastSetActive(self.commonSource.gameObject, false)
        GameObjectHelper.FastSetActive(self.noneSource.gameObject, true)
        self.itemObtainWay.text = self.model:GetAccess()
        return
    end

    local giftboxRewardData = self.model:GetItemContent()
    if giftboxRewardData then
        GameObjectHelper.FastSetActive(self.giftboxContent.gameObject, true)
        self.itemBoardArea.sizeDelta = Vector2(self.itemBoardArea.sizeDelta.x, 520)
        self.giftboxScrolView:InitView(giftboxRewardData)
        GameObjectHelper.FastSetActive(self.arrow.gameObject, self.giftboxContentRect.childCount >= 5)
    end
end

-- 初始化教练道具
function ItemDetailView:InitTacticView()
    -- 教练阵型/战术道具用到 PackedSpritesDynamic 材质 和 其他的物品不同
    if not self.packedMat then
        self.packedMat = res.LoadRes("Assets/CapstonesRes/Common/Materials/PackedSpritesDynamic.mat")
    end
    self.itemIcon.material = self.packedMat
    self.itemIcon.overrideSprite = AssetFinder.GetCoachTacticItemIcon(self.model:GetIconIndex())
    self.itemNumForOther.text = lang.trans("itemDetail_number",self.model:GetOwnNum())
end

-- 初始化绿茵征途道具显示
function ItemDetailView:InitAdvItemView()
    self.itemIcon.overrideSprite = AssetFinder.GetItemIcon(self.model:GetIconIndex())
    self.itemNumForOther.text = lang.trans("itemDetail_number",self.model:GetOwnNum())

    local giftboxRewardData = self.model:GetItemContent()
    if giftboxRewardData then
        GameObjectHelper.FastSetActive(self.giftboxContent.gameObject, true)
        self.itemBoardArea.sizeDelta = Vector2(self.itemBoardArea.sizeDelta.x, 520)
        self.giftboxScrolView:InitView(giftboxRewardData)
        GameObjectHelper.FastSetActive(self.arrow.gameObject, self.giftboxContentRect.childCount >= 5)
    end
end

-- 初始化货币类型道具显示
function ItemDetailView:InitCurrencyView()
    
end

function ItemDetailView:SetEquipNum(num)
    if num == 0 then
        self:Close()
        return
    end
    if self.itemOriginType == ItemOriginType.ITEMLIST then
        self.itemNumForItemList.text = "x" .. tostring(num)
    elseif self.itemOriginType == ItemOriginType.OTHER then
        self.itemNumForOther.text = lang.trans("itemDetail_number",tostring(num))
    end
end

function ItemDetailView:SetEquipPieceNum(num)
    if self.itemType == MenuType.EQUIPPIECE then
        if num == 0 then
            self:Close()
            return
        end
        if self.itemOriginType == ItemOriginType.ITEMLIST then
            self.itemNumForItemList.text = "x" .. tostring(num)
            local pieceLimit = self.model:GetPieceNum()
            self.pieceNumber.text = tostring(num) .. "/" .. tostring(pieceLimit)
            self:SetPieceCompositeBtnState(num)
        elseif self.itemOriginType == ItemOriginType.OTHER then
            self.itemNumForOther.text = lang.trans("itemDetail_number",tostring(num))
        end
    elseif self.itemType == MenuType.EQUIP then
        if self.itemOriginType == ItemOriginType.ITEMLIST then
            if self.model:GetPieceNum() ~= 1 then
                local pieceLimit = self.model:GetPieceNum()
                self.pieceNumber.text = tostring(num) .. "/" .. tostring(pieceLimit)
                self:SetPieceCompositeBtnState(num)
            end
        end
    end
end

function ItemDetailView:SetItemNum(num)
    if num == 0 then
        self:Close()
        return
    end
    if self.itemOriginType == ItemOriginType.ITEMLIST then
        self.itemNumForItemList.text = "x" .. tostring(num)
    elseif self.itemOriginType == ItemOriginType.OTHER then
        self.itemNumForOther.text = lang.trans("itemDetail_number",tostring(num))
    end
end

function ItemDetailView:SetPieceCompositeBtnState(pieceNumber)
    local pieceLimit = self.model:GetPieceNum()
    if pieceNumber >= pieceLimit then
        self.pieceCompositeButton.interactable = true
        self.pieceCompositeAllButton.interactable = true
        self.btnPieceComposite:onPointEventHandle(true)
        self.btnPieceCompositeAll:onPointEventHandle(true)
        GameObjectHelper.FastSetActive(self.pieceCompositeButtonNormalText.gameObject, true)
        GameObjectHelper.FastSetActive(self.pieceCompositeAllButtonNormalText.gameObject, true)
        GameObjectHelper.FastSetActive(self.pieceCompositeButtonDisableText.gameObject, false)
        GameObjectHelper.FastSetActive(self.pieceCompositeAllButtonDisableText.gameObject, false)
    else
        self.pieceCompositeButton.interactable = false
        self.pieceCompositeAllButton.interactable = false
        self.btnPieceComposite:onPointEventHandle(false)
        self.btnPieceCompositeAll:onPointEventHandle(false)
        GameObjectHelper.FastSetActive(self.pieceCompositeButtonNormalText.gameObject, false)
        GameObjectHelper.FastSetActive(self.pieceCompositeAllButtonNormalText.gameObject, false)
        GameObjectHelper.FastSetActive(self.pieceCompositeButtonDisableText.gameObject, true)
        GameObjectHelper.FastSetActive(self.pieceCompositeAllButtonDisableText.gameObject, true)
    end
end

function ItemDetailView:ShowOrHidePlayerBoard(isShow)
    GameObjectHelper.FastSetActive(self.playerBoard.gameObject, isShow)
    if isShow then
        self.itemBoardArea.localPosition = Vector3(-106.5, self.itemBoardArea.y, self.itemBoardArea.z)
    else
        self.itemBoardArea.localPosition = Vector3(0, self.itemBoardArea.y, self.itemBoardArea.z)
    end
end

function ItemDetailView:EventEquipNumChanged(eid, num)
    if self.equipNumChangedCallBack then
        self.equipNumChangedCallBack(eid, num)
    end
end

function ItemDetailView:EventEquipPieceNumChanged(pid, num)
    if self.equipPieceNumChangedCallBack then
        self.equipPieceNumChangedCallBack(pid, num)
    end
end

function ItemDetailView:EventItemNumChanged(id, num)
    if self.itemNumChangedCallBack then
        self.itemNumChangedCallBack(pid, num)
    end
end

function ItemDetailView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function ItemDetailView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function ItemDetailView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function ItemDetailView:Close()
    self:PlayOutAnimator()
end

function ItemDetailView:EnterScene()
    EventSystem.AddEvent("EquipsMapModel_ResetEquipNum", self, self.EventEquipNumChanged)
    EventSystem.AddEvent("EquipPieceMapModel_ResetItemNum", self, self.EventEquipPieceNumChanged)
    EventSystem.AddEvent("ItemsMapModel_ResetItemNum", self, self.EventItemNumChanged)
end

function ItemDetailView:ExitScene()
    EventSystem.RemoveEvent("EquipsMapModel_ResetEquipNum", self, self.EventEquipNumChanged)
    EventSystem.RemoveEvent("EquipPieceMapModel_ResetItemNum", self, self.EventEquipPieceNumChanged)
    EventSystem.RemoveEvent("ItemsMapModel_ResetItemNum", self, self.EventItemNumChanged)
end

return ItemDetailView