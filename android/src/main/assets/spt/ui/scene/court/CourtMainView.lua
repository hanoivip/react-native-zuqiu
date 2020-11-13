local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local AudioSettings = UnityEngine.AudioSettings
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local AudioManager = require("unity.audio")
local Court3DManager = require("ui.scene.court.Court3DManager")
local ShareHelper = require("ui.common.ShareHelper")
local ShareConstants = require("ui.scene.shareSDK.ShareConstants")
local CourtMainView = class(unity.newscene)

function CourtMainView:ctor()
    CourtMainView.super.ctor(self)
    self.clouds = self.___ex.clouds
    self.stadiumView = self.___ex.stadiumView
    self.communicationView = self.___ex.communicationView
    self.scoutingView = self.___ex.scoutingView
    self.parkView = self.___ex.parkView
    self.technologyHallView = self.___ex.technologyHallView
    self.btnShare = self.___ex.btnShare
    self.shareInfo = self.___ex.shareInfo
    self.shareInfoText = self.___ex.shareInfoText
    self.court3DManager = self.___ex.court3DManager
    self.btnBack = self.___ex.btnBack
    self.timer = {}
    self.stadiumView.click = function(courtBuildType) self:OnClick(courtBuildType) end
    self.scoutingView.click = function(courtBuildType) self:OnClick(courtBuildType) end
    self.technologyHallView.click = function(courtBuildType) self:OnClick(courtBuildType) end
    self.parkView.click = function(courtBuildType) self:OnClick(courtBuildType) end

    if luaevt.trig("___EVENT__NOT_OPEN_FORBIDDEN_HK") then
        GameObjectHelper.FastSetActive(self.communicationView.gameObject, false)
    end
end

function CourtMainView:RegOnDynamicLoad(func)
end

function CourtMainView:start()
    self.btnShare:regOnButtonClick(function()
        self:OnBtnShareClick()
    end)
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBack()
    end)
end

function CourtMainView:OnBtnBack()
    if self.clickBack then 
        self.clickBack()
    end
end

function CourtMainView:Load3DRes(courtBuildType,courtBuildLevel)
    self.court3DManager:Show3DResByType(courtBuildType, courtBuildLevel)
end

function CourtMainView:ShowClouds(isShow)
    GameObjectHelper.FastSetActive(self.clouds, isShow)
end

function CourtMainView:RegisterAudioListener()
    AudioManager.RegListener("ActionConstruct", function()
        if self.actionConstruct then
            self:OnConstruct()
        end
    end, "ActionConstruct")
end

function CourtMainView:RemoveAudioListener()
    AudioManager.RegListener("ActionConstruct", nil, "ActionConstruct")
end

function CourtMainView:onDestroy()
    if self.onDestroyEvent then 
        self.onDestroyEvent()
    end
end

function CourtMainView:OnClick(courtBuildType)
    if self.click then 
        self.click(courtBuildType)
    end
end

function CourtMainView:OnBtnShareClick()
    self:OnBtnShare()
end

function CourtMainView:InitView(isRefresh)
    self.timer = {}
    self.courtBuildModel = CourtBuildModel.new()
    self.court3DManager:InitView(self.courtBuildModel)
    if not isRefresh then 
        self.stadiumView:InitView(self.courtBuildModel, self.court3DManager, CourtBuildType.StadiumBuild)
        self.scoutingView:InitView(self.courtBuildModel, self.court3DManager, CourtBuildType.ScoutBuild)
        self.technologyHallView:InitView(self.courtBuildModel, CourtBuildType.TechnologyHallBuild)
        self.parkView:InitView(self.courtBuildModel, self.court3DManager, CourtBuildType.ParkingBuild)
    end
    
    GameObjectHelper.FastSetActive(self.btnShare.gameObject, cache.getIsOpenShareSDK())
    GameObjectHelper.FastSetActive(self.shareInfo, cache.getIsOpenShareSDK() and not cache.getIsShareTaskComplete())    
    self:ShowConstructSound(self.courtBuildModel)


end

function CourtMainView:RefreshBuild(buildType, courtBuildModel)
    self:ShowConstructSound(courtBuildModel)
end

function CourtMainView:OnConstructEnd()
    if self.actionConstruct then
        Object.Destroy(self.actionConstruct.gameObject)
        self.actionConstruct = nil
    end
end

function CourtMainView:OnConstruct()
    self.actionConstruct = AudioManager.GetPlayer("ActionConstruct")
    local index = math.random(1, 2)
    self.actionConstruct.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/Court/Construct" .. tostring(index) .. ".mp3", 0.2)
end

