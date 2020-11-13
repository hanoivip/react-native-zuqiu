local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local FancyStoreBoardView = class(unity.base, "FancyStoreBoardView")

function FancyStoreBoardView:ctor()
--------Start_Auto_Generate--------
    self.residualTimerTxt = self.___ex.residualTimerTxt
    self.fsTxt = self.___ex.fsTxt
    self.fancyPieceTxt = self.___ex.fancyPieceTxt
    self.noGoodsGo = self.___ex.noGoodsGo
    self.scrollViewSpt = self.___ex.scrollViewSpt
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
end

function FancyStoreBoardView:start()
    self:RegEvent()
    local playerInfoModel = PlayerInfoModel.new()
    self:EventPlayerInfo(playerInfoModel)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FancyStoreBoardView:InitView(fancyStoreModel)
    self.model = fancyStoreModel
    local endTime = self.model:GetEndTime()
    self.residualTimerTxt.text = endTime
    GameObjectHelper.FastSetActive(self.noGoodsGo, endTime == "")
    local goodsList = self.model:GetGoodsList()
    self.scrollViewSpt:InitView(goodsList)
end

function FancyStoreBoardView:RegEvent()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

-- 更新玩家信息
function FancyStoreBoardView:EventPlayerInfo(playerInfoModel)
    self.fsTxt.text = "x" .. tonumber(playerInfoModel:GetFS())
    self.fancyPieceTxt.text = "x" .. tonumber(playerInfoModel:GetFancyPiece())
end

function FancyStoreBoardView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

function FancyStoreBoardView:onDestroy()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

return FancyStoreBoardView
