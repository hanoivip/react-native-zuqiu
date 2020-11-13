local UnityEngine = clr.UnityEngine
local Quaternion = UnityEngine.Quaternion
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local TweenExtensions = Tweening.TweenExtensions
local BaseMenuBarModel = require("ui.models.menuBar.BaseMenuBarModel")
local MenuType = require("ui.controllers.home.MenuType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ItemListMenuType = require("ui.controllers.itemList.MenuType")
local ItemListConstants = require("ui.models.itemList.ItemListConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local MenuBarCtrl = class()

function MenuBarCtrl:ctor(viewParent, parentCtrl, moveOutField, menuBarModel)
    assert(viewParent and parentCtrl)
    self.parentCtrl = parentCtrl
    self.playerInfoModel = PlayerInfoModel.new()
    if menuBarModel then
        self.menuBarModel = menuBarModel
    else
        self.menuBarModel = BaseMenuBarModel.new(MenuType.Close)
    end
    local viewObject, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/MenuBar/OptionMenuBar/MenuBar.prefab")
    viewObject.transform:SetParent(viewParent.transform, false)
    self.menuBarView = spt
    self:InitButtonEvent()

    local parentOnEnterScene = parentCtrl.OnEnterScene
    parentCtrl.OnEnterScene = function(parentCtrl)
        if parentOnEnterScene then 
            parentOnEnterScene(parentCtrl)
        end
        self:OnEnterScene()
    end

    local parentOnExitScene = parentCtrl.OnExitScene
    parentCtrl.OnExitScene = function(parentCtrl)
        if parentOnExitScene then 
            parentOnExitScene(parentCtrl)
        end
        self:OnExitScene()
    end

    self:InitView(self.playerInfoModel)
end

function MenuBarCtrl:OnEnterScene()
    -- 没有共享状态的menubar在进入相关功能时需要重置状态
    local loadType = self.parentCtrl.__loadType
    if loadType and(loadType == res.LoadType.Change or loadType == res.LoadType.Push) then
        local resetState = self.menuBarModel:GetResetState()
        if resetState then
            self.menuBarModel:ResetState()
        end
    end
    self:InitMenu()
    self.menuBarView:OnEnterScene()
end

function MenuBarCtrl:OnExitScene()
    self.menuBarView:OnExitScene()
end

function MenuBarCtrl:InitButtonEvent()
    self.menuBarView.clickPlayers = function() self:OnBtnPlayers() end
    self.menuBarView.clickFormation = function() self:OnBtnFormation() end
    self.menuBarView.clickReward = function() self:OnBtnReward() end
    self.menuBarView.clickBall = function() self:OnBtnBall() end
end

function MenuBarCtrl:OnBtnBall()
    self:PlayMenuTeen()
end

function MenuBarCtrl:OnBtnPlayers()
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        local playerListMainCtrl = res.PushSceneImmediate("ui.controllers.playerList.PlayerListMainCtrl", nil, nil, nil, nil, true)
        GuideManager.Show(playerListMainCtrl)
    end)
end

function MenuBarCtrl:OnBtnFormation()
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        local playerTeamsModel = PlayerTeamsModel.new()
        local teamType = self.menuBarModel:GetTeamType()
        playerTeamsModel:SetTeamType(teamType)
        res.PushSceneImmediate("ui.controllers.formation.FormationPageCtrl", playerTeamsModel)
    end)
end

function MenuBarCtrl:OnBtnReward()
    clr.coroutine(function()
        unity.waitForEndOfFrame()
        local rewardListCtrl = res.PushDialogImmediate("ui.controllers.rewards.RewardListCtrl")
        -- GuideManager.Show(rewardListCtrl)
    end)
end

function MenuBarCtrl:InitMenu()
    local controlRect = self.menuBarView.moveArea
    local ballRect = self.menuBarView.btnBall.transform
    local rotato = 0
    local progressHeight = self.menuBarView.moveArea.sizeDelta.y
    local menuState = self.menuBarModel:GetMenuBarState()
    if menuState == MenuType.Close then 
        controlRect.anchoredPosition = Vector2(0, -progressHeight)
        rotato = 0
    else
        controlRect.anchoredPosition = Vector2(0, 0)
        rotato = -179.9
    end
    ballRect.localRotation = Quaternion.Euler(0, 0, rotato)
end

function MenuBarCtrl:PlayMenuTeen()
    local time = 0.6
    local position = 0
    local ease
    local rotato = 0
    local controlRect = self.menuBarView.moveArea
    local progressHeight = self.menuBarView.moveArea.sizeDelta.y
    local ballRect = self.menuBarView.btnBall.transform
    local menuState = self.menuBarModel:GetMenuBarState()
    if menuState == MenuType.Close then 
        self.menuBarModel:SetMenuBarState(MenuType.Open)
        ease = Ease.OutQuint 
        rotato = -179.9
    else
        self.menuBarModel:SetMenuBarState(MenuType.Close)
        ease = Ease.InQuint 
        position = -progressHeight
    end
    local moveInTweener = ShortcutExtensions.DOAnchorPosY(controlRect, position, time)
    TweenSettingsExtensions.SetEase(moveInTweener, ease)
    local rotatoInTweener = ShortcutExtensions.DOLocalRotate(ballRect, Vector3(0, 0, rotato), time)
    TweenSettingsExtensions.SetEase(rotatoInTweener, ease)
end

function MenuBarCtrl:InitView(playerInfoModel)
    if playerInfoModel then
        self.playerInfoModel = playerInfoModel
    end

    self.menuBarView:InitView(self.playerInfoModel)
end

return MenuBarCtrl
