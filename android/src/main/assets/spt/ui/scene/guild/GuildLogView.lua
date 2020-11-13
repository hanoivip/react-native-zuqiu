local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local GUILD_LOGTYPE = require("ui.controllers.guild.GUILD_LOGTYPE")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildLogView = class(unity.base)

local MENU_MAP = {
    [GUILD_LOGTYPE.ALL] = "all",
    [GUILD_LOGTYPE.DAILY] = "daily",
    [GUILD_LOGTYPE.WAR] = "war",
    [GUILD_LOGTYPE.SIGN] = "sign",
    [GUILD_LOGTYPE.DONATION] = "donation",
}

local MENUREVERSE_MAP = {
    ["all"] = GUILD_LOGTYPE.ALL,
    ["daily"] = GUILD_LOGTYPE.DAILY,
    ["war"] = GUILD_LOGTYPE.WAR,
    ["sign"] = GUILD_LOGTYPE.SIGN,
    ["sign"] = GUILD_LOGTYPE.SIGN,
    ["donation"] = GUILD_LOGTYPE.DONATION,
}

function GuildLogView:ctor()
    self.infoBarDynParent = self.___ex.infoBar
    self.scrollerView = self.___ex.scrollerView
    self.menuButtonGroup = self.___ex.menuButtonGroup
end


function GuildLogView:start()
    local logMenu = self.menuButtonGroup.menu
    for key, v in pairs(logMenu) do
        v:regOnButtonClick(function()
            self:OnLogTypeClick(MENUREVERSE_MAP[key])
        end)
    end
end

function GuildLogView:OnLogTypeClick(index)
    if self.clickLogType then
        self.clickLogType(index)
    end
end

function GuildLogView:SwitchMenu(menuType)
    self.menuButtonGroup:selectMenuItem(MENU_MAP[menuType])
end

function GuildLogView:InitView(model, menuType)
    local list = {}
    if menuType == GUILD_LOGTYPE.ALL then
        list = model:GetAllRecordList()
    elseif menuType == GUILD_LOGTYPE.DAILY then
        list = model:GetDailyRecordList()
    elseif menuType == GUILD_LOGTYPE.WAR then
        list = model:GetWarRecordList()
    elseif menuType == GUILD_LOGTYPE.SIGN then
        list = model:GetSignRecordList()
    elseif menuType == GUILD_LOGTYPE.DONATION then
        list = model:GetDonateRecordList()
    end
    self.scrollerView:InitView(list)
    self:SwitchMenu(menuType)
end

function GuildLogView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return GuildLogView