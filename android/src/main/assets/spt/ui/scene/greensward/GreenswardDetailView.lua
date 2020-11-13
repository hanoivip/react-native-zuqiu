local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local Input = UnityEngine.Input
local Timer = require('ui.common.Timer')
local GreenswardResourceCache = require("ui.scene.greensward.GreenswardResourceCache")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local GreenswardBuildModel = require("ui.models.greensward.build.GreenswardBuildModel")
local AssetFinder = require("ui.common.AssetFinder")
local GreenswardEventActionEffectHelper = require("ui.models.greensward.event.GreenswardEventActionEffectHelper")
local GreenswardDetailView = class(unity.newscene)

local AVATAR_PATH = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Avatar/GreenswardAvatar.prefab"

function GreenswardDetailView:ctor()
    GreenswardDetailView.super.ctor(self)
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.buildView = self.___ex.buildView
--------Start_Auto_Generate--------
    self.effectImg = self.___ex.effectImg
    self.bagBtn = self.___ex.bagBtn
    self.powerBtn = self.___ex.powerBtn
    self.storeBtn = self.___ex.storeBtn
    self.planeBtn = self.___ex.planeBtn
    self.rankBtn = self.___ex.rankBtn
    self.introduceBtn = self.___ex.introduceBtn
    self.curveBtn = self.___ex.curveBtn
    self.drinkContentTrans = self.___ex.drinkContentTrans
    self.floorTrans = self.___ex.floorTrans
    self.floorContentTrans = self.___ex.floorContentTrans
    self.expandGo = self.___ex.expandGo
    self.expandArrowTrans = self.___ex.expandArrowTrans
    self.expandTxt = self.___ex.expandTxt
    self.moraleAreaTrans = self.___ex.moraleAreaTrans
    self.regionAndFloorTxt = self.___ex.regionAndFloorTxt
    self.completeRateTxt = self.___ex.completeRateTxt
    self.rewardRedPointGo = self.___ex.rewardRedPointGo
    self.rewardDetailBtn = self.___ex.rewardDetailBtn
    self.seasonInfoGo = self.___ex.seasonInfoGo
    self.seasonTxt = self.___ex.seasonTxt
    self.scoreTxt = self.___ex.scoreTxt
    self.startNewSeasonBtn = self.___ex.startNewSeasonBtn
    self.disPlayBtn = self.___ex.disPlayBtn
--------End_Auto_Generate----------
    self.btnExpand = self.___ex.btnExpand
    self.floorMask = self.___ex.floorMask
    self.planeArea = self.___ex.planeArea
    self.btnView = self.___ex.btnView
    -- 左上角周期详情
    self.objCycleDetail = self.___ex.objCycleDetail
    self.txtRoundLeft = self.___ex.txtRoundLeft
    self.txtCurrCycle = self.___ex.txtCurrCycle
    self.imgWeaIcon = self.___ex.imgWeaIcon
    self.txtWea = self.___ex.txtWea
    self.imgStarIcon = self.___ex.imgStarIcon
    self.txtStar = self.___ex.txtStar
    self.btnCycleDetail = self.___ex.btnCycleDetail
    self.currentPowerTxt = self.___ex.currentPowerTxt
    self.currentBuffTxt = self.___ex.currentBuffTxt
    self.objContent = self.___ex.objContent
    self.rctAvatar = self.___ex.rctAvatar
    self.btnAvatar = self.___ex.btnAvatar
    self.moraleSupplyRedPointGo = self.___ex.moraleSupplyRedPointGo
    self.animCycleDetail = self.___ex.animCycleDetail
    self.normalCycleDetail = self.___ex.normalCycleDetail
    self.graphicRay = self.___ex.graphicRay

    self.stepsMap = {}
    self.drinkSpt = nil
    self.floorSpt = nil
    self.prePoint = 0
    self.greenswardResourceCache = GreenswardResourceCache.Create()
end

