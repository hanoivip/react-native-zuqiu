local BaseCtrl = require("ui.controllers.BaseCtrl")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildWarTypeSelectModel = require("ui.models.guild.guildMistWar.GuildWarTypeSelectModel")

local GuildWarTypeSelectCtrl = class(BaseCtrl, "GuildWarTypeSelectCtrl")

GuildWarTypeSelectCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildWarTypeSelect.prefab"

function GuildWarTypeSelectCtrl:ctor()
    GuildWarTypeSelectCtrl.super.ctor(self)
end

function GuildWarTypeSelectCtrl:AheadRequest(guildInfo)
    if self.model == nil then
        self.model = GuildWarTypeSelectModel.new()
    end
    local response = req.guildWarMainInfo()
    if api.success(response) then
        local data = response.val
        if type(data) == "table" and next(data) then
            self.model:InitWithProtocol(data)
        end
    end
end

function GuildWarTypeSelectCtrl:Init(guildInfo)
    self.view.onBtnNormalClick = function() self:OnBtnNormalClick() end
    self.view.onBtnMistClick = function() self:OnBtnMistClick() end

    self.model:SetGuildInfo(guildInfo)
    self.view:InitView(self.model)
end

function GuildWarTypeSelectCtrl:Refresh(guildInfo)
    GuildWarTypeSelectCtrl.super.Refresh(self)
    self.view:RefreshView()
end

-- 点击标准战场
function GuildWarTypeSelectCtrl:OnBtnNormalClick()
    local guildInfo = self.model:GetGuildInfo()
    self.view:coroutine(function()
        local response = req.getGuildWarInfo()
        if api.success(response) then
            local data = response.val
            res.PopScene()
            if data.state == GUILDWAR_STATE.FIGHTING then
                if data.settlementInfo.schedule and table.nums(data.settlementInfo.schedule) == 1 then
                    guildInfo.settlementInfo = data.settlementInfo
                    guildInfo.settlementInfo.hasShow = false
                end
                res.PushScene("ui.controllers.guild.guildWar.GuildWarAttackCtrl", guildInfo)
            else
                if data.settlementInfo.schedule and table.nums(data.settlementInfo.schedule) > 1 then
                    data.settlementInfo.hasShow = false
                end
                data.guildInfo = guildInfo
                res.PushScene("ui.controllers.guild.guildWar.GuildWarEnrollCtrl", data)
            end
        end
    end)
end

-- 点击迷雾战场
function GuildWarTypeSelectCtrl:OnBtnMistClick()
    res.PopScene()
    res.PushScene("ui.controllers.guild.guildMistWar.GuildMistWarMainCtrl")
end

return GuildWarTypeSelectCtrl
