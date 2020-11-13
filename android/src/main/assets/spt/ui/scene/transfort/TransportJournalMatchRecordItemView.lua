local AssetFinder = require("ui.common.AssetFinder")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local Timer = require("ui.common.Timer")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local TransportInvitationItemView = class(unity.base)

function TransportInvitationItemView:ctor()
    self.signBtn = self.___ex.signBtn
    self.detailBtn = self.___ex.detailBtn
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.serverTxt = self.___ex.serverTxt
    self.powerTxt = self.___ex.powerTxt
    self.sponsorLogoImg = self.___ex.sponsorLogoImg
    self.scoreTxt = self.___ex.scoreTxt
    self.allScoreTxt = self.___ex.allScoreTxt
    self.normalRect = self.___ex.normalRect
    self.normalCountTxt = self.___ex.normalCountTxt
    self.specialRect =self.___ex.specialRect
    self.specialCountTxt = self.___ex.specialCountTxt
    self.buttonComponent = self.___ex.buttonComponent
    self.gradientText = self.___ex.gradientText
    self.buttonTxt = self.___ex.buttonTxt
end

function TransportInvitationItemView:start()
    self.detailBtn:regOnButtonClick(function ()
        if self.onDetailBtnClick then
            self.onDetailBtnClick()
        end
    end)
    self.signBtn:regOnButtonClick(function ()
        if self.onSigntBtnClick then
            self.onSigntBtnClick()
        end
    end)
end

function TransportInvitationItemView:InitView(data)
    TeamLogoCtrl.BuildTeamLogo(self.logoImg, data.logo)
    self.nameTxt.text = data.name
    self.powerTxt.text = tostring(data.power)
    self.serverTxt.text = data.serverName
    if data.expressGuardScore or data.expressScore then
        if data.expressGuardScore then
            self.scoreTxt.text = (data.expressGuardScore or 0) .. ":" .. (data.robberyGuardScore or 0) .. "/" .. data.expressScore .. ":" .. data.robberyScore
        else
            self.scoreTxt.text = data.expressScore .. ":" .. data.robberyScore
        end
        self.allScoreTxt.text = ((data.expressGuardScore or 0) + (data.expressScore or 0)) .. ":" .. ((data.robberyGuardScore or 0) + (data.robberyScore or 0))
    end
    self.gradientText.enabled = not data.markStatus
    self.buttonComponent.interactable = not data.markStatus
    self.signBtn:onPointEventHandle(not data.markStatus)
    
    local r, g, b 
    if not data.markStatus then 
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.buttonTxt.color = color

    self:InitRewardContent(data)
end

function TransportInvitationItemView:InitRewardContent(data)
    if not data.robberyReward then 
        self.normalCountTxt.text = lang.trans("none")
        self.specialCountTxt.text = lang.trans("none")
        res.ClearChildren(self.normalRect)
        res.ClearChildren(self.specialRect)
        return 
    end
    local num
    for k, v in pairs(data.robberyReward.baseReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.normalCountTxt.text = "x" .. string.formatNumWithUnit(num)

    -- 基础奖励
    res.ClearChildren(self.normalRect)
    local rewardParams = {
        parentObj = self.normalRect,
        rewardData = data.robberyReward.baseReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)

    -- 特殊奖励
    res.ClearChildren(self.specialRect)
    if not data.robberyReward.specialReward then
        self.specialCountTxt.text = lang.trans("none")
        return
    end

    local num
    for k, v in pairs(data.robberyReward.specialReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.specialCountTxt.text = "x" .. num

    local rewardParams = {
        parentObj = self.specialRect,
        rewardData = data.robberyReward.specialReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function TransportInvitationItemView:onDestroy()

end

return TransportInvitationItemView