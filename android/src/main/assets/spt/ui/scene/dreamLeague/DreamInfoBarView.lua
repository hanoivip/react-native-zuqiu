local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamInfoBarView = class()

function DreamInfoBarView:ctor()
    self.txtDreamCoin = self.___ex.txtDreamCoin
    self.txtDreamPiece = self.___ex.txtDreamPiece
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDreamCoin = self.___ex.btnDreamCoin
    self.btnDreamPiece = self.___ex.btnDreamPiece
    self.btnBack = self.___ex.btnBack
end

function DreamInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
    self.playerInfoModel = PlayerInfoModel.new()
    self:EventPlayerInfo(self.playerInfoModel)
end

function DreamInfoBarView:RegViewEvent()
    self.btnDreamCoin:regOnButtonClick(function()
        self:OnBtnDreamCoinClick()
    end)
    self.btnDreamPiece:regOnButtonClick(function()
        self:OnBtnDreamPieceClick()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
end

function DreamInfoBarView:OnBtnDreamCoinClick()

end

function DreamInfoBarView:OnBtnDreamPieceClick()

end

function DreamInfoBarView:OnBtnBackClick()
    res.PopSceneImmediate()
end

-- function DreamInfoBarView:ShowLuckyArea(isShow)
--     GameObjectHelper.FastSetActive(self.luckyArea, isShow)
-- end

function DreamInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function DreamInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function DreamInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        dc = tonumber(playerInfoModel:GetDreamCoin()),
        dp = tonumber(playerInfoModel:GetDreamPiece()),
    }
    self:UpdateInfo(info)
end
function DreamInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")

    if info.dc then
        self.txtDreamCoin.text = tostring(info.dc)
    end
    if info.dp then
        self.txtDreamPiece.text = tostring(info.dp)
    end
end

function DreamInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return DreamInfoBarView

