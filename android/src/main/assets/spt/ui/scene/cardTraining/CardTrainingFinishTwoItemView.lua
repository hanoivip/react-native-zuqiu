local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Skills = require("data.Skills")

local CardTrainingFinishTwoItemView = class(unity.base)

function CardTrainingFinishTwoItemView:ctor()
    self.selectdBg = self.___ex.selectdBg
    self.normalBg = self.___ex.normalBg
    self.toggle = self.___ex.toggle
    self.attributeAreaRect = self.___ex.attributeAreaRect

    self.attributePath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/AttributeItem.prefab"
end

function CardTrainingFinishTwoItemView:start()
end

-- option为第几个属性，给服务器传
function CardTrainingFinishTwoItemView:InitView(data, toggleGroup, skillOption)
    self.toggle.group = toggleGroup
    self.toggle.isOn = data.option == skillOption
    local obj, spt = res.Instantiate(self.attributePath)
    obj.transform:SetParent(self.attributeAreaRect, false)
    spt:InitView(data, self.toggle.isOn)

    GameObjectHelper.FastSetActive(self.selectdBg, self.toggle.isOn)
    GameObjectHelper.FastSetActive(self.normalBg, not self.toggle.isOn)

    self.toggle.onValueChanged:AddListener(function (isOn)
        GameObjectHelper.FastSetActive(self.selectdBg, isOn)
        GameObjectHelper.FastSetActive(self.normalBg, not isOn)
        spt:InitView(data, isOn)

        if self.onSkillChanged and isOn then
            self.onSkillChanged()
        end
    end)
end

return CardTrainingFinishTwoItemView
