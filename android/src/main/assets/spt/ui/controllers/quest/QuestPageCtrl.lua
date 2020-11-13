local GameObjectHelper = require("ui.common.GameObjectHelper")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local QuestInfoModel = require("ui.models.quest.QuestInfoModel")
local QuestPageViewModel = require("ui.models.quest.QuestPageViewModel")
local QuestRewardCtrl = require("ui.controllers.quest.QuestRewardCtrl")
local MenuBarCtrl = require("ui.controllers.common.MenuBarCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local QuestMenuBarModel = require("ui.models.menuBar.QuestMenuBarModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local DialogManager = require("ui.control.manager.DialogManager")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local BaseMenuBarModel = require("ui.models.menuBar.BaseMenuBarModel")
local CareerRaceModel = require("ui.models.quest.CareerRaceModel")
local QuestPageCtrl = class(BaseCtrl)
QuestPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Quest/QuestPage.prefab"

function QuestPageCtrl:Init(guideCallBack, stageId, chapterId, isFromStartGame)
    self.questInfoModel = QuestInfoModel.new()
    self.questPageViewModel = QuestPageViewModel.new()
    self.questPageViewModel:SetModel(self.questInfoModel)
    if stageId ~= nil then
        self.questPageViewModel:SetDataStorageType(true)
    end
    if isFromStartGame then
        chapterId = self.questInfoModel:GetLastChapterId()
    end
    self:InitView(stageId, chapterId)
    local questMenuBarModel = QuestMenuBarModel.new(BaseMenuBarModel.MenuState.Open, FormationConstants.TeamType.QUEST)
    self.menuBarCtrl = MenuBarCtrl.new(self.view.menuBarDynParent, self, nil, questMenuBarModel)

    if guideCallBack then
        guideCallBack()
    end

    self.view:RegOnDynamicLoad(function (child)
        local infoBarCtrl = InfoBarCtrl.new(child, self)
        infoBarCtrl:RegOnBtnBack(function ()
            self.view:SetStageId()
            self.questPageViewModel:SetDataStorageType(false)
            cache.setRequiredEquipId(nil)
            cache.setRequiredEquipStageId(nil)
            clr.coroutine(function()
                unity.waitForEndOfFrame()
                res.PopSceneImmediate()
                -- 关闭主线页面
                GuideManager.Show(res.curSceneInfo.ctrl)
            end)
        end)
    end)
    self.view.clickBtnCareerRace = function() self:OnClickBtnCareerRace() end
end

function QuestPageCtrl:CheckForCareerRaceActivity()
    -- ios提审屏蔽
    if luaevt.trig("___EVENT__NOT_OPEN_FORBIDDEN") then
        GameObjectHelper.FastSetActive(self.view.careerRaceObj, false)
        return
    end
    clr.coroutine(function()
        local requestParam = "CareerRaceSelf"
        local response = req.careerRaceInfo(requestParam)
        if api.success(response) then
            local data = response.val
            if data and next(data) then
                for k, v in pairs(data) do
                    self.careerRaceModel = CareerRaceModel.new(v, k)
                end
            else
                self.careerRaceModel = nil
            end
        end
        if not self.careerRaceModel then
            GameObjectHelper.FastSetActive(self.view.careerRaceObj, false)
        else
            GameObjectHelper.FastSetActive(self.view.careerRaceObj, true)
        end
    end)
end

-- 当前版本release_vn_lua2分支只有韩国需要，并且已有单独版本，所有直接屏蔽了spt下的，需要开竞速在打开
function QuestPageCtrl:Refresh(guideCallBack, stageId, chapterId, isFromStartGame)
    GameObjectHelper.FastSetActive(self.view.careerRaceObj, false)
    --self:CheckForCareerRaceActivity()
    self.super.Refresh(self)
    if stageId ~= nil then
        self.questPageViewModel:SetDataStorageType(true)
        self.view:GoToStage(stageId)
    end
    self.view:RefreshPage(self.isRefreshPage, isFromStartGame)
    if self.isRefreshPage and not isFromStartGame then
        self.isRefreshPage = false
        EventSystem.SendEvent("StagePage.RefreshView")
    end
    QuestRewardCtrl.new(self.questPageViewModel)
end

function QuestPageCtrl:InitView(stageId, chapterId)
    if stageId then
        local nowChapterId = self.questInfoModel:GetChapterIdByStageId(stageId)
        self.view:InitView(self.questPageViewModel, nowChapterId, stageId)
    elseif chapterId then
        self.view:InitView(self.questPageViewModel, chapterId)
    else
        self.view:InitView(self.questPageViewModel)
    end
end

function QuestPageCtrl:OnClickBtnCareerRace()
    if not self.careerRaceModel then return end

    local isActivityEnd = self.careerRaceModel:GetIsActivityEnd()
    if not isActivityEnd then
        res.PushDialog("ui.controllers.quest.CareerRaceCtrl", self.careerRaceModel)
    else
        DialogManager.ShowToast(lang.trans("time_limit_growthPlan_desc5"))
    end
end

function QuestPageCtrl:GetStatusData()

end

function QuestPageCtrl:OnExitScene()
    self.isRefreshPage = true
end

return QuestPageCtrl
