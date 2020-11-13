local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildCreateModel = require("ui.models.guild.GuildCreateModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local UnityEngine = clr.UnityEngine

local GuildCreateCtrl = class(BaseCtrl)

GuildCreateCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildCreate.prefab"

function GuildCreateCtrl:Init()
    self.guildCreateModel = GuildCreateModel.new()
    self.view.createGuildFunc = function()
        local name = self.view:GetInputText()
        local eid = self.guildCreateModel:GetCurrentIndex()
        if string.len(name) > 0 then
            DialogManager.ShowConfirmPopByLang(lang.transstr("guild_createTitle"), lang.transstr("guild_createTip1"), function()
                local costDiamond = self.guildCreateModel:GetPrice()
                CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
                    clr.coroutine(function()
                        local response = req.createGuild(name, eid)
                        if api.success(response) then
                            local data = response.val
			    local playerInfoModel = PlayerInfoModel.new()
                            if type(data.cost) == "table" then
                                if data.cost["type"] == "d" then
                                    playerInfoModel:AddDiamond(-1 * data.cost.num)
                                    local consumeType = 3
                                    local mInfo = {}
                                    mInfo.phylum = "guild"
                                    mInfo.classfield = "create"
                                    CustomEvent.ConsumeDiamond(consumeType, tonumber(data.cost.num), mInfo)
                                end
                            end
                            res.PushScene("ui.controllers.guild.GuildHomeCtrl", data)
							local gid = data.base and data.base.gid
                            local server = cache.getCurrentServer()
                            local serverCode = server.id
                            local serverName = server.name
                            local roleId = playerInfoModel:GetID()
                            local roleName = playerInfoModel:GetName()
                            local roleLvl = playerInfoModel:GetLevel()
							luaevt.trig("SDK_Report", "guild_create", gid, name, serverCode, serverName, roleId, roleName, roleLvl)
                        end
                    end)
                end)
            end)
        else
            DialogManager.ShowToastByLang("guild_createTip2")
        end
    end

    self.view.chooseIconFunc = function()
        self.view:InitScrollerView(self.guildCreateModel:GetIconInfo())
        self.view:PlayShowAnimation()
        EventSystem.SendEvent("Guild_LogoItemClick", self.guildCreateModel:GetCurrentIndex())        
    end
    self.view.onBtnCancelClick = function()
        self.guildCreateModel:SetChooseIndex(self.guildCreateModel:GetCurrentIndex())
        self:InitIconView()
        self.view:PlayLeaveAnimation()
    end
    self.view.onBtnComfirmClick = function()
        self.guildCreateModel:SetCurrentIndex(self.guildCreateModel:GetChooseIndex())
        self:InitIconView()
        self.view:PlayLeaveAnimation()
    end

end

function GuildCreateCtrl:Refresh()
    GuildCreateCtrl.super.Refresh(self)            
    self:InitIconView()
end

function GuildCreateCtrl:InitIconView()
    self.view:InitIconImg(self.guildCreateModel:GetChooseIndex())
end

function GuildCreateCtrl:EventLogoItemClick(index)
    self.guildCreateModel:SetChooseIndex(index)
end

function GuildCreateCtrl:OnEnterScene()
    EventSystem.AddEvent("Guild_LogoItemClick", self, self.EventLogoItemClick)
end

function GuildCreateCtrl:OnExitScene()
    EventSystem.RemoveEvent("Guild_LogoItemClick", self, self.EventLogoItemClick)
end

return GuildCreateCtrl