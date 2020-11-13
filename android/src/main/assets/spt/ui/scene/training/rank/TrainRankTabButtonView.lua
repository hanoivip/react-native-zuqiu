local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local TrainRankConstants = require("ui.scene.training.rank.TrainRankConstants")
local TrainType = require("training.TrainType")

local TrainRankTabButtonView = class(LuaButton)

function TrainRankTabButtonView:ctor()
    TrainRankTabButtonView.super.ctor(self)
    self.selectImg = self.___ex.selectImg
    self.selectText = self.___ex.selectText
    self.normalText = self.___ex.normalText
    self.trainType = self.___ex.trainType
end

function TrainRankTabButtonView:start()
    self:regOnButtonClick(function()
        self:OnBtnClick()
    end)
end

function TrainRankTabButtonView:InitView(isOpenBrain)
    self.selectText.text = lang.trans(TrainRankConstants.TabName[self.trainType])
    self.normalText.text = lang.trans(TrainRankConstants.TabName[self.trainType])
    if self.trainType == TrainType.BRAIN then
        GameObjectHelper.FastSetActive(self.gameObject, isOpenBrain)
    end
end

function TrainRankTabButtonView:ChangeState(isSelect)
    self:onPointEventHandle(not isSelect)
    GameObjectHelper.FastSetActive(self.selectImg, isSelect)
    GameObjectHelper.FastSetActive(self.selectText.gameObject, isSelect)
    GameObjectHelper.FastSetActive(self.normalText.gameObject, not isSelect)
end

function TrainRankTabButtonView:OnBtnClick()
    if self.clickRankTab then 
        self.clickRankTab()
    end
end

return TrainRankTabButtonView