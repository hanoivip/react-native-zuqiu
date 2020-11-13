local AssetFinder = require("ui.common.AssetFinder")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local Timer = require("ui.common.Timer")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")

local TransportJournalMatchProtectRecordItemView = class(unity.base)

function TransportJournalMatchProtectRecordItemView:ctor()
    self.receiveBtn = self.___ex.receiveBtn
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

function TransportJournalMatchProtectRecordItemView:start()
    self.detailBtn:regOnButtonClick(function ()
        if self.onDetailBtnClick then
            self.onDetailBtnClick()
        end
    end)
    self.receiveBtn:regOnButtonClick(function ()
        if self.onReveiveBtnClick then
            self.onReveiveBtnClick()
        end
    end)
end

function TransportJournalMatchProtectRecordItemView:InitView(data)
    TeamLogoCtrl.BuildTeamLogo(self.logoImg, data.logo)
    self.nameTxt.text = data.name
    self.powerTxt.text = tostring(data.power)
    self.serverTxt.text = data.serverName

    self.gradientText.enabled = not data.status
    self.buttonComponent.interactable = not data.status
    self.receiveBtn:onPointEventHandle(not data.status)

    local r, g, b 
    if not data.status then 
        r, g, b = 145, 125, 86
        self.buttonTxt.text = lang.trans("mail_collectRewards")
    else
        r, g, b = 125, 125, 125
        self.buttonTxt.text = lang.trans("have_received")
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.buttonTxt.color = color

    self:InitRewardContent(data)
end

function TransportJournalMatchProtectRecordItemView:InitRewardContent(data)
    if not data.reward then 
        self.normalCountTxt.text = lang.trans("none")
        self.specialCountTxt.text = lang.trans("none")
        return
    end
    local num
    for k, v in pairs(data.reward.baseReward.contents) do
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
        rewardData = data.reward.baseReward.contents,
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
    if not data.reward.specialReward then
        self.specialCountTxt.text = lang.trans("none")
        return
    end

    local num
    for k, v in pairs(data.reward.specialReward.contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.specialCountTxt.text = "x" .. num

    local rewardParams = {
        parentObj = self.specialRect,
        rewardData = data.reward.specialReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function TransportJournalMatchProtectRecordItemView:onDestroy()

end

return TransportJournalMatchProtectRecordItemView