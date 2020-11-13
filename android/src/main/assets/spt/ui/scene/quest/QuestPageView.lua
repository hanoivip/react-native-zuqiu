local Vector2 = clr.UnityEngine.Vector2
local DialogManager = require("ui.control.manager.DialogManager")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")
local AssetFinder = require("ui.common.AssetFinder")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local QuestInfoModel = require("ui.models.quest.QuestInfoModel")
local Text = clr.UnityEngine.UI.Text

local QuestPageView = class(unity.base)

function QuestPageView:ctor()
    -- 顶部信息条框
    self.infoBarBox = self.___ex.infoBarBox
    -- 左切换按钮
    self.leftSwitchBtn = self.___ex.leftSwitchBtn
    -- 右切换按钮
    self.rightSwitchBtn = self.___ex.rightSwitchBtn
    -- 副本滚动视图
    self.questScrollerView = self.___ex.questScrollerView
    -- 球员信函按钮
    self.playerLetterBtn = self.___ex.playerLetterBtn
    -- 生涯竞速按钮
    self.careerRaceBtn = self.___ex.careerRaceBtn
    self.careerRaceObj = self.___ex.careerRaceObj
    self.careerRaceRedPointObj = self.___ex.careerRaceRedPointObj
    -- 球员信函背后发光效果
    self.playerLetterEffect =self.___ex.playerLetterEffect
    -- 球员信函按钮Trans
    self.playerLetterBtnTrans = self.___ex.playerLetterBtnTrans
    -- 球员信函红点
    self.playerLetterRedPoint = self.___ex.playerLetterRedPoint
    self.menuBarDynParent = self.___ex.menuBarDynParent
    -- 首页按钮
    self.homeBtn = self.___ex.homeBtn
    -- 球员来信特效
    self.effectPlayerLetterFlash = self.___ex.effectPlayerLetterFlash
    -- 球员来信按钮区域
    self.playerLetterBtnBox = self.___ex.playerLetterBtnBox
    -- 球员来信提示（玉宁）
    self.letterTip = self.___ex.letterTip
    -- 通用来信提示
    self.commonTip = self.___ex.commonTip
    -- 球员来信提示内容
    self.letterTipContent = nil
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 副本视图model
    self.questPageViewModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
    -- 当前章节数据
    self.nowChapterData = nil
    -- 章节总数
    self.chapterSum = nil
    -- 目标章节索引
    self.destChapterIndex = nil
    -- 切换章节时是否滚动到特定章节
    self.isScrollToStageOnSwitchChapter = false
    -- 是否播放翻页动画
    self.isPlayFlipAnim = false
end

function QuestPageView:InitView(questPageViewModel, nowChapterId, nowStageId)
    self.questPageViewModel = questPageViewModel
    self.questInfoModel = self.questPageViewModel:GetModel()
    self.nowStageId = nowStageId
    if nowChapterId == nil then
        local nowChapterId = self.questPageViewModel:GetLastOpenedChapterId()
        if nowChapterId == nil then
            self.nowChapterIndex = self.questInfoModel:GetLastChapterIndex()
        else
            self.nowChapterIndex = self.questInfoModel:GetChapterIndexById(nowChapterId)
        end
    else
        self.nowChapterIndex = self.questInfoModel:GetChapterIndexById(nowChapterId)
    end
    self:SetNowChapterData()
    self.chapterSum = self.questInfoModel:GetChapterSum()
    self.questScrollerView:InitView(self.questPageViewModel, self.nowChapterIndex)
    self.playerLetterBtnBox:SetActive(self.questInfoModel:GetLastStageIndexByChapterIndex(1) > 3)
    self:InitYuNingTip(self.nowChapterIndex)
    
    self.nowChapterId = nowChapterId
end

function QuestPageView:RelocateCareerRaceEntry()
    local entryY = 118
    local guideCareerRaceFlag = cache.getGuideCareerRaceFlag()
    if not guideCareerRaceFlag then
        guideCareerRaceFlag = {}
    end
    guideCareerRaceFlag.isChangeCoordinate = false
    cache.setGuideCareerRaceFlag(guideCareerRaceFlag)
    if self.questPageViewModel:IsHomeBtnShow() then
        entryY = 185
        guideCareerRaceFlag.isChangeCoordinate = true
        cache.setGuideCareerRaceFlag(guideCareerRaceFlag)
    end
    self.careerRaceObj.transform.anchoredPosition = Vector2(0, entryY)
end

--- 设置当前章节数据
function QuestPageView:SetNowChapterData()
    self.nowChapterData = self.questInfoModel:GetChapterDataByIndex(self.nowChapterIndex)
    self.questPageViewModel:SetLastOpenedChapterId(self.nowChapterData.chapterId)
