local Model = require("ui.models.Model")
local GuildWar = require("data.GuildWar")
local GuildMistShop = require("data.GuildMistShop")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")
local MEMBERTYPE = require("ui.controllers.guild.MEMBERTYPE")

local GuildLogItemModel = class(Model, "GuildLogItemModel")


function GuildLogItemModel:ctor(data)
    self.data = data
    self.content = ""
end

function GuildLogItemModel:GetContent()
    local newAuthority = self.data.content.newAuthority
    local oldAuthority = self.data.content.oldAuthority
    local performerAuthority = self.data.content.authority
    local operate = self.data.content.operate
    local operateAccepter = self.data.content.operateAccepter or ""
    local operatePerformer = self.data.content.operatePerformer or ""
    local key1 = self.data.content.key1
    local srcKey2 = self.data.content.key2
    local key2 = math.clamp(tonumber(self.data.content.key2), 1, 10)
    local key3 = self.data.content.key3
    local srcKey4 = self.data.content.key4
    local key4 = math.clamp(tonumber(self.data.content.key4), 1, 10)
    local str = ""

    local authorityColorTable = {
        "#FF594F",
        "#F0AD35",
        "#F0AD35",
        "#FFEB04"
    }

    local newAcceptColorStr = "【%s】"
    local oldAcceptColorStr = "【%s】"
    local performerColorStr = "【%s】"
    if newAuthority and newAuthority ~= "" and tonumber(newAuthority) > 0 then
        newAcceptColorStr = "<color=" .. authorityColorTable[newAuthority] .. ">【%s】" .. "</color>"
    end
    if oldAuthority and oldAuthority ~= "" and tonumber(oldAuthority) > 0 then
        oldAcceptColorStr = "<color=" .. authorityColorTable[oldAuthority] .. ">【%s】" .. "</color>"
    end
    if performerAuthority and performerAuthority ~= "" and tonumber(performerAuthority) > 0 then
        performerColorStr = "<color=" .. authorityColorTable[performerAuthority] .. ">【%s】" .. "</color>"
    end

    local acceptNewName = string.format(newAcceptColorStr, operateAccepter)
    local acceptOldName = string.format(oldAcceptColorStr, operateAccepter)
    local performerName = string.format(performerColorStr, operatePerformer)
    local position = MEMBERTYPE[newAuthority]

    if tostring(operate) == "add" then
        str = lang.transstr("guild_logadd", acceptNewName)
    elseif tostring(operate) == "quit" then
        str = lang.transstr("guild_logquit", acceptOldName)
    elseif tostring(operate) == "kick" then
        str = lang.transstr("guild_logkick", acceptOldName, performerName)
    elseif tostring(operate) == "cpos" then
        if newAuthority > oldAuthority then
            str = lang.transstr("guild_logcpos1", acceptOldName, performerName, position)
        else
            str = lang.transstr("guild_logcpos2", acceptOldName, performerName, position)
        end
    elseif tostring(operate) == "epos" then
        str = lang.transstr("guild_logepos", performerName, acceptOldName)
    elseif tostring(operate) == "masterAuto" then
        if operatePerformer ~= "" then
            str = lang.transstr("guild_logmasterAuto1", performerName, acceptOldName)
        else
            str = lang.transstr("guild_logmasterAuto2", acceptOldName, position)
        end
    elseif tostring(operate) == "signm" or tostring(operate) == "signd" then
        str = lang.transstr("guild_logsign", performerName)
    elseif tostring(operate) == "warSign" then
        local level = tostring(key4)
        local minLevel = GuildWar[level].minLevel
        local type = GuildWar[level].type
        if type == GuildWarType.Mist then
            str = lang.transstr("mist_log_war_sign", performerName, key1, lang.transstr("number_" .. minLevel))
        else
            str = lang.transstr("guild_logwarSign", performerName, key1, srcKey2, key3, lang.transstr("number_" .. minLevel))
        end
    elseif tostring(operate) == "warResult" then
        str = lang.transstr("guild_logwarResult", key1, lang.transstr("number_" .. key2))
    elseif tostring(operate) == "arkBuf" then
        --用为转换的key2
        str = lang.transstr("guild_logatkBuf", performerName, srcKey2, key1, key3, srcKey4)
    elseif tostring(operate) == "defBuf" then
        str = lang.transstr("guild_logdefBuf", performerName, srcKey2, key1, key3, srcKey4)
    elseif tostring(operate) == "donation" then
        str = lang.transstr("mist_vote_log", performerName, key1)
    elseif tostring(operate) == "shopItem" then
        local mapId = tostring(key3)
        local mapName = GuildMistShop[mapId].name
        str = lang.transstr("mist_log_shop_item", performerName, self.data.content.key2, key1, mapName)
    end

    self.content = str

    return self.content
end

function GuildLogItemModel:GetTime()
    local time = self.data.c_t
    local timeStr = string.convertSecondToMonth(time)
    return timeStr
end

return GuildLogItemModel