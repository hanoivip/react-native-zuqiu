local FriendsInviteMenuType = require("ui.models.friends.FriendsInviteMenuType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local FriendsInviteScrollItemModel = require("ui.models.friends.friendsInvite.FriendsInviteScrollItemModel")

local FriendsInviteBoardView = class(unity.base)

local FriendsInviteMenuMap = {
    [FriendsInviteMenuType.DIAMOND_RETURN] = "diaReturnReward",
    [FriendsInviteMenuType.FRIENDS_NUM] = "friendsNumReward",
    [FriendsInviteMenuType.FRIENDS_LVL] = "friendsLvlReward",
    [FriendsInviteMenuType.FRIENDS_CHARGE] = "friendsChargeReward",
}

function FriendsInviteBoardView:ctor()
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.otherThreeScrollView = self.___ex.otherThreeScrollView
    self.diamondShowTipTxt = self.___ex.diamondShowTipTxt
    self.noInvitedDiaShow = self.___ex.noInvitedDiaShow
    self.diamondReturnObj = self.___ex.diamondReturnObj
    self.otherThreeAreaObj = self.___ex.otherThreeAreaObj
    self.diamondReturnScrollView = self.___ex.diamondReturnScrollView
    self.diamondReturnScrollObj = self.___ex.diamondReturnScrollObj
    self.newPlayerTipTxt = self.___ex.newPlayerTipTxt
    self.diaShowTipTxt = self.___ex.diaShowTipTxt
    self.scrollRectDia = self.___ex.scrollRectDia
    self.scrollRectOther = self.___ex.scrollRectOther
    self.myCodeTxt = self.___ex.myCodeTxt
    self.inputCodeAreaObj = self.___ex.inputCodeAreaObj
    self.inputCodeTxt = self.___ex.inputCodeTxt
    self.noInputRewardArea = self.___ex.noInputRewardArea
    self.inputRewardContent = self.___ex.inputRewardContent
    self.noInputRewardContent = self.___ex.noInputRewardContent
    self.btnRecord = self.___ex.btnRecord
    self.btnSubmit = self.___ex.btnSubmit
    self.inputCodeTxt = self.___ex.inputCodeTxt
    self.diaRtnScrollContentRect = self.___ex.diaRtnScrollContentRect

    self.scrollItemType = {
        diamond = "Dia",
        other = "Other",
    }
end

function FriendsInviteBoardView:start()
    self.btnRecord:regOnButtonClick(function()
        if type(self.clickBtnRecord) == "function" then
            self.clickBtnRecord()
        end
    end)
    self.btnSubmit:regOnButtonClick(function()
        if type(self.clickBtnSubmit) == "function" then
            self.clickBtnSubmit()
        end
    end)

    tabMenuCount = table.nums(FriendsInviteMenuMap)
    for i = 1, tabMenuCount do
        local tag = FriendsInviteMenuMap[i]
        self.menuButtonGroup:BindMenuItem(tag, function()
            self:OnMenuClick(i)
        end)
        self.menuButtonGroup.menu[tag]:Init(nil, tag)
    end

    self:RefreshTabMenuRedPoints()
end

function FriendsInviteBoardView:InitView(model)
    self.friendsInviteModel = model
    self.friendsInviteModel:SetMenuTypeToTabTagMap(FriendsInviteMenuMap)
    local menuType = model:GetCurrentMenu()

    self.myCodeTxt.text = self.friendsInviteModel:GetMyInvitationCode()
    self.menuButtonGroup:selectMenuItem(FriendsInviteMenuMap[menuType])
    self:InitNewPlayerRewardArea()
    self:CreateDiamondReturnRewardScroll()
    self:OnMenuClick(menuType)
    self:RefreshTabMenuRedPoints()
end

function FriendsInviteBoardView:InitNewPlayerRewardArea()
    self.diaShowTipTxt.text = self.friendsInviteModel:GetReturnDiamondTip()

    local isShowInput = self.friendsInviteModel:IsShowInputCodeView()
    self.newPlayerTipTxt.text = self.friendsInviteModel:GetNewPlayerRewardTip(isShowInput)
    self:ShowOrHideInputCodeArea(isShowInput)
    if isShowInput then
        self:InitNewPlayerRewardContent(self.inputRewardContent)
    else
        self:InitNewPlayerRewardContent(self.noInputRewardContent)
    end
end

function FriendsInviteBoardView:InitNewPlayerRewardContent(parentScrollRect)
    res.ClearChildren(parentScrollRect)
    local rewardParams = {
        parentObj = parentScrollRect,
        rewardData = self.friendsInviteModel:GetNewPlayerReward(),
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

function FriendsInviteBoardView:ShowOrHideInputCodeArea(isShowInput)
    GameObjectHelper.FastSetActive(self.inputCodeAreaObj, isShowInput)
    GameObjectHelper.FastSetActive(self.noInputRewardArea, not isShowInput)
end

function FriendsInviteBoardView:RefreshTabMenuRedPoints()
    for k, v in pairs(FriendsInviteMenuType) do
        local isShowRedPoint = self.friendsInviteModel:HasRewardNotCollected(v)
        local menuTag = FriendsInviteMenuMap[v]
        EventSystem.SendEvent("TabItem_RefreshRedPoint", menuTag, isShowRedPoint)
    end 
end

function FriendsInviteBoardView:CreateDiamondReturnRewardScroll()
    local isPlayerHasInvited = self.friendsInviteModel:HasPlayerBeenInvited()
    GameObjectHelper.FastSetActive(self.diamondReturnScrollObj, isPlayerHasInvited)
    GameObjectHelper.FastSetActive(self.noInvitedDiaShow, not isPlayerHasInvited)
    if isPlayerHasInvited then
        self:RefreshRewardScroll(self.diamondReturnScrollView, self.scrollItemType.diamond)
    end
end

function FriendsInviteBoardView:RefreshRewardScroll(scrollView, scrollItemType)
    local currentMenuType = self.friendsInviteModel:GetCurrentMenu()
    local rewardList = self.friendsInviteModel:GetSelectedRewardList(currentMenuType)
    if scrollItemType == self.scrollItemType.diamond then
        if currentMenuType ~= FriendsInviteMenuType.DIAMOND_RETURN then
            currentMenuType = FriendsInviteMenuType.DIAMOND_RETURN
            rewardList = self.friendsInviteModel:GetSelectedRewardList(currentMenuType)
        end
    end

    scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsInvite/FriendsInvite" .. scrollItemType .. "RewardScrollItem.prefab")
        return obj, spt
    end
    scrollView.onScrollResetItem = function(spt, index)
        local itemData = scrollView.itemDatas[index]
        local itemModel = FriendsInviteScrollItemModel.new(itemData)
        spt:InitView(itemModel, self.friendsInviteModel, self["scrollRect" .. scrollItemType])
        scrollView:updateItemIndex(spt, index)
    end
    scrollView:clearData()
    scrollView:refresh(rewardList)
end

function FriendsInviteBoardView:OnMenuClick(index)
    if type(self.clickMenu) == "function" then
        self.clickMenu(index)
    end
end

function FriendsInviteBoardView:SwitchFriendsInviteTab()
    local menuType = self.friendsInviteModel:GetCurrentMenu()
    if menuType == FriendsInviteMenuType.DIAMOND_RETURN then
        self:ShowOrHideFriendsInviteBoard(true, false)
    else
        self:ShowOrHideFriendsInviteBoard(false, true)
    end
end

function FriendsInviteBoardView:ShowOrHideFriendsInviteBoard(isShowDaimondReturn, isShowOtherThree)
     GameObjectHelper.FastSetActive(self.diamondReturnObj, isShowDaimondReturn)
     GameObjectHelper.FastSetActive(self.otherThreeAreaObj, isShowOtherThree)
end

function FriendsInviteBoardView:EnterScene()
end

function FriendsInviteBoardView:ExitScene()
end

return FriendsInviteBoardView