end

function QuestPageView:awake()
    self:BindAll()
    self:RegisterEvent()
end

function QuestPageView:RefreshPage(isRefreshPage, isFromStartGame)
    -- 从大卡进出主线后再从首页进出主线时需要刷新主线章节
    local isDiscard = self.questPageViewModel:GetDataStorageType()
    if not isDiscard then
        if isRefreshPage and isFromStartGame then
            self.nowChapterIndex = self.questInfoModel:GetLastChapterIndex()
            self:SetNowChapterData()
            self.questScrollerView:InitView(self.questPageViewModel, self.nowChapterIndex)
        else
            local viewDiscardData = self.questPageViewModel:GetViewDiscardData()
            if viewDiscardData ~= nil and next(viewDiscardData) then
                local nowChapterId = self.questPageViewModel:GetLastOpenedChapterId()
                if nowChapterId ~= nil then
                    self.nowChapterIndex = self.questInfoModel:GetChapterIndexById(nowChapterId)
                    self:SetNowChapterData()
                    self.questScrollerView:InitView(self.questPageViewModel, self.nowChapterIndex)
                end
                self.questPageViewModel:SetViewDiscardData()
            end
        end

        GameObjectHelper.FastSetActive(self.menuBarDynParent.gameObject, true)
        GameObjectHelper.FastSetActive(self.homeBtn.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.menuBarDynParent.gameObject, false)
        GameObjectHelper.FastSetActive(self.homeBtn.gameObject, true)
    end

    self:BuildPage()
    self:IsShowPlayerLetterRedPoint()
    self:InitYuNingTip(self.nowChapterIndex)
    EventSystem.SendEvent("ChapterPageView.ControlScrollRect")
    self:ShowCareerRaceRedPoint()
    self:IsShowRaceBtn()
    self:RelocateCareerRaceEntry()
    self.questInfoModel:CheckInfoEmptyData()
end

function QuestPageView:BindAll()
    -- 左切换按钮
    self.leftSwitchBtn:regOnButtonClick(function ()
        self:ChangeToPreviousChapter()
    end)

    -- 右切换按钮
    self.rightSwitchBtn:regOnButtonClick(function ()
        self:ChangeToNextChapter()
    end)

    -- 球员信函按钮
    self.playerLetterBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.playerLetter.PlayerLetterCtrl")
    end)

    -- 生涯竞速按钮
    self.careerRaceBtn:regOnButtonClick(function ()
        if self.clickBtnCareerRace then
            self.clickBtnCareerRace()
        end
    end)

    -- 首页按钮
    self.homeBtn:regOnButtonClick(function()
        self.questPageViewModel:SetViewDiscardData()
        self.questPageViewModel:SetDataStorageType(false)
        self.questPageViewModel:SetLastOpenedChapterId()
        cache.setRequiredEquipId(nil)
        cache.setRequiredEquipStageId(nil)
        self:SetStageId()
        res.ChangeScene("ui.controllers.home.HomeMainCtrl")
        res.ClearCtrlStack()
    end)
end

function QuestPageView:RegOnDynamicLoad(func)
    self.infoBarBox:RegOnDynamicLoad(func)
end

--- 构建界面
function QuestPageView:BuildPage()
    -- 左切换按钮
    GameObjectHelper.FastSetActive(self.leftSwitchBtn.gameObject, self.nowChapterIndex > 1)
    -- 右切换按钮
    GameObjectHelper.FastSetActive(self.rightSwitchBtn.gameObject, self.nowChapterIndex < self.chapterSum)
end

--- 到上一章
function QuestPageView:ChangeToPreviousChapter()
    if self.nowChapterIndex > 1 then
        self:GoToChapterByIndex(self.nowChapterIndex - 1, false, true)
    end
end

--- 到下一章
function QuestPageView:ChangeToNextChapter()
    if self.nowChapterIndex < self.chapterSum then
        self:GoToChapterByIndex(self.nowChapterIndex + 1, false, true)
    end
end

--- 刷新界面
-- @param nowChapterIndex 当前章节索引
function QuestPageView:RefreshChapterPage(nowChapterIndex)
    self.nowChapterIndex = nowChapterIndex
    self:SetNowChapterData()
    self:BuildPage()
end

function QuestPageView:OnPostAgain()
    self:coroutine(function()
        local respone = req.questInfo()
        if api.success(respone) then
            self.questInfoModel:InitWithProtocol(cache.getQuestInfo())
            local nowChapterId = self.nowChapterId
            if self.nowStageId then
                nowChapterId = self.questInfoModel:GetChapterIdByStageId(self.nowStageId)
            end

            self:InitView(self.questPageViewModel, nowChapterId, self.nowStageId)
        end
    end)
end

--- 注册事件
function QuestPageView:RegisterEvent()
    EventSystem.AddEvent("QuestPageView.RefreshChapterPage", self, self.RefreshChapterPage)
    EventSystem.AddEvent("QuestPageView.GoToChapter", self, self.GoToChapter)
    EventSystem.AddEvent("QuestPageView.GoToStage", self, self.GoToStage)
    EventSystem.AddEvent("ReqEventModel_letterFinish", self, self.IsShowFinishBubble)
    EventSystem.AddEvent("StagePageView.StartMatch", self, self.SetMatchStageId)
    EventSystem.AddEvent("ReqEventModel_letter", self, self.IsShowPlayerLetterRedPoint)
    EventSystem.AddEvent("QuestPage_UpdateInfo", self, self.UpdateQuestInfo)
    EventSystem.AddEvent("ReqEventModel_letterUnReceive", self, self.IsShowPlayerLetterEffect)
    EventSystem.AddEvent("QuestPageView.PlayGetPlayerLetterEffect", self, self.PlayGetPlayerLetterEffect)
    EventSystem.AddEvent("LetterMoveEnd", self, self.OnLetterMoveEnd)
    EventSystem.AddEvent("Quest_SetStageId", self, self.SetStageId)
    EventSystem.AddEvent("Quest_OnSpanDay", self, self.OnSpanDay)
    EventSystem.AddEvent("QuestInfo_PostAgain", self, self.OnPostAgain)
    EventSystem.AddEvent("ReqEventModel_activity", self, self.ShowCareerRaceRedPoint)
end

--- 移除事件
function QuestPageView:RemoveEvent()
    EventSystem.RemoveEvent("QuestPageView.RefreshChapterPage", self, self.RefreshChapterPage)
    EventSystem.RemoveEvent("QuestPageView.GoToChapter", self, self.GoToChapter)
    EventSystem.RemoveEvent("QuestPageView.GoToStage", self, self.GoToStage)
    EventSystem.RemoveEvent("StagePageView.StartMatch", self, self.SetMatchStageId)
    EventSystem.RemoveEvent("ReqEventModel_letterFinish", self, self.IsShowFinishBubble)
    EventSystem.RemoveEvent("ReqEventModel_letter", self, self.IsShowPlayerLetterRedPoint)
    EventSystem.RemoveEvent("QuestPage_UpdateInfo", self, self.UpdateQuestInfo)
    EventSystem.RemoveEvent("ReqEventModel_letterUnReceive", self, self.IsShowPlayerLetterEffect)
    EventSystem.RemoveEvent("QuestPageView.PlayGetPlayerLetterEffect", self, self.PlayGetPlayerLetterEffect)
    EventSystem.RemoveEvent("LetterMoveEnd", self, self.OnLetterMoveEnd)
    EventSystem.RemoveEvent("Quest_SetStageId", self, self.SetStageId)
    EventSystem.RemoveEvent("Quest_OnSpanDay", self, self.OnSpanDay)
    EventSystem.RemoveEvent("QuestInfo_PostAgain", self, self.OnPostAgain)
    EventSystem.RemoveEvent("ReqEventModel_activity", self, self.ShowCareerRaceRedPoint)
end

--- 跳转至特定章节
function QuestPageView:GoToChapterByIndex(chapterIndex, isScrollToStage, isPlayFlipAnim)
    -- 章节是否已开启
    local isChapterOpened = self.questInfoModel:CheckChapterOpenedByIndex(chapterIndex)
    self.isPlayFlipAnim = isPlayFlipAnim or false

    -- 如果章节已开启
    if isChapterOpened == true then
        self.destChapterIndex = chapterIndex
        self.isScrollToStageOnSwitchChapter = isScrollToStage
        self:JumpChapter()
    else
        -- 上一章节是否已通关
        local isNowChapterCleared = self.questInfoModel:CheckChapterClearedByIndex(chapterIndex - 1)
        -- 如果上一章节已通关，但是下一章节未开启，说明玩家等级未达到开启条件
        if isNowChapterCleared == true then
            local chapterData = self.questInfoModel:GetChapterDataByIndex(chapterIndex)
            DialogManager.ShowToast(lang.trans("level_unlock", chapterData.staticData.condition1))
        else
            DialogManager.ShowToastByLang("quest_chapterNoCleared")
        end
    end

    return isChapterOpened
end

