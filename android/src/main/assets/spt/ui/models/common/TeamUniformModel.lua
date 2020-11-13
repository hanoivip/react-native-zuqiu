local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local TeamLogoColor = require("data.TeamLogoColor")
local AwayShirt = require("data.AwayShirt")
local GKShirt = require("data.GKShirt")
local ShirtMask = require("data.ShirtMask")
local InitShirt = require("data.InitShirt")
local InitTeam = require("data.InitTeam")
local ClothUtils = require("cloth.ClothUtils")

local Model = require("ui.models.Model")

local TeamUniformModel = class(Model)

TeamUniformModel.UniformType = {
    Home = "homeShirt",
    Away = "awayShirt",
    HomeGk = "homeGkShirt",
    AwayGk = "awayGkShirt",
}

TeamUniformModel.ShirtMask = ShirtMask
TeamUniformModel.InitShirtMask = {}
for k, v in pairs(ShirtMask) do
    if v.initial == 1 then
        table.insert(TeamUniformModel.InitShirtMask, k)
    end
end

-- 计算color1和color2之间的颜色差异值
local function CalcColorDiffValue(color1, color2)
    local h1 = ClothUtils.getHsvFromRgb(color1)
    local h2 = ClothUtils.getHsvFromRgb(color2)
    local diff = math.abs(h1 - h2)
    if diff > 180 then
        diff = 360 - diff
    end
    return diff
end

function TeamUniformModel.GenerateAwayUniformModel(homeModel, randomMask)
    local homeColor = homeModel:GetMaskColorRed()    
    local maxDiffValue = 0
    local maxDiffKey = nil
    for k, v in pairs(AwayShirt) do
        local awayColor = ClothUtils.parseColorString(v.maskRedChannel)
        local diffValue = CalcColorDiffValue(homeColor, awayColor)
        if diffValue > maxDiffValue then
            maxDiffValue = diffValue
            maxDiffKey = k
        end
    end
    if maxDiffKey then
        local data = AwayShirt[maxDiffKey]
        data.shirtName = nil
        if randomMask then
            data.mask = homeModel:GetMask()
        end
        data.mask = string.capital(data.mask)
        return TeamUniformModel.new(data)
    end
end

function TeamUniformModel.GenerateGkUniformModel(model)
    local color = model:GetMaskColorRed()    
    local maxDiffValue = 0
    local maxDiffKey = nil
    for k, v in pairs(GKShirt) do
        local gkColor = ClothUtils.parseColorString(v.maskRedChannel)
        local diffValue = CalcColorDiffValue(color, gkColor)
        if diffValue > maxDiffValue then
            maxDiffValue = diffValue
            maxDiffKey = k
        end
    end
    if maxDiffKey then
        local data = GKShirt[maxDiffKey]
        data.shirtName = nil
        return TeamUniformModel.new(data)
    end
end

function TeamUniformModel.GetHomeUniformColorData(colorId)
    local data = TeamLogoColor[colorId]
    local ret = {
        colorId = colorId,
        trouNumColor = data.trouNumColor,
        backNumColor = data.backNumColor,
        maskRedChannel = data.maskRedChannel,
        maskGreenChannel = data.maskGreenChannel,
        maskBlueChannel = data.maskBlueChannel,
    }
    return ret
end

function TeamUniformModel.GetSpectatorColors(colorId)
    local data = TeamLogoColor[colorId]
    return data.FirstColor, data.SecondColor
end

function TeamUniformModel.GetAwayUniformInitData(id)
    local data = InitShirt[InitTeam[id].awayKit]
    local ret = {
        trouNumColor = data.trouNumColor,
        backNumColor = data.backNumColor,
        maskRedChannel = data.maskRedChannel,
        maskGreenChannel = data.maskGreenChannel,
        maskBlueChannel = data.maskBlueChannel,
        mask = data.mask,
        chestAd = (type(data.chestAd) == "string" and data.chestAd ~= "") and data.chestAd or nil,
    }
    return ret
end

function TeamUniformModel.GetHomeUniformInitData(id)
    local data = InitShirt[InitTeam[id].homeKit]
    local ret = {
        trouNumColor = data.trouNumColor,
        backNumColor = data.backNumColor,
        maskRedChannel = data.maskRedChannel,
        maskGreenChannel = data.maskGreenChannel,
        maskBlueChannel = data.maskBlueChannel,
        mask = data.mask,
        chestAd = (type(data.chestAd) == "string" and data.chestAd ~= "") and data.chestAd or nil,
    }
    return ret
end

function TeamUniformModel.GetSpectators(id)
    local data = InitShirt[InitTeam[id].homeKit]
    local spectators = {
        firstColor = data.FirstColor,
        secondColor = data.SecondColor,
        maskTex = data.MaskTex,
    }
    return spectators
end

function TeamUniformModel.GetSmallTeamUniformId(id)
    return InitTeam[id].small
end

function TeamUniformModel.GetGkSmallTeamUniformId(id)
    return InitTeam[id].gkSmall
end

function TeamUniformModel.GenerateSmallAndGkSmallTeamUniformId()
    local small = math.random(3) * 2 - 1
    local gkSmall = small + 1
    return format("Npc%d", small), format("Npc%d", gkSmall)
end

function TeamUniformModel:ctor(data)
    self.data = data
end

function TeamUniformModel:GetMask()
    return self.data.mask
end

function TeamUniformModel:GetChestAd()
    return self.data.chestAd
end

function TeamUniformModel:GetMaskBlueChannel()
    return self.data.maskBlueChannel
end

function TeamUniformModel:GetMaskRedChannel()
    return self.data.maskRedChannel
end

function TeamUniformModel:GetMaskGreenChannel()
    return self.data.maskGreenChannel
end

function TeamUniformModel:GetBackNumColor()
    return self.data.backNumColor
end

function TeamUniformModel:GetTrouNumColor()
    return self.data.trouNumColor
end

function TeamUniformModel:GetMaskColorRed()
    local colorString = self:GetMaskRedChannel()
    if type(colorString) == "string" and colorString ~= "" then
        return ClothUtils.parseColorString(colorString)
    end
end

function TeamUniformModel:GetMaskColorGreen()
    local colorString = self:GetMaskGreenChannel()
    if type(colorString) == "string" and colorString ~= "" then
        return ClothUtils.parseColorString(colorString)
    end
end

function TeamUniformModel:GetMaskColorBlue()
    local colorString = self:GetMaskBlueChannel()
    if type(colorString) == "string" and colorString ~= "" then
        return ClothUtils.parseColorString(colorString)
    end
end

return TeamUniformModel
