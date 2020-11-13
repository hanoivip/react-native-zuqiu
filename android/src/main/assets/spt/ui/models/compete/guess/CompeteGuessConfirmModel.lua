local Model = require("ui.models.Model")
local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")

local CompeteGuessConfirmModel = class(Model, "CompeteGuessConfirmModel")

function CompeteGuessConfirmModel:ctor()
    self.data = nil
    self.label = nil -- 0不接受，1接受
end

function CompeteGuessConfirmModel:InitWithProtocol(data)
    self.data = data
    self.isBigEar = false
    self.isSmallEar = false
    for k, v in pairs(data.matchTypes) do
        if v >= CompeteSchedule.Big_Ear_Match and v <= CompeteSchedule.Big_Ear_Match_Kick_Off then
            self.isBigEar = true
        elseif v >= CompeteSchedule.Small_Ear_Match and v <= CompeteSchedule.Small_Ear_Match_Kick_Off then
            self.isSmallEar = true
        end
    end
end

function CompeteGuessConfirmModel:SetCompeteMainModel(competeMainModel)
    self.competeMainModel = competeMainModel
end

function CompeteGuessConfirmModel:GetCompeteMainModel()
    return self.competeMainModel
end

function CompeteGuessConfirmModel:GetHead()
    if self.isBigEar and not self.isSmallEar then
        return lang.trans("compete_guess_confirm_head", lang.transstr("compete_cup2")) -- 大耳朵杯
    elseif not self.isBigEar and self.isSmallEar then
        return lang.trans("compete_guess_confirm_head", lang.transstr("compete_cup1")) -- 小耳朵杯
    else
        return ""
    end
end

function CompeteGuessConfirmModel:GetContent()
    if self.isBigEar and not self.isSmallEar then
        return lang.trans("compete_guess_confirm_content", lang.transstr("compete_cup2")) -- 大耳朵杯
    elseif not self.isBigEar and self.isSmallEar then
        return lang.trans("compete_guess_confirm_content", lang.transstr("compete_cup1")) -- 小耳朵杯
    else
        return ""
    end
end

function CompeteGuessConfirmModel:GetRewards()
    if self.isBigEar and not self.isSmallEar then
        return self.data.guessReward[tostring(CompeteSchedule.Big_Ear_Match)]
    elseif not self.isBigEar and self.isSmallEar then
        return self.data.guessReward[tostring(CompeteSchedule.Small_Ear_Match)]
    else
        return {}
    end
end

function CompeteGuessConfirmModel:GetLabel()
    return self.label
end

function CompeteGuessConfirmModel:SetLabel(label)
    self.label = label
end

return CompeteGuessConfirmModel
