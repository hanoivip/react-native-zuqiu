local Model = require("ui.models.Model")
local LoseGuideOptionModel = require("ui.models.loseGuide.LoseGuideOptionModel")

-- 失败引导模型
local LoseGuideModel = class(Model, "LoseGuideModel")

function LoseGuideModel:ctor()
    self.data = nil
    LoseGuideModel.super.ctor(self)
end

function LoseGuideModel:Init(data)
    if not data then
        data = cache.getLoseGuideData()
        if data == nil then
            data = {}
        end
    end
    self.data = data
end

function LoseGuideModel:InitLetterData(data)
    self.data = data
    local newData = {}

    for i, optionID in ipairs(self.data) do
        if i <= 2 then
            local loseGuideOptionModel = LoseGuideOptionModel.new(optionID)
            newData[optionID] = loseGuideOptionModel
        end
    end

    self.data = newData
    cache.setLoseGuideData(self.data)
end

function LoseGuideModel:InitWithProtocol(data)
    self:InitLetterData(data)
end

function LoseGuideModel:GetData()
    return self.data
end

return LoseGuideModel