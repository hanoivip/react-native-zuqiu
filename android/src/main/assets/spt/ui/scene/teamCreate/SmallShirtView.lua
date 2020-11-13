local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local ClothUtils = require("cloth.ClothUtils")

local SmallShirtView = class(LuaButton)

function SmallShirtView:ctor()
    SmallShirtView.super.ctor(self)
    self.image = self.___ex.image
    self.bgImage = self.___ex.bgImage
    self.UIClothBase = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/UISmallCloth/UIClothBase.mat")
    EventSystem.AddEvent("SetShirtBG", self, self.InitShirtBG)
end

function SmallShirtView:Init(data)
    self.data = data
    local mat = Object.Instantiate(self.UIClothBase)
    local mask = 1
    local maskName = "Small" .. data.mask
    local maskPath = "Assets/CapstonesRes/Game/UI/Common/UISmallCloth/Mask/" .. maskName .. "/" .. maskName .. ".png"
    mat:SetTexture("_Mask", res.LoadRes(maskPath))
    mat:SetColor("_MaskRedChannel", ClothUtils.parseColorString(data.maskRedChannel))
    mat:SetColor("_MaskGreenChannel", ClothUtils.parseColorString(data.maskGreenChannel))
    mat:SetColor("_MaskBlueChannel", ClothUtils.parseColorString(data.maskBlueChannel))

    self.image.material = mat
    self.image.sprite = clr.null
end

function SmallShirtView:InitShirtBG(spt)
    GameObjectHelper.FastSetActive(self.bgImage, spt == self)
end

function SmallShirtView:onDestroy()
    EventSystem.RemoveEvent("SetShirtBG", self, self.InitShirtBG)
end

return SmallShirtView
