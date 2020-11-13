local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local AuctionHallItemView = class(unity.base, "AuctionHallItemView")

function AuctionHallItemView:ctor()
    self.txt = self.___ex.txt
    self.choosed = self.___ex.choosed
end

function AuctionHallItemView:InitView(data)
    local time = string.formatTimestampAllWithDot(data.time)
    local serverName = tostring(data.serverName)
    local name = tostring(data.name)
    local money = string.formatNumWithUnit(data.money)
    self.txt.text = lang.trans("auction_hall_record_list", time, serverName, name, money)
    local pid = PlayerInfoModel.new():GetID()
    GameObjectHelper.FastSetActive(self.choosed.gameObject, data.pid == pid)
end

return AuctionHallItemView