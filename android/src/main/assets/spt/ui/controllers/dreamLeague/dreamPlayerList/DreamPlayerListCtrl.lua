local DreamPlayerSearchDecomposeModel = require("ui.models.dreamLeague.dreamPlayerSearch.DreamPlayerSearchDecomposeModel")
local DreamPlayerSearchFilterModel = require("ui.models.dreamLeague.dreamPlayerSearch.DreamPlayerSearchFilterModel")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local DreamPlayerListCtrl = class(BaseCtrl)

DreamPlayerListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamPlayerList/DreamPlayerList.prefab"

-- 因为该选人界面需要多处复用，但回调不同，可以将回调传入(该回调是从TeamPageCtrl传入的)
function DreamPlayerListCtrl:Refresh(dreamPlayerListModel, confirmCallback)
    DreamPlayerListCtrl.super.Refresh(self)
    if dreamPlayerListModel then
        self.dreamPlayerListModel = dreamPlayerListModel
    end
    self.confirmCallback = confirmCallback
    self.dreamPlayerListModel:SetDecomposeCallBack(function(dcid) self:DecomposeCardCallBack(dcid) end)
    self.dreamPlayerListModel:SetCheckBoxCallBack(function(selectState, dcid) self:SelectCardCallBack(selectState, dcid) end)
    self.view.onDecomposeClick = function() self:DecomposeClick() end
    self.view.onSelectFilterBtn = function() self:SelectFilterClick() end
    self.view.onConfirmClick = function() self:ConfirmClick() end
    self.view:InitView(self.dreamPlayerListModel)
end

function DreamPlayerListCtrl:Init()
end

function DreamPlayerListCtrl:DecomposeClick()
    local allDcids = self.dreamPlayerListModel:GetAllDcids()
    local dreamLeagueListModel = self.dreamPlayerListModel:GetDreamLeagueListModel()
    local dreamPlayerSearchDecomposeModel = DreamPlayerSearchDecomposeModel.new(allDcids, dreamLeagueListModel)
    res.PushDialog("ui.controllers.dreamLeague.dreamPlayerSearch.DreamPlayerSearchDecomposeCtrl", dreamPlayerSearchDecomposeModel)
end

function DreamPlayerListCtrl:SelectFilterClick()
    local allDcids = self.dreamPlayerListModel:GetAllDcids()
    local dreamLeagueListModel = self.dreamPlayerListModel:GetDreamLeagueListModel()
    local dreamPlayerSearchFilterModel = DreamPlayerSearchFilterModel.new(allDcids, dreamLeagueListModel)
    res.PushDialog("ui.controllers.dreamLeague.dreamPlayerSearch.DreamPlayerSearchFilterCtrl", dreamPlayerSearchFilterModel)
end

function DreamPlayerListCtrl:ConfirmClick()
    local selectDcid = self.dreamPlayerListModel:GetSelectDcid()

    if self.confirmCallback then
        self.confirmCallback(selectDcid)
        return
    end

    local addPlayer = function()
        clr.coroutine(function()
            local response = req.dreamLeagueTeamAddDreamCard(selectDcid)
            if api.success(response) then
                local data = response.val
                -- 1是玩家锁，2是系统锁
                PlayerDreamCardsMapModel.new():ResetCardLock(selectDcid, DreamConstants.DreamCardLockState.SYSTEM_LOCK)
                res.PopAppointSceneImmediate(3)
            end
        end)
    end
    if not selectDcid then
        DialogManager.ShowToast(lang.trans("none_player_choose"))
        return
    end
    local dreamLeagueCardModel = DreamLeagueCardModel.new(selectDcid)
    local selectName = dreamLeagueCardModel:GetName()
    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("dream_add_player_confirm", selectName),
    function() 
            addPlayer()
    end)
end

function DreamPlayerListCtrl:SetScrollDataFilter(scrollDataFilter)
    self.dreamPlayerListModel:SetScrollDataFilter(scrollDataFilter)
end

function DreamPlayerListCtrl:OnEnterScene()
    EventSystem.AddEvent("DreamPlayerSearchDecomposeCtrl_Refresh", self, self.Refresh)
    EventSystem.AddEvent("DreamPlayerSearchFilterCtrl_Refresh", self, self.Refresh)
    EventSystem.AddEvent("DreamPlayerSearchFilterCtrl_SetScrollDataFilter", self, self.SetScrollDataFilter)
    EventSystem.AddEvent("DreamLeagueCardView_SetSelectCard", self, self.SetSelectCard)
end

function DreamPlayerListCtrl:OnExitScene()
    EventSystem.RemoveEvent("DreamPlayerSearchDecomposeCtrl_Refresh", self, self.Refresh)
    EventSystem.RemoveEvent("DreamPlayerSearchFilterCtrl_Refresh", self, self.Refresh)
    EventSystem.RemoveEvent("DreamPlayerSearchFilterCtrl_SetScrollDataFilter", self, self.SetScrollDataFilter)
    EventSystem.RemoveEvent("DreamLeagueCardView_SetSelectCard", self, self.SetSelectCard)
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

function DreamPlayerListCtrl:SetSelectCard(selectObj, model)
    local dcid = model:GetDcid()
    if self.preSelectObj and self.selectDcid ~= dcid then
        GameObjectHelper.FastSetActive(self.preSelectObj, false)
        self.premodel.selectState = false
        EventSystem.SendEvent("DreamLeagueCardView_HideSelect", dcid)
    end

    -- 之前这块只考虑了选中，当再次点击时，还有取消的状态没考虑
    if dcid == (self.premodel and self.premodel:GetDcid()) then
        GameObjectHelper.FastSetActive(selectObj, not self.premodel.selectState)
        self.premodel.selectState = not self.premodel.selectState
        return
    end

    model.selectState = true
    GameObjectHelper.FastSetActive(selectObj, true)
    self.preSelectObj = selectObj
    self.selectDcid = dcid
    self.premodel = model
end

function DreamPlayerListCtrl:DecomposeCardCallBack(dcid)
    local dreamLeagueListModel = self.dreamPlayerListModel:GetDreamLeagueListModel()
    dreamLeagueListModel:DelCard(tostring(dcid))
    self:Refresh()
end

function DreamPlayerListCtrl:SelectCardCallBack(selectState, dcid)
    self.dreamPlayerListModel:SetSelectDcid(selectState, dcid)
end

function DreamPlayerListCtrl:GetStatusData()
    return self.dreamPlayerListModel, self.confirmCallback
end

return DreamPlayerListCtrl
