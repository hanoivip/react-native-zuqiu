local LittleGame = require("data.LittleGame")
local TrainRulesConstants = require("ui.scene.training.TrainRulesConstants")
local TrainType = require("training.TrainType")

local TrainRulesView = class(unity.base)

function TrainRulesView:ctor()
    self.bgPlayer = self.___ex.bgPlayer
    self.title = self.___ex.title
    self.smallSuccess = self.___ex.smallSuccess
    self.bigSuccess = self.___ex.bigSuccess
    self.boardTitle = self.___ex.boardTitle
end

function TrainRulesView:InitView(trainingType, gameID)
    local rulesData = TrainRulesConstants[trainingType]
    self.bgPlayer.overrideSprite = res.LoadRes(rulesData.BgImgPath)
    self.boardTitle.text = lang.trans(rulesData.BoardTitle)
    self.title.text = lang.trans(rulesData.Title)
    local gameData = LittleGame[gameID]
    if trainingType ~= TrainType.DEFEND then
        self.smallSuccess.text = lang.trans(rulesData.Condition, gameData.success)
        self.bigSuccess.text = lang.trans(rulesData.Condition, gameData.bigSuccess)
    else
        self.smallSuccess.text = lang.trans(rulesData.Condition, gameData.success / 10)
        self.bigSuccess.text = lang.trans(rulesData.Condition, gameData.bigSuccess / 10)
    end
end

function TrainRulesView:onDestroy()
    EventSystem.SendEvent("TrainEntry.InitTrainManager")
end

return TrainRulesView