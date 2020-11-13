local EventSystem = require("EventSystem")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamLeagueCardName = require("data.DreamLeagueCardName")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local DreamGuessLittleBoardCtrl = class(BaseCtrl)

DreamGuessLittleBoardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamGuessLittleBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamGuess/DreamGuessLittleBoard.prefab"

function DreamGuessLittleBoardCtrl:AheadRequest(matchType)
    local response = req.dreamLeagueMatchGuessInfo(matchType)
    if api.success(response) then
        local data = response.val
        self.data = data
        self.data.matchType = matchType
    end
end

function DreamGuessLittleBoardCtrl:Refresh()
    DreamGuessLittleBoardCtrl.super.Refresh(self)
    self.view.onChooseBtnClick = function () self:OnChooseBtnClick() end
    self.view:InitView(self.data)
end

function DreamGuessLittleBoardCtrl:Init()
    DreamGuessLittleBoardCtrl.super.Init(self)
end

function DreamGuessLittleBoardCtrl:OnGoldSelect(selectPlayerName)
    local selectPlayer = function()
        clr.coroutine(function()
            local response = req.dreamLeagueMatchGuess(selectPlayerName, nil, self.data.matchType)
            if api.success(response) then
                local data = response.val
                res.PopAppointSceneImmediate(2)
            end
        end)
    end

    langKey = nil
    if DreamConstants.Lottery.GOLD == self.data.matchType then
        langKey = "dream_gold_select_player"
    elseif DreamConstants.Lottery.BOOTS == self.data.matchType then
        langKey = "dream_foot_select_player"
    elseif DreamConstants.Lottery.ASIST == self.data.matchType then
        langKey = "dream_asist_select_player"
    end

    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans(langKey, DreamLeagueCardName[selectPlayerName].name),
    function() 
        selectPlayer()
    end)
end

function DreamGuessLittleBoardCtrl:OnChooseBtnClick()
    if self.data.playerGuess and self.data.playerGuess.guessCardName then
        DialogManager.ShowToast(lang.trans("skillList_selectNum"))
        return
    end

    -- 不需要选一个特定品质的球员
    local onlyNeedPlayerName = true

    res.PushScene("ui.controllers.dreamLeague.dreamBag.DreamBagCtrl", nil, true, nil, nil, function (selectPlayerName)
        self:OnGoldSelect(selectPlayerName)
    end, onlyNeedPlayerName)
end

function DreamGuessLittleBoardCtrl:OnEnterScene()
end

function DreamGuessLittleBoardCtrl:OnExitScene()
end

function DreamGuessLittleBoardCtrl:GetStatusData()
    return self.data.matchType
end

return DreamGuessLittleBoardCtrl