function GreenswardDetailView:start()
    self.btnAvatar:regOnButtonClick(function()
        self:OnBtnAvatar()
    end)
    self.btnView:regOnButtonClick(function()
        self:OnViewClick()
    end)
    self.planeBtn:regOnButtonClick(function()
        self:OnPlaneClick()
    end)
    self.bagBtn:regOnButtonClick(function()
        self:OnBagClick()
    end)
    self.powerBtn:regOnButtonClick(function()
        self:OnPowerClick()
    end)
    self.storeBtn:regOnButtonClick(function()
        self:OnStoreClick()
    end)
    self.introduceBtn:regOnButtonClick(function()
        self:OnIntroduceClick()
    end)
    self.btnCycleDetail:regOnButtonClick(function()
        self:OnBtnCycleDetailClick()
    end)
    self.rankBtn:regOnButtonClick(function()
        self:OnRankClick()
    end)
    self.rewardDetailBtn:regOnButtonClick(function()
        self:OnRewardDetailClick()
    end)
    self.startNewSeasonBtn:regOnButtonClick(function()
        self:OnStartNewSeasonClick()
    end)
    self.btnExpand:regOnButtonClick(function()
        self:OnBuffExpandClick()
    end)
    self.curveBtn:regOnButtonClick(function()
        self:OnHideClick()
    end)
    self.disPlayBtn:regOnButtonClick(function()
        self:OnDisPlayClick()
    end)

    GameObjectHelper.FastSetActive(self.objCycleDetail.gameObject, false)
    self:StopCycleChangeAnim()

    Input.multiTouchEnabled = true
end

