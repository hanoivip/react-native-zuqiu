local UnityEngine = clr.UnityEngine
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerDetailModel = require("ui.models.playerDetail.PlayerDetailModel")
local MatchLoader = require("coregame.MatchLoader")
local EventSystem = require("EventSystem")
local CardBuilder = require("ui.common.card.CardBuilder")
local DialogManager = require("ui.control.manager.DialogManager")
local ChatMainModel = require("ui.models.chat.ChatMainModel")
local ArenaModel = require("ui.models.arena.ArenaModel")
local GuildDetailModel = require("ui.models.guild.GuildDetailModel")
local HonorPalaceModel = require("ui.models.honorPalace.HonorPalaceModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")
local ChatTipDialogModel = require("ui.models.chat.ChatTipDialogModel")
local OtherCoachMainModel = require("ui.models.coach.OtherCoachMainModel")

local PlayerDetailCtrl = class(BaseCtrl)
PlayerDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerDetail/PlayerDetail.prefab"

PlayerDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function PlayerDetailCtrl:Init()
    self.playerDetailModel = PlayerDetailModel.new()
    self.chatMainModel = ChatMainModel.new()
    self.arenaModel = ArenaModel.new()
    self.guildDetailModel = nil
    self.honorPalaceModel = HonorPalaceModel.new()
    self.playerInfoModel = PlayerInfoModel.new()
end

function PlayerDetailCtrl:Refresh(data, pid, sid, hideFunBtn, showIndex, friendManagerModel, specialEventsMatchId, arenaType, bShowMyScene)
    PlayerDetailCtrl.super.Refresh(self)
    self.data = data
    self.pid = pid
    self.sid = sid
    self.showIndex = showIndex
    self.hideFunBtn = hideFunBtn
    self.friendManagerModel = friendManagerModel
    self.specialEventsMatchId = specialEventsMatchId
    self.playerDetailModel:InitWithProtocol(data)
    self.playerDetailModel.specialEventsMatchId = specialEventsMatchId
    self.playerDetailModel:SetArenaType(arenaType)
    self.bShowMyScene = bShowMyScene
    self.playerDetailModel:SetHomeCourtState(bShowMyScene)
    local guild = self.playerDetailModel:GetGuild()
    local size = guild and table.nums(guild) or 0
    -- 如果没有公会，就不用创建了
    if size ~= 0 then
        self.guildDetailModel = GuildDetailModel.new()
        self.guildDetailModel:InitWithProtrol(guild)
    end
    local player = data.player
    local honorData = {
        honor = player.honor,
        list = player.list
    }
    self.honorPalaceModel:InitWithProtocol(honorData)

    local sender = {
        authority = 1,
        logo = self.playerDetailModel:GetTeamLogo(),
        lvl = self.playerDetailModel:GetPlayerLevel(),
        name = self.playerDetailModel:GetPlayerName(),
        pid = pid,
        sid = sid
    }
    self.chatDialogModel = ChatTipDialogModel.new(sender)
    self:InitView()
end

function PlayerDetailCtrl:InitView()
    -- 注册事件
    self.view.onAddFriend = function()
        local pidTable = {{pid = self.pid, sid = tostring(self.sid)}}
        self:OnAddFriend(pidTable)
    end

    self.view.onPrivateChat = function()
        clr.coroutine(function()
            self.view:Close()
            coroutine.yield(UnityEngine.WaitForEndOfFrame())
            local isShow = cache.getIsChatViewOpen()
            self.chatMainModel:SetCurrentPlayerPid(self.pid, self.sid)
            -- 如果是从聊天界面打开，就不要再打开聊天界面了
            if not isShow then
                cache.setChatSideData(self.chatDialogModel)
                res.PushDialog("ui.controllers.chat.ChatMainCtrl", CHAT_TYPE.PLAYER)
            else
                EventSystem.SendEvent("ChatTipDialog_SideChat", self.chatDialogModel)
            end
        end)
    end

    self.view.onStartMatch = function() self:OnStartMatch() end
    self.view.onDeleteFriend = function () self:OnDeleteFriend() end
    self.view.onApplyGuild = function() self:JoinGuild() end

    local sameGuild = false
    local friendGuildID = self.playerDetailModel:GetGuildID()
    local myGuild = self.playerInfoModel:GetGuild()
    if myGuild then
        if myGuild.gid == friendGuildID then
            sameGuild = true
        end
    end
    sameGuild = sameGuild or (self.playerInfoModel:GetSID() ~= self.sid)
    local isMe = false
    if self.pid == self.playerInfoModel:GetID() then
        isMe = true
    end
    self.playerDetailModel:SetIsMe(isMe)
    self.view:InitView(self.playerDetailModel, self.guildDetailModel, self.honorPalaceModel, sameGuild, isMe, self.showIndex, self.hideFunBtn, self.specialEventsMatchId, self.bShowMyScene)
end

-- 恢复UI时，传入的参数
function PlayerDetailCtrl:GetStatusData()
    return self.data, self.pid, self.sid, self.hideFunBtn, self.playerDetailModel:GetIndex(), self.friendManagerModel, self.specialEventsMatchId, self.playerDetailModel:GetArenaType(), self.bShowMyScene
end

