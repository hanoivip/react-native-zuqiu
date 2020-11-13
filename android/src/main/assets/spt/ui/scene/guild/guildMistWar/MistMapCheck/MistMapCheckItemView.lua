local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MistMapCheckItemView = class(LuaButton)

function MistMapCheckItemView:ctor()
    MistMapCheckItemView.super.ctor(self)
--------Start_Auto_Generate--------
    self.normalGo = self.___ex.normalGo
    self.levelImg = self.___ex.levelImg
    self.buildNameTxt = self.___ex.buildNameTxt
    self.mistGo = self.___ex.mistGo
    self.emptyGo = self.___ex.emptyGo
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
    self.mapItemLevel = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildMistWar/GuildWar_MistBuild%d.png"
end

function MistMapCheckItemView:start()
    self:RegBtnEvent()
end

function MistMapCheckItemView:RegBtnEvent()
    self:regOnButtonClick(function()
        self.clickCallback(self.mapItemIndex)
    end)
end

function MistMapCheckItemView:InitView(mapItemIndex, mapData)
    mapItemIndex = tostring(mapItemIndex)
    self.mapItemIndex = mapItemIndex
    local mapPosList = mapData.mapPosList
    local emptyMapPosList = mapData.emptyMapPosList
    local default = mapData.default
    self.isEmpty = tobool(emptyMapPosList[mapItemIndex])
    self.isClosed = (not self.isEmpty) and (not mapPosList[mapItemIndex])
    if self.isClosed then
        
    end
    
    if self.isEmpty then

    else
        local level = mapPosList[mapItemIndex].level
        local levelPath = string.format(self.mapItemLevel, level)
        self.levelImg.overrideSprite = res.LoadRes(levelPath)
    end
    GameObjectHelper.FastSetActive(self.emptyGo, self.isEmpty)
    GameObjectHelper.FastSetActive(self.normalGo, not self.isEmpty)
    GameObjectHelper.FastSetActive(self.mistGo, false)
    self.buildNameTxt.text = mapItemIndex
end

function MistMapCheckItemView:InitMapPos()
    self.mapPos = {}
    local count = self.mapPosTrans.childCount
    for i = 1, count do
        local index = tostring(i)
        self.mapPos[index] = self.mapPosTrans:GetChild(i - 1).transform
        GameObjectHelper.FastSetActive(self.mapPos[index].gameObject, false)
    end
end

function MistMapCheckItemView:SetOpenState(state)
    if state then
        if self.isEmpty then
            GameObjectHelper.FastSetActive(self.normalGo, false)
            GameObjectHelper.FastSetActive(self.emptyGo, true)
        else
            GameObjectHelper.FastSetActive(self.normalGo, true)
            GameObjectHelper.FastSetActive(self.emptyGo, false)
        end
    else
        GameObjectHelper.FastSetActive(self.mistGo, state)
    end
    GameObjectHelper.FastSetActive(self.mistGo, not state)
end

return MistMapCheckItemView
