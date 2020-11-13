local Model = require("ui.models.Model")

local GuildLogoItemModel = class(Model, "GuildLogoItemModel")


function GuildLogoItemModel:ctor(data)
    self.data = data
    self.isSelected = false
end

function GuildLogoItemModel:GetPicIndex()
    return self.data.picIndex
end

function GuildLogoItemModel:GetIndex()
    return self.data.index
end

function GuildLogoItemModel:GetSelectedState()
    return self.isSelected
end

function GuildLogoItemModel:SetSelectedState(isSelected)
    self.isSelected = isSelected
end

return GuildLogoItemModel