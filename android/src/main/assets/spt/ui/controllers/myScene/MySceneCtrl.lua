local BaseCtrl = require("ui.controllers.BaseCtrl")
local MySceneCtrl = class(BaseCtrl, "MySceneCtrl")
MySceneCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/MyScene/MySceneView.prefab"

function MySceneCtrl:Init()
    self.mySceneModel = require("ui.models.myscene.MySceneModel").new()
end

function MySceneCtrl:Refresh()
    self:InitView()
end

function MySceneCtrl:InitView()
	self.view.onSetClick = function(modelName, name) self:SetClick(modelName, name) end
    self.view:InitView(self.mySceneModel)
end

function MySceneCtrl:SetClick(modelName, name)
	for k, v in pairs(self.mySceneModel:GetStaticData()) do
		if v:GetName() == modelName then
			self:ReqSetMyScene(k, name)
		end
	end
end

function MySceneCtrl:ReqSetMyScene(type, name)
	self.view:coroutine(function()
		local data = {}
		for k, v in pairs(self.mySceneModel:GetData()) do
			if k == type then
				data[k] = name
			else
				data[k] = v
			end
		end
		local response = req.setScenario({scenario = data})
		if api.success(response) then
			self.mySceneModel:InitWithProtocol(data)
			self.mySceneModel:SetSelect()
			EventSystem.SendEvent("MySceneUpdate")
		end
	end)
end

return MySceneCtrl