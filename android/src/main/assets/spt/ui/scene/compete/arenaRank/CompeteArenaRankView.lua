local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local CompeteArenaRankView = class(unity.base, "CompeteArenaRankView")

local AZMAP = require("ui.models.compete.arenaRank.CompeteArenaRankConstants") 

function CompeteArenaRankView:ctor()
    self.btnBack = self.___ex.btnBack
    self.txtRankBoardTitle = self.___ex.txtRankBoardTitle
    self.rankLabelView = self.___ex.rankLabelView
    self.rankSeasonTabView = self.___ex.rankTabView
    self.currMatchType = self.___ex.currMatchType
    self.myRank = self.___ex.myRank
    self.myScore = self.___ex.myScore
    self.scrollView = self.___ex.scrollView
end

function CompeteArenaRankView:start()
end

function CompeteArenaRankView:InitView(competeArenaRankModel)
    self.model = competeArenaRankModel

    self.btnBack:regOnButtonClick(function()
        if self.onClickBack then
            self.onClickBack()
        end
    end)

    self.rankLabelView:InitView(self.model:GetRankLabel(), self.onClickLabel)    --上侧
    local seasonList = self.model:GetSeasonList()
    if seasonList and next(seasonList) and seasonList[1] then
        cache.setSelectedArenaRabkTabID(tostring(seasonList[1].tag)) --选中第一个tab
    end
    self.rankSeasonTabView:InitView(seasonList, self.onClickTab)        --左侧
    self.model:SetCurrSeasonTag(self:GetSeasonTabSelectedTag())
    self.model:SetCurrLabelTag(self:GetMatchTypeLabelSelectedTag())
    self:InitMyRankArea(self.model:GetCurrSeasonTag())
end

function CompeteArenaRankView:InitRankList()
    self.scrollView:InitView(self.model:GetRankList())
end

function CompeteArenaRankView:InitMyRankArea(season)
    local mySubType = nil
    local myMatchType = self.model:GetCurrMatchType(season)
    if myMatchType == "share_leagueNone" then
        self.currMatchType.text = lang.transstr("share_leagueNone")
        self.myRank.text = lang.transstr("none")
        self.myScore.text = "0"
    else
        if  myMatchType == "compete_match_type5" then
            mySubType = self.model:GetMyRankSubType(season)
        end
        if myMatchType and myMatchType ~= "" then
            self.currMatchType.text = lang.transstr(myMatchType)
        else
            self.currMatchType.text = ""
        end
        if mySubType and self.currMatchType.text and self.currMatchType.text ~= "" then
            self.currMatchType.text = self.currMatchType.text..AZMAP[tostring(mySubType)]        
        end
        if self.model:GetMyRank(season) and tonumber(self.model:GetMyRank(season)) ~= 0 then
            self.myRank.text = tostring(self.model:GetMyRank(season))
        else
            self.myRank.text = lang.transstr("none")
        end
        if self.model:GetMyScore(season) then
            self.myScore.text = tostring(self.model:GetMyScore(season))
        else
            self.myScore.text = "0"
        end
    end  
end

function CompeteArenaRankView:ChangeSeasonTabSelectTag(tag)
    self.rankSeasonTabView:ChangeSelectTag(tag)
end

function CompeteArenaRankView:GetSeasonTabSelectedTag()
    return self.rankSeasonTabView:GetSelectedTag()
end

function CompeteArenaRankView:ChangeMatchTypeLabelSelectTag(tag)
    self.rankLabelView:ChangeSelectTag(tag)
end

function CompeteArenaRankView:GetMatchTypeLabelSelectedTag()
    return self.rankLabelView:GetSelectedTag()
end

function CompeteArenaRankView:RefreshRankLabels()
    self.rankLabelView:ClearTabs()
    self.rankLabelView:InitView(self.model:GetRankLabel(), self.onClickLabel)
end

function CompeteArenaRankView:RefreshRankList()
    self.scrollView:clearData()
    self:InitRankList()
end

return CompeteArenaRankView