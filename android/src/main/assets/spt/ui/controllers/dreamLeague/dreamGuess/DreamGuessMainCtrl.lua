local EventSystem = require("EventSystem")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamLeagueCardModel = require("ui.models.dreamLeague.DreamLeagueCardModel")
local DialogManager = require("ui.control.manager.DialogManager")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DreamLeagueCardName = require("data.DreamLeagueCardName")
local DreamGuessMainCtrl = class(BaseCtrl)

DreamGuessMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamGuess/DreamGuess.prefab"

-- mvp独用一个ctrl
function DreamGuessMainCtrl:AheadRequest()
    local response = req.dreamLeagueMatchGuessList()
    if api.success(response) then
        local data = response.val
        self.data = data
    end
end

function DreamGuessMainCtrl:Refresh()
    DreamGuessMainCtrl.super.Refresh(self)
    self.view:InitView(self.data)
end

function DreamGuessMainCtrl:Init()
    self.view.scrollView:RegOnItemButtonClick("selectBtn", function (data)
        self:OnSelectPlayerBtnClick(data)
    end)
end

function DreamGuessMainCtrl:OnSelectPlayerBtnClick(data)
    if not data.guessStatus or data.resultState == 1 or data.guessCardName ~= nil then
        return
    end
    local nations = {}
    nations[data.homeTeamEn] = true
    nations[data.awayTeamEn] = true

    local playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
    local allDcids = playerDreamCardsMapModel:GetCardList()

    local partNationDcids = {}
    
    for i,v in ipairs(allDcids) do
        local dreamLeagueCardModel = DreamLeagueCardModel.new(v)
        local nation = dreamLeagueCardModel:GetNation()
        if nations[nation] then
            table.insert(partNationDcids, v)
        end
    end

    -- 不需要选一个球员的特定品质
    local onlyNeedPlayerName = true

    -- 第一个参数是所选国家的dcids列表
    res.PushScene("ui.controllers.dreamLeague.dreamBag.DreamBagCtrl", partNationDcids, true, nil, nations, function (selectPlayerName)
        self:SelectPlayerCallback(selectPlayerName, data.matchId)
    end, onlyNeedPlayerName)
end

function DreamGuessMainCtrl:SelectPlayerCallback(selectPlayerName, matchId)
    local selectPlayer = function()
        clr.coroutine(function()
            local response = req.dreamLeagueMatchGuess(selectPlayerName, matchId, DreamConstants.Lottery.EVERY_MVP)
            if api.success(response) then
                local data = response.val
                res.PopAppointSceneImmediate(2)
            end
        end)
    end

    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("dream_mvp_select_player", DreamLeagueCardName[selectPlayerName].name),
    function()
        selectPlayer()
    end)
end

return DreamGuessMainCtrl