function CourtMainView:ShowConstructSound(courtBuildModel)
    local time = courtBuildModel and courtBuildModel:GetBuildUpgradingTime() or 0
    local isCooling = tobool(time > 0)
    if isCooling then 
        self:OnConstruct()
    else
        self:OnConstructEnd()
    end
end

function CourtMainView:CourtTimer(timeUser, time, courtBuildType)
    local timer = { time = time, courtBuildType = courtBuildType }
    self.timer[timeUser] = timer
end

function CourtMainView:CourtTimeDie(timeUser)
    if self.timer then 
        self.timer[timeUser] = nil
    end
end


function CourtMainView:OnBtnShare()
    self:SetViewOnShareRender()
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        ShareHelper.CaptrueCamera(ShareConstants.Type.Court)
    end)
end

function CourtMainView:UpdateShareTaskState()
    GameObjectHelper.FastSetActive(self.shareInfo,not cache.getIsShareTaskComplete())
end

function CourtMainView:SetViewOnShareRender()
    GameObjectHelper.FastSetActive(self.btnShare.gameObject, false)
end

function CourtMainView:SetViewOnShareRenderComplete()
    GameObjectHelper.FastSetActive(self.btnShare.gameObject, true)
end

function CourtMainView:SetViewOnShareComplete()
    GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
end

function CourtMainView:OnShareComplete()
    self:SetViewOnShareComplete()
end

function CourtMainView:OnShareCancel()
    self:SetViewOnShareRenderComplete()
end

function CourtMainView:OnEnterScene()
    self.stadiumView:OnEnterScene()
    self.scoutingView:OnEnterScene()
    self.parkView:OnEnterScene()
    EventSystem.AddEvent("CourtTimer", self, self.CourtTimer)
    EventSystem.AddEvent("CourtTimeDie", self, self.CourtTimeDie)
    EventSystem.AddEvent("CourtLevelUp", self, self.CourtLevelUp)
    EventSystem.AddEvent("CourtComplete", self, self.CourtComplete)
    EventSystem.AddEvent("RefreshBuild", self, self.RefreshBuild)
    EventSystem.AddEvent("ShareRenderComplete", self, self.SetViewOnShareRenderComplete)
    EventSystem.AddEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    luaevt.reg("ShareSDK_OnComplete", function(cate, action)
        self:OnShareComplete() 
    end)
    luaevt.reg("ShareSDK_OnCancel", function(cate, action)
        self:OnShareCancel()
    end)

    self:RegisterAudioListener()
end

function CourtMainView:OnExitScene()
    self.stadiumView:OnExitScene()
    self.scoutingView:OnExitScene()
    self.parkView:OnExitScene()
    EventSystem.RemoveEvent("CourtTimer", self, self.CourtTimer)
    EventSystem.RemoveEvent("CourtTimeDie", self, self.CourtTimeDie)
    EventSystem.RemoveEvent("CourtComplete", self, self.CourtComplete)
    EventSystem.RemoveEvent("RefreshBuild", self, self.RefreshBuild)
    EventSystem.RemoveEvent("CourtLevelUp", self, self.CourtLevelUp)
    EventSystem.RemoveEvent("ShareRenderComplete", self, self.SetViewOnShareRenderComplete)
    EventSystem.RemoveEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    luaevt.unreg("ShareSDK_OnComplete")
    luaevt.unreg("ShareSDK_OnCancel")
    self:OnConstructEnd()
    self:RemoveAudioListener()
end

function CourtMainView:CourtLevelUp(courtBuildType)
    if self.courtLevelUp then 
        self.courtLevelUp(courtBuildType)
    end
end

function CourtMainView:CourtComplete(courtBuildType)
    if self.courtComplete then 
        self.courtComplete(courtBuildType)
    end
end

function CourtMainView:RefreshBuildTime(courtBuildType)
    if self.refreshBuildTime then 
        self.refreshBuildTime(courtBuildType)
    end
end

function CourtMainView:update()
    local time = self.courtBuildModel and self.courtBuildModel:GetBuildUpgradingTime() or 0
    if time > 0 then
        time = time - Time.unscaledDeltaTime
        local courtBuildType = self.courtBuildModel:GetBuildUpgradingType()
        self.courtBuildModel:SetBuildTime(courtBuildType, time)
        if time < 0 then
            self:RefreshBuildTime(courtBuildType)
        else
            for timeUser, timer in pairs(self.timer) do
                if timer.courtBuildType == courtBuildType then
                    timeUser:UpdateTime(time)
                elseif self.courtBuildModel:IsBuildChild(timer.courtBuildType, courtBuildType) then 
                    timeUser:UpdateChildTime(time, courtBuildType)   
                end
            end
        end
    end
end

return CourtMainView
