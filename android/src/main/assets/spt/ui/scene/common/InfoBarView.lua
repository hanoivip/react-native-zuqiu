local DynamicLoaded = require("ui.control.utils.DynamicLoaded")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local InfoBarView = class(DynamicLoaded)

local tostring = tostring
local tonumber = tonumber
local type = type

function InfoBarView:ctor()
    self.txtStrength = self.___ex.txtStrength
    self.btnStrength = self.___ex.btnStrength
    self.txtLucky = self.___ex.txtLucky
    self.txtGold = self.___ex.txtGold
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDiamond = self.___ex.btnDiamond
    self.btnBack = self.___ex.btnBack
    self.btnMoney = self.___ex.btnMoney
    self.btnLucky = self.___ex.btnLucky
    self.btnBlackDiamond = self.___ex.btnBlackDiamond
    self.luckyArea = self.___ex.luckyArea
    self.strength = self.___ex.strength
    self.blackDiamond = self.___ex.blackDiamond
    self.txtBlackDiamond = self.___ex.txtBlackDiamond
end

function InfoBarView:start()
    self:RegViewEvent()
    self:RegModelHandler()
end

function InfoBarView:InitView(playerInfoModel)
    self.playerInfoModel = playerInfoModel
end

function InfoBarView:RegViewEvent()
    self.btnStrength:regOnButtonClick(function()
        self:OnBtnStrengthClick()
    end)
    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
    self.btnLucky:regOnButtonClick(function ()
        self:OnBtnLuckyClick()
    end)
    self.btnMoney:regOnButtonClick(function()
        self:OnBtnMoneyClick()
    end)
    self.btnBlackDiamond:regOnButtonClick(function ()
        self:OnBtnBlackDiamondClick()
    end)
end

function InfoBarView:OnBtnBlackDiamondClick()
    if self.clickBlackDiamond then
        self.clickBlackDiamond()
    end
end

function InfoBarView:OnBtnTeamInfoClick()
    if self.clickTeam then
        self.clickTeam()
    end
end

function InfoBarView:OnBtnStrengthClick()
    if self.clickStrength then
        self.clickStrength(self.isShowActivity)
    end
end

function InfoBarView:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function InfoBarView:OnBtnMoneyClick()
    if self.clickMoney then
        self.clickMoney()
    end
end

function InfoBarView:OnBtnLuckyClick()
    if self.clickLucky then
        self.clickLucky()
    end
end

function InfoBarView:OnBtnBackClick()
    if self.clickBack then
        self.clickBack()
    end
end

function InfoBarView:ShowLuckyArea(isShow)
    GameObjectHelper.FastSetActive(self.luckyArea, isShow)
end

function InfoBarView:ShowBlackDiamond(isShow)
    GameObjectHelper.FastSetActive(self.strength, not isShow)
    GameObjectHelper.FastSetActive(self.blackDiamond, isShow)
end

function InfoBarView:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function InfoBarView:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
end

function InfoBarView:EventPlayerInfo(playerInfoModel)
    local info = {
        level = tonumber(playerInfoModel:GetLevel()),
        exp = tonumber(playerInfoModel:GetExp()),
        levelUpExp = tonumber(playerInfoModel:GetLevelUpExp()),
        teamName = playerInfoModel:GetName(),
        vipLevel = tonumber(playerInfoModel:GetVipLevel()),
        strength = tonumber(playerInfoModel:GetStrengthPower()),
        gold = tonumber(playerInfoModel:GetMoney()),
        diamond = tonumber(playerInfoModel:GetDiamond()),
        teamLogo = playerInfoModel:GetTeamLogo(),
        lucky = playerInfoModel:GetLucky(),
        bkd = playerInfoModel:GetBlackDiamond()
    }
    self:UpdateInfo(info)
end
local DefaultStrengthLimit = 120 
function InfoBarView:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")

    if info.strength then
        local currentStrength = tonumber(info.strength)
        self.txtStrength.text = currentStrength .. '/' .. DefaultStrengthLimit
    end
    if info.gold then
        self.txtGold.text = string.formatNumWithUnit(info.gold)
    end
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
    if info.lucky then
        self.txtLucky.text = tostring(info.lucky)
    end
    if info.bkd then
        self.txtBlackDiamond.text = tostring(info.bkd)
    end
end

function InfoBarView:onDestroy()
    self:RemoveModelHandler()
end

return InfoBarView

