local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local RectTransformUtility = UnityEngine.RectTransformUtility
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local EventSystems = UnityEngine.EventSystems

local Helper = require("ui.scene.formation.Helper")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local DialogManager = require("ui.control.manager.DialogManager")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerCardCircle = require("ui.scene.formation.PlayerCardCircle")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local SkillType = require("ui.common.enum.SkillType")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LevelLimit = require("data.LevelLimit")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")
local FormationPageView = class(unity.base)

function FormationPageView:ctor()
    -- 阵容切换按钮
    self.teamBtn = self.___ex.teamBtn
    -- 阵容按钮文本
    self.teamBtnText = self.___ex.teamBtnText
    -- 战力文本区域
    self.powerNumArea = self.___ex.powerNumArea
    -- 右侧按钮组
    self.rightBtnGroup = self.___ex.rightBtnGroup
    -- 阵型按钮
    self.formationBtn = self.___ex.formationBtn
    -- 切换球员显示信息按钮
    self.switchInfoBtn = self.___ex.switchInfoBtn
    -- 切换显示最佳拍档信息按钮
    self.switchCoupleBtn = self.___ex.switchCoupleBtn
    -- 使用推荐阵容按钮
    self.automaticBtn = self.___ex.automaticBtn
    -- 保存并使用按钮
    self.saveBtn = self.___ex.saveBtn
    -- 关键球员按钮
    self.keyPlayerBtn = self.___ex.keyPlayerBtn
    -- 战术调整按钮
    self.tacticsBtn = self.___ex.tacticsBtn
    -- 球员擅长位置组
    self.areaGroup = self.___ex.areaGroup
    -- 首发球员组
    self.initPlayerGroup = self.___ex.initPlayerGroup
    -- 替补球员框
    self.benchContent = self.___ex.benchContent
    -- 候补滚动视图
    self.candidateScrollerView = self.___ex.candidateScrollerView
    -- 候补滚动视图切换按钮
    self.candidateSwitchBtn = self.___ex.candidateSwitchBtn
    -- 候补区域框
    self.candidateBox = self.___ex.candidateBox
    -- 排序按钮
    self.sortBtn = self.___ex.sortBtn
    -- 排序按钮文本
    self.sortBtnText = self.___ex.sortBtnText
    -- 阵型名字相关
    self.formationName = self.___ex.formationName
    -- 保存按钮的多态图片
    self.saveDisableBtn = self.___ex.saveDisableBtn
    self.saveEnableBtn = self.___ex.saveEnableBtn
    -- 换人时五维属性相关
    self.playerAttr1 = self.___ex.shootAttr
    self.playerAttr2 = self.___ex.passAttr
    self.playerAttr3 = self.___ex.dribbleAttr
    self.playerAttr4 = self.___ex.interceptAttr
    self.playerAttr5 = self.___ex.stealAttr
    self.playerAttr1Title = self.___ex.playerAttr1Title
    self.playerAttr2Title = self.___ex.playerAttr2Title
    self.playerAttr3Title = self.___ex.playerAttr3Title
    self.playerAttr4Title = self.___ex.playerAttr4Title
    self.playerAttr5Title = self.___ex.playerAttr5Title
    self.changePlayerAttrsBar = self.___ex.changePlayerAttrsBar
    -- 首发的矩形区域
    self.courtArea = self.___ex.courtArea
    -- 筛选按钮
    self.filterBtn = self.___ex.filterBtn
    -- 球场区域框
    self.courtBox = self.___ex.courtBox
    -- 替补区域框
    self.benchBox = self.___ex.benchBox
    -- 候补框材质
    self.candidateBoardMaterial1 = self.___ex.candidateBoardMaterial1
    self.candidateBoardMaterial2 = self.___ex.candidateBoardMaterial2
    -- 顶部通用标题栏
    self.infoBarDynParent = self.___ex.infoBar
    self.animator = self.___ex.animator
    --最佳拍档tips
    self.coupleTips = self.___ex.coupleTips

    -- 教练
    self.coachEntryGo = self.___ex.coachEntryGo
    self.coachEntryTrans = self.___ex.coachEntryTrans
    self.coachBtn = self.___ex.coachBtn

    --我的場景
    self.mySceneGo = self.___ex.mySceneGo
    self.mySceneTrans = self.___ex.mySceneTrans

    -- 球员队伍模型
    self.playerTeamsModel = nil
    -- 当前阵容Id
    self.nowTeamId = 0
    -- 当前阵型Id
    self.nowFormationId = 0
    -- 首发球员数据
    self.initPlayersData = nil
    -- 替补球员数据
    self.replacePlayersData = nil
    -- 候补球员数据（不重复的）
    self.waitPlayersNoRepeatList = nil
    -- 候补球员数据（重复的）
    self.waitPlayersRepeatList = nil
    -- 总战力
    self.totalPower = nil
    -- 当前卡牌显示类型
    self.nowCardShowType = 0
    -- 当前最近拍档显示状态
    self.coupleState = FormationConstants.CoupleState.HIDE
    -- 候补区域是否是扩展状态
    self.isExpandCandidateBox = false
    -- 拖拽相关
    self.playerCardCircleOnDrop = nil
    self.dataIndexOnDrop = nil
    self.playerClassifyOnDrop = nil
    self.playerCardCircleOnEndDrag = nil
    self.dataIndexOnEndDrag = nil
    self.playerClassifyOnEndDrag = nil
    -- 首发球员脚本列表
    self.initPlayersScriptList = nil
    -- 当前排序类型
    self.nowSortType = 0
    -- 临时缓存数据Model
    self.formationCacheDataModel = nil
    -- 换人时五维属性变化显示时间
    self.playerAttrsShowTime = 3
    -- 门将位置
    self.numberPosWithGk = 26
    -- 阵型选择页面排序方式 1：后卫 2：前锋
    self.selectedType = nil
    self.savedSelectedType = nil
    self.animatorStateIsLeave = false
    -- 最佳拍档队列
    self.chemicalMap = {}

    -- PlayerCardCircle资源路径
    self.playerCardCirclePath = "Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab"

    self.cardResourceCache = CardResourceCache.new()
    self.candidateScrollerView:SetCardResCache(self.cardResourceCache)
end

function FormationPageView:SetChemicalMap()
    self.chemicalMap = {}
    local initPlayersList = self:SortInitPlayersWithPos()
    local index = 1
    local playerCardsMapModel = require("ui.models.PlayerCardsMapModel").new()   
    for i, itemData in pairs(initPlayersList) do
        if itemData.pcId ~= 0 and tonumber(itemData.pcId) ~= 0 then
            local pcId = itemData.pcId
            local skillList = playerCardsMapModel:GetCardData(itemData.pcId).skills
            for k, v in ipairs(skillList) do
                local skillModel = SkillItemModel.new()          
                skillModel:InitWithCache(v)             
                local needChemicalMap = false
                local cardId1, cardId2
                if skillModel:IsChemicalSkill() and skillModel:IsOpen() then
                    needChemicalMap = true
                    cardId1, cardId2 = skillModel:GetChemicalSkillCoupleID()
                elseif skillModel:IsTrainingSkill() and skillModel:GetSkillType() == SkillType.CHEMICAL then
                    needChemicalMap = true
                    cardId1, cardId2 = skillModel:GetTrainingChemicalSkillCoupleID()
                end
                if needChemicalMap then
                    self.chemicalMap[tostring(pcId)] = {}
                    self.chemicalMap[tostring(pcId)].coupleIndex = index
                    self.chemicalMap[tostring(pcId)].coupleID = cardId2
                    index = index + 1
                    break
                end
            end
        end
    end
end

function FormationPageView:GetCoupleIndexList(cid)
    local coupleIndexList = {}
    for k, v in pairs(self.chemicalMap) do
        if v["coupleID"] == cid then
            table.insert(coupleIndexList, v["coupleIndex"])
        end
    end
    return coupleIndexList
end

function FormationPageView:GetCoupleInfo(pcId)
    local coupleInfo = {}
    coupleInfo.coupleIndexList = {}
    coupleInfo.coupleCanActivate = false
    if pcId == nil or tonumber(pcId) == 0 then
        coupleInfo.coupleID = 0
    else
        local tempCardModel = SimpleCardModel.new(pcId)
        if self.chemicalMap[tostring(pcId)] then
            coupleInfo.coupleID = self.chemicalMap[tostring(pcId)].coupleIndex
            local isActivated = self:IsInTeam(self.chemicalMap[tostring(pcId)].coupleID)
            coupleInfo.coupleIsActivated = isActivated
            if not isActivated then
                coupleInfo.coupleCanActivate = self:IsInWait(self.chemicalMap[tostring(pcId)].coupleID)            
            end
        end
        coupleInfo.coupleIndexList = self:GetCoupleIndexList(tempCardModel:GetCid())
    end
    return coupleInfo
end

function FormationPageView:IsInWait(cid)
    for k, v in pairs(self.waitPlayersNoRepeatList) do
        if cid == v:GetCid() then
            return true
        end
    end
end

function FormationPageView:IsInTeam(cid)
    local inInitFlag = false
    local inReplaceFlag = false
    for k, v in pairs(self.initPlayersData) do
        if v ~= 0 and tonumber(v) ~= 0 then
            local tempModel = SimpleCardModel.new(v)
            if cid == tempModel:GetCid() then
                inInitFlag = true
                break
            end
        end
    end

    for k, v in pairs(self.replacePlayersData) do
        if v ~= 0 and tonumber(v) ~= 0 then
            local tempModel = SimpleCardModel.new(v)
            if cid == tempModel:GetCid() then
                inReplaceFlag = true
                break
            end
        end        
    end

    return inInitFlag or inReplaceFlag
end

function FormationPageView:InitView(playerTeamsModel, formationCacheDataModel)
    self.playerTeamsModel = playerTeamsModel
    self.selectedType = self.playerTeamsModel:GetSelectedType()
    self.savedSelectedType = self.selectedType
    self.formationCacheDataModel = formationCacheDataModel
    self.nowTeamId = self.playerTeamsModel:GetNowEditTeamId()
    self.nowCardShowType = self.formationCacheDataModel:GetCardShowType()
    self.coupleState = self.formationCacheDataModel:GetCoupleState()
    self.nowSortType = self.formationCacheDataModel:GetSortType()
    self:RefreshCoachInfo()
    self:RefreshMySceneInfo()
end

function FormationPageView:SetPlayersData()
    self.initPlayersData = self.formationCacheDataModel:GetInitPlayerCacheData()
    self.replacePlayersData = self.formationCacheDataModel:GetReplacePlayerCacheData()
    self.waitPlayersNoRepeatList, self.waitPlayersRepeatList = self.formationCacheDataModel:GetWaitPlayerCacheData(self.nowSortType)
    self:InitCandidateScrollerView()
end

function FormationPageView:SetFormationData()
    self.nowFormationId = self.formationCacheDataModel:GetFormationIdCacheData()
end

function FormationPageView:start()
    self:BindAll()
end

function FormationPageView:BuildPage()
    self:SetChemicalMap()
    self:BuildCount()
    self:BuildBenchBox()
    self:SetTeamBtn()
    self:CalculateTotalPower()
    self:BuildFormationName()
    self:BuildSortBtnText()
    self:SetChangePlayerAttrsBarState(false)
    self:FormationDataChange(self:CheckTeamChanged())
end

function FormationPageView:RefreshPage(isPush)
    self.formationCacheDataModel:BuildTeamLegendInfo()
    self:SetPlayersData()
    self:SetFormationData()
    self:BuildPage()
    self.candidateScrollerView:BuildPage()
    self.candidateScrollerView:scrollToCellImmediate(1)
    if isPush then
        self:PlayAccessAnimation()
    else
        self:AdjustAnimation()
    end
end

-- 在从大卡回来时去掉界面动画，而从其它界面回来则重新播放动画
function FormationPageView:AdjustAnimation()
    if self.animatorStateIsLeave then 
        self.animator:Play("EffectFormationPage")
        self.animatorStateIsLeave = false
    end
end

-- 为所有的按钮绑定事件
function FormationPageView:BindAll()
    -- 阵容按钮
    self.teamBtn:regOnButtonClick(function ()
        --[[暂时关闭此功能
        self:AskSaveTeamOrNot(function ()
            self.nowTeamId = self.nowTeamId + 1
            if self.nowTeamId > 2 then
                self.nowTeamId = 0
            end
            self:SwitchTeam(self.nowTeamId)
        end)]]
    end)

    -- 选择阵型按钮
    self.formationBtn:regOnButtonClick(function ()
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationSelect.prefab", "camera", true, true)
        dialogcomp.contentcomp:InitView(self.playerTeamsModel, self.nowFormationId)
    end)

    -- 切换球员显示信息按钮
    self.switchInfoBtn:regOnButtonClick(function ()
        if self.nowCardShowType == FormationConstants.CardShowType.MAIN_INFO then
            self.nowCardShowType = FormationConstants.CardShowType.LEVEL_INFO
        else
            self.nowCardShowType = FormationConstants.CardShowType.MAIN_INFO
        end

        self.formationCacheDataModel:SetCardShowType(self.nowCardShowType)
        self:InitCandidateScrollerView()
        self:BuildPage()
        self.candidateScrollerView:RefreshScroller()
    end)
    --切换最佳拍档信息显示
    self.switchCoupleBtn:regOnButtonClick(function ()
        if self.coupleState == FormationConstants.CoupleState.HIDE then
            self.coupleState = FormationConstants.CoupleState.SHOW
            GameObjectHelper.FastSetActive(self.coupleTips, true)

            GameObjectHelper.FastSetActive(self.titleArea, false)
            GameObjectHelper.FastSetActive(self.specialEventsTips, false)
        else
            self.coupleState = FormationConstants.CoupleState.HIDE
            GameObjectHelper.FastSetActive(self.coupleTips, false)

            GameObjectHelper.FastSetActive(self.titleArea, true)
            GameObjectHelper.FastSetActive(self.specialEventsTips, true)         
        end
        self.formationCacheDataModel:SetCoupleState(self.coupleState)
        self:InitCandidateScrollerView()
        self:BuildPage()
        self.candidateScrollerView:RefreshScroller()
        self.candidateScrollerView:BuildPage()    
    end)   
    -- 使用推荐阵容按钮
    self.automaticBtn:regOnButtonClick(function ()
        self.initPlayersData, self.replacePlayersData, self.waitPlayersNoRepeatList, self.waitPlayersRepeatList = self.playerTeamsModel:GetRecommendTeam(self.nowFormationId, self.nowSortType)
        self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
        self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
        self.formationCacheDataModel:BuildTeamLegendInfo()
        self:InitCandidateScrollerView()
        self:BuildPage()
        self.candidateScrollerView:BuildPage()
    end)

    -- 保存并使用按钮
    self.saveBtn:regOnButtonClick(function ()
        self:SaveFormation()
    end)

    -- 关键球员按钮
    self.keyPlayerBtn:regOnButtonClick(function()
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationKeyPlayer.prefab", "camera", true, true)
        if self.formationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(self.initPlayersData) then
            self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
            self.formationCacheDataModel:SetKeyPlayersDefaultData()
        end
        dialogcomp.contentcomp:InitView(self.playerTeamsModel, self.formationCacheDataModel)
    end)

    -- 战术调整按钮
    self.tacticsBtn:regOnButtonClick(function()
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationTactics.prefab", "camera", false, true)
        dialogcomp.contentcomp:InitView(self.playerTeamsModel, self.formationCacheDataModel)
    end)

    -- 候补滚动视图切换按钮
    self.candidateSwitchBtn:regOnButtonClick(function ()
        self:ShrinkCandidateBox()
    end)

    -- 排序按钮
    self.sortBtn:regOnButtonClick(function ()
        if self.nowSortType == FormationConstants.SortType.POWER then
            self.nowSortType = FormationConstants.SortType.QUALITY
        elseif self.nowSortType == FormationConstants.SortType.QUALITY then
            self.nowSortType = FormationConstants.SortType.GET_TIME
        elseif self.nowSortType == FormationConstants.SortType.GET_TIME then
            self.nowSortType = FormationConstants.SortType.NAME
        elseif self.nowSortType == FormationConstants.SortType.NAME then
            self.nowSortType = FormationConstants.SortType.POWER
        end

        self.formationCacheDataModel:SetSortType(self.nowSortType)
        self.waitPlayersNoRepeatList, self.waitPlayersRepeatList = self.formationCacheDataModel:GetWaitPlayerCacheData(self.nowSortType)
        self:BuildSortBtnText()
        self:InitCandidateScrollerView()
        self.candidateScrollerView:BuildPage()
    end)

    -- 筛选按钮
    self.filterBtn:regOnButtonClick(function()
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationWaitPlayerFilter.prefab", "camera", true, true)
        dialogcomp.contentcomp:InitView(self.formationCacheDataModel)
        dialogcomp.contentcomp.onFilterConfirm = function(filterPosData) self:OnFilterConfirm(filterPosData) end
    end)

    -- 教练
    self.coachBtn:regOnButtonClick(function()
        self:OnBtnCoachClick()
    end)
end

function FormationPageView:SaveFormation()
    -- 如果阵容已修改
    if self:CheckTeamChanged() then
        -- 阵容是否合法
        local validType = self:CheckTeamValid()
        if validType == FormationConstants.FormationValidType.VALID then
            self:SaveTeamData(function()
                DialogManager.ShowToastByLang("formation_saveSuccess")
                self:FormationDataChange(false)
            end)
        elseif validType == FormationConstants.FormationValidType.NOVALID_INITPLAYERS_NOTENOUGH then
            DialogManager.ShowToastByLang("formation_validType_initPlayers_notEnough")
        elseif validType == FormationConstants.FormationValidType.NOVALID_HASSAMEPLAYER then
            DialogManager.ShowToastByLang("formation_validType_hasSamePlayer")
        end
    else
        DialogManager.ShowToastByLang("formation_noNeedSave")
    end
end

-- 注册事件
function FormationPageView:RegisterEvent()
    EventSystem.AddEvent("FormationPageView.ShowPlayerArea", self, self.ShowPlayerArea)
    EventSystem.AddEvent("FormationPageView.HidePlayerArea", self, self.HidePlayerArea)
    EventSystem.AddEvent("FormationPageView.ReceiveDropPlayer", self, self.ReceiveDropPlayer)
    EventSystem.AddEvent("FormationPageView.ReceiveEndDragPlayer", self, self.ReceiveEndDragPlayer)
    EventSystem.AddEvent("FormationPageView.ChangeFormation", self, self.ChangeFormation)
    EventSystem.AddEvent("ClickPlayerCardCircle", self, self.ShowCardDetail)
    EventSystem.AddEvent("FormationDataChange", self, self.FormationDataChange)
    EventSystem.AddEvent("RemoveWaitPlayer", self, self.RemoveWaitPlayer)
    EventSystem.AddEvent("FormationPageView.ChangeFormationSelectedType", self, self.ChangeFormationSelectedType)
    EventSystem.AddEvent("FormationPageView.ChangeTactic", self, self.CalculateTotalPower)
    EventSystem.AddEvent("MySceneUpdate", self, self.OnHomeCourtUpdate)
end

-- 移除事件
function FormationPageView:UnRegisterEvent()
    EventSystem.RemoveEvent("FormationPageView.ShowPlayerArea", self, self.ShowPlayerArea)
    EventSystem.RemoveEvent("FormationPageView.HidePlayerArea", self, self.HidePlayerArea)
    EventSystem.RemoveEvent("FormationPageView.ReceiveDropPlayer", self, self.ReceiveDropPlayer)
    EventSystem.RemoveEvent("FormationPageView.ReceiveEndDragPlayer", self, self.ReceiveEndDragPlayer)
    EventSystem.RemoveEvent("FormationPageView.ChangeFormation", self, self.ChangeFormation)
    EventSystem.RemoveEvent("ClickPlayerCardCircle", self, self.ShowCardDetail)
    EventSystem.RemoveEvent("FormationDataChange", self, self.FormationDataChange)
    EventSystem.RemoveEvent("RemoveWaitPlayer", self, self.RemoveWaitPlayer)
    EventSystem.RemoveEvent("FormationPageView.ChangeFormationSelectedType", self, self.ChangeFormationSelectedType)
    EventSystem.RemoveEvent("FormationPageView.ChangeTactic", self, self.CalculateTotalPower)
    EventSystem.RemoveEvent("MySceneUpdate", self, self.OnHomeCourtUpdate)
end

-- 构建球场上的球员
function FormationPageView:BuildCount()
    local playerCardCircle = res.LoadRes(self.playerCardCirclePath)
    local index = 0
    local childLoadedCount = self.initPlayerGroup.childCount
    self.initPlayersScriptList = {}

    local initPlayersList = self:SortInitPlayersWithPos()
    for i, itemData in pairs(initPlayersList) do
        local node = nil
        local nodeScript = nil
        local cardShowType = nil
        if itemData.pcId == nil or tonumber(itemData.pcId) == 0 then
            cardShowType = FormationConstants.CardShowType.EMPTY
        else
            cardShowType = self.nowCardShowType
        end
        local coupleInfo = self:GetCoupleInfo(itemData.pcId)
        if index >= childLoadedCount then
            node = Object.Instantiate(playerCardCircle).transform
            nodeScript = node:GetComponent("CapsUnityLuaBehav")
            node:SetParent(self.initPlayerGroup, false)
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.INIT, self.formationCacheDataModel)
            nodeScript:SetChemical(coupleInfo)
            nodeScript:SetCoupleState(self.coupleState)
            nodeScript:SetPos(itemData.pos, self.nowFormationId, 800, 400, 15, false, 1)
            self.initPlayersScriptList[itemData.pos] = nodeScript
        else
            node = self.initPlayerGroup:GetChild(index)
            nodeScript = self.initPlayersScriptList[itemData.pos]
            if nodeScript == nil then
                nodeScript = node:GetComponent("CapsUnityLuaBehav")
                self.initPlayersScriptList[itemData.pos] = nodeScript
            end
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.INIT, self.formationCacheDataModel)
            nodeScript:SetChemical(coupleInfo)
            nodeScript:SetCoupleState(self.coupleState)
            nodeScript:SetPos(itemData.pos, self.nowFormationId, 800, 400, 15, false, 1)
            nodeScript:BuildPage()
        end

        index = index + 1
    end
end
-- 构建替补球员
function FormationPageView:BuildBenchBox()
    local playerCardCircle = res.LoadRes(self.playerCardCirclePath)
    local loadedCount = self.benchContent.childCount
    local index = 0
    local replacePlayersList = self:SortReplacePlayersWithPos()

    for i, itemData in pairs(replacePlayersList) do
        local node = nil
        local nodeScript = nil
        local cardShowType = nil
        if itemData.pcId == nil or tonumber(itemData.pcId) == 0 then
            cardShowType = FormationConstants.CardShowType.EMPTY
        else
            cardShowType = self.nowCardShowType
        end        
        local coupleInfo = self:GetCoupleInfo(itemData.pcId)
        if index >= loadedCount then
            node = Object.Instantiate(playerCardCircle).transform
            nodeScript = node:GetComponent("CapsUnityLuaBehav")
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.REPLACE, self.formationCacheDataModel)
            nodeScript:SetChemical(coupleInfo)
            nodeScript:SetCoupleState(self.coupleState)
            node:SetParent(self.benchContent, false)
        else
            node = self.benchContent:GetChild(index)
            nodeScript = node:GetComponent("CapsUnityLuaBehav")
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.REPLACE, self.formationCacheDataModel)
            nodeScript:SetChemical(coupleInfo)
            nodeScript:SetCoupleState(self.coupleState)
            nodeScript:BuildPage()
        end

        index = index + 1
    end
end

-- 初始化候补滚动视图
function FormationPageView:InitCandidateScrollerView()
    self.candidateScrollerView:InitView(self.waitPlayersNoRepeatList, self.waitPlayersRepeatList, self.nowCardShowType, self, self.matchId)
end

-- 构建阵型名称
function FormationPageView:BuildFormationName()
    self.formationName.text = self.playerTeamsModel:GetFormationNameById(self.nowFormationId)
end

-- 设置阵容按钮组
function FormationPageView:SetTeamBtn()
    self.teamBtnText.text = lang.trans("formation_nowTeam", self.nowTeamId + 1)
end

function FormationPageView:BuildSortBtnText()
    if self.nowSortType == FormationConstants.SortType.QUALITY then
        self.sortBtnText.text = lang.trans("formation_sortOrderByQuality")
    elseif self.nowSortType == FormationConstants.SortType.GET_TIME then
        self.sortBtnText.text = lang.trans("formation_sortOrderByGetTime")
    elseif self.nowSortType == FormationConstants.SortType.NAME then
        self.sortBtnText.text = lang.trans("formation_sortOrderByName")
    elseif self.nowSortType == FormationConstants.SortType.POWER then
        self.sortBtnText.text = lang.trans("formation_sortOrderByPower")
    end
end

function FormationPageView:GetCoupleState()
    return self.coupleState
end

function FormationPageView:RefreshCurrentTeamData(teamId)
    self.nowTeamId = teamId
    self.nowFormationId = self.playerTeamsModel:GetFormationId(self.nowTeamId)
    self.formationCacheDataModel:InitCacheData()
end

-- 切换阵容
function FormationPageView:SwitchTeam(teamId)
    self.nowTeamId = teamId
    self.nowFormationId = self.playerTeamsModel:GetFormationId(self.nowTeamId)
    self.formationCacheDataModel:InitCacheData()
    self.formationCacheDataModel:BuildTeamLegendInfo()
    self:SetPlayersData()
    self:SetFormationData()
    self:BuildPage()
    self.candidateScrollerView:BuildPage()
end

-- 计算总战力
function FormationPageView:CalculateTotalPower()
    local totalPower = 0
    for pos, nodeScript in pairs(self.initPlayersScriptList) do
        totalPower = totalPower + nodeScript:GetPower()
    end
    self:UpdatePower(totalPower)
end

function FormationPageView:UpdatePower(totalPower)
    self.totalPower = math.floor(totalPower)
    if self.onShowPower then
        self.onShowPower(self.totalPower)
    end
end

-- 更新主场特性改变的战力
function FormationPageView:OnHomeCourtUpdate()
    local totalPower = 0
    for pos, nodeScript in pairs(self.initPlayersScriptList) do
        nodeScript:UpdateStartersHomeCourt()
        totalPower = totalPower + nodeScript:GetPower()
    end
    self:UpdatePower(totalPower)
end

-- 显示球员擅长的位置区域
function FormationPageView:ShowPlayerArea(posList)
    for _, letterPos in ipairs(posList) do
        local numberPosList = FormationConstants.PositionToNumber[letterPos]
        for _, numberPos in ipairs(numberPosList) do
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationArea.prefab")
            obj.transform:SetParent(self.areaGroup, false)
            local isPosExisted = Helper.IsPosExisted(tonumber(numberPos), self.nowFormationId)
            spt:SetPos(numberPos, self.nowFormationId, 800, 400, 15, true, 1, isPosExisted)
            if isPosExisted then
                self.initPlayersScriptList[numberPos]:ShowOrHideAddFlag(false)
                self.initPlayersScriptList[numberPos]:ShowOrHideSwapPlayerEffect(true)
            end
        end
    end
end

-- 隐藏球员擅长的位置区域
function FormationPageView:HidePlayerArea(posList)
    local count = self.areaGroup.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.areaGroup:GetChild(i).gameObject)
    end
    for pos, script in pairs(self.initPlayersScriptList) do
        script:ShowOrHideAddFlag(true)
        script:ShowOrHideSwapPlayerEffect(false)
    end
end

-- 接受发生onDrop事件的球员位置的数据
function FormationPageView:ReceiveDropPlayer(playerCardCircle, dataIndex, playerClassify)
    self.playerCardCircleOnDrop = playerCardCircle
    self.dataIndexOnDrop = dataIndex
    self.playerClassifyOnDrop = playerClassify
end

function FormationPageView:ReceiveEndDragPlayer(playerCardCircle, dataIndex, playerClassify, eventData)
    self.playerCardCircleOnEndDrag = playerCardCircle
    self.dataIndexOnEndDrag = dataIndex
    self.playerClassifyOnEndDrag = playerClassify

    if self.playerCardCircleOnDrop == self.playerCardCircleOnEndDrag then
        return
    end

    -- 如果拖拽到首发球员上（包括空位）
    if self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.INIT then
        -- 如果拖拽的是首发球员
        if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
            self:SwapSameClassify()
        -- 如果拖拽的是替补球员
        elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.REPLACE then
            self:SwapInitAndReplace()
            self:RefreshPlayerAllAttrsChange(self.playerCardCircleOnDrop, self.playerCardCircleOnEndDrag)
            -- 换人
            GuideManager.Show(self)
        -- 如果拖拽的是候补球员
        elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.WAIT then
            self:SwapInitReplaceAndWait()
            self:RefreshPlayerAllAttrsChange(self.playerCardCircleOnDrop, self.playerCardCircleOnEndDrag)
        end
    -- 如果拖拽到替补球员上（包括空位）
    elseif self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.REPLACE then
        -- 如果拖拽的是首发球员
        if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
            self:SwapInitAndReplace()
            self:RefreshPlayerAllAttrsChange(self.playerCardCircleOnEndDrag, self.playerCardCircleOnDrop)
        -- 如果拖拽的是替补球员
        elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.REPLACE then
            self:SwapSameClassify()
        -- 如果拖拽的是候补球员
        elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.WAIT then
            self:SwapInitReplaceAndWait()
        end
    -- 如果拖拽到候补球员上
    elseif self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.WAIT then
        if not GuideManager.GuideIsOnGoing("main") then
            -- 如果拖拽的是首发球员
            if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
                self:SwapInitReplaceAndWait()
                self:RefreshPlayerAllAttrsChange(self.playerCardCircleOnEndDrag, self.playerCardCircleOnDrop)
            -- 如果拖拽的是替补球员
            elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.REPLACE then
                self:SwapInitReplaceAndWait()
            end
        end
    else
        if not GuideManager.GuideIsOnGoing("main") then
            local isInCourtArea = RectTransformUtility.RectangleContainsScreenPoint(self.courtArea, eventData.position, eventData.pressEventCamera)
            if not isInCourtArea then
                local playerCardCircleOnDrop = nil
                if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
                    playerCardCircleOnDrop = PlayerCardCircle.new()
                    local pcIdOnEndDrag = self.playerCardCircleOnEndDrag:GetPcId()
                    local showTypeOnEndDrag = self.playerCardCircleOnEndDrag:GetShowType()
                    playerCardCircleOnDrop:initData(self.dataIndexOnDrop, pcIdOnEndDrag, showTypeOnEndDrag, self.playerClassifyOnDrop, self.formationCacheDataModel)
                end
                -- 如果拖拽的是首发球员或替补球员
                if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT or self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.REPLACE then
                    self:SwapInitReplaceAndEmpty()
                end
                if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
                    self:RefreshPlayerAllAttrsChange(self.playerCardCircleOnEndDrag, playerCardCircleOnDrop)
                end
            end
        end
    end

    self:ClearDragVariable()
    self:CalculateTotalPower()
end


-- 同类型球员交换：首发球员或者替补球员
function FormationPageView:SwapSameClassify()
    local pcIdOnDrop = self.playerCardCircleOnDrop:GetPcId()
    local pcIdOnEndDrag = self.playerCardCircleOnEndDrag:GetPcId()
    local showTypeOnDrop = self.playerCardCircleOnDrop:GetShowType()
    local showTypeOnEndDrag = self.playerCardCircleOnEndDrag:GetShowType()

    self.playerCardCircleOnDrop:initData(self.dataIndexOnDrop, pcIdOnEndDrag, showTypeOnEndDrag, self.playerClassifyOnDrop, self.formationCacheDataModel)
    self.playerCardCircleOnDrop:BuildPage()

    self.playerCardCircleOnEndDrag:initData(self.dataIndexOnEndDrag, pcIdOnDrop, showTypeOnDrop, self.playerClassifyOnEndDrag, self.formationCacheDataModel)
    self.playerCardCircleOnEndDrag:BuildPage()    
    -- 如果是首发球员
    if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
        self.initPlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
        self.initPlayersData[self.dataIndexOnEndDrag] = pcIdOnDrop
    -- 如果是替补球员
    else
        self.replacePlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
        self.replacePlayersData[self.dataIndexOnEndDrag] = pcIdOnDrop
    end
    self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
    self:SetChemicalMap()
    self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
    self:InitCandidateScrollerView()
    self.candidateScrollerView:BuildPage()
    self:BuildCount()
    self:BuildBenchBox()
end

-- 交换首发和替补球员
function FormationPageView:SwapInitAndReplace()
    if self:HasSamePlayer() then
        DialogManager.ShowToastByLang("formation_validType_hasSamePlayer")
        return
    end
    local pcIdOnDrop = self.playerCardCircleOnDrop:GetPcId()
    local pcIdOnEndDrag = self.playerCardCircleOnEndDrag:GetPcId()
    local showTypeOnDrop = self.playerCardCircleOnDrop:GetShowType()
    local showTypeOnEndDrag = self.playerCardCircleOnEndDrag:GetShowType()

    self.playerCardCircleOnDrop:initData(self.dataIndexOnDrop, pcIdOnEndDrag, showTypeOnEndDrag, self.playerClassifyOnDrop, self.formationCacheDataModel)
    self.playerCardCircleOnDrop:BuildPage()

    self.playerCardCircleOnEndDrag:initData(self.dataIndexOnEndDrag, pcIdOnDrop, showTypeOnDrop, self.playerClassifyOnEndDrag, self.formationCacheDataModel)
    self.playerCardCircleOnEndDrag:BuildPage()

    -- 如果拖拽的是替补球员
    if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.REPLACE then
        self.initPlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
        self.replacePlayersData[self.dataIndexOnEndDrag] = pcIdOnDrop
    -- 如果拖拽的是首发球员
    elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
        self.initPlayersData[self.dataIndexOnEndDrag] = pcIdOnDrop
        self.replacePlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
    end
    self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
    self:SetChemicalMap()
    self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
    self.formationCacheDataModel:BuildTeamLegendInfo()
    self:InitCandidateScrollerView()
    self.candidateScrollerView:BuildPage()
    self:BuildCount()
    self:BuildBenchBox()

end

-- 交换(首发/替补)和候补球员
function FormationPageView:SwapInitReplaceAndWait()
    if self:HasSamePlayer() then
        DialogManager.ShowToastByLang("formation_validType_hasSamePlayer")
        return
    end
    local pcIdOnDrop = self.playerCardCircleOnDrop:GetPcId()
    local pcIdOnEndDrag = self.playerCardCircleOnEndDrag:GetPcId()
    local showTypeOnDrop = self.playerCardCircleOnDrop:GetShowType()
    local showTypeOnEndDrag = self.playerCardCircleOnEndDrag:GetShowType()
    local powerOnDrop = self.playerCardCircleOnDrop:GetPower()
    local powerOnEndDrag = self.playerCardCircleOnEndDrag:GetPower()
    local dataIndexOnDrop = tonumber(self.dataIndexOnDrop)
    local dataIndexOnEndDrag = tonumber(self.dataIndexOnEndDrag)
    local removeWaitPlayer = false

    self.playerCardCircleOnDrop:initData(self.dataIndexOnDrop, pcIdOnEndDrag, showTypeOnEndDrag, self.playerClassifyOnDrop, self.formationCacheDataModel)
    self.playerCardCircleOnDrop:BuildPage()

    -- 如果拖拽到首发或替补阵容中的空位上
    if showTypeOnDrop == FormationConstants.CardShowType.EMPTY then
        self.candidateScrollerView:DeleteItem(dataIndexOnEndDrag)
        -- return
        -- self.playerCardCircleOnEndDrag:initData(self.dataIndexOnEndDrag, pcIdOnDrop, showTypeOnDrop, self.playerClassifyOnEndDrag, self.formationCacheDataModel)
    else
        self.playerCardCircleOnEndDrag:initData(self.dataIndexOnEndDrag, pcIdOnDrop, showTypeOnDrop, self.playerClassifyOnEndDrag, self.formationCacheDataModel)
        self.playerCardCircleOnEndDrag:BuildPage()
    end

    -- 如果拖拽的是候补球员
    if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.WAIT then
        -- 拖拽到首发球员
        if self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.INIT then
            self.initPlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
        -- 拖拽到替补球员
        elseif self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.REPLACE then
            self.replacePlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
        end

        -- 如果拖拽到首发或替补阵容中的球员上而不是空位上
        if showTypeOnDrop ~= FormationConstants.CardShowType.EMPTY then
            if dataIndexOnEndDrag <= #self.waitPlayersNoRepeatList then
                self.waitPlayersNoRepeatList[dataIndexOnEndDrag] = self.playerTeamsModel:GetCardModelWithPcid(pcIdOnDrop)
            else
                self.waitPlayersRepeatList[dataIndexOnEndDrag - #self.waitPlayersNoRepeatList] = self.playerTeamsModel:GetCardModelWithPcid(pcIdOnDrop)
            end
        else
            removeWaitPlayer = true
        end
    -- 如果拖拽的是首发球员或替补球员
    else
        -- 拖拽的是首发球员
        if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
            self.initPlayersData[self.dataIndexOnEndDrag] = pcIdOnDrop
        -- 拖拽的是替补球员
        elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.REPLACE then
            self.replacePlayersData[self.dataIndexOnEndDrag] = pcIdOnDrop
        end
                
        if dataIndexOnDrop <= #self.waitPlayersNoRepeatList then
            self.waitPlayersNoRepeatList[dataIndexOnDrop] = self.playerTeamsModel:GetCardModelWithPcid(pcIdOnEndDrag)
        else
            self.waitPlayersRepeatList[dataIndexOnDrop - #self.waitPlayersNoRepeatList] = self.playerTeamsModel:GetCardModelWithPcid(pcIdOnEndDrag)
        end
    end

    -- if not removeWaitPlayer then
    self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
    self:SetChemicalMap()
    self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
    self.formationCacheDataModel:BuildTeamLegendInfo()
    self:InitCandidateScrollerView()
    if showTypeOnDrop ~= FormationConstants.CardShowType.EMPTY then
        self.candidateScrollerView:BuildPage()
    end
    self:BuildCount()
    self:BuildBenchBox()
    -- end
end

-- 判断拖拽球员时是否首发和替补球员中有相同BaseId的球员
function FormationPageView:HasSamePlayer()
    local pcIdOnDrop = self.playerCardCircleOnDrop:GetPcId()
    local pcIdOnEndDrag = self.playerCardCircleOnEndDrag:GetPcId()
    local playerCardModelOnDrop = self.playerCardCircleOnDrop:GetModel()
    local playerCardModelOnEndDrag = self.playerCardCircleOnEndDrag:GetModel()
    local posOnDrop = self.playerCardCircleOnDrop:GetPos()
    local posOnEndDrag = self.playerCardCircleOnEndDrag:GetPos()
    local isInitOnDrop = self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.INIT
    local isReplaceOnDrop = self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.REPLACE

    local newInitPlayersData = {}
    local newReplacePlayersData = {}
    local baseIdsData = {}
    local cIdsData = {}

    for pos, pcid in pairs(self.initPlayersData) do
        if pcid == pcIdOnEndDrag then
            newInitPlayersData[pos] = pcIdOnDrop
        else
            newInitPlayersData[pos] = pcid
        end
    end

    for pos, pcid in pairs(self.replacePlayersData) do
        if pcid == pcIdOnEndDrag then
            newReplacePlayersData[pos] = pcIdOnDrop
        else
            newReplacePlayersData[pos] = pcid
        end
    end

    if isInitOnDrop then
        newInitPlayersData[posOnDrop] = pcIdOnEndDrag
    elseif isReplaceOnDrop then
        newReplacePlayersData[posOnDrop] = pcIdOnEndDrag
    end

    for pos, pcid in pairs(newInitPlayersData) do
        if pcid ~= 0 then
            local initPlayerCardModel = self.playerTeamsModel:GetCardModelWithPcid(pcid)
            local initBaseId = initPlayerCardModel:GetBaseID()
            local initCId = initPlayerCardModel:GetCid()

            if baseIdsData[initBaseId] then
                return true
            else
                baseIdsData[initBaseId] = true
            end

            if cIdsData[initCId] then
                return true
            else
                cIdsData[initCId] = true
            end
        end
    end

    for pos, pcid in pairs(newReplacePlayersData) do
        if pcid ~= 0 then
            local replacePlayerCardModel = self.playerTeamsModel:GetCardModelWithPcid(pcid)
            local replaceCId = replacePlayerCardModel:GetCid()

            if cIdsData[replaceCId] then
                return true
            else
                cIdsData[replaceCId] = true
            end
        end
    end

    return false
end

function FormationPageView:RemoveWaitPlayer()
    local dataIndexOnEndDrag = tonumber(self.dataIndexOnEndDrag)
    if dataIndexOnEndDrag <= #self.waitPlayersNoRepeatList then
        table.remove(self.waitPlayersNoRepeatList, dataIndexOnEndDrag)
    else
        table.remove(self.waitPlayersRepeatList, dataIndexOnEndDrag - #self.waitPlayersNoRepeatList)
    end
    local pcIdOnEndDrag = self.playerCardCircleOnEndDrag:GetPcId()
    -- 如果拖拽的是候补球员
    if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.WAIT then
        -- 拖拽到首发球员
        if self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.INIT then
            self.initPlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
        -- 拖拽到替补球员
        elseif self.playerClassifyOnDrop == FormationConstants.PlayersClassifyInFormation.REPLACE then
            self.replacePlayersData[self.dataIndexOnDrop] = pcIdOnEndDrag
        end
    end

    self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
    self:SetChemicalMap()
    self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
    self:InitCandidateScrollerView()
    --self.candidateScrollerView:BuildPage()
    self:BuildCount()
    self:BuildBenchBox()
end

-- 拖拽首发或替补球员到空地，首发或替补球员被置空
function FormationPageView:SwapInitReplaceAndEmpty()
    local pcIdOnEndDrag = self.playerCardCircleOnEndDrag:GetPcId()
    local showTypeOnEndDrag = self.playerCardCircleOnEndDrag:GetShowType()

    self.playerCardCircleOnEndDrag:initData(self.dataIndexOnEndDrag, 0, FormationConstants.CardShowType.EMPTY, self.playerClassifyOnEndDrag, self.formationCacheDataModel)
    self.playerCardCircleOnEndDrag:BuildPage()

    -- 拖拽的是首发球员
    if self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.INIT then
        self.initPlayersData[self.dataIndexOnEndDrag] = 0
    -- 拖拽的是替补球员
    elseif self.playerClassifyOnEndDrag == FormationConstants.PlayersClassifyInFormation.REPLACE then
        self.replacePlayersData[self.dataIndexOnEndDrag] = 0
    end

    self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
    self:SetChemicalMap()
    self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
    self.formationCacheDataModel:BuildTeamLegendInfo()
    self.waitPlayersNoRepeatList, self.waitPlayersRepeatList = self.formationCacheDataModel:GetWaitPlayerCacheData(self.nowSortType)
    self:InitCandidateScrollerView()
    self.candidateScrollerView:BuildPage()
    self:BuildCount()
    self:BuildBenchBox()
end

-- 清空拖拽中使用的变量
function FormationPageView:ClearDragVariable()
    self.playerCardCircleOnDrop = nil
    self.dataIndexOnDrop = nil
    self.playerClassifyOnDrop = nil
    self.playerCardCircleOnEndDrag = nil
    self.dataIndexOnEndDrag = nil
    self.playerClassifyOnEndDrag = nil
end

function FormationPageView:SetChangePlayerAttrsBarState(isShow)
    GameObjectHelper.FastSetActive(self.changePlayerAttrsBar, isShow)
end

function FormationPageView:RefreshPlayerAllAttrsChange(comePlayerCircleCard, leavePlayerCircleCard)
    --[[暂时屏蔽此功能
    self:SetChangePlayerAttrsBarState(true)
    if tonumber(comePlayerCircleCard:GetDataIndex()) == self.numberPosWithGk then
        self.playerAttr1Title.text = lang.trans("goalkeeping")
        self.playerAttr2Title.text = lang.trans("launching")
        self.playerAttr3Title.text = lang.trans("composure")
        self.playerAttr4Title.text = lang.trans("commanding")
        self.playerAttr5Title.text = lang.trans("anticipation")
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "goalkeeping", self.playerAttr1)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "launching", self.playerAttr2)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "composure", self.playerAttr3)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "commanding", self.playerAttr4)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "anticipation", self.playerAttr5)
    else
        self.playerAttr1Title.text = lang.trans("shoot")
        self.playerAttr2Title.text = lang.trans("pass")
        self.playerAttr3Title.text = lang.trans("dribble")
        self.playerAttr4Title.text = lang.trans("intercept")
        self.playerAttr5Title.text = lang.trans("steal")
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "shoot", self.playerAttr1)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "pass", self.playerAttr2)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "dribble", self.playerAttr3)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "intercept", self.playerAttr4)
        self:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, "steal", self.playerAttr5)
    end

    DOTween.Kill("playerAttrsSequence")
    local playerAttrsSequence = DOTween.Sequence()
    TweenSettingsExtensions.SetId(playerAttrsSequence, "playerAttrsSequence")
    TweenSettingsExtensions.AppendInterval(playerAttrsSequence, self.playerAttrsShowTime)
    TweenSettingsExtensions.AppendCallback(playerAttrsSequence, function ()
        self:SetChangePlayerAttrsBarState(false)
    end)]]
end

function FormationPageView:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, attrIndex, attrTable)
    local baseNum, plusNum = comePlayerCircleCard:GetAbility(attrIndex)
    local comeAttr = baseNum + plusNum

    baseNum, plusNum = leavePlayerCircleCard:GetAbility(attrIndex)
    local leaveAttr = baseNum + plusNum

    local changeAttr = comeAttr - leaveAttr
    if changeAttr > 0 then
        GameObjectHelper.FastSetActive(attrTable.add, true)
        GameObjectHelper.FastSetActive(attrTable.reduce, false)
        GameObjectHelper.FastSetActive(attrTable.equal, false)
        attrTable.addText.text = "+" .. changeAttr
    elseif changeAttr < 0 then
        GameObjectHelper.FastSetActive(attrTable.add, false)
        GameObjectHelper.FastSetActive(attrTable.reduce, true)
        GameObjectHelper.FastSetActive(attrTable.equal, false)
        attrTable.reduceText.text = "-" .. math.abs(changeAttr)
    else
        GameObjectHelper.FastSetActive(attrTable.add, false)
        GameObjectHelper.FastSetActive(attrTable.reduce, false)
        GameObjectHelper.FastSetActive(attrTable.equal, true)
        attrTable.equalText.text = "0"
    end
end

-- 检测上场阵容是否改变
function FormationPageView:CheckTeamChanged()

    -- 判断阵型Id是否已修改
    if self.formationCacheDataModel:CheckFormationIdChanged() then
        return true
    end
    
    -- 判断首发球员是否已修改
    if self.formationCacheDataModel:CheckInitPlayersChanged() then
        return true
    end

    -- 判断替补球员是否已修改
    if self.formationCacheDataModel:CheckReplacePlayersChanged() then
        return true
    end

    -- 判断关键球员是否已修改
    if self.formationCacheDataModel:CheckKeyPlayersChanged() then
        return true
    end

    -- 判断战术是否已修改
    if self.formationCacheDataModel:CheckTacticsChanged() then
        return true
    end

    -- 判断默认阵容是否已修改
    if self.formationCacheDataModel:CheckNowTeamIdChanged() then
        return true
    end

    return false
end

-- 检测阵容是否符合条件，即有11位上场球员
function FormationPageView:CheckTeamValid()
    local index = 0
    local hasSamePlayer = false

    for pos, pcId in pairs(self.initPlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            index = index + 1
        end
    end

    if index ~= 11 then
        return FormationConstants.FormationValidType.NOVALID_INITPLAYERS_NOTENOUGH
    end

    local playersData = {}
    for pos, pcId in pairs(self.initPlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            local baseID = self.playerTeamsModel:GetCardModelWithPcid(pcId):GetBaseID()
            if playersData[baseID] == nil then
                playersData[baseID] = 1
            else
                hasSamePlayer = true
                break
            end
        end
    end

    if hasSamePlayer then
        return FormationConstants.FormationValidType.NOVALID_HASSAMEPLAYER
    end

    local replacePlayersData = {}
    for pos, pcId in pairs(self.replacePlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            replacePlayersData[pos] = pcId
            local cid = self.playerTeamsModel:GetCardModelWithPcid(pcId):GetCid()
            if replacePlayersData[cid] == nil then
                replacePlayersData[cid] = 1
            else
                hasSamePlayer = true
                break
            end
        end
    end

    if hasSamePlayer then
        return FormationConstants.FormationValidType.NOVALID_HASSAMEPLAYER
    end

    return FormationConstants.FormationValidType.VALID
end

-- 询问是否保存阵容
function FormationPageView:AskSaveTeamOrNot(callback)
    -- 如果阵容已修改
    if self:CheckTeamChanged() then
        DialogManager.ShowConfirmPopByLang("formation_saveFormation", "formation_useTeamOrNot", function ()
            -- 阵容是否合法
            local validType = self:CheckTeamValid()
            if validType == FormationConstants.FormationValidType.VALID then
                self:SaveTeamData(function ()
                    if type(callback) == "function" then
                        callback()
                    end
                end)
            elseif validType == FormationConstants.FormationValidType.NOVALID_INITPLAYERS_NOTENOUGH then
                DialogManager.ShowToastByLang("formation_validType_initPlayers_notEnough")
            elseif validType == FormationConstants.FormationValidType.NOVALID_HASSAMEPLAYER then
                DialogManager.ShowToastByLang("formation_validType_hasSamePlayer")
            end
        end, function ()
            self:ResetTeamDataSelectedType()
            if type(callback) == "function" then
                callback()
            end
        end, nil, DialogManager.DialogType.GeneralBox)
    else
        self:ResetTeamDataSelectedType()
        if type(callback) == "function" then
            callback()
        end
    end
end

function FormationPageView:ResetCardsLock(data)
    local locks = data.lock or {}
    local playerCardsMapModel = require("ui.models.PlayerCardsMapModel").new()
    for pcid, lock in pairs(locks) do
        playerCardsMapModel:ResetCardLock(pcid, lock)
    end
end

-- 保存阵容数据
function FormationPageView:SaveTeamData(onComplete)
    local replacePlayersData = {}
    for pos, pcId in pairs(self.replacePlayersData) do
        if tonumber(pcId) ~= 0 then
            replacePlayersData[pos] = pcId
        end
    end

    self:coroutine(function()
        if self.formationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(self.initPlayersData) then
            self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
            self.formationCacheDataModel:SetKeyPlayersDefaultData()
        end
        local keyPlayersData = self.formationCacheDataModel:GetKeyPlayersCacheData()
        keyPlayersData = self.playerTeamsModel:FixKeyPlayersData(keyPlayersData, self.initPlayersData)
        local tacticsData = self.formationCacheDataModel:GetTacticsCacheData()
        local teamType = self.playerTeamsModel:GetTeamType()
        local resp = req.saveTeam(self.nowTeamId, self.nowFormationId, self.initPlayersData, replacePlayersData, teamType, keyPlayersData, tacticsData, self.selectedType)
        if api.success(resp) then
            self:UpdateTeamData(resp.val)
            if type(onComplete) == "function" then
                onComplete()
            end
            -- 保存阵型
            GuideManager.Show(self)
        end
    end)
end

function FormationPageView:UpdateTeamData(data)
    self.playerTeamsModel:SetFormationId(self.nowTeamId, self.nowFormationId)
    self.playerTeamsModel:SetInitPlayersData(self.nowTeamId, self.initPlayersData)
    self.playerTeamsModel:SetReplacePlayersData(self.nowTeamId, self.replacePlayersData)
    self.playerTeamsModel:SetSelectedType(self.selectedType)
    self.savedSelectedType = self.selectedType
    self.playerTeamsModel:SetNowTeamKeyPlayersData(self.formationCacheDataModel:GetKeyPlayersCacheData())
    self.playerTeamsModel:SetNowTeamTacticsData(self.formationCacheDataModel:GetTacticsCacheData())
    self.playerTeamsModel:SetNowTeamId(self.formationCacheDataModel:GetInitCurrTeamId())
    self:SetTeamBtn()
    self:ResetCardsLock(data)
end

-- 阵型修改&不保存时重置selectedType
function FormationPageView:ResetTeamDataSelectedType()
    self.playerTeamsModel:SetSelectedType(self.savedSelectedType)
end

-- 收缩候补区域框
function FormationPageView:ShrinkCandidateBox()
    local shrinkTweener = ShortcutExtensions.DOSizeDelta(self.candidateBox, Vector2(70, self.candidateBox.sizeDelta.y), 0.4)
    TweenSettingsExtensions.SetEase(shrinkTweener, Ease.OutCubic)
    TweenSettingsExtensions.OnComplete(shrinkTweener, function ()
        self:ShrinkCandidateBoxCallback()
    end)

    local btnGroupTweener = ShortcutExtensions.DOAnchorPosX(self.rightBtnGroup, self.isExpandCandidateBox and 0 or self.rightBtnGroup.sizeDelta.x, 0.4)
    TweenSettingsExtensions.SetEase(btnGroupTweener, Ease.OutCubic)

    local courtBoxTweener = ShortcutExtensions.DOAnchorPosX(self.courtBox, self.isExpandCandidateBox and 0 or 164, 0.4)
    TweenSettingsExtensions.SetEase(courtBoxTweener, Ease.OutCubic)

    local benchBoxTweener = ShortcutExtensions.DOAnchorPosX(self.benchBox, self.isExpandCandidateBox and 0 or 164, 0.4)
    TweenSettingsExtensions.SetEase(benchBoxTweener, Ease.OutCubic)
end

-- 收缩候补区域框回调
function FormationPageView:ShrinkCandidateBoxCallback()
    local endValue = 0

    -- 候补区域初始为收缩状态
    if self.isExpandCandidateBox == false then
        endValue = 348
        self.candidateScrollerView:ResetWidth(280)
        self:SetCandidateSwitchBtnStatus(true)
        self:SetCandidateBoardMaterial(true)
    -- 候补区域初始为扩展状态
    else
        endValue = 184
        self.candidateScrollerView:ResetWidth(100)
        self:SetCandidateSwitchBtnStatus(false)
        self:SetCandidateBoardMaterial(false)
    end

    self.candidateScrollerView:BuildPage()
    self:ExpandCandidateBox(endValue)
end

-- 扩展候补区域
function FormationPageView:ExpandCandidateBox(endValue)
    local expandTweener = ShortcutExtensions.DOSizeDelta(self.candidateBox, Vector2(endValue, self.candidateBox.sizeDelta.y), 0.4)
    TweenSettingsExtensions.OnComplete(expandTweener, function ()
        self:ExpandCandidateBoxCallback()
    end)
end

-- 设置候补区域切换按钮
function FormationPageView:SetCandidateSwitchBtnStatus(isExpand)
    local trans = self.candidateSwitchBtn.transform
    local expandIcon = trans:Find("ExpandIcon")
    local shrinkIcon = trans:Find("ShrinkIcon")
    GameObjectHelper.FastSetActive(expandIcon.gameObject, not isExpand)
    GameObjectHelper.FastSetActive(shrinkIcon.gameObject, isExpand)
end

-- 扩展候补区域框回调
function FormationPageView:ExpandCandidateBoxCallback()
    self.isExpandCandidateBox = not self.isExpandCandidateBox
end

function FormationPageView:SetCandidateBoardMaterial(isExpand)
    GameObjectHelper.FastSetActive(self.candidateBoardMaterial1, not isExpand)
    GameObjectHelper.FastSetActive(self.candidateBoardMaterial2, isExpand)
end

-- 更换阵型
function FormationPageView:ChangeFormation(formationId)
    self.nowFormationId = formationId
    self.formationCacheDataModel:SetFormationIdCacheData(self.nowFormationId)
    self.initPlayersData = self.playerTeamsModel:ChangeFormation(self.nowFormationId, self.initPlayersData)
    self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
    self.formationCacheDataModel:BuildTeamLegendInfo()
    self:BuildPage()
end

function FormationPageView:ChangeFormationSelectedType(selectedType)
    self.selectedType = selectedType
    self.playerTeamsModel:SetSelectedType(self.selectedType)
end

-- 数字补间动画
function FormationPageView:PlayNumTweenAnim(textComp, oldNum, newNum)
    if oldNum == newNum then
        return
    end
    if newNum == nil then
        return
    end
    if oldNum == nil then
        textComp.text = tostring(newNum)
        return
    end
    textComp.text = tostring(oldNum)
    local textTrans = textComp.transform
    local unitNum = math.floor((newNum - oldNum) / 10)
    local mySequence = DOTween.Sequence()
    local scaleInTweener = ShortcutExtensions.DOScale(textTrans, Vector3(1.2, 1.2, 1), 0.2)
    TweenSettingsExtensions.Append(mySequence, scaleInTweener)
    for i = 1, 10 do
        local nowNum = oldNum + i * unitNum
        if i == 10 then
            nowNum = newNum
        end
        TweenSettingsExtensions.AppendInterval(mySequence, 0.1)
        TweenSettingsExtensions.AppendCallback(mySequence, function ()
            textComp.text = tostring(nowNum)
        end)
    end
    local scaleOutTweener = ShortcutExtensions.DOScale(textTrans, Vector3.one, 0.2)
    TweenSettingsExtensions.Append(mySequence, scaleOutTweener)
end

function FormationPageView:ShowCardDetail(pcId, playerCardCircle)
    if self.onCardClick then
        local cardList = {}
        local index = 0
        local tempIndex = 0
        local playerClassify = self:CheckPlayerClassify(pcId)
        if playerClassify == FormationConstants.PlayersClassifyInFormation.INIT then
            local sortInitPlayersData = self:SortInitPlayersWithPos()
            for _, playerData in pairs(sortInitPlayersData) do
                if playerData.pcId ~= nil and playerData.pcId ~= 0 then
                    table.insert(cardList, playerData.pcId)
                    tempIndex = tempIndex + 1
                    if playerData.pcId == pcId then
                        index = tempIndex
                    end
                end
            end
        elseif playerClassify == FormationConstants.PlayersClassifyInFormation.REPLACE then
            local sortReplacePlayersData = self:SortReplacePlayersWithPos()
            for _, playerData in pairs(sortReplacePlayersData) do
                if playerData.pcId ~= nil and playerData.pcId ~= 0 then
                    table.insert(cardList, playerData.pcId)
                    tempIndex = tempIndex + 1
                    if playerData.pcId == pcId then
                        index = tempIndex
                    end
                end
            end
        elseif playerClassify == FormationConstants.PlayersClassifyInFormation.WAIT then
            for _, playerCardModel in pairs(self.waitPlayersNoRepeatList) do
                local waitPcid = playerCardModel:GetPcid()
                table.insert(cardList, waitPcid)
                tempIndex = tempIndex + 1
                if waitPcid == pcId then
                    index = tempIndex
                end
            end
            for _, playerCardModel in pairs(self.waitPlayersRepeatList) do
                local waitPcid = playerCardModel:GetPcid()
                table.insert(cardList, waitPcid)
                tempIndex = tempIndex + 1
                if waitPcid == pcId then
                    index = tempIndex
                end
            end
        end

        self.onCardClick(cardList, index, self.nowTeamId)
    end
end

function FormationPageView:CheckPlayerClassify(pcId)
    assert(pcId ~= nil and pcId ~= 0)
    for _, initPcId in pairs(self.initPlayersData) do
        if initPcId == pcId then
            return FormationConstants.PlayersClassifyInFormation.INIT
        end
    end
    for _, replacePcId in pairs(self.replacePlayersData) do
        if replacePcId == pcId then
            return FormationConstants.PlayersClassifyInFormation.REPLACE
        end
    end
    for _, playerCardModel in pairs(self.waitPlayersNoRepeatList) do
        local waitPcid = playerCardModel:GetPcid()
        if waitPcid == pcId then
            return FormationConstants.PlayersClassifyInFormation.WAIT
        end
    end
    for _, playerCardModel in pairs(self.waitPlayersRepeatList) do
        local waitPcid = playerCardModel:GetPcid()
        if waitPcid == pcId then
            return FormationConstants.PlayersClassifyInFormation.WAIT
        end
    end
end

function FormationPageView:SortInitPlayersWithPos()
    local initPlayersList = {}

    for pos, pcId in pairs(self.initPlayersData) do
        table.insert(initPlayersList, {pos = pos, pcId = pcId})
    end
    table.sort(initPlayersList, function (a, b)
        return tonumber(a.pos) < tonumber(b.pos)
    end)

    return initPlayersList
end

function FormationPageView:SortReplacePlayersWithPos()
    local replacePlayersList = {}

    for pos, pcId in pairs(self.replacePlayersData) do
        table.insert(replacePlayersList, {pos = pos, pcId = pcId})
    end
    table.sort(replacePlayersList, function (a, b)
        return tonumber(a.pos) < tonumber(b.pos)
    end)

    return replacePlayersList
end

function FormationPageView:FormationDataChange(formationDataChanged)
    GameObjectHelper.FastSetActive(self.saveEnableBtn, formationDataChanged)
    GameObjectHelper.FastSetActive(self.saveDisableBtn, not formationDataChanged)
end

-- 筛选候补球员
function FormationPageView:OnFilterConfirm(filterPosData)
    if table.nums(filterPosData) == 0 then
        self.formationCacheDataModel:SetWaitPlayerFilterPosData()
    else
        self.formationCacheDataModel:SetWaitPlayerFilterPosData(filterPosData)
    end
    self.waitPlayersNoRepeatList, self.waitPlayersRepeatList = self.formationCacheDataModel:GetWaitPlayerCacheData(self.nowSortType)
    self:InitCandidateScrollerView()
    self.candidateScrollerView:BuildPage()
end

function FormationPageView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function FormationPageView:OnBack()
    self:AskSaveTeamOrNot(function ()
        self:coroutine(function ()
            unity.waitForNextEndOfFrame()
            self:PlayLeaveAnimation()
        end)
        self.formationCacheDataModel:InitCacheData()
        self.cardResourceCache:Clear()
        --DOTween.Kill("playerAttrsSequence")
    end)
end

function FormationPageView:onDestroy()
    self.cardResourceCache:Clear()
end

function FormationPageView:RegOnAccess(func)
    self.onAccessCallBack = func
end

function FormationPageView:OnAccess()
    if type(self.onAccessCallBack) == "function" then
        self.onAccessCallBack()
    end
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem.enabled = true
    end
end

function FormationPageView:OnLeave()
    clr.coroutine(function ()
        coroutine.yield(WaitForSeconds(0.05))
        res.PopSceneImmediate()
        -- 关闭阵型页面
        GuideManager.Show(res.curSceneInfo.ctrl)
    end)
end

function FormationPageView:PlayAccessAnimation()
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem = EventSystems.EventSystem.current
        self.currentEventSystem.enabled = false
    end
    self.animator:Play("EffectFormationPage")
    self.animatorStateIsLeave = false
end

function FormationPageView:PlayLeaveAnimation()
    self.animator:Play("EffectFormationPageLeave")
    self.animatorStateIsLeave = true
end

function FormationPageView:RefreshCoachInfo()
    local playerInfoModel = PlayerInfoModel.new()
    local level = playerInfoModel:GetLevel()
    local coachOpenLevel = LevelLimit.Coach.playerLevel
    local coachOpenState = coachOpenLevel <= level
    GameObjectHelper.FastSetActive(self.coachEntryGo, coachOpenState)
    if coachOpenState then
        local coachMainModel = CoachMainModel.new()
        local credentialLevel = coachMainModel:GetCredentialLevel()
        local starLevel = coachMainModel:GetStarLevel()
        if not self.coachInfoSpt then
            local coachInfoObj, coachInfoSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachEntry.prefab")
            coachInfoObj.transform:SetParent(self.coachEntryTrans, false)
            self.coachInfoSpt = coachInfoSpt
        end
        self.coachInfoSpt:InitView(credentialLevel, starLevel)
    end
end

function FormationPageView:RefreshMySceneInfo()
    local playerInfoModel = PlayerInfoModel.new()
    local level = playerInfoModel:GetLevel()
    local coachOpenLevel = LevelLimit.Coach.playerLevel
    local coachOpenState = coachOpenLevel <= level
    local mySceneOpenState = false
    if coachOpenState then
        mySceneOpenState = CoachMainPageConfig.GetOpenStateByTag("CoachGuide")
    end
    GameObjectHelper.FastSetActive(self.mySceneGo, mySceneOpenState)
    if mySceneOpenState then
        if not self.mySceneSpt then
            local Obj, Spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/MyScene/MySceneEnterView.prefab")
            Obj.transform:SetParent(self.mySceneTrans, false)
            self.mySceneSpt = Spt
        end
        self.mySceneSpt:InitView(2)
    end
end

function FormationPageView:OnBtnCoachClick()
    res.PushScene("ui.controllers.coach.coachMainPage.CoachMainPageCtrl")
end

return FormationPageView