local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MySceneView = class(unity.base)

function MySceneView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.group = self.___ex.group
end

function MySceneView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self:PlayInAnimator()
    EventSystem.AddEvent("MySceneUpdate", self, self.OnMySceneUpdate)
end

function MySceneView:InitView(mySceneModel)
    self.mySceneModel = mySceneModel
    local staticData = self.mySceneModel:GetStaticData()
    self.sceneList = {}
    self:InitSceneList(staticData.weather)
    self:InitSceneList(staticData.grass)
    self:InitSceneList(staticData.home)
end

function MySceneView:OnMySceneUpdate()
    for k,v in pairs(self.sceneList) do
        v:SetSelect()
    end
end

function MySceneView:InitSceneList(data)
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/MyScene/MySceneList.prefab")
    obj.transform:SetParent(self.group, false)
    spt:InitView(data)
    spt.SetClick = function(modelName, type) self:OnSetClick(modelName, type) end
    table.insert(self.sceneList, spt)
end

function MySceneView:OnSetClick(modelName, type)
    if self.onSetClick then
        self.onSetClick(modelName, type)
    end
end

function MySceneView:OnConfirm()
    self:Close()
end

function MySceneView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function MySceneView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function MySceneView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function MySceneView:Close()
    self:PlayOutAnimator()
    EventSystem.RemoveEvent("MySceneUpdate", self, self.OnMySceneUpdate)
end

return MySceneView