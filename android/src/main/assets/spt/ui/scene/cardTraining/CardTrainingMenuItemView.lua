local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local CardTrainingMenuItemView = class(LuaButton)

function CardTrainingMenuItemView:ctor()
    CardTrainingMenuItemView.super.ctor(self)
    self.bgImg = self.___ex.bgImg
    self.titleTxt = self.___ex.titleTxt
    self.levelArea = self.___ex.levelArea
    self.selectedImg = self.___ex.selectedImg
    self.levelView = self.___ex.levelView
    self.lock = self.___ex.lock
    self.normalSelect = self.___ex.normalSelect
    self.specialSelect = self.___ex.specialSelect

    self:InitCommon()

    -- 9级及以上的用特殊贴图
    self.specialTag = 9
end

function CardTrainingMenuItemView:start()
end

function CardTrainingMenuItemView:InitCommon()
    self.menuBgDirPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/MenuBg/"
    self.menuBgPath = self.menuBgDirPath .. "MenuBg_%s.png"
    self.normalSelectedPath = self.menuBgDirPath .. "NormalSelected.png"
    self.sSSelectedPath = self.menuBgDirPath .. "SSPlusSelected.png"
    self.menuTitleColor = {"3e3e3b", "5f5f42", "725613", "946b08", "705b08", "73680d", "73680d", "73680d", "203262", "203262"}
end

function CardTrainingMenuItemView:InitView(data)
    self.data = data
    self.titleTxt.color = self:ConvertToColor(self.menuTitleColor[tonumber(data.sortOrder)])
    self.bgImg.overrideSprite = res.LoadRes(string.format(self.menuBgPath, tostring(data.sortOrder)))
    if tonumber(data.sortOrder) < self.specialTag then
        self.selectedImg.overrideSprite = res.LoadRes(self.normalSelectedPath)
        table.insert(self.select, self.normalSelect)
    else
        self.selectedImg.overrideSprite = res.LoadRes(self.sSSelectedPath)
        table.insert(self.select, self.specialSelect)
    end
    self.titleTxt.text = data.name
    if not self.data.lock then
        self.levelView:InitView(self.data.subId, tonumber(data.sortOrder) % 2 ~= 0)
    end
    GameObjectHelper.FastSetActive(self.lock, self.data.lock)
    GameObjectHelper.FastSetActive(self.levelView.gameObject, not self.data.lock)
end

function CardTrainingMenuItemView:onDestroy()

end

-- 将美术给的16进制颜色转化成10进制
function CardTrainingMenuItemView:ConvertToColor(colorInfo)
    local r = tonumber(string.sub(colorInfo, 1, 2), 16)
    local g = tonumber(string.sub(colorInfo, 3, 4), 16)
    local b = tonumber(string.sub(colorInfo, 5, 6), 16)

    return Color(r / 255, g / 255, b / 255, 1)
end

return CardTrainingMenuItemView

