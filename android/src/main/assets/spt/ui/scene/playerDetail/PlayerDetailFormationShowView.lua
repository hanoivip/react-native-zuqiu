local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachHelper = require("ui.scene.coach.common.CoachHelper")
local LevelLimit = require("data.LevelLimit")
local Formation = require("data.Formation")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")

-- 阵型显示
local PlayerDetailFormationShowView = class(unity.base)

function PlayerDetailFormationShowView:ctor()
    self.power = self.___ex.power
    self.formationName = self.___ex.formationName
    self.initArea = self.___ex.initArea
    self.powerArea = self.___ex.powerArea
    self.formationTxt = self.___ex.formationTxt
    self.formationInfo = self.___ex.formationInfo
    self.formationInfoObj = self.___ex.formationInfoObj
    self.coachInfoTrans = self.___ex.coachInfoTrans
    self.btnCoach = self.___ex.btnCoach
    self.objCoachList = self.___ex.objCoachList
    self.btnCoachMask = self.___ex.btnCoachMask
    self.btnCoachBaseInfo = self.___ex.btnCoachBaseInfo
    self.btnCoachTalent = self.___ex.btnCoachTalent
    self.btnCoachAssist = self.___ex.btnCoachAssist
    self.mySceneTrans = self.___ex.mySceneTrans

    self.cardResourceCache = CardResourceCache.new()
    self.isCoach = false
end

function PlayerDetailFormationShowView:onEnable()
    self:CloseCoachList()
end

function PlayerDetailFormationShowView:onDestroy()
    self.cardResourceCache:Clear()
end

function PlayerDetailFormationShowView:InitView(detailModel, bShowMyScene)
    self.playerDetailModel = detailModel
    self.formationTxt.text = lang.transstr("pd_formation_txt")
    local arenaType = detailModel:GetArenaType()
    if arenaType then
        self.formationInfoObj:SetActive(true)
        arenaType = lang.trans("arena_" .. arenaType)
        self.formationInfo.text = arenaType
    else
        self.formationInfoObj:SetActive(false)
    end
    local otherPlayerTeamsModel = OtherPlayerTeamsModel.new()
    self:ShowCourt(otherPlayerTeamsModel)
    self:ShowPower(self.playerDetailModel:GetPower())
    self:ShowFormationName(otherPlayerTeamsModel:GetFormationId())
    local level = self.playerDetailModel:GetCoachLevel()
    local playerLevel = self.playerDetailModel:GetPlayerLevel()

    local coachOpenLevel = LevelLimit.Coach.playerLevel
    local coachOpenState = coachOpenLevel <= playerLevel and level > 0
    GameObjectHelper.FastSetActive(self.coachInfoTrans.gameObject, coachOpenState)
    local mySceneState = false
    if bShowMyScene and coachOpenState then
        mySceneState = CoachMainPageConfig.GetOpenStateByTag("CoachGuide", level)
    end
    GameObjectHelper.FastSetActive(self.mySceneTrans.gameObject, mySceneState)
    if coachOpenState then
        self:ShowCoach()
    end
    if mySceneState then
        self:ShowMyScene()
    end
end

-- 显示球场
function PlayerDetailFormationShowView:ShowCourt(otherPlayerTeamsModel)
    local playerCardCircle = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab")
    local formationId = otherPlayerTeamsModel:GetFormationId()
    local initPlayersData = otherPlayerTeamsModel:GetInitPlayersData()
    local initPlayersList = {}

    for i = 1, self.initArea.transform.childCount do
        Object.Destroy(self.initArea.transform:GetChild(i - 1).gameObject)
    end
    
    for pos, pcId in pairs(initPlayersData) do
        table.insert(initPlayersList, {pos = pos, pcId = pcId})
    end
    table.sort(initPlayersList, function (a, b)
        return tonumber(a.pos) < tonumber(b.pos)
    end)

    for i, itemData in pairs(initPlayersList) do
        local prefab = Object.Instantiate(playerCardCircle)
        local script = res.GetLuaScript(prefab)
        prefab.transform:SetParent(self.initArea, false)
        local playerCardModel = self.playerDetailModel:GetPlayerCardModel(itemData.pcId)
        if playerCardModel then
            script:SetCardResCache(self.cardResourceCache)
            script:initDataByModel(itemData.pos, playerCardModel, FormationConstants.CardShowType.MAIN_INFO, FormationConstants.PlayersClassifyInFormation.INIT, false, false, true, self.playerDetailModel.specialEventsMatchId)
            script:SetPosInPlane(itemData.pos, formationId, 620, 430, false, 1)
        end
    end
end

-- 显示战力
function PlayerDetailFormationShowView:ShowPower(power)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.powerArea, 3, 8)
    end
    self.powerCtrl:InitPower(power)
end

-- 显示阵容
function PlayerDetailFormationShowView:ShowFormationName(formationId)
    self.formationName.text = Formation[tostring(formationId)].name
end

-- 显示教练
function PlayerDetailFormationShowView:ShowCoach()
    local coachLvl = self.playerDetailModel:GetCoachLevel()
    local credentialLevel = CoachHelper.GetCredentialLevel(coachLvl)
    local starLevel = CoachHelper.GetStarLevel(coachLvl)
    if not self.coachInfoSpt then
        local coachInfoObj, coachInfoSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachEntry.prefab")
        coachInfoObj.transform:SetParent(self.coachInfoTrans, false)
        coachInfoObj.transform:SetAsFirstSibling()
        self.coachInfoSpt = coachInfoSpt
    end
    self.coachInfoSpt:InitView(credentialLevel, starLevel)

    local formation = self.playerDetailModel:GetCoachFormation()
    local tactics = self.playerDetailModel:GetCoachTactics()
    local talent = self.playerDetailModel:GetCoachTalent()
    local assistant = self.playerDetailModel:GetCoachAssistant()

    local hasBaseInfo = not table.isEmpty(formation) and not table.isEmpty(tactics)
    local hasTalent = not table.isEmpty(talent)
    local hasAssist = not table.isEmpty(assistant)
    self.btnCoach:regOnButtonClick(function()
        self:ShowCoachList(not self.isCoach)
    end)
    self.btnCoachMask:regOnButtonClick(function()
        self:CloseCoachList()
    end)
    self.btnCoachBaseInfo:regOnButtonClick(function()
        -- 点击教练信息
        self:CloseCoachList()
        local coach = self.playerDetailModel:GetCoach()
        local otherPlayerCardsMapModel = self.playerDetailModel:GetOtherPlayerCardsMapModel()
        local otherPlayerTeamsModel = self.playerDetailModel:GetOtherPlayerTeamsModel()
        res.PushScene("ui.controllers.coach.otherPlayer.OtherCoachBaseInfoCtrl", coach, otherPlayerTeamsModel, otherPlayerCardsMapModel)
    end)
    self.btnCoachTalent:regOnButtonClick(function()
        -- 执教天赋
        self:CloseCoachList()
        res.PushScene("ui.controllers.coach.otherPlayer.OtherCoachTalentCtrl", talent)
    end)
    self.btnCoachAssist:regOnButtonClick(function()
        -- 助理教练
        self:CloseCoachList()
        res.PushScene("ui.controllers.coach.otherPlayer.OtherAssistantCoachSystemCtrl", assistant)
    end)
    GameObjectHelper.FastSetActive(self.btnCoachBaseInfo.gameObject, hasBaseInfo)
    GameObjectHelper.FastSetActive(self.btnCoachTalent.gameObject, hasTalent)
    GameObjectHelper.FastSetActive(self.btnCoachAssist.gameObject, hasAssist)
end

function PlayerDetailFormationShowView:ShowMyScene()
    if not self.mySceneSpt then
        local Obj, Spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/MyScene/MySceneEnterView.prefab")
        Obj.transform:SetParent(self.mySceneTrans, false)
        self.mySceneSpt = Spt
    end
    self.mySceneSpt:InitView(3)
end

function PlayerDetailFormationShowView:CloseCoachList()
    self.isCoach = false
    self:ShowCoachList(self.isCoach)
end

function PlayerDetailFormationShowView:ShowCoachList(isShow)
    GameObjectHelper.FastSetActive(self.objCoachList, isShow)
    GameObjectHelper.FastSetActive(self.btnCoachMask.gameObject, isShow)
end

return PlayerDetailFormationShowView