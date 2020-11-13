local Item = require("data.Item")
local ItemContent = require("data.ItemContent")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local GuildMistVoteItemView = class(unity.base)

function GuildMistVoteItemView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.mainIconImg = self.___ex.mainIconImg
    self.timeTxt = self.___ex.timeTxt
    self.donateBtn = self.___ex.donateBtn
    self.currencyImg = self.___ex.currencyImg
    self.priceTxt = self.___ex.priceTxt
    self.rewardTxt = self.___ex.rewardTxt
    self.rewardTrans = self.___ex.rewardTrans
--------End_Auto_Generate----------
end

function GuildMistVoteItemView:start()
    self.donateBtn:regOnButtonClick(function()
        self.applyVote(self.id)
    end)
end

function GuildMistVoteItemView:InitView(voteData, applyVote)
    self.id = voteData.id
    self.applyVote = applyVote
    local startStr = string.formatTimestampNoYear(voteData.beginTime)
    local endStr = string.formatTimestampNoYear(voteData.endTime)
    local priceType = voteData.priceType
    local mainImgPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildMistWar/VoteLevel_%s.png"
    mainImgPath = string.format(mainImgPath, self.id)
    self.titleTxt.text = voteData.name

    local price = voteData.price
    if priceType == CurrencyType.Money then
        price = string.formatIntWithTenThousands(price)
    end
    self.priceTxt.text = "x" .. price
    self.timeTxt.text = lang.trans("time_last", startStr, endStr)
    self.rewardTxt.text = lang.trans("mist_vote_add", voteData.gc)
    self.rewardTxt.text = voteData.desc
    self.currencyImg.overrideSprite = res.LoadRes(CurrencyImagePath[priceType])
    self.mainIconImg.overrideSprite = res.LoadRes(mainImgPath)
    self.mainIconImg:SetNativeSize()
    GameObjectHelper.FastSetActive(self.timeTxt.gameObject, voteData.endTime > 0)

    local rewardId = tostring(voteData.reward.id)
    local contents = Item[rewardId].itemContent
    local reward = {}
    for i, v in pairs(contents) do
        local t = ItemContent[v].contents
        table.insert(reward, t)
    end
    res.ClearChildren(self.rewardTrans)
    for i, v in pairs(reward) do
        local rewardParams = {
            parentObj = self.rewardTrans,
            rewardData = v,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

return GuildMistVoteItemView
