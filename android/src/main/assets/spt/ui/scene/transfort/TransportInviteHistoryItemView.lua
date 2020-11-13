local AssetFinder = require("ui.common.AssetFinder")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local Timer = require("ui.common.Timer")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local TransportInvitationItemView = class(unity.base)

function TransportInvitationItemView:ctor()
    self.acceptBtn = self.___ex.acceptBtn
    self.detailBtn = self.___ex.detailBtn
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.serverTxt = self.___ex.serverTxt
    self.powerTxt = self.___ex.powerTxt
    self.sponsorLogoImg = self.___ex.sponsorLogoImg
    self.normalCountTxt = self.___ex.normalCountTxt
    self.normalRect = self.___ex.normalRect
    self.specialRect = self.___ex.specialRect
    self.specialCountTxt = self.___ex.specialCountTxt
end

function TransportInvitationItemView:start()
    self.detailBtn:regOnButtonClick(function ()
        if self.onDetailBtnClick then
            self.onDetailBtnClick()
        end
    end)
    self.acceptBtn:regOnButtonClick(function ()
        if self.onAcceptBtnClick then
            self.onAcceptBtnClick()
        end
    end)
end

function TransportInvitationItemView:InitView(data)
    TeamLogoCtrl.BuildTeamLogo(self.logoImg, data.logo)
    self.nameTxt.text = data.name
    self.powerTxt.text = tostring(data.power)
    self.sponsorLogoImg.overrideSprite = AssetFinder.GetSponsorIcon(data.sponsorId)
    self.serverTxt.text = data.serverName
    self:InitReward(data)
end

function TransportInvitationItemView:InitReward(data)
    local num
    for k, v in pairs(data.baseReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.normalCountTxt.text = "x" .. num

    -- 基础奖励
    res.ClearChildren(self.normalRect)
    local rewardParams = {
        parentObj = self.normalRect,
        rewardData = data.baseReward.contents,
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
    if not data.specialReward then
        return
    end

    local num
    for k, v in pairs(data.specialReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.specialCountTxt.text = "x" .. num

    local rewardParams = {
        parentObj = self.specialRect,
        rewardData = data.specialReward.contents,
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