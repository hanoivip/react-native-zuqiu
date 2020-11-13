local CardConfig = require("ui.common.card.CardConfig")
local AssetFinder = require("ui.common.AssetFinder")
local SmallCardItem = class(unity.base)

function SmallCardItem:ctor()
    self.quality = self.___ex.quality
    self.playerIcon = self.___ex.playerIcon
end

function SmallCardItem:start()

end

function SmallCardItem:SetCardResourceCache(resourceCache)
    self.resourceCache = resourceCache
end

function SmallCardItem:InitView(cardModel)
    local quality = cardModel:GetCardQuality()
    -- 品质
    self:SetQualityCard(quality)
    -- 头像
    self:SetCardAvatar(cardModel:GetAvatar())
end

-- 设置卡牌品质框
function SmallCardItem:SetQualityCard(quality)
    local qualityRes = AssetFinder.GetCardAvatarBox(quality)
    self.quality.overrideSprite = qualityRes
end

function SmallCardItem:SetCardAvatar(avatar)
    local avatarRes = AssetFinder.GetPlayerIcon(avatar)
    self.playerIcon.overrideSprite = avatarRes
end

return SmallCardItem
