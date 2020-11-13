local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local System = UnityEngine.System
local Collections = System.Collections
local TextAsset = UnityEngine.TextAsset
local Object = UnityEngine.Object
local Resources = UnityEngine.Resources

local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local MatchLoader = require("coregame.MatchLoader")
local MatchInfoModel = require("ui.models.MatchInfoModel")

local PreMatchManager = class(unity.base)

function PreMatchManager:ctor()
    self.teamMatchPanel = self.___ex.teamMatchPanel
    self.homeTeamInfoPanel = self.___ex.homeTeamInfoPanel
    self.awayTeamInfoPanel = self.___ex.awayTeamInfoPanel
    self.skipButton = self.___ex.skipButton
end

function PreMatchManager:start()
    collectgarbage()
    clr.System.GC.Collect()
    self:BindAll()
    self:RegisterEvent()
    local matchInfoModel = MatchInfoModel.GetInstance()
    if matchInfoModel:IsDemoMatch() then
        self.skipButton.gameObject:SetActive(false)
    end
end

function PreMatchManager:BindAll()
    self.skipButton:regOnButtonClick(function()
        GameHubWrap.MatchOpening()
        ___deadBallTimeManager:SetSkipMatchOpening()
    end)
end

--- 注册事件
function PreMatchManager:RegisterEvent()
    EventSystem.AddEvent("PreMatchManager.SwitchToHomeTeamInfoPanel", self, self.SwitchToHomeTeamInfoPanel)
    EventSystem.AddEvent("PreMatchManager.SwitchToAwayTeamInfoPanel", self, self.SwitchToAwayTeamInfoPanel)
    EventSystem.AddEvent("PreMatchManager.StartMatch", self, self.StartMatch)
end

--- 移除事件
function PreMatchManager:RemoveEvent()
    EventSystem.RemoveEvent("PreMatchManager.SwitchToHomeTeamInfoPanel", self, self.SwitchToHomeTeamInfoPanel)
    EventSystem.RemoveEvent("PreMatchManager.SwitchToAwayTeamInfoPanel", self, self.SwitchToAwayTeamInfoPanel)
    EventSystem.RemoveEvent("PreMatchManager.StartMatch", self, self.StartMatch)
end

function PreMatchManager:SwitchToHomeTeamInfoPanel()
    EventSystem.SendEvent("CommentaryManager.PlayShowFormationAudio")
    self.teamMatchPanel:SetActive(false)
    self.homeTeamInfoPanel:SetActive(true)
end

function PreMatchManager:SwitchToAwayTeamInfoPanel()
    self.homeTeamInfoPanel:SetActive(false)
    self.awayTeamInfoPanel:SetActive(true)
end

function PreMatchManager:StartMatch()
    EventSystem.SendEvent("Match_PlayerEnterCourt")
    GameHubWrap.MatchOpening()
end

function PreMatchManager:onDestroy()
    self:RemoveEvent()
end

return PreMatchManager
