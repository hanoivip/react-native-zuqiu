-- local AuctionMainConstants = require("ui.models.auction.main.AuctionMainConstants")
local AuctionMainConstants = {}

AuctionMainConstants.AuctionHall = "hall"
AuctionMainConstants.History = "history"

AuctionMainConstants.AuctionStep = {
    NOT_START = 0,
    STEP_1 = 1,
    STEP_2 = 2,
    STEP_3 = 3,
    STEP_4 = 4,
    FINISH = 5
}

AuctionMainConstants.AuctionMain_NoPreNotice = 0 -- 未来24小时没有拍卖发送值

AuctionMainConstants.BidCooldown = 1 -- 竞拍按钮冷却时间

AuctionMainConstants.refreshCooldown = 5 -- 刷新按钮冷却时间

AuctionMainConstants.AuctionMain_PassiveRefreshDuration = 30 -- 主界面静默刷新间隔

AuctionMainConstants.AuctionHall_PassiveRefreshDuration = 30 -- 竞拍界面静默刷新间隔

AuctionMainConstants.AuctionHall_PassiveRefreshDuration_core = 5 -- 竞拍界面最后一分钟静默刷新间隔

AuctionMainConstants.AuctionHall_RecordMaxNum = 20 -- 竞拍界面记录数目

AuctionMainConstants.AuctionRank_NotOnList = 0 -- 未上榜服务器发送值

AuctionMainConstants.Auction_Step4_Core_Time = 60 -- 最后阶段重置时间

return AuctionMainConstants