local DreamRankModel = require("ui.models.dreamLeague.dreamRank.DreamRankModel")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local DreamRankMainCtrl = class(BaseCtrl)

DreamRankMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamRank/DreamRankBoard.prefab"

function DreamRankMainCtrl:AheadRequest()
    local response = req.dreamLeagueMatchRank()
    if api.success(response) then
        local data = response.val
        if data then
            self.dreamRankModel = DreamRankModel.new()
            self.dreamRankModel:InitWithProtocol(data)
        end
    end
end

function DreamRankMainCtrl:Init(peakRewardPoint)
end

function DreamRankMainCtrl:Refresh()
    DreamRankMainCtrl.super.Refresh(self)
    self:InitView()
end

function DreamRankMainCtrl:GetStatusData()
    return self.dreamRankModel
end

function DreamRankMainCtrl:InitView()
    self:CreateItemList()
    self.view:InitView(self.dreamRankModel)
end

function DreamRankMainCtrl:CreateItemList()
    self.view.tabScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRankTabBar.prefab")
        return obj, spt
    end
    self.view.tabScrollView.onScrollResetItem = function(spt, index)
        local seasonData = self.view.tabScrollView.itemDatas[index]
        spt.btnRankTab.clickRankTab = function() self:ClickRankTab(index) end
        spt:InitView(seasonData.name)
        spt:ChangeButtonState(seasonData.isSelect)
        self.view.tabScrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function DreamRankMainCtrl:RefreshScrollView()
    local tabList = self.dreamRankModel:GetRankTabList()
    self.view.tabScrollView:clearData()
    if tabList then
        for i = 1, #tabList do
            table.insert(self.view.tabScrollView.itemDatas, tabList[i])
        end
    end
    self.view.tabScrollView:refresh()
end

function DreamRankMainCtrl:ClickRankTab(index)
    local tabList = self.dreamRankModel:GetRankTabList()
    for i, seasonData in ipairs(tabList) do
        if i == index then
            seasonData.isSelect = true
            self:RequestCurRankDataList(seasonData.matchTag)
        else
            seasonData.isSelect = false
        end
        local spt = self.view.tabScrollView:getItem(i)
        if spt then
            spt:ChangeButtonState(seasonData.isSelect)
        end
    end
end

function DreamRankMainCtrl:RequestCurRankDataList(matchTag)
    clr.coroutine(function()
        if matchTag ~= "current" then
            local isHadData = self.dreamRankModel:GetContentWithTab(matchTag)
            if not isHadData then
                local response = req.dreamLeagueMatchRank(matchTag)
                if api.success(response) then
                    self.dreamRankModel:SetContentWithTab(matchTag, response.val.rankList)
                end
            end
        end
        self.view:InitView(self.dreamRankModel)
    end)
end

return DreamRankMainCtrl