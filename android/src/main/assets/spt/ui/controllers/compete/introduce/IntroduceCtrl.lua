local BaseCtrl = require("ui.controllers.BaseCtrl")
local IntroduceModel = require("ui.models.compete.introduce.IntroduceModel")
local IntroduceConstants = require("ui.models.compete.introduce.IntroduceConstants")

local IntroduceCtrl = class(BaseCtrl)

IntroduceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Introduce/Introduce.prefab"

function IntroduceCtrl:Init()
    self.view:InitView(IntroduceModel.new())
    self.view:RegOnMenuGroup(IntroduceConstants.PROCESS_DESC, function ()
        self:SwitchMenu(IntroduceConstants.PROCESS_DESC)
    end)
    self.view:RegOnMenuGroup(IntroduceConstants.DISTRICT_LEAGUE_DESC, function ()
        self:SwitchMenu(IntroduceConstants.DISTRICT_LEAGUE_DESC)
    end)
    self.view:RegOnMenuGroup(IntroduceConstants.CROSS_DISTRICT_DESC, function ()
        self:SwitchMenu(IntroduceConstants.CROSS_DISTRICT_DESC)
    end)
    self.view:RegOnMenuGroup(IntroduceConstants.COMPETE_REWARD, function ()
        self:SwitchMenu(IntroduceConstants.COMPETE_REWARD, nil)
    end)
    self.view:RegOnMenuGroup(IntroduceConstants.PLAYING_DESC, function ()
        self:SwitchMenu(IntroduceConstants.PLAYING_DESC)
    end)
    self.view:RegOnMenuGroup(IntroduceConstants.IDENTIFIER_DESC, function ()
        self:SwitchMenu(IntroduceConstants.IDENTIFIER_DESC)
    end)
    self.view:RegOnMenuGroup(IntroduceConstants.REWARD_TYPE_DESC, function ()
        self:SwitchMenu(IntroduceConstants.REWARD_TYPE_DESC)
    end)
end

function IntroduceCtrl:Refresh()
    IntroduceCtrl.super.Refresh(self)
    self:SwitchMenu(IntroduceConstants.PROCESS_DESC)
end

function IntroduceCtrl:SwitchMenu(tag, rewardLabelTag)
    if tag == IntroduceConstants.PROCESS_DESC then
        self.view:InitProcessDescView()
    elseif tag == IntroduceConstants.DISTRICT_LEAGUE_DESC then
        self.view:InitDistrictDescView()
    elseif tag == IntroduceConstants.CROSS_DISTRICT_DESC then
        self.view:InitCrossDisView()
    elseif tag == IntroduceConstants.COMPETE_REWARD then
        self.view:InitCompeteRewardView()
        self.rewardLabelTab = IntroduceModel:GetLeagueTags()-------------------get data here
        self.view:InitRewardView()
        self.view:ClearAllRewardLabels()
        self.view:InitRewardMenuLabelTab(self.rewardLabelTab, function(labelTag)
            self:OnClickRewardMenuLabel(labelTag)
        end)
        if (not rewardLabelTag or not IsInTable(rewardLabelTag, self.rewardLabelTab)) and #self.rewardLabelTab >= 1 then
            rewardLabelTag = self.rewardLabelTab[1]
        end
        self.view.rewardMenuGroup:selectMenuItem(rewardLabelTag)
        self:OnClickRewardMenuLabel(rewardLabelTag)
    elseif tag == IntroduceConstants.PLAYING_DESC then
        self.view:InitPlayingDescView()
    elseif tag == IntroduceConstants.IDENTIFIER_DESC then
        self.view:InitIdentfDescView()
    elseif tag == IntroduceConstants.REWARD_TYPE_DESC then
        self.view:InitRewardTypeView()
    end
end

function  IntroduceCtrl:OnClickRewardMenuLabel(tag)
    self.view:OnClickRewardMenuLabel(tag)
end

return IntroduceCtrl