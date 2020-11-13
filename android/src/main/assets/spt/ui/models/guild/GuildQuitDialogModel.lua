local Model = require("ui.models.Model")

local GuildQuitDialogModel = class(Model, "GuildQuitDialogModel")

function GuildQuitDialogModel:ctor()
    
end

function GuildQuitDialogModel:SetTitle(str)
    self.title = str
end

function GuildQuitDialogModel:SetContent(str)
    self.content = str
end

function GuildQuitDialogModel:GetTitle()
    return self.title
end

function GuildQuitDialogModel:GetContent()
    return self.content
end

return GuildQuitDialogModel