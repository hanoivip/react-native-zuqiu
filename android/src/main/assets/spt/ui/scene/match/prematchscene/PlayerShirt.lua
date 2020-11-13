local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Texture = Texture

local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local MatchConstants = require("ui.scene.match.MatchConstants")
local AssetFinder = require("ui.common.AssetFinder")
local ClothUtils = require("cloth.ClothUtils")
local MatchUseShirtType = require("coregame.MatchUseShirtType")

local PlayerShirt = class(unity.base)

PlayerShirt.clothMaterialMap = {}

function PlayerShirt:ctor()
    -- 号码
    self.number = self.___ex.number
    -- 衬衫图像
    self.shirtImage = self.___ex.shirtImage
    -- 球员名称
    self.nameText = self.___ex.nameText
    -- 球员数据
    self.athleteData = nil
    -- 球队数据
    self.teamData = nil

    self.UIClothBase = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/UISmallCloth/UIClothBase.mat")
end

function PlayerShirt:InitView(athleteData, teamData)
    self.athleteData = athleteData
    self.teamData = teamData
    self:BuildView()
end

function PlayerShirt:BuildView()
    self.number.text = tostring(self.athleteData.number)
    self.nameText.text = self.athleteData.name

    if tonumber(self.athleteData.role) == MatchConstants.SpecificPosNum.GOALKEEPER_POS then
        local gkShirt = self.teamData.currentUseGKShirt
        local shirtKey = tostring(gkShirt)
        if PlayerShirt.clothMaterialMap[shirtKey] == nil or PlayerShirt.clothMaterialMap[shirtKey] == clr.null then
            local mat = Object.Instantiate(self.UIClothBase)
            local maskName = "Small" .. gkShirt.mask
            local maskPath = "Assets/CapstonesRes/Game/UI/Common/UISmallCloth/Mask/" .. maskName .. "/" .. maskName .. ".png"
            mat:SetTexture("_Mask", res.LoadRes(maskPath))
            mat:SetColor("_MaskRedChannel", ClothUtils.parseColorString(gkShirt.maskRedChannel))
            mat:SetColor("_MaskGreenChannel", ClothUtils.parseColorString(gkShirt.maskGreenChannel))
            mat:SetColor("_MaskBlueChannel", ClothUtils.parseColorString(gkShirt.maskBlueChannel))
            PlayerShirt.clothMaterialMap[shirtKey] = mat
        end

        self.shirtImage.material = PlayerShirt.clothMaterialMap[shirtKey]
        self.shirtImage.sprite = clr.null
    else
        if type(self.teamData.specificTeam) == "string" and self.teamData.useShirtType ~= MatchUseShirtType.BACKUP then
            local SpecificTeamData = require("cloth.SpecificTeamData")
            self.shirtImage.material = clr.null
            self.shirtImage.overrideSprite = res.LoadRes(SpecificTeamData[self.teamData.specificTeam].resMap[self.teamData.useShirtType].smallCloth)
        else
            local shirt = self.teamData.currentUseShirt
            local shirtKey = tostring(shirt)
            if PlayerShirt.clothMaterialMap[shirtKey] == nil or PlayerShirt.clothMaterialMap[shirtKey] == clr.null then
                local mat = Object.Instantiate(self.UIClothBase)
                local maskName = "Small" .. shirt.mask
                local maskPath = "Assets/CapstonesRes/Game/UI/Common/UISmallCloth/Mask/" .. maskName .. "/" .. maskName .. ".png"
                mat:SetTexture("_Mask", res.LoadRes(maskPath))
                mat:SetColor("_MaskRedChannel", ClothUtils.parseColorString(shirt.maskRedChannel))
                mat:SetColor("_MaskGreenChannel", ClothUtils.parseColorString(shirt.maskGreenChannel))
                mat:SetColor("_MaskBlueChannel", ClothUtils.parseColorString(shirt.maskBlueChannel))
                PlayerShirt.clothMaterialMap[shirtKey] = mat
            end

            self.shirtImage.material = PlayerShirt.clothMaterialMap[shirtKey]
            self.shirtImage.sprite = clr.null
        end
    end
end

function PlayerShirt:onDestroy()
    PlayerShirt.clothMaterialMap = {}
end

return PlayerShirt
