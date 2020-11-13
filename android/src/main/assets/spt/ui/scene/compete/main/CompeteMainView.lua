local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local BannerCollectionModel = require("ui.models.compete.main.BannerCollectionModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteMainView = class(unity.base)

function CompeteMainView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.btnStore = self.___ex.btnStore
    self.btnReward = self.___ex.btnReward
    self.btnArenaMatch = self.___ex.btnArenaMatch
    self.btnCrossCup1 = self.___ex.btnCrossCup1
    self.btnCrossCup2 = self.___ex.btnCrossCup2
    self.btnIntroduce = self.___ex.btnIntroduce
    self.btnFormation = self.___ex.btnFormation
    self.btnCrossIntroduce = self.___ex.btnCrossIntroduce
    self.btnGuess = self.___ex.btnGuess
    self.scrollEx = self.___ex.scrollEx
    self.season = self.___ex.season
    self.banner1 = self.___ex.banner1
    self.banner2 = self.___ex.banner2
    self.banner1View = self.___ex.banner1View
    self.banner2View = self.___ex.banner2View
    self.hasMailRedPoint = self.___ex.hasMailRedPoint
    --  争霸赛竞猜红点
    self.hasGuessRedPoint = self.___ex.hasGuessRedPoint
    -- 冠军墙
    self.btnChampionWall = self.___ex.btnChampionWall
end

function CompeteMainView:start()
    self.btnFormation:regOnButtonClick(function()
        self:OnBtnFormation()
    end)
    self.btnStore:regOnButtonClick(function()
        self:OnBtnStore()
    end)
    self.btnReward:regOnButtonClick(function()
        self:OnBtnReward()
    end)
    self.btnArenaMatch:regOnButtonClick(function()
        self:OnBtnArenaMatch()
    end)
    self.btnCrossCup1:regOnButtonClick(function()
        self:OnBtnCrossCup1()
    end)
    self.btnCrossCup2:regOnButtonClick(function()
        self:OnBtnCrossCup2()
    end)
    self.btnCrossIntroduce:regOnButtonClick(function()
        self:OnBtnCrossInfo()
    end)
    self.btnIntroduce:regOnButtonClick(function()
        self:OnBtnIntroduce()
    end)
    self.btnGuess:regOnButtonClick(function()
        self:OnBtnGuess()
    end)
    self.btnChampionWall:regOnButtonClick(function()
        self:OnBtnChampionWall()
    end)
    if luaevt.trig("__SGP__VERSION__") or luaevt.trig("__KR__VERSION__") or luaevt.trig("__UK__VERSION__") then
        GameObjectHelper.FastSetActive(self.btnGuess.transform.parent.gameObject, false)
    end
end

function CompeteMainView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.scrollEx.gameObject, isShow)
end

function CompeteMainView:InitView(competeMainModel)
    self.isGuessRed = nil

    self.scrollEx:InitView(competeMainModel)
    self.season.text = competeMainModel:GetMatchSeason() .. lang.transstr("compete_match")

    self:BannerLamp()
end

-- 左边banner是自身相关进程
-- 右边banner是世界排行进程
local WaitPostTime = 8
function CompeteMainView:BannerLamp()
    self.showBanner = true
    local isRefresh = false
    self:coroutine(function()
        while(self.showBanner) do
            local respone = req.competeBanner(nil, nil, true)
            if api.success(respone) then
                local data = respone.val
                local bannerCollectionModel = BannerCollectionModel.new()
                bannerCollectionModel:InitWithProtocol(data.leftBorder)
                local rightBannerCollectionModel = BannerCollectionModel.new()
                rightBannerCollectionModel:InitWithProtocol(data.rightBorder)
                
                if isRefresh then 
                    self.banner1View:RefreshView(bannerCollectionModel, true)
                    self.banner2View:RefreshView(rightBannerCollectionModel, false)
                else
                    self.banner1View:InitView(bannerCollectionModel, true)
                    self.banner2View:InitView(rightBannerCollectionModel, false)
                end
                isRefresh = true
            end
            coroutine.yield(WaitForSeconds(WaitPostTime))
        end
    end)
end

function CompeteMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function CompeteMainView:OnBtnFormation()
    if self.clickFormation then 
        self.clickFormation()
    end
end

function CompeteMainView:OnBtnStore()
    if self.clickStore then 
        self.clickStore()
    end
end

function CompeteMainView:OnBtnReward()
    if self.clickReward then 
        self.clickReward()
    end
end

function CompeteMainView:OnBtnArenaMatch()
    if self.clickArenaMatch then 
        self.clickArenaMatch()
    end
end

function CompeteMainView:OnBtnCrossInfo()
    if self.clickCrossInfo then 
        self.clickCrossInfo()
    end
end

function CompeteMainView:OnBtnIntroduce()
    if self.clickIntroduce then 
        self.clickIntroduce()
    end
end

function CompeteMainView:OnBtnCrossCup1()
    if self.clickCrossCup1 then 
        self.clickCrossCup1()
    end
end

function CompeteMainView:OnBtnCrossCup2()
    if self.clickCrossCup2 then 
        self.clickCrossCup2()
    end
end

function CompeteMainView:OnBtnGuess()
    if self.clickGuess then
        self.clickGuess()
    end
end

function CompeteMainView:OnBtnChampionWall()
    if self.clickChampionWall and type(self.clickChampionWall) == "function" then
        self.clickChampionWall()
    end
end

function CompeteMainView:CompeteStartMatch(competeModel)
    if self.clickStartMatch then 
        self.clickStartMatch(competeModel)
    end
end

function CompeteMainView:CompeteCheckFormation(competeModel)
    if self.clickCheckFormation then 
        self.clickCheckFormation(competeModel)
    end
end

function CompeteMainView:DisplayMailRedPoint()
    if self.displayMailRedPoint then
        self.displayMailRedPoint()
    end
end

-- 争霸赛竞猜红点
function CompeteMainView:DisplayGuessRedPoint()
    if self.displayGuessRedPoint then
        self.displayGuessRedPoint()
    end
end

function CompeteMainView:DisplayGuessRewardRedPoint()
    if self.displayGuessRewardRedPoint then
        self.displayGuessRewardRedPoint()
    end
end

function CompeteMainView:SetGuessRedPoint(isShow)
    -- 两个逻辑控制一个红点，or的关系
    if self.isGuessRed ~= nil then
        self.isGuessRed = self.isGuessRed or isShow
    else
        self.isGuessRed = isShow
    end
    GameObjectHelper.FastSetActive(self.hasGuessRedPoint.gameObject, self.isGuessRed)
end

function CompeteMainView:OnSeasonRankClose()
    if self.onSeasonRankListClose then
        self.onSeasonRankListClose()
    end
end

function CompeteMainView:OnEnterScene()
    EventSystem.AddEvent("CompeteStart_Match", self, self.CompeteStartMatch)
    EventSystem.AddEvent("CompeteCheck_Formation", self, self.CompeteCheckFormation)
    EventSystem.AddEvent("ReqEventModel_worldTournamentEmail", self, self.DisplayMailRedPoint)
    EventSystem.AddEvent("ReqEventModel_worldTournamentGuess", self, self.DisplayGuessRedPoint)
    EventSystem.AddEvent("ReqEventModel_worldTournamentGuessBonus", self, self.DisplayGuessRewardRedPoint)
    EventSystem.AddEvent("Compete_OnSeasonRankClose", self, self.OnSeasonRankClose)
end

function CompeteMainView:OnExitScene()
    EventSystem.RemoveEvent("CompeteStart_Match", self, self.CompeteStartMatch)
    EventSystem.RemoveEvent("CompeteCheck_Formation", self, self.CompeteCheckFormation)
    EventSystem.RemoveEvent("ReqEventModel_worldTournamentEmail", self, self.DisplayMailRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_worldTournamentGuess", self, self.DisplayGuessRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_worldTournamentGuessBonus", self, self.DisplayGuessRewardRedPoint)
    EventSystem.RemoveEvent("Compete_OnSeasonRankClose", self, self.OnSeasonRankClose)
    self.banner1View:OnExitScene()
    self.banner2View:OnExitScene()
    self.showBanner = false
end

return CompeteMainView