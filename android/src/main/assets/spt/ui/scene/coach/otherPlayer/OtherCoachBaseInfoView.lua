local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local CoachBaseInfoView = require("ui.scene.coach.baseInfo.CoachBaseInfoView")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local OtherCoachBaseInfoView = class(CoachBaseInfoView, "OtherCoachBaseInfoView")

-- 教练头像prefab
local CoachPortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachPortrait.prefab"

function OtherCoachBaseInfoView:ctor()
    -- 中间面板
    self.mainView = self.___ex.mainView
    -- 教练头像
    self.rctPortrait = self.___ex.rctPortrait
    -- 阵型框
    self.rctFormation = self.___ex.rctFormation
    -- 滑动框
    self.scrollView = self.___ex.scrollView
    -- 介绍
    self.btnIntro = self.___ex.btnIntro
    -- 阵型控制脚本
    self.sptFormation = self.___ex.sptFormation
    -- 返回按钮
    self.btnBack = self.___ex.btnBack

    -- 教练头像控制脚本
    self.coachPortraitSpt = nil
end

function OtherCoachBaseInfoView:start()
    self:RegBtnEvent()
end

function OtherCoachBaseInfoView:RegBtnEvent()
    self.btnIntro:regOnButtonClick(function()
        if self.onBtnIntroClick then
            self.onBtnIntroClick()
        end
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBackClick()
    end)
end

function OtherCoachBaseInfoView:InitView(otherCoachBaseInfoModel, playerTeamsModel)
    self.model = otherCoachBaseInfoModel
    self.playerTeamsModel = playerTeamsModel
end

function OtherCoachBaseInfoView:RefreshView()
    if not self.model then
        self:ShowDisplayArea(false)
        return
    end

    -- 教练头像
    self:InitCoachPortrait()
    -- 滑动框
    self.scrollView:InitView(self.model:GetScrollData())
    -- 阵型
    self.sptFormation:InitView(0, self.model:GetCurrFormationId(), self.model:GetCurrFormationData())
end

function OtherCoachBaseInfoView:OnEnterScene()
end

function OtherCoachBaseInfoView:OnExitScene()
end

function OtherCoachBaseInfoView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

-- 点击返回按钮
function OtherCoachBaseInfoView:OnBtnBackClick()
    if self.onBtnBackClick and type(self.onBtnBackClick) then
        self.onBtnBackClick()
    end
end

return OtherCoachBaseInfoView
