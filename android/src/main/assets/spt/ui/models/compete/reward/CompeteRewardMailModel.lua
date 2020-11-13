local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local CustomEvent = require("ui.common.CustomEvent")

local CompeteRewardMailModel = class(Model)

function CompeteRewardMailModel:ctor(mailData)
    CompeteRewardMailModel.super.ctor(self)
    self.cacheData = mailData
    self.mailIndex = nil
end

function CompeteRewardMailModel:GetTitle()
    return self.cacheData.title
end

function CompeteRewardMailModel:GetDesc()
    return self.cacheData.desc
end

function CompeteRewardMailModel:GetStartTime()
    return self.cacheData.starttime
end

function CompeteRewardMailModel:GetTime()
    local timeString = os.date("%x %X", self:GetStartTime()) or ""
    if timeString then
        timeString = string.sub(timeString, 1, -4)
    end
    return timeString
end

function CompeteRewardMailModel:GetRestTime()
    local serverTimeNow = GetServerTimeNow()
    local overTime = self:GetOverTime()
    local daySeconds = 86400

    local restTime = overTime - serverTimeNow
    restTime = restTime < 0 and 0 or restTime
    restTimeDays = math.ceil(restTime / daySeconds)
    return restTimeDays
end

function CompeteRewardMailModel:GetOverTime()
    return self.cacheData.overtime
end

function CompeteRewardMailModel:GetType()
    return self.cacheData.type
end

function CompeteRewardMailModel:GetMailID()
    return self.cacheData.mid
end

-- 0标识未读，1标识已读
function CompeteRewardMailModel:GetRead()
    return self.cacheData.read
end

function CompeteRewardMailModel:SetRead(status)
    self.cacheData.read = status
    return self.cacheData.read
end

function CompeteRewardMailModel:IsRead()
    return self:GetRead() == 1
end

-- 是否有附件
function CompeteRewardMailModel:HasContent()
    return tobool(self.cacheData.contents)
end

-- 通用的奖励格式
function CompeteRewardMailModel:GetRewardContents()
    return self.cacheData.contents or {}
end

-- 是否为文本邮件
function CompeteRewardMailModel:IsTextMail()
    local mailType = self:getMailIconType()
    return tobool(mailType == 0)
end

function CompeteRewardMailModel:GetMailIndex()
    return self.mailIndex
end

function CompeteRewardMailModel:SetMailIndex(mailIndex)
    self.mailIndex = mailIndex
end

-- 根据邮件内容种类数得到邮件的icon
function CompeteRewardMailModel:getMailIconType()
    local contents = self.cacheData.contents or {}
    local num = 0
    for k, v in pairs(contents) do
        if type(v) == "table" and next(v) or type(v) == "number" and v ~= 0 then
            num = num + 1
        end
    end
    if num >= 3 then
        num = 3
    end
    return num
end

-- 邮件领取奖励或者已阅
function CompeteRewardMailModel:SetMailCollected(data)
    assert(tostring(data.mid) == tostring(self:GetMailID()))

    self.cacheData.read = 1

    -- TODO 更新缓存中的数据
    local contents = data.contents
    if contents then
        if contents.d and tonumber(contents.d) > 0 then
            CustomEvent.GetDiamond("3", tonumber(contents.d))
        end
        if contents.m and tonumber(contents.m) > 0 then
            CustomEvent.GetMoney("6", tonumber(contents.m))
        end
    end
    EventSystem.SendEvent("CompeteRewardMailModel_SetMailRead", self:GetMailID())
end

function CompeteRewardMailModel:IsJumpToiOSStore()
    return self.cacheData.addType == "jump"
end

return CompeteRewardMailModel
