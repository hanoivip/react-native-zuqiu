local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistWarMapItemState = require("ui.models.guild.guildMistWar.GuildMistWarMapItemState")
local MistMapItemView = class(LuaButton)

function MistMapItemView:ctor()
    MistMapItemView.super.ctor(self)
--------Start_Auto_Generate--------
    self.openGo = self.___ex.openGo
    self.normalGo = self.___ex.normalGo
    self.levelImg = self.___ex.levelImg
    self.buildNameTxt = self.___ex.buildNameTxt
    self.capturedGo = self.___ex.capturedGo
    self.emptyBuildingGo = self.___ex.emptyBuildingGo
    self.emptyGo = self.___ex.emptyGo
    self.mistGo = self.___ex.mistGo
    self.chooseGo = self.___ex.chooseGo
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
    self.animator = self.___ex.animator
    self.mapItemLevel = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildMistWar/GuildWar_MistBuild%d.png"
end

function MistMapItemView:start()
    self:RegBtnEvent()
end

function MistMapItemView:RegBtnEvent()
    local data = {
        clickThreshold = 1,   -- 识别点击还是连续按下的时间阈值
        startSpeed = 1,    -- 一开始的时候每秒钟的调用次数
        acceleration = 0,   -- 加速度，执行的越来越快
        step = true,    -- 当速度很大的时候是否通过降低速度让count连续增长，为false的时候count会跳跃增长
        clickCallback = self.clickCallback,    -- 点击执行的回调方法
        durationCallback = self.pressCallback,    -- 连续按下执行的回调方法，count为当前的执行次数
    }
    self:regOnButtonPressing(data)
    self:regOnButtonUp(self.upCallback)
    self:regOnBeginDrag(self.dragStartCallback)
    self:regOnDrag(self.dragCallback)
    self:regOnEndDrag(self.dragEndCallback)
end

function MistMapItemView:InitView(mapItemIndex, mistMapModel)
    self.mapItemIndex = mapItemIndex
    self.mistMapModel = mistMapModel
    self.mapItemData = mistMapModel:GetStaticMapDataByIndex(mapItemIndex)
    self.isEmptyPos = mistMapModel:IsEmptyPos(mapItemIndex)
    self.isKingPos = mistMapModel:IsKingPos(mapItemIndex)
    self.isDefender = mistMapModel:GetIsDefender()
    local itemState = mistMapModel:GetMapItemStateByIndex(mapItemIndex)
    local guardData = self.mistMapModel:GetGuardDataByIndex(mapItemIndex)
    local damage = guardData.damage
    local defendLife = mistMapModel:GetDefendLife()
    local level = guardData.level or 0
    local levelPath = string.format(self.mapItemLevel, level)
    self.levelImg.overrideSprite = res.LoadRes(levelPath)
    self:SetName(guardData)
    self:SetState(itemState)
    self:SetPress(false)
    self:SetChoose(false)
end

function MistMapItemView:InitMapPos()
    self.mapPos = {}
    local count = self.mapPosTrans.childCount
    for i = 1, count do
        local index = tostring(i)
        self.mapPos[index] = self.mapPosTrans:GetChild(i - 1).transform
        GameObjectHelper.FastSetActive(self.mapPos[index].gameObject, false)
    end
end

function MistMapItemView:SetName(guardData)
    local name = self:GetName(guardData)
    self.buildNameTxt.text = name
end

function MistMapItemView:SetState(itemState)
    if GuildMistWarMapItemState.Hide == itemState then
        GameObjectHelper.FastSetActive(self.gameObject, false)
        return
    end

    local isMist = GuildMistWarMapItemState.Mist == itemState
    GameObjectHelper.FastSetActive(self.mistGo, isMist )
    GameObjectHelper.FastSetActive(self.openGo, not isMist)
    GameObjectHelper.FastSetActive(self.normalGo, false)
    GameObjectHelper.FastSetActive(self.capturedGo, false)
    GameObjectHelper.FastSetActive(self.emptyBuildingGo, false)
    GameObjectHelper.FastSetActive(self.emptyGo, false)

    if self.isDefender then
        GameObjectHelper.FastSetActive(self.mistGo, false )
        GameObjectHelper.FastSetActive(self.openGo, true)
        GameObjectHelper.FastSetActive(self.normalGo, true)
        GameObjectHelper.FastSetActive(self.emptyGo, false)
    end

    if self.isEmptyPos then
        GameObjectHelper.FastSetActive(self.emptyBuildingGo, true)
        GameObjectHelper.FastSetActive(self.normalGo, false)
        return
    end

    local guardData = self.mistMapModel:GetGuardDataByIndex(self.mapItemIndex)
    if GuildMistWarMapItemState.Empty == itemState then
        GameObjectHelper.FastSetActive(self.normalGo, true)
        GameObjectHelper.FastSetActive(self.emptyGo, not self.isDefender)
        local name = self:GetName(guardData)
        self.buildNameTxt.text = name
    elseif GuildMistWarMapItemState.Occupy == itemState then
        GameObjectHelper.FastSetActive(self.normalGo, true)
        local name = self:GetName(guardData)
        self.buildNameTxt.text = name
    elseif GuildMistWarMapItemState.Captured == itemState then
        GameObjectHelper.FastSetActive(self.normalGo, true)
        GameObjectHelper.FastSetActive(self.capturedGo, true)
        local name = self:GetName(guardData)
        self.buildNameTxt.text = name
    end
    if self.isKingPos then
        GameObjectHelper.FastSetActive(self.normalGo, true)
        GameObjectHelper.FastSetActive(self.mistGo, false)
        GameObjectHelper.FastSetActive(self.openGo, true)
    end
end

function MistMapItemView:GetName(guardData)
    local nameStr = ""
    if guardData.name then
        nameStr = guardData.name
    else
        local level = guardData.level
        if level then
            nameStr = lang.transstr("mist_quality_" .. level)
        end
    end
    return nameStr
end

function MistMapItemView:SetPress(state)
    if state then
        self.canvasGroup.alpha = 0.5
    else
        self.canvasGroup.alpha = 1
    end
end

function MistMapItemView:PlayMapItemOpenAnim()
    self.animator:Play("Open")
end

function MistMapItemView:SetChoose(state)
    GameObjectHelper.FastSetActive(self.chooseGo, state)
end

return MistMapItemView
