local GameObjectHelper = require("ui.common.GameObjectHelper")
local MedalView = class(unity.base)

function MedalView:ctor()
    self.border = self.___ex.border
    self.icon = self.___ex.icon
    self.strengthenIcon = self.___ex.strengthenIcon
    self.unEquipSign = self.___ex.unEquipSign
    self.equipSign = self.___ex.equipSign
    self.btnMedal = self.___ex.btnMedal
    self.effect = self.___ex.effect
end

function MedalView:InitView(pos, isFull, medalSingleModel)
    self.border.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Medal_Border" .. pos ..".png")
    self.border:SetNativeSize()

    local hasMedal = false
    local hasStrength = false
    if medalSingleModel then 
        hasMedal = true
        local picIndex = medalSingleModel:GetPic()
        self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex ..".png")
        local state = medalSingleModel:GetBenedictionState()
        if state > 0 then 
            hasStrength = true
            self.strengthenIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Benediction" .. state ..".png")
        end
        GameObjectHelper.FastSetActive(self.effect, state == 3)
    else
        self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Medal/Medal_Default" .. pos ..".png")
    end
    self.icon:SetNativeSize()

    GameObjectHelper.FastSetActive(self.unEquipSign, not hasMedal and isFull)
    GameObjectHelper.FastSetActive(self.equipSign, not isFull and not hasMedal)
    GameObjectHelper.FastSetActive(self.strengthenIcon.gameObject, hasStrength)
end

return MedalView
