local UnityEngine = clr.UnityEngine
local GameObject = UnityEngine.GameObject
local TextAsset = UnityEngine.TextAsset
local Font = UnityEngine.Font
local Sprite = UnityEngine.Sprite

local ObjectPool = require("ui.scene.match.overlay.ObjectPool")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local AssetFinder = require("ui.common.AssetFinder")
local Skills = require("data.Skills")

local PrefabCache = {}

PrefabCache.isLoaded = nil
PrefabCache.isAllMatchPrefabLoaded = nil
PrefabCache.skillIdsWithPlayerEffect = {"B01_A", "B03_A", "C04_A", "D07_A", "E04_A", "G01_A"}
PrefabCache.skillIdsWithBallEffect = {"B01_A", "D05_A", "C01_A", "C03_A", "D07_B", "D06_A"}

local function loadSkillIcon()
    PrefabCache.skillIcon = {}
    for name, item in pairs(Skills) do
        if item.type == 1 or item.type == 4 or item.type == 5 then
            local icon = AssetFinder.GetSkillIcon(name)
            if icon and icon ~= clr.null then
                PrefabCache.skillIcon[name] = icon
            end
        end
    end
end

function PrefabCache.load()
    if not PrefabCache.isLoaded then
        -- load prefabs used in prematch
        local matchInfoModel = MatchInfoModel.GetInstance()

        PrefabCache.labelBarPool = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/LabelBar.prefab", GameObject))
        PrefabCache.candidateMarkerPool = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/CandidateMarker.prefab", GameObject))

        PrefabCache.ManualOperateGoalSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_icon_SheMen.png")
        PrefabCache.ManualOperatePassSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_icon_ChuanQiu.png")
        PrefabCache.ManualOperateDribbleSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_icon_DaiQiu.png")
        PrefabCache.ManualOperateButtonUpSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_up.png")
        PrefabCache.ManualOperateButtonDownSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_Down.png")
        PrefabCache.manualOperatePanelObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/ManualOperatePanel.prefab")
        PrefabCache.ManualOperatePassObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectHeroTimeDestination.prefab")
        PrefabCache.ManualOperateDribbleObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectHeroTimeBallDestination.prefab")
        PrefabCache.ManualOperateButtonPool = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/ManualOperateButton.prefab"))
        PrefabCache.ManualOperateLabelPool = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/OutOfScreenLabel.prefab"))
        PrefabCache.EffectSkillIcoDribble = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectSkillIcoDribble.prefab")
        PrefabCache.EffectSkillIcoPass = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectSkillIcoPass.prefab")
        PrefabCache.EffectSkillIcoShoot = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectSkillIcoShoot.prefab")

        PrefabCache.PlayerBuffPool = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/SkillEffect/Buff/PlayerBuff.prefab"))
        PrefabCache.PlayerDebuffPool = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/SkillEffect/Buff/PlayerDebuff.prefab"))

        PrefabCache.fightMenu = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/FightMenu.prefab")

        loadSkillIcon()

        if matchInfoModel:IsDemoMatch() ~= true then -- these prefabs will be loaded only for normal match
            local playerTeamData = matchInfoModel:GetPlayerTeamData()
            local opponentTeamData = matchInfoModel:GetOpponentTeamData()

            PrefabCache.playerShirtObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/PlayerShirt.prefab", GameObject)

            -- load prefabs used in overlay UI
            PrefabCache.goalAnimation = res.LoadRes("Assets/CapstonesRes/Game/SkillEffect/Goal/Prefabs/GOAL.prefab", GameObject)

            PrefabCache.EffectSelect = res.LoadRes("Assets/CapstonesRes/Game/Effects/Skill/EffectSelectYellow.prefab")
            PrefabCache.EffectSelectPool = ObjectPool.new(PrefabCache.EffectSelect)

            PrefabCache.isLoaded = true
        end

        local skillIdStatusData = matchInfoModel:GetSkillExistStatus(PrefabCache.skillIdsWithPlayerEffect)
        for skillId, status in pairs(skillIdStatusData) do
            if status then
                PrefabCache[PrefabCache.getSkillEffectPoolName(skillId, "Player")] = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/Effects/Skill/Effect_" .. skillId .. "_Player.prefab"))
            end
        end

        local skillIdStatusData = matchInfoModel:GetSkillExistStatus(PrefabCache.skillIdsWithBallEffect)
        for skillId, status in pairs(skillIdStatusData) do
            if status then
                PrefabCache[PrefabCache.getSkillEffectPoolName(skillId, "Ball")] = ObjectPool.new(res.LoadRes("Assets/CapstonesRes/Game/Effects/Skill/Effect_" .. skillId .. "_Ball.prefab"))
            end
        end
    end
