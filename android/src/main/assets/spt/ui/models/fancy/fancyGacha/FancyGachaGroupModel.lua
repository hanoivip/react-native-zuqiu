local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local Model = require("ui.models.Model")
local FancyGachaGroupModel = class(Model, "FancyGachaGroupModel")

function FancyGachaGroupModel:ctor()
    FancyGachaGroupModel.super.ctor(self)
end

function FancyGachaGroupModel:InitData(groupData)
    self.data = groupData
    self.requestTime = Time.realtimeSinceStartup
end

-- 获取招募卡组id
function FancyGachaGroupModel:GetId()
    return self.data.id
end

-- 获取招募卡组排序
function FancyGachaGroupModel:GetSortId()
    return self.data.detail.Id
end

-- 获取剩余时间
function FancyGachaGroupModel:GetRemainTime()
    if not self.data.detail.endTime then 
        return false 
    end
    local serverTime = self.data.detail.serverTime
    local realtimeSinceStartup = Time.realtimeSinceStartup
    local nowTime = serverTime + realtimeSinceStartup - self.requestTime
    local endTime = self.data.detail.endTime
    local remainTime = endTime - nowTime
    if remainTime < 0 then
        remainTime = 0
    end
    return remainTime
end

-- 获取招募卡组名
function FancyGachaGroupModel:GetName()
    return self.data.detail.name
end

-- 获取招募卡组类型
function FancyGachaGroupModel:GetType()
    return tonumber(self.data.detail.type)
end

-- 获取招募消耗物品
function FancyGachaGroupModel:GetGachaItemId(times)
    local itemId = nil
    if times == 1 then
        itemId = self.data.detail.oneGachaItemId
    elseif times == 10 then
        itemId = self.data.detail.tenGachaItemId
    end
    return itemId
end

-- 获取招募卡组卡牌
function FancyGachaGroupModel:GetCardDisply()
    local cardList = {}
    for i, v in pairs(self.data.detail.cardDisplay) do
        local fancyCardModel = FancyCardModel.new()
        fancyCardModel:InitData(v)
        table.insert(cardList, fancyCardModel)
    end
    return cardList
end

-- 是否为UP抽卡
function FancyGachaGroupModel:GetUpIcon()
    return self.data.detail.upIcon == 1
end

-- 获取招募卡组旗帜背景
function FancyGachaGroupModel:GetBoardPic()
    local picPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyGacha/Image/FancyGacha_%s.png"
    local picName = nil
    local boardPic = self.data.detail.boardPic
    if boardPic == "FancyBoardNormal" then
        picName = "FlagNormal"
    elseif boardPic == "FancyBoardIcon" then
        picName = "FlagBg"
    else
        picName = "FlagUp"
    end
    local imgPath = string.format(picPath, picName)
    local sprite = res.LoadRes(imgPath)
    return sprite
end

-- 获取招募卡组队标
function FancyGachaGroupModel:GetBoardIcon()
    local picPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/Common/FancyGroupIcon/%s.png"
    local sprite = nil
    local picName = string.gsub(self.data.detail.boardIcon,"^%l", string.upper)
    if picName then
        local imgPath = string.format(picPath, picName)
        sprite = res.LoadRes(imgPath)
    end
    return sprite
end

-- 获取招募卡组介绍
function FancyGachaGroupModel:GetDes()
    return self.data.detail.text
end

-- 招募是否有保底
function FancyGachaGroupModel:GetTenGachaSafeTip()
    return self.data.detail.tenGachaSafeTip == 1
end

-- 是否免费招募
function FancyGachaGroupModel:GetFirst()
    return self.data.detail.first
end

-- 设置非免费
function FancyGachaGroupModel:SetNotFirst()
    self.data.detail.first = false
end

-- 是否是新开启的
function FancyGachaGroupModel:IsNew()
    local fancyGacha = ReqEventModel.GetInfo("fancyGacha") or {}
    for k, v in pairs(fancyGacha) do
        if self:GetId() == v then
            return true
        end
    end
    return false
end

return FancyGachaGroupModel
