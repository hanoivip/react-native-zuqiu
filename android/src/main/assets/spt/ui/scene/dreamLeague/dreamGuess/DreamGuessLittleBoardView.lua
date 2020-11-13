local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local DreamLeagueCardName = require("data.DreamLeagueCardName")
local DreamGuessLittleBoardView = class(unity.base)

function DreamGuessLittleBoardView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.chooseBtn = self.___ex.chooseBtn
    self.playerTxt = self.___ex.playerTxt
    self.scrollView = self.___ex.scrollView
    self.titleTxt = self.___ex.titleTxt
    self.chooseTxt = self.___ex.chooseTxt

    DialogAnimation.Appear(self.transform, nil)
end

function DreamGuessLittleBoardView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.chooseBtn:regOnButtonClick(function ()
        if self.onChooseBtnClick then
            self.onChooseBtnClick()
        end
    end)
end

function DreamGuessLittleBoardView:InitView(data)
    -- 服务器没给排名，自己整
    table.sort(data.guessCardList, function (a, b)
        return a.num > b.num
    end)
    local rank = 0
    for k, v in pairs(data.guessCardList) do
        rank = rank + 1
        data.guessCardList[k].rank = rank
    end
    self.scrollView:InitView(data.guessCardList)

    if DreamConstants.Lottery.GOLD == data.matchType then
        self.titleTxt.text = lang.trans("dream_gold_lottery")
    elseif DreamConstants.Lottery.BOOTS == data.matchType then
        self.titleTxt.text = lang.trans("dream_boots_lottery")
    elseif DreamConstants.Lottery.ASIST == data.matchType then
        self.titleTxt.text = lang.trans("dream_asist_lottery")
    end

    if data.playerGuess and data.playerGuess.guessCardName then
        self.playerTxt.text = lang.trans("dream_my_choose", DreamLeagueCardName[data.playerGuess.guessCardName].name)
    else
        self.playerTxt.text = lang.trans("dream_my_choose_no")
    end
end

function DreamGuessLittleBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return DreamGuessLittleBoardView
