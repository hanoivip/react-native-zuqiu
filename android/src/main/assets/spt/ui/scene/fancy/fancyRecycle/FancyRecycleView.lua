local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local DialogManager = require("ui.control.manager.DialogManager")
local ScrollSizeConfig = require("ui.scene.fancy.fancyRecycle.ScrollSizeConfig")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")

local FancyRecycleView = class(unity.base)
local Tag = {}
Tag.Card = "card"
Tag.Recycle = "recycle"
local DefaultTag = Tag.Card
local SizeCount = {-1100, -700, -400, -200, -100, 0}
local MaxRecycleCount = 10

function FancyRecycleView:ctor()
--------Start_Auto_Generate--------
    self.recycleGo = self.___ex.recycleGo
    self.addGo = self.___ex.addGo
    self.addTipBtn = self.___ex.addTipBtn
    self.recycleAreaGo = self.___ex.recycleAreaGo
    self.recycleTrans = self.___ex.recycleTrans
    self.cancelBtn = self.___ex.cancelBtn
    self.confirmBtn = self.___ex.confirmBtn
    self.fsCountTxt = self.___ex.fsCountTxt
    self.scrollViewSpt = self.___ex.scrollViewSpt
    self.cardTrans = self.___ex.cardTrans
    self.selectBtn = self.___ex.selectBtn
    self.selectGo = self.___ex.selectGo
    self.scrollbarTrans = self.___ex.scrollbarTrans
    self.filterBtn = self.___ex.filterBtn
    self.recycleEmptyGo = self.___ex.recycleEmptyGo
    self.bagGo = self.___ex.bagGo
    self.cardCountTxt = self.___ex.cardCountTxt
    self.bagQualityGroupSpt = self.___ex.bagQualityGroupSpt
    self.defaultBtn = self.___ex.defaultBtn
    self.defaultSelectGo = self.___ex.defaultSelectGo
    self.bagFilterBtn = self.___ex.bagFilterBtn
    self.bagScrollSpt = self.___ex.bagScrollSpt
    self.cardTrans = self.___ex.cardTrans
    self.detailBtn = self.___ex.detailBtn
    self.bagEmptyTxt = self.___ex.bagEmptyTxt
    self.btnGroupSpt = self.___ex.btnGroupSpt
    self.backBtn = self.___ex.backBtn
    self.infoBarDynSpt = self.___ex.infoBarDynSpt
--------End_Auto_Generate----------
    self.scrollBar = self.___ex.scrollBar
    self.cardSelectSpt = {}
    self.bagDefaultState = true
end

function FancyRecycleView:start()
    self:BindButtonHandler()
    self:InitTab()
end

function FancyRecycleView:BindButtonHandler()
    -- 返回
    self.backBtn:regOnButtonClick(function()
        self:Close()
    end)

    -- 卡牌分解 分解
    self.confirmBtn:regOnButtonClick(function()
        self:OnRecycleClick()
    end)

    -- 卡牌分解 取消
    self.cancelBtn:regOnButtonClick(function()
        self:OnCancelClick()
    end)

    -- 卡牌分解 筛选
    self.filterBtn:regOnButtonClick(function()
        self:OnFilterBtnClick()
    end)

    -- 卡牌分解 添加卡牌提示
    self.addTipBtn:regOnButtonClick(function()
        DialogManager.ShowToastByLang("fancy_recycle_select")
    end)

    -- 背包筛选 的默认还原按钮
    self.defaultBtn:regOnButtonClick(function()
        self:OnBagDefaultBtnClick()
    end)

    -- 背包筛选 筛选
    self.bagFilterBtn:regOnButtonClick(function()
        self:OnBagFilterBtnClick()
    end)
end

function FancyRecycleView:RegOnDynamicLoad(func)
    self.infoBarDynSpt:RegOnDynamicLoad(func)
end

function FancyRecycleView:InitView(fancyRecycleModel, fancyBagModel, tag, fancyCardResourceCache)
    self.fancyCardsMapModel = FancyCardsMapModel.new()
    self.fancyCardResourceCache = fancyCardResourceCache
    self.model = fancyRecycleModel
    self.fancyBagModel = fancyBagModel
    tag = tag or DefaultTag
    self:OnTabClick(tag)
    self.btnGroupSpt:selectMenuItem(tag)
    self:ChangeBagQualityBtnState()
