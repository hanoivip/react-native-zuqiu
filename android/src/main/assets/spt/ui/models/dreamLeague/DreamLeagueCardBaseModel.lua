-- static data 
local Card = require("data.DreamLeagueCard")

local DreamLeagueCardBaseModel = class()

function DreamLeagueCardBaseModel:ctor(dreamCardId)
    assert(dreamCardId, "DreamLeagueCardBaseModel::dcid does not exist!")
    self.dreamCardId = dreamCardId
    self.staticData = Card[dreamCardId] or {}
end

-- dreamCardId
function DreamLeagueCardBaseModel:GetDreamCardId()
    return self.dreamCardId
end

-- 位置
function DreamLeagueCardBaseModel:GetMainPosition()
    return self.staticData["mainPosition"]
end

-- 位置编号
function DreamLeagueCardBaseModel:GetPositionType()
    return self.staticData["positionType"]
end

-- 头像
function DreamLeagueCardBaseModel:GetPlayerIcon()
    return self.staticData["pictureID"]
end

-- 国家图标
function DreamLeagueCardBaseModel:GetNationIcon()
    return self.staticData["nationIcon"]
end

-- 国家
function DreamLeagueCardBaseModel:GetNation()
    return self.staticData["nation"]
end

-- 名字
function DreamLeagueCardBaseModel:GetName()
    return self.staticData["name"]
end

-- 名字ID
function DreamLeagueCardBaseModel:GetNameId()
    return self.staticData["nameId"]
end

-- 品质
function DreamLeagueCardBaseModel:GetQuality()
    return self.staticData["quality"]
end

-- 所属球队
function DreamLeagueCardBaseModel:GetTeam()
    return self.staticData["teamInfo"]
end

return DreamLeagueCardBaseModel

