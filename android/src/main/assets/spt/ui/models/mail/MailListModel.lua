local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local MailListModel = class(Model)

function MailListModel:ctor()
    MailListModel.super.ctor(self)
end

function MailListModel:InitWithProtocol(data)
    assert(data)
    local mailMap = {}
    for i, mailData in ipairs(data) do
        mailMap[tostring(mailData.mid)] = mailData
    end
    self.data = data
end

function MailListModel:GetMailList()
    return self.data
end

return MailListModel
