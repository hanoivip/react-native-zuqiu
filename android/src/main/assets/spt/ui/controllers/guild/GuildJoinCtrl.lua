local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildJoinModel = require("ui.models.guild.GuildJoinModel")
local DialogManager = require("ui.control.manager.DialogManager")

local GuildJoinCtrl = class(BaseCtrl)

GuildJoinCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildJoinCanvas.prefab"

function GuildJoinCtrl:Init()
    --初次进入谈窗口
    self:AutoInvitation()

    self.guildJoinModel = GuildJoinModel.new()

    self.view.onBtnRefreshClick = function()
        clr.coroutine(function()
            local isSearch = self.guildJoinModel:GetSearchState()
            if not isSearch then
                local respone = req.getPriorityGuild()
                if api.success(respone) then
                    local data = respone.val
                    self.guildJoinModel:InitWithProtocal(data)
                end
            end
            self.guildJoinModel:SetSearchState(false)
            self.view:InitView(self.guildJoinModel:GetGuildList())
        end)
    end

    self.view.onBtnSearchClick = function()
        local content = self.view:GetInputText()
        if string.len(content) > 0 then
            clr.coroutine(function()
                local respone = req.searchGuild(content)
                if api.success(respone) then
                    local data = respone.val
                    local list = {}

                    if #data <= 10 then
                        list = data
                        self.view:InitView(list)
                        self.guildJoinModel:SetSearchState(true)
                    elseif #data <= 20 then
                        DialogManager.ShowConfirmPop(lang.transstr("guild_joinFindTitle"), lang.transstr("guild_joinFindTip1"), function()
                            for i = 1, 10 do 
                                table.insert(list, data[i])
                            end
                            self.view:InitView(list)
                            self.guildJoinModel:SetSearchState(true)
                        end)
                    else
                        DialogManager.ShowToastByLang("guild_joinFindTip2")
                    end
                    
                end
            end)
        else
            self.view:InitView(self.guildJoinModel:GetGuildList())
        end
    end

    self.view.onBtnCreateGuild = function()
        res.PushDialog("ui.controllers.guild.GuildCreateCtrl")
    end

    self.view.onBtnJoinGuild = function()
        clr.coroutine(function()
            local respone = req.sendGuildRequest(self.guildJoinModel:GetCurrentGid())
            if api.success(respone) then
                local data = respone.val
                local itemModel = self.guildJoinModel:GetCurrentItemModel()
                local isAuto = itemModel:GetisAutoRequest()
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
                local playerInfoModel = require("ui.models.PlayerInfoModel").new()
                local roleId = playerInfoModel:GetID()
                local roleName = playerInfoModel:GetName()
                local roleLvl = playerInfoModel:GetLevel()
				luaevt.trig("SDK_Report", "guild_join", itemModel:GetGid(), itemModel:GetName(), serverCode, serverName, roleId, roleName, roleLvl)
            end
            self.guildJoinModel:AddRequestGuild(self.guildJoinModel:GetCurrentGid())
            self:EventSelectedItemReceive(self.guildJoinModel:GetCurrentItemModel())
        end)
    end
end

function GuildJoinCtrl:AutoInvitation()
    if cache.getGuildFirstEnter() then
        clr.coroutine(function()
            local response = req.GetGuildAutoInviteGuilds()
            if api.success(response) then
                local data = response.val
                if data and next(data) then
                    res.PushDialog("ui.controllers.guild.GuildInvitationCtrl", data) 
                end
            end
        end)
    end
end

function GuildJoinCtrl:Refresh()
    GuildJoinCtrl.super.Refresh(self)   
    self:InitView()
end

function GuildJoinCtrl:InitView()
    clr.coroutine(function()
        local respone = req.getPriorityGuild()
        if api.success(respone) then
            local data = respone.val
            self.guildJoinModel:InitWithProtocal(data)
            self.view:InitView(self.guildJoinModel:GetGuildList())
            self.view.gameObject:SetActive(true)
        end
    end)
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
end

function GuildJoinCtrl:EventSelectedItemReceive(itemModel)
    if itemModel then
        self.guildJoinModel:SetCurrentItemModel(itemModel)
        
        local notice = itemModel:GetMsg()
        local isAuto = itemModel:GetisAutoRequest()
        local levelReach = self.guildJoinModel:CheckLevelReach(itemModel:GetMinPlayerLvl())
        local numFull = self.guildJoinModel:CheckMemberFull(itemModel:GetMemberNum())
        local hasReq = self.guildJoinModel:CheckRequestGuild(itemModel:GetGid())
        self.view:InitNoticeView(notice, numFull, levelReach, isAuto, hasReq)
    else
        self.view:HideNoticeView()
    end
end

function GuildJoinCtrl:OnEnterScene()
    EventSystem.AddEvent("GuildJoinScrollerView_ItemClick", self, self.EventSelectedItemReceive)
end

function GuildJoinCtrl:OnExitScene()
    EventSystem.SendEvent("GuildJoinScrollerView_ItemClick", nil)    
    EventSystem.RemoveEvent("GuildJoinScrollerView_ItemClick", self, self.EventSelectedItemReceive)
end

return GuildJoinCtrl
