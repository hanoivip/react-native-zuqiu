local MatchEntryView = class(unity.newscene)

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

local PrefabCache = require("ui.scene.match.overlay.PrefabCache")

function MatchEntryView:ctor()
    MatchEntryView.super.ctor(self)

    PrefabCache.load()

    -- Instantiate FightMenu prefab
    local fightMenu = Object.Instantiate(PrefabCache.fightMenu)
    local matchUISpt = fightMenu:GetComponent(CapsUnityLuaBehav)
    -- fightmenu对外部的引用
    matchUISpt.fightMenuManager.ballEffectObject = self.___ex.ballEffectObject
    matchUISpt.fightMenuManager.___ex.fingerTest.ball = self.___ex.ball
    -- gamehub对fingerTest的引用
    self.___ex.gameHub.fingerTest = matchUISpt.fightMenuManager.___ex.fingerTest
end

return MatchEntryView
