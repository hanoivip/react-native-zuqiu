local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CoachBaseInfoModel = require("ui.models.coach.baseInfo.CoachBaseInfoModel")
local CoachBaseInfoUpdateModel = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local FormationCacheDataModel = require("ui.models.formation.FormationCacheDataModel")
local FormationType = require("ui.common.enum.FormationType")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local CoachBaseInfoCtrl = class(BaseCtrl, "CoachBaseInfoCtrl")

CoachBaseInfoCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/BaseInfo/CoachBaseInfo.prefab"

function CoachBaseInfoCtrl:ctor()
    CoachBaseInfoCtrl.super.ctor(self)
    self.playerTeamsModel = nil
    self.formationCacheDataModel = nil
end

function CoachBaseInfoCtrl:Init(cacheData)
    CoachBaseInfoCtrl.super.Init(self)
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self, false, false)
        self.infoBarCtrl:RegOnBtnBack(function()
            self.view:coroutine(function()
                unity.waitForEndOfFrame()
                res.PopSceneImmediate()
            end)
        end)
    end)

    self.view.onBtnIntroClick = function() self:OnBtnIntroClick() end
    self.view.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
    self.view.onBtnCurrencyPlusClick = function() self:OnBtnCurrencyPlusClick() end
    self.view.onItemClick = function(itemData) self:OnItemClick(itemData) end
    self.view.updateAfterFormationUpgrade = function(idx, formationId, newData) self:UpdateAfterFormationUpgrade(idx, formationId, newData) end
    self.view.updateAfterTacticUpgrade = function(idx, tacticType, id, newData) self:UpdateAfterTacticUpgrade(idx, tacticType, id, newData) end
end

function CoachBaseInfoCtrl:Refresh(cacheData)
    CoachBaseInfoCtrl.super.Refresh(self)
    if not self.model then
        self.model = CoachBaseInfoModel.new()
    end
    self.playerTeamsModel = PlayerTeamsModel.new()
    self.formationCacheDataModel = FormationCacheDataModel.new(self.playerTeamsModel)
    self.model:InitWithProtocol(cacheData, self.playerTeamsModel, self.formationCacheDataModel)
    self.view:ShowDisplayArea(true)
    self.view:InitView(self.model, self.playerTeamsModel, self.formationCacheDataModel)
    if not GuideManager.HasGuideOnGoing() then
        self:CheckGuide()
    end
    GuideManager.Show(self)
end

function CoachBaseInfoCtrl:GetStatusData()
    return self.model:GetStatusData()
end

function CoachBaseInfoCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CoachBaseInfoCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CoachBaseInfoCtrl:OnBtnIntroClick()
    res.PushDialog("ui.controllers.coach.baseInfo.CoachBaseInfoDetailCtrl", self.model)
end

function CoachBaseInfoCtrl:OnBtnUpdateClick()
    if self.model:IsCoachMaxLevel() then
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level") -- 已满级
        return
    end
    local hadCENum = self.model:GetCurrCENum()
    local needCENum = self.model:GetUpdateNeedCENum()
    if hadCENum < needCENum then
        DialogManager.ShowToast(lang.transstr("lack_item_tips", lang.transstr("credentialExp"))) -- 执教经验书不足
        return
    end
    -- 点击确定回调
    local confirmCallback = function()
        self.view:coroutine(function()
            local needCENum = self.model:GetUpdateNeedCENum()
            local respone = req.coachBaseInfoAddExp(needCENum)
            if api.success(respone) then
                local data = respone.val
                if type(data) == "table" and next(data) then
                    self.model:UpdateAfterUpgradeCoach(data)
                    -- 更新头像
                    self.view:UpdateCoachPortrait()
                    -- 弹升级成功的框
                    res.PushDialog("ui.controllers.coach.baseInfo.CoachBaseInfoSuccessCtrl", self.model)
                    -- 更新等级相关
                    self.view:InitUpdateDisplay()
                end
            end
        end)
    end

    local title = lang.transstr("playerGuide_coachName") .. lang.transstr("levelUp") -- 教练升级
    -- 是否使用执教经验书X5升级教练
    local msg = lang.transstr("coach_baseInfo_update_tip", lang.transstr("credentialExp") .. "X" .. needCENum, lang.transstr("playerGuide_coachName"))
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

function CoachBaseInfoCtrl:OnBtnCurrencyPlusClick()
    dump("Currency Plus Click")
end

-- 点击阵型/战术的item，弹出升级面板
function CoachBaseInfoCtrl:OnItemClick(itemData)
    itemData.coachLevelId = self.model:GetCurrCoachLvl()
    local coachBaseInfoUpdateModel = CoachBaseInfoUpdateModel.new()
    coachBaseInfoUpdateModel:InitWithParent(itemData)
    res.PushDialog("ui.controllers.coach.baseInfo.CoachBaseInfoUpdateCtrl", coachBaseInfoUpdateModel)
end

-- 阵型升级后更新
function CoachBaseInfoCtrl:UpdateAfterFormationUpgrade(idx, formationId, newData)
    self.model:UpdateAfterFormationUpgrade(idx, formationId, newData)
    self.view.scrollView:UpdateItem(idx, self.model:GetScrollData()[idx])
end

-- 战术升级后更新
function CoachBaseInfoCtrl:UpdateAfterTacticUpgrade(idx, tacticType, id, newData)
    self.model:UpdateAfterTacticUpgrade(idx, tacticType, id, newData)
    self.view.scrollView:UpdateItem(idx, self.model:GetScrollData()[idx])
end

-- 新手引导的检查点（兼容线上等级超过开启等级的玩家）
function CoachBaseInfoCtrl:CheckGuide()
    local tallentOpenState = CoachMainPageConfig.GetOpenStateByTag(CoachMainPageConfig.Tag.CoachTalentSkill)
    if tallentOpenState then
        GuideManager.InitCurModule("coachtalent")
    end
    local coachGuideOpenState = CoachMainPageConfig.GetOpenStateByTag(CoachMainPageConfig.Tag.CoachGuide)
    if coachGuideOpenState then
        GuideManager.InitCurModule("coachguide1")
    end
    local gachaOpenState = CoachMainPageConfig.GetOpenStateByTag(CoachMainPageConfig.Tag.AssistantCoachInfomationGacha)
    if gachaOpenState then
        GuideManager.InitCurModule("assistantcoach1")
    end
end

return CoachBaseInfoCtrl
