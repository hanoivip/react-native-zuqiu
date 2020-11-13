local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardScrollerItemModel = require("ui.models.compete.introduce.RewardScrollerItemModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardItemBarView = class(unity.base)

function RewardItemBarView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.txtNormalRank = self.___ex.txtNormalRank
    self.txtHonorPoint = self.___ex.txtHonorPoint
    self.iconAreaTrans1 = self.___ex.iconAreaTrans1
    self.iconAreaTrans2 = self.___ex.iconAreaTrans2
    self.iconAreaTrans3 = self.___ex.iconAreaTrans3
    self.text1 = self.___ex.text1
    self.text2 = self.___ex.text2
    self.text3 = self.___ex.text3
end

function RewardItemBarView:InitView(model)
    model:ParseModelData()
    data = model.data
    if data.rankLow == 1 and data.rankHigh == 1 then
        self:SetRankShowStatus(true, false, false)
    elseif data.rankLow == 2 and data.rankHigh == 2 then
        self:SetRankShowStatus(false, true, false)
    elseif data.rankLow == 3 and data.rankHigh == 3 then
        self:SetRankShowStatus(false, false, true)
    elseif data.rankLow ~= nil then
        self:SetRankShowStatus(false, false, false)
        if data.rankLow ~= data.rankHigh then
            self.txtNormalRank.text = lang.trans("ladder_rewardDetail_rank", tostring(data.rankLow), tostring(data.rankHigh))
        else
            self.txtNormalRank.text = lang.trans("ladder_rank", data.rankLow)
        end
    else
        self:SetRankShowStatus(false, false, false)
        self.txtNormalRank.text = data.leftText
    end

    local rewardIDs, rewardItemNum = model:GetDataItem()
    self:ClearRewardIconsData()
    if #rewardIDs == 2 then
        self:FillOneIconArea(1, rewardIDs[1], rewardItemNum[1])
        self:FillOneIconArea(2, rewardIDs[2], rewardItemNum[2])
        self:SetIconArea3Active(false)
    elseif #rewardIDs == 1 then
        self:SetIconArea3Active(true)
        self:FillOneIconArea(3, rewardIDs[1], rewardItemNum[1])
    else
        dump("unexpected error!!!")
    end
end

function RewardItemBarView:SetIconArea3Active(enabled)
    GameObjectHelper.FastSetActive(self.iconAreaTrans3.gameObject, enabled)
    GameObjectHelper.FastSetActive(self.text3.gameObject, enabled)
end

function RewardItemBarView:FillOneIconArea(index, rewardID, rewardItemNum)
    local contents = {}
    contents.item = {}
    local temp = {}
    temp.id = tostring(rewardID)
    temp.num = 1
    table.insert(contents.item, temp)
    local rewardParams = {
        parentObj = self["iconAreaTrans"..tostring(index)],
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = false,
        isShowCardReward = false,
        isShowDetail = true,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
    self["text"..tostring(index)].text = "X"..tostring(rewardItemNum)
end

function RewardItemBarView:SetRankShowStatus(isFirstRank, isSecondRank, isThirdRank)
    GameObjectHelper.FastSetActive(self.firstRank, isFirstRank)
    GameObjectHelper.FastSetActive(self.secondRank, isSecondRank)
    GameObjectHelper.FastSetActive(self.thirdRank, isThirdRank)
    GameObjectHelper.FastSetActive(self.normalRank, not (isFirstRank or isSecondRank or isThirdRank))
end

function RewardItemBarView:ClearRewardIconsData()
    for i=1,3 do
        res.ClearChildren(self["iconAreaTrans"..tostring(i)])
        self["text"..tostring(i)].text = ""
    end
end

return RewardItemBarView