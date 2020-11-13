local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems
local CommonConstants = require("ui.common.CommonConstants")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local IntroduceModel = require("ui.models.compete.introduce.IntroduceModel")
local RewardDescModel = require("ui.models.compete.introduce.RewardDescModel")
local IntroduceConstants = require("ui.models.compete.introduce.IntroduceConstants")
local IntroduceView = class(unity.base)

function  IntroduceView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.processContent = self.___ex.processContent
    self.districtContent = self.___ex.districtContent
    self.crossContent = self.___ex.crossContent
    self.rewardContent = self.___ex.rewardContent
    self.playingContent = self.___ex.playingContent
    self.menuOver4 = self.___ex.menuOver4
    self.menuLimit4 = self.___ex.menuLimit4
    self.rewardMenuGroup = self.___ex.rewardMenuGroup
    self.rewardMenuScroll = self.___ex.rewardMenuScroll
    self.scrollToLeft = self.___ex.scrollToLeft
    self.scrollToRight = self.___ex.scrollToRight
    self.rewardAnimator = self.___ex.rewardAnimator
    self.scrollLeftArrowNormal = self.___ex.scrollLeftArrowNormal
    self.scrollLeftArrowHighlight = self.___ex.scrollLeftArrowHighlight
    self.scrollRightArrowNormal = self.___ex.scrollRightArrowNormal
    self.scrollRightArrowHighlight = self.___ex.scrollRightArrowHighlight
    self.rewardScrollerView = self.___ex.rewardScrollerView
    self.rewardContentIcons = self.___ex.rewardContentIcons
    self.rewardProcessDesc = self.___ex.rewardProcessDesc
    self.rewardCrossDesc = self.___ex.rewardCrossDesc
    self.rewardPlayingDesc = self.___ex.rewardPlayingDesc
    self.leagueUpgradeDesc = self.___ex.leagueUpgradeDesc
    self.earCupNumDesc = self.___ex.earCupNumDesc
    self.crossScoreDesc = self.___ex.crossScoreDesc
    self.rewardBoxDesc = self.___ex.rewardBoxDesc
    self.insideReardDesc = self.___ex.insideReardDesc
    self.identifierContent = self.___ex.identifierContent
    self.backButton = self.___ex.backButton
    self.rewardTypeDesc = self.___ex.rewardTypeDesc
    self.rewardTypeContent = self.___ex.rewardTypeContent

    self:InitRewardMenuLabel()

    self.isShowModuleTags = {
        [IntroduceConstants.PROCESS_DESC] = true,
        [IntroduceConstants.DISTRICT_LEAGUE_DESC] = false,
        [IntroduceConstants.CROSS_DISTRICT_DESC] = false, 
        [IntroduceConstants.COMPETE_REWARD] = false,
        [IntroduceConstants.PLAYING_DESC] = false,
        [IntroduceConstants.IDENTIFIER_DESC] = false,
        [IntroduceConstants.REWARD_TYPE_DESC] = false,
    }
end

function IntroduceView:start()
    self.backButton:regOnButtonClick(function()
        res.PopScene()
    end)
end

function IntroduceView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function IntroduceView:InitView(model)
    self.model = model
end

function IntroduceView:InitProcessDescView()
    self.menuGroup:selectMenuItem(IntroduceConstants.PROCESS_DESC)
    self.rewardProcessDesc.text = RewardDescModel:GetProcessDesc()
    self:RefreshShowModuleTags(IntroduceConstants.PROCESS_DESC)
    self:ShowOrHideModulePrefab()
end

function IntroduceView:InitDistrictDescView()
    self.leagueUpgradeDesc.text = RewardDescModel:GetLeagueUpgradeDesc()
    self.earCupNumDesc.text = RewardDescModel:GetEarCupNumDesc()
    self.crossScoreDesc.text = RewardDescModel:GetCrossScoreDesc()
    self:RefreshShowModuleTags(IntroduceConstants.DISTRICT_LEAGUE_DESC)
    self:ShowOrHideModulePrefab()
end

function IntroduceView:InitCrossDisView()
    self.rewardCrossDesc.text = RewardDescModel:GetCrossDesc()
    self:RefreshShowModuleTags(IntroduceConstants.CROSS_DISTRICT_DESC)
    self:ShowOrHideModulePrefab()
end

function IntroduceView:InitCompeteRewardView()
    self.rewardBoxDesc.text = RewardDescModel:GetRewardBoxDesc()
    self:RefreshShowModuleTags(IntroduceConstants.COMPETE_REWARD)
    self:ShowOrHideModulePrefab()
end

