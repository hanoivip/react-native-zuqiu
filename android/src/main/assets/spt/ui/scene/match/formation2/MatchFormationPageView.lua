local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Color = UnityEngine.Color
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local RectTransformUtility = UnityEngine.RectTransformUtility
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local EmulatorInput = clr.EmulatorInput
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

local EventSystem = require("EventSystem")
local Helper = require("ui.scene.formation.Helper")
local Formation = require("data.Formation")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local MatchFormationPageView = class(unity.base)

function MatchFormationPageView:ctor()
    -- 返回按钮
    self.backBtn = self.___ex.backBtn
    -- 战力文本区域
    self.powerNumArea = self.___ex.powerNumArea
    -- 阵型按钮
    self.formationBtn = self.___ex.formationBtn
    -- 切换球员显示信息按钮
    self.switchInfoBtn = self.___ex.switchInfoBtn
    -- 保存并使用按钮
    self.saveBtn = self.___ex.saveBtn
    -- 关键球员按钮
    self.keyPlayerBtn = self.___ex.keyPlayerBtn
    -- 球员擅长位置组
    self.areaGroup = self.___ex.areaGroup
    -- 首发球员组
    self.initPlayerGroup = self.___ex.initPlayerGroup
    -- 替补球员框
    self.benchContent = self.___ex.benchContent
    -- 已使用换人名额文本
    self.alreadyChange = self.___ex.alreadyChange
    -- 可用换人名额文本
    self.availableChange = self.___ex.availableChange
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
    self.powerNum = self.___ex.powerNum
    -- 首发的矩形区域
    self.courtArea = self.___ex.courtArea
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
    -- 总战力
    self.totalPower = nil
    -- 当前卡牌显示类型
    self.nowCardShowType = 0
    -- 拖拽相关
    self.playerCardCircleOnDrop = nil
    self.dataIndexOnDrop = nil
    self.playerClassifyOnDrop = nil
    self.playerCardCircleOnEndDrag = nil
    self.dataIndexOnEndDrag = nil
    self.playerClassifyOnEndDrag = nil
    -- 首发球员脚本列表
    self.initPlayersScriptList = nil
    -- 比赛信息model
    self.matchInfoModel = nil
    -- 被替换下的球员数据
    self.substitutedPlayersData = nil
    -- 正在替换的球员数据
    self.substitutingPlayersData = nil
    -- 临时缓存数据Model
    self.formationCacheDataModel = nil
    -- 换人时五维属性变化显示时间
    self.playerAttrsShowTime = 3
    -- 门将位置
    self.numberPosWithGk = 26

    self.cardResourceCache = CardResourceCache.new()
end

function MatchFormationPageView:InitView(playerTeamsModel, formationCacheDataModel)
    self.playerTeamsModel = playerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel
    self.nowTeamId = self.playerTeamsModel:GetNowTeamId()
    self.nowCardShowType = FormationConstants.CardShowType.MAIN_INFO
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.substitutedPlayersData = self.matchInfoModel:GetSubstitutedPlayersData()
    self.substitutingPlayersData = {}

    self:SetPlayersData()
    self:SetFormationData()
    
    self:BuildPage()
end

function MatchFormationPageView:SetPlayersData()
    self.initPlayersData = self.playerTeamsModel:GetInitPlayersData(self.nowTeamId)
    self.replacePlayersData = self.playerTeamsModel:GetReplacePlayersData(self.nowTeamId)
end

function MatchFormationPageView:SetFormationData()
    self.nowFormationId = self.formationCacheDataModel:GetFormationIdCacheData()
end

function MatchFormationPageView:start()
    self:BindAll()
    self:RegisterEvent()
end

function MatchFormationPageView:BuildPage()
    self:BuildCount()
    self:BuildBenchBox()
    self:CalculateTotalPower()
    self:BuildFormationName()
    self:BuildTopTipText()
    --self:SetChangePlayerAttrsBarState(false)
end

