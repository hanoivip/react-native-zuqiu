local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AuctionRankItemView = class(unity.base, "AuctionRankItemView")

function AuctionRankItemView:ctor()
    self.txtRank = self.___ex.txtRank
    self.icon = self.___ex.icon
    self.one = self.___ex.one
    self.two = self.___ex.two
    self.three = self.___ex.three
    self.txtName = self.___ex.txtName
    self.txtServerName = self.___ex.txtServerName
    self.txtMoney = self.___ex.txtMoney
end

function AuctionRankItemView:InitView(data)
    self.data = data
    GameObjectHelper.FastSetActive(self.txtRank.gameObject, false)
    GameObjectHelper.FastSetActive(self.one.gameObject, false)
    GameObjectHelper.FastSetActive(self.two.gameObject, false)
    GameObjectHelper.FastSetActive(self.three.gameObject, false)
    if data.index == 1 then
        GameObjectHelper.FastSetActive(self.one.gameObject, true)
    elseif data.index == 2 then
        GameObjectHelper.FastSetActive(self.two.gameObject, true)
    elseif data.index == 3 then
        GameObjectHelper.FastSetActive(self.three.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.txtRank.gameObject, true)
        self.txtRank.text = lang.trans("guildwar_rank", data.index)
    end
    self.txtName.text = data.name
    self.txtServerName.text = data.serverName
    self.txtMoney.text = string.formatNumWithUnit(data.totalMoney)
end

return AuctionRankItemView