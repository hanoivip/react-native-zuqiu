local Object = clr.UnityEngine.Object
local ItemModel = require("ui.models.ItemModel")
local MenuType = require("ui.controllers.itemList.MenuType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardContentBarView = class(unity.base)

function RewardContentBarView:ctor()
    self.bg = self.___ex.bg
    self.contentTrans = self.___ex.contentTrans
    self.giftboxTrans = self.___ex.giftboxTrans
    self.randomTxt = self.___ex.randomTxt
    self.h_lg = self.___ex.h_lg
end

function RewardContentBarView:InitView(itemID, parentTrans)
    res.ClearChildren(self.giftboxTrans)
    self.h_lg.enabled = false
    res.ClearChildren(self.contentTrans.transform)   
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildWar/%s.png"
    local effctPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/Effect%s.prefab"
    local TipMap = {["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 7}
    local quality = string.sub(itemID or "", -1)
    self.bg.overrideSprite = res.LoadRes(format(path, quality))
    if tonumber(quality) < 5 then
        self.randomTxt.gameObject:SetActive(false)
    else
        self.randomTxt.text = lang.trans("guild_desc_" .. TipMap[tostring(quality)])
    end
    local itemModel = ItemModel.new(itemID)
    local rewardData = itemModel:GetItemContent()
    local contents = {}
    contents.item = {}
    local temp = {}
    temp.id = tostring(itemID)
    temp.num = 1
    table.insert(contents.item, temp)

    -- 暂时不开启粒子特效加载（不能正常剪裁）
    if tonumber(quality) ~= 1 then
        local obj = res.Instantiate(format(effctPath, quality))
        obj.transform:SetParent(self.giftboxTrans, false)
    end

    local rewardParams = {
        parentObj = self.giftboxTrans,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = false,
        isShowCardReward = false,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
    
    for k, v in pairs(rewardData) do
        local rewardParams = {
            parentObj = self.contentTrans,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
    self.transform:SetSiblingIndex(1)
    self.randomTxt.transform:SetSiblingIndex(10)
    self:coroutine(function()
        coroutine.yield()
        coroutine.yield()
        self.h_lg.enabled = true
    end)

end

return RewardContentBarView