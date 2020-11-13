local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Formation = require("data.Formation")

-- 阵型显示
local CompeteChampionWallFormationView = class(unity.base)

local Court_Width = 674
local Court_Height = 330

function CompeteChampionWallFormationView:ctor()
    self.formationName = self.___ex.formationName
    self.txtFormationTitle = self.___ex.txtFormationTitle
    self.initArea = self.___ex.initArea
    self.txtPowerTitle = self.___ex.txtPowerTitle
    self.powerArea = self.___ex.powerArea

    self.cardResourceCache = CardResourceCache.new()
end

function CompeteChampionWallFormationView:InitView(playerDetailModel, otherPlayerTeamsModel)
    self.playerDetailModel = playerDetailModel
    self.otherPlayerTeamsModel = otherPlayerTeamsModel
    self:ShowCourt(otherPlayerTeamsModel)
    self:ShowPower(playerDetailModel:GetPower())
    self:ShowFormationName(otherPlayerTeamsModel:GetFormationId())
end

-- 显示球场
function CompeteChampionWallFormationView:ShowCourt(otherPlayerTeamsModel)
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
            script:SetPosInPlane(itemData.pos, formationId, Court_Width, Court_Height, false, 1)
        end
    end
end

-- 显示战力
function CompeteChampionWallFormationView:ShowPower(power)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.powerArea, 3, 7)
    end
    self.powerCtrl:InitPower(power)
end

-- 显示阵容
function CompeteChampionWallFormationView:ShowFormationName(formationId)
    self.formationName.text = Formation[tostring(formationId)].name
end

-- 设置显示
function CompeteChampionWallFormationView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.initArea.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.txtFormationTitle.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.formationName.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.txtPowerTitle.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.powerArea.gameObject, isShow)
end

return CompeteChampionWallFormationView
