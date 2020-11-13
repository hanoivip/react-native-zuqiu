local Model = require("ui.models.Model")
local DreamRankModel = class(Model, "DreamRankModel")

function DreamRankModel:InitWithProtocol(data)
    self.data = data
    self.cacheData = {}
    self.cacheData.tabContent = {}
    self:InitRankTabList()
end

-- 获得赛季排行
function DreamRankModel:GetSeasonRankList()
    return self.data.rankList
end

-- 初始化tab内容
function DreamRankModel:InitRankTabList()
    self.cacheData.tabList = {
        {
            name = lang.trans("dream_season_rank"),
            isSelect = true,
            matchTag = "current"
        }
    }

    table.sort(self.data.matchTags, function (a, b)
        return a.time > b.time
    end)

    for k, v in pairs(self.data.matchTags) do
        local seasonData = {}
        local matchDate = string.convertSecondToYearAndMonthAndDay(v.time)
        local date = matchDate.year .. "/" .. matchDate.month .. "/" .. matchDate.day
        seasonData.name = date
        seasonData.matchTag = tostring(v.matchTag)
        seasonData.isSelect = false

        table.insert(self.cacheData.tabList, seasonData)
    end

    -- 初始化当前赛季排行
    self.cacheData.tabContent["current"] = self.data.rankList
end

function DreamRankModel:GetRankTabList()
    return self.cacheData.tabList
end

-- 获得某个赛季的内容，如果没有，则向服务器请求
function DreamRankModel:GetContentWithTab(tab)
    return self.cacheData.tabContent[tab]
end

function DreamRankModel:SetContentWithTab(tab, content)
    self.cacheData.tabContent[tab] = content
end

return DreamRankModel
