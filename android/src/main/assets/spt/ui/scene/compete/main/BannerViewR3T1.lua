local BannerViewBase = require("ui.scene.compete.main.BannerViewBase")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local BannerViewR3T1 = class(BannerViewBase)

function BannerViewR3T1:ctor()
    BannerViewR3T1.super.ctor(self)
    self.rank1 = self.___ex.rank1
    self.rank2 = self.___ex.rank2
    self.rank3 = self.___ex.rank3
    self.team1 = self.___ex.team1
    self.team2 = self.___ex.team2
    self.team3 = self.___ex.team3
    self.score1 = self.___ex.score1
    self.score2 = self.___ex.score2
    self.score3 = self.___ex.score3
    self.sign1 = self.___ex.sign1
    self.sign2 = self.___ex.sign2
    self.sign3 = self.___ex.sign3
end

function BannerViewR3T1:InitView(bannerCollectionModel, typeIndex, index)
    local content = bannerCollectionModel:GetCollectionContent(typeIndex, index)
    local sortList = content.sortList or {}
    for i = 1, 3 do
        GameObjectHelper.FastSetActive(self["sign" .. i].gameObject, false)
    end
    for i, v in ipairs(sortList) do
        if i <= 3 then 
            self["rank" .. i].text = tostring(v.rank)
            self["team" .. i].text = tostring(v.name)
            self["score" .. i].text = tostring(v.score)
            self:InitCompeteSign(i, v.worldTournamentLevel)
        end
    end

    self:SetTitle(content.season, content.matchType, content.server)
end

function BannerViewR3T1:InitCompeteSign(i, worldTournamentLevel)
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self["sign" .. i].gameObject, true)
            self["sign" .. i].overrideSprite = AssetFinder.GetCompeteSign(signData.path)
        else
            GameObjectHelper.FastSetActive(self["sign" .. i].gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self["sign" .. i].gameObject, false)
    end
end

return BannerViewR3T1