--- 跳转至特定章节
function QuestPageView:GoToChapter(chapterId, isScrollToStage)
    isScrollToStage = isScrollToStage or false
    local chapterIndex = self.questInfoModel:GetChapterIndexById(chapterId)
    if chapterIndex == self.nowChapterIndex and isScrollToStage == false then
        return
    end

    self:GoToChapterByIndex(chapterIndex, isScrollToStage)
end

--- 跳转到特定关卡
function QuestPageView:GoToStage(stageId)
    cache.setRequiredEquipStageId(stageId)
    local isOpened = self.questInfoModel:CheckStageOpenedById(stageId)
    if isOpened then
        local chapterId = self.questInfoModel:GetChapterIdByStageId(stageId)
        self:SetStageId(stageId)
        self:GoToChapter(chapterId, true)
    else
        DialogManager.ShowToastByLang("quest_stageNotOpened")
    end
end

function QuestPageView:SetMatchStageId(stageId)
    self.questPageViewModel:SetMatchStageId(stageId)
    self:SetStageId(stageId)
end

--- 更新副本信息
function QuestPageView:UpdateQuestInfo(updateData)
    self.questPageViewModel:UpdateProtocolData(updateData)
    EventSystem.SendEvent("StagePage.RefreshView")
end

function QuestPageView:onDestroy()
    self:RemoveEvent()
end

function QuestPageView:IsShowFinishBubble()
    local letter = ReqEventModel.GetInfo("letterFinish")
    GameObjectHelper.FastSetActive(self.commonTip, tonumber(letter) > 0)
end

function QuestPageView:RegOnMenuBarDynamicLoad(func)
    self.menuBarDynParent:RegOnDynamicLoad(func)
end

function QuestPageView:IsShowPlayerLetterRedPoint()
    local letter = ReqEventModel.GetInfo("letter")
    -- if tonumber(letter) > 0 then
    --     self.playerLetterRedPoint:SetActive(true)
    -- else
    --     self.playerLetterRedPoint:SetActive(false)
    -- end
end

function QuestPageView:IsShowRaceBtn()
    local questInfoModel = QuestInfoModel.new()
    local isOpen = questInfoModel:CheckStageOpenedByIndex(1, 7)
    GameObjectHelper.FastSetActive(self.careerRaceBtn.gameObject, isOpen)
end

function QuestPageView:ShowCareerRaceRedPoint()
    local isShow = false
    local activity = ReqEventModel.GetInfo("activity")
    if type(activity.CareerRaceSelf) == "table" then
        local flagValue = 1
        local CareerRaceSelf = activity.CareerRaceSelf
        for k, v in pairs(CareerRaceSelf) do
            flagValue = v
        end
        isShow = tonumber(flagValue) == 0
    end
    GameObjectHelper.FastSetActive(self.careerRaceRedPointObj, isShow)
end

function QuestPageView:IsShowPlayerLetterEffect()
    local letterUnReceive = ReqEventModel.GetInfo("letterUnReceive")
    if tonumber(letterUnReceive) > 0 then
        self.playerLetterEffect:SetActive(true)
    else
        self.playerLetterEffect:SetActive(false)
    end
end

function QuestPageView:PlayGetPlayerLetterEffect()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerLetterTrigger.prefab", "camera", false, false)
    dialogcomp.contentcomp:InitView(self.playerLetterBtnTrans.position)
end

function QuestPageView:InitYuNingTip(chapterIndex)
    -- 第一封球员来信的提示只在Q103完成并且Q105没有完成的时候显示
    local Q103StageInfoModel = self.questInfoModel:GetStageInfoModelById("Q103")
    local Q105StageInfoModel = self.questInfoModel:GetStageInfoModelById("Q104")
    GameObjectHelper.FastSetActive(self.letterTip, Q103StageInfoModel:CheckStageCleared() and not Q105StageInfoModel:CheckStageCleared())
end

function QuestPageView:SetStageId(stageId)
    self.questPageViewModel:SetStageId(stageId)
end

--- 跳转到某章节
function QuestPageView:JumpChapter()
    self.questScrollerView:JumpChapter(self.destChapterIndex, self.isScrollToStageOnSwitchChapter, self.isPlayFlipAnim)
end

function QuestPageView:OnLetterMoveEnd()
    self:coroutine(function()
        GameObjectHelper.FastSetActive(self.effectPlayerLetterFlash, true)
        coroutine.yield(clr.UnityEngine.WaitForSeconds(3))
        GameObjectHelper.FastSetActive(self.effectPlayerLetterFlash, false)
    end)
end

function QuestPageView:OnSpanDay(questData)
    self.questPageViewModel:UpdateProtocolData(questData.list)
end

return QuestPageView