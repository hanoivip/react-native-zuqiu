local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CardConfig = require("ui.common.card.CardConfig")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")

local PeakPlayerTeamsModel = class(PlayerTeamsModel, "PeakPlayerTeamsModel")

function PeakPlayerTeamsModel:ctor(data, ptid)
    PeakPlayerTeamsModel.super.ctor(self)
    assert(data, "please input the data of the peak formation")
    self.ptid = ptid
    self:Init(data)
end

function PeakPlayerTeamsModel:Init(data)
    if data ~= nil then
        self.data = clone(data)
        if not next(self.data) then
            self:SetNowTeamId(0)
            self.data.teams = {}
            self.nowFormationId = 10
        end
        self:InitAllCardsData()
        self:SetNowTeamData(self:GetNowTeamId())
        self:SetSelectedType(self:GetSelectedType())
    end
end

function PeakPlayerTeamsModel:GetData()
    return self.data
end

function PeakPlayerTeamsModel:SaveData(data)
end

function PeakPlayerTeamsModel:GetCardMaxQuality()
    return CardConfig.QUALITY.GOLD
end

function PeakPlayerTeamsModel:GetPtid()
    return self.ptid or 0
end

function PeakPlayerTeamsModel:InitAllCardsData()
    self.initAllCardsDataTable = {}
    -- 获取卡牌背包中的数据
    local initAllCardsDataTable = cache.getPlayerCardsMap()
    local inTeamPlayerData = cache.getPeakTeamData()
    local inTeamPlayersList = {}

    for k, v in pairs(inTeamPlayerData) do
        if v.init and v.ptid ~= self.ptid then
            for _, pcid in pairs(v.init) do
                inTeamPlayersList[SimpleCardModel.new(pcid):GetCid()] = true
            end
        end
        if v.rep and v.ptid ~= self.ptid then
            for _, pcid in pairs(v.rep) do
                inTeamPlayersList[SimpleCardModel.new(pcid):GetCid()] = true
            end
        end
    end

    local playerCardsMapModel = PlayerCardsMapModel.new()
    local cardCidMaps = playerCardsMapModel:GetCardCidMaps()

    for k, v in pairs(cardCidMaps) do
        if not inTeamPlayersList[k] then
            for pcid, _ in pairs(v) do
                self.initAllCardsDataTable[tostring(pcid)] = initAllCardsDataTable[tostring(pcid)]
            end
        end
    end
end

function PeakPlayerTeamsModel:SetAllCardsData()
    assert(self.initAllCardsDataTable, "data has error!")
    self.allCardsData = self.initAllCardsDataTable
end

return PeakPlayerTeamsModel