function PlayerDetailCtrl:OnEnterScene()
    EventSystem.AddEvent("ClickPlayerCardCircle", self, self.OnCardClick)
end

function PlayerDetailCtrl:OnExitScene()
    EventSystem.RemoveEvent("ClickPlayerCardCircle", self, self.OnCardClick)
end

function PlayerDetailCtrl:OnStartMatch()
    clr.coroutine(function()
        local response = req.friendsMatch(self.pid, self.sid)
        if api.success(response) then
            MatchLoader.startMatch(response.val)
        end
    end)
end

-- 删除好友确认面板
function PlayerDetailCtrl:OnDeleteFriend()
    DialogManager.ShowConfirmPop(lang.trans("friends_manager_item_deleteFriend"), lang.trans("friends_delete_tip", self.playerDetailModel:GetPlayerName()), function ()
        self:OnDelFriend(self.pid, self.sid)
        self.view:Close()
    end, nil)
end

-- 点击球员
function PlayerDetailCtrl:OnCardClick(pcId)
    local cids = self.playerDetailModel:GetChemicalCids()
    local otherPlayerTeamsModel = self.playerDetailModel:GetOtherPlayerTeamsModel()
    local playerCardModelsMap = self.playerDetailModel:GetOtherPlayerCardsMapModel()
    local otherLegendCardsMapModel = self.playerDetailModel:GetOtherPlayerLegendCardModel()
    local otherSceneModel = self.playerDetailModel:GetOtherSceneModel()
    local coachMainModel = self.playerDetailModel:GetCoachMainModel()
    local currentModel = CardBuilder.GetOtherCardModel(pcId, cids, playerCardModelsMap, otherPlayerTeamsModel, otherLegendCardsMapModel, otherSceneModel, coachMainModel)

    local pcidList = {}
    local tempIndex = 1
    local mIndex = nil
    for k,v in pairs(otherPlayerTeamsModel:GetInitPlayersData()) do
        table.insert(pcidList, v)
        if tostring(v) == tostring(pcId) then
            mIndex = tempIndex
        end
        tempIndex = tempIndex + 1
    end
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", mIndex and pcidList or {pcId}, mIndex and mIndex or 1, currentModel, nil, self.bShowMyScene)
end

-- 入口
-- @param hideFunBtn 是否隐藏右侧功能按钮 true:隐藏 不传递就不隐藏
-- @param showIndex 打开面板后显示那个页面,不传递默认打开第一个页面
-- @param arenaType 冠军联赛战区信息
function PlayerDetailCtrl.ShowPlayerDetailView(reqPlayerDetailFunc, pid, sid, hideFunBtn, showIndex, friendManagerModel, specialEventsMatchId, arenaType, bShowMyScene)
    if type(reqPlayerDetailFunc) == "function" then
        clr.coroutine(function()
            local respone = reqPlayerDetailFunc()
            if api.success(respone) then
                local data = respone.val
                res.PushDialog("ui.controllers.playerDetail.PlayerDetailCtrl", data, pid, sid, hideFunBtn, showIndex, friendManagerModel, specialEventsMatchId, arenaType, bShowMyScene)
            end
        end)
    end
end

-- 添加好友
function PlayerDetailCtrl:OnAddFriend(pidTable)
    clr.coroutine(function()
        local respone = req.friendsRequest({pidArray = pidTable})
        if api.success(respone) then
            local data = respone.val
            if data["ok"] then
                DialogManager.ShowToastByLang("friends_applySendHint")
            end
        end
    end)
end

-- 删除好友
function PlayerDetailCtrl:OnDelFriend(pid, sid)
    clr.coroutine(function()
        local respone = req.friendsRemove(pid, sid)
        if api.success(respone) then
            local data = respone.val
            local playerInfoModel = PlayerInfoModel.new()
            local friendNum = playerInfoModel:GetFriendsCount() - 1
            playerInfoModel:SetFriendsCount(friendNum)
            if self.friendManagerModel then
                self.friendManagerModel:UpdateFriendsList(pid)
            end
        end
    end)
end

-- 申请加入公会
function PlayerDetailCtrl:JoinGuild()
    if self.guildDetailModel == nil then
        return
    end
    clr.coroutine(function()
        local respone = req.sendGuildRequest(self.guildDetailModel:GetID())
        if api.success(respone) then
            local data = respone.val
            local isAuto = self.guildDetailModel:GetisAutoRequest()
            if isAuto then
                local respone2 = req.guildIndex()
                if api.success(respone2) then
                    local data2 = respone2.val
                    if data2.base.isExsit == true then
                        res.PushScene("ui.controllers.guild.GuildHomeCtrl", data2) 
                    end
                end
            else
                DialogManager.ShowToastByLang("guild_joinSuccess")
            end
            local server = cache.getCurrentServer()
            local serverCode = server.id
            local serverName = server.name
            local roleId = self.playerInfoModel:GetID()
            local roleName = self.playerInfoModel:GetName()
            local roleLvl = self.playerInfoModel:GetLevel()
			luaevt.trig("SDK_Report", "guild_join", self.guildDetailModel:GetID(), self.guildDetailModel:GetGuildName(), serverCode, serverName, roleId, roleName, roleLvl)
        end
    end)
end

return PlayerDetailCtrl