end

function FancyRecycleView:InitTab()
    for i, v in pairs(self.btnGroupSpt.menu) do
        self.btnGroupSpt:BindMenuItem(i, function()
            self:OnTabClick(i)
        end)
    end
    for i, v in pairs(self.bagQualityGroupSpt.menu) do
        self.bagQualityGroupSpt:BindMenuItem(i, function()
            self:OnBagQualityTabClick(i)
        end)
    end
end

function FancyRecycleView:OnTabClick(tag)
    self.currTag = tag
    if self.onTabClick then
        self.onTabClick(tag)
    end
    if tag == Tag.Card then
        self:InitCardBag()
    elseif tag == Tag.Recycle then
        self:InitRecycle()
    end
    GameObjectHelper.FastSetActive(self.recycleGo, tag == Tag.Recycle)
    GameObjectHelper.FastSetActive(self.bagGo, tag == Tag.Card)
end

function FancyRecycleView:OnBagQualityTabClick(tag)
    self.fancyBagModel:SetSelectQuality(tag)
    self.bagDefaultState = false
    self:InitCardBag()
end

function FancyRecycleView:InitCardBag()
    local filterCardList = self.fancyBagModel:GetFilterCardList()
    local count = self.fancyBagModel:GetCount()
    self.bagScrollSpt:InitView(filterCardList, self.fancyCardResourceCache)
    self.cardCountTxt.text = tostring(count)
    if #filterCardList == 0 then
        local isFilterEmpty = self.fancyBagModel:IsFilterEmpty()
        if isFilterEmpty then
            self.bagEmptyTxt.text = lang.trans("fancy_empty")
        else
            self.bagEmptyTxt.text = lang.trans("fancy_filter_empty")
        end
    end
    GameObjectHelper.FastSetActive(self.bagEmptyTxt.gameObject,#filterCardList == 0)
    GameObjectHelper.FastSetActive(self.defaultSelectGo, self.bagDefaultState)
end

function FancyRecycleView:InitRecycle()
    local filterCardList = self.model:GetFilterCardList()
    self:ResetSelect()
    local scrollBarSizeDelta = self:GetScrollBarSize(#filterCardList)
    self.scrollViewSpt:InitView(filterCardList, function(cardData) self:OnSelectClick(cardData) end, self.fancyCardResourceCache)
    self.scrollbarTrans.sizeDelta = scrollBarSizeDelta
    self.selectCount = 0
    self:SetAddState()
    res.ClearChildren(self.recycleTrans)
    GameObjectHelper.FastSetActive(self.recycleEmptyGo, #filterCardList == 0)
end

function FancyRecycleView:ResetSelect()
    self.cardSelectSpt = {}
    self.model:ResetSelectCards()
end

function FancyRecycleView:OnRecycleClick()
    if self.recycleClick then
        self.recycleClick()
    end
end

function FancyRecycleView:OnBagDefaultBtnClick()
    if not self.bagDefaultState then
        self.bagDefaultState = true
        self.fancyBagModel:SetSelectQuality()
        self:InitCardBag()
        self.bagQualityGroupSpt.currentMenuTag = nil
        for k, v in pairs(self.bagQualityGroupSpt.menu) do
            v:unselectBtn()
            v:onPointEventHandle(true)
        end
    end
end

function FancyRecycleView:OnSelectClick(cardData)
    local index = cardData.index
    if self.selectCount >= MaxRecycleCount and (not cardData.selected) then
        DialogManager.ShowToastByLang("fancy_recycle_max")
        return
    end
    cardData.selected = not cardData.selected
    if cardData.selected then
        if not self.cardSelectSpt[index] then
            local fancyCardModel = FancyCardModel.new()
            fancyCardModel:InitData(cardData.fid, self.fancyCardsMapModel)
            local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
            itemObj.transform:SetParent(self.recycleTrans, false)
            self.cardSelectSpt[index] = itemSpt
            self.cardSelectSpt[index]:SetResourceCache(self.fancyCardResourceCache)
            self.cardSelectSpt[index]:InitView(fancyCardModel)
            self.cardSelectSpt[index].OnBtnClick = function() self:OnUpSelectCardClick(index, cardData) end
        end
        GameObjectHelper.FastSetActive(self.cardSelectSpt[index].gameObject, true)
        self.selectCount = self.selectCount + 1
    else
        GameObjectHelper.FastSetActive(self.cardSelectSpt[index].gameObject, false)
        self.selectCount = self.selectCount - 1
    end
    self:RefreshFS()
    self.scrollViewSpt:UpdateItem(index, cardData)
end

function FancyRecycleView:OnUpSelectCardClick(index, cardData)
    cardData.selected = false
    GameObjectHelper.FastSetActive(self.cardSelectSpt[index].gameObject, false)
    self.selectCount = self.selectCount - 1
    self.scrollViewSpt:UpdateItem(index, cardData)
    self:RefreshFS()
end

function FancyRecycleView:RefreshFS()
    local fsCount = self.model:GetSelectFSCount()
    self.fsCountTxt.text = "x" .. fsCount
    local count = SizeCount[self.selectCount] or 0
    count = math.clamp(count, -1100, 0)
    self.recycleTrans.transform.sizeDelta = Vector2(count, 320)
    self:SetAddState()
end

function FancyRecycleView:OnCancelClick()
    self.model:FilterCardList()
    self:InitView(self.model, self.fancyBagModel, Tag.Recycle)
end

function FancyRecycleView:OnFilterBtnClick()
    local groupIds = self.model:GetSelectGroupIDs()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyRecycle/FancyRecycleFilter.prefab"
    local dialog, dialogcomp = res.ShowDialog(path, "camera", false, true)
    local script = dialogcomp.contentcomp
    script:InitView(groupIds)
end

function FancyRecycleView:OnBagFilterBtnClick()
    local groupIds = self.fancyBagModel:GetSelectGroupIDs()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyRecycle/FancyRecycleFilter.prefab"
    local dialog, dialogcomp = res.ShowDialog(path, "camera", false, true)
    local script = dialogcomp.contentcomp
    script:InitView(groupIds)
end

function FancyRecycleView:OnFilterConfirm(groupIds)
    if self.currTag == Tag.Card then
        self.fancyBagModel:SetSelectGroupIDs(groupIds)
        self:InitCardBag()
    else
        self.model:SetSelectGroupIDs(groupIds)
        self:InitRecycle()
    end
end

function FancyRecycleView:OnFilterReset()
    if self.currTag == Tag.Card then
        self.fancyBagModel:SetSelectGroupIDs()
        self:InitCardBag()
    else
        self.model:SetSelectGroupIDs()
        self:InitRecycle()
    end
end

function FancyRecycleView:SetAddState()
    GameObjectHelper.FastSetActive(self.recycleAreaGo, self.selectCount > 0)
    GameObjectHelper.FastSetActive(self.addGo, self.selectCount == 0)
end

function FancyRecycleView:GetScrollBarSize(count)
    if count <= 11 then
        count = 14000
    elseif ScrollSizeConfig[count]then
        count = ScrollSizeConfig[count]
    else
        count = 4400000*count^-2.407
        math.clamp(count, 0, 6600)
    end
    return Vector2(count, 20)
end

function FancyRecycleView:ChangeBagQualityBtnState()
    local quality = self.fancyBagModel:GetSelectQuality()
    local quality = next(quality)
    for k, v in pairs(self.bagQualityGroupSpt.menu) do
        v:unselectBtn()
        v:onPointEventHandle(true)
    end
    if quality then
        self.bagQualityGroupSpt:selectMenuItem(tostring(quality))
        self.bagQualityGroupSpt.menu[tostring(quality)]:selectBtn()
        self.bagQualityGroupSpt.menu[tostring(quality)]:onPointEventHandle(false)
        GameObjectHelper.FastSetActive(self.defaultSelectGo, false)
    else
        GameObjectHelper.FastSetActive(self.defaultSelectGo, true)
    end
end


function FancyRecycleView:Close()
    res.PopScene()
end

function FancyRecycleView:EnterScene()
    EventSystem.AddEvent("FancyRecycleFilter_Confirm", self, self.OnFilterConfirm)
    EventSystem.AddEvent("FancyRecycleFilter_Reset", self, self.OnFilterReset)
end

function FancyRecycleView:ExitScene()
    EventSystem.RemoveEvent("FancyRecycleFilter_Confirm", self, self.OnFilterConfirm)
    EventSystem.RemoveEvent("FancyRecycleFilter_Reset", self, self.OnFilterReset)
end

return FancyRecycleView
