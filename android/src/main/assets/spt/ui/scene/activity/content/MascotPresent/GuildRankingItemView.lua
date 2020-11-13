local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildRankingItemView = class(unity.base)

function GuildRankingItemView:ctor()
    self.nameTxt = self.___ex.name
    self.logo = self.___ex.logo
    self.contribute = self.___ex.contribute
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.third = self.___ex.third
    self.normal = self.___ex.normal
    self.pointValue = self.___ex.pointValue
    self.rankList = {self.first, self.second, self.third}
    self.btnDetail = self.___ex.btnDetail
    self.guildInfoObj = self.___ex.guildInfoObj
    self.pointTipObj = self.___ex.pointTipObj
    self.pointTipTxt = self.___ex.pointTipTxt
end

function GuildRankingItemView:start()
    self.btnDetail:regOnButtonClick(function()
        if type(self.onBtnDetailClick) == "function" then
            self.onBtnDetailClick()
        end
    end)
end

local iconMaxRankingNum = 3
function GuildRankingItemView:InitView(itemModel, mascotPresentModel)
    self.itemModel = itemModel
    self.activityModel = mascotPresentModel
    local rankOrder = tonumber(itemModel:GetRank())
    --排名为1/2/3时显示图片，大于3时显示数字
    for i = 1, iconMaxRankingNum do
        GameObjectHelper.FastSetActive(self.rankList[i], rankOrder == i)
    end
    GameObjectHelper.FastSetActive(self.normal.gameObject, rankOrder > iconMaxRankingNum)
    self.normal.text = tostring(rankOrder)

    local isUpToPointStandard = self.itemModel:IsUpToPointStandard()
    GameObjectHelper.FastSetActive(self.guildInfoObj, isUpToPointStandard)
    GameObjectHelper.FastSetActive(self.pointTipObj, not isUpToPointStandard)
    if not isUpToPointStandard then
        local standardPoint = self.activityModel:GetStandardPointValueByRanking(rankOrder)
        self.pointTipTxt.text = lang.transstr("mascotPresent_add1", standardPoint)
        return
    end

    self.logo.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. tostring(itemModel:GetEid()))
    self.nameTxt.text = tostring(itemModel:GetName())
    if itemModel:GetIsMySelf() then
        self.nameTxt.text = "<color=#FAEB46FF>" .. tostring(itemModel:GetName()) .. "</color>"
    end
    self.pointValue.text = tostring(itemModel:GetPointValue())
   
end

function GuildRankingItemView:onDestroy()
end

return GuildRankingItemView
