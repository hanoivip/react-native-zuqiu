local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamLeagueCardHelper = require("ui.scene.dreamLeague.DreamLeagueCardHelper")
local DreamLeagueCardBaseModel = require("ui.models.dreamLeague.DreamLeagueCardBaseModel")
local AssetFinder = require("ui.common.AssetFinder")

local TeamPlayerItemView = class(unity.base)

function TeamPlayerItemView:ctor()
    self.newFlag = self.___ex.newFlag
    self.enterBtn = self.___ex.enterBtn
    self.quality = self.___ex.quality
    self.playerIcon = self.___ex.playerIcon
    self.playerName = self.___ex.playerName
    self.playerPos = self.___ex.playerPos
end

function TeamPlayerItemView:InitView(data, onPlayerClickCallBack, notShowQualityNum)
    self.data = data
    dreamCardId = data.playerName .. "1"
    self.cardModel = DreamLeagueCardBaseModel.new(dreamCardId)
    local newState = data.listModel:IsAllQualityContainsNewPlayer(data.playerName) or false
    GameObjectHelper.FastSetActive(self.newFlag, newState)
    local playerPageIndex = {}
    playerPageIndex.playerName = data.playerName
    self.enterBtn:regOnButtonClick(function()
        if onPlayerClickCallBack then
            onPlayerClickCallBack(playerPageIndex)
        end
    end)

    for i = 1, 3 do
        local cardQuality = DreamLeagueCardHelper:GetQualityByQualityIndex(i)
        local cardNum = self:GetQualityNum(i)
        self.quality[tostring(i)].text = notShowQualityNum and "" or lang.transstr("dream_quality_text", cardQuality, cardNum)
    end
    local picIcon = self.cardModel:GetPlayerIcon()
    self.playerIcon.overrideSprite = AssetFinder.GetPlayerIcon(picIcon)
    self.playerName.text = self.cardModel:GetName()
    self.playerPos.text = self.cardModel:GetMainPosition()
end

function TeamPlayerItemView:GetQualityNum(index)
    local qualityData = self.data[index]
    local num = 0
    if type(qualityData) == "table" then
        for k,v in pairs(qualityData) do
            num = num + 1
        end
    end
    return num
end

return TeamPlayerItemView
