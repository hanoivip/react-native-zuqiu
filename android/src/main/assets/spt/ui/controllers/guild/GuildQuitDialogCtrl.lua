local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildQuitDialogModel = require("ui.models.guild.GuildQuitDialogModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GUILD_MEMBERTYPE = require("ui.controllers.guild.GUILD_MEMBERTYPE")
local DialogManager = require("ui.control.manager.DialogManager")
local UnityEngine = clr.UnityEngine

local GuildQuitDialogCtrl = class(BaseCtrl)

GuildQuitDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildQuitDialog.prefab"

function GuildQuitDialogCtrl:Init()
    self.guildQuitDialogModel = GuildQuitDialogModel.new()
    self.playerInfoModel = PlayerInfoModel.new()
end

function GuildQuitDialogCtrl:Refresh(authority, memberNum)
    local title = ""
    local content = ""
    if authority == GUILD_MEMBERTYPE.ADMIN then 
        if memberNum  == 1 then
            title = lang.transstr("guild_quitTipTitle1")
            content = lang.transstr("guild_quitTip1")
            self.view.onBtnComfirmClick = function()
                clr.coroutine(function()
                    local respone = req.GuildDismiss()
                    if api.success(respone) then
                        local data = respone.val
                        if data.ok == 1 then
                            self.playerInfoModel:SetGuild(nil)
                            res.PushScene("ui.controllers.home.HomeMainCtrl")
                            DialogManager.ShowToastByLang("guild_quitSuccess1")
                        else
                            self.view:Close()                            
                        end
                    else
                        self.view:Close()
                    end
                end)
            end
        else
            title = lang.transstr("guild_quitTipTitle2")
            content = lang.transstr("guild_quitTip2")
            self.view.onBtnComfirmClick = function()
                clr.coroutine(function()
                    local respone = req.GuildQuit()
                    if api.success(respone) then
                        local data = respone.val
                        if data.ok == 1 then
                            self.playerInfoModel:SetGuild(nil)
                            res.PushScene("ui.controllers.home.HomeMainCtrl")
                            DialogManager.ShowToastByLang("guild_quitSuccess2")
                        else
                            self.view:Close()                            
                        end
                    else
                        self.view:Close()
                    end
                end)
            end
        end
    else
        title = lang.transstr("guild_quitTipTitle2")
        content = lang.transstr("guild_quitTip3")
        self.view.onBtnComfirmClick = function()
            clr.coroutine(function()
                local respone = req.GuildQuit()
                if api.success(respone) then
                    local data = respone.val
                    if data.ok == 1 then
                        self.playerInfoModel:SetGuild(nil)
                        res.PushScene("ui.controllers.home.HomeMainCtrl")
                        DialogManager.ShowToastByLang("guild_quitSuccess2")
                    else
                        self.view:Close()                    
                    end
                else
                    self.view:Close()
                end
            end)
        end
    end
    self.guildQuitDialogModel:SetTitle(title)
    self.guildQuitDialogModel:SetContent(content)
    self:InitView()
end

function GuildQuitDialogCtrl:InitView()
    self.view:InitView(self.guildQuitDialogModel)
end

function GuildQuitDialogCtrl:OnEnterScene()
end

function GuildQuitDialogCtrl:OnExitScene()
end

return GuildQuitDialogCtrl