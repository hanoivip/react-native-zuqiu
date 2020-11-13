local GameObjectHelper = require("ui.common.GameObjectHelper")
local SubBaseSupporterCtrl = class(unity.base, "SubBaseSupporterCtrl")

function SubBaseSupporterCtrl:ctor(subSupporterModel, parentTrans, prefabPath)
    self.prefabPath = prefabPath
    self.model = subSupporterModel
    self.parentTrans = parentTrans
    self:InstancePrefab()
    self:Init()
    self:OnEnterScene()
end

function SubBaseSupporterCtrl:Init()

end

function SubBaseSupporterCtrl:InstancePrefab()
    self.obj, self.view = res.Instantiate(self.prefabPath)
    self.obj.transform:SetParent(self.parentTrans, false)
end

function SubBaseSupporterCtrl:SetViewState(state)
    GameObjectHelper.FastSetActive(self.obj, state)
end

function SubBaseSupporterCtrl:Refresh()
    self.view:InitView(self.model)
end

function SubBaseSupporterCtrl:OnEnterScene()
    self.view:EnterScene()
end

function SubBaseSupporterCtrl:OnExitScene()
    self.view:ExitScene()
end

return SubBaseSupporterCtrl
