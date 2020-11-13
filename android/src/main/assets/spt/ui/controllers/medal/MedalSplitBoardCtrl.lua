local DialogManager = require("ui.control.manager.DialogManager")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalSplitBoardCtrl = class(BaseCtrl)
MedalSplitBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalSplitBoard.prefab"
MedalSplitBoardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalSplitBoardCtrl:Init()
    self.view.clickConfirm = function(selectQuality) self:ClickConfirm(selectQuality) end
end

function MedalSplitBoardCtrl:Refresh(medalListModel)
    MedalSplitBoardCtrl.super.Refresh(self)
    self.medalListModel = medalListModel
    self.view:InitView(medalListModel)
end

function MedalSplitBoardCtrl:ClickConfirm(selectQuality)
    if selectQuality and next(selectQuality) then 
        local selectModels = self.medalListModel:GetMedalByQuality(selectQuality)
        if next(selectModels) then 
            local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/SplitTip.prefab", "overlay", false, true)
            local view = dialogcomp.contentcomp
            view.clickConfirm = function() self:ClickSplitAll(selectModels) end
            view:InitView(selectModels)
        else
            DialogManager.ShowToast(lang.trans("medal_split_tip4"))
        end
    else
        DialogManager.ShowToast(lang.trans("medal_split_tip3"))
    end
end

function MedalSplitBoardCtrl:ClickSplitAll(selectModels)
    local pmids = {}
    for i, model in ipairs(selectModels) do
        local pmid = model:GetPmid()
        table.insert(pmids, pmid)
    end
    clr.coroutine(function()
        local respone = req.decompositionAll(pmids)
        if api.success(respone) then
            local data = respone.val
            CongratulationsPageCtrl.new(data.contents)
            if data.cost and next(data.cost) then
                local playerMedalsMapModel = PlayerMedalsMapModel.new()
                playerMedalsMapModel:RemoveMedalsData(data.cost.pmid)
            end
            self.view:Close()
        end
    end)
end

return MedalSplitBoardCtrl
