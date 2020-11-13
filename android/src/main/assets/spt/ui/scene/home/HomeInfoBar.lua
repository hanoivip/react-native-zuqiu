local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require ("EventSystem")
local HomeMainTheme = require("ui.scene.home.HomeMainTheme")

local HomeInfoBar = class(unity.base, "HomeInfoBar")

local tostring = tostring
local tonumber = tonumber
local type = type

function HomeInfoBar:ctor()
    self.logo = self.___ex.logo
    self.btnTeamLogo = self.___ex.btnTeamLogo
    self.txtTeamName = self.___ex.txtTeamName
    self.txtGold = self.___ex.txtGold
    self.txtDiamond = self.___ex.txtDiamond
    self.btnDiamond = self.___ex.btnDiamond
    self.btnMoney = self.___ex.btnMoney
    self.strength = self.___ex.strength
    self.playerName = self.___ex.playerName
    self.playerLevel = self.___ex.playerLevel
    self.expRect = self.___ex.expRect
    self.expBarRect = self.___ex.expBarRect
    self.btnStrength = self.___ex.btnStrength
    self.titleBar = self.___ex.titleBar
    self.sign = self.___ex.sign
end

function HomeInfoBar:start()
    self:RegViewEvent()
    self:RegModelHandler()

    self:UpdateSuitSkin()
end

function HomeInfoBar:InitView(playerInfoModel)
    self:EventPlayerInfo(playerInfoModel)
end

function HomeInfoBar:UpdateSuitSkin()
    local playerInfoModel = PlayerInfoModel.new()
    local skinKey = playerInfoModel:GetSpecificTeam() or HomeMainTheme.Default_Skin_Key
    local themeConfig = HomeMainTheme[skinKey]
    if themeConfig == nil then themeConfig = HomeMainTheme.Classic end

    self.titleBar.color = themeConfig.currencyBgColor
    GameObjectHelper.FastSetActive(self.sign.gameObject, themeConfig.isShowSign)
    if themeConfig.isShowSign then
        self.sign.overrideSprite = res.LoadRes(themeConfig.signPath)
    end
    self:ChangeLogo()
end

function HomeInfoBar:ChangeLogo()
    if self.changeLogo then
        self.changeLogo()
    end
end

function HomeInfoBar:RegViewEvent()
    self.btnStrength:regOnButtonClick(function()
        self:OnBtnStrengthClick()
    end)

    self.btnDiamond:regOnButtonClick(function()
        self:OnBtnDiamondClick()
    end)

    self.btnMoney:regOnButtonClick(function()
        self:OnBtnMoneyClick()
    end)

    if self.btnTeamLogo then 
        self.btnTeamLogo:regOnButtonClick(function()
            self:OnBtnTeamInfoClick()
        end)
    end
end

function HomeInfoBar:OnBtnStrengthClick()
    if self.clickStrength then
        self.clickStrength()
    end
end

function HomeInfoBar:OnBtnDiamondClick()
    if self.clickDiamond then
        self.clickDiamond()
    end
end

function HomeInfoBar:OnBtnMoneyClick()
    if self.clickMoney then
        self.clickMoney()
    end
end

function HomeInfoBar:OnBtnTeamInfoClick()
    if self.clickTeam then
        self.clickTeam()
    end
end

function HomeInfoBar:RegModelHandler()
    EventSystem.AddEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.AddEvent("UpdateSuitSkin", self, self.UpdateSuitSkin)
end

function HomeInfoBar:RemoveModelHandler()
    EventSystem.RemoveEvent("PlayerInfo", self, self.EventPlayerInfo)
    EventSystem.RemoveEvent("UpdateSuitSkin", self, self.UpdateSuitSkin)
end

function HomeInfoBar:EventPlayerInfo(playerInfoModel)
    local info = {
        level = tonumber(playerInfoModel:GetLevel()),
        exp = tonumber(playerInfoModel:GetExp()),
        levelUpExp = tonumber(playerInfoModel:GetLevelUpExp()),
        teamName = playerInfoModel:GetName(),
        vipLevel = tonumber(playerInfoModel:GetVipLevel()),
        strength = tonumber(playerInfoModel:GetStrengthPower()),
        gold = tonumber(playerInfoModel:GetMoney()),
        diamond = tonumber(playerInfoModel:GetDiamond()),
    }
    self:UpdateInfo(info)
end

local DefaultStrengthLimit = 120 
function HomeInfoBar:UpdateInfo(info)
    assert(type(info) == "table", "playerInfo is not a table !")

    if info.gold then
        self.txtGold.text = string.formatNumWithUnit(info.gold)
    end
    if info.diamond then
        self.txtDiamond.text = tostring(info.diamond)
    end
    if info.strength then
        local currentStrength = tonumber(info.strength)
        self.strength.text = currentStrength .. '/' .. DefaultStrengthLimit
    end
    if info.level then
        self.playerLevel.text = "Lv:" .. tostring(info.level)
    end
    if info.exp then
        local currentExp = info.exp
        local needExp = info.levelUpExp
        self:UpdateExpProgress(currentExp, needExp)
    end
    if info.teamName then
        self.playerName.text = tostring(info.teamName)
    end
end

-- 经验条带空白影子，手动计算当经验条压缩的位移
local ExpBarFixSideWidth = 16 -- 经验条三宫格一边宽度
local ExpRatio = 0.7 -- 经验条蓝色区域在一边比例
local DefaultOffset = 5 -- 经验条进经验槽偏移单位
function HomeInfoBar:UpdateExpProgress(currentExp, needExp)
    local progress = currentExp / needExp * self.expRect.rect.width
    self.expBarRect.sizeDelta = Vector2(progress, self.expBarRect.sizeDelta.y)
    local offset = DefaultOffset
    if progress / 2 < ExpBarFixSideWidth then 
        local value = (ExpBarFixSideWidth - progress / 2) * ExpRatio
        offset = offset + value
    end
    self.expBarRect.anchoredPosition = Vector2(offset, 0)
end

function HomeInfoBar:onDestroy()
    self:RemoveModelHandler()
end

return HomeInfoBar
