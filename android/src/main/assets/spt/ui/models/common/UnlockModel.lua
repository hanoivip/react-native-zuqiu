local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local LevelLimit = require("data.LevelLimit")
local StartGameConstants = require("ui.scene.startGame.StartGameConstants")
local Model = require("ui.models.Model")
local UnlockModel = class(Model, "UnlockModel")

function UnlockModel:ctor(playerLevel)
    UnlockModel.super.ctor(self)
    self.unlockOpenStates = {}
    self:SetCurrentLevel(playerLevel)
end

function UnlockModel:SetCurrentLevel(playerLevel)
    local playerLevel = playerLevel
    local playerInfoModel = PlayerInfoModel.new()
    if not playerLevel then 
        playerLevel = playerInfoModel:GetLevel()
    end
    for key, unlockData in pairs(LevelLimit) do
        local needLevel = unlockData.playerLevel
        local isOpen = false
        if tonumber(playerLevel) >= tonumber(needLevel) then
            isOpen = true
        end
        unlockData.key = key
        local openData = {}
        openData.unlockData = unlockData
        openData.isOpen = isOpen
        self.unlockOpenStates[tostring(unlockData.ID)] = openData
    end
    -- 梦幻联赛的开关是服务器控制
    local dreamLeagueOpenState = (playerInfoModel:GetDreamLeagueOpenState() > 0)
    local dreamViewID = tostring(StartGameConstants.ViewConstants.DREAM.LIMIT_ID)
    self.unlockOpenStates[dreamViewID] = {}
    self.unlockOpenStates[dreamViewID].isOpen = dreamLeagueOpenState
end

function UnlockModel:GetUnlockTable()
    return self.unlockOpenStates
end

function UnlockModel:GetUnlockDataById(id)
    local openData = self.unlockOpenStates[tostring(id)] or {}
    return openData
end

function UnlockModel:GetStateById(id)
    if id == 0 then
        return true
    elseif id < 0 then
        return false
    end
    local openData = self.unlockOpenStates[tostring(id)] or {}
    return openData.isOpen
end

function UnlockModel:GetTipsById(id)
    local openData = self.unlockOpenStates[tostring(id)] or {}
    return openData.unlockData
end

return UnlockModel