end

function PrefabCache.getSkillEffectPoolName(skillId, suffix)
    return "Effect_" .. skillId .. suffix .. "_Pool"
end

function PrefabCache.getSkillEffectPool(skillId, suffix)
    return PrefabCache[PrefabCache.getSkillEffectPoolName(skillId, suffix)]
end

function PrefabCache.destroy()
    PrefabCache.isLoaded = false

    for i, skillId in ipairs(PrefabCache.skillIdsWithPlayerEffect) do
        local poolName = PrefabCache.getSkillEffectPoolName(skillId, "Player")
        if PrefabCache[poolName] ~= nil then
            PrefabCache[poolName]:destroy()
            PrefabCache[poolName] = nil
        end
    end

    for i, skillId in ipairs(PrefabCache.skillIdsWithBallEffect) do
        local poolName = PrefabCache.getSkillEffectPoolName(skillId, "Ball")
        if PrefabCache[poolName] ~= nil then
            PrefabCache[poolName]:destroy()
            PrefabCache[poolName] = nil
        end
    end

    if PrefabCache.EffectSelectPool ~= nil then
        PrefabCache.EffectSelectPool:destroy()
        PrefabCache.EffectSelectPool = nil
    end

    if PrefabCache.candidateMarkerPool ~= nil then
        PrefabCache.candidateMarkerPool:destroy()
        PrefabCache.candidateMarkerPool = nil
    end

    if PrefabCache.PlayerBuffPool ~= nil then
        PrefabCache.PlayerBuffPool:destroy()
        PrefabCache.PlayerBuffPool = nil
    end

    if PrefabCache.PlayerDebuffPool ~= nil then
        PrefabCache.PlayerDebuffPool:destroy()
        PrefabCache.PlayerDebuffPool = nil
    end

    if PrefabCache.ManualOperateButtonPool ~= nil then
        PrefabCache.ManualOperateButtonPool:destroy()
        PrefabCache.ManualOperateButtonPool = nil
    end

    if PrefabCache.ManualOperateLabelPool ~= nil then
        PrefabCache.ManualOperateLabelPool:destroy()
        PrefabCache.ManualOperateLabelPool = nil
    end

    -- unload prefabs used in prematch
    PrefabCache.playerListItemBuleBg1 = nil
    PrefabCache.playerListItemBuleBg2 = nil
    PrefabCache.playerListItemGreenBg1 = nil
    PrefabCache.playerListItemGreenBg2 = nil
    PrefabCache.playerShirtObj = nil

    -- unload prefabs used in overlay UI
    PrefabCache.skillIcon = nil
    PrefabCache.labelBarPool = nil
    PrefabCache.goalAnimation = nil
    PrefabCache.EffectSelect = nil
    PrefabCache.EffectSkillIcoDribble = nil
    PrefabCache.EffectSkillIcoPass = nil
    PrefabCache.EffectSkillIcoShoot = nil
    PrefabCache.fightMenu = nil

    PrefabCache.ManualOperateGoalSprite = nil
    PrefabCache.ManualOperatePassSprite = nil
    PrefabCache.ManualOperateDribbleSprite = nil
    PrefabCache.ManualOperateButtonUpSprite = nil
    PrefabCache.ManualOperateButtonDownSprite = nil
    PrefabCache.manualOperatePanelObj = nil
    PrefabCache.ManualOperatePassObj = nil
    PrefabCache.ManualOperateDribbleObj = nil
end

return PrefabCache