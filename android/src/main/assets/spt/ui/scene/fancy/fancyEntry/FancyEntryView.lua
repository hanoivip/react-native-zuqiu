local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local FancyEntryView = class(unity.base)

function FancyEntryView:ctor()
--------Start_Auto_Generate--------
    self.gachaBtn = self.___ex.gachaBtn
    self.groupBtn = self.___ex.groupBtn
    self.newTipGo = self.___ex.newTipGo
    self.helpBtn = self.___ex.helpBtn
    self.backBtn = self.___ex.backBtn
--------End_Auto_Generate----------
    self.gachaRedPoint = self.___ex.gachaRedPoint
end

function FancyEntryView:start()
    self:BindButtonHandler()
end

function FancyEntryView:BindButtonHandler()
    -- 抽卡入口
    self.gachaBtn:regOnButtonClick(function()
        res.PushScene("ui.controllers.fancy.fancyGacha.FancyGachaMainCtrl")
    end)

    -- 卡组入口
    self.groupBtn:regOnButtonClick(function()
        res.PushScene("ui.controllers.fancy.fancyEntry.FancySortCtrl")
    end)

    -- 帮助
    self.helpBtn:regOnButtonClick(function()
        self:OnHelp()
    end)
    -- 返回
    self.backBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function FancyEntryView:InitView(fancyHomeModel)
    self.model = fancyHomeModel
    local fancyCardsMapModel = FancyCardsMapModel.new()
    GameObjectHelper.FastSetActive(self.newTipGo, fancyCardsMapModel:IsHaveNewCard())
    self:FreshRedPoint()
end

function FancyEntryView:FreshRedPoint()
    local isShow = table.nums(ReqEventModel.GetInfo("fancyGacha") or {}) > 0 -- 有可领取的奖励
    GameObjectHelper.FastSetActive(self.gachaRedPoint, isShow)
end

function FancyEntryView:Close()
    res.PopScene()
end

function FancyEntryView:OnHelp()
    res.PushDialog("ui.controllers.fancy.FancyIntroduceCtrl")
end

return FancyEntryView
