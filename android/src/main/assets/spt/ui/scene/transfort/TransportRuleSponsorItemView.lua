local AssetFinder = require("ui.common.AssetFinder")
local SponsorBaseReward = require("data.SponsorBaseReward")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local TransportRuleSponsorItemView = class(unity.base)

function TransportRuleSponsorItemView:ctor()
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.name1Txt = self.___ex.name1Txt
    self.normalRect = self.___ex.normalRect
    self.normalDescTxt = self.___ex.normalDescTxt
    self.specialRect = self.___ex.specialRect
    self.specialDescTxt = self.___ex.specialDescTxt
    self.allDescTxt = self.___ex.allDescTxt
    self.sponsorDescTxt = self.___ex.sponsorDescTxt
    self.noSpecial = self.___ex.noSpecial
end

function TransportRuleSponsorItemView:start()
end

function TransportRuleSponsorItemView:InitView(data)
    self.nameTxt.text = lang.trans("transport_lvl_sponsor", data.quality, data.sponsorName)
    self.name1Txt.text = data.sponsorName
    self.logoImg.overrideSprite = AssetFinder.GetSponsorIcon(data.picIndex)
    self.sponsorDescTxt.text = data.desc
    self.normalDescTxt.text = data.descBaseSteal
    self.specialDescTxt.text = data.descSpecialSteal
    self.allDescTxt.text = data.descNum

    -- 基础奖励
    res.ClearChildren(self.normalRect)
    for k, v in pairs(data.baseReward) do
        local rewardParams = {
            parentObj = self.normalRect,
            rewardData = SponsorBaseReward[tostring(k)].contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end

    if type(data.specialReward) ~= "table" then
        return
    end
    self.specialRect.transform.parent.gameObject:SetActive(true)
    self.noSpecial:SetActive(false)
    -- 特殊奖励
    res.ClearChildren(self.specialRect)
    for k, v in pairs(data.specialReward) do
        local rewardParams = {
            parentObj = self.specialRect,
            rewardData = SponsorBaseReward[tostring(k)].contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function TransportRuleSponsorItemView:onDestroy()

end

return TransportRuleSponsorItemView
