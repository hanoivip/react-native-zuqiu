local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Object = UnityEngine.Object
local Helper = require("ui.scene.formation.Helper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamUniformModel  = require("ui.models.common.TeamUniformModel")
local ClothUtils = require("cloth.ClothUtils")
local MatchUseShirtType = require("coregame.MatchUseShirtType")

local FormationItemShirtView = class(unity.base)

FormationItemShirtView.clothMaterialMap = {}

function FormationItemShirtView:ctor()
    self.shirtImage = self.___ex.shirtImage
    self.UIClothBase = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/UISmallCloth/UIClothBase.mat")
    self.gkPosIndex = 11
end

function FormationItemShirtView:InitView(posIndex)
    local playerInfoModel = PlayerInfoModel.new()

    local shirt = nil
    if posIndex == self.gkPosIndex then
        shirt = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.HomeGk)
        local shirtKey = tostring(shirt)
        if FormationItemShirtView.clothMaterialMap[shirtKey] == nil or FormationItemShirtView.clothMaterialMap[shirtKey] == clr.null then
            local mat = Object.Instantiate(self.UIClothBase)
            local maskName = "Small" .. shirt.mask
            local maskPath = "Assets/CapstonesRes/Game/UI/Common/UISmallCloth/Mask/" .. maskName .. "/" .. maskName .. ".png"
            mat:SetTexture("_Mask", res.LoadRes(maskPath))
            mat:SetColor("_MaskRedChannel", ClothUtils.parseColorString(shirt.maskRedChannel))
            mat:SetColor("_MaskGreenChannel", ClothUtils.parseColorString(shirt.maskGreenChannel))
            mat:SetColor("_MaskBlueChannel", ClothUtils.parseColorString(shirt.maskBlueChannel))
            FormationItemShirtView.clothMaterialMap[shirtKey] = mat
        end

        self.shirtImage.material = FormationItemShirtView.clothMaterialMap[shirtKey]
        self.shirtImage.sprite = clr.null
    else
        if playerInfoModel:IsUseSpecificTeam() then
            local specificTeam = playerInfoModel:GetSpecificTeam()
            local SpecificTeamData = require("cloth.SpecificTeamData")
            self.shirtImage.material = clr.null
            self.shirtImage.overrideSprite = res.LoadRes(SpecificTeamData[specificTeam].resMap[MatchUseShirtType.HOME].smallCloth)
        else
            shirt = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Home)
            local shirtKey = tostring(shirt)
            if FormationItemShirtView.clothMaterialMap[shirtKey] == nil or FormationItemShirtView.clothMaterialMap[shirtKey] == clr.null then
                local mat = Object.Instantiate(self.UIClothBase)
                local maskName = "Small" .. shirt.mask
                local maskPath = "Assets/CapstonesRes/Game/UI/Common/UISmallCloth/Mask/" .. maskName .. "/" .. maskName .. ".png"
                mat:SetTexture("_Mask", res.LoadRes(maskPath))
                mat:SetColor("_MaskRedChannel", ClothUtils.parseColorString(shirt.maskRedChannel))
                mat:SetColor("_MaskGreenChannel", ClothUtils.parseColorString(shirt.maskGreenChannel))
                mat:SetColor("_MaskBlueChannel", ClothUtils.parseColorString(shirt.maskBlueChannel))
                FormationItemShirtView.clothMaterialMap[shirtKey] = mat
            end

            self.shirtImage.material = FormationItemShirtView.clothMaterialMap[shirtKey]
            self.shirtImage.sprite = clr.null
        end
    end
end

function FormationItemShirtView:SetPos(numberPos, formationId, courtSize)
    local posCoords = Helper.GetPos(numberPos, formationId, false, true)
    self.transform.localPosition = Vector3(posCoords.x * courtSize.x, posCoords.y * courtSize.y, 0)
end

function FormationItemShirtView:onDestroy()
    FormationItemShirtView.clothMaterialMap = {}
end

return FormationItemShirtView
