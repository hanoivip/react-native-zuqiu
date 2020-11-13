local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildMistWarMap = require("data.GuildMistWarMap")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildMistChooseMapCtrl = class(BaseCtrl, "GuildMistChooseMapCtrl")
local GuildMistChooseMapModel = require("ui.models.guild.guildMistWar.GuildMistChooseMapModel")

GuildMistChooseMapCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistChooseMap.prefab"

function GuildMistChooseMapCtrl:AheadRequest(round)
    local response = req.guildWarMistMapInfo()
    if api.success(response) then
        local data =response.val
        self.model = GuildMistChooseMapModel.new()
        self.model:InitWithProtocol(data)
        self.model:SetRound(round)
    end
end

function GuildMistChooseMapCtrl:Init(round)
    self.view.onApplyClick = function(mapId) self:OnClickApply(mapId) end
end

function GuildMistChooseMapCtrl:Refresh()
    self.view:InitView(self.model)
end

function GuildMistChooseMapCtrl:OnClickApply(mapId)
    local mapIdStr = tostring(mapId)
    local mapData = GuildMistWarMap[mapIdStr]
    local title = lang.trans("tips")
    local content = lang.trans("mist_map_change", mapData.name)
    DialogManager.ShowConfirmPop(title, content, function()
            self:Apply(mapId)
    end)
end

function GuildMistChooseMapCtrl:Apply(mapId)
    local round = self.model:GetRound()
    self.view:coroutine(function ()
        local response = req.guildWarSelectMistMap(round, mapId)
        if api.success(response) then
            local data = response.val
            self.model:RefreshData(data)
            self.view:Close()
            DialogManager.ShowToastByLang("mist_map_success")
            --self.view:InitView(self.model)
        end
    end)
end

return GuildMistChooseMapCtrl
