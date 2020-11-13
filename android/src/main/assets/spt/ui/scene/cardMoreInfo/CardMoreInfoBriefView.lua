local AssetFinder = require("ui.common.AssetFinder")
local CardMoreInfoBriefView = class(unity.base)

function CardMoreInfoBriefView:ctor()
    self.nameTxt = self.___ex.name
    self.englishName = self.___ex.englishName
    self.nation = self.___ex.nation
    self.nationIcon = self.___ex.nationIcon
    self.height = self.___ex.height
    self.birth = self.___ex.birth
    self.desc = self.___ex.desc
end

function CardMoreInfoBriefView:InitView(cardModel)
    self.nameTxt.text = tostring(cardModel:GetName())
    self.englishName.text = tostring(cardModel:GetNameByEnglish())
    self.nation.text = tostring(cardModel:GetNationName())
    self.height.text = tostring(cardModel:GetHeight())
    self.birth.text = tostring(cardModel:GetBirthday())
    self.desc.text = tostring(cardModel:GetProfile())
    local nationRes = AssetFinder.GetNationIcon(cardModel:GetNation())
    self.nationIcon.overrideSprite = nationRes
end

return CardMoreInfoBriefView
