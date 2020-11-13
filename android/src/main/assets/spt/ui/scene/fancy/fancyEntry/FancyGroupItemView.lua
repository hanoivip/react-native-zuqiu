local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyGroupItemView = class(unity.base)

function FancyGroupItemView:ctor()
--------Start_Auto_Generate--------
    self.spaceGo = self.___ex.spaceGo
    self.groupBtn = self.___ex.groupBtn
    self.groupIconImg = self.___ex.groupIconImg
    self.groupNameTxt = self.___ex.groupNameTxt
--------End_Auto_Generate----------
end

function FancyGroupItemView:start()
    self:BindButtonHandler()
end

function FancyGroupItemView:BindButtonHandler()
    self.groupBtn:regOnButtonClick(function()
        if self.groupClick then
            self.groupClick()
        end
    end)
end

function FancyGroupItemView:InitView(groupData, groupClick)
    self.groupClick = groupClick
    local sortId = groupData.groupId
    local mod = math.fmod( sortId, 2 )
    GameObjectHelper.FastSetActive(self.spaceGo, mod > 0)
    self.groupNameTxt.text = groupData.groupName
    local imgPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/Common/FancyGroupIcon/%s.png"
    local imgRes = res.LoadRes(string.format(imgPath, groupData.groupIcon))
    self.groupIconImg.overrideSprite = imgRes
end

return FancyGroupItemView
