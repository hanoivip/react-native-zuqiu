local EventSystem = require("EventSystem")
local DreamPlayerListModel = require("ui.models.dreamLeague.dreamPlayerList.DreamPlayerListModel")
local DreamPlayerSearchDecomposeModel = require("ui.models.dreamLeague.dreamPlayerSearch.DreamPlayerSearchDecomposeModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local TeamPageCtrl = class(BaseCtrl)

TeamPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/TeamPage/TeamPage.prefab"

-- 因为该选人界面需要多处复用，但回调不同，可以将回调传入(该回调是从DreamBagCtrl传入的)
function TeamPageCtrl:Refresh(teamPageModel, confirmCallback, onlyNeedPlayerName)
    TeamPageCtrl.super.Refresh(self)
    if teamPageModel then
        self.teamPageModel = teamPageModel
    end
    self.confirmCallback = confirmCallback
    self.onlyNeedPlayerName = onlyNeedPlayerName
    self.dreamLeagueListModel = self.teamPageModel:GetDreamLeagueListModel()
    self.view.onDecomposeClick = function() self:DecomposeClick() end
    self.view.onPlayerClickCallBack = function(playerPageIndex) self:OnPlayerClick(playerPageIndex) end
    self.view:InitView(self.teamPageModel, onlyNeedPlayerName)
end

function TeamPageCtrl:DecomposeClick()
    local allDcids = self.teamPageModel:GetAllDcids()
    local dreamPlayerSearchDecomposeModel = DreamPlayerSearchDecomposeModel.new(allDcids, self.dreamLeagueListModel)
    res.PushDialog("ui.controllers.dreamLeague.dreamPlayerSearch.DreamPlayerSearchDecomposeCtrl", dreamPlayerSearchDecomposeModel)
end

function TeamPageCtrl:OnPlayerClick(playerPageIndex)
    if self.onlyNeedPlayerName then
        local playerName = playerPageIndex.playerName
        self.confirmCallback(playerName)
        return
    end
    
    local teamPageIndex = self.teamPageModel:GetTeamPageIndex()
    playerPageIndex.firstLetter = teamPageIndex.firstLetter
    playerPageIndex.nationName = teamPageIndex.nationName
    playerPageIndex.teamName = teamPageIndex.teamName
    local isSelectMode = self.teamPageModel:GetSelectModeState()
    local dreamPlayerListModel = DreamPlayerListModel.new(playerPageIndex, self.dreamLeagueListModel, isSelectMode)
    res.PushScene("ui.controllers.dreamLeague.dreamPlayerList.DreamPlayerListCtrl", dreamPlayerListModel, self.confirmCallback)
end

function TeamPageCtrl:OnEnterScene()
    EventSystem.AddEvent("DreamPlayerSearchDecomposeCtrl_Refresh", self, self.Refresh)
end

function TeamPageCtrl:OnExitScene()
    EventSystem.RemoveEvent("DreamPlayerSearchDecomposeCtrl_Refresh", self, self.Refresh)
end

function TeamPageCtrl:GetStatusData()
    return self.teamPageModel, self.confirmCallback, self.onlyNeedPlayerName
end

return TeamPageCtrl
