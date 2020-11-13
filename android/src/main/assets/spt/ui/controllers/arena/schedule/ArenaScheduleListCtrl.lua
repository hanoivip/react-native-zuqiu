local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local ArenaTeamMatchModel = require("ui.models.arena.schedule.ArenaTeamMatchModel")
local ArenaKnockoutModel = require("ui.models.arena.schedule.ArenaKnockoutModel")
local GroupPageCtrl = require("ui.controllers.arena.schedule.GroupPageCtrl")
local ArenaOutPageCtrl = require("ui.controllers.arena.schedule.ArenaOutPageCtrl")
local ArenaOutSchedulePageCtrl = require("ui.controllers.arena.schedule.ArenaOutSchedulePageCtrl")
local ScheduleListPageType = require("ui.scene.arena.schedule.ScheduleListPageType")
local RuleType = require("ui.scene.arena.RuleType")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ArenaScheduleListCtrl = class(BaseCtrl, "CourtMainCtrl")

ArenaScheduleListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ScheduleList.prefab"

function ArenaScheduleListCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
    end)
    self.matchPageMap = {}
    self.page = ScheduleListPageType.MatchPage

    self.view.clickPage = function(key) self:OnBtnPage(key) end
    self.view.clickRule = function() self:OnClickRule() end
end

function ArenaScheduleListCtrl:OnClickRule()
    local selectRule
    if self.page == ScheduleListPageType.MatchPage then
        selectRule = RuleType.GroupType
    elseif self.page == ScheduleListPageType.KnockoutPage or self.page == ScheduleListPageType.SchedulePage then
        selectRule = RuleType.KnockoutType
    end
    res.PushScene("ui.controllers.arena.ArenaRuleCtrl", selectRule)
end

function ArenaScheduleListCtrl:Refresh(page, arenaType)
    ArenaScheduleListCtrl.super.Refresh(self)
    self.arenaType = arenaType
    self.view:InitView(page)
end

function ArenaScheduleListCtrl:GetStatusData()
    return self.page, self.arenaType
end

function ArenaScheduleListCtrl:ShowKnockoutPage(view)
    if not self.scheduleModel then
        clr.coroutine(function()
            local response = req.getArenaOutScheduleBoard(self.arenaType)
            if api.success(response) then
                local data = response.val
                self.scheduleModel = ArenaKnockoutModel.new()
                self.scheduleModel:InitWithProtocol(data)
                view:InitView(self.scheduleModel)
            end
        end)
    else
        view:InitView(self.scheduleModel)
    end
end

function ArenaScheduleListCtrl:OnBtnPage(key)
    if self.matchPageMap[self.page] then 
        self.matchPageMap[self.page]:ShowPageVisible(false)
    end

    if not self.matchPageMap[key] then 
        if key == ScheduleListPageType.MatchPage then 
            self.matchPageMap[key] = GroupPageCtrl.new(nil, self.view.pageArea)
        elseif key == ScheduleListPageType.KnockoutPage then 
            self.matchPageMap[key] = ArenaOutPageCtrl.new(nil, self.view.pageArea)
        elseif key == ScheduleListPageType.SchedulePage then 
            self.matchPageMap[key] = ArenaOutSchedulePageCtrl.new(nil, self.view.pageArea)
        end
        self.matchPageMap[key]:EnterScene()
    end
    self.matchPageMap[key]:InitView(self.arenaType)

    self.matchPageMap[key]:ShowPageVisible(true)
    self.page = key
end

function ArenaScheduleListCtrl:OnEnterScene()
    self.view:EnterScene()
    for k, v in pairs(self.matchPageMap) do
        v:EnterScene()
    end
end

function ArenaScheduleListCtrl:OnExitScene()
    self.view:ExitScene()
    for k, v in pairs(self.matchPageMap) do
        v:ExitScene()
    end
    ArenaTeamMatchModel.ClearInstance()
    ArenaKnockoutModel.ClearInstance()
end

return ArenaScheduleListCtrl
