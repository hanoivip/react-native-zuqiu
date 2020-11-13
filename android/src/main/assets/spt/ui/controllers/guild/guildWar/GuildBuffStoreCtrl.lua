local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildBuffStoreModel = require("ui.models.guild.guildWar.GuildBuffStoreModel")

local GuildBuffStoreCtrl = class(BaseCtrl, "GuildBuffStoreCtrl")

GuildBuffStoreCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildBuffStore.prefab"

GuildBuffStoreCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GuildBuffStoreCtrl:Init(attackOrDefenseModel, isAttackBuff, nextRound)
    clr.coroutine(function ()
        local response = req.buffInfo(nextRound or attackOrDefenseModel:GetRound())
        if api.success(response) then
            local buffInfo = response.val
            local guildBuffStoreModel = GuildBuffStoreModel.new(attackOrDefenseModel, buffInfo)
            self.view:InitView(guildBuffStoreModel, isAttackBuff, nextRound, buffInfo)
        end
    end)
end

return GuildBuffStoreCtrl