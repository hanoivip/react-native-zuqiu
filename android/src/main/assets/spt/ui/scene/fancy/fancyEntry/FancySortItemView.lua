local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancySortItemView = class(unity.base)

function FancySortItemView:ctor()
--------Start_Auto_Generate--------
    self.spaceGo = self.___ex.spaceGo
    self.groupBtn = self.___ex.groupBtn
    self.groupIconImg = self.___ex.groupIconImg
    self.groupNameTxt = self.___ex.groupNameTxt
    self.newTipGo = self.___ex.newTipGo
--------End_Auto_Generate----------
end

function FancySortItemView:start()
    self:BindButtonHandler()
end

function FancySortItemView:BindButtonHandler()
    self.groupBtn:regOnButtonClick(function()
        if self.groupClick then
            self.groupClick(self.groupData.sortId)
        end
    end)
end

function FancySortItemView:InitView(groupData, groupClick)
    self.groupClick = groupClick
    self.groupData = groupData
    local sortIndex = groupData.sortIndex
    local mod = math.fmod(sortIndex, 2 )
    GameObjectHelper.FastSetActive(self.spaceGo, mod > 0)
    self.groupNameTxt.text = groupData.sortName
    local imgPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/Common/FancyGroupIcon/%s.png"
    local imgRes = res.LoadRes(string.format(imgPath, groupData.sortIcon))
    self.groupIconImg.overrideSprite = imgRes
    GameObjectHelper.FastSetActive(self.newTipGo, groupData.haveNewCard)
end

return FancySortItemView
