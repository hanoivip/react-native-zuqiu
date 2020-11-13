local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Timer = require("ui.common.Timer")

local TransportDetailResultView = class(unity.base)

function TransportDetailResultView:ctor()
    self.selfLogoImg = self.___ex.selfLogoImg
    self.nameTxt = self.___ex.nameTxt
    self.serverTxt = self.___ex.serverTxt
    self.lvlTxt = self.___ex.lvlTxt
    self.powerTxt = self.___ex.powerTxt
    self.detailBtn = self.___ex.detailBtn
    self.vipLvlTxt = self.___ex.vipLvlTxt
    self.sponsorImg = self.___ex.sponsorImg
    self.normalRobberyTimeTxt = self.___ex.normalRobberyTimeTxt
    self.specialRobberyTimeTxt = self.___ex.specialRobberyTimeTxt
    self.vipAreaRect = self.___ex.vipAreaRect

    self.protectLogoImg = self.___ex.protectLogoImg
    self.protectNameTxt = self.___ex.protectNameTxt
    self.protectServerTxt = self.___ex.protectServerTxt
    self.protectPowerTxt = self.___ex.protectPowerTxt
    self.protectDetailBtn = self.___ex.protectDetailBtn

    self.normalRect = self.___ex.normalRect
    self.specialRect = self.___ex.specialRect
    self.normalCountTxt = self.___ex.normalCountTxt
    self.specialCountTxt = self.___ex.specialCountTxt

    self.tipNormalRect = self.___ex.tipNormalRect
    self.tipSpecialRect = self.___ex.tipSpecialRect
    self.tipNormalCountTxt = self.___ex.tipNormalCountTxt
    self.tipSpecialCountTxt = self.___ex.tipSpecialCountTxt

    self.specialTip = self.___ex.specialTip

    self.resultScroll = self.___ex.resultScroll

    self.robberyBtn = self.___ex.robberyBtn
    self.closeBtn = self.___ex.closeBtn

    self.haveProtection = self.___ex.haveProtection
    self.notHaveProtection = self.___ex.notHaveProtection

    self.content = self.___ex.content

    DialogAnimation.Appear(self.transform, nil)
end

function TransportDetailResultView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.robberyBtn:regOnButtonClick(function ()
        if self.onRobberyBtnClick then
            self.onRobberyBtnClick()
        end
    end)
    self.detailBtn:regOnButtonClick(function ()
        if self.onDetailBtnClick then
            self.onDetailBtnClick()
        end
    end)
end

function TransportDetailResultView:InitView(model)
    self.model = model
    self:InitCommon()
    self:InitReward()
    self:InitResultScroll()
    self:InitGuardContent()
end

function TransportDetailResultView:InitGuardContent()
    local isHaveGuard = self.model:GetIsHaveGuard()
    GameObjectHelper.FastSetActive(self.haveProtection, isHaveGuard)
    GameObjectHelper.FastSetActive(self.notHaveProtection, not isHaveGuard)

    if isHaveGuard then
        TeamLogoCtrl.BuildTeamLogo(self.protectLogoImg, self.model:GetGuardLogo())
        self.protectNameTxt.text = self.model:GetGuardName()
        self.protectPowerTxt.text = tostring(self.model:GetGuardPower())
        self.protectDetailBtn:regOnButtonClick(function ()
            if self.onProtecDetailBtnClick then
                self.onProtecDetailBtnClick()
            end
        end)
    end
end

function TransportDetailResultView:InitResultScroll()
    local matchData = self.model:GetRobberyHistoryData()
    self.resultScroll:InitView(matchData)
end

