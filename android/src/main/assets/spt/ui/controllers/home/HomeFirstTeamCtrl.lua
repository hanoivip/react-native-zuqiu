local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local FormationType = require("ui.common.enum.FormationType")
local CardBuilder = require("ui.common.card.CardBuilder")
local HomeFirstTeamCtrl = class()

function HomeFirstTeamCtrl:ctor(view, parentCtrl)
    self.parentCtrl = parentCtrl
    self.firstTeamView = view
    self.firstTeamView.clickCard = function(pcid)
        self:OnBtnCard(pcid)
    end
    self.powerValue = 0
    self.legendCardsMapModel = LegendCardsMapModel.new()
end

-- 初始化首发球员数据
function HomeFirstTeamCtrl:InitView(teamsModel)
    assert(teamsModel)
    self.teamsModel = teamsModel

    self.legendCardsMapModel:BuildTeamLegendInfo(teamsModel)
    local initPlayerData = teamsModel:GetInitPlayersData(teamsModel:GetNowTeamId())
    local cardList = {}
    local cardMap = {}
    local cardModelMap = {}
    for k, pcid in pairs(initPlayerData) do
        local cardModel = PlayerCardModel.new(pcid, teamsModel)
        cardModelMap[tostring(pcid)] = cardModel
        local cardData = {}
        cardData.pcid = pcid
        cardData.pos = k
        table.insert(cardMap, cardData)
        table.insert(cardList, pcid)
    end
    table.sort(cardMap, function(a, b) return a.pos < b.pos end)
    self.cardMap = cardMap
    self.cardList = cardList
    self.cardModelMap = cardModelMap
    self.firstTeamView:InitView(self.cardMap, self.cardModelMap, self.teamsModel)
    self:InitPower(teamsModel:GetTotalPower())
end

local TotalTime = 3
local PowerNums = 8
function HomeFirstTeamCtrl:InitPower(power)
    if not self.powerCtrl then 
        self.powerCtrl = CardPowerCtrl.new(self.firstTeamView.powerParent, TotalTime, PowerNums)
    end
    if self.powerValue ~= power or power == 0 then 
        self.powerCtrl:InitPower(power) 
    end
    self.powerValue = power
end

function HomeFirstTeamCtrl:OnHomeCourtUpdate()
    self:InitPower(self.teamsModel:GetTotalPower())
end

-- 卡牌详情页按照cardList中对应索引
function HomeFirstTeamCtrl:GetCardIndex(selectPcid)
    local index = 1
    for i, pcid in ipairs(self.cardList) do
        if pcid == selectPcid then 
            index = i
            break
        end
    end
    return index
end

-- 点击卡牌，弹出卡牌详情页面 传入cardList只包括pcid
function HomeFirstTeamCtrl:OnBtnCard(pcid)
    local index = self:GetCardIndex(pcid)
    local currentModel = CardBuilder.GetStarterModel(pcid, self.playerTeamsModel)
    local cardCtrl = res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", self.cardList, index, currentModel, nil, true)
end

-- 首发阵容在每次切换会刷新数据
function HomeFirstTeamCtrl:Refresh()
    self.playerTeamsModel = PlayerTeamsModel.new()
    self.playerTeamsModel:SetFormationType(FormationType.HOME)
    self:InitView(self.playerTeamsModel)
end

function HomeFirstTeamCtrl:RefreshViewRect()
    self.firstTeamView:RefreshViewRect()
end

return HomeFirstTeamCtrl