function IntroduceView:InitPlayingDescView()
    self.rewardPlayingDesc.text = RewardDescModel:GetPlayingDesc()
    self:RefreshShowModuleTags(IntroduceConstants.PLAYING_DESC)
    self:ShowOrHideModulePrefab()
end

function IntroduceView:InitIdentfDescView()
    self:RefreshShowModuleTags(IntroduceConstants.IDENTIFIER_DESC)
    self:ShowOrHideModulePrefab()
end

function IntroduceView:InitRewardTypeView()
    self.rewardTypeDesc.text = RewardDescModel:GetRewardTypeDesc()
    self:RefreshShowModuleTags(IntroduceConstants.REWARD_TYPE_DESC)
    self:ShowOrHideModulePrefab()
end

function IntroduceView:RefreshShowModuleTags(tagKey)
    for k, v in pairs(self.isShowModuleTags) do
        self.isShowModuleTags[k] = k == tagKey
    end
end

function IntroduceView:ShowOrHideModulePrefab()
    GameObjectHelper.FastSetActive(self.processContent, self.isShowModuleTags[IntroduceConstants.PROCESS_DESC])
    GameObjectHelper.FastSetActive(self.districtContent, self.isShowModuleTags[IntroduceConstants.DISTRICT_LEAGUE_DESC])
    GameObjectHelper.FastSetActive(self.crossContent, self.isShowModuleTags[IntroduceConstants.CROSS_DISTRICT_DESC])
    GameObjectHelper.FastSetActive(self.rewardContent, self.isShowModuleTags[IntroduceConstants.COMPETE_REWARD])
    GameObjectHelper.FastSetActive(self.playingContent, self.isShowModuleTags[IntroduceConstants.PLAYING_DESC])
    GameObjectHelper.FastSetActive(self.identifierContent, self.isShowModuleTags[IntroduceConstants.IDENTIFIER_DESC])
    GameObjectHelper.FastSetActive(self.rewardTypeContent, self.isShowModuleTags[IntroduceConstants.REWARD_TYPE_DESC])
end

function IntroduceView:InitRewardMenuLabel()
    self.rewardMenuScroll:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/Introduce/RewardMenuLabel.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.rewardMenuScroll:regOnItemIndexChanged(function(index)
        if index > 1 then
            GameObjectHelper.FastSetActive(self.scrollLeftArrowNormal, false)
            GameObjectHelper.FastSetActive(self.scrollLeftArrowHighlight, true)
        else
            GameObjectHelper.FastSetActive(self.scrollLeftArrowNormal, true)
            GameObjectHelper.FastSetActive(self.scrollLeftArrowHighlight, false)
        end
        if index <= #self.rewardMenuScroll.itemDatas - 4 then
            GameObjectHelper.FastSetActive(self.scrollRightArrowNormal, false)
            GameObjectHelper.FastSetActive(self.scrollRightArrowHighlight, true)
        else
            GameObjectHelper.FastSetActive(self.scrollRightArrowNormal, true)
            GameObjectHelper.FastSetActive(self.scrollRightArrowHighlight, false)
        end
    end)
    self.scrollToLeft:regOnButtonClick(function()
        self.rewardMenuScroll:scrollToPreviousGroup();
    end)
    self.scrollToRight:regOnButtonClick(function()
        self.rewardMenuScroll:scrollToNextGroup();
    end)
end

function IntroduceView:InitRewardMenuLabelTab(labelTab, clickFunc)
    if type(labelTab) == "table" then
        if #labelTab <= 4 then
            dump("labelTab error!!!")
        else
            GameObjectHelper.FastSetActive(self.menuLimit4.gameObject, false)
            GameObjectHelper.FastSetActive(self.menuOver4, true)
            self.rewardMenuScroll:regOnResetItem(function (scrollSelf, spt, index)
                local tag = scrollSelf.itemDatas[index]
                local title = IntroduceModel:GetLeagueName(tag)
                spt:Init(title, tag)
                self.rewardMenuGroup.menu[tag] = spt
                self.rewardMenuGroup:BindMenuItem(tag, function()
                    clickFunc(tag)
                end)
            end)
            self.rewardMenuScroll:refresh(labelTab)
        end
    end
end

function IntroduceView:InitRewardView()
end

function IntroduceView:ClearAllRewardLabels()
    self.rewardMenuGroup.menu = {}
end

function IntroduceView:OnClickRewardMenuLabel(tag)
    self.rewardContentIcons:InitView(CommonConstants["CompeteRewardId"..tostring(tag)])
    local leagueName = IntroduceModel:GetLeagueName(tag)
    self.insideReardDesc.text = lang.transstr("compete_introduce_reward_desc1", leagueName, leagueName)
    local data = IntroduceModel:GetRewardDataOfTag(tag)
    self.rewardScrollerView:InitView(data)
end

return IntroduceView