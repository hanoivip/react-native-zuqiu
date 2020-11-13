local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local GuildJoinModel = class(Model, "GuildJoinModel")

function GuildJoinModel:ctor()
    self.playerInfoModel = PlayerInfoModel.new()
    self.MemberLimitNum = 40
    self.currentGid = nil
    self.currentItemModel = nil
    self.hasRequestGuildList = {}
    self.hasSearch = false
end

function GuildJoinModel:InitWithProtocal(data)
    self.cacheData = data
end

function GuildJoinModel:GetGuildList()
    return self.cacheData
end

function GuildJoinModel:SetSearchState(isSearch)
    self.hasSearch = isSearch
end

function GuildJoinModel:GetSearchState()
    return self.hasSearch
end


function GuildJoinModel:CheckLevelReach(itemLevel)
    local level = self.playerInfoModel:GetLevel()
    return level >= itemLevel
end

function GuildJoinModel:CheckMemberFull(itemNum)
    return itemNum >= self.MemberLimitNum
end

function GuildJoinModel:GetCurrentGid()
    return self.currentItemModel:GetGid()
end

function GuildJoinModel:GetCurrentItemModel()
    return self.currentItemModel
end

function GuildJoinModel:SetCurrentItemModel(itemModel)
    self.currentItemModel = itemModel
end

function GuildJoinModel:AddRequestGuild(gid)
    if gid then
        local flag = true
        for i = 1, #self.hasRequestGuildList do
            if self.hasRequestGuildList[i] == gid then
                flag = false
                break
            end
        end
        if flag then
            table.insert(self.hasRequestGuildList, gid)
        end
    end
end

function GuildJoinModel:CheckRequestGuild(gid)
    for i = 1, #self.hasRequestGuildList do
        if self.hasRequestGuildList[i] == gid then
            return true
        end
    end
    return false
end

return GuildJoinModel