local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local MemoryPageCtrl = class(BaseCtrl, "MemoryPageCtrl")

function MemoryPageCtrl:ctor(view, content)
    self:Init(content)
end

function MemoryPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Memory/MemoryPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
end

function MemoryPageCtrl:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.pageView:InitView(cardDetailModel)
end

function MemoryPageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function MemoryPageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function MemoryPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return MemoryPageCtrl
