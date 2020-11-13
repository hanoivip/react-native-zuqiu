local UnityEngine = clr.UnityEngine
local WWW = UnityEngine.WWW
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerHomeEventModel = require("ui.models.PlayerHomeEventModel")
local HomeEventCtrl = require("ui.controllers.home.HomeEventCtrl")
local HomeInfoBarCtrl = require("ui.controllers.home.HomeInfoBarCtrl")
local HomeSideBarCtrl = require("ui.controllers.home.HomeSideBarCtrl")
local HomeMenuBarCtrl = require("ui.controllers.home.HomeMenuBarCtrl")
local HomeEnterBtnGroupCtrl = require("ui.controllers.home.HomeEnterBtnGroupCtrl")
local HomeFirstTeamCtrl = require("ui.controllers.home.HomeFirstTeamCtrl")
local HomePersonalCtrl = require("ui.controllers.home.HomePersonalCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CourtBgMusicCtrl = require("ui.controllers.court.CourtBgMusicCtrl")
local CHAT_TYPE = require("ui.controllers.chat.CHAT_TYPE")
local DialogManager = require("ui.control.manager.DialogManager")
local LevelLimit = require("data.LevelLimit")
local EventSystem = require("EventSystem")
local HomeMainCtrl = class(BaseCtrl, "HomeMainCtrl")
local FriendsMenuType = require("ui.models.friends.MenuType")
local ShareHelper = require("ui.common.ShareHelper")
local ShareConstants = require("ui.scene.shareSDK.ShareConstants")
local ShowGirlModel = require("ui.models.showgirl.ShowGirlModel")

local isEnterPlayerGuide = true
HomeMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Home/HomeCanvas.prefab"
HomeMainCtrl.withoutPop = true

function HomeMainCtrl:RefreshHomeEvent()
    self.view:coroutine(function()
        local response = req.playerHomeEvent(nil, nil, true)
        if api.success(response) then
            local data = response.val
            PlayerInfoModel.new():SetStrength(data.sp)
            --签到最后推荐
            self.homeEnterBtnGroupCtrl:AddPageBack(function()
                local playerHomeEventModel = PlayerHomeEventModel.new()
                playerHomeEventModel:InitWithProtocol(data)
                HomeEventCtrl.new(playerHomeEventModel)
            end)
            cache.setIsOpenBeginnerCarnival(data.bcShow)
            cache.setCourtBuildData(data.build)
            EventSystem.SendEvent("HomeMain_InitBeginnerCarnivalView")
            EventSystem.SendEvent("courtBuild_UpdateState")
            if cache.getIsOpenShareSDK() then
                cache.setIsShareTaskComplete(data.share == 1)
                EventSystem.SendEvent("ShareTask_UpdateState")
            end
            self.homeEnterBtnGroupCtrl:InitWithProtocol(data)

            local banner = data.banner or {}
            self:ShowHomeBannerAds(banner)

            local gsSet = data.gsSet or {}
            self:ShowGirl(gsSet)
        end
    end)
end

function HomeMainCtrl:ShowGirl(data)
    if next(data) then
        local showGirlModel = ShowGirlModel.new()
        showGirlModel:InitWithProtocol(data)
        ShowGirlModel.SetCache(showGirlModel)

        EventSystem.SendEvent("ShowGirl_UpdateState")
    end
end

function HomeMainCtrl:RefreshShowGirl()
    self.view:coroutine(function()
        local response = req.getGsSetting(nil, nil, true)
        if api.success(response) then
            self:ShowGirl(response.val)
        end
    end)
end

function HomeMainCtrl:ShowHomeBannerAds(data)
    if next(data) then
        self.view:coroutine(function()
            local wwwBundle = WWW(data.picIndex)
            if wwwBundle then
                while not wwwBundle.isDone do
                    unity.waitForEndOfFrame()
                end
                if (not wwwBundle.error or wwwBundle.error == '') and wwwBundle.texture then
                    data.picTexture = wwwBundle.texture
                    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Home/HomeBannerAds.prefab", "camera", true, true)
                    dialogcomp.contentcomp:InitView(data)
                    wwwBundle:Dispose()
                end
            end
        end)
    end
end

function HomeMainCtrl:Refresh()
    HomeMainCtrl.super.Refresh(self)
    if not GuideManager.HasGuideOnGoing() then
        self:RefreshHomeEvent()
    end
    self.homeFirstTeamCtrl:Refresh()
    self.homeInfoBarCtrl:Refresh()
    self:InitView(self.playerInfoModel)
end

function HomeMainCtrl:GetStatusData()
end

function HomeMainCtrl:Init()
    -- 基本信息
    local playerInfoModel = PlayerInfoModel.new()

    self.homeMenuBarCtrl = HomeMenuBarCtrl.new(self.view.menuBarParent, self)
    self.homeSideBarCtrl = HomeSideBarCtrl.new(self.view.subView.sideBarView, nil, self)
    self.homeInfoBarCtrl = HomeInfoBarCtrl.new(self.view.subView.homeInfoView, nil, self)
    self.homeFirstTeamCtrl = HomeFirstTeamCtrl.new(self.view.subView.homeFirstTeamView, self)
    self.homeEnterBtnGroupCtrl = HomeEnterBtnGroupCtrl.new(self.view.subView.enterBtnGroupView, self)
    if playerInfoModel:IsCached() then
        self:InitView(playerInfoModel)
        self.homeInfoBarCtrl:InitView(playerInfoModel)

        if isEnterPlayerGuide then
            isEnterPlayerGuide = false
            local enterOtherScene = GuideManager.EnterReturnPointScene()
            if not enterOtherScene then
                GuideManager.InitCurModule("main")
                GuideManager.Show(self)
            end
        end
    end

    self.view.clickStart = function() self:OnBtnStartGame() end
    self.view.clickCourt = function() self:OnBtnCourt() end
    self.view.clickChat = function() self:OnBtnChat() end
    self.view.clickGuild = function() self:OnBtnGuild() end
    self.view.clickFriends = function() self:OnBtnFriends() end
    self.view.clickShare = function() self:OnBtnShare() end
    self.view.clickCarnival = function() self:OnBtnCarnival() end
    self.view.clickShowGirl = function() self:OnBtnShowGirl() end
    self.view.clickFreshPlayerLevel = function() self:OnBtnFreshPlayerLevel() end
end

function HomeMainCtrl:OnBtnCourt()
    local unlockCourtLevel = LevelLimit["building"] and LevelLimit["building"].playerLevel
    local level = self.playerInfoModel:GetLevel()
    if tonumber(level) >= tonumber(unlockCourtLevel) then
        res.ChangeScene("ui.controllers.court.CourtMainCtrl")
    else
        DialogManager.ShowToast(lang.trans("not_need_court_level", unlockCourtLevel))
    end
end

function HomeMainCtrl:OnBtnStartGame()
    res.PushDialog("ui.controllers.startGame.StartGameMainCtrl", true)
end

function HomeMainCtrl:OnBtnChat()
    res.PushDialog("ui.controllers.chat.ChatMainCtrl", CHAT_TYPE.WORLD)
end

function HomeMainCtrl:OnBtnGuild()
    local unlockGuideLevel = LevelLimit["guild"] and LevelLimit["guild"].playerLevel
    local level = self.playerInfoModel:GetLevel()
    if tonumber(level) < tonumber(unlockGuideLevel) then
        DialogManager.ShowToast(lang.trans("not_need_court_level", unlockGuideLevel))
        return
    end

    self.view:coroutine(function()
        local respone = req.guildIndex()
        if api.success(respone) then
            local data = respone.val
            if data.base.isExsit == true then
                res.PushScene("ui.controllers.guild.GuildHomeCtrl", data)
            else
                res.PushScene("ui.controllers.guild.GuildJoinCtrl")
            end
        end
    end)
end

function HomeMainCtrl:OnBtnFriends()
    res.PushScene("ui.controllers.friends.FriendsMainCtrl", FriendsMenuType.MESSAGES)
end

function HomeMainCtrl:OnBtnShare()
    ShareHelper.HomeCaptrueCamera(ShareConstants.Type.HomeMain)
end

function HomeMainCtrl:OnBtnCarnival()
    res.PushDialog("ui.controllers.carnival.CarnivalPageCtrl")
end

function HomeMainCtrl:OnBtnShowGirl()
    res.PushDialog("ui.controllers.showgirl.ShowGirlCtrl")
end

function HomeMainCtrl:OnBtnCoach()
    res.PushScene("ui.controllers.coach.coachMainPage.CoachMainPageCtrl")
end

function HomeMainCtrl:OnBtnFreshPlayerLevel()
    res.PushDialog("ui.controllers.freshPlayerLevel.FreshPlayerLevelCtrl")
end

function HomeMainCtrl:InitView(playerInfoModel)
    if playerInfoModel then
        self.playerInfoModel = playerInfoModel
    end
    self.view:InitView(playerInfoModel)
end

function HomeMainCtrl:OnEnterScene()
    luaevt.trig("SetOnBackType", "exit")
    luaevt.trig("EnterHomeScene")

    self.view:EnterScene()

    EventSystem.AddEvent("Charge_Success", self, self.OnCharged)
    EventSystem.AddEvent("CarnivalRedPoint_RefreshHomeEvent", self, self.RefreshHomePage)
end

function HomeMainCtrl:OnExitScene()
    luaevt.trig("SetOnBackType", "common")
    luaevt.trig("ExitHomeScene")

    self.homeEnterBtnGroupCtrl:OnExitScene()
    self.view:ExitScene()
    self.homeFirstTeamCtrl:RefreshViewRect()

    EventSystem.RemoveEvent("Charge_Success", self, self.OnCharged)
    EventSystem.RemoveEvent("CarnivalRedPoint_RefreshHomeEvent", self, self.RefreshHomePage)
end

function HomeMainCtrl:OnCharged()
    self:RefreshShowGirl()
end

function HomeMainCtrl:RefreshHomePage()
    self:Refresh()
end

return HomeMainCtrl
