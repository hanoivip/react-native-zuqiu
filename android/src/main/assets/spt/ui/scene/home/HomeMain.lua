local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local RectTransform = UnityEngine.RectTransform
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local Time = UnityEngine.Time
local Timer = require('ui.common.Timer')
local ReqEventModel = require("ui.models.event.ReqEventModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerNewFunctionModel = require("ui.models.PlayerNewFunctionModel")
local ShowGirlModel = require("ui.models.showgirl.ShowGirlModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")
local FreshPlayerLevelModel = require("ui.models.freshPlayerLevel.FreshPlayerLevelModel")
local LevelLimit = require("data.LevelLimit")
local HomeMain = class(unity.base)
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")

function HomeMain:ctor()
    -- sub view
    self.subView = self.___ex.subView
    self.menuBarParent = self.___ex.menuBarParent
    self.btnStart = self.___ex.btnStart
    self.btnCourt = self.___ex.btnCourt
    self.startRedPoint = self.___ex.startRedPoint
    self.startGuideArrow = self.___ex.startGuideArrow
    self.btnChat = self.___ex.btnChat
    self.chatRedPoint = self.___ex.chatRedPoint
    self.btnGuild = self.___ex.btnGuild
    self.qqVip = self.___ex.qqVip
    self.btnFriends = self.___ex.btnFriends
    self.friendsRedPoint = self.___ex.friendsRedPoint
    self.btnShare = self.___ex.btnShare
    self.leftSidebar = self.___ex.leftSidebar
    self.rightSidebar = self.___ex.rightSidebar
    self.centerBar = self.___ex.centerBar
    self.leftMenuBar = self.___ex.leftMenuBar
    self.logoSign = self.___ex.logoSign
    self.titleBar = self.___ex.titleBar
    self.ribbon = self.___ex.ribbon
    self.personalMark = self.___ex.personalMark
    self.shareInfo = self.___ex.shareInfo
    self.guildRedPoint = self.___ex.guildRedPoint
    self.courtRedPoint = self.___ex.courtRedPoint
    self.btnShowGirl = self.___ex.btnShowGirl
    self.startButtonsBg = self.___ex.startButtonsBg
    self.courtBuilding = self.___ex.courtBuilding
    self.courtNormal = self.___ex.courtNormal
    self.courtTime = self.___ex.courtTime
    self.courtCanUp = self.___ex.courtCanUp
    self.beginnerCarnivalObj = self.___ex.beginnerCarnivalObj
    self.btnCarnival = self.___ex.btnCarnival
    self.carnivalRedPoint = self.___ex.carnivalRedPoint
    self.coachEntryGo = self.___ex.coachEntryGo
    self.coachBtn = self.___ex.coachBtn
    self.coachEntryTrans = self.___ex.coachEntryTrans
    self.freshPlayerLevelBtn = self.___ex.freshPlayerLevelBtn
    self.freshPlayerLevelGo = self.___ex.freshPlayerLevelGo
    self.remainTimeTxt = self.___ex.remainTimeTxt
    self.fancyNew = self.___ex.fancyNew
end

function HomeMain:start()
    self.btnStart:regOnButtonClick(function()
        self:OnBtnStartClick()
    end)
    self.btnCourt:regOnButtonClick(function()
        self:OpenNewFunction("building")
        self:OnBtnCourtClick()
    end)
    self.btnChat:regOnButtonClick(function()
        self:OnBtnChatClick()
    end)
    self.btnGuild:regOnButtonClick(function()
        self:OpenNewFunction("guild")
        self:OnBtnGuildClick()
    end)
    self.btnFriends:regOnButtonClick(function()
        self:OnBtnFriendsClick()
    end)
    self.btnShare:regOnButtonClick(function()
        self:OnBtnShareClick()
    end)
    self.btnCarnival:regOnButtonClick(function()
        self:OnBtnCarnivalClick()
    end)
    self.btnShowGirl:regOnButtonClick(function()
        self:OnBtnShowGirlClick()
    end)
    self.coachBtn:regOnButtonClick(function()
        self:OnBtnCoachClick()
    end)
    if self.freshPlayerLevelBtn then
        self.freshPlayerLevelBtn:regOnButtonClick(function()
            self:OnBtnFreshPlayerLevelClick()
        end)
    end

    -- qq vip
    if self.___ex.qqVip then
        local LoginCtrl = require("ui.controllers.login.LoginCtrl")
        if LoginCtrl.___isQQ then
            self.___ex.qqVip.gameObject:SetActive(true)    
        else
            self.___ex.qqVip.gameObject:SetActive(false)
        end
        self.___ex.qqVip:regOnButtonClick(function()
            clr.coroutine(function()
                local data = {
                    openid = LoginCtrl.___ysdk_openid,
                    openkey = LoginCtrl.___ysdk_openkey,
                }
                local response = req.post("qq/giftInfo", data)
                if api.success(response) then
                    local url = response.val.url
                    if url then
                        luaevt.trig("SDK_OpenWebView", url)
                    end
                end
            end)
        end)
    end

    self:IsShowFriendsRedPoint()

    self:RegModelHandler()
    self:UpdateSuitSkin()
end

function HomeMain:UpdateSuitSkin()
    local playerInfoModel = PlayerInfoModel.new()
    local skinKey = playerInfoModel:GetSpecificTeam()
    local changeColor = Color(1, 1, 1)
    local menuPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Side_Bar.png"
    local titlePath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/TitleBar1.png"
    local sideBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Stand_Side.png"
    local TopBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Stand_Top.png"
    local isShowLogo = false
    local markTransform = self.personalMark.transform
    if markTransform.childCount > 0 then
        Object.Destroy(markTransform:GetChild(0).gameObject)
    end
    local ribbonTransform = self.ribbon.transform
    if ribbonTransform.childCount > 0 then
        Object.Destroy(ribbonTransform:GetChild(0).gameObject)
    end

    if skinKey == "Bayern" then 
        changeColor = Color(255 / 255, 15 / 255, 42 / 255)
        menuPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Side_Bar2.png"
        titlePath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/TitleBar2.png"
        self.logoSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Home/Images/BayernLogo.png")
        isShowLogo = true

        local titleSignObj = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Home/Skin/BayernSkinTitle.prefab")
        titleSignObj.transform:SetParent(markTransform, false)

        local ribbonObj = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Home/Skin/BayernSkinRibbon.prefab")
        ribbonObj.transform:SetParent(ribbonTransform, false)

    elseif skinKey == "RealMadrid" then
        changeColor = Color(255 / 255, 255 / 255, 255 / 255)
        menuPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Side_Bar3.png"
        titlePath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/TitleBar3.png"
        self.logoSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Home/Images/RealMadridLogo.png")
        isShowLogo = true

        local titleSignObj = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Home/Skin/RealMadridSkinTitle.prefab")
        titleSignObj.transform:SetParent(markTransform, false)

        local ribbonObj = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Home/Skin/RealMadridSkinRibbon.prefab")
        ribbonObj.transform:SetParent(ribbonTransform, false)

        sideBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Special_Side.png"
        TopBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Special_Top.png"
    end
    
    self.leftSidebar.color = changeColor
    self.rightSidebar.color = changeColor
    self.centerBar.color = changeColor
    self.leftSidebar.overrideSprite = res.LoadRes(sideBarPath)
    self.rightSidebar.overrideSprite = res.LoadRes(sideBarPath)
    self.centerBar.overrideSprite = res.LoadRes(TopBarPath)
    self.leftMenuBar.overrideSprite = res.LoadRes(menuPath)
    self.titleBar.overrideSprite = res.LoadRes(titlePath)
    GameObjectHelper.FastSetActive(self.logoSign.gameObject, isShowLogo)
end

function HomeMain:OnBtnStartClick()
    if self.clickStart then
        self.clickStart()
    end
end

function HomeMain:OnBtnCourtClick()
    if self.clickCourt then
        self.clickCourt()
    end
end

function HomeMain:OnBtnChatClick()
    if self.clickChat then
        self.clickChat()
    end
end

function HomeMain:OnBtnGuildClick()
    if self.clickGuild then
        self.clickGuild()
    end
end

function HomeMain:OnBtnFriendsClick()
    if self.clickFriends then
        self.clickFriends()
    end
end

function HomeMain:OnBtnShareClick()
    if self.clickShare then
        self.clickShare()
    end
end

function HomeMain:OnBtnCarnivalClick()
    if self.clickCarnival then
        self.clickCarnival()
    end
end

function HomeMain:OnBtnShowGirlClick()
    if self.clickShowGirl then
        self.clickShowGirl()
    end
end

function HomeMain:OnBtnCoachClick()
    if self.clickCoach then
        self.clickCoach()
    end
end

function HomeMain:OnBtnFreshPlayerLevelClick()
    if self.clickFreshPlayerLevel then
        self.clickFreshPlayerLevel()
    end
end

local GuideArrowLevel = 10
function HomeMain:InitView(playerInfoModel)
    self:IsShowStartRedPoint()
    self:IsShowChatRedPoint()
    self:IsShowFriendsRedPoint()
    self:ISShowGuildRedPoint()

    local level = playerInfoModel:GetLevel()
    local isShowGuideArrow = false
    if not GuideManager.GuideIsOnGoing("main") and level < GuideArrowLevel then 
        isShowGuideArrow = true
    end
    GameObjectHelper.FastSetActive(self.startGuideArrow, isShowGuideArrow)
    local coachOpenLevel = LevelLimit.Coach.playerLevel
    local coachOpenState = coachOpenLevel <= level
    GameObjectHelper.FastSetActive(self.coachEntryGo, coachOpenState)
    if coachOpenState then
        self:RefreshCoachInfo()
    end

    self:InitPlayerLevelBox()

    self:InitStartButtons()
    self:CheckNewFunctionOpend(PlayerNewFunctionModel.new())
    self:InitBeginnerCarnivalView()
end

function HomeMain:InitBeginnerCarnivalView()
    GameObjectHelper.FastSetActive(self.beginnerCarnivalObj, cache.getIsOpenBeginnerCarnival())
    if cache.getIsOpenBeginnerCarnival() then
        self:IsShowCarnivalRedPoint()
    end
end

function HomeMain:InitStartButtons()
    local activeCount = self.startButtonsBg.childCount
    activeCount = activeCount - self:InitShareView()
    activeCount = activeCount - self:InitShowGirl()

    -- distribute active buttons evenly inside Image_bg
    local bgWidth = self.startButtonsBg.rect.width
    local itemWidth = self.startButtonsBg:GetChild(0).rect.width
    local gap = (bgWidth - itemWidth * (activeCount)) / (activeCount + 1)
    for i = 0, activeCount - 1 do
        local item = self.startButtonsBg:GetChild(i)
        local x = bgWidth / 2 - gap * (i + 1) - itemWidth * 0.5 - itemWidth * i 
        item.anchoredPosition = Vector2(x, item.anchoredPosition.y)
    end
end

function HomeMain:InitShareView()
    local isOpenShare = cache.getIsOpenShareSDK()
    GameObjectHelper.FastSetActive(self.btnShare.transform.parent.gameObject, isOpenShare)
    if isOpenShare then
        GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
    end
    return isOpenShare and 0 or 1
end

function HomeMain:InitShowGirl()
    local isOpenShowGirl = ShowGirlModel.Enabled()
    GameObjectHelper.FastSetActive(self.btnShowGirl.transform.parent.gameObject, isOpenShowGirl)
    return isOpenShowGirl and 0 or 1
end

function HomeMain:Refresh()
    if self.refresh then
        self.refresh()
    end
end

function HomeMain:RegOnDynamicLoad(func)
    self.menuBarParent:RegOnDynamicLoad(func)
end

function HomeMain:IsShowStartRedPoint()
    local letter = ReqEventModel.GetInfo("letter")
    local leagueLimit = ReqEventModel.GetInfo("leagueLimit")
    local ladderRecord = ReqEventModel.GetInfo("ladderRecord")
    local arenaHonor = ReqEventModel.GetInfo("arenaHonor")
    local specific = ReqEventModel.GetInfo("specific")
    local peak = ReqEventModel.GetInfo("peak")
    local transport = ReqEventModel.GetInfo("transport")
    local advReward = ReqEventModel.GetInfo("advReward") or 0 -- 有可领取的奖励
    local advDaily = ReqEventModel.GetInfo("advDaily") or 0 -- 有可领取的士气
    local advReward = ReqEventModel.GetInfo("advReward") or 0 -- 有可领取的奖励
    local advDaily = ReqEventModel.GetInfo("advDaily") or 0 -- 有可领取的士气
    local fancyGacha = ReqEventModel.GetInfo("fancyGacha") or {} -- 梦幻11人抽卡
    local isShowRedPoint = false
    if tonumber(advReward) > 0 or tonumber(advDaily) > 0 or tonumber(letter) > 0 or tonumber(leagueLimit) > 0 or tonumber(ladderRecord) > 0 or tonumber(arenaHonor) > 0 or tonumber(specific) > 0 or tonumber(peak) > 0 or tonumber(transport) > 0 or table.nums(fancyGacha) > 0 then
        isShowRedPoint = true
    end
    GameObjectHelper.FastSetActive(self.startRedPoint, isShowRedPoint)
    GameObjectHelper.FastSetActive(self.fancyNew, not isShowRedPoint and FancyCardsMapModel.new():IsHaveNewCard())
end

function HomeMain:IsShowChatRedPoint()
    local playerMsg = ReqEventModel.GetInfo("msgPlayer")
    local guildMsg = ReqEventModel.GetInfo("msgGuild")
    local isShowRedPoint = tonumber(playerMsg) > 0 or tonumber(guildMsg) > 0
    GameObjectHelper.FastSetActive(self.chatRedPoint, isShowRedPoint)   
end

function HomeMain:IsShowFriendsRedPoint()
    local friendsNum = ReqEventModel.GetInfo("friend")
    local isShowRedPoint = tonumber(friendsNum) > 0
    GameObjectHelper.FastSetActive(self.friendsRedPoint, isShowRedPoint)
end

function HomeMain:ISShowGuildRedPoint()
    local guildSign = ReqEventModel.GetInfo("guildSign")
    local guildMsg = ReqEventModel.GetInfo("msgGuild")
    local guildChlg = ReqEventModel.GetInfo("guildChlg")
    local guildWar = ReqEventModel.GetInfo("guildWar")
    local guildRequest = ReqEventModel.GetInfo("guildRequest")
    local isShowRedPoint = tonumber(guildSign) > 0 or tonumber(guildMsg) > 0 or tonumber(guildChlg) > 0 or tonumber(guildWar) > 0 or tonumber(guildRequest) > 0
    GameObjectHelper.FastSetActive(self.guildRedPoint, isShowRedPoint)
end

function HomeMain:IsShowCarnivalRedPoint()
    local BeginnerCarnivalSelf = ReqEventModel.GetInfo("BeginnerCarnivalSelf")
    local isShow = tonumber(BeginnerCarnivalSelf) > 0
    GameObjectHelper.FastSetActive(self.carnivalRedPoint, isShow)
end

function HomeMain:UpdateShareTaskState()
    GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
end

function HomeMain:SetViewOnShareComplete()
    GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
end

function HomeMain:OnShareComplete()
    self:SetViewOnShareComplete()
end

function HomeMain:EnterScene()
    EventSystem.AddEvent("ReqEventModel_letter", self, self.IsShowStartRedPoint)
    EventSystem.AddEvent("ReqEventModel_leagueLimit", self, self.IsShowStartRedPoint)
    EventSystem.AddEvent("ReqEventModel_ladderRecord", self, self.IsShowStartRedPoint)
    EventSystem.AddEvent("ReqEventModel_arenaHonor", self, self.IsShowStartRedPoint)
    EventSystem.AddEvent("ReqEventModel_specific", self, self.IsShowStartRedPoint)
    EventSystem.AddEvent("ReqEventModel_peak", self, self.IsShowStartRedPoint)
    EventSystem.AddEvent("ReqEventModel_msgPlayer", self, self.IsShowChatRedPoint)
    EventSystem.AddEvent("ReqEventModel_msgGuild", self, self.IsShowChatRedPoint)
    EventSystem.AddEvent("ReqEventModel_guildSign", self, self.ISShowGuildRedPoint)
    EventSystem.AddEvent("ReqEventModel_friend", self, self.IsShowFriendsRedPoint)
    EventSystem.AddEvent("ReqEventModel_beginnerCarnival", self, self.IsShowCarnivalRedPoint)
    EventSystem.AddEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    EventSystem.AddEvent("UpdateNewFunctionState", self, self.UpdateNewFunctionState)
    EventSystem.AddEvent("ShowGirl_UpdateState", self, self.InitStartButtons)
    EventSystem.AddEvent("courtBuild_UpdateState", self, self.IsShowCourtBuilding)
    EventSystem.AddEvent("HomeMain_InitBeginnerCarnivalView", self, self.InitBeginnerCarnivalView)
    EventSystem.AddEvent("FreshPlayerLevel_Changed", self, self.InitPlayerLevelBox)
    luaevt.reg("ShareSDK_OnComplete", function(cate, action)
        self:OnShareComplete() 
    end)
end

function HomeMain:ExitScene()
    EventSystem.RemoveEvent("ReqEventModel_letter", self, self.IsShowStartRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_leagueLimit", self, self.IsShowStartRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_ladderRecord", self, self.IsShowStartRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_arenaHonor", self, self.IsShowStartRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_specific", self, self.IsShowStartRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_peak", self, self.IsShowStartRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_msgPlayer", self, self.IsShowChatRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_msgGuild", self, self.IsShowChatRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_guildSign", self, self.ISShowGuildRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_friend", self, self.IsShowFriendsRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_beginnerCarnival", self, self.IsShowCarnivalRedPoint)
    EventSystem.RemoveEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    EventSystem.RemoveEvent("UpdateNewFunctionState", self, self.UpdateNewFunctionState)
    EventSystem.RemoveEvent("ShowGirl_UpdateState", self, self.InitStartButtons)
    EventSystem.RemoveEvent("courtBuild_UpdateState", self, self.IsShowCourtBuilding)
    EventSystem.RemoveEvent("HomeMain_InitBeginnerCarnivalView", self, self.InitBeginnerCarnivalView)
    EventSystem.RemoveEvent("FreshPlayerLevel_Changed", self, self.InitPlayerLevelBox)
    luaevt.unreg("ShareSDK_OnComplete")
    if self.courtCoroutine then
        self:StopCoroutine(self.courtCoroutine)
        self.courtCoroutine = nil
    end
end

function HomeMain:CheckNewFunctionOpend(playerNewFunctionModel)
    if playerNewFunctionModel:IsOpend() then
        if playerNewFunctionModel:CheckFirstEnterScene("guild") then
            cache.setGuildFirstEnter(true)
            GameObjectHelper.FastSetActive(self.guildRedPoint, true)
        else
            cache.setGuildFirstEnter(false)
            GameObjectHelper.FastSetActive(self.guildRedPoint, false)
        end
        if playerNewFunctionModel:CheckFirstEnterScene("building")  then
            GameObjectHelper.FastSetActive(self.courtRedPoint, true)
        else
            GameObjectHelper.FastSetActive(self.courtRedPoint, false)
        end              
    else
        GameObjectHelper.FastSetActive(self.guildRedPoint, false)
        GameObjectHelper.FastSetActive(self.courtRedPoint, false)
    end
end

function HomeMain:IsShowCourtBuilding()
    if self.courtCoroutine then
        self:StopCoroutine(self.courtCoroutine)
        self.courtCoroutine = nil
    end 

    self.courtCoroutine = self:coroutine(function()
        local playerInfoModel = PlayerInfoModel.new()
        self.courtBuildModel = CourtBuildModel.new()
        local unlockCourtLevel = LevelLimit["building"] and LevelLimit["building"].playerLevel
        local level = playerInfoModel:GetLevel()
        if tonumber(level) >= tonumber(unlockCourtLevel) then 
            local flag = true
            while(flag) do
                local time = self.courtBuildModel:GetBuildUpgradingTime()
                if time > 0 then
                    GameObjectHelper.FastSetActive(self.courtNormal, false)
                    GameObjectHelper.FastSetActive(self.courtBuilding, true)
                    GameObjectHelper.FastSetActive(self.courtCanUp, false)
                    self.courtTime.text = string.formatTimeClock(time, 3600)
                    coroutine.yield()
                    time = time - Time.unscaledDeltaTime
                    local courtBuildType = self.courtBuildModel:GetBuildUpgradingType()
                    self.courtBuildModel:SetBuildTime(courtBuildType, time)
                else
                    local canUpflag = self.courtBuildModel:HasCanUpBuilding()
                    GameObjectHelper.FastSetActive(self.courtNormal, not canUpflag)
                    GameObjectHelper.FastSetActive(self.courtBuilding, false)
                    GameObjectHelper.FastSetActive(self.courtCanUp, canUpflag)     
                    flag = false
                end                
            end    
        else
            GameObjectHelper.FastSetActive(self.courtNormal, true)
            GameObjectHelper.FastSetActive(self.courtBuilding, false)
            GameObjectHelper.FastSetActive(self.courtCanUp, false) 
        end
    end)    
end

function HomeMain:OpenNewFunction(functionName)
    local playerNewFunctionList = PlayerNewFunctionModel.new()
    if playerNewFunctionList:IsOpend() then
        if  playerNewFunctionList:CheckFirstEnterScene(functionName) then
            clr.coroutine(function()
                local response = req.setEnterSenceList(functionName, 2)
                if api.success(response) then
                    playerNewFunctionList:SetWithProtocol(response.val, functionName)
                end
            end)
        end
    end
end

function HomeMain:UpdateNewFunctionState(name, isShow)
    if name == "guild" then 
        GameObjectHelper.FastSetActive(self.trainRedPoint, isShow)
    elseif name == "building" then 
        GameObjectHelper.FastSetActive(self.arenaRedPoint, isShow)
    end
end

function HomeMain:RefreshCoachInfo()
    local coachMainModel = CoachMainModel.new()
    local credentialLevel = coachMainModel:GetCredentialLevel()
    local starLevel = coachMainModel:GetStarLevel()
    if not self.coachInfoSpt then
        local coachInfoObj, coachInfoSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachEntry.prefab")
        coachInfoObj.transform:SetParent(self.coachEntryTrans, false)
        self.coachInfoSpt = coachInfoSpt
    end
    self.coachInfoSpt:InitView(credentialLevel, starLevel)
end

-- 等级限时礼盒
function HomeMain:InitPlayerLevelBox()
    local freshPlayerLevelModel = FreshPlayerLevelModel.new()
    local remainTime = freshPlayerLevelModel:GetShortestEndTime()
    GameObjectHelper.FastSetActive(self.freshPlayerLevelGo, remainTime > 0)
    if remainTime > 2 then
        self:RefreshPlayerLevel(remainTime)
    end
end

function HomeMain:RefreshPlayerLevel(remainTime)
    if remainTime > 2 then
        if self.cdTimer then
            self.cdTimer:Destroy()
            self.cdTimer = nil
        end
        self.cdTimer = Timer.new(remainTime, function(time)
            if time > 1 then
                local timeStr = string.convertSecondToTime(time)
                self.remainTimeTxt.text = lang.transstr("residual_time") .. timeStr
            else
                self:InitPlayerLevelBox()
            end
        end)
    end
end

function HomeMain:RegModelHandler()
    EventSystem.AddEvent("UpdateSuitSkin", self, self.UpdateSuitSkin)
end

function HomeMain:RemoveModelHandler()
    EventSystem.RemoveEvent("UpdateSuitSkin", self, self.UpdateSuitSkin)
end

function HomeMain:onDestroy()
    self:RemoveModelHandler()
    if self.cdTimer then
        self.cdTimer:Destroy()
        self.cdTimer = nil
    end
end

return HomeMain
