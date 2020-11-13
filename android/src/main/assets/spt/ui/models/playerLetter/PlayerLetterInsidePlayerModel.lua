local Model = require("ui.models.Model")
local LetterCards = require("data.LetterCards")

local PlayerLetterInsidePlayerModel = class(Model, "PlayerLetterInsidePlayerModel")

function PlayerLetterInsidePlayerModel:ctor()
    self.data = nil
    self.playersHasFinishedName = {}
    self.allPlayersNNameInsideLetter = {}
    self.super.ctor(self)
end

function PlayerLetterInsidePlayerModel:Init(data)
    if not data then
        data = cache.getPlayerLetterInsidePlayer()
        if data == nil then
            data = {}
        end
    end
    self.data = data
    self.allPlayersNNameInsideLetter = table.keys(LetterCards)
    self:InitPlayersName()
end

function PlayerLetterInsidePlayerModel:InitWithProtocol(data)
    cache.setPlayerLetterInsidePlayer(data)
    self:Init(data)
end

function PlayerLetterInsidePlayerModel:InitPlayersName()
    for k, v in pairs(self.data) do
        local card = v.cond.card
        if card ~= nil then
            for k, v in pairs(card) do
                table.insert(self.playersHasFinishedName, k)
            end
        end
    end
end

function PlayerLetterInsidePlayerModel:GetHasFinishedPlayersName()
    return self.playersHasFinishedName
end

-- 判断球员卡片是否处于未完成的球员信件需求中
function PlayerLetterInsidePlayerModel:IsBelongToLetterCard(name)
    for i, v in ipairs(self.allPlayersNNameInsideLetter) do
        if name == tostring(v) then
            for key, value in ipairs(self.playersHasFinishedName) do
                if name == value then return false end --- 在球员信件需求中,但有已满足条件的球员卡片
            end
            return true --- 在未完成的球员信件需求中
        end
    end
    return false --- 不在球员信件需求中
end

return PlayerLetterInsidePlayerModel