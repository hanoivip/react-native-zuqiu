local Card = require("data.DreamLeagueCard")
local Skills = require("data.DreamLeagueSkill")
local PlayerDreamCardsMapModel = require("ui.models.dreamLeague.PlayerDreamCardsMapModel")
local DreamLeagueCardBaseModel = require("ui.models.dreamLeague.DreamLeagueCardBaseModel")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local DreamLeagueSkillName = require("data.DreamLeagueSkillName")
local DreamLeagueCardModel = class(DreamLeagueCardBaseModel)

function DreamLeagueCardModel:ctor(dcid)
    assert(dcid, "DreamLeagueCardModel::dcid or data does not exist!")
    self.dcid = dcid
    self.playerDreamCardsMapModel = PlayerDreamCardsMapModel.new()
    local dreamCardId = self.playerDreamCardsMapModel:GetDreamCardIdBydcid(dcid)
    self.staticData = Card[dreamCardId] or {}
    self.extraData = self.playerDreamCardsMapModel:GetCardData(dcid) or {}
end

function DreamLeagueCardModel:GetDcid()
   return self.extraData["dcid"]
end

function DreamLeagueCardModel:GetDreamCardId()
   return self.extraData["dreamCardId"]
end

-- 球员技能
function DreamLeagueCardModel:GetSkills()
    local skillT = {}
    for k,v in pairs(self.extraData.attribute) do
        if DreamLeagueSkillName[k] then
            local tempSkill = DreamLeagueSkillName[k].desc .. ":" .. v .. "%"
            table.insert(skillT, tempSkill)
        end
    end
    return skillT
end

local function IsLockByType(lock, locknum)
    if math.floor(lock / (2 * locknum)) == math.floor((lock + locknum) / (2 * locknum)) then
        return false
    else
        return true
    end
end

-- 是否被系统锁住
function DreamLeagueCardModel:IsLockedBySystem()
    return IsLockByType(self.extraData["lock"], DreamConstants.DreamCardLockState.SYSTEM_LOCK)
end

-- 是否被玩家锁住
function DreamLeagueCardModel:IsLockedByPlayer()
    return IsLockByType(self.extraData["lock"], DreamConstants.DreamCardLockState.USER_LOCK)
end

-- 是否被锁住
function DreamLeagueCardModel:IsLocked()
    return IsLockByType(self.extraData["lock"], DreamConstants.DreamCardLockState.USER_LOCK) or IsLockByType(self.extraData["lock"], DreamConstants.DreamCardLockState.SYSTEM_LOCK)
end

-- 是否为新获得卡牌
function DreamLeagueCardModel:IsNew()
    return self.extraData["isNew"]
end

-- 改变锁的状态
-- @param lockStatus 0:default, 1:locked by user, 2:locked by system
function DreamLeagueCardModel:SetLockStatus(lockStatus)
    self.extraData["lock"] = lockStatus
    self.playerDreamCardsMapModel:SetCardLockState(self.dcid, lockStatus)
end

---
-- 改变新获得的状态
-- @param newStatus 0:old, 1:new
function DreamLeagueCardModel:SetNewStatus(newStatus)
    self.extraData["new"] = newStatus
end

-- 在球队中的位置，例如后卫门将
function DreamLeagueCardModel:GetPostionType()
    return self.staticData.positionType
end

function DreamLeagueCardModel:GetQuality()
    return self.staticData.quality
end

function DreamLeagueCardModel:GetCardName()
    return self.staticData.nameId
end


return DreamLeagueCardModel