function TransportDetailResultView:InitCommon()
    TeamLogoCtrl.BuildTeamLogo(self.selfLogoImg, self.model:GetLogo())
    GameObjectHelper.FastSetActive(self.selfLogoImg.gameObject, true)
    self.nameTxt.text = self.model:GetName()
    self.serverTxt.text = self.model:GetServer()
    self.lvlTxt.text = "Lv" .. self.model:GetLvl()
    self.powerTxt.text = tostring(self.model:GetPower())
    local vipLevel = self.model:GetVipLvl()
    self.vipLvlTxt.text = tostring(vipLevel)
    local vipRectPosX = tonumber(vipLevel) > 9 and 270 or 275
    self.vipAreaRect.anchoredPosition = Vector2(vipRectPosX, 0)
    self.sponsorImg.overrideSprite = AssetFinder.GetSponsorIcon(self.model:GetSponsorId())
    GameObjectHelper.FastSetActive(self.sponsorImg.gameObject, true)
    self.specialTip.text = lang.trans("transport_history_tip_1", self.model:GetTipSpecialProbability())

    self.normalRobberyTimeTxt.text = lang.trans("transport_robbery_time", self.model:GetRobberyRewardTimes(), self.model:GetMaxBaseRewardRobberyTimes())
    self.specialRobberyTimeTxt.text = lang.trans("transport_robbery_time", self.model:GetRobberySpecialRewardTimes(), self.model:GetMaxSpecialRewardRobberyTimes())
    self.specialRobberyTimeTxt.fontSize = 14
	if not self.model:GetSpecialReward() then
        self.specialRobberyTimeTxt.text = ""
		self.specialRobberyTimeTxt.fontSize = 18
    end
end

function TransportDetailResultView:InitReward()
    local num
    local baseReward = self.model:GetBaseReward()
    for k, v in pairs(baseReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.normalCountTxt.text = "x" .. string.formatNumWithUnit(num)
	self.normalCountTxt.fontSize = 18
    local robberyBaseCount = self.model:GetRobberyBaseCount()
    if robberyBaseCount and robberyBaseCount ~= 0 then
        self.normalCountTxt.text = lang.trans("transfort_general_sponsor_count", string.formatNumWithUnit(num), string.formatNumWithUnit(robberyBaseCount))
		self.normalCountTxt.fontSize = 14
	end

    -- 基础奖励
    res.ClearChildren(self.normalRect)
    local rewardParams = {
        parentObj = self.normalRect,
        rewardData = baseReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)

    -- 提示条上的显示
    local rewardParams = {
        parentObj = self.tipNormalRect,
        rewardData = baseReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
    local percent = self.model:GetTipBaseRewardPercent()
    self.tipNormalCountTxt.text = "x" .. string.formatNumWithUnit(num * percent)

    -- 特殊奖励
    res.ClearChildren(self.specialRect)
    local specialReward = self.model:GetSpecialReward()
    if not specialReward then
        self.specialTip.text = ""
        return
    end

    local num
    for k, v in pairs(specialReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.specialCountTxt.text = "x" .. num
    local robberySpecialCount = self.model:GetRobberySpecialCount()
    if robberySpecialCount and robberySpecialCount ~= 0 then
        self.specialCountTxt.text = lang.trans("transfort_general_sponsor_count", num, robberySpecialCount)
    end

    local rewardParams = {
        parentObj = self.specialRect,
        rewardData = specialReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)

    local tipSpecialRewardCount = self.model:GetTipSpecialRewardCount()
    if not tipSpecialRewardCount then
        self.tipSpecialCountTxt.text = ""
        self.specialTip.text = ""
        res.ClearChildren(self.tipSpecialRect)
        return
    end

    self.tipSpecialCountTxt.text = "x" .. tipSpecialRewardCount
    res.ClearChildren(self.tipSpecialRect)
    rewardParams = {
        parentObj = self.tipSpecialRect,
        rewardData = specialReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function TransportDetailResultView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function TransportDetailResultView:CloseImmediate()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function TransportDetailResultView:OnEnterScene()

end

function TransportDetailResultView:OnExitScene()
end

function TransportDetailResultView:onDestroy()

end



return TransportDetailResultView