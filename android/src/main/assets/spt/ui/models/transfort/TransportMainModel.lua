local Model = require("ui.models.Model")
local TeamSponsor = require("data.TeamSponsor")
local SponsorUpgrade = require("data.SponsorUpgrade")
local TransportMySponsorType = require("ui.scene.transfort.TransportMySponsorType")

local TransportMainModel = class(Model)

function TransportMainModel:InitWithProtocol(data)
    assert(data)
    self.data = data
    self.TeamSponsorId = tostring(1)
    self:InitMySponsorDataList()
    self.data.currSponsorLvl = self:InitCurrSponsorLvl()
end

function TransportMainModel:GetCourseDataList()
    return self.data.express
end

-- 初始化当前赞助商
function TransportMainModel:InitCurrSponsorLvl()
    for k,v in pairs(self.data.mySponsorDataList or {}) do
        if v.status == 0 or v.status == 1 then            
            if v.sponsorId then
                return v.sponsorId
            end
        end
    end
    return 1
end

-- 当前赞助商等级
function TransportMainModel:GetCurrSponsorLvl()
    return self.data.currSponsorLvl
end

function TransportMainModel:SetCurrSponsorLvl(lvl)
    local oldLvl = self.data.currSponsorLvl
    self.data.currSponsorLvl = lvl
    if oldLvl >= lvl then oldLvl = nil end  
    EventSystem.SendEvent("Transfort_Refresh_Sponsor_Info", oldLvl)
end

-- 如果有未领取的奖励，则不显示最初的签约页签
function TransportMainModel:IsHaveNotReceiveReward()
    for k, v in pairs(self.data.transport.express or {}) do
        if not v.receiveGift and v.status == TransportMySponsorType.AfterFinsh then
            return true
        end
    end
end

-- 初始化我的赞助商界面信息
function TransportMainModel:InitMySponsorDataList()
    self.data.mySponsorDataList = {}
    local mySponsorDataList = self.data.transport.express
    if self.data.transport.preSponsor and not self:IsHaveNotReceiveReward() then
        self.data.transport.preSponsor.status = self.data.transport.status
        table.insert(self.data.mySponsorDataList, self.data.transport.preSponsor)
    end
    for k, v in pairs(self.data.transport.express or {}) do
        table.insert(self.data.mySponsorDataList, v)
    end

    table.sort(self.data.mySponsorDataList, function (a, b)
        if a.status == TransportMySponsorType.AfterFinsh and b.status == TransportMySponsorType.AfterFinsh then
            if not a.receiveGift then return true end
            if not b.receiveGift then return false end
            return false
        end
        return a.status < b.status
    end)
end

-- 是否正在运镖
function TransportMainModel:IsStartAndNotFinish()
    for k, v in pairs(self.data.mySponsorDataList) do
        if v.status == TransportMySponsorType.AfterStartAndNotFinish or v.status == TransportMySponsorType.AfterSignAndBeforeStart then
            return true
        end
    end
end

-- 谈判完之后会刷新preSponsor数据
function TransportMainModel:SetPreSponsor(sponsorInfo)
    self.data.transport.preSponsor = sponsorInfo
    self:InitMySponsorDataList()
    EventSystem.SendEvent("Transport_Refresh_My_Sponsor")
    self:SetCurrSponsorLvl(sponsorInfo.sponsorId)
end

function TransportMainModel:GetMySponsorDataList()
    return self.data.mySponsorDataList or {}
end

function TransportMainModel:SetMySponsorDataList(dataList)
    assert(type(dataList) == "table")
    table.sort(dataList, function (a, b)
        if a.status == TransportMySponsorType.AfterFinsh and b.status == TransportMySponsorType.AfterFinsh then
            if not a.receiveGift then return true end
            if not b.receiveGift then return false end
            return false
        end
        return a.status < b.status
    end)
    self.data.mySponsorDataList = dataList
    EventSystem.SendEvent("Transport_Refresh_My_Sponsor")
end

-- 可签约次数
function TransportMainModel:GetSignedTime()
    return self.data.transport.sign_times
end

-- 最大签约次数
function TransportMainModel:GetMaxSignTime()
    return TeamSponsor[self.TeamSponsorId].sponsorNum
end

-- 地图可刷新次数
function TransportMainModel:GetMapRefreshedTime()
    return self.data.transport.map_times
end

-- 地图刷新价格
function TransportMainModel:GetMapRefreshPrice()
    return TeamSponsor[self.TeamSponsorId].mapPrice
end

-- 地图最大免费刷新次数
function TransportMainModel:GetMaxRefreshTime()
    return TeamSponsor[self.TeamSponsorId].mapFreeNum
end

-- 可洽谈次数
function TransportMainModel:GetBargainTime()
    return self.data.transport.cs_times
end

-- 设置可洽谈次数
function TransportMainModel:SetBargainTime(time)
    self.data.transport.cs_times = time
    EventSystem.SendEvent("Transport_Refresh_Common")
end

-- 最大洽谈次数
function TransportMainModel:GetMaxBargainTime()
    return TeamSponsor[self.TeamSponsorId].talkFreeNum
end

-- 获得洽谈价格
function TransportMainModel:GetBargainPrice()
    local bargainTime = self:GetBargainTime()
    local price = TeamSponsor[self.TeamSponsorId].talkPrice
    return price[math.abs(bargainTime + 1)] or price[#price]
end

-- 一键最高品质价格
function TransportMainModel:GetBestPrice()
    return TeamSponsor[self.TeamSponsorId].oneButtonPrice
end

-- 可挑战次数
function TransportMainModel:GetRobberyTime()
    return self.data.transport.robbery_times
end

-- 最大挑战次数
function TransportMainModel:GetMaxRobberyTime()
    return TeamSponsor[self.TeamSponsorId].stealNum
end

-- 获得赞助商信息
function TransportMainModel:GetSponsorInfoList()
    return SponsorUpgrade
end

function TransportMainModel:GetSpnsorNameBySponsorId(id)
    return SponsorUpgrade[tostring(id)].sponsorName
end

function TransportMainModel:GetNextRefreshTime()
    return self.data.mapRefreshRemainTime
end

function TransportMainModel:SetNextRefreshTime(time)
    self.data.mapRefreshRemainTime = time
    EventSystem.SendEvent("Transport_Refresh_Map_Time")
end

function TransportMainModel:GetMaxSponsorLvl()
    return 5
end

return TransportMainModel