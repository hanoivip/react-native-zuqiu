local ItemsMapModel = require("ui.models.ItemsMapModel")
local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyGachaInfoBarView = class(DynamicLoaded, "FancyGachaInfoBarView")

local tostring = tostring
local tonumber = tonumber
local type = type

function FancyGachaInfoBarView:ctor()
--------Start_Auto_Generate--------
    self.diamondBtn = self.___ex.diamondBtn
    self.diamondTxt = self.___ex.diamondTxt
    self.moneyBtn = self.___ex.moneyBtn
    self.moneyTxt = self.___ex.moneyTxt
    self.fancyTicketBtn = self.___ex.fancyTicketBtn
    self.fancyTicketTxt = self.___ex.fancyTicketTxt
    self.fancyTicketx10Btn = self.___ex.fancyTicketx10Btn
    self.fancyTicketx10Txt = self.___ex.fancyTicketx10Txt
    self.fancyPieceBtn = self.___ex.fancyPieceBtn
    self.fancyPieceTxt = self.___ex.fancyPieceTxt
    self.fancySoulBtn = self.___ex.fancySoulBtn
    self.fancySoulTxt = self.___ex.fancySoulTxt
    self.backBtn = self.___ex.backBtn
--------End_Auto_Generate----------
end

function FancyGachaInfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

--param = {
--    isHideBack = false, -- 返回按钮
--    isHideDiamond = false, --钻石按钮
--    isHideFancyTicket1 = false,  -- 单抽券
--    isHideFancyTicket10 = false,  -- 十连抽券
--    isHidePiece = false,  -- 碎片
--    isHideSoul = false,  -- 球魂
--    isHideMoney = false, -- 欧元
--}
function FancyGachaInfoBarView:InitView(param)
    param = param or {}
    GameObjectHelper.FastSetActive(self.backBtn.gameObject, not param.isHideBack)
    GameObjectHelper.FastSetActive(self.diamondBtn.gameObject, not param.isHideDiamond)
    GameObjectHelper.FastSetActive(self.fancyTicketBtn.gameObject, not param.isHideFancyTicket1)
    GameObjectHelper.FastSetActive(self.fancyTicketx10Btn.gameObject, not param.isHideFancyTicket10)
    GameObjectHelper.FastSetActive(self.fancyPieceBtn.gameObject, not param.isHidePiece)
    GameObjectHelper.FastSetActive(self.fancySoulBtn.gameObject, not param.isHideSoul)
    GameObjectHelper.FastSetActive(self.moneyBtn.gameObject, not param.isHideMoney)
end

function FancyGachaInfoBarView:RegViewEvent()
    self.backBtn:regOnButtonClick(function()
        if self.clickBack and type(self.clickBack) == "function" then
            self.clickBack()
        end
    end)
    self.diamondBtn:regOnButtonClick(function()
        if self.clickDiamond and type(self.clickDiamond) == "function" then
            self.clickDiamond()
        end
    end)
    self.moneyBtn:regOnButtonClick(function()
        if self.clickMoney and type(self.clickMoney) == "function" then
            self.clickMoney()
        end
    end)
    self.fancyTicketBtn:regOnButtonClick(function()
        if self.clickFancyOneTicket and type(self.clickFancyOneTicket) == "function" then
            self.clickFancyOneTicket()
        end
    end)
    self.fancyTicketx10Btn:regOnButtonClick(function()
        if self.clickFancyTenTicket and type(self.clickFancyTenTicket) == "function" then
            self.clickFancyTenTicket()
        end
    end)
    self.fancyPieceBtn:regOnButtonClick(function()
        if self.clickFancyPiece and type(self.clickFancyPiece) == "function" then
            self.clickFancyPiece()
        end
    end)
    self.fancySoulBtn:regOnButtonClick(function()
        if self.clickFs and type(self.clickFs) == "function" then
            self.clickFs()
        end
    end)
end

function FancyGachaInfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.AddEvent("FancyGachaInfo", self, self.EventPlayerInfo)
    EventSystem.AddEvent("BuyStoreItem", self, self.EventItemListInfo)
    EventSystem.AddEvent("FancyGachaStart", self, self.EventItemListInfo)
end

function FancyGachaInfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.RemoveEvent("FancyGachaInfo", self, self.EventPlayerInfo)
    EventSystem.AddEvent("BuyStoreItem", self, self.EventItemListInfo)
    EventSystem.RemoveEvent("FancyGachaStart", self, self.EventItemListInfo)
end

function FancyGachaInfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        diamond = tonumber(playerInfoModel:GetDiamond()),
        fancyPiece = tonumber(playerInfoModel:GetFancyPiece()),
        fs = tonumber(playerInfoModel:GetFS()),
        money = tonumber(playerInfoModel:GetMoney())
    }
    self:UpdateInfo(info)
end

function FancyGachaInfoBarView:EventItemListInfo()
    local itemsMapModel = ItemsMapModel.new()
    local info = {
        fancyOneTicket = tonumber(itemsMapModel:GetItemNum(2005)),
        fancyTenTicket = tonumber(itemsMapModel:GetItemNum(2006)),
    }
    self:UpdateInfo(info)
end

function FancyGachaInfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")
    if info.diamond then
        self.diamondTxt.text = tostring(info.diamond)
    end
    if info.money then
        self.moneyTxt.text = string.formatNumWithUnit(info.money)
    end
    if info.fancyOneTicket then
        self.fancyTicketTxt.text = tostring(info.fancyOneTicket)
    end
    if info.fancyTenTicket then
        self.fancyTicketx10Txt.text = tostring(info.fancyTenTicket)
    end
    if info.fancyPiece then
        self.fancyPieceTxt.text = tostring(info.fancyPiece)
    end
    if info.fs then
        self.fancySoulTxt.text = tostring(info.fs)
    end
end

function FancyGachaInfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return FancyGachaInfoBarView

