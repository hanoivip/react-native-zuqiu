local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LoginModel = require("ui.models.login.LoginModel")
local RankingItemView = class(unity.base)

function RankingItemView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.nameText = self.___ex.nameText
    self.districtText = self.___ex.districtText
    self.pointsText = self.___ex.pointsText
    self.normalRank = self.___ex.normalRank
    self.normalRankText = self.___ex.normalRankText
    self.bg = self.___ex.bg

    self.mapServers = {}
    self:MakeMapOfServers()
end

function RankingItemView:MakeMapOfServers()
    local servers = LoginModel.GetServers()
    for k, v in pairs(servers) do
        self.mapServers[tostring(v.id)] = v.displayId       
    end
end

function RankingItemView:InitView(model, index)
    self.data = model
    if not self.data or type(self.data) ~= "table" then return end
    GameObjectHelper.FastSetActive(self.bg, index % 2 == 0)

    self:SetRankShowStatus(self.data.rank == 1, self.data.rank == 2, self.data.rank == 3)
    if self.data.rank > 3 then self.normalRankText.text = tostring(self.data.rank) end

    local name = ""
    local district = ""
    if self.data.ext then
        name = self.data.ext.name and self.data.ext.name or ""
        district = self.data.p_s_id or ""
        district = string.sub(district, #district, #district)
    else
        name = self.data.name or ""
        district = tostring(self.data.serverId or "")
    end
    district = self.mapServers[district] or ""
    self.nameText.text = name
    self.districtText.text = district
    self.pointsText.text = tostring(self.data.score or 0)
end

function RankingItemView:SetRankShowStatus(isFirstRank, isSecondRank, isThirdRank)
    GameObjectHelper.FastSetActive(self.firstRank, isFirstRank)
    GameObjectHelper.FastSetActive(self.secondRank, isSecondRank)
    GameObjectHelper.FastSetActive(self.thirdRank, isThirdRank)
    GameObjectHelper.FastSetActive(self.normalRank, not (isFirstRank or isSecondRank or isThirdRank))
end

return RankingItemView