local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color

local DialogManager = require("ui.control.manager.DialogManager")
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local ItemModel = require("ui.models.ItemModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local QuestPlotModel = require("ui.models.quest.questPlot.QuestPlotModel")
local QuestPlotManager = require("ui.controllers.quest.questPlot.QuestPlotManager")
local QuestConstants = require("ui.scene.quest.QuestConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")

local StagePageView = class(unity.base)

local function IsNeedShowUseSymbol(playerData, equipID)
    local CardBuilder = require("ui.common.card.CardBuilder")
    for k, pcid in pairs(playerData) do
        local playerModel = CardBuilder.GetStarterModel(pcid)
        playerModel:InitEquipsAndSkills()
        if playerModel:HasNeedEquip(equipID) then
            return true
        end
    end
end

function StagePageView:ctor()
    -- 关卡名称
    self.stageName = self.___ex.stageName
    -- 星星组
    self.starGroup = self.___ex.starGroup
    -- 所需体力
    self.strengthNum = self.___ex.strengthNum
    -- 挑战次数
    self.challengeNum = self.___ex.challengeNum
    -- 开始比赛按钮
    self.startBtn = self.___ex.startBtn
    -- 掉落奖励滚动内容框
    self.rewardScrollerContent = self.___ex.rewardScrollerContent
    -- 单次扫荡
    self.sweepOnce = self.___ex.sweepOnce
    self.sweepOnceButton = self.___ex.sweepOnceButton
    -- 十连扫荡
    self.sweepRepeatedly = self.___ex.sweepRepeatedly
    self.sweepRepeatedlyButton = self.___ex.sweepRepeatedlyButton
    -- 队伍名称
    self.teamName = self.___ex.teamName
    -- 队伍战力
    self.teamPower = self.___ex.teamPower
    -- 默认队伍战力
    self.defaultTeamPower = self.___ex.defaultTeamPower
    -- 队伍logo
    self.teamLogo = self.___ex.teamLogo
    -- 通关条件视图
    self.stageConditionView = self.___ex.stageConditionView
    -- 扫荡劵
    self.sweepCuponNumText = self.___ex.sweepCuponNumText
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 扫荡一次按钮的文本
    self.sweepNormalText = self.___ex.sweepNormalText
    self.sweepDisabledText = self.___ex.sweepDisabledText
    -- 扫荡十次按钮的文本
    self.sweepTenNormalText = self.___ex.sweepTenNormalText
    self.sweepTenDisabledText = self.___ex.sweepTenDisabledText
    -- 剧情回放按钮
    self.playbackBtn = self.___ex.playbackBtn
    self.strengthTipTrans = self.___ex.strengthTipTrans
    self.challengeTimesTipTrans = self.___ex.challengeTimesTipTrans
    self.strengthTipText = self.___ex.strengthTipText
    self.challengeTimesTipText = self.___ex.challengeTimesTipText
    self.requirementArea = self.___ex.requirementArea
    self.rewardsArea = self.___ex.rewardsArea
    self.sweepArea = self.___ex.sweepArea
    self.startBtnTrans = self.___ex.startBtnTrans
    -- 条件标题
    self.conditionTitle = self.___ex.conditionTitle
    -- 特殊条件
    self.specialConditionText = self.___ex.specialConditionText
    -- 普通条件组
    self.normalConditionGroup = self.___ex.normalConditionGroup
    -- 新手引导箭头
    self.guideArrow = self.___ex.guideArrow
    -- 主线副本单独关卡数据模型
    self.stageInfoModel = nil
    -- 当前星级
    self.nowStar = nil
    -- 当前关卡数据
    self.nowStageData = nil
    -- 玩家信息数据模型
    self.playerInfoModel = nil
    -- 玩家队伍model
    self.playerTeamsModel = nil
    self.itemsMapModel = nil
    -- 扫荡劵的数量
    self.sweepCuponNum = nil
    -- 挑战次数
    self.challegeTimes = nil
    -- 关卡Id
    self.stageId = nil
    -- 新的关卡数据模型
    self.newStageInfoModel = nil
    -- 关卡是否已通关
    self.isCleared = false
    -- 是否开启双倍掉落活动
    self.isDoubleDrop = false
end

function StagePageView:InitView(stageInfoModel)
    self.stageInfoModel = stageInfoModel
    self.nowStageData = self.stageInfoModel:GetData()
    self.nowStar = self.stageInfoModel:GetStar()
    self.stageId = self:GetStageId()
    self.isCleared = self.stageInfoModel:CheckStageCleared()
    self:EnterView()
    self:RefreshView()
end

function StagePageView:awake()
    self:RegisterEvent()
    self:BindAll()
end

function StagePageView:EnterView()
    self:BuildRewardScroller()
end

function StagePageView:RefreshView()
    self:BuildPage()
end

function StagePageView:SetIsOpenDoubleDrop(data)
    -- 双倍掉落活动开启
    if data.equip ~= nil then
        self.isDoubleDrop = true
        self.dropTime = tonumber(data.equip)
    end
    self:InitMoreSweepTxt()
end

function StagePageView:BindAll()
    -- 开始比赛按钮
    self.startBtn:regOnButtonClick(function ()
        -- 挑战次数不足
        if self.challegeTimes <= 0 then
            self:ChallengeTimesNotEnough()
            return
        end

        -- 体力不足
        local playerPower = self:GetPlayerStrength()
        if playerPower < self.stageInfoModel:GetCostStrength() then
            self:AskBuyStrengthOrNot()
            return
        end

        self:coroutine(function()
            EventSystem.SendEvent("StagePageView.StartMatch", self.stageId)
            local response = req.questAccept(self.stageId)
            if api.success(response) then
                res.RemoveCurrentSceneDialogsInfo()
                cache.setQuestId(self.stageId)
                local CustomEvent = require("ui.common.CustomEvent")
                CustomEvent.StoryMatchStart(self.stageId, self:GetPlayerPower())
                local MatchLoader = require("coregame.MatchLoader")
                MatchLoader.startMatch(response.val)
            end
        end)
    end)

    -- 扫荡一次按钮
    self.sweepOnce:regOnButtonClick(function()
        -- 没有三星通关
        if self.nowStar < 3 then
            self:AlertOnlyThreeStarsCanSweep()
            return
        end

        -- 挑战次数不足
        if self.challegeTimes <= 0 then
            self:ChallengeTimesNotEnough()
            return
        end

        -- 体力不足
        local playerPower = self:GetPlayerStrength()
        if playerPower < self.stageInfoModel:GetCostStrength() then
            self:AskBuyStrengthOrNot()
            return
        end

        -- 扫荡券不足
        if self.sweepCuponNum == 0 then
            self:AskBuySweepCuponOrNot()
            return
        end

        self:SweepOnce()
    end)

    -- 扫荡十次按钮
    self.sweepRepeatedly:regOnButtonClick(function()
        
        -- 没有三星通关
        if self.nowStar < 3 then
            self:AlertOnlyThreeStarsCanSweep()
            return
        end

        -- 挑战次数不足
        if self.challegeTimes <= 0 then
            self:ChallengeTimesNotEnough()
            return
        end
        self:SweepMoreTime()
    end)

    -- 剧情回放按钮
    self.playbackBtn:regOnButtonClick(function ()
        local plotShowPos = self.stageInfoModel:GetRead()
        if plotShowPos ~= QuestConstants.QuestPlotShowPos.MATCH_STAGE_FIRST then
            local questPlotModel = QuestPlotModel.new(self.stageId, QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE)
            local callback = function()
                if questPlotModel:GetHasStageAfter() then
                    questPlotModel:SetShowPos(QuestConstants.QuestPlotShowPos.MATCH_STAGE_AFTER)
                    QuestPlotManager.Show(questPlotModel)
                end
            end
            QuestPlotManager.Show(questPlotModel, callback)
        end
    end)
end

function StagePageView:CalculateSweepTime()
    local id = cache.getRequiredEquipId()
    local count = cache.getRequiredEquipCount() or 1
    local isSweepStage = false
    local sweepTime = 0
    if id ~= nil then
        local stageId = cache.getRequiredEquipStageId()
        if stageId == nil then
            isSweepStage = true
        else
            if self.nowStageData.stageId == stageId then
                isSweepStage = true
            end
        end
        local equipPieceModel = ItemDetailModel.new(id)
        local needNum = equipPieceModel:GetCompositePieceNum() * count
        local currNum = equipPieceModel:GetEquipPieceNum()
        sweepTime = needNum - currNum
        if sweepTime <= 0 then
            sweepTime = 1
        end
        sweepTime = math.ceil(sweepTime/(self.dropTime or 1))
        sweepTime = math.clamp(sweepTime, 1, 10)

        if not isSweepStage then
            sweepTime = 10
        end
    else
        if self.challegeTimes > 10 then
            sweepTime = 10
        else
            sweepTime = self.challegeTimes
            if sweepTime == 0 then
                sweepTime = 10
            end
        end
    end
    self.sweepTime = sweepTime
end

function StagePageView:SweepMoreTime()
    local playerPower = self:GetPlayerStrength()
    if playerPower < self.stageInfoModel:GetCostStrength() * self.sweepTime then
        self:AskBuyStrengthOrNot()
        return
    end

    if self.sweepCuponNum < self.sweepTime then
        self:AskBuySweepCuponOrNot()
        return
    end

    self:SweepRepeatedly(self.sweepTime)
end

--- 注册事件
function StagePageView:RegisterEvent()
    EventSystem.AddEvent("StagePage_InitView", self, self.InitView)
    EventSystem.AddEvent("StagePage.EnterView", self, self.EnterView)
    EventSystem.AddEvent("StagePage.RefreshView", self, self.RefreshView)
    EventSystem.AddEvent("StagePage_PlayMoveOutAnim", self, self.PlayMoveOutAnim)
    EventSystem.AddEvent("StagePageView_SetIsOpenDoubleDrop", self, self.SetIsOpenDoubleDrop)
    EventSystem.AddEvent("GuideManager.MainGuideEnd", self, self.SetGuideArrow)
    EventSystem.AddEvent("GuideManager.RaceGuideActive", self, self.SetGuideArrowHide)
end

--- 移除事件
function StagePageView:RemoveEvent()
    EventSystem.RemoveEvent("StagePage_InitView", self, self.InitView)
    EventSystem.RemoveEvent("StagePage.EnterView", self, self.EnterView)
    EventSystem.RemoveEvent("StagePage.RefreshView", self, self.RefreshView)
    EventSystem.RemoveEvent("StagePageView_SetIsOpenDoubleDrop", self, self.SetIsOpenDoubleDrop)
    EventSystem.RemoveEvent("StagePage_PlayMoveOutAnim", self, self.PlayMoveOutAnim)
    EventSystem.RemoveEvent("GuideManager.MainGuideEnd", self, self.SetGuideArrow)
    EventSystem.RemoveEvent("GuideManager.RaceGuideActive", self, self.SetGuideArrowHide)
    EventSystem.RemoveEvent("GuideManager.MainGuideEnd", self, self.SetGuideArrow)
end

function StagePageView:ChallengeTimesNotEnough()
    clr.coroutine(function ()
        local response = req.questResetCost(self.stageId)
        if api.success(response) then
            local data = response.val
            local reset = tonumber(data.reset)
            local resetMaxTimes = tonumber(data.resetMaxTimes)
            if reset < resetMaxTimes then
                self:GotoResetPage(reset, resetMaxTimes)
            else
                self:GotoVIPPage()
            end
        end
    end)
end

function StagePageView:GotoVIPPage()
    local vipLevel = self.playerInfoModel:GetVipLevel()
    local callback = nil
    local gotoVIPLevel  = nil
    local content = lang.trans("request_tip")
    if vipLevel <= 3 then 
        gotoVIPLevel = 4
    elseif vipLevel <= 6 then 
        gotoVIPLevel = 7
    elseif vipLevel <= 11 then 
        gotoVIPLevel = 12
    elseif vipLevel <= 13 then 
        gotoVIPLevel = 14
        callback = function () res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", "vip", 14) end
        content = lang.trans("request_tip")
    else
        content = lang.trans("request_reset_time_is_zero")
    end
    if gotoVIPLevel == nil then
        callback = nil
    else
        callback = function () res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", "vip", gotoVIPLevel) end
    end
    DialogManager.ShowConfirmPop(lang.trans("tips"), content, callback)
end

function StagePageView:GotoResetPage(currResetTime, maxResetTime)
    local content = lang.transstr("request_reset_time") .. tostring(maxResetTime - currResetTime) .. "/" .. tostring(maxResetTime)
    local callback = function ()
        clr.coroutine(function ()
            local response = req.questReset(self.stageId)
            if api.success(response) then
                EventSystem.SendEvent("QuestPage_UpdateInfo", response.val.questInfo)
            end
        end
        )
    end
    DialogManager.ShowConfirmPop(lang.trans("tips"), content, callback)
end

function StagePageView:SweepOnce()
    local SweepOnceCtrl = require("ui.controllers.quest.sweep.SweepOnceCtrl")
    SweepOnceCtrl.new(self.stageInfoModel)
end

function StagePageView:SweepRepeatedly(sweepTime)
    local SweepRepeatedlyCtrl = require("ui.controllers.quest.sweep.SweepRepeatedlyCtrl")
    SweepRepeatedlyCtrl.new(self.stageInfoModel, sweepTime)
end

function StagePageView:BuildPage()
    local AssetFinder = require("ui.common.AssetFinder")
    -- 名称
    self.stageName.text = self.stageInfoModel:GetSerialNumber() .. "  " .. self.stageInfoModel:GetStageName()
    -- 队伍名称
    self.teamName.text = self.stageInfoModel:GetTeamName()
    -- 队伍战力
    local teamPower = self.stageInfoModel:GetTeamPower()
    local isShowPower = teamPower < 10000000
    if isShowPower then
        self.teamPower.text = tostring(self.stageInfoModel:GetTeamPower())
    end
    GameObjectHelper.FastSetActive(self.teamPower.gameObject, isShowPower)
    GameObjectHelper.FastSetActive(self.defaultTeamPower.gameObject, not isShowPower)

    -- 队徽
    local teamLogoId = self.stageInfoModel:GetTeamLogo()
    self.teamLogo.overrideSprite = AssetFinder.GetTeamIcon(teamLogoId)
    -- 所需体力
    self.strengthNum.text = tostring(self.stageInfoModel:GetCostStrength())
    -- 挑战次数
    self.challegeTimes = tonumber(self.nowStageData.remainCnt)
    self.challengeNum.text = "<color=#EB7227>" .. self.challegeTimes .. "</color>/20"

    -- 关卡星级
    for i = 1, 3 do
        local starBox = self.starGroup:GetChild(i - 1)
        local star = starBox:Find("Star" .. i)
        GameObjectHelper.FastSetActive(star.gameObject, i <= self.nowStar)
    end

    self:BuildSweepArea()
    self:AdjustViewByConditions()
    self:BuildPlaybackBtn()
    self:SetGuideArrow()

    -- 进入时刷新装备掉落的绿点逻辑
    self:RefreshRewardContent()
end

function StagePageView:RefreshRewardContent()
    if not self.rewardSptMap then return end

    local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
    local playerTeamsModel = PlayerTeamsModel.new()
    playerTeamsModel:Init()
    local initPlayerData = playerTeamsModel:GetInitPlayersData(playerTeamsModel:GetNowTeamId())

    for equipID, spt in pairs(self.rewardSptMap) do
        if spt and spt ~= clr.null then
            local isShowUseSymbol = IsNeedShowUseSymbol(initPlayerData, equipID)
            spt:SetEquipUseSymbol(isShowUseSymbol)
        end
    end
end

function StagePageView:BuildSweepArea()
    local isAllowSweep = self.nowStar == 3
    self.sweepCuponNum = self:GetSweepCuponNum()
    self.sweepCuponNumText.text = "x" .. self.sweepCuponNum
    -- 扫荡十次按钮文本
    self:InitMoreSweepTxt()
    self.sweepTenDisabledText.text = self.sweepTenNormalText.text
    self.sweepOnceButton.interactable = isAllowSweep
    self.sweepOnce:onPointEventHandle(isAllowSweep)
    self.sweepRepeatedlyButton.interactable = isAllowSweep
    self.sweepRepeatedly:onPointEventHandle(isAllowSweep)
    GameObjectHelper.FastSetActive(self.sweepNormalText.gameObject, isAllowSweep)
    GameObjectHelper.FastSetActive(self.sweepDisabledText.gameObject, not isAllowSweep)
    GameObjectHelper.FastSetActive(self.sweepTenNormalText.gameObject, isAllowSweep)
    GameObjectHelper.FastSetActive(self.sweepTenDisabledText.gameObject, not isAllowSweep)
end

function StagePageView:InitMoreSweepTxt()
    self:CalculateSweepTime()
    self.sweepTenNormalText.text = lang.transstr("sweep") .. " x" .. self.sweepTime
end

function StagePageView:AdjustViewByConditions()
    local hasSpecialConditions = self.stageInfoModel:HasSpecialConditions()
    GameObjectHelper.FastSetActive(self.specialConditionText.gameObject, hasSpecialConditions)
    GameObjectHelper.FastSetActive(self.normalConditionGroup, not hasSpecialConditions)
    GameObjectHelper.FastSetActive(self.requirementArea, hasSpecialConditions)
    local conditionList = self.stageInfoModel:GetConditionList()
    -- 有特殊通关条件
    if hasSpecialConditions then
        self.conditionTitle.text = lang.trans("quest_specialCondition")
        self.specialConditionText.text = conditionList[1]
        self.challengeTimesTipTrans.anchoredPosition = Vector2(-105, 150)
        self.challengeTimesTipText.fontSize = 14
        self.challengeNum.fontSize = 14
        self.strengthTipTrans.anchoredPosition = Vector2(119, 150)
        self.strengthTipText.fontSize = 14
        self.strengthNum.fontSize = 14
        self:SetRectTransformPosY(self.rewardsArea, 266)
        self:SetRectTransformPosY(self.sweepArea, -205)
        self:SetRectTransformPosY(self.startBtnTrans, 52)
    else
        self.challengeTimesTipTrans.anchoredPosition = Vector2(-220, 110)
        self.challengeTimesTipText.fontSize = 19
        self.challengeNum.fontSize = 19
        self.strengthTipTrans.anchoredPosition = Vector2(70, 110)
        self.strengthTipText.fontSize = 19
        self.strengthNum.fontSize = 19
        self:SetRectTransformPosY(self.rewardsArea, 341)
        self:SetRectTransformPosY(self.sweepArea, -155)
        self:SetRectTransformPosY(self.startBtnTrans, 80)
    end
end

function StagePageView:BuildPlaybackBtn()
    local questPlotModel = QuestPlotModel.new(self.stageId, QuestConstants.QuestPlotShowPos.MATCH_STAGE_BEFORE)
    local questPlotExisted = QuestPlotManager.CheckQuestPlotExisted(questPlotModel)
    if not questPlotExisted then
        GameObjectHelper.FastSetActive(self.playbackBtn.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.playbackBtn.gameObject, true)
    end
end

function StagePageView:SetRectTransformPosY(rectTrans, posY)
    rectTrans.anchoredPosition = Vector2(rectTrans.anchoredPosition.x, posY)
end

--- 构建掉落奖励滚动列表
function StagePageView:BuildRewardScroller()
    res.ClearChildren(self.rewardScrollerContent)
    self.rewardSptMap = {}

    local itemDropData = self.nowStageData.staticData.itemDrop
    local equipBoxPrefab = nil
    local equipList = itemDropData.Rand1.eqs
    if equipList ~= nil then
        equipBoxPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
        for i, v in ipairs(equipList) do
            self:BuildEquipBox(v[1], equipBoxPrefab, false)
        end
    end

    local equipPieceList = itemDropData.Rand1.equipPiece
    if equipPieceList ~= nil then
        if equipBoxPrefab == nil then
            equipBoxPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
        end
        for i, v in ipairs(equipPieceList) do
            self:BuildEquipBox(v[1], equipBoxPrefab, true)
        end
    end

    local itemList = itemDropData.Rand2.item
    if itemList ~= nil then
        local itemBoxObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
        for i, v in ipairs(itemList) do
            local itemModel = ItemModel.new(v[1])
            local go = Object.Instantiate(itemBoxObj)
            go.transform:SetParent(self.rewardScrollerContent, false)
            local goScript = go:GetComponent(clr.CapsUnityLuaBehav)
            goScript:InitView(itemModel, v[1], true, false, true, ItemOriginType.OTHER)
            goScript:SetNameColor(Color(0.196, 0.196, 0.196), Color(1, 1, 1, 0.5))
        end
    end
end

function StagePageView:BuildEquipBox(equipId, equipBoxPrefab, isShowPiece)
    local equipItemModel = EquipItemModel.new()
    equipItemModel:InitWithStaticId(equipId)
    local obj = Object.Instantiate(equipBoxPrefab)
    obj.transform:SetParent(self.rewardScrollerContent, false)
    local objScript = obj:GetComponent(clr.CapsUnityLuaBehav)
    objScript:InitView(equipItemModel, equipId, true, false, isShowPiece, true, ItemOriginType.OTHER)
    objScript:SetNameColor(Color(0.196, 0.196, 0.196), Color(1, 1, 1, 0.5))

    self.rewardSptMap[tostring(equipId)] = objScript
end

--- 获取玩家体力
function StagePageView:GetPlayerStrength()
    if self.playerInfoModel == nil then
        local PlayerInfoModel = require("ui.models.PlayerInfoModel")
        self.playerInfoModel = PlayerInfoModel.new()
    end
    return self.playerInfoModel:GetStrengthPower()
end

--- 获取玩家等级
function StagePageView:GetPlayerLevel()
    if self.playerInfoModel == nil then
        local PlayerInfoModel = require("ui.models.PlayerInfoModel")
        self.playerInfoModel = PlayerInfoModel.new()
    end
    return self.playerInfoModel:GetLevel()
end

--- 获取玩家战力
function StagePageView:GetPlayerPower()
    if self.playerTeamsModel == nil then
        local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
        self.playerTeamsModel = PlayerTeamsModel.new()
    end
    return self.playerTeamsModel:GetTotalPower()
end

--- 获取扫荡券的数量
function StagePageView:GetSweepCuponNum()
    local CommonConstants = require("ui.common.CommonConstants")
    if self.itemsMapModel == nil then
        local ItemsMapModel = require("ui.models.ItemsMapModel")
        self.itemsMapModel = ItemsMapModel.new()
    end
    return self.itemsMapModel:GetItemNum(CommonConstants.SweepItemId)
end

--- 询问是否购买体力
function StagePageView:AskBuyStrengthOrNot()
    DialogManager.ShowConfirmPopByLang("quest_title", "strengthNotEnoughAndBuy", function ()
        local UserStrengthCtrl = require("ui.controllers.user.UserStrengthCtrl")
        UserStrengthCtrl.new()
    end)
end

--- 询问是否购买扫荡券
function StagePageView:AskBuySweepCuponOrNot()
    DialogManager.ShowConfirmPopByLang("quest_title", "sweepCuponNotEnoughAndBuy", function ()
        clr.coroutine(function ()
            coroutine.yield(UnityEngine.WaitForSeconds(0.05))
            local StoreModel = require("ui.models.store.StoreModel")
            res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
        end)
    end)
end

--- 提示三星通关才能扫荡
function StagePageView:AlertOnlyThreeStarsCanSweep()
    DialogManager.ShowAlertPopByLang("quest_title", "quest_onlyThreeStarsCanSweep")
end

function StagePageView:PlayMoveInAnim()
    self.animator:Play("Base Layer.MoveIn", 0)
end

function StagePageView:PlayMoveOutAnim(stageInfoModel)
    if not self.gameObject.activeInHierarchy then
        return
    end
    self.newStageInfoModel = stageInfoModel
    self.animator.enabled = true
    self.animator:Play("Base Layer.MoveOut", 0)
end

function StagePageView:EndAnimation()
    self.gameObject:SetActive(false)
end

function StagePageView:OnAnimEnd(animMoveType)
    local CommonConstants = require("ui.common.CommonConstants")
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:InitView(self.newStageInfoModel)
        self:PlayMoveInAnim()
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self.animator.enabled = false
    end
end

function StagePageView:SetGuideArrow()
    -- 是否显示引导箭头
    if not GuideManager.GuideIsOnGoing("main") and tonumber(self:GetPlayerLevel()) < 10 and not self.isCleared then
        GameObjectHelper.FastSetActive(self.guideArrow, true)
    else
        GameObjectHelper.FastSetActive(self.guideArrow, false)
    end
end

function StagePageView:SetGuideArrowHide()
    GameObjectHelper.FastSetActive(self.guideArrow, false)
end

function StagePageView:Close()
    self:PlayMoveOutAnim()
end

function StagePageView:GetStageId()
    return self.stageInfoModel:GetStageId()
end

function StagePageView:onDestroy()
    self:RemoveEvent()
    self.rewardSptMap = nil
end

return StagePageView
