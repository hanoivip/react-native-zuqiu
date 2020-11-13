local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Model = require("ui.models.Model")
local GachaMainModel = class(Model, "GachaMainModel")
local Gacha = require("data.Gacha")
local GachaStepUp = require("data.GachaStepUp")
local FriendGacha = require("data.FriendGacha")

local Card = require("data.Card")

local GachaType = {
    Normal = "normal",
    StepUp = "stepUp",
    Friend = "friend",
}

GachaMainModel.StaticType = {}
for k, v in pairs(Gacha) do
    table.insert(GachaMainModel.StaticType, k)
end
for k, v in pairs(GachaStepUp) do
    table.insert(GachaMainModel.StaticType, k)
end
for k, v in pairs(FriendGacha) do
    table.insert(GachaMainModel.StaticType, k)
end

local function IsInTable(e, t)
    for i, v in ipairs(t) do
        if v == e then
            return true
        end
    end
    return false
end

function GachaMainModel:ctor()
    GachaMainModel.super.ctor(self)
    self.data = nil
end

function GachaMainModel:InitData(data)
    for k, v in pairs(Gacha) do
        -- 服务器覆盖本地表
        if data.content[k] == nil then
            data.content[k] = v
        end
        data.content[k].gachaType = GachaType.Normal
    end
    for k, v in pairs(GachaStepUp) do
        data.content[k] = v
        data.content[k].gachaType = GachaType.StepUp
    end
    for k, v in pairs(FriendGacha) do
        data.content[k] = v
        data.content[k].gachaType = GachaType.Friend
    end
    if type(data.ctl) == "table" then
        for k, v in pairs(data.ctl) do
            if type(data.content[k]) == "table" then
                data.content[k].ctl = data.ctl[k]
            end
        end
    end

    if type(data.limited) == "table" then 
        for k, v in pairs(data.limited) do
            if v == 0 then 
                data.limited[k] = nil
            end
        end
        self.discontinuedList = data.limited
    end
    if type(data.tag) == "table" then
        for i = #data.tag, 1 , -1 do
            local v = data.tag[i]
            if not data.content[v] then
                table.remove(data.tag, i)
            end
        end
    else
        data.tag = {}
    end

    self.data = data
    -- 友情抽没有A1，其余情况均有
    if self:GetStaticDataByTag("A1") then
        PlayerInfoModel.new():SetLucky(self:GetStaticDataByTag("A1").ctl.lucky)
    end
end

function GachaMainModel:GetStaticDataByTag(tag)
    if not tag then tag = self:GetLabelTag() end
    return self.data.content[tag]
end

function GachaMainModel:GetLabels()
    return self.data.tag
end

function GachaMainModel:GetLabelCount()
    return #self.data.tag
end

function GachaMainModel:GetLabelTitle(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).name
end

-- 当前抽卡类型是否可以使用抽卡券
function GachaMainModel:GetIsUseTicket(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).itemUse
end

function GachaMainModel:GetBanner(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).bannerPic
end

function GachaMainModel:GetBoard(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).boardPic
end

function GachaMainModel:GetCtlByTag(tag)
    if type(self.data.ctl) == "table" then
        return self.data.ctl[tag]
    end
end

function GachaMainModel:SetLabelTag(tag)
    self.labelTag = tag
end

function GachaMainModel:GetLabelTag()
    if self.data.content[self.labelTag] then
        return self.labelTag
    else
        return self.data.tag[1]
    end
end

function GachaMainModel:NeedShowRedPoint(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    local ctl = gachaContent.ctl
    return tobool(type(ctl) == "table" and ctl.event)
end

function GachaMainModel:GetCurrentStep(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    if gachaContent.gachaType == GachaType.StepUp then
        local ctl = gachaContent.ctl
        return (type(ctl) == "table" and type(ctl.curStep) == "number" and ctl.curStep < 3) and ctl.curStep + 1 or 3
    end
end

function GachaMainModel:GetPrice(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    if gachaContent.gachaType == GachaType.StepUp then
        if gachaContent.ctl.curStep == 3 then return end
        local curStep = self:GetCurrentStep(tag)
        if type(gachaContent.cardNumber) == "table" and tostring(gachaContent.cardNumber[curStep]) == "1" then
            return gachaContent.price[curStep]
        end
    else
        return gachaContent.price
    end
end

function GachaMainModel:IsFinished(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    return gachaContent.gachaType == GachaType.StepUp and gachaContent.ctl.curStep == 3
end

function GachaMainModel:GetTenPrice(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    if gachaContent.gachaType == GachaType.StepUp then
        if gachaContent.ctl.curStep == 3 then return end
        local curStep = self:GetCurrentStep(tag)
        if type(gachaContent.cardNumber) == "table" and tostring(gachaContent.cardNumber[curStep]) == "10" then
            return gachaContent.price[curStep]
        end
    else
        return gachaContent.tenPrice
    end
end

function GachaMainModel:GetPriceType(tag)
    if not tag then tag = self:GetLabelTag() end
    -- 有免费次数
    if self:IsHaveFreeTime(tag) then return "free" end
    -- 消费抽卡券
    if self:GetIsUseTicket(tag) and self:GetIsUseTicket(tag) ~= "0" and tag ~= "B2" then
        return "item"
    end
    -- 使用钻石
    return self:GetStaticDataByTag(tag).priceType or "d"
end

-- 只有普通招募有免费次数
function GachaMainModel:IsHaveFreeTime(tag)
    if not tag then tag = self:GetLabelTag() end
    if self:IsTagNormalGacha(tag) then
        return tonumber(self:GetStaticDataByTag(tag).ctl.free) > 0 
    end

    return false
end

-- 获得倒计时免费刷新的时间
function GachaMainModel:GetCountDownTime(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).ctl.c_d
end

-- 当前tag是否为普通招募
function GachaMainModel:IsTagNormalGacha(tag)
    if not tag then tag = self:GetLabelTag() end
    return tobool(tag == "A1" or tag == "A2" or tag == "A3" or tag == "A4" or tag == "A5" or tag == "A6")
end

function GachaMainModel:GetProbUpQuality(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    local ret
    if gachaContent.gachaType == GachaType.StepUp then
        local curStep = self:GetCurrentStep(tag)
        ret = gachaContent["probUpQuality" .. curStep]
    else
        ret = gachaContent.probUpQuality
    end
    if type(ret) == "table" then
        for i, v in ipairs(ret) do
            ret[i] = tostring(v)
        end
    end
    return ret
end

function GachaMainModel:GetProbUpCard(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    if gachaContent.gachaType == GachaType.StepUp then
        local curStep = self:GetCurrentStep(tag)
        return gachaContent["probUpCard" .. curStep]
    else
        return gachaContent.probUpCard
    end
end

function GachaMainModel:GetMustGet(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    if gachaContent.gachaType == GachaType.StepUp then
        local curStep = self:GetCurrentStep(tag)
        return gachaContent["mustGet" .. curStep]
    else
        return gachaContent.mustGet
    end
end

function GachaMainModel:SetDiscontinued(tag, detailTable)
    if not tag then tag = self:GetLabelTag() end
    for cid, time in pairs(self.discontinuedList) do
        if  detailTable[cid] ~= nil then 
            detailTable[cid].discontinued = time
        end
    end
    return detailTable
end

function GachaMainModel:GetText1(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).text1
end

function GachaMainModel:GetText2(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).text2
end

function GachaMainModel:GetText3(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).text3
end

function GachaMainModel:GetLayout(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).layout
end

function GachaMainModel:GetCardDisplay(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).cardDisplay
end

function GachaMainModel:GetArtWords(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).artWordsPic
end

function GachaMainModel:GetGachaDetail(tag)
    if not tag then tag = self:GetLabelTag() end
    assert(self.data and type(self.data.content) == "table" and type(self.data.content[tag]) == "table")
    local gachaContent = self.data.content[tag]
    local detailTable = {}
    if type(gachaContent) == "table" then
        local cardRand = nil
        local cardPool = nil
        if gachaContent.gachaType == GachaType.StepUp then
            local curStep = self:GetCurrentStep(tag)
            local detail = gachaContent["GachaDetail" .. curStep]
            cardRand = detail.cardRand
            cardPool = detail.cardPool
        elseif gachaContent.gachaType == GachaType.Friend then
            cardRand = table.keys(gachaContent.cardRand)
        else
            cardRand = gachaContent.cardRand
            cardPool = gachaContent.cardPool
        end
        if type(cardRand) == "table" then
            for _, quality in ipairs(cardRand) do
                for cid, cardStatic in pairs(Card) do
                    if tostring(cardStatic.quality) == tostring(quality) and cardStatic.valid == 1 and cardStatic.packageWeight > 0 then
                        local data = {
                            cid = tostring(cid),
                            quality = cardStatic.quality,
                        }
                        detailTable[cid] = data
                    end
                end
            end
        end
        if type(cardPool) == "table" and #cardPool > 0 then
            for _, cid in ipairs(cardPool) do
                local card = Card[cid]
                if card and card.valid == 1 and card.packageWeight > 0 then
                    local data = {
                        cid = tostring(cid),
                        quality = card.quality,
                    }
                    detailTable[tostring(cid)] = data
                end
            end
        end
        if type(self.discontinuedList) == "table" then 
            detailTable = self:SetDiscontinued(tag, detailTable)
        end
        detailTable = table.values(detailTable)
        local probUpQuality = self:GetProbUpQuality(tag)
        local probUpCard = self:GetProbUpCard(tag)
        local mustGet = self:GetMustGet(tag)
        for i, v in ipairs(detailTable) do
            if type(mustGet) == "table" and IsInTable(tostring(v.cid), mustGet) then
                v.mustGet = true
            elseif type(probUpQuality) == "table" and IsInTable(tostring(v.quality), probUpQuality) then
                v.probUpQuality = true
            elseif type(probUpCard) == "table" and IsInTable(tostring(v.cid), probUpCard) then
                v.probUpCard = true
            end
        end
        table.sort(detailTable, function(a, b)
            if a.discontinued and not b.discontinued then
                return true
            elseif not a.discontinued and b.discontinued then
                return false
            end 

            if a.mustGet and not b.mustGet then
                return true
            elseif not a.mustGet and b.mustGet then
                return false
            end

            if a.probUpQuality and not b.probUpQuality then
                return true
            elseif not a.probUpQuality and b.probUpQuality then
                return false
            end

            if a.probUpCard and not b.probUpCard then
                return true
            elseif not a.probUpCard and b.probUpCard then
                return false
            end

            if tonumber(a.quality) > tonumber(b.quality) then
                return true
            elseif tonumber(a.quality) < tonumber(b.quality) then
                return false
            end

            if a.cid < b.cid then
                return true
            else
                return false
            end
        end)
    end
    return detailTable
end

function GachaMainModel:SetLeftTime(tag, time)
    local gachaContent = self:GetStaticDataByTag(tag)
    local ctl = gachaContent.ctl
    if ctl.ttl then ctl.ttl = time end
end

function GachaMainModel:GetLeftTime(tag)
    if not tag then tag = self:GetLabelTag() end
    local gachaContent = self:GetStaticDataByTag(tag)
    local ctl = gachaContent.ctl
    return (type(ctl) == "table" and type(ctl.ttl) == "number") and ctl.ttl or nil
end

function GachaMainModel:SetNormalGachaTime(tag, time)
    assert(tag == "A1" or tag == "A2" or tag == "A3" or tag == "A4" or tag == "A5" or tag == "A6")
    self:GetStaticDataByTag(tag).ctl.c_d = time
end

function GachaMainModel:GetLucky(tag)
    if not tag then tag = self:GetLabelTag() end
    return self:GetStaticDataByTag(tag).lucky
end

function GachaMainModel:GetFriendshipPoint(tag)
    if not tag then tag = self:GetLabelTag() end
    if tag == "C1" then
        return PlayerInfoModel.new():GetFriendshipPoint()
    end
end

return GachaMainModel

