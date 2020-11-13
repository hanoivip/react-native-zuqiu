local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildBuffStoreType = require("ui/models/guild/guildMistWar/GuildBuffStoreType")
local GuildMistWarBuffStoreModel = require("ui.models.guild.guildMistWar.GuildMistWarBuffStoreModel")

local GuildMistWarBuffStoreCtrl = class(BaseCtrl, "GuildMistWarBuffStoreCtrl")

GuildMistWarBuffStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarBuffStore.prefab"

function GuildMistWarBuffStoreCtrl:AheadRequest(guildMistWarMainModel, round)
    local response = req.guildWarMistShopInfo()
    if api.success(response) then
        local data = response.val
        self.model = GuildMistWarBuffStoreModel.new(round)
        self.model:SetGuildMistWarMainModel(guildMistWarMainModel)
        self.model:InitWithProtocol(data)
    end
end

function GuildMistWarBuffStoreCtrl:Init(guildMistWarMainModel)
    self.view.buyBuffClick = function(keyId) self:OnBuyBuff(keyId) end
    self.view.buyItemClick = function(keyId) self:OnBuyItem(keyId) end
end

function GuildMistWarBuffStoreCtrl:Refresh(guildMistWarMainModel)
    GuildMistWarBuffStoreCtrl.super.Refresh(self)
    self.view:InitView(self.model)
end

function GuildMistWarBuffStoreCtrl:OnBuyBuff(keyId)
    self.view:coroutine(function()
        local round = self.model:GetSelectRound()
        local nowRound = self.model:GetNowRound()
        if round >= nowRound then
            local response = req.guildWarBuyBuffMist(round,  keyId)
            if api.success(response) then
                local data = response.val
                if data.atkBuff then
                    self.model:SetAtkBuff(round, data.atkBuff)
                else
                    self.model:SetDefBuff(round, data.defBuff)
                end
                self.model:SetCumulativeTotal(data.cumulativeDay)
                self.view:InitView(self.model, GuildBuffStoreType.BuffTag)
            end
        else
            DialogManager.ShowToastByLang("guild_mist_buff_end")
        end
    end)
end

function GuildMistWarBuffStoreCtrl:OnBuyItem(keyId)
    self.view:coroutine(function()
        local response = req.guildWarBuyMistItem(keyId)
        if api.success(response) then
            local data = response.val
            self.model:SetItemStoreServerList(data.map)
            self.model:SetCumulativeTotal(data.cumulativeDay)
            self.view:InitView(self.model, GuildBuffStoreType.ItemTag)
            DialogManager.ShowToastByLang("buy_item_success")
        end
    end)
end

return GuildMistWarBuffStoreCtrl