function GreenswardDetailView:InitView(greenswardBuildModel, weaBuildModel, starBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    self.weaBuildModel = weaBuildModel
    self.starBuildModel = starBuildModel
    self.buildView:InitView(greenswardBuildModel, self.greenswardResourceCache)
    self:InitAvatar()
    self:InitCycleDetail()
    self:InitBuff()
    self:InitPower()
    self:CompleteRateDetail()
    self:CheckWelcome()
    self:InitSeason()
    self:InitMoraleRecieve()
    self:IsShowGreenswardPoint()
    self:IsShowMoraleSupplyRedPoint()
    self:InitHudState(greenswardBuildModel)
end

function GreenswardDetailView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function GreenswardDetailView:InitHudState(greenswardBuildModel)
    local hasRetract = greenswardBuildModel:GetHudRetract()
    self:HandleHudBar(hasRetract)
end

function GreenswardDetailView:OnHideClick()
    self.greenswardBuildModel:SetHudRetract(true)
    self:HandleHudBar(true)
end

function GreenswardDetailView:OnDisPlayClick()
    self.greenswardBuildModel:SetHudRetract(false)
    self:HandleHudBar(false)
end

function GreenswardDetailView:HandleHudBar(hasRetract)
    self:DisplayUIContent(not hasRetract)
    GameObjectHelper.FastSetActive(self.disPlayBtn.gameObject, hasRetract)
end

-- 初始化玩家形象
function GreenswardDetailView:InitAvatar()
    if not self.avatarSpt then
        res.ClearChildren(self.rctAvatar.transform)
        local obj, spt = res.Instantiate(AVATAR_PATH)
        if obj ~= nil and spt ~= nil then
            obj.transform:SetParent(self.rctAvatar.transform, false)
            self.avatarSpt = spt
            self.avatarSpt:InitView(self.greenswardBuildModel:GetCurrAvatarPicIndex())
        end
    else
        self.avatarSpt:InitView(self.greenswardBuildModel:GetCurrAvatarPicIndex())
    end
end

function GreenswardDetailView:InitCycleDetail()
    GameObjectHelper.FastSetActive(self.objCycleDetail.gameObject, true)
    -- 剩余回合
    self.txtRoundLeft.text = tostring(self.greenswardBuildModel:GetRoundLeft())
    -- 当前周期
    self.txtCurrCycle.text = lang.transstr("greensward_cycle", self.greenswardBuildModel:GetCurrCycle())
    -- 天气图标
    self.imgWeaIcon.overrideSprite = self.weaBuildModel:GetCurrWeaIconRes()
    -- 当前天气
    self.txtWea.text = self.weaBuildModel:GetCurrWeaName() .. " + "
    -- 星象图标
    self.imgStarIcon.overrideSprite = AssetFinder.GetGreenswardStarIcon(self.starBuildModel:GetCurrStarIconIndex())
    -- 形象名仔
    self.txtStar.text = self.starBuildModel:GetCurrStarName()
end

-- 周期更换回调事件
function GreenswardDetailView:OnGreenswardCycleUpdate()
    self:PlayCycleChangeAnim()
end

-- 播放周期切换的特效
function GreenswardDetailView:PlayCycleChangeAnim()
    self.animCycleDetail:Rebind()
    GameObjectHelper.FastSetActive(self.animCycleDetail.gameObject, true)
    GameObjectHelper.FastSetActive(self.normalCycleDetail.gameObject, false)
end

-- 停止周期切换的特效
function GreenswardDetailView:StopCycleChangeAnim()
    GameObjectHelper.FastSetActive(self.animCycleDetail.gameObject, false)
    GameObjectHelper.FastSetActive(self.normalCycleDetail.gameObject, true)
end

function GreenswardDetailView:MoveConstructionPos(greenswardBuildModel)
    local row, col = greenswardBuildModel:GetJumpGirdNumber()
    self.buildView:OnMoveConstruction(row, col)
end

-- base数据更新后更新面板相关
function GreenswardDetailView:GreenswardInfoUpdate()
    if self.onInfoUpdate ~= nil and type(self.onInfoUpdate) == "function" then
        self.onInfoUpdate()
    end
    -- 刷新面板
    self:InitCycleDetail()

    -- 刷新Buff
    self:InitBuff()

    -- 刷新战力
    self:InitPower()

    -- 完成度
    self:CompleteRateDetail()

    -- 新赛季
    self:CheckWelcome()

    -- 是否可以领取奖励
    self:InitMoraleRecieve()
end

function GreenswardDetailView:GetDrinkRes()
    if not self.drinkRes then 
        self.drinkRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/DrinkBuff.prefab")
    end
    return self.drinkRes
end

function GreenswardDetailView:GetFloorRes()
    if not self.floorRes then 
        self.floorRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/TotalFloorBuff.prefab")
    end
    return self.floorRes
end

function GreenswardDetailView:GetMoraleRecieveRes()
    if not self.moraleRes then
        self.moraleRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/MoraleRecieveFrame.prefab")
    end
    return self.moraleRes
end

function GreenswardDetailView:InitMoraleRecieve()
    local moraleRecieveStatus = self.greenswardBuildModel:GetMoraleRecieveStatus()
    if moraleRecieveStatus then
        if not self.moraleSpt then
            local objRes = self:GetMoraleRecieveRes()
            local obj = Object.Instantiate(objRes)
            local script = res.GetLuaScript(obj)
            obj.transform:SetParent(self.moraleAreaTrans, false)
            self.moraleSpt = script
        end
        self.moraleSpt:InitView(self.greenswardBuildModel)
    elseif self.moraleSpt then
        Object.Destroy(self.moraleSpt.gameObject)
        self.moraleSpt = nil
    end
end

--如果获得的BUFF效果为负，最多也只会按照-99%来算
local MinBuffNum = -99
function GreenswardDetailView:InitPower()
    local activeBuffs = self.greenswardBuildModel:GetActiveBuffPlus()
    local playerPower = self.greenswardBuildModel:GetPlayerPower()

    local symbol = activeBuffs >= 0 and "+" or ""
    if activeBuffs == 0 then
        self.currentBuffTxt.text = lang.transstr("current_buff", lang.transstr("none"))
    else
        local attributeTxt = lang.transstr("allAttribute") .. symbol .. activeBuffs .. "%"
        self.currentBuffTxt.text = lang.transstr("current_buff", attributeTxt)
    end
    local fixBuffs = activeBuffs
    if activeBuffs < MinBuffNum then
        fixBuffs = MinBuffNum
    end
    local currentPower = math.floor(playerPower * (1 + fixBuffs / 100))
    self.currentPowerTxt.text = lang.trans("current_power", currentPower)
end

function GreenswardDetailView:InitBuff()
    local buff = self.greenswardBuildModel:GetBuff()
    local drinkBuff = buff.drink
    -- 饮料
    if drinkBuff then
        if not self.drinkSpt then
            local objRes = self:GetDrinkRes()
            local obj = Object.Instantiate(objRes)
            local script = res.GetLuaScript(obj)
            obj.transform:SetParent(self.drinkContentTrans, false)
            self.drinkSpt = script
        else
            GameObjectHelper.FastSetActive(self.drinkSpt.gameObject, true)
        end
        self.drinkSpt:InitView(drinkBuff, self.greenswardResourceCache)
    end
    GameObjectHelper.FastSetActive(self.drinkContentTrans.gameObject, drinkBuff)
    -- 楼层buff
    local floorBuff = buff.floor
    local buffNum = 0
    local currentFloor = self.greenswardBuildModel:GetCurrentFloor()
    if floorBuff then
        for floor, v in pairs(floorBuff) do
            floor = tonumber(floor)
            if tonumber(floor) <= currentFloor then
                buffNum = buffNum + 1
            end
        end
        if buffNum > 0 then
            if self.floorSpt then
                GameObjectHelper.FastSetActive(self.floorSpt.gameObject, true)
            else
                local objRes = self:GetFloorRes()
                local obj = Object.Instantiate(objRes)
                local script = res.GetLuaScript(obj)
                obj.transform:SetParent(self.floorContentTrans, false)
                self.floorSpt = script
            end
            self.floorSpt:InitView(currentFloor, floorBuff, self.greenswardResourceCache)
            self.floorSpt:DisableBg()
        end
    end
    local hasFloorBuff = buffNum > 0
    local hasMultipleBuff = buffNum > 0
    local bottom = hasMultipleBuff and -24 or 0
    self.floorContentTrans.offsetMin = Vector2(self.floorContentTrans.offsetMin.x, bottom)
    GameObjectHelper.FastSetActive(self.floorTrans.gameObject, hasFloorBuff)
    GameObjectHelper.FastSetActive(self.expandGo.gameObject, hasMultipleBuff)
end

function GreenswardDetailView:CompleteRateDetail()
    local regionName = self.greenswardBuildModel:GetRegionName()
    local floor = self.greenswardBuildModel:GetCurrentFloor()
    local cpl = self.greenswardBuildModel:GetCurrentFloorCpl()
    local point = self.greenswardBuildModel:GetPoint()
    -- 战区和当前层数
    self.regionAndFloorTxt.text = regionName .. ":" .. lang.transstr("floor_order", floor)
    -- 当前层数的完成度
    self.completeRateTxt.text = lang.transstr("adventure_complete_rate") .. cpl .. "%"
    -- 当前层数的积分
    self.scoreTxt.text = lang.trans("dream_my_score", point)
    local initColor = Color(253 / 255, 243 / 255, 195 / 255)
    self.myScoreSequence = GreenswardEventActionEffectHelper.BlingExtensions(point, self.prePoint, self.myScoreSequence, self.scoreTxt, initColor)
    self.prePoint = point
end

function GreenswardDetailView:CheckWelcome()
    local welcome = self.greenswardBuildModel:GetWelcome()
    if welcome and type(welcome) == "table" then
        local welcomePath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/WelcomePage.prefab"
        local dialog, dialogcomp = res.ShowDialog(welcomePath, "camera", false, true)
        dialogcomp.contentcomp:InitView(self.greenswardBuildModel)
        self.greenswardBuildModel:DeleteWelcome()
    end
end

function GreenswardDetailView:InitSeason()
    local point = self.greenswardBuildModel:GetPoint()
    self:RefreshSeasonTime()
    self.scoreTxt.text = lang.trans("dream_my_score", point)
end

function GreenswardDetailView:RefreshSeasonTime()
    local remainTime = self.greenswardBuildModel:GetSeasonRemainTime()
    if remainTime <= 1 then
        self:RefreshNextSeasonTime()
    else
        self:RefreshNowSeasonTime()
    end
end

function GreenswardDetailView:RefreshNowSeasonTime()
    GameObjectHelper.FastSetActive(self.seasonInfoGo, true)
    GameObjectHelper.FastSetActive(self.startNewSeasonBtn.gameObject, false)
    local season = self.greenswardBuildModel:GetSeason()
    local remainTime = self.greenswardBuildModel:GetSeasonRemainTime()
    local title = lang.transstr("ladder_reward_seasonName", season) .. ":"
    if remainTime <= 1 then
        self:RefreshNextSeasonTime()
        return
    end
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            self:RefreshNextSeasonTime()
            return
        else
            local t = string.convertSecondToTime(time)
            self.seasonTxt.text = title .. t
        end
    end)
