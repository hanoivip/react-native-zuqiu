local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")

local DreamMainView = class(unity.base)

function DreamMainView:ctor()
    self.backBtn = self.___ex.backBtn
    self.bagBtn = self.___ex.bagBtn
    self.storeBtn = self.___ex.storeBtn
    self.nationScroll = self.___ex.nationScroll
    self.dayRankScroll = self.___ex.dayRankScroll
    self.seasonRankScroll = self.___ex.seasonRankScroll
    self.startLeague = self.___ex.startLeague
    self.startBattle = self.___ex.startBattle
    self.mvpGuessBtn = self.___ex.mvpGuessBtn
    self.goldenballGuessBtn = self.___ex.goldenballGuessBtn
    self.goldenbootsGuessBtn = self.___ex.goldenbootsGuessBtn
    self.assistGuessBtn = self.___ex.assistGuessBtn
    self.rankBtn = self.___ex.rankBtn
    self.helpBtn = self.___ex.helpBtn
end

function DreamMainView:start()
    self.bagBtn:regOnButtonClick(function ()
        res.PushScene("ui.controllers.dreamLeague.dreamBag.DreamBagCtrl")
    end)

    self.storeBtn:regOnButtonClick(function ()
        res.PushScene("ui.controllers.dreamLeague.dreamStore.DreamStoreCtrl")
    end)

    self.backBtn:regOnButtonClick(function ()
        res.PopSceneImmediate()
    end)

    self.startLeague:regOnButtonClick(function ()
        res.PushScene("ui.controllers.dreamLeague.dreamHall.DreamHallCtrl")
    end)

    self.startBattle:regOnButtonClick(function ()
        if self.startBattleBtnClick then
            self.startBattleBtnClick()
        end
    end)

    self.mvpGuessBtn:regOnButtonClick(function ()
        res.PushScene("ui.controllers.dreamLeague.dreamGuess.DreamGuessMainCtrl")
    end)

    self.goldenballGuessBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.dreamLeague.dreamGuess.DreamGuessLittleBoardCtrl", DreamConstants.Lottery.GOLD)
    end)

    self.goldenbootsGuessBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.dreamLeague.dreamGuess.DreamGuessLittleBoardCtrl", DreamConstants.Lottery.BOOTS)
    end)

    self.assistGuessBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.dreamLeague.dreamGuess.DreamGuessLittleBoardCtrl", DreamConstants.Lottery.ASIST)
    end)

    self.rankBtn:regOnButtonClick(function ()
        res.PushScene("ui.controllers.dreamLeague.dreamRank.DreamRankMainCtrl")
    end)

    self.helpBtn:regOnButtonClick(function ()
        res.PushScene("ui.controllers.dreamLeague.dreamRule.DreamRuleCtrl")
    end)
end

function DreamMainView:InitView(dreamMainModel)
    self.dreamMainModel = dreamMainModel

    self:InitMatchNationScrollView()
    self:InitDayRankScrollView()
    self:InitSeasonRankScrollView()
end

function DreamMainView:InitMatchNationScrollView()
    local matchNationData = self.dreamMainModel:GetNationMatchScrollData()
    self.nationScroll:InitView(matchNationData)
    local scrollIndex = self.dreamMainModel:GetNationMatchScrollIndex()
    self.nationScroll:scrollToCell(scrollIndex)
end

function DreamMainView:InitDayRankScrollView()
    local dayRankData = self.dreamMainModel:GetDayRankScrollData()
    self.dayRankScroll:InitView(dayRankData)
end

function DreamMainView:InitSeasonRankScrollView()
    local seasonRankData = self.dreamMainModel:GetSeasonRankScrollData()
    self.seasonRankScroll:InitView(seasonRankData)
end

return DreamMainView
