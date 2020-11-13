local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local CoachTaskHelper = require("ui.scene.coach.coachTask.CoachTaskHelper")
local CoachTaskPlayerChooseModel = require("ui.models.coach.coachTask.CoachTaskPlayerChooseModel")

local CoachTaskDetailCardItemView = class(unity.base)

function CoachTaskDetailCardItemView:ctor()
    self.addBtn = self.___ex.addBtn
    self.cardTrans = self.___ex.cardTrans
end

return CoachTaskDetailCardItemView
