local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")

local GuildRankingItemView = class(unity.base)

function GuildRankingItemView:ctor()
    self.nameTxt = self.___ex.name
    self.logo = self.___ex.logo
    self.contribute = self.___ex.contribute
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.third = self.___ex.third
    self.normal = self.___ex.normal
    self.rankList = {self.first, self.second, self.third}
    self.btnDetail = self.___ex.btnDetail
end

function GuildRankingItemView:start()
    self.btnDetail:regOnButtonClick(function()
        if type(self.onBtnDetailClick) == "function" then
            self.onBtnDetailClick()
        end
    end)
end

function GuildRankingItemView:InitView(itemModel)
    self.itemModel = itemModel
    self.logo.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. itemModel:GetEid())
    self.nameTxt.text = itemModel:GetName()
    if itemModel:GetIsMySelf() then
        self.nameTxt.text = "<color=#FAEB46FF>" .. itemModel:GetName() .. "</color>"
    end
    self.contribute.text = tostring(itemModel:GetThreeContribute())
    local rankOrder = itemModel:GetRank()
    if rankOrder < 4 then
        for i = 1, 3 do
            if rankOrder == i then
                self.rankList[i]:SetActive(true)
            else
                self.rankList[i]:SetActive(false)
            end
        end
        self.normal.gameObject:SetActive(false)
    else
        for i = 1, 3 do
            self.rankList[i]:SetActive(false)
        end
        self.normal.gameObject:SetActive(true)
        self.normal.text = tostring(rankOrder)
    end
end

function GuildRankingItemView:onDestroy()
end

return GuildRankingItemView
