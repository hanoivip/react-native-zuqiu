local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamLeagueInfoBarView = class(DynamicLoaded)

function DreamLeagueInfoBarView:ctor()
    self.btnBack = self.___ex.btnBack
    self.dlPiece = self.___ex.dlPiece
    self.dlCoin = self.___ex.dlCoin
end

function DreamLeagueInfoBarView:start()
    -- self:RegModelHandler()
end

function DreamLeagueInfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
end

function DreamLeagueInfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function DreamLeagueInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function DreamLeagueInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function DreamLeagueInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        gold = tonumber(playerInfoModel:GetMoney()),
        diamond = tonumber(playerInfoModel:GetDiamond())
    }
    self:UpdateInfo(info)
end

function DreamLeagueInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")

    if info.diamond then
        self.dlPiece.text = string.formatNumWithUnit(info.diamond)
    end
    if info.gold then
        self.dlCoin.text = string.formatNumWithUnit(info.gold)
    end
end

function DreamLeagueInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return DreamLeagueInfoBarView

