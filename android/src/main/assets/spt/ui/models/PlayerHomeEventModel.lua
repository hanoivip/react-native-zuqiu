local Model = require("ui.models.Model")
local PlayerHomeEventModel = class(Model, "PlayerInfoModel")

function PlayerHomeEventModel:ctor()
    PlayerHomeEventModel.super.ctor(self)
end

function PlayerHomeEventModel:Init(data)
    if not data then
        data = cache.getHomeEvent()
    end
    self.data = data or {}
end

function PlayerHomeEventModel:InitWithProtocol(data)
    cache.setHomeEvent(data)
    self:Init(data)
end

function PlayerHomeEventModel:GetBannerData()
    return self.data.bannerNote
end

function PlayerHomeEventModel:GetSignNoteData()
    return self.data.signNote and self.data.signNote[1]
end

-- 特殊处理不下线自动更新签到数据（服务器带两层数组）
function PlayerHomeEventModel:HasSignPlate()
    return self.data.signNote and self.data.signNote[1] and self.data.signNote[1].type == 'Sign'
end

function PlayerHomeEventModel:GetSignRewardData()
    return self.data.signNote[1].signInfo 
end

-- 布冯礼包购买次数
function PlayerHomeEventModel:GetFirstPayGiftBoxBoughtTime()
    return self.data.timeLimitBonus and self.data.timeLimitBonus.buyCounter
end

function PlayerHomeEventModel:GetFirstPayGiftBoxRemainTime()
    return self.data.timeLimitBonus and self.data.timeLimitBonus.lastTime
end



return PlayerHomeEventModel
