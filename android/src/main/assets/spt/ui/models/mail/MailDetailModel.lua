local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local CustomEvent = require("ui.common.CustomEvent")

local MailDetailModel = class(Model)

function MailDetailModel:ctor(mailData)
    MailDetailModel.super.ctor(self)
    self.cacheData = mailData
end

function MailDetailModel:GetTitle()
    return self.cacheData.title
end

function MailDetailModel:GetDesc()
    return self.cacheData.desc
end

function MailDetailModel:GetStartTime()
    return self.cacheData.starttime
end

function MailDetailModel:GetTime()
    return os.date("%x %X", self:GetStartTime())
end

function MailDetailModel:GetRestTime()
    if self:GetRead() == 0 or (not self.cacheData.lasttime)  then
        local restTime = self.cacheData.overtime - self.cacheData.starttime
        return math.ceil(restTime/86400)
    else
        local timeTable = string.convertSecondToTimeTable(self.cacheData.lasttime or 172600)
        if timeTable.day > 2 then
            timeTable.day = 2
        elseif timeTable.day < 1 then
            timeTable.day = 1
        end
        return (timeTable.day + 1)
    end
end

function MailDetailModel:GetType()
    return self.cacheData.type
end

function MailDetailModel:GetMailID()
    return self.cacheData.mid
end

-- 0标识未读，1标识已读
function MailDetailModel:GetRead()
    return self.cacheData.read
end

function MailDetailModel:SetRead(status)
    self.cacheData.read = status
    return self.cacheData.read
end

function MailDetailModel:IsRead()
    return self:GetRead() == 1
end

-- 是否有附件
function MailDetailModel:HasContent()
    return tobool(self.cacheData.contents)
end

-- 通用的奖励格式
function MailDetailModel:GetRewardContent()
    return self.cacheData.contents or {}
end

-- 是否为文本邮件
function MailDetailModel:IsTextMail()
    local mailType = self:getMailIconType()
    return tobool(mailType == 0)
end

-- 奖励中是否包含球员
function MailDetailModel:IsRewardsContainPlayer()
    local contents = self.cacheData.contents or {}
    local card = contents.card
    local hasPlayer = tobool(card and #card ~= 0)
    return hasPlayer
end

-- 根据邮件内容种类数得到邮件的icon
function MailDetailModel:getMailIconType()
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
function MailDetailModel:SetMailCollect(data)
    assert(tostring(data.mid) == tostring(self:GetMailID()))

    self.cacheData.read = 1

    -- TODO 更新缓存中的数据
    local contents = data.contents
    if contents.d and tonumber(contents.d) > 0 then
        CustomEvent.GetDiamond("3", tonumber(contents.d))
    end
    if contents.m and tonumber(contents.m) > 0 then
        CustomEvent.GetMoney("6", tonumber(contents.m))
    end

    EventSystem.SendEvent("MailDetailModel_SetMailRead", self:GetMailID())
end

function MailDetailModel:IsJumpToiOSStore()
    return self.cacheData.addType == "jump"
end

-- uk版本激活码专用
function MailDetailModel:HasHoolaiCode()
    return self.cacheData.ud and self.cacheData.ud.__uk_hoolai_code__ or nil
end

return MailDetailModel
