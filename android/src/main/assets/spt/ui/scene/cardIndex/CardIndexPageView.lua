local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local EventSystems = UnityEngine.EventSystems

local CardIndexPageView = class(unity.base)

function CardIndexPageView:ctor()
    -- 顶部信息栏
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 滚动视图
    self.scrollView = self.___ex.scrollerView
    self.scrollRect = self.___ex.scrollRect
    -- 滚动条
    self.scrollBar = self.___ex.scrollBar
    -- 位置筛选btn
    self.btnSearch = self.___ex.btnSearch
    -- 位置筛选文本
    self.posText = self.___ex.posText
    -- 视图背景
    self.viewBg = self.___ex.viewBg
    self.animator = self.___ex.animator
    -- 球员已拥有过数量
    self.playerNumber = self.___ex.playerNumber
    -- 滚动归一化位置
    self.scrollNormalizedPosition = nil
end

function CardIndexPageView:start()
    self.btnSearch:regOnButtonClick(function()
        self:OnBtnSearch()
    end)
end

function CardIndexPageView:EnterScene()
    EventSystem.AddEvent("CardIndexModel.SortCardList", self, self.EventSortCardList)
end

function CardIndexPageView:ExitScene()
    EventSystem.RemoveEvent("CardIndexModel.SortCardList", self, self.EventSortCardList)
end

function CardIndexPageView:InitView(cardIndexModel)
    self.cardIndexModel = cardIndexModel
    self:SetCurrentCardsCount(cardIndexModel:GetOwnCardsCount(), cardIndexModel:GetTotalCardsCount())
    self:OnBuildPage()
end

function CardIndexPageView:EventSortCardList()
    self:SetSelectDetail(self.cardIndexModel)
    if self.sortCardListCallBack then
        self.sortCardListCallBack()
    end
end

function CardIndexPageView:OnBuildPage()
    self.scrollView:ResetWithCellSpace(22, 25)
    self.scrollView:ResetWithViewSize(1018, 420)
    self.scrollBar.anchoredPosition = Vector2(14, 1)
    self.viewBg.sizeDelta = Vector2(1054, 445)
    if self.clickMenu then
        self.clickMenu(index)
    end
end

function CardIndexPageView:OnBtnSearch()
    if self.clickSearch then
        self.clickSearch()
    end
end

function CardIndexPageView:SetCurrentCardsCount(ownCount, totalCount)
    local desc = tostring(ownCount) .. "/" .. tostring(totalCount)
    self.playerNumber.text = desc
    self.playerNumber.color = Color(0.98, 0.92, 0.275, 1)
end

--- 获取滚动归一化位置
function CardIndexPageView:GetScrollNormalizedPosition()
    return self.scrollView:GetScrollNormalizedPosition()
end

function CardIndexPageView:InitialData()
    local selectTypeIndex = self.cardIndexModel:GetSelectTypeIndex()
    self.sortMenuView:InitialData(selectTypeIndex)
end

function CardIndexPageView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function CardIndexPageView:PlayLeaveAnimation()
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem = EventSystems.EventSystem.current
        self.currentEventSystem.enabled = false
    end
    self.animator:Play("EffectPlayerListLeave")
end

function CardIndexPageView:SetSelectDetail(cardIndexModel)
    local isSelected = false
    if cardIndexModel then
        local selectPos = cardIndexModel:GetSelectPos()
        local selectQuality = cardIndexModel:GetSelectQuality()
        local selectName = cardIndexModel:GetSeletName()
        local selectNationality = cardIndexModel:GetSeletNationality()
        local selectSkill = cardIndexModel:GetSeletSkill()

        if selectPos and next(selectPos) then
            isSelected = true
        end
        if selectQuality and next(selectQuality) then
            isSelected = true
        end
        if selectSkill and next(selectSkill) then
            isSelected = true
        end
        if selectName ~= "" or selectNationality ~= "" then
            isSelected = true
        end
    end
    self.posText.text = isSelected and lang.trans("pos_be_selected_title") or lang.trans("cardIndex_select")
end

return CardIndexPageView
