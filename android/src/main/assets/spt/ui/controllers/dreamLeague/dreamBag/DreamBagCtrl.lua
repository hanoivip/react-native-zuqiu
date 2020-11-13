local DreamBagModel = require("ui.models.dreamLeague.dreamBag.DreamBagModel")
local TeamPageModel = require("ui.models.dreamLeague.teamPage.TeamPageModel")
local DreamPlayerSearchDecomposeModel = require("ui.models.dreamLeague.dreamPlayerSearch.DreamPlayerSearchDecomposeModel")
local EventSystem = require("EventSystem")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamBagCtrl = class(BaseCtrl)

DreamBagCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBag/BagMain.prefab"

-- 因为该选人界面需要多处复用，但回调不同，可以将回调传入(该回调是从DreamPlayerChooseCtrl传入的 or 直接从这里传入)
function DreamBagCtrl:Refresh(dcids, isSelectMode, posIndex, allNations, confirmCallback, onlyNeedPlayerName)
    DreamBagCtrl.super.Refresh(self)
    self.dcids = dcids
    self.isSelectMode = isSelectMode
    self.posIndex = posIndex
    self.allNations = allNations
    self.confirmCallback = confirmCallback
    self.onlyNeedPlayerName = onlyNeedPlayerName
    self.dreamBagModel = DreamBagModel.new(dcids, isSelectMode, posIndex, allNations)
    self.view.onDecomposeClick = function() self:DecomposeClick() end
    self.view.onSearchClick = function(title) self:OnSearchClick(title) end
    self.view.clickNationCallBack = function(teamPageIndex) self:OnClickNation(teamPageIndex) end
    self.view:InitView(self.dreamBagModel, self.posIndex)
end

function DreamBagCtrl:DecomposeClick()
    local allDcids = self.dreamBagModel:GetAllDcids()
    local dreamLeagueListModel = self.dreamBagModel:GetDreamLeagueListModel()
    local dreamPlayerSearchDecomposeModel = DreamPlayerSearchDecomposeModel.new(allDcids, dreamLeagueListModel)
    res.PushDialog("ui.controllers.dreamLeague.dreamPlayerSearch.DreamPlayerSearchDecomposeCtrl", dreamPlayerSearchDecomposeModel)
end

function DreamBagCtrl:OnSearchClick(title)
    local index = 1
    for k,v in pairs(self.view.searchScrollData) do
        if v.firstLetter == title then
            clr.coroutine(function ()
                -- 当手动滑动到最底部时，下一次滚动失效，临时这么改
                self.view.bagScrollView:scrollToCell(index)
                unity.waitForNextEndOfFrame()
                self.view.bagScrollView:scrollToCell(index)
            end)
            return
        end
        index = index + 1
    end
end

function DreamBagCtrl:OnClickNation(teamPageIndex)
    local dreamLeagueListModel = self.dreamBagModel:GetDreamLeagueListModel()
    local isSelectMode = self.dreamBagModel:GetSelectModeState()
    local posIndex = self.dreamBagModel:GetPosIndex()
    local teamPageModel = TeamPageModel.new(teamPageIndex, dreamLeagueListModel, isSelectMode, posIndex)
    res.PushScene("ui.controllers.dreamLeague.teamPage.TeamPageCtrl", teamPageModel, self.confirmCallback, self.onlyNeedPlayerName)
end

function DreamBagCtrl:OnEnterScene()
    EventSystem.AddEvent("DreamPlayerSearchDecomposeCtrl_Refresh", self, self.Refresh)
end

function DreamBagCtrl:OnExitScene()
    EventSystem.RemoveEvent("DreamPlayerSearchDecomposeCtrl_Refresh", self, self.Refresh)
end

function DreamBagCtrl:GetStatusData()
    return self.dcids, self.isSelectMode, self.posIndex, self.allNations, self.confirmCallback, self.onlyNeedPlayerName
end

return DreamBagCtrl
