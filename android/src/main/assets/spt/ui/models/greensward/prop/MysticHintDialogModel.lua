local Model = require("ui.models.Model")

local MysticHintDialogModel = class(Model, "MysticHintDialogModel")

function MysticHintDialogModel:ctor()
    MysticHintDialogModel.super.ctor(self)
end

function MysticHintDialogModel:Init()
    MysticHintDialogModel.super.Init(self)
end

function MysticHintDialogModel:InitWithProtocol(data)
    self.data = data
end

function MysticHintDialogModel:SetItemModel(greenswardItemModel)
    self.itemModel = greenswardItemModel
end

function MysticHintDialogModel:GetItemModel()
    return self.itemModel
end

function MysticHintDialogModel:GetData()
    return self.data
end

return MysticHintDialogModel
