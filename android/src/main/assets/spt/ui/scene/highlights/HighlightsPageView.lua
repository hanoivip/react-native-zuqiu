local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local HighlightsPageView = class(unity.base)

function HighlightsPageView:ctor()
    self.animator = self.___ex.animator
    self.scrollView = self.___ex.scrollView
    self.btnPlayback = self.___ex.btnPlayback
    self.btnRecord = self.___ex.btnRecord
    self.homeTeamNameText = self.___ex.homeTeamNameText
    self.awayTeamNameText = self.___ex.awayTeamNameText
    self.scoreText = self.___ex.scoreText
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamLogo = self.___ex.awayTeamLogo
    self.allIndexArray = {}
    self.dataList = {}
    self.selectIndexArray = {}
    self.settlementPageView = nil
    self.matchInfoModel = nil
end

function HighlightsPageView:InitView(playerTeamData, awayTeamData, settlementPageView)
    self.playerTeamData = playerTeamData
    self.awayTeamData = awayTeamData
    self.settlementPageView = settlementPageView
    self:BuildScrollData()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    
    self:BuildScoreArea(self.playerTeamData, self.awayTeamData)
    self:CreateItemList()
end

function HighlightsPageView:start()
    self:BindAll()
end

function HighlightsPageView:BindAll()
    self.btnPlayback:regOnButtonClick(function()
        self.selectIndexArray = {}
        for i, v in ipairs(self.dataList) do
            if v.isSelected then
                table.insert(self.selectIndexArray, i)
            end
        end
        if #self.selectIndexArray > 0 then
            ___playbackManager:StartPlaybackMatchHighlights(self.selectIndexArray, function()
                ___matchUI:onPlaybackMatchHighlightsEnd()
                self:start()
            end)
        end
    end)

    self.btnRecord:regOnButtonClick(function()
        -- TODO 暂时做“继续”按钮用，需要跟策划重新讨论这个UI的逻辑
        EventSystem.SendEvent("SettlementPageView.ExitScene")
        -- TODO 录屏功能，ShareREC方案
        -- luaevt.trig("SDK_ShareREC_InitRecorder", "1dd00a083a280", "9a3288e832e017949b578a037513158e")
        -- luaevt.trig("SDK_ShareREC_SetMaxFrameSize", "LEVEL_1280_720")
        -- luaevt.trig("SDK_ShareREC_SetVideoQuality", "LEVEL_HIGH")
        -- luaevt.trig("SDK_ShareREC_SetMinDuration", 5 * 1000)
        -- luaevt.trig("SDK_ShareREC_SetCacheFolder", "/sdcard/hmzqfy/cvr/")
        -- luaevt.trig("SDK_ShareREC_Start")
    end)    

    self.scrollView.onScrollCreateItem = function(spt, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Highlights/HighlightsItemBar.prefab")
        return obj, spt
    end
    self.scrollView.onScrollResetItem = function(spt, index)
        local data = self.scrollView.itemDatas[index]
        spt:InitView(data, index)
        self.scrollView:updateItemIndex(spt, index)
    end
end

function HighlightsPageView:CreateItemList()
    self:RefreshScrollView()
end

function HighlightsPageView:RefreshScrollView()
    local dataList = self:GetDataList()
    self.scrollView:clearData()
    for i = 1, #dataList do
        table.insert(self.scrollView.itemDatas, dataList[i])
    end
    self.scrollView:refresh()
end

function HighlightsPageView:BuildScrollData()
    local matchHighlightsData = ___playbackManager:GetMatchHighlightsData()

    for i, v in ipairs(matchHighlightsData) do
        local data = {}
        data.goalCount = v.goalCount
        data.goalTime = v.goalTime
        data.isFromLeftToRight = v.isFromLeftToRight
        data.isSelf = ___matchUI:isPlayer(v.goalPlayer)
        data.isSelected = false
        data.goalPlayer = ___matchUI:getAthlete(v.goalPlayer)
        table.insert(self.dataList, data)
    end
end

function HighlightsPageView:GetDataList()
    return self.dataList
end

function HighlightsPageView:BuildScoreArea(playerTeamData, awayTeamData)
    self.scoreText.text = self.settlementPageView:GetMatchScoreText()
    self.settlementPageView:SetTeamName(self.homeTeamNameText, playerTeamData.teamName)
    self.settlementPageView:SetTeamName(self.awayTeamNameText, awayTeamData.teamName)
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamLogo, playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.awayTeamLogo, awayTeamData.logo)
end

return HighlightsPageView