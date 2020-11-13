local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local ClothUtils = require("cloth.ClothUtils")

local Model = require("ui.models.Model")
local TeamLogoPic = require("data.TeamLogoPic")
local TeamLogoBoard = require("data.TeamLogoBoard")
local TeamLogoColor = require("data.TeamLogoColor")
local InitTeam = require("data.InitTeam")

local InitTeamMainColor = {"ManutdPlayer", "MancityPlayer", "RealmadridPlayer", "ChelseaPlayer",
                            "LiverpoolPlayer", "BarcelonaPlayer", "BayernPlayer", "ArsenalPlayer",
                            "PsgPlayer", "DortmundPlayer", "InterPlayer", "AcmilanPlayer", "JuventusPlayer",
                            "AtmadridPlayer"}
local TeamLogoModel = class(Model)

TeamLogoModel.Color = table.keys(TeamLogoColor)

TeamLogoModel.BoardColorDict = {}
for k, v in pairs(TeamLogoBoard) do
    TeamLogoModel.BoardColorDict[k] = v.color
end

TeamLogoModel.Board = table.keys(TeamLogoBoard)
TeamLogoModel.Border = {}
TeamLogoModel.Icon = {}
TeamLogoModel.Ribbon = {}

for k, v in pairs(TeamLogoPic) do
    if v["type"] == "frame" then
        table.insert(TeamLogoModel.Border, k)
    elseif v["type"] == "figure" then
        table.insert(TeamLogoModel.Icon, k)
    elseif v["type"] == "ribbon" then
        table.insert(TeamLogoModel.Ribbon, k)
    end
end

TeamLogoModel.InitTeamLogos = {}

-- for k, v in pairs(InitTeam) do
--     local teamLogoInfo = clone(v)
--     teamLogoInfo.id = k
--     table.insert(TeamLogoModel.InitTeamLogos, teamLogoInfo)
-- end

for i, v in ipairs(InitTeamMainColor) do
    local teamLogoInfo = clone(InitTeam[v])
    teamLogoInfo.id = v
    table.insert(TeamLogoModel.InitTeamLogos, teamLogoInfo)
end

-- table.sort(TeamLogoModel.InitTeamLogos, function (a, b)
--     if a.order and b.order then
--         return tonumber(a.order) < tonumber(b.order)
--     else
--         return a.id < b.id
--     end
-- end)

function TeamLogoModel:ctor(data)
    self:Init(data)
end

function TeamLogoModel:Init(data)
    -- TODO:处理数据格式的转换
    self.data = data
end

function TeamLogoModel:IsUserDefined()
    return type(self.data) == "table"
end

function TeamLogoModel:GetTeamId()
    if self:IsUserDefined() then return end
    return self.data
end

function TeamLogoModel:GetTeamLogoId()
    if self:IsUserDefined() then return end
    return tostring(self.data)
end

function TeamLogoModel:GetBoardId()
    if not self:IsUserDefined() then return end
    return self.data.boardId
end

function TeamLogoModel:SetBoardId(id)
    if not self:IsUserDefined() then return end
    self.data.boardId = id
end

function TeamLogoModel:GetBorderId()
    if not self:IsUserDefined() then return end
    return self.data.borderId
end

function TeamLogoModel:SetBorderId(id)
    if not self:IsUserDefined() then return end
    self.data.borderId = id
end

function TeamLogoModel:GetIconId()
    if not self:IsUserDefined() then return end
    return self.data.iconId
end

function TeamLogoModel:SetIconId(id)
    if not self:IsUserDefined() then return end
    self.data.iconId = id
end

function TeamLogoModel:GetRibbonId()
    if not self:IsUserDefined() then return end
    return self.data.ribbonId
end

function TeamLogoModel:SetRibbonId(id)
    if not self:IsUserDefined() then return end
    self.data.ribbonId = id
end

function TeamLogoModel:GetBoardColorId()
    if not self:IsUserDefined() then return end
    return self.data.colorId
end

function TeamLogoModel:SetBoardColorId(id)
    if not self:IsUserDefined() then return end
    self.data.colorId = id
end

function TeamLogoModel:GetBoardColorRed()
    if not self:IsUserDefined() then return end
    local colorString = TeamLogoColor[tostring(self.data.colorId)].redChannel
    if type(colorString) == "string" and colorString ~= "" then
        return ClothUtils.parseColorString(colorString)
    end
end

function TeamLogoModel:GetBoardColorGreen()
    if not self:IsUserDefined() then return end
    local colorString = TeamLogoColor[tostring(self.data.colorId)].greenChannel
    if type(colorString) == "string" and colorString ~= "" then
        return ClothUtils.parseColorString(colorString)
    end
end

function TeamLogoModel:GetBoardColorBlue()
    if not self:IsUserDefined() then return end
    local colorString = TeamLogoColor[tostring(self.data.colorId)].blueChannel
    if type(colorString) == "string" and colorString ~= "" then
        return ClothUtils.parseColorString(colorString)
    end
end

return TeamLogoModel
