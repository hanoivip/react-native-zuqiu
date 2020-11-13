local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local CommonConstants = require("ui.common.CommonConstants")
local CourtBuildType = require("ui.scene.court.CourtBuildType")

local LeagueMatchRewardPageView = class(unity.base)

function LeagueMatchRewardPageView:ctor()
    -- 上次排名
    self.oldRank = self.___ex.oldRank
    -- 新的排名
    self.newRank = self.___ex.newRank
    -- 主场收入显示条
    self.homeBar = self.___ex.homeBar
    -- 赞助费显示条
    self.sponsorBar = self.___ex.sponsorBar
    -- 主场收入
    self.homeIncomeNum = self.___ex.homeIncomeNum
    -- 观众席
    self.capacityAudienceLv = self.___ex.capacityAudienceLv
    self.capacityAudienceDetail = self.___ex.capacityAudienceDetail
    -- 停车场
    self.parkingLv = self.___ex.parkingLv
    self.parkingDetail = self.___ex.parkingDetail
    -- 电子计分板
    self.priceBoardLv = self.___ex.priceBoardLv
    self.boardDetail = self.___ex.boardDetail
    -- 照明设备
    self.lightingLv = self.___ex.lightingLv
    self.lightDetail = self.___ex.lightDetail
    -- 零售商店
    self.storeLv = self.___ex.storeLv
    self.storeDetail = self.___ex.storeDetail
    --赞助费
    self.sponsorNum = self.___ex.sponsorNum
    -- 排名提升组
    self.rankGroup = self.___ex.rankGroup
    -- 初次排名信息
    self.firstRankObj = self.___ex.firstRankObj
    -- 排名上升
    self.rankObj = self.___ex.rankObj
    -- 动画管理器
    self.animator = self.___ex.animator
    -- model
    self.leagueInfoModel = nil
    -- 联赛基础信息
    self.baseInfo = nil
    -- 结算数据
    self.settlementData = nil
    -- 界面销毁时的回调
    self.destroyCallback = nil
end

function LeagueMatchRewardPageView:InitView(leagueInfoModel, settlementData, destroyCallback)
    self.leagueInfoModel = leagueInfoModel
    self.settlementData = settlementData
    self.destroyCallback = destroyCallback
    self.baseInfo = self.leagueInfoModel:GetBaseInfo()
    
    self:BuildPage()
end

function LeagueMatchRewardPageView:start()
end

function LeagueMatchRewardPageView:BuildPage()
    -- 联赛排名提升
    local leaguePreRanking = self.settlementData.leaguePreRanking or 0
    local leagueRanking = self.baseInfo.leagueRanking or 0
    -- 新排名
    local newRankNum = leagueRanking + 1
    local rankState = (leaguePreRanking > leagueRanking or leaguePreRanking == -1) and newRankNum ~= 0
    if rankState then
        -- 上次排名
        self.oldRank.text = self.settlementData.leaguePreRanking == -1 and "0" or tostring(self.settlementData.leaguePreRanking + 1)
        self.firstRankObj:SetActive(self.settlementData.leaguePreRanking == -1)
        self.rankObj:SetActive(self.settlementData.leaguePreRanking ~= -1)
        self.newRank.text = tostring(newRankNum)
    else
        self.rankGroup:SetActive(false)
    end
    local courtData = self.settlementData.buildsLvl
    -- 主场收入
    local homeMoney = tonumber(self.settlementData.homeIncome) or 0
    if homeMoney > 0 then
        self.homeIncomeNum.text = string.formatNumWithUnit(homeMoney)
        self.capacityAudienceLv.text = "Lv" .. tostring(courtData[CourtBuildType.AudienceBuild].lvl)
        self.parkingLv.text = "Lv" .. tostring(courtData[CourtBuildType.ParkingBuild].lvl)
        self.priceBoardLv.text = "Lv" .. tostring(courtData[CourtBuildType.ScoreBoardBuild].lvl)
        self.lightingLv.text = "Lv" .. tostring(courtData[CourtBuildType.LightingBuild].lvl)
        self.storeLv.text = "Lv" .. tostring(courtData[CourtBuildType.StoreBuild].lvl)
        self.capacityAudienceDetail.text = lang.trans("league_capacity", self.settlementData.homeDetail.capacityAudience)
        self.parkingDetail.text = lang.trans("league_attendence", string.format("%.2f", self.settlementData.homeDetail.rateParking.rate * self.settlementData.homeDetail.rateParking.wave * 100))
        self.lightDetail.text = lang.trans("league_lightPrice",string.format("%.1f", tonumber(self.settlementData.homeDetail.priceLighting) / 10000))
        self.boardDetail.text = lang.trans("league_boardPrice", string.format("%.1f", tonumber(self.settlementData.homeDetail.priceBoard) / 10000))
        self.storeDetail.text = lang.trans("league_extraIncome", string.format("%.2f", tonumber(self.settlementData.homeDetail.priceStore) / 10000))
    else
        self.homeBar:SetActive(false)
    end

    -- 赞助费
    local sponsorMoney = tonumber(self.settlementData.sponserMoney) or 0
    if sponsorMoney > 0 then
        self.sponsorNum.text = string.formatNumWithUnit(sponsorMoney)
    else
        self.sponsorBar:SetActive(false)
    end
end

function LeagueMatchRewardPageView:Close()
    self:PlayMoveOutAnim()
end

function LeagueMatchRewardPageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut")
end

function LeagueMatchRewardPageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:Destroy()
    end
end

function LeagueMatchRewardPageView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
    if type(self.destroyCallback) == "function" then
        self.destroyCallback()
    end
end

return LeagueMatchRewardPageView
