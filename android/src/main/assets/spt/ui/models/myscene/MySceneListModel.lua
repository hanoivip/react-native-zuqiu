local BuildingBase = require("data.BuildingBase")
local Model = require("ui.models.Model")
local MySceneListModel = class(Model)

function MySceneListModel:ctor(name, list)
    MySceneListModel.super.ctor(self)
    self.name = name
    self.data = {}
    for i = 1, #list do
    	self.data[i] = require("ui.models.myscene.MySceneItemModel").new(list[i])
    end
end

function MySceneListModel:GetName()
    return self.name
end

function MySceneListModel:GetData()
	return self.data
end

function MySceneListModel:SetSelect(name)
	for k, v in pairs(self.data) do
		v:SetSelect(name)
	end
end

return MySceneListModel
