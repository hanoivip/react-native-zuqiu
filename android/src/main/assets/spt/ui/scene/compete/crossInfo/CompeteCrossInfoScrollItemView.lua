local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")

local CompeteCrossInfoScrollItemView = class(unity.base, "CompeteCrossInfoScrollItemView")

function CompeteCrossInfoScrollItemView:ctor()
    self.rank = self.___ex.rank    --耳朵杯信息
    self.nameTxt = self.___ex.name
    self.district = self.___ex.district
    self.team = self.___ex.team
    self.goalOrAssist = self.___ex.goalOrAssist

    self.bg = self.___ex.bg

    self.disRank = self.___ex.disRank   --区服积分信息
    self.disName = self.___ex.disName
    self.preScore1 = self.___ex.preScore1
    self.preScore2 = self.___ex.preScore2
    self.preScore3 = self.___ex.preScore3
    self.preScore4 = self.___ex.preScore4
    self.totalScore = self.___ex.totalScore

    self.tRank = self.___ex.tRank     --耳朵杯信息标题
    self.tName = self.___ex.tName
    self.tDistrict = self.___ex.tDistrict
    self.tTeam = self.___ex.tTeam
    self.tGoalorAssist = self.___ex.tGoalorAssist

    self.tDisRank = self.___ex.tDisRank    --区服积分信息标题
    self.tDisName = self.___ex.tDisName
    self.tPreScore1 = self.___ex.tPreScore1
    self.tPreScore2 = self.___ex.tPreScore2
    self.tPreScore4 = self.___ex.tPreScore4
    self.tPreScore3 = self.___ex.tPreScore3
    self.tTotalScore = self.___ex.tTotalScore
end

function CompeteCrossInfoScrollItemView:start()
end

function CompeteCrossInfoScrollItemView:InitView(data)
    self.data = data
    self:ClearScrollItemData()
    if not data.player then
        self:InitScrollItemView(true, false, data)
        self.disRank.text = tostring(data.pos or "-")   --区服积分信息
        self.disName.text = data.serverName or "-"
        local sortedScores = self:SortScoreBySeason(data.score)
        local preNum = 1
        for k, v in pairs(sortedScores) do
            self["preScore"..tostring(preNum)].text = tostring(v)
            preNum = preNum + 1
        end

        self.totalScore.text = tostring(data.totalScores or "-") 
    else
        self:InitScrollItemView(false, true, nil)
        local staticCardModel = StaticCardModel.new(data.cid) 
        self.rank.text = tostring(data.pos or "-")
        self.nameTxt.text = staticCardModel:GetName() or "-"
        self.district.text = data.player.serverName or "-"
        self.team.text = data.player.name or "-"
        self.goalOrAssist.text = tostring(data.count or "-")
    end
    GameObjectHelper.FastSetActive(self.bg, data.index % 2 == 0)
end

function CompeteCrossInfoScrollItemView:GetItemData()
    return self.data
end

function CompeteCrossInfoScrollItemView:ClearScrollItemData()
    self.rank.text = "-"    --耳朵杯信息
    self.nameTxt.text = "-"
    self.district.text = "-"
    self.team.text = "-"
    self.goalOrAssist.text = "-"

    self.disRank.text = "-"   --区服积分信息
    self.disName.text = "-"
    self.preScore1.text = "-"
    self.preScore2.text = "-"
    self.preScore3.text = "-"
    self.preScore4.text = "-"
    self.totalScore.text = "-"
end

function CompeteCrossInfoScrollItemView:SortScoreBySeason(scores)
    local sortedKeys = {}
    local sortedScores = {}
    if scores and next(scores) then
        for k, v in pairs(scores) do
            table.insert(sortedKeys, k)
        end
        table.sort(sortedKeys, function(a, b)
            return tonumber(a) > tonumber(b)
        end)
    end
    for k,v in pairs(sortedKeys) do
        table.insert(sortedScores, scores[v])
    end
    return sortedScores
end

function CompeteCrossInfoScrollItemView:InitScrollItemView(isDistrict, isOther, data)
    GameObjectHelper.FastSetActive(self.disRank.gameObject, isDistrict)   --区服积分信息
    GameObjectHelper.FastSetActive(self.disName.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.preScore1.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.preScore2.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.preScore3.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.preScore4.gameObject, isDistrict)
    GameObjectHelper.FastSetActive(self.totalScore.gameObject, isDistrict)

    GameObjectHelper.FastSetActive(self.rank.gameObject, isOther)    --耳朵杯信息
    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, isOther)
    GameObjectHelper.FastSetActive(self.district.gameObject, isOther)
    GameObjectHelper.FastSetActive(self.team.gameObject, isOther)
    GameObjectHelper.FastSetActive(self.goalOrAssist.gameObject, isOther)
end

return CompeteCrossInfoScrollItemView