local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")

local AuctionMainItemView = class(unity.base, "AuctionMainItemView")

function AuctionMainItemView:ctor()
    self.itemArea = self.___ex.itemArea
    self.imgSold = self.___ex.imgSold
    self.imgClosed = self.___ex.imgClosed
    self.imgSuccess = self.___ex.imgSuccess
    self.gridLayout = self.___ex.gridLayout
    self.txtSold = self.___ex.txtSold
end

function AuctionMainItemView:InitView(data)
    GameObjectHelper.FastSetActive(self.imgSold.gameObject, false)
    GameObjectHelper.FastSetActive(self.imgClosed.gameObject, false)
    GameObjectHelper.FastSetActive(self.imgSuccess.gameObject, false)

    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = data.content,
        isShowName = false,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    if data.scrollItemType then
        local step = data.step
        if data.scrollItemType == AuctionMainConstants.AuctionHall then -- 竞拍大厅界面
            if step == AuctionMainConstants.AuctionStep.FINISH then -- 已结束，显示已售出
                GameObjectHelper.FastSetActive(self.imgSold.gameObject, true)
            end
        elseif data.scrollItemType == AuctionMainConstants.History then -- 历史数据界面
            if step == AuctionMainConstants.AuctionStep.FINISH then -- 已结束，显示售出对象
                if data.isSuccess then
                    GameObjectHelper.FastSetActive(self.imgSuccess.gameObject, true)
                else
                    GameObjectHelper.FastSetActive(self.imgClosed.gameObject, true)
                end
            end
        end
    end

    if data.isSold then
        self.txtSold.text = lang.trans("auction_main_history_sold")
    else
        self.txtSold.text = lang.trans("auction_main_history_failed")
    end
end

function AuctionMainItemView:SetItemSize(x, y)
    self.gridLayout.cellSize = Vector2(x, y)
end

return AuctionMainItemView