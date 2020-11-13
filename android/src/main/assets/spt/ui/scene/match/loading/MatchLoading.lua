local UnityEngine = clr.UnityEngine
local TypeWriterElement = require("ui.control.typeWriter.TypeWriterElement")
local TypeWriter = require("ui.control.typeWriter.TypeWriter")
local TypeWriterLine = require("ui.control.typeWriter.TypeWriterLine")
local AssetFinder = require("ui.common.AssetFinder")
local MatchLoadingBase = require('ui.scene.match.loading.MatchLoadingBase')
local WeatherConstParams = require("coregame.WeatherConstParams")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchConstants = require("ui.scene.match.MatchConstants")

local MatchLoading = class(MatchLoadingBase)

local grassTxtMap = {
    Common = "grass_normal",
    Mixed = "grass_mixed",
    NatureShort = "grass_natureShort",
    NatureLong = "grass_natureLong",
    ArtificialShort = "grass_artificialShort",
    ArtificialLong = "grass_artificialLong",
}

function MatchLoading:ctor()
    luaevt.trig("SetOnBackType", "forbid")

    self.super.ctor(self)
    self.animator = self.___ex.animator
    self.bgImage = self.___ex.bgImage
    self.weatherTitle = self.___ex.weatherTitle
    self.weatherIcon = self.___ex.weatherIcon
    self.weatherImage = self.___ex.weatherImage
    self.stadiumTitle = self.___ex.stadiumTitle
    self.stadiumName = self.___ex.stadiumName
    self.opponentTitle = self.___ex.opponentTitle
    self.opponentTeamName = self.___ex.opponentTeamName
    self.opponentTeamLogo = self.___ex.opponentTeamLogo
    self.matchTimeTitle = self.___ex.matchTimeTitle
    self.matchTime = self.___ex.matchTime
    self.grassTitle = self.___ex.grassTitle
    self.grassName = self.___ex.grassName
    self.matchTimeTitle2 = self.___ex.matchTimeTitle2
    self.matchTime2 = self.___ex.matchTime2
    self.timeRoot1 = self.___ex.timeRoot1
    self.timeRoot2 = self.___ex.timeRoot2
    self.grassRoot = self.___ex.grassRoot
    self.charPauseTime = 0.03
    self.linePauseTime = 0.1
end