end

function GreenswardDetailView:RefreshNextSeasonTime()
    local point = self.greenswardBuildModel:GetPoint()
    self.scoreTxt.text = lang.trans("my_final_score", point)
    local remainTime = self.greenswardBuildModel:GetNextSeasonRemainTime()
    GameObjectHelper.FastSetActive(self.startNewSeasonBtn.gameObject, false)
    if remainTime <= 1 then
        GameObjectHelper.FastSetActive(self.seasonInfoGo, false)
        GameObjectHelper.FastSetActive(self.startNewSeasonBtn.gameObject, true)
        return
    end
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            GameObjectHelper.FastSetActive(self.seasonInfoGo, false)
            GameObjectHelper.FastSetActive(self.startNewSeasonBtn.gameObject, true)
            return
        else
            local t = string.convertSecondToTime(time)
            self.seasonTxt.text = lang.trans("adventure_start", t)
        end
    end)
end

function GreenswardDetailView:IsShowMoraleTips()
    local advMoraleNum = ReqEventModel.GetInfo("advMorale")
    local isShowMoraleTips = tonumber(advMoraleNum) > 0
    if isShowMoraleTips then
        local advMoraleTxt = "-" .. tostring(advMoraleNum)
        local tips = lang.trans("adventure_morele_reduce_tips", advMoraleTxt)
        self.myMoraleEffectSequence = GreenswardEventActionEffectHelper.BlingMoraleEffectExtensions(self.myMoraleEffectSequence, self.effectImg)
        if self.onTipsTrigger then
            self.onTipsTrigger(tips)
        end
    end
end

function GreenswardDetailView:IsShowGreenswardPoint()
    local advReward = ReqEventModel.GetInfo("advReward") or 0 -- 有可领取的奖励
    local isShow = tonumber(advReward) > 0
    GameObjectHelper.FastSetActive(self.rewardRedPointGo, isShow)
end

function GreenswardDetailView:IsShowMoraleSupplyRedPoint()
    local advFriend = ReqEventModel.GetInfo("advFriend") or 0 -- 有可领取的赠送士气
    local isShow = tonumber(advFriend) > 0
    GameObjectHelper.FastSetActive(self.moraleSupplyRedPointGo, isShow)
end

function GreenswardDetailView:BuffRetract()
    GameObjectHelper.FastSetActive(self.floorTrans.gameObject, true)
end

--* 在新手引导结束后判断射线是否开启（新手引导每步都是在下一步实例化后才删除上一个操作prefab）
function GreenswardDetailView:OnGreenswardGraphicRaySwitch(step, lock)
    if lock then
        self.stepsMap[step] = lock
    else
        self.stepsMap[step] = nil
    end

    local isTouchHandleOpen = not next(self.stepsMap)
    self.graphicRay.enabled = isTouchHandleOpen
end

function GreenswardDetailView:OnEnterScene()
    self.buildView:OnEnterScene()
    EventSystem.AddEvent("GreenswardPlaneFlyToAnArea", self, self.PlaneFly)
    EventSystem.AddEvent("GreenswardInfoUpdate", self, self.GreenswardInfoUpdate)
    -- 照明弹模式
    EventSystem.AddEvent("GreenswardFlashBang_SelectStep", self, self.OnEnterFlashBang)
    EventSystem.AddEvent("GreenswardFlashBang_QuitFlashBang", self, self.OnQuitFlashBang)
    -- 玩家形象改变
    EventSystem.AddEvent("Greensward_AvatarChange", self, self.InitAvatar)
    -- 提示
    EventSystem.AddEvent("ReqEventModel_advMorale", self, self.IsShowMoraleTips)
    EventSystem.AddEvent("ReqEventModel_advReward", self, self.IsShowGreenswardPoint)
    EventSystem.AddEvent("ReqEventModel_advFriend", self, self.IsShowMoraleSupplyRedPoint)
    -- 收起buff
    EventSystem.AddEvent("GreenswardBuffRetract", self, self.BuffRetract)
    -- 周期更换
    EventSystem.AddEvent("GreenswardCycleUpdate", self, self.OnGreenswardCycleUpdate)
    -- 屏蔽点击事件
    EventSystem.AddEvent("GreenswardGraphicRaySwitch", self, self.OnGreenswardGraphicRaySwitch)
    -- 刷新base
    EventSystem.AddEvent("Greensward_RefreshBaseInfo", self, self.OnRefreshBaseInfo)
end

function GreenswardDetailView:OnExitScene()
    self.buildView:OnExitScene()
    EventSystem.RemoveEvent("GreenswardPlaneFlyToAnArea", self, self.PlaneFly)
    EventSystem.RemoveEvent("GreenswardInfoUpdate", self, self.GreenswardInfoUpdate)
    -- 照明弹模式
    EventSystem.RemoveEvent("GreenswardFlashBang_SelectStep", self, self.OnEnterFlashBang)
    EventSystem.RemoveEvent("GreenswardFlashBang_QuitFlashBang", self, self.OnQuitFlashBang)
    -- 玩家形象改变
    EventSystem.RemoveEvent("Greensward_AvatarChange", self, self.InitAvatar)
    -- 提示
    EventSystem.RemoveEvent("ReqEventModel_advMorale", self, self.IsShowMoraleTips)
    EventSystem.RemoveEvent("ReqEventModel_advReward", self, self.IsShowGreenswardPoint)
    EventSystem.RemoveEvent("ReqEventModel_advFriend", self, self.IsShowMoraleSupplyRedPoint)
    -- 收起buff
    EventSystem.RemoveEvent("GreenswardBuffRetract", self, self.BuffRetract)
    -- 周期更换
    EventSystem.RemoveEvent("GreenswardCycleUpdate", self, self.OnGreenswardCycleUpdate)
    -- 屏蔽点击事件
    EventSystem.RemoveEvent("GreenswardGraphicRaySwitch", self, self.OnGreenswardGraphicRaySwitch)
    -- 刷新base
    EventSystem.RemoveEvent("Greensward_RefreshBaseInfo", self, self.OnRefreshBaseInfo)
end

function GreenswardDetailView:PlaneFly(index)
    if self.filterClick then
        self.filterClick(index)
    end
end

function GreenswardDetailView:PlaneFilterTrigger()
    self.planeFilter:OnFilterClick()
    self.planeFilter = nil
end

function GreenswardDetailView:OnPlaneClick()
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/Filter.prefab")
    spt:InitView(self.greenswardBuildModel)
    obj.transform:SetParent(self.planeArea, false)
    self.planeFilter = spt
end

-- 点击玩家形象
function GreenswardDetailView:OnBtnAvatar()
    if self.onBtnAvatar ~= nil and type(self.onBtnAvatar) == "function" then
        self.onBtnAvatar()
    end
end

-- 点击buff详情
function GreenswardDetailView:OnViewClick()
    if self.onViewClick then
        self.onViewClick(self.greenswardResourceCache)
    end
end

-- 点击背包按钮
function GreenswardDetailView:OnBagClick()
    if self.onBagClick ~= nil and type(self.onBagClick) == "function" then
        self.onBagClick()
    end
end

-- 点击士气补给
function GreenswardDetailView:OnPowerClick()
    if self.onBtnPowerClick and type(self.onBtnPowerClick) == "function" then
        self.onBtnPowerClick()
    end
end

-- 点击商店
function GreenswardDetailView:OnStoreClick()
    if self.onBtnStoreClick and type(self.onBtnStoreClick) == "function" then
        self.onBtnStoreClick()
    end
end

-- 点击开始新赛季
function GreenswardDetailView:OnStartNewSeasonClick()
    if self.onStartNewSeasonClick and type(self.onStartNewSeasonClick) == "function" then
        self.onStartNewSeasonClick()
    end
end

-- 点击buff展开
function GreenswardDetailView:OnBuffExpandClick()
    GameObjectHelper.FastSetActive(self.floorTrans.gameObject, false)
    if self.onBuffExpandClick then
        self.onBuffExpandClick(self.greenswardBuildModel, self.greenswardResourceCache)
    end
end

function GreenswardDetailView:onDestroy()
    self.greenswardResourceCache:Release()
    self.drinkRes = nil
    self.floorRes = nil
    self.moraleRes = nil
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if self.myScoreSequence then
        GreenswardEventActionEffectHelper.DestroyExtensions(self.myScoreSequence)
    end
    if self.myMoraleEffectSequence then
        GreenswardEventActionEffectHelper.DestroyExtensions(self.myMoraleEffectSequence)
    end
    GreenswardBuildModel.Instance = nil
    Input.multiTouchEnabled = false
end

-- 点击周期详情
function GreenswardDetailView:OnBtnCycleDetailClick()
    if self.onCycleDetailClick ~= nil and type(self.onCycleDetailClick) == "function" then
        self.onCycleDetailClick()
    end
end

-- 点击玩法介绍
function GreenswardDetailView:OnIntroduceClick()
    res.PushDialog("ui.controllers.greensward.introduce.GreenswardIntroduceCtrl", self.greenswardBuildModel)
end

-- 点击排行榜
function GreenswardDetailView:OnRankClick()
    res.PushDialog("ui.controllers.greensward.rank.GreenswardRankCtrl", self.greenswardBuildModel)
end

-- 点击完成度奖励
function GreenswardDetailView:OnRewardDetailClick()
    res.PushDialog("ui.controllers.greensward.seasonReward.GreenswardSeasonRewardCtrl", self.greenswardBuildModel)
end

-- 进入照明弹模式
-- 屏蔽UI，设置返回按钮事件
function GreenswardDetailView:OnEnterFlashBang()
    self:DisplayUIContent(false)
    self.infoBarCtrl:RegOnBtnBack(function()
        EventSystem.SendEvent("GreenswardFlashBang_OnBtnBackClick")
    end)
end

-- 退出照明弹模式
-- 显示UI，重设返回按钮事件
function GreenswardDetailView:OnQuitFlashBang()
    self:DisplayUIContent(true)
    self.infoBarCtrl:RegOnBtnBack(function()
        if self.onClickBack and type(self.onClickBack) == "function" then
            self.onClickBack()
        end
    end)
end

-- 刷新base
function GreenswardDetailView:OnRefreshBaseInfo(base)
    if base and type(base) == "table" and next(base) then
        self.greenswardBuildModel:RefreshBaseInfo(base)
    end
end

-- HUD显示控制
function GreenswardDetailView:DisplayUIContent(isShow)
    GameObjectHelper.FastSetActive(self.objContent.gameObject, isShow)
end

-- 设置上方资源条控制脚本
function GreenswardDetailView:SetInforBar(infoBarCtrl)
    self.infoBarCtrl = infoBarCtrl
end

return GreenswardDetailView
