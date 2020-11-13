local LadderRankCurrentSeasonCtrl = require("ui.controllers.ladder.LadderRankCurrentSeasonCtrl")
local LadderRankOtherSeasonCtrl = require("ui.controllers.ladder.LadderRankOtherSeasonCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local LadderRankMainCtrl = class(BaseCtrl)

LadderRankMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRankBoard.prefab"

function LadderRankMainCtrl:Init(ladderModel)
    self.ladderModel = ladderModel
    self.ladderRankCurrentSeasonCtrl = LadderRankCurrentSeasonCtrl.new(self.view:GetCurrentSeasonRankBoard())
    self.ladderRankOtherSeasonCtrl = LadderRankOtherSeasonCtrl.new(self.view:GetOtherSeasonRankBoard())
end

function LadderRankMainCtrl:Refresh()
    LadderRankMainCtrl.super.Refresh(self)
    self:InitView()
end

function LadderRankMainCtrl:GetStatusData()
    return self.ladderModel
end

function LadderRankMainCtrl:InitView()
    self:CreateItemList()
    self.view.onBack = function() self:OnBack() end
    self.view:InitView(self.ladderModel)
    self.ladderRankOtherSeasonCtrl:InitView(self.ladderModel)
end

function LadderRankMainCtrl:CreateItemList()
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
    -- 默认进入时更新第一个赛季的服务器信息，否则在第二次进入当前赛季信息时时缺少时间刷新的机制
    self:ClickRankTab(1)
    self:RefreshScrollView()
end

function LadderRankMainCtrl:RefreshScrollView()
    local seasonList = self.ladderModel:GetRankSeasonList()
    self.view.scrollView:clearData()
    for i = 1, #seasonList do
        table.insert(self.view.scrollView.itemDatas, seasonList[i])
    end
    self.view.scrollView:refresh()
end

function LadderRankMainCtrl:ClickRankTab(index)
    local seasonList = self.ladderModel:GetRankSeasonList()
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

function LadderRankMainCtrl:RequestCurRankDataList(seasonType)
    clr.coroutine(function()
        local respone = req.ladderRank(seasonType)
        if api.success(respone) then
            local data = respone.val
            if data.rank then
                self.ladderModel:InitCurRankDataList(data.rank)
            end
            self.ladderModel:InitMySeasonRankInfo(data.self)
            if data.seasonCd then
                self.ladderModel:InitCurSeasonCd(data.seasonCd)
            end
            self.view:InitView(self.ladderModel)
            if seasonType == "season" then
                self.ladderRankCurrentSeasonCtrl:InitView(self.ladderModel)
            else
                self.ladderRankOtherSeasonCtrl:InitView(self.ladderModel)
            end
        end
    end)
end

function LadderRankMainCtrl:OnBack()
    res.PopScene()
end

return LadderRankMainCtrl