function MatchLoading:start()
    res.ClearSceneCache()
    GameObjectHelper.FastSetActive(self.loadingCircle.gameObject, false)
    self.isWriting = true
    self.super.start(self)
    assert(WeatherConstParams.currentWeather)

    local matchInfoModel = MatchInfoModel.GetInstance()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    self.weatherImage.enabled = false
    self.opponentTeamLogo.gameObject:SetActive(false)

    local typeWriters = {}
    local weatherElements = {}
    table.insert(weatherElements, TypeWriterElement.new(ElementType.TEXT, self.weatherTitle, clr.unwrap(lang.trans("matchLoading_weather"))))
    table.insert(weatherElements, TypeWriterElement.new(ElementType.BYTESIMAGE, self.weatherIcon, WeatherConfig[WeatherConstParams.currentWeather].Icon))
    local weatherTypeWriter = TypeWriter.new(weatherElements, self.charPauseTime)
    table.insert(typeWriters, weatherTypeWriter)

    if matchInfoModel:IsDemoMatch() ~= true then
        local stadiumElements = {}
        table.insert(stadiumElements, TypeWriterElement.new(ElementType.TEXT, self.stadiumTitle, clr.unwrap(lang.trans("matchLoading_stadium"))))
        table.insert(stadiumElements, TypeWriterElement.new(ElementType.TEXT, self.stadiumName, matchInfoModel:GetStadiumName() and tostring(matchInfoModel:GetStadiumName()) or clr.unwrap(lang.trans("matchLoading_stadium_name", matchInfoModel:GetPlayerTeamDisplayName()))))
        local stadiumTypeWriter = TypeWriter.new(stadiumElements, self.charPauseTime)
        table.insert(typeWriters, stadiumTypeWriter)

        local opponentElements = {}
        table.insert(opponentElements, TypeWriterElement.new(ElementType.TEXT, self.opponentTitle, clr.unwrap(lang.trans("matchLoading_opponent"))))
        TeamLogoCtrl.BuildTeamLogo(self.opponentTeamLogo, opponentTeamData.logo)
        table.insert(opponentElements, TypeWriterElement.new(ElementType.GAMEOBJECT, self.opponentTeamLogo))
        table.insert(opponentElements, TypeWriterElement.new(ElementType.TEXT, self.opponentTeamName, matchInfoModel:GetOpponentTeamDisplayName()))
        local opponentTypeWriter = TypeWriter.new(opponentElements, self.charPauseTime)
        table.insert(typeWriters, opponentTypeWriter)

        local timeElements = {}
        -- 日文版暂时没有天梯，不会走这个，暂时不会有问题
        if matchInfoModel:IsUseWeatherGrassTech() then
            if self.timeRoot1 then
                self.timeRoot1:SetActive(false)
            end

            local grassElements = {}
            local grassTech = matchInfoModel:GetBaseInfo().grassTech
            grassTech = grassTech or "Common"

            table.insert(grassElements, TypeWriterElement.new(ElementType.TEXT, self.grassTitle, clr.unwrap(lang.trans("grass_title"))))
            table.insert(grassElements, TypeWriterElement.new(ElementType.TEXT, self.grassName, clr.unwrap(lang.trans(grassTxtMap[grassTech]))))
            local grassWriter = TypeWriter.new(grassElements, self.charPauseTime)
            table.insert(typeWriters, grassWriter)

            table.insert(timeElements, TypeWriterElement.new(ElementType.TEXT, self.matchTimeTitle2, clr.unwrap(lang.trans("matchLoading_time"))))
            table.insert(timeElements, TypeWriterElement.new(ElementType.TEXT, self.matchTime2, matchInfoModel:GetKickoffTime() and tostring(matchInfoModel:GetKickoffTime()) or WeatherConfig[WeatherConstParams.currentWeather].Time))
            local timeTypeWriter = TypeWriter.new(timeElements, self.charPauseTime)
            table.insert(typeWriters, timeTypeWriter)
        else
            if self.grassRoot then
                self.grassRoot:SetActive(false)
            end
            if self.timeRoot2 then
                self.timeRoot2:SetActive(false)
            end

            table.insert(timeElements, TypeWriterElement.new(ElementType.TEXT, self.matchTimeTitle, clr.unwrap(lang.trans("matchLoading_time"))))
            table.insert(timeElements, TypeWriterElement.new(ElementType.TEXT, self.matchTime, matchInfoModel:GetKickoffTime() and tostring(matchInfoModel:GetKickoffTime()) or WeatherConfig[WeatherConstParams.currentWeather].Time))
            local timeTypeWriter = TypeWriter.new(timeElements, self.charPauseTime)
            table.insert(typeWriters, timeTypeWriter)
        end
    end

    local typeWriterLine = TypeWriterLine.new(typeWriters, self.linePauseTime)
    typeWriterLine:regOnFinished(function() self:OnTypeWriterFinished() end)
    typeWriterLine:StartWriterLine()

    PrefabCache.load()
end

function MatchLoading:OnTypeWriterFinished()
    GameObjectHelper.FastSetActive(self.loadingCircle.gameObject, true)
    self.isWriting = false
    self:coroutine(function()
        --self.waitText:SetActive(false)
         coroutine.yield(UnityEngine.WaitForSeconds(3))
        -- self.animator.enabled = true
        -- coroutine.yield(UnityEngine.WaitForSeconds(1))
        -- self.animator.enabled = false
        -- self.effect:SetActive(false)
        -- self.bgImage.color = UnityEngine.Color(0, 0, 0, 1)
        -- coroutine.yield(UnityEngine.WaitForSeconds(1))

        res.CollectGarbageDeep(function()
            local loadinfo = res.ChangeSceneAsync("ui.controllers.match.MatchCtrl")
            if loadinfo then
                while not loadinfo.done do
                    unity.waitForNextEndOfFrame()
                end
            end

            res.CollectGarbageDeep(function()
                UnityEngine.Resources.UnloadUnusedAssets()
                res.UnloadAllBundleSoft()
                self.isDone = true
            end)
        end)
    end)
end

return MatchLoading
