local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GUILD_MEMBERTYPE = require("ui.controllers.guild.GUILD_MEMBERTYPE")
local GuildHomeModel = require("ui.models.guild.GuildHomeModel")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")
local DialogManager = require("ui.control.manager.DialogManager")
local MEMBERTYPE = require("ui.controllers.guild.MEMBERTYPE")
local GUILD_LOGTYPE = require("ui.controllers.guild.GUILD_LOGTYPE")
local GuildWarMainCtrl = require("ui.controllers.guild.guildWar.GuildWarMainCtrl")

local GuildHomeCtrl = class(BaseCtrl)

GuildHomeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildHomeCanvas.prefab"

function GuildHomeCtrl:Init()
    self.guildHomeModel = GuildHomeModel.new()

    self.view.onBtnGuildSettingClick = function()
        res.PushDialog("ui.controllers.guild.GuildSettingCtrl", self.guildHomeModel:GetGuildBaseInfo())
    end

    self.view.onBtnRequestClick = function()
        res.PushDialog("ui.controllers.guild.GuildRequestCtrl")
    end

    self.view.onBtnSettingClick = function()
        self.guildHomeModel:SetMemberManager()
        self.view:SetBtnSettingScale(self.guildHomeModel:GetMemberManager())
    end

    self.view.onBtnChatClick = function()
        res.PushDialog("ui.controllers.chat.ChatMainCtrl", CHAT_TYPE.GUILD)
    end

    self.view.onBtnLogClick = function()
        res.PushScene("ui.controllers.guild.GuildLogCtrl", GUILD_LOGTYPE.ALL)
    end

    self.view.onBtnRankClick = function()
        clr.coroutine(function()
            local respone = req.GetRankPos()
            if api.success(respone) then
                local data = respone.val
                res.PushScene("ui.controllers.guild.GuildRankingCtrl", data)
            end
        end)
    end

    self.view.onBtnArrowClick = function()
        self:MoveThePanel()
        self.guildHomeModel:SetMoveUpState()        
    end

    self.view.onBtnQuitClick = function()
        local authority = self.guildHomeModel:GetMyselfAuthority()
        local memberNum = self.guildHomeModel:GetGuildMemberNum()
        res.PushDialog("ui.controllers.guild.GuildQuitDialogCtrl", authority, memberNum)
    end

    self.view.onBtnSignInClick = function()
        res.PushScene("ui.controllers.guild.GuildSignInCtrl", self.guildHomeModel:GetGuildMemberNum())
    end

    self.view.onBtnChallengeClick = function()
        res.PushScene("ui.controllers.guild.GuildChallengeCtrl")
    end

    self.view.onBtnWarClick = function()
        local myGuildInfo = {}
        myGuildInfo.authority = self.guildHomeModel:GetMyselfAuthority()
        myGuildInfo.pid = self.guildHomeModel:GetSelfPid()
        myGuildInfo.cumulative = self.guildHomeModel:GetCumulativeTotal()
        myGuildInfo.gid = self.guildHomeModel:GetGid()
        GuildWarMainCtrl.GuildWarEntry(myGuildInfo)
    end

    self.view.onBtnVoteClick = function()
        res.PushScene("ui.controllers.guild.guildMistWar.GuildMistVoteCtrl", self.guildHomeModel)
    end
end

function GuildHomeCtrl:MoveThePanel()
    local isUp = self.guildHomeModel:GetMoveUpState()
    if isUp then
        self.view:MoveUpThePanel()
        self.view:SetArrowDownState()
        self.view:SetButtonsState(false)
    else
        self.view:MoveDownThePanel()
        self.view:SetArrowUpState()
        self.view:SetButtonsState(true)
    end
end

function GuildHomeCtrl:Refresh(data)
    self.data = data
    GuildHomeCtrl.super.Refresh(self)
    self:InitView(self.data)
end

function GuildHomeCtrl:GetStatusData()
    return self.data
end

function GuildHomeCtrl:InitView(data)
    self.guildHomeModel:InitWithProtocal(data)
    self.view.gameObject:SetActive(true)
    self:InitInfoView()
    self:InitBottomView()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PushScene("ui.controllers.home.HomeMainCtrl")
        end)
    end)
end

function GuildHomeCtrl:InitInfoView()
    self.view:InitInfoView(self.guildHomeModel:GetGuildBaseInfo(), self)
    self.view:InitButtonState(self.guildHomeModel:GetMyselfAuthority())
    self.view:SetWarEffectState(self.guildHomeModel:GetGuildWarTip())
end

function GuildHomeCtrl:InitBottomView()
    clr.coroutine(function()
        local respone = req.getMemberList()
        if api.success(respone) then
            local data = respone.val
            self.guildHomeModel:SetMemberList(data)
            self.view:InitMemberView(self.guildHomeModel)
            EventSystem.SendEvent("GuildMember_ManagerEvent", self.guildHomeModel:GetMemberManager())
        end
    end)
end

function GuildHomeCtrl:IsShowChatRedPoint()
    if self.view then
        self.view:IsShowChatRedPoint()
    end
end

function GuildHomeCtrl:OnEnterScene()
    EventSystem.AddEvent("MemberItem_SetAuthority", self, self.EventMemberItemClick)
    EventSystem.AddEvent("GuildHome_RefreshMember", self, self.EventRefreshMemberNum)
    EventSystem.AddEvent("GuildSetting_Success", self, self.EventGuildSettingSuccess)
    EventSystem.AddEvent("ReqEventModel_msgGuild", self, self.IsShowChatRedPoint)
    EventSystem.AddEvent("ReqEventModel_guildRequest", self, self.IsShowRequestRedPoint)
end

function GuildHomeCtrl:OnExitScene()
    EventSystem.RemoveEvent("MemberItem_SetAuthority", self, self.EventMemberItemClick)
    EventSystem.RemoveEvent("GuildHome_RefreshMember", self, self.EventRefreshMemberNum)
    EventSystem.RemoveEvent("GuildSetting_Success", self, self.EventGuildSettingSuccess)
    EventSystem.RemoveEvent("ReqEventModel_msgGuild", self, self.IsShowChatRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_guildRequest", self, self.IsShowRequestRedPoint)
end

function GuildHomeCtrl:EventRefreshMemberNum()
    self.guildHomeModel:AddGuildMemberNum()
    self:InitBottomView()
    self:InitInfoView()
end

function GuildHomeCtrl:EventGuildSettingSuccess(data)
    self.guildHomeModel:SetGuildBaseInfo(data)
    self.view:InitInfoView(self.guildHomeModel:GetGuildBaseInfo(), self)
end

function GuildHomeCtrl:EventMemberItemClick(type, itemModel)
    local SETAUTHORITYTYPE = itemModel.GetAuthorityEnum()
    local pid = itemModel:GetPid()
    local name = itemModel:GetName()
    if type == SETAUTHORITYTYPE.UP then
        local authority = itemModel:GetAuthority() - 1

        if itemModel:GetAuthority() == GUILD_MEMBERTYPE.VP then
            DialogManager.ShowConfirmPop(lang.transstr("guild_homeTipTitle"), lang.transstr("guild_homeTip1", name), function()
                clr.coroutine(function()
                    local respone = req.GuildChangeAdmin(pid)
                    if api.success(respone) then
                        local data = respone.val
                        self.guildHomeModel:ChangeMemberAdmin(pid)
                        self:ResetMemberView()
                    end
                end)
            end)
            
        else
            DialogManager.ShowConfirmPop(lang.transstr("guild_homeTipTitle2"),
                lang.transstr("guild_homeTip5", lang.transstr("untranslated_2482"), name), function()
                    clr.coroutine(function()
                        local respone = req.GuildChangePos(pid, authority)
                        if api.success(respone) then
                            local data = respone.val
                            if data.ok == 1 then
                                self.guildHomeModel:ChangeMemberAuthority(pid, authority)
                                self:ResetMemberView()
                                DialogManager.ShowToast(lang.transstr("guild_homeTip2", name, MEMBERTYPE[authority]))
                            end
                        end
                    end)
                end)
        end
    elseif type == SETAUTHORITYTYPE.DOWN then
        local authority = itemModel:GetAuthority() + 1
        DialogManager.ShowConfirmPop(lang.transstr("guild_homeTipTitle2"), 
            lang.transstr("guild_homeTip5", lang.transstr("untranslated_2483"), name), function()
                clr.coroutine(function()
                    local respone = req.GuildChangePos(pid, authority)
                    if api.success(respone) then
                        local data = respone.val
                        if data.ok == 1 then
                            self.guildHomeModel:ChangeMemberAuthority(pid, authority)
                            self:ResetMemberView()
                            DialogManager.ShowToast(lang.transstr("guild_homeTip3", name, MEMBERTYPE[authority]))
                        end
                    end
                end)
            end)
    elseif type == SETAUTHORITYTYPE.OUT then
        DialogManager.ShowConfirmPop(lang.transstr("guild_homeTipTitle2"), 
            lang.transstr("guild_homeTip5", lang.transstr("untranslated_2484"), name), function()
                clr.coroutine(function()
                    local respone = req.GuildKick(pid)
                    if api.success(respone) then
                        local data = respone.val
                        if data.ok == 1 then
                            self.guildHomeModel:RemoveMember(pid)
                            self.guildHomeModel:ReduceGuildMemberNum()
                            self:ResetMemberView()
                            DialogManager.ShowToast(lang.transstr("guild_homeTip4", name))
                            self:InitInfoView()
                        end
                    end
                end)
            end)
    end
end

function GuildHomeCtrl:ResetMemberView()
    self.view:InitMemberView(self.guildHomeModel)    
    EventSystem.SendEvent("GuildMember_ManagerEvent", true)
end

return GuildHomeCtrl
