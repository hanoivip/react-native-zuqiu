local ArenaKnockoutModel = require("ui.models.arena.schedule.ArenaKnockoutModel")
local ArenaOutPageCtrl = class(nil, "ArenaOutPageCtrl")

function ArenaOutPageCtrl:ctor(view, content)
    self:Init(content)
end

function ArenaOutPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaOutPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
end

function ArenaOutPageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function ArenaOutPageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function ArenaOutPageCtrl:InitView(arenaType)
    local arenaKnockoutModel = ArenaKnockoutModel.GetInstance()
    if not arenaKnockoutModel then
        clr.coroutine(function()
            local response = req.getArenaOutScheduleBoard(arenaType)
            if api.success(response) then
                local data = response.val
                arenaKnockoutModel = ArenaKnockoutModel.new()
                arenaKnockoutModel:InitWithProtocol(data)
                self.pageView:InitView(arenaKnockoutModel, arenaType)
            end
        end)
    else
        self.pageView:InitView(arenaKnockoutModel, arenaType)
    end
end

function ArenaOutPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return ArenaOutPageCtrl
