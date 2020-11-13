local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector3 = UnityEngine.Vector3
local SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
local MeshRenderer = UnityEngine.MeshRenderer

local PlayerReplacer = require("coregame.PlayerReplacer")
local BaseTexGenerator = require("cloth.BaseTexGenerator")
local NameNumGenerator = require("cloth.NameNumGenerator")
local ClothUtils = require("cloth.ClothUtils")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local HomeShirt = require("data.HomeShirt")
local AwayShirt = require("data.AwayShirt")
local GKShirt = require("data.GKShirt")

local WeatherConstParams = require("coregame.WeatherConstParams")
local PlayerModelConstructer = require("coregame.PlayerModelConstructer")
local SpecificTeamData = require("cloth.SpecificTeamData")
local MatchUseShirtType = require("coregame.MatchUseShirtType")

local PlayerManager = class(unity.base)

function PlayerManager:ctor()
    self.players = {}
    self.opponents = {}
    self.referees = {}
    for i = 1, 11 do
        self.players[i] = self.___ex["player" .. i]
    end
    for i = 1, 11 do
        self.opponents[i] = self.___ex["opponent" .. i]
    end
    for i = 1, 4 do
        self.referees[i] = self.___ex["referee" .. i]
    end
    self.kitFontTexture = self.___ex.kitFontTexture
    self.kitFont = self.___ex.kitFont

    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    self.opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    self.baseInfo = self.matchInfoModel:GetBaseInfo()

    self.skipOpeningButton = self.___ex.skipOpeningButton

    self.playersSomatoMap = {}
    self.opponentsSomatoMap = {}
end

function PlayerManager:onDestroy()
    self.nameNumTexture = nil
    self.clothTexture = nil
    self.gkClothTexture = nil
end

function PlayerManager:start()
    if self.playerTeamData then
        self:initMesh()
        self:initKit()
    end
end

function PlayerManager:ChangeBodyMesh(meshTable)
    for k, v in pairs(self.playersSomatoMap) do
        local player = self.players[k]
        player.transform:FindChild("body"):GetComponent(SkinnedMeshRenderer).sharedMesh = meshTable[v]
    end
    for k, v in pairs(self.opponentsSomatoMap) do
        local player = self.opponents[k]
        player.transform:FindChild("body"):GetComponent(SkinnedMeshRenderer).sharedMesh = meshTable[v]
    end
end

local originalHeightScale = {}
-- 庆祝动作特写时设置球员的模型缩放为1
function PlayerManager:EqualizePlayersHeight(ids)
    for i, id in pairs(ids) do
        if originalHeightScale[id] == nil then
            if id <= 11 then
                originalHeightScale[id] = self.players[id].transform.localScale.x
                self.players[id].transform.localScale = Vector3(1, 1, 1)
            else
                originalHeightScale[id] = self.opponents[id - 11].transform.localScale.x
                self.opponents[id - 11].transform.localScale = Vector3(1, 1, 1)
            end
        end
    end
end
-- 庆祝动作结束后恢复原有的身高
function PlayerManager:RestorePlayersOriginalHeight()
    for id, v in pairs(originalHeightScale) do
        if id <= 11 then
            self.players[id].transform.localScale = Vector3(v, v, v)
        else
            self.opponents[id - 11].transform.localScale = Vector3(v, v, v)
        end
    end
    originalHeightScale = {}
end

function PlayerManager:initMesh()
    for i, athlete in ipairs(self.playerTeamData.athletes) do
        if athlete.onfieldId ~= nil then
            local player = self.players[athlete.onfieldId]
            player.athleteId = athlete.id

            local athleteData = PlayerModelConstructer.CreatePlayerData(athlete.modelID)
            PlayerReplacer.replaceMesh(player, athleteData.faceMesh, athleteData.faceTexture, athleteData.isUseFaceHair, athleteData.hairMesh, athleteData.hairTextrue, athleteData.beardTexture, athleteData.hairColor, athleteData.height, athleteData.bodyTexture, athleteData.bodyHairTexture, athleteData.somato, athleteData.faceHairTexID)
            self.playersSomatoMap[athlete.onfieldId] = athleteData.somato
        end
    end
    for i, athlete in ipairs(self.opponentTeamData.athletes) do
        if athlete.onfieldId ~= nil then
            local player = self.opponents[athlete.onfieldId - 11]
            player.athleteId = athlete.id

            local athleteData = PlayerModelConstructer.CreatePlayerData(athlete.modelID)
            PlayerReplacer.replaceMesh(player, athleteData.faceMesh, athleteData.faceTexture, athleteData.isUseFaceHair, athleteData.hairMesh, athleteData.hairTextrue, athleteData.beardTexture, athleteData.hairColor, athleteData.height, athleteData.bodyTexture, athleteData.bodyHairTexture, athleteData.somato, athleteData.faceHairTexID)
            self.opponentsSomatoMap[athlete.onfieldId - 11] = athleteData.somato
        end
    end
    for i = 1, 4 do
        if self.referees[i] then
            local athleteData = PlayerModelConstructer.GetRandomModelData()
            PlayerReplacer.replaceMesh(self.referees[i], athleteData.faceMesh, athleteData.faceTexture, athleteData.isUseFaceHair, "Hair1", "HairTexture1", nil, athleteData.hairColor, 180, athleteData.bodyTexture, athleteData.bodyHairTexture, athleteData.somato, athleteData.faceHairTexID)
        end
    end
end

function PlayerManager:updateMeshAndKit(athleteIdList)
    for i, athleteId in ipairs(athleteIdList) do
        self:updateSingleMeshAndKit(i, athleteId)
    end
end

function PlayerManager:updateSingleMeshAndKit(onfieldId, athleteId)
    local player = self.players[onfieldId]

    if self.playerTeamData then
        for i, athlete in ipairs(self.playerTeamData.athletes) do
            if athleteId == athlete.id then
                if athleteId ~= player.athleteId then
                    player.athleteId = athleteId
                    local athleteData = PlayerModelConstructer.CreatePlayerData(athlete.modelID)
                    PlayerReplacer.replaceMesh(player, athleteData.faceMesh, athleteData.faceTexture, athleteData.isUseFaceHair, athleteData.hairMesh, athleteData.hairTextrue, athleteData.beardTexture, athleteData.hairColor, athleteData.height, athleteData.bodyTexture, athleteData.bodyHairTexture, athleteData.somato, athleteData.faceHairTexID)
                    self.playersSomatoMap[athlete.onfieldId] = athleteData.somato

                    self:coroutine(function()
                        for k = 1, 3 do coroutine.yield() end
                        if onfieldId == 1 then
                            PlayerReplacer.replaceKitNew(player, self.gkClothTexture, self.nameNumTexture, NameNumGenerator.GetUVWH(i), self.gkBackNumColor, self.gkTrouNumColor, self.playerTeamData.printingStyle)
                        else
                            PlayerReplacer.replaceKitNew(player, self.clothTexture, self.nameNumTexture, NameNumGenerator.GetUVWH(i), self.backNumColor, self.trouNumColor, self.playerTeamData.printingStyle)
                        end
                    end)
                end
                break
            end
        end
    end
end

function PlayerManager:initKit()
    local playerGkParas = clone(self.playerTeamData.currentUseGKShirt)
    playerGkParas.logo = self.playerTeamData.logo
    local playerParas = clone(self.playerTeamData.currentUseShirt)
    playerParas.logo = self.playerTeamData.logo
    local opponentGkParas = clone(self.opponentTeamData.currentUseGKShirt)
    opponentGkParas.logo = self.opponentTeamData.logo
    local opponentParas = clone(self.opponentTeamData.currentUseShirt)
    opponentParas.logo = self.opponentTeamData.logo

    local nameNumList = {}
    for i, athlete in ipairs(self.playerTeamData.athletes) do
        table.insert(nameNumList, {athlete.kitName, athlete.number})
    end

    NameNumGenerator.GenerateBaseTexture(self.playerTeamData.nameNumType, nameNumList, function(nameNumTexture)
        -- cache texture resouce
        self.nameNumTexture = nameNumTexture

        -- 处理拜仁这种特殊的队服
        if type(self.playerTeamData.specificTeam) == "string" and self.playerTeamData.useShirtType ~= MatchUseShirtType.BACKUP then
            local clothTex = res.LoadRes(SpecificTeamData[self.playerTeamData.specificTeam].resMap[self.playerTeamData.useShirtType].shirtPath, UnityEngine.Texture2D)
            local backNumColor = ClothUtils.parseColorString(playerParas.backNumColor)
            local trouNumColor = ClothUtils.parseColorString(playerParas.trouNumColor)
            self.clothTexture = clothTex
            self.backNumColor = backNumColor
            self.trouNumColor = trouNumColor
            for i, athlete in ipairs(self.playerTeamData.athletes) do
                if athlete.onfieldId ~= nil then
                    if athlete.role ~= 26 then
                        PlayerReplacer.replaceKitNew(self.players[athlete.onfieldId], clothTex, nameNumTexture, NameNumGenerator.GetUVWH(i), backNumColor, trouNumColor, self.playerTeamData.printingStyle)
                    end
                end
            end
        else
            -- not gk
            BaseTexGenerator.GenerateBaseTexture(playerParas, function(texture)
                local backNumColor = ClothUtils.parseColorString(playerParas.backNumColor)
                local trouNumColor = ClothUtils.parseColorString(playerParas.trouNumColor)
                self.clothTexture = texture
                self.backNumColor = backNumColor
                self.trouNumColor = trouNumColor
                for i, athlete in ipairs(self.playerTeamData.athletes) do
                    if athlete.onfieldId ~= nil then
                        if athlete.role ~= 26 then
                            PlayerReplacer.replaceKitNew(self.players[athlete.onfieldId], texture, nameNumTexture, NameNumGenerator.GetUVWH(i), backNumColor, trouNumColor, self.playerTeamData.printingStyle)
                        end
                    end
                end
            end)
        end
        -- gk
        BaseTexGenerator.GenerateBaseTexture(playerGkParas, function(texture)
            local backNumColor = ClothUtils.parseColorString(playerGkParas.backNumColor)
            local trouNumColor = ClothUtils.parseColorString(playerGkParas.trouNumColor)
            self.gkClothTexture = texture
            self.gkBackNumColor = backNumColor
            self.gkTrouNumColor = trouNumColor
            for i, athlete in ipairs(self.playerTeamData.athletes) do
                if athlete.onfieldId ~= nil then
                    if athlete.role == 26 then
                        PlayerReplacer.replaceKitNew(self.players[athlete.onfieldId], texture, nameNumTexture, NameNumGenerator.GetUVWH(i), backNumColor, trouNumColor, self.playerTeamData.printingStyle)
                    end
                end
            end
        end)
    end)

    nameNumList = {}
    for i, athlete in ipairs(self.opponentTeamData.athletes) do
        table.insert(nameNumList, {athlete.kitName, athlete.number})
    end

    NameNumGenerator.GenerateBaseTexture(self.opponentTeamData.nameNumType, nameNumList, function(nameNumTexture)
        -- 处理拜仁这种特殊的队服
        if type(self.opponentTeamData.specificTeam) == "string" and self.opponentTeamData.useShirtType ~= MatchUseShirtType.BACKUP then
            local clothTex = res.LoadRes(SpecificTeamData[self.opponentTeamData.specificTeam].resMap[self.opponentTeamData.useShirtType].shirtPath, UnityEngine.Texture2D)
            local backNumColor = ClothUtils.parseColorString(opponentParas.backNumColor)
            local trouNumColor = ClothUtils.parseColorString(opponentParas.trouNumColor)
            for i, athlete in ipairs(self.opponentTeamData.athletes) do
                if athlete.onfieldId ~= nil then
                    if athlete.role ~= 26 then
                        PlayerReplacer.replaceKitNew(self.opponents[athlete.onfieldId - 11], clothTex, nameNumTexture, NameNumGenerator.GetUVWH(i), backNumColor, trouNumColor, self.opponentTeamData.printingStyle)
                    end
                end
            end
        else
            BaseTexGenerator.GenerateBaseTexture(opponentParas, function(texture)
                local backNumColor = ClothUtils.parseColorString(opponentParas.backNumColor)
                local trouNumColor = ClothUtils.parseColorString(opponentParas.trouNumColor)
                for i, athlete in ipairs(self.opponentTeamData.athletes) do
                    if athlete.onfieldId ~= nil then
                        if athlete.role ~= 26 then
                            PlayerReplacer.replaceKitNew(self.opponents[athlete.onfieldId - 11], texture, nameNumTexture, NameNumGenerator.GetUVWH(i), backNumColor, trouNumColor, self.opponentTeamData.printingStyle)
                        end
                    end
                end
            end)
        end

        BaseTexGenerator.GenerateBaseTexture(opponentGkParas, function(texture)
            local backNumColor = ClothUtils.parseColorString(opponentGkParas.backNumColor)
            local trouNumColor = ClothUtils.parseColorString(opponentGkParas.trouNumColor)
            for i, athlete in ipairs(self.opponentTeamData.athletes) do
                if athlete.onfieldId ~= nil then
                    if athlete.role == 26 then
                        PlayerReplacer.replaceKitNew(self.opponents[athlete.onfieldId - 11], texture, nameNumTexture, NameNumGenerator.GetUVWH(i), backNumColor, trouNumColor, self.opponentTeamData.printingStyle)
                    end
                end
            end
        end)
    end)

    self:coroutine(function()
        for i = 1, 3 do coroutine.yield() end
        if self.skipOpeningButton ~= nil then
            self.skipOpeningButton:SetActive(true)
        end
    end)
end

function PlayerManager:SwitchMaterialLevel(qualityLevel)
    for k, v in pairs(self.playersSomatoMap) do
        local player = self.players[k]
        PlayerReplacer.SwitchMaterialQuality(player,qualityLevel)
    end
    for k, v in pairs(self.opponentsSomatoMap) do
        local player = self.opponents[k]
        PlayerReplacer.SwitchMaterialQuality(player,qualityLevel)
    end
end

return PlayerManager
