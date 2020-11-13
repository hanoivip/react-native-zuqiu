local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CompeteCrossInfoView = class(unity.base, "CompeteCrossInfoView")

function CompeteCrossInfoView:ctor()
    self.btnBack = self.___ex.btnBack
    self.txtRankBoardTitle = self.___ex.txtRankBoardTitle
    self.rankLabelView = self.___ex.rankLabelView
    self.rankSeasonTabView = self.___ex.rankTabView
    self.scrollView = self.___ex.scrollView
    self.scrollContent = self.___ex.scrollContent

    self.tPreScore1 = self.___ex.tPreScore1
    self.tPreScore2 = self.___ex.tPreScore2
    self.tPreScore3 = self.___ex.tPreScore3
    self.tPreScore4 = self.___ex.tPreScore4
    self.tGoalorAssist = self.___ex.tGoalorAssist
       
    self.tRank = self.___ex.tRank
    self.tName = self.___ex.tName
    self.tDistrict = self.___ex.tDistrict
    self.tTeam = self.___ex.tTeam
    self.tDisRank = self.___ex.tDisRank
    self.tDisName = self.___ex.tDisName
    self.tTotalScore = self.___ex.tTotalScore
end

function CompeteCrossInfoView:start()
end

function CompeteCrossInfoView:InitView(competeCrossInfoModel)
    self.model = competeCrossInfoModel

    self.btnBack:regOnButtonClick(function()
        if self.onClickBack then
            self.onClickBack()
        end
    end)

    self.rankLabelView:InitView(self.model:GetRankLabel(), self.onClickLabel)           --上侧
    local seasonList = self.model:GetSeasonList()
    if seasonList and next(seasonList) and seasonList[1] then
        cache.setSelectedCrossInfoTabID(tostring(seasonList[1].tag))  --选中第一个tab
    end
    self.rankSeasonTabView:InitView(seasonList, self.onClickTab, self.model)        --左侧
end

function CompeteCrossInfoView:InitRankList(matchType)
    local dataList = self.model:GetRankList()
    if tonumber(matchType) == 1 then
        self:ChangeScrollView(true, false, matchType)
    else
        self:ChangeScrollView(false, true, matchType)
    end

    self.scrollView:InitView(dataList)
end

function CompeteCrossInfoView:ChangeScrollView(isDistrict, isOther, matchType)
    self:ChangeScrollTitleView(isDistrict, isOther)
    local fourSeasons = self.model:GetFourSeasons()
    if fourSeasons and next(fourSeasons) then
        for i = 1, 4 do
            if fourSeasons[i] then
                self["tPreScore"..tostring(i)].text = lang.trans("ladder_oldSeasonRank", fourSeasons[i].seasonName)
            else
                self["tPreScore"..tostring(i)].text = "-"
            end
        end
    end

    if tonumber(matchType) == 2 or tonumber(matchType) == 3 then
        self.tGoalorAssist.text = lang.transstr("compete_crossInfo_goalCount")
    elseif tonumber(matchType) == 4 or tonumber(matchType) == 5 then
        self.tGoalorAssist.text = lang.transstr("compete_crossInfo_assist")
    end
end

function CompeteCrossInfoView:ChangeScrollTitleView(isDistrict, isOther)
    GameObjectHelper.FastSetActive(self.tRank, isOther)   --耳朵杯信息标题
    GameObjectHelper.FastSetActive(self.tName, isOther)
    GameObjectHelper.FastSetActive(self.tDistrict, isOther)
    GameObjectHelper.FastSetActive(self.tTeam, isOther)
    GameObjectHelper.FastSetActive(self.tGoalorAssist.gameObject, isOther)

    GameObjectHelper.FastSetActive(self.tDisRank, isDistrict)    --区服积分信息标题
    GameObjectHelper.FastSetActive(self.tDisName, isDistrict)
    GameObjectHelper.FastSetActive(self.tPreScore1.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.tPreScore2.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.tPreScore4.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.tPreScore3.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.tTotalScore, isDistrict)
end

function CompeteCrossInfoView:ChangeSeasonTabSelectTag(tag)
    self.rankSeasonTabView:ChangeSelectTag(tag)
end

function CompeteCrossInfoView:GetSeasonTabSelectedTag()
    return self.rankSeasonTabView:GetSelectedTag()
end

function CompeteCrossInfoView:ChangeMatchTypeLabelSelectTag(tag)
    self.rankLabelView:ChangeSelectTag(tag)
end

function CompeteCrossInfoView:GetMatchTypeLabelSelectedTag()
    return self.rankLabelView:GetSelectedTag()
end

function CompeteCrossInfoView:RefreshRankLabels()
    self.rankLabelView:ClearTabs()
    self.rankLabelView:InitView(self.model:GetRankLabel(), self.onClickLabel)
end

function CompeteCrossInfoView:RefreshRankList(matchType)
    self.scrollView:clearData()
    self:InitRankList(matchType)
end

return CompeteCrossInfoView