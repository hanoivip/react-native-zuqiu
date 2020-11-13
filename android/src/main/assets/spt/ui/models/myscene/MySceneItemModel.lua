local BuildingBase = require("data.BuildingBase")
local CourtAssetFinder = require("ui.scene.court.CourtAssetFinder")
local Model = require("ui.models.Model")
local MySceneItemModel = class(Model)

function MySceneItemModel:ctor(data)
    MySceneItemModel.super.ctor(self)
    self.data = data
end

function MySceneItemModel:GetName()
    return lang.trans(self.data.label)
end

function MySceneItemModel:GetIcon()
    if BuildingBase[self.data.key] then
        return CourtAssetFinder.GetTechnologyIcon(self.data.key)
    else
        if self.data.key == 'home' then
            return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/MyScene/Bytes/homeIcon.png")
        else
            return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/MyScene/Bytes/awayIcon.png")
        end
    end
end

function MySceneItemModel:SetSelect(name)
    if self.data.key == name then
        self.select = true
    else
        self.select = false
    end
end

function MySceneItemModel:GetSelect()
    return self.select
end

return MySceneItemModel
