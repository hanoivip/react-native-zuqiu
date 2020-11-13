local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local Formation = require("data.Formation")
local CardResourceCache = require("ui.common.card.CardResourceCache")

-- 阵型显示
local PeakPlayerDetailFormationShowView = class(unity.base)

function PeakPlayerDetailFormationShowView:ctor()
    self.power = self.___ex.power
    self.formationName = self.___ex.formationName
    self.initArea = self.___ex.initArea
    self.powerArea = self.___ex.powerArea
    self.formationTxt = self.___ex.formationTxt
    self.formationInfo = self.___ex.formationInfo
    self.formationInfoObj = self.___ex.formationInfoObj
    self.cardResourceCache = CardResourceCache.new()
end

function PeakPlayerDetailFormationShowView:InitView(detailModel)
    self.playerDetailModel = detailModel
    self.formationTxt.text = lang.transstr("pd_formation_txt")
    local teamName = detailModel:GetTeamName()
    if teamName then
        self.formationInfoObj:SetActive(true)
        self.formationInfo.text = teamName
    else
        self.formationInfoObj:SetActive(false)
    end
    local otherPlayerTeamsModel = OtherPlayerTeamsModel.new()
    self:ShowCourt(otherPlayerTeamsModel)
    self:ShowPower(self.playerDetailModel:GetPower())
    self:ShowFormationName(otherPlayerTeamsModel:GetFormationId())
end

-- 显示球场
function PeakPlayerDetailFormationShowView:ShowCourt(otherPlayerTeamsModel)
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
function PeakPlayerDetailFormationShowView:ShowPower(power)
    if not self.powerCtrl then
        self.powerCtrl = CardPowerCtrl.new(self.powerArea, 3, 8)
    end
    self.powerCtrl:InitPower(power)
end

-- 显示阵容
function PeakPlayerDetailFormationShowView:ShowFormationName(formationId)
    self.formationName.text = Formation[tostring(formationId)].name
end

--清空显示
function PeakPlayerDetailFormationShowView:ClearView()

end


function PeakPlayerDetailFormationShowView:onDestroy()
    self.cardResourceCache:Clear()
end

return PeakPlayerDetailFormationShowView