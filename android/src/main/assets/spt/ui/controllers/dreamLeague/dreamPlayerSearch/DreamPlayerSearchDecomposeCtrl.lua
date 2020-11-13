local EventSystem = require ("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamPlayerSearchDecomposeCtrl = class(BaseCtrl)

DreamPlayerSearchDecomposeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamPlaySearch/DreamPlayerSearchDecomposeBoard.prefab"

function DreamPlayerSearchDecomposeCtrl:Refresh(dreamPlayerSearchModel)
    self.dreamPlayerSearchModel = dreamPlayerSearchModel
    self.dreamLeagueListModel = dreamPlayerSearchModel:GetDreamLeagueListModel()
    self.view:InitView(dreamPlayerSearchModel)
    self.view.clickConfirm = function(selectPos, selectQuality, selectLock)  self:ClickConfirm(selectPos, selectQuality, selectLock) end
    self.view.clickReset = function() self:OnBtnReset() end
end

function DreamPlayerSearchDecomposeCtrl:ClickConfirm(selectPos, selectQuality, selectLock)
    local selectModels = self.dreamPlayerSearchModel:GetFilterDcids(selectPos, selectQuality, selectLock)
    if next(selectModels) then
        local dcids = {}
        for k, v in pairs(selectModels) do
            local dcid = v:GetDcid()
            table.insert(dcids, dcid)
        end
        local decomposition = function()
            clr.coroutine(function()
                local response = req.dreamCardDecompositionAll(dcids)
                if api.success(response) then
                    local data = response.val
                    for i, v in ipairs(data.cost.dcid) do
                        self.dreamLeagueListModel:DelCard(tostring(v))
                    end
                    EventSystem.SendEvent("DreamPlayerSearchDecomposeCtrl_Refresh")
                    local playerInfoModel = PlayerInfoModel.new()
                    playerInfoModel:AddDreamPiece(data.contents.dp)
                    DialogManager.ShowToast(lang.trans("dream_reslove_reward", data.contents.dp))
                end
            end)
        end
        local tipText = lang.transstr("dream_decompose_confirm", #dcids)
        DialogManager.ShowConfirmPop(lang.trans("tips"), tipText, 
        function() 
            decomposition() 
        end)
    else
        DialogManager.ShowToastByLang("dream_filter_no_player")
    end
end

function DreamPlayerSearchDecomposeCtrl:OnBtnReset()
    self.view:OnReset()
end

function DreamPlayerSearchDecomposeCtrl:OnEnterScene()
    if self.view.OnEnterScene then
        self.view:OnEnterScene()
    end
end

function DreamPlayerSearchDecomposeCtrl:OnExitScene()
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

return DreamPlayerSearchDecomposeCtrl
