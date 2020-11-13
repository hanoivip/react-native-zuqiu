local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local GuildPowerItemView = class(unity.base)

function GuildPowerItemView:ctor()
    self.nameTxt = self.___ex.name
    self.logo = self.___ex.logo
    self.first = self.___ex.first
    self.second = self.___ex.second
    self.third = self.___ex.third
    self.normal = self.___ex.normal
    self.rankList = {self.first, self.second, self.third}
    self.btnDetail = self.___ex.btnDetail
    self.levelTxt = self.___ex.levelTxt
    self.rankTxt = self.___ex.rankTxt
    self.winTimeTxt = self.___ex.winTimeTxt
    self.captureTimeTxt = self.___ex.captureTimeTxt
    self.resizeTimeTxt = self.___ex.resizeTimeTxt
    self.mistNameGo = self.___ex.mistNameGo
    self.commonNameGo = self.___ex.commonNameGo
end

function GuildPowerItemView:start()
    self.btnDetail:regOnButtonClick(function()
        if type(self.onBtnDetailClick) == "function" then
            self.onBtnDetailClick()
        end
    end)
end

function GuildPowerItemView:InitView(itemModel)
    self.itemModel = itemModel
    self.logo.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. itemModel:GetEid())
    self.nameTxt.text = itemModel:GetName()
    if itemModel:GetIsMySelf() then
        self.nameTxt.text = "<color=#FAEB46FF>" .. itemModel:GetName() .. "</color>"
    end
    local rankOrder = itemModel:GetRank()
    local isCommon = itemModel:IsCommon()
    GameObjectHelper.FastSetActive(self.mistNameGo, not isCommon)
    GameObjectHelper.FastSetActive(self.commonNameGo, isCommon)
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
    self.levelTxt.text = itemModel:GetLevel()
    self.rankTxt.text = tostring(itemModel:GetBestRank())
    self.winTimeTxt.text = itemModel:GetWinTime()
    self.captureTimeTxt.text = itemModel:GetCaptureTime()
    self.resizeTimeTxt.text = itemModel:GetResizeTime()
end

function GuildPowerItemView:onDestroy()
end

return GuildPowerItemView
