local Model = require("ui.models.Model")
local UnityEngine = clr.UnityEngine
local Timer = require("ui.common.Timer")
local ChatMainModel = class(Model, "ChatMainModel")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")


function ChatMainModel:ctor()
    self.worldMsgList = {}
    self.guildMsgList = {}
    self.playerMsgList = {}
    self.globalMsgList = {}
    self.newWorldMsgList = {}
    self.newGuildMsgList = {}
    self.newPlayerMsgList = {}
    self.newGlobalMsgList = {}
    self.playerMsgGroup = {}
    self.newPlayerMsgGroup = {}
    self.playerInfoList = {}
    self.hasNewMsgPlayerList = {}
    self.hasNewMsgGuildList = {}
    self.packetList = {}    

    self.worldLimitLevel = 10
    self.worldLimitTime = 0
    self.currentPlayerPid = nil
    self.currentPlayerSid = nil
    self.unreadMsgCount = 0
    self.firstInitPlayer = true
    self.firstInitGuild = true
    self.freeCount = 0
    self.worldSendPrice = 5
    self.limitTimer = nil
end

function ChatMainModel:GetLastWorldSeq()
    if #self.worldMsgList > 0 then
        return self.worldMsgList[#self.worldMsgList].seq
    else
        return "-1"
    end
end

function ChatMainModel:GetLastGuildSeq()
    if #self.guildMsgList > 0 then
        return self.guildMsgList[#self.guildMsgList].seq
    else
        return "-1"
    end
end

function ChatMainModel:GetLastPlayerSeq()
    if #self.playerMsgList > 0 then
        return self.playerMsgList[#self.playerMsgList].seq
    else
        return "-1"
    end
end

function ChatMainModel:GetLastGlobalSeq()
    if #self.globalMsgList > 0 then
        return self.globalMsgList[#self.globalMsgList].seq
    else
        return "-1"
    end
end

function ChatMainModel:InitWithProtocol(data, currentChatType)
    self.data = data
    self.data.global = {}
    self.newWorldMsgList = {}
    self.newGuildMsgList = {}
    self.newPlayerMsgList = {}
    self.newGlobalMsgList = {}
    self.newPlayerMsgGroup = {}
    self.playerMsgGroup = {}
    self.newPlayerInfoList = {}
    
    self:SetWorldFreeCount(data.free)
    self:SetServerMessage(data.world, self.worldMsgList, self.newWorldMsgList)
    self:SetServerMessage(data.guild, self.guildMsgList, self.newGuildMsgList)
    self:SetServerMessage(data.player, self.playerMsgList, self.newPlayerMsgList)
    self:SetServerMessage(data.allServer, self.globalMsgList, self.newGlobalMsgList)
    self:SetPlayerMsgGroup(self.newPlayerMsgGroup, self.newPlayerMsgList)
    self:SetPlayerMsgGroup(self.playerMsgGroup, self.playerMsgList)
    self:SetPlayerInfoList(self.newPlayerInfoList)
    self:SetPlayerInfoList(self.playerInfoList)    
    self:SetHasNewMsgPlayerList()
    self:SetHasNewMsgGuildList(currentChatType)
    self:SetPacketList()
end

function ChatMainModel:SetHasNewMsgPlayerList()
    if self.firstInitPlayer then
        for k, v in pairs(self.newPlayerMsgGroup) do
            for i = 1, #v do
                if v[i].new == 1 then
                    table.insert(self.hasNewMsgPlayerList, k)
                    break
                end
            end
        end
        self.firstInitPlayer = false
    else
        for k, v in pairs(self.newPlayerMsgGroup) do
            if k ~= self:GetCurrentPlayerPid() then
                local flag = true
                for i = 1, #self.hasNewMsgPlayerList do
                    if k == self.hasNewMsgPlayerList[i] then
                        flag = false
                        break
                    end                
                end
                if flag then
                    table.insert(self.hasNewMsgPlayerList, k)
                end
            end
        end
    end
end

function ChatMainModel:SetHasNewMsgGuildList(currentChatType)
    if self.firstInitGuild then
        for i = 1, #self.newGuildMsgList do
            if self.newGuildMsgList[i].new == 1 then
                if currentChatType ~= CHAT_TYPE.GUILD then
                    table.insert(self.hasNewMsgGuildList, self.newGuildMsgList[i])
                end
                break
            end
        end
        self.firstInitGuild = false
    else
        for m = 1, #self.newGuildMsgList do
            local flag = true
            for n = 1, #self.hasNewMsgGuildList do
                if self.newGuildMsgList[m].c_t == self.hasNewMsgGuildList[n].c_t then
                    flag = false
                    break
                end                
            end
            if flag and (currentChatType ~= CHAT_TYPE.GUILD) then
                table.insert(self.hasNewMsgGuildList, self.newGuildMsgList[m])
            end
        end
    end
    EventSystem.SendEvent("MainModel_GuildHasNewMessage", self.hasNewMsgGuildList)
end

function ChatMainModel:ResetHasNewMsgGuildList()
    self.hasNewMsgGuildList = {}
    EventSystem.SendEvent("MainModel_GuildHasNewMessage", self.hasNewMsgGuildList)
end

function ChatMainModel:RemoveNewMsgPlayerListItem(pid)
    for i = 1, #self.hasNewMsgPlayerList do
        if self.hasNewMsgPlayerList[i] == pid then
            table.remove(self.hasNewMsgPlayerList, i)
            break
        end
    end
    EventSystem.SendEvent("MainModel_PlayerHasNewMessage", self.hasNewMsgPlayerList)
end

function ChatMainModel:GetNewMsgPlayerList()
    return self.hasNewMsgPlayerList
end

function ChatMainModel:SetServerMessage(serverMsgList, allMsgList, newMsgList)
    if serverMsgList then
        for i = #serverMsgList, 1, -1 do
            local flag = true
            for j = 1, #allMsgList do
               if serverMsgList[i].seq == allMsgList[j].seq then
                   flag = false
                   break 
               end
            end
            if flag then
                allMsgList[#allMsgList + 1] = serverMsgList[i]
                newMsgList[#newMsgList + 1] = serverMsgList[i]
            end
        end
    end
end

function ChatMainModel:GetNewWorldMsgList()
    return self.newWorldMsgList
end

function ChatMainModel:GetWorldMsgList()
    return self.worldMsgList
end

function ChatMainModel:GetNewGuildMsgList()
    return self.newGuildMsgList
end

function ChatMainModel:GetGuildMsgList()
    return self.guildMsgList
end

function ChatMainModel:GetNewGlobalMsgList()
    return self.newGlobalMsgList
end

function ChatMainModel:GetGlobalMsgList()
    return self.globalMsgList
end

function ChatMainModel:GetWorldLimitTime()
    return self.worldLimitTime
end

function ChatMainModel:GetWorldLimitLevel()
    return self.worldLimitLevel
end

function ChatMainModel:GetWorldFreeCount()
    return self.freeCount
end

function ChatMainModel:SetWorldFreeCount(count)
    self.freeCount = tonumber(count)
end

function ChatMainModel:SetPacketList()
    self.packetList = {}
    for i = 1, #self.guildMsgList do
        if self.guildMsgList[i].form == 3 and self.guildMsgList[i].new == 1 then
            local packet = {index = i, _id = self.guildMsgList[i].content._id, new = 1}
            table.insert(self.packetList, packet)
        end
    end
end

function ChatMainModel:GetPacketList()
    return self.packetList
end

function ChatMainModel:RemovePacketListItem(id)
    for i = 1, #self.packetList do
        if self.packetList[i]._id == id then
            self.guildMsgList[self.packetList[i].index].new = 0
            table.remove(self.packetList, i)
            break
        end
    end
end

function ChatMainModel:SetWorldLimitTime(time)
    self.worldLimitTime = time
    if self.worldLimitTime > 0 then
        if self.limitTimer ~= nil then
            self.limitTimer:Destroy()
            self.limitTimer = nil
        end
        self.limitTimer = Timer.new(time, function (secondTime)
            if secondTime > 0 then
                self.worldLimitTime = math.floor(secondTime)
            end
        end)
    end
end

function ChatMainModel:SetCurrentPlayerPid(pid, sid)
    self.currentPlayerPid = pid
    self.currentPlayerSid = sid
    if pid then
        EventSystem.SendEvent("SidePlayerScroll_SelectedItem", pid)
    end
end

function ChatMainModel:GetCurrentPlayerPid()
    return self.currentPlayerPid
end

function ChatMainModel:GetCurrentPlayerSid()
    return self.currentPlayerSid
end

function ChatMainModel:SetPlayerMsgGroup(playerMsgGroup, playerMsgList)
    for i = 1, #playerMsgList do
        local pid = playerMsgList[i].sender.pid
        local flag = true
        for k, v in pairs(playerMsgGroup) do
            if pid == k then
                table.insert(v, playerMsgList[i])
                flag = false
                break;
            end
        end
        if flag then
            playerMsgGroup[pid] = {}
            table.insert(playerMsgGroup[pid], playerMsgList[i])
        end
    end
end

function ChatMainModel:GetPlayerMsgList(pid, sid)
    self:SetCurrentPlayerPid(pid, sid)
    return self.playerMsgGroup[pid] or {}
end

function ChatMainModel:GetNewPlayerMsgList(pid, sid)
    self:SetCurrentPlayerPid(pid, sid)
    return self.newPlayerMsgGroup[pid] or {}
end

function ChatMainModel:GetCurrentNewPlayerMsgList()
    return self:GetNewPlayerMsgList(self.currentPlayerPid, self.currentPlayerSid)
end

function ChatMainModel:GetCurrentPlayerMsgList()
    return self:GetPlayerMsgList(self.currentPlayerPid, self.currentPlayerSid)
end

function ChatMainModel:GetFirstPlayerMsgList()
    if #self.playerInfoList > 0 then
        local pid = self.playerInfoList[1].pid
        return self:GetPlayerMsgList(pid, self.playerInfoList[1].sid)
    end
    return {}
end

function ChatMainModel:AddPlayerInfoList(sender)
    for i = 1, #self.playerInfoList do
        if self.playerInfoList[i].pid == sender.pid then
            self.playerInfoList[1], self.playerInfoList[i] = self.playerInfoList[i], self.playerInfoList[1]
            return
        end
    end
    table.insert(self.playerInfoList, 1, sender)
end

function ChatMainModel:RemovePlayerInfoListItem(pid)
    for i = 1, #self.playerInfoList do
        if self.playerInfoList[i].pid == pid then
            table.remove(self.playerInfoList, i)
            break
        end
    end
end

function ChatMainModel:GetPlayerInfoList()
    local list = {}
    for i = 1, #self.playerInfoList do
        if i < 21 then
            table.insert(list, self.playerInfoList[i])
        end
    end
    return list
end

function ChatMainModel:SetPlayerInfoList(plist)
    for k, v in pairs(self.newPlayerMsgGroup) do 
        for i = 1, #v do
            if tonumber(v[i].isSelf) == 0 then
                local flag = true
                for j = 1, #self.playerInfoList do
                    if self.playerInfoList[j].pid == v[i].sender.pid then
                        flag = false
                        break
                    end
                end
                if flag then
                    table.insert(plist, v[i].sender)
                    break
                end
            end
        end
    end
end

function ChatMainModel:GetNewPlayerInfoList()
    return self.newPlayerInfoList
end

function ChatMainModel:AppendUnreadMsgCount(count)
    self.unreadMsgCount = self.unreadMsgCount + count
end

function ChatMainModel:ResetUnreadMsgCount()
    self.unreadMsgCount = 0
end

function ChatMainModel:GetUnReadMsgCount()
    return self.unreadMsgCount
end

function ChatMainModel:GetDiamondPrice()
    return self.worldSendPrice
end

return ChatMainModel
