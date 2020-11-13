local EventSystem = require ("EventSystem")
local CongratulationsDreamCardPageModel = require ("ui.models.dreamLeague.congratulationsDreamCardPage.CongratulationsDreamCardPageModel")
local PlayerDreamCardsMapModel = require ("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CongratulationsDreamCardPageCtrl = class(BaseCtrl)

CongratulationsDreamCardPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/CongratulationsDreamCardPage/CongratulationsDreamCardPage.prefab"

function CongratulationsDreamCardPageCtrl:Refresh(rewardData)
    self.model = CongratulationsDreamCardPageModel.new(rewardData)
    self.view.clickConfirm = function() self:OnConfirmClick() end
    self.view.clickSell = function() self:OnBtnSellClick() end
    self.view.clickSelect = function(selectState, dcid) self:OnSelectClick(selectState, dcid) end
    self.view:InitView(self.model)
end

function CongratulationsDreamCardPageCtrl:OnConfirmClick()
    self.view:Close()
end

function CongratulationsDreamCardPageCtrl:OnBtnSellClick()
    local dcids = self.model:GetAllSelectCards()
    local decomposition = function()
        clr.coroutine(function()
            local response = req.dreamCardDecompositionAll(dcids)
            if api.success(response) then
                local data = response.val
                local playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
                for i, v in ipairs(data.cost.dcid) do
                    playerDreamCardsMapModel:RemoveSingleCardData(v)
                end
                if data.contents.dp ~= nil then
                    PlayerInfoModel.new():AddDreamPiece(data.contents.dp)
                    DialogManager.ShowToast(lang.trans("dream_reslove_reward", data.contents.dp))
                end
                self.model:SellCardsCallBack(dcids)
                self.view:InitView(self.model)
            end
        end)
    end
    local dcidNums = #dcids
    if dcidNums > 0 then
        local tipText = lang.transstr("dream_decompose_confirm", #dcids)
        DialogManager.ShowConfirmPop(lang.trans("tips"), tipText, 
        function() 
            decomposition() 
        end)
    else
        DialogManager.ShowToastByLang("none_player_choose")
    end
end

function CongratulationsDreamCardPageCtrl:OnSelectClick(selectState, dcid)
    if selectState then
        self.model:AddSelectCards(dcid)
    else
        self.model:RemoveSelectCards(dcid)
    end
end

function CongratulationsDreamCardPageCtrl:OnEnterScene()
    if self.view.OnEnterScene then
        self.view:OnEnterScene()
    end
end

function CongratulationsDreamCardPageCtrl:OnExitScene()
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

return CongratulationsDreamCardPageCtrl
