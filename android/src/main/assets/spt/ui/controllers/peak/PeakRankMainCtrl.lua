local PeakRealTimeRankCtrl = require("ui.controllers.peak.PeakRealTimeRankCtrl")
local PeakSeasonRankCtrl = require("ui.controllers.peak.PeakSeasonRankCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakRankModel = require("ui.models.peak.PeakRankModel")

local PeakRankMainCtrl = class(BaseCtrl)

PeakRankMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakRankBoard.prefab"

function PeakRankMainCtrl:AheadRequest()
    local response = req.peakSeasonRank()
    if api.success(response) then
        local data = response.val
        if data then
            self.peakRankModel = PeakRankModel.new()
            if data.player then
                self.peakRankModel:InitMyRankInfo(data.player)
            end
            if data.rankList then
                self.peakRankModel:InitCurRankDataList(data.rankList)
            end
            if data.historyRankList then
                self.peakRankModel:InitRankSeasonList(data.historyRankList)
            end
        end
    end    
end

function PeakRankMainCtrl:Init(peakRewardPoint)
    self.peakRankModel:SetPrePeakDailyCount(peakRewardPoint)
    self.peakRealTimeRankCtrl = PeakRealTimeRankCtrl.new(self.view:GetRealTimeRankBoard())
    self.peakSeasonRankCtrl = PeakSeasonRankCtrl.new(self.view:GetSeasonRankBoard())
end

function PeakRankMainCtrl:Refresh()
    PeakRankMainCtrl.super.Refresh(self)
    self:InitView()
end

function PeakRankMainCtrl:GetStatusData()
    return self.peakRankModel
end

function PeakRankMainCtrl:InitView()
    self:CreateItemList()
    self.view.onBack = function() self:OnBack() end
    self.view:InitView(self.peakRankModel)
    self.peakSeasonRankCtrl:InitView(self.peakRankModel)
end

function PeakRankMainCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRankTabBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local seasonData = self.view.scrollView.itemDatas[index]
        spt.btnRankTab.clickRankTab = function() self:ClickRankTab(index) end
        spt:InitView(seasonData.name)
        spt:ChangeButtonState(seasonData.isSelect)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:ClickRankTab(1)
    self:RefreshScrollView()
end

function PeakRankMainCtrl:RefreshScrollView()
    local seasonList = self.peakRankModel:GetRankSeasonList()
    self.view.scrollView:clearData()
    if seasonList then
        for i = 1, #seasonList do
            table.insert(self.view.scrollView.itemDatas, seasonList[i])
        end
    end
    self.view.scrollView:refresh()
end

function PeakRankMainCtrl:ClickRankTab(index)
    local seasonList = self.peakRankModel:GetRankSeasonList()
    if seasonList then
        for i, seasonData in ipairs(seasonList) do
            if i == index then
                seasonData.isSelect = true
                self:RequestCurRankDataList(seasonData.type)
            else
                seasonData.isSelect = false
            end
            local spt = self.view.scrollView:getItem(i)
            if spt then
                spt:ChangeButtonState(seasonData.isSelect)
            end
        end
    end
end

function PeakRankMainCtrl:RequestCurRankDataList(seasonType)
    clr.coroutine(function()
        if seasonType == "current" then
            local response = req.peakRank()
            if api.success(response) then
                local data = response.val
                if data then
                    self.peakRankModel = self.peakRankModel or PeakRankModel.new()
                    if data.player then
                        self.peakRankModel:InitMyRealTimeRankInfo(data.player)
                    end
                    if data.rankList then
                        self.peakRankModel:InitRealTimeRankList(data.rankList)
                    end
                end
            end
        end
        self.peakRankModel:InitCurRankDataBySelectType(seasonType)
        self.view:InitView(self.peakRankModel)
        if seasonType == "current" then
            self.peakRealTimeRankCtrl:InitView(self.peakRankModel)
        else
            self.peakSeasonRankCtrl:InitView(self.peakRankModel)
        end
    end)
end

function PeakRankMainCtrl:OnBack()
    res.PopScene()
end

return PeakRankMainCtrl