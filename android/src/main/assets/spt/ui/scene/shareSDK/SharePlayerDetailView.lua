local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local PlayerDetailModel = require("ui.models.playerDetail.PlayerDetailModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local Formation = require("data.Formation")

-- 阵型显示
local SharePlayerDetailView = class(unity.base)

function SharePlayerDetailView:ctor()
    self.power = self.___ex.power
    self.formationName = self.___ex.formationName
    self.initArea = self.___ex.initArea
	self.cardResourceCache = CardResourceCache.new()
end

function SharePlayerDetailView:InitView(initCallBack)
    self.playerDetailModel = PlayerDetailModel.new()
    clr.coroutine(function()
        local playerInfoModel = PlayerInfoModel.new()
        local respone = req.friendsDetail(playerInfoModel:GetID(), playerInfoModel:GetSID())
        if api.success(respone) then
            local data = respone.val
            self.playerDetailModel:InitWithProtocol(data)
            local otherPlayerTeamsModel = OtherPlayerTeamsModel.new()
            self:ShowCourt(otherPlayerTeamsModel)
            self:ShowFormationName(otherPlayerTeamsModel:GetFormationId())
            self:ShowPower(self.playerDetailModel:GetPower())
            if initCallBack ~= nil then
                initCallBack()
            end 
        end
    end)
end

-- 显示球场
function SharePlayerDetailView:ShowCourt(otherPlayerTeamsModel)
    local playerCardCircle = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/SharePlayerCardCircle.prefab")
    local formationId = otherPlayerTeamsModel:GetFormationId()
    local initPlayersData = otherPlayerTeamsModel:GetInitPlayersData()
    local initPlayersList = {}

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
            script:initDataByModel(itemData.pos, playerCardModel, FormationConstants.CardShowType.MAIN_INFO, FormationConstants.PlayersClassifyInFormation.INIT, false, false, true)
            script:SetPosInPlane(itemData.pos, formationId, 620, 430, false, 1)
        end
    end
end

-- 显示战力
function SharePlayerDetailView:ShowPower(power)
    self.power.text = lang.trans("share_power", power)
end

-- 显示阵容
function SharePlayerDetailView:ShowFormationName(formationId)
    self.formationName.text = lang.trans("share_formation", Formation[tostring(formationId)].name)
end

function SharePlayerDetailView:onDestroy()
    self.cardResourceCache:Clear()
end

return SharePlayerDetailView