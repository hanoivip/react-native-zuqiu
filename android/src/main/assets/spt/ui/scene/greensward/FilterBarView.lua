local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local FilterBarView = class(LuaButton)

function FilterBarView:ctor()
    FilterBarView.super.ctor(self)
    --------Start_Auto_Generate--------
    self.lineGo = self.___ex.lineGo
    self.slectGo = self.___ex.slectGo
    self.lockGo = self.___ex.lockGo
    self.textTxt = self.___ex.textTxt
    --------End_Auto_Generate----------
    self.slectImage = self.___ex.slectImage
    self.isLock = false
    self:regOnButtonClick(function()
        self:OnFilterBarClick()
    end)
end

local fixWidth = 102
function FilterBarView:InitView(index, greenswardBuildModel)
    self.index = index
    self.textTxt.text = lang.trans("floor_order", index)
    local totalFloor = greenswardBuildModel:GetTotalFloor()
    local currentFloor = greenswardBuildModel:GetCurrentFloor()
    local openFloor = greenswardBuildModel:GetOpenFloor()
    local selectImageName = "Gird"
    if index == 1 then
        selectImageName = "Gird_U"
    elseif index == totalFloor then
        selectImageName = "Gird_L"
    end
    self.slectImage.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Common/" .. selectImageName .. ".png")
    self.slectImage:SetNativeSize()
    self.slectImage.transform.sizeDelta = Vector2(fixWidth, self.slectImage.transform.sizeDelta.y)

    local isLock = tobool(index > openFloor)
    local isShowLine = tobool(index ~= 1)
    local isSelect = tobool(index == currentFloor)
    self.isSelect = isSelect
    GameObjectHelper.FastSetActive(self.lineGo, isShowLine)
    GameObjectHelper.FastSetActive(self.lockGo, isLock)
    self:ChangeSelectState(isSelect)
    local preColor = self.textTxt.color
    self.textTxt.color = isLock and Color.gray or preColor
    self.isLock = isLock
end

function FilterBarView:ChangeSelectState(isSelct)
    self.textTxt.color = isSelct and Color(0.21, 0.17, 0.17, 1) or Color.white
    GameObjectHelper.FastSetActive(self.slectGo, isSelct)
end

function FilterBarView:OnFilterBarClick()
    if not self.isLock and not self.isSelect then
        EventSystem.SendEvent("GreenswardPlaneFlyToAnArea", self.index)
    end
end

return FilterBarView
