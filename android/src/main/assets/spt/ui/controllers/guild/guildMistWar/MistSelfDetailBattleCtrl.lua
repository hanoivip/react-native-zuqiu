local MistSelfDetailBattleModel = require("ui.models.guild.guildMistWar.MistSelfDetailBattleModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MistSelfDetailBattleCtrl = class(BaseCtrl, "MistSelfDetailBattleCtrl")

MistSelfDetailBattleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistSelfDetailBattle.prefab"

function MistSelfDetailBattleCtrl:AheadRequest(guildMistWarMainModel)
    local round = guildMistWarMainModel:GetRound()
    self.guildMistWarMainModel = guildMistWarMainModel
    local response = req.guildWarMemberInfoMist(round)
    if api.success(response) then
        local data =response.val
        self.model = MistSelfDetailBattleModel.new()
        self.model:InitWithProtocol(data)
    end
end

function MistSelfDetailBattleCtrl:Refresh()
    self.view:InitView(self.model)
end

function MistSelfDetailBattleCtrl:GetStatusData()
    return self.guildMistWarMainModel
end

return MistSelfDetailBattleCtrl
