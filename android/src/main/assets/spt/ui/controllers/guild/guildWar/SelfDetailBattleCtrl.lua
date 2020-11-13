local SelfDetailBattleModel = require("ui.models.guild.guildWar.SelfDetailBattleModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local SelfDetailBattleCtrl = class(BaseCtrl, "SelfDetailBattleCtrl")

SelfDetailBattleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/SelfDetailBattle.prefab"

SelfDetailBattleCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function SelfDetailBattleCtrl:Init(gid)
    clr.coroutine(function ()
        local response = req.getMemberInfo()
        if api.success(response) then
            local data =response.val
            local model = SelfDetailBattleModel.new(gid)
            model:InitWithProtocal(data)
            self.view:InitView(model)
        end
    end)
end

return SelfDetailBattleCtrl