-- 为所有的按钮绑定事件
function MatchFormationPageView:BindAll()
    -- 返回按钮
    self.backBtn:regOnButtonClick(function ()
        self:AskSaveTeamOrNot(function ()
            self:Destroy()
        end)
    end)

    -- 选择阵型按钮
    self.formationBtn:regOnButtonClick(function ()
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationSelect.prefab", "overlay", true, true)
        dialogcomp.contentcomp:InitView(self.playerTeamsModel, self.nowFormationId)
    end)

    -- 切换球员显示信息按钮
    self.switchInfoBtn:regOnButtonClick(function ()
        if self.nowCardShowType == FormationConstants.CardShowType.MAIN_INFO then
            self.nowCardShowType = FormationConstants.CardShowType.LEVEL_INFO
        else
            self.nowCardShowType = FormationConstants.CardShowType.MAIN_INFO
        end
        self:BuildPage()
    end)

    -- 保存并使用按钮
    self.saveBtn:regOnButtonClick(function ()
        -- 如果阵容已修改
        if self:CheckTeamChanged() then
            -- 阵容是否合法
            local validType = self:CheckTeamValid()
            if validType == FormationConstants.FormationValidType.VALID then
                self:SaveTeamData(function ()
                    DialogManager.ShowToastByLang("formation_saveSuccess")
                    self:FormationDataChange(false)
                end)
            elseif validType == FormationConstants.FormationValidType.NOVALID_INITPLAYERS_NOTENOUGH then
                DialogManager.ShowToastByLang("formation_validType_initPlayers_notEnough")
            elseif validType == FormationConstants.FormationValidType.NOVALID_EXTRA_SUBSTITUTION_SUM then
                DialogManager.ShowToastByLang("formation_validType_extra_substitution_sum")
            end
        else
            DialogManager.ShowToastByLang("formation_noNeedSave")
        end
    end)

    -- 关键球员按钮
    self.keyPlayerBtn:regOnButtonClick(function()
        local dialog, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Scene/Formation/FormationKeyPlayer.prefab', 'overlay', true, true)
        if self.formationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(self.initPlayersData) then
            self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
            self.formationCacheDataModel:SetKeyPlayersDefaultData()
        end
        dialogcomp.contentcomp:InitView(self.playerTeamsModel, self.formationCacheDataModel)
    end)
end

-- 注册事件
function MatchFormationPageView:RegisterEvent()
    EventSystem.AddEvent("FormationPageView.ShowPlayerArea", self, self.ShowPlayerArea)
    EventSystem.AddEvent("FormationPageView.HidePlayerArea", self, self.HidePlayerArea)
    EventSystem.AddEvent("FormationPageView.ReceiveDropPlayer", self, self.ReceiveDropPlayer)
    EventSystem.AddEvent("FormationPageView.ReceiveEndDragPlayer", self, self.ReceiveEndDragPlayer)
    EventSystem.AddEvent("FormationPageView.ChangeFormation", self, self.ChangeFormation)
    EventSystem.AddEvent("FormationPageView.Destroy", self, self.Destroy)
    EventSystem.AddEvent("MatchFormationDataChange", self, self.FormationDataChange)
end

-- 移除事件
function MatchFormationPageView:UnRegisterEvent()
    EventSystem.RemoveEvent("FormationPageView.ShowPlayerArea", self, self.ShowPlayerArea)
    EventSystem.RemoveEvent("FormationPageView.HidePlayerArea", self, self.HidePlayerArea)
    EventSystem.RemoveEvent("FormationPageView.ReceiveDropPlayer", self, self.ReceiveDropPlayer)
    EventSystem.RemoveEvent("FormationPageView.ReceiveEndDragPlayer", self, self.ReceiveEndDragPlayer)
    EventSystem.RemoveEvent("FormationPageView.ChangeFormation", self, self.ChangeFormation)
    EventSystem.RemoveEvent("FormationPageView.Destroy", self, self.Destroy)
    EventSystem.RemoveEvent("MatchFormationDataChange", self, self.FormationDataChange)
end

-- 构建球场上的球员
function MatchFormationPageView:BuildCount()
    local playerCardCircle = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab")

    local index = 0
    local childLoadedCount = self.initPlayerGroup.childCount
    self.initPlayersScriptList = {}

    local initPlayersList = self:SortInitPlayersWithPos()

    for i, itemData in pairs(initPlayersList) do
        local node = nil
        local nodeScript = nil
        local cardShowType = nil
        local isSubstituted = self.matchInfoModel:IsSubstitutedPlayer(itemData.pcId)

        if itemData.pcId == nil or tonumber(itemData.pcId) == 0 then
            cardShowType = FormationConstants.CardShowType.EMPTY
        else
            cardShowType = self.nowCardShowType
        end

        if index >= childLoadedCount then
            node = Object.Instantiate(playerCardCircle).transform
            nodeScript = node:GetComponent(CapsUnityLuaBehav)
            node:SetParent(self.initPlayerGroup, false)
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.INIT, self.formationCacheDataModel, isSubstituted)
            nodeScript:SetPos(itemData.pos, self.nowFormationId, 800, 400, 15, false, 1)
        else
            node = self.initPlayerGroup:GetChild(index)
            nodeScript = node:GetComponent(CapsUnityLuaBehav)
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.INIT, self.formationCacheDataModel, isSubstituted)
            nodeScript:BuildPage()
            nodeScript:SetPos(itemData.pos, self.nowFormationId, 800, 400, 15, false, 1)
        end

        self.initPlayersScriptList[itemData.pos] = nodeScript
        index = index + 1
    end
end

-- 构建替补球员
function MatchFormationPageView:BuildBenchBox()
    local playerCardCircle = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab")
    local loadedCount = self.benchContent.childCount
    local index = 0
    local replacePlayersList = self:SortReplacePlayersWithPos()

    for i, itemData in pairs(replacePlayersList) do
        local node = nil
        local nodeScript = nil
        local cardShowType = nil
        local isSubstituted = self.matchInfoModel:IsSubstitutedPlayer(itemData.pcId)

        if itemData.pcId == nil or tonumber(itemData.pcId) == 0 then
            cardShowType = FormationConstants.CardShowType.EMPTY
        else
            cardShowType = self.nowCardShowType
        end

        if index < loadedCount then
            node = self.benchContent:GetChild(index)
        end

        if node == nil then
            node = Object.Instantiate(playerCardCircle).transform
            nodeScript = node:GetComponent(CapsUnityLuaBehav)
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.REPLACE, self.formationCacheDataModel, isSubstituted)
            node:SetParent(self.benchContent, false)
        else
            nodeScript = node:GetComponent(CapsUnityLuaBehav)
            nodeScript:SetCardResCache(self.cardResourceCache)
            nodeScript:initData(itemData.pos, itemData.pcId, cardShowType, FormationConstants.PlayersClassifyInFormation.REPLACE, self.formationCacheDataModel, isSubstituted)
            nodeScript:BuildPage()
        end

        index = index + 1
    end
end

-- 构建阵型名称
function MatchFormationPageView:BuildFormationName()
    self.formationName.text = Formation[tostring(self.nowFormationId)].name
end

-- 计算总战力
function MatchFormationPageView:CalculateTotalPower()
    self.totalPower = 0
    for pos, nodeScript in pairs(self.initPlayersScriptList) do
        self.totalPower = self.totalPower + nodeScript:GetPower()
    end
    self.totalPower = math.floor(self.totalPower)
    self.powerNum.text = tostring(self.totalPower)
end

-- 显示球员擅长的位置区域
function MatchFormationPageView:ShowPlayerArea(posList)
    for _, letterPos in ipairs(posList) do
        local numberPosList = FormationConstants.PositionToNumber[letterPos]
        for _, numberPos in ipairs(numberPosList) do
            local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Formation/FormationArea.prefab")
            obj.transform:SetParent(self.areaGroup, false)
            local isPosExisted = Helper.IsPosExisted(tonumber(numberPos), self.nowFormationId)
            -- spt:SetPos(numberPos, self.nowFormationId, 800, 400, 15, true, 1.1, isPosExisted)
            if isPosExisted then
                self.initPlayersScriptList[numberPos]:ShowOrHideAddFlag(false)
                self.initPlayersScriptList[numberPos]:ShowOrHideSwapPlayerEffect(true)
            end
        end
    end
end

-- 隐藏球员擅长的位置区域
function MatchFormationPageView:HidePlayerArea(posList)
    local count = self.areaGroup.childCount
    for i = 0, count - 1 do
        Object.Destroy(self.areaGroup:GetChild(i).gameObject)
    end
    for pos, script in pairs(self.initPlayersScriptList) do
        script:ShowOrHideAddFlag(true)
        script:ShowOrHideSwapPlayerEffect(false)
    end
end

-- 构建顶部提示文本
function MatchFormationPageView:BuildTopTipText()
    local totalSubstitutedPlayersNum = #self.substitutedPlayersData
    local lastPlaceNum = MatchConstants.SubstitutionSum - totalSubstitutedPlayersNum - #self.substitutingPlayersData
    if lastPlaceNum < 0 then
        lastPlaceNum = 0
    end
    self.alreadyChange.text = lang.trans("matchFormation_alreadyChange", totalSubstitutedPlayersNum + #self.substitutingPlayersData, MatchConstants.SubstitutionSum)
    --self.availableChange.text = lang.trans("matchFormation_availableChange", lastPlaceNum, MatchConstants.SubstitutionSum - totalSubstitutedPlayersNum)
end

-- 接受发生onDrop事件的球员位置的数据
function MatchFormationPageView:ReceiveDropPlayer(playerCardCircle, dataIndex, playerClassify)
    self.playerCardCircleOnDrop = playerCardCircle
    self.dataIndexOnDrop = dataIndex
    self.playerClassifyOnDrop = playerClassify
end

function MatchFormationPageView:ReceiveEndDragPlayer(playerCardCircle, dataIndex, playerClassify, eventData)
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
        end
    end

    self:ClearDragVariable()
    self:CalculateTotalPower()
    self.substitutingPlayersData = self.playerTeamsModel:GetNewReplacedPlayersList(self.nowTeamId, self.replacePlayersData)
    self:BuildTopTipText()
end

-- 同类型球员交换：首发球员或者替补球员
function MatchFormationPageView:SwapSameClassify()
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
    self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
end

-- 判断拖拽球员时是否首发和替补球员中有相同BaseId的球员
function MatchFormationPageView:HasSamePlayer()
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

-- 交换首发和替补球员
function MatchFormationPageView:SwapInitAndReplace()
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
    self.formationCacheDataModel:SetReplacePlayerCacheData(self.replacePlayersData)
end

-- 清空拖拽中使用的变量
function MatchFormationPageView:ClearDragVariable()
    self.playerCardCircleOnDrop = nil
    self.dataIndexOnDrop = nil
    self.playerClassifyOnDrop = nil
    self.playerCardCircleOnEndDrag = nil
    self.dataIndexOnEndDrag = nil
    self.playerClassifyOnEndDrag = nil
end

function MatchFormationPageView:SetChangePlayerAttrsBarState(isShow)
    GameObjectHelper.FastSetActive(self.changePlayerAttrsBar, isShow)
end

function MatchFormationPageView:RefreshPlayerAllAttrsChange(comePlayerCircleCard, leavePlayerCircleCard)
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

function MatchFormationPageView:RefreshPlayerAttrChange(comePlayerCircleCard, leavePlayerCircleCard, attrIndex, attrTable)
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
function MatchFormationPageView:CheckTeamChanged()

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

    return false
end

-- 检测阵容是否符合条件，即有11位上场球员
function MatchFormationPageView:CheckTeamValid()
    local index = 0

    for pos, pcId in pairs(self.initPlayersData) do
        if pcId ~= nil and pcId ~= 0 then
            index = index + 1
        end
    end

    local extraSubstitutePlayerNum = #self.substitutedPlayersData + #self.substitutingPlayersData - MatchConstants.SubstitutionSum
    if index ~= 11 then
        return FormationConstants.FormationValidType.NOVALID_INITPLAYERS_NOTENOUGH
    elseif extraSubstitutePlayerNum > 0 then
        return FormationConstants.FormationValidType.NOVALID_EXTRA_SUBSTITUTION_SUM
    else
        return FormationConstants.FormationValidType.VALID
    end
end

-- 询问是否保存阵容
function MatchFormationPageView:AskSaveTeamOrNot(callback)
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
            elseif validType == FormationConstants.FormationValidType.NOVALID_EXTRA_SUBSTITUTION_SUM then
                DialogManager.ShowToastByLang("formation_validType_extra_substitution_sum")
            end
        end, function ()
            if type(callback) == "function" then
                callback()
            end
        end)
    else
        if type(callback) == "function" then
            callback()
        end
    end
end

-- 保存阵容数据
function MatchFormationPageView:SaveTeamData(onComplete)
    if self.formationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(self.initPlayersData) then
        self.formationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(self.initPlayersData)
        self.formationCacheDataModel:SetKeyPlayersDefaultData()
    end
    local oldInitPlayersData = self.playerTeamsModel:GetInitPlayersData(self.nowTeamId)
    local oldReplacePlayersData = self.playerTeamsModel:GetReplacePlayersData(self.nowTeamId)
    self.matchInfoModel:UpdatePlayerTeamDataAfterSubstitution(self.nowFormationId, oldInitPlayersData, self.initPlayersData, oldReplacePlayersData, self.replacePlayersData)
    local keyPlayersPcidCacheData = self.formationCacheDataModel:GetKeyPlayersCacheData()
    local keyPlayersPosCacheData = {}
    for pos, pcid in pairs(self.initPlayersData) do
        if keyPlayersPcidCacheData.captain == pcid then
            keyPlayersPosCacheData.captain = tonumber(pos)
        end
        if keyPlayersPcidCacheData.corner == pcid then
            keyPlayersPosCacheData.cornerKicker = tonumber(pos)
        end
        if keyPlayersPcidCacheData.freeKickPass == pcid then
            keyPlayersPosCacheData.freeKickPasser = tonumber(pos)
        end
        if keyPlayersPcidCacheData.freeKickShoot == pcid then
            keyPlayersPosCacheData.freeKickShooter = tonumber(pos)
        end
        if keyPlayersPcidCacheData.spotKick == pcid then
            keyPlayersPosCacheData.penaltyKicker = tonumber(pos)
        end
    end
    self.matchInfoModel:UpdatePlayerKeyPlayersData(keyPlayersPosCacheData)
    local formationInfo = self.matchInfoModel:GetPlayerFormationInfo()
    EmulatorInput.GetInstance():SetFormationJson(json.encode(formationInfo))
    EmulatorInput.GetInstance():SetIsFormationChanged(true)
    self.playerTeamsModel:SetNowTeamId(self.nowTeamId)
    self.playerTeamsModel:SetFormationId(self.nowTeamId, self.nowFormationId)
    self.playerTeamsModel:SetInitPlayersData(self.nowTeamId, self.initPlayersData)
    self.playerTeamsModel:SetReplacePlayersData(self.nowTeamId, self.replacePlayersData)
    self.playerTeamsModel:SetNowTeamKeyPlayersData(self.formationCacheDataModel:GetKeyPlayersCacheData())
    self.matchInfoModel:SetMatchTeamData(self.playerTeamsModel:GetData())
    self.matchInfoModel:SetSubstitutedPlayersData(self.substitutingPlayersData)

    if type(onComplete) == "function" then
        onComplete()
    end
end

-- 更换阵型
function MatchFormationPageView:ChangeFormation(formationId)
    self.nowFormationId = formationId
    self.formationCacheDataModel:SetFormationIdCacheData(self.nowFormationId)
    self.initPlayersData = self.playerTeamsModel:ChangeFormation(self.nowFormationId, self.initPlayersData)
    self.formationCacheDataModel:SetInitPlayerCacheData(self.initPlayersData)
    self:BuildPage()
end

function MatchFormationPageView:SortInitPlayersWithPos()
    local initPlayersList = {}

    for pos, pcId in pairs(self.initPlayersData) do
        table.insert(initPlayersList, {pos = pos, pcId = pcId})
    end
    table.sort(initPlayersList, function (a, b)
        return tonumber(a.pos) < tonumber(b.pos)
    end)

    return initPlayersList
end

function MatchFormationPageView:SortReplacePlayersWithPos()
    local replacePlayersList = {}

    for pos, pcId in pairs(self.replacePlayersData) do
        table.insert(replacePlayersList, {pos = pos, pcId = pcId})
    end
    table.sort(replacePlayersList, function (a, b)
        return tonumber(a.pos) < tonumber(b.pos)
    end)

    return replacePlayersList
end

function MatchFormationPageView:FormationDataChange(formationDataChanged)
    GameObjectHelper.FastSetActive(self.saveEnableBtn, formationDataChanged)
    GameObjectHelper.FastSetActive(self.saveDisableBtn, not formationDataChanged)
end

function MatchFormationPageView:Destroy()
    --DOTween.Kill("playerAttrsSequence")
    Object.Destroy(self.gameObject)
    self.cardResourceCache:Clear()
end

function MatchFormationPageView:onDestroy()
    self:UnRegisterEvent()
end

return MatchFormationPageView
