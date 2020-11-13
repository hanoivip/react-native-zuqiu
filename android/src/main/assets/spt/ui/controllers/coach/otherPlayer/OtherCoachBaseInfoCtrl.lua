local CoachBaseInfoCtrl = require("ui.controllers.coach.baseInfo.CoachBaseInfoCtrl")
local OtherCoachBaseInfoModel = require("ui.models.coach.otherPlayer.OtherCoachBaseInfoModel")
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")

local OtherCoachBaseInfoCtrl = class(CoachBaseInfoCtrl, "OtherCoachBaseInfoCtrl")

OtherCoachBaseInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/OtherPlayer/OtherCoachBaseInfo.prefab"

function OtherCoachBaseInfoCtrl:ctor()
    OtherCoachBaseInfoCtrl.super.ctor(self)
    self.playerTeamsModel = nil
end

function OtherCoachBaseInfoCtrl:Init(coach, otherPlayerTeamsModel, otherPlayerCardsMapModel)
    self.view.onBtnIntroClick = function() self:OnBtnIntroClick() end
    self.view.onItemClick = function(itemData) self:OnItemClick(itemData) end
    self.view.onBtnBackClick = function() self:OnBtnBackClick() end
end

function OtherCoachBaseInfoCtrl:Refresh(coach, otherPlayerTeamsModel, otherPlayerCardsMapModel)
    if not self.model then
        self.model = OtherCoachBaseInfoModel.new()
    end
    self.playerTeamsModel = otherPlayerTeamsModel
    self.model:InitWithProtocol(coach, otherPlayerCardsMapModel, self.playerTeamsModel)
    self.view:InitView(self.model, self.playerTeamsModel)
    self.view:ShowDisplayArea(true)
    self.view:RefreshView()
end

function OtherCoachBaseInfoCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function OtherCoachBaseInfoCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 点击返回按钮
function OtherCoachBaseInfoCtrl:OnBtnBackClick()
    res.PopScene()
end

return OtherCoachBaseInfoCtrl
