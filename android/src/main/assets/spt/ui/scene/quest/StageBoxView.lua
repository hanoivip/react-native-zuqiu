local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local QuestPlotModel = require("ui.models.quest.questPlot.QuestPlotModel")
local QuestPlotManager = require("ui.controllers.quest.questPlot.QuestPlotManager")
local QuestConstants = require("ui.scene.quest.QuestConstants")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local StageBoxView = class(unity.base)

function StageBoxView:ctor()
    -- 关卡序号
    self.stageNum = self.___ex.stageNum
    -- 星星组
    self.starGroup = self.___ex.starGroup
    -- 触摸层
    self.touchMask = self.___ex.touchMask
    -- 队伍logo
    self.teamLogo = self.___ex.teamLogo
    -- 灰色的队伍logo
    self.teamLogoGray = self.___ex.teamLogoGray
    -- 奖杯
    self.cupImg = self.___ex.cupImg
    -- 灰色的奖杯
    self.cupGray = self.___ex.cupGray
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 默认背景
    self.bg = self.___ex.bg
    -- 选中的背景
    self.bgSelected = self.___ex.bgSelected
    -- 未通关的背景
    self.bgNotCleared = self.___ex.bgNotCleared
    -- 奖杯框
    self.cupBox = self.___ex.cupBox
    -- 副本视图model
    self.questPageViewModel = nil
    -- 主线副本数据模型
    self.questInfoModel = nil
    -- 当前章节索引
    self.nowChapterIndex = nil
    -- 关卡索引
    self.nowStageIndex = nil
    -- 主线副本单独关卡数据模型
    self.stageInfoModel = nil
    -- 当前星级
    self.nowStar = nil
    -- 关卡是否开启
    self.isOpen = false
    -- 关卡是否已通关
    self.isCleared = false
end

function StageBoxView:InitView(questPageViewModel, stageInfoModel)
    self.questPageViewModel = questPageViewModel
    self.questInfoModel = self.questPageViewModel:GetModel()
    self.stageInfoModel = stageInfoModel
    self.nowChapterIndex = self.stageInfoModel:GetChapterIndex()
    self.nowStageIndex = self.stageInfoModel:GetStageIndex()
    self.nowStar = self.stageInfoModel:GetStar()
    self.isOpen = self.questInfoModel:CheckStageOpenedByIndex(self.nowChapterIndex, self.nowStageIndex)
    self.isCleared = self.stageInfoModel:CheckStageCleared()
    self:BuildPage()
end

function StageBoxView:start()
    self:BindAll()
    self:RegisterEvent()
end

function StageBoxView:BindAll()
    self.touchMask:regOnButtonClick(function ()
        -- 关卡未开启
        if not self.isOpen then
            return
        end
        self:ShowStagePage()
    end)
end

--- 注册事件
function StageBoxView:RegisterEvent()
    EventSystem.AddEvent("Stage_Select", self, self.SwitchSelectState)
    EventSystem.AddEvent("Stage_PlayUnlockAnim", self, self.PlayUnlockAnim)
    EventSystem.AddEvent("Stage_SetPlayUnlockAnimPreState", self, self.SetPlayUnlockAnimPreState)
    EventSystem.AddEvent("PlayerLetterTrigger_Destroy", self, self.OnPlayerLetterTriggerViewDestroy)
    EventSystem.AddEvent("PlayerLetterDestroy", self, self.OnPlayerLetterDestroy)
end

--- 移除事件
function StageBoxView:RemoveEvent()
    EventSystem.RemoveEvent("Stage_Select", self, self.SwitchSelectState)
    EventSystem.RemoveEvent("Stage_PlayUnlockAnim", self, self.PlayUnlockAnim)
    EventSystem.RemoveEvent("Stage_SetPlayUnlockAnimPreState", self, self.SetPlayUnlockAnimPreState)
    EventSystem.RemoveEvent("PlayerLetterTrigger_Destroy", self, self.OnPlayerLetterTriggerViewDestroy)
    EventSystem.RemoveEvent("PlayerLetterDestroy", self, self.OnPlayerLetterDestroy)
end

function StageBoxView:ShowStagePage()
    EventSystem.SendEvent("Quest_SetStageId", self.stageInfoModel:GetStageId())
    EventSystem.SendEvent("StagePage_PlayMoveOutAnim", self.stageInfoModel)
    EventSystem.SendEvent("Stage_Select")
end

function StageBoxView:BuildPage()
    -- 关卡序号
    self.stageNum.text = self.stageInfoModel:GetSerialNumber()

    -- 关卡已开启
    if self.isOpen then
        -- 关卡星级
        for i = 1, self.starGroup.childCount do
            local starBox = self.starGroup:GetChild(i - 1)
            local star = starBox:GetChild(0)

            if i <= self.nowStar then
                GameObjectHelper.FastSetActive(star.gameObject, true)
            else
                GameObjectHelper.FastSetActive(star.gameObject, false)
            end
        end

        -- 奖杯
        -- TODO: 暂时写死
        -- self.cupImg.sprite = AssetFinder.GetQuestCupCircleIcon(1)

        -- 队徽
        local teamLogoId = self.stageInfoModel:GetTeamLogo()
        self.teamLogo.sprite = AssetFinder.GetTeamIcon(teamLogoId)
        self.teamLogo.color = Color.white
        self.cupImg.color = Color.white
    end

    GameObjectHelper.FastSetActive(self.teamLogoGray.gameObject, self.isOpen)
    GameObjectHelper.FastSetActive(self.starGroup.gameObject, self.isOpen)
    GameObjectHelper.FastSetActive(self.cupBox, self.isOpen)

    self:SwitchSelectState()
end

--- 切换选择动画
function StageBoxView:SwitchSelectState()
    if not self.gameObject.activeInHierarchy then
        return
    end
    local isSelected = self.questPageViewModel:GetStageId() == self.stageInfoModel:GetStageId()
    GameObjectHelper.FastSetActive(self.bg, not isSelected and (self.isCleared or self.isOpen))
    GameObjectHelper.FastSetActive(self.bgNotCleared, not isSelected and not self.isCleared and not self.isOpen)
    GameObjectHelper.FastSetActive(self.bgSelected, isSelected)
    if isSelected then
        self:PlaySelectAnim()
    else
        if self.isCleared or self.isOpen then
            self:PlayUnselectAnim()
        else
            self:PlayLockAnim()
        end
    end
end

--- 播放选中动画
function StageBoxView:PlaySelectAnim()
    self.animator:Play("Select", 0)
end

--- 播放未选中动画
function StageBoxView:PlayUnselectAnim()
    self.animator:Play("Unselect", 0)
end

--- 播放未解锁动画
function StageBoxView:PlayLockAnim()
    self.animator:Play("Lock", 0)
end

--- 播放通关动画
function StageBoxView:PlayCompleteAnim()
    self.animator:Play("Complete", 0)
end

--- 设置播放解锁动画的准备状态
function StageBoxView:SetPlayUnlockAnimPreState()
    if self.isOpen and not self.isCleared then
        self.teamLogoGray.sprite = self.teamLogo.sprite
        self.cupGray.sprite = self.cupImg.sprite
        self:SetGrayImgEnabled(false)
        self:SetImgActive(false)
        GameObjectHelper.FastSetActive(self.bg, true)
    end
end

--- 播放解锁动画
function StageBoxView:PlayUnlockAnim(bNotLevelUp)
    if self.isOpen and not self.isCleared then
        self.bNotLevelUp = bNotLevelUp and true or false
        self:SetGrayImgEnabled(true)
        self:SetImgActive(true)
        self.animator:Play("Unlock", 0)
        self:CheckPlotIsShow()
    end
end

--- 设置灰度图的激活状态
function StageBoxView:SetGrayImgEnabled(isEnabled)
    self.teamLogoGray.enabled = isEnabled
    self.cupGray.enabled = isEnabled
end

--- 设置logo、奖杯、选中背景的激活状态
function StageBoxView:SetImgActive(isActive)
    GameObjectHelper.FastSetActive(self.teamLogo.gameObject, isActive)
    GameObjectHelper.FastSetActive(self.cupImg.gameObject, isActive)
    GameObjectHelper.FastSetActive(self.bgSelected, isActive)
end

function StageBoxView:OnAnimEnd(animMoveType)
    -- 通关动画
    if animMoveType == 1 then
        
    -- 解锁动画
    elseif animMoveType == 2 then
        self:SetGrayImgEnabled(false)
    end
end

--- 判断是否显示主线剧情
function StageBoxView:CheckPlotIsShow()
    local stageId = self.stageInfoModel:GetStageId()
    local questPlotModel = QuestPlotModel.new(stageId, QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE)
    local questPlotExisted = QuestPlotManager.CheckQuestPlotExisted(questPlotModel)
    if questPlotExisted then
        local plotShowPos = self.stageInfoModel:GetRead()
        if plotShowPos == QuestConstants.QuestPlotShowPos.MATCH_STAGE_FIRST then
            clr.coroutine(function()
                local response = req.questReadStory(stageId, QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE)
                if api.success(response) then
                    local data = response.val
                    self.stageInfoModel:SetRead(data.read)
                end
            end)
            QuestPlotManager.Show(questPlotModel, function() self:OnQuestPlotCompleted() end)
        end
    else
        self:OnPlayerLetterTriggerViewDestroy()
    end
end

--- 剧情结束再弹出球员来信
function StageBoxView:OnQuestPlotCompleted()
    local isPlayEffect = ReqEventModel.GetInfo("letterOpen")
    -- 是否播放球员来信特效
    if isPlayEffect == 1 then
        EventSystem.SendEvent("QuestPageView.PlayGetPlayerLetterEffect")
    else
        self:OnPlayerLetterTriggerViewDestroy()
    end
end

--- 当球员来信特效销毁时
function StageBoxView:OnPlayerLetterTriggerViewDestroy()
    if cache.getHasNoReadMessage() or cache.getHasFinishMessage() then
        res.PushDialog("ui.controllers.playerLetter.PlayerLetterCtrl")
        GuideManager.InitCurModule("letter")
        GuideManager.Show()
    else
        self:OnPlayerLetterDestroy()
    end
end

--球員來信銷毀時
function StageBoxView:OnPlayerLetterDestroy()
    if self.isOpen and not self.isCleared then
        if not self.bNotLevelUp then
            GuideManager.LevelGuide()
            self.bNotLevelUp = true
        end
    end
end

function StageBoxView:onDestroy()
    self:RemoveEvent()
end

return StageBoxView
