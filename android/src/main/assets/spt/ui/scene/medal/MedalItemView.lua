local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MedalItemView = class(unity.base)

function MedalItemView:ctor()
    self.boxQuality = self.___ex.boxQuality
    self.medalQuality = self.___ex.medalQuality
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
    self.selectBorder = self.___ex.selectBorder
    self.btnMedalItem = self.___ex.btnMedalItem
    self.equiped = self.___ex.equiped
    self.new = self.___ex.new

    self.btnMedalItem:regOnButtonClick(function() self:OnClickMedal() end)
end

function MedalItemView:OnClickMedal()
    if self.clickMedal then
        self.clickMedal(self.medalModel, self.index)
    end
    if self.new ~= nil and self.isNew then
        self.medalModel:SetNew(false)
        self.isNew = false
        GameObjectHelper.FastSetActive(self.new.gameObject, false)
    end
end

function MedalItemView:InitView(medalModel, index, selectMedalIndex)
    self.medalModel = medalModel
    self.index = index
    local quality = medalModel:GetQuality()
    self.medalQuality.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/Medal_Quality" .. quality .. ".png")
    local boxQuality = medalModel:GetBoxQuality()
    self.boxQuality.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/ItemQualityBoard/quality_board" .. boxQuality .. ".png")
    local picIndex = medalModel:GetPic()
    self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/Medal/" .. picIndex .. ".png")
    self.nameTxt.text = medalModel:GetName()
    
    local hasBroken = medalModel:HasBroken()
    local brokenColor = hasBroken and 0 or 1
    self.boxQuality.color = Color(brokenColor, 1, 1)
    self.medalQuality.color = Color(brokenColor, 1, 1)
    local isSelect = tobool(index == selectMedalIndex)
    self:IsSelect(isSelect)
    self.hasEquiped = medalModel:HasEquiped()
    self.isNew = medalModel:IsNew()

    if self.equiped then
        GameObjectHelper.FastSetActive(self.equiped.gameObject, self.hasEquiped)
    end
    if self.new then
        GameObjectHelper.FastSetActive(self.new.gameObject, self.isNew)
    end
end

function MedalItemView:IsSelect(isSelect)
    if self.selectBorder then 
        GameObjectHelper.FastSetActive(self.selectBorder.gameObject, isSelect)
    end
end

function MedalItemView:ClearName()
    self.nameTxt.text = ""
end

function MedalItemView:UpdateItemIndex(index)
    self.index = index
end

return MedalItemView
