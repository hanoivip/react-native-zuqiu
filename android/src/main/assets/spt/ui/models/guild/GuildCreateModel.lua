local Model = require("ui.models.Model")
local GuildLogo = require("data.GuildLogo")

local GuildCreateModel = class(Model, "GuildCreateModel")


function GuildCreateModel:ctor()
    self.currentIndex = 1
    self.chooseIndex = 1
    self.price = 500
end

function GuildCreateModel:GetIconInfo()
    local list = {}

    for k, v in pairs(GuildLogo) do
        v.index = tonumber(k)
        table.insert(list, v)
    end

    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

function GuildCreateModel:GetPrice()
    return self.price
end

function GuildCreateModel:GetCurrentIndex()
    return self.currentIndex
end

function GuildCreateModel:SetCurrentIndex(index)
    self.currentIndex = index
end

function GuildCreateModel:GetChooseIndex()
    return self.chooseIndex
end

function GuildCreateModel:SetChooseIndex(index)
    self.chooseIndex = index
end

return GuildCreateModel