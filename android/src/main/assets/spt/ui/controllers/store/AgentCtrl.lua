local AgentPageType = require("ui.scene.store.AgentPageType")
local PlayerExchangeCtrl = require("ui.controllers.store.PlayerExchangeCtrl")
local PlayerLeadIntoAidCtrl = require("ui.controllers.store.PlayerLeadIntoAidCtrl")

local AgentCtrl = class(nil, "AgentCtrl")

function AgentCtrl:ctor(view, content)
    self:Init(content)
end

function AgentCtrl:Init(content)
    local agentObject, agentSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/Agent.prefab")
    agentObject.transform:SetParent(content.transform, false)
    self.agentView = agentSpt
    self.agentView.clickPage = function(key)
        self:OnBtnPage(key)
    end
    self.pageMap = {}
    self.page = AgentPageType.Aid
end

function AgentCtrl:InitView(model, lastTime)
    local page = AgentPageType.Aid
    self.agentView:InitView(model, page, lastTime)
end

function AgentCtrl:OnBtnPage(key)
    if self.pageMap[self.page] then 
        self.pageMap[self.page]:ShowPageVisible(false)
    end

    if not self.pageMap[key] then 
        if key == AgentPageType.Exchange then 
            self.pageMap[key] = PlayerExchangeCtrl.new(nil, self.agentView.pageArea)
        elseif key == AgentPageType.Aid then 
            self.pageMap[key] = PlayerLeadIntoAidCtrl.new(nil, self.agentView.pageArea)
        end
        self.pageMap[key]:EnterScene()
    end
    self.pageMap[key]:InitView()

    self.pageMap[key]:ShowPageVisible(true)
    self.page = key
end

return AgentCtrl
