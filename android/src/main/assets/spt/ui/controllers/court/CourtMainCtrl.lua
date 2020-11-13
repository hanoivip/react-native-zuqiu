local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local CourtBgMusicCtrl = require("ui.controllers.court.CourtBgMusicCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local ShareHelper = require("ui.common.ShareHelper")

local BaseCtrl = require("ui.controllers.BaseCtrl")
local CourtMainCtrl = class(BaseCtrl, "CourtMainCtrl")

CourtMainCtrl.viewPath = "Assets/CapstonesRes/Game/Models/PitchBuild/QJ/Scene/QJ_Base.unity"

function CourtMainCtrl:AheadRequest()
    local response = req.buildInfo()
    if api.success(response) then
        local data = response.val
        local courtBuildModel = CourtBuildModel.new()
        courtBuildModel:InitWithProtocol(data)
    end
end

function CourtMainCtrl:Init()
    self.view.refreshBuildTime = function(courtBuildType) self:RefreshBuildTime(courtBuildType) end 
    self.view.courtLevelUp = function(courtBuildType) self:CourtLevelUp(courtBuildType) end 
    self.view.courtComplete = function(courtBuildType) self:CourtComplete(courtBuildType) end 
    self.view.onDestroyEvent = function() self:OnDestroyEvent() end
    self.view.clickShare = function() self:OnBtnShare() end
    self.view.clickBack = function() self:OnClickBack() end
    CourtBgMusicCtrl.StartPlayBgm()
    GuideManager.InitCurModule("court")
    if GuideManager.GuideIsOnGoing("court") then 
        EventSystem.SendEvent("CourtMobileTouchEventSwitch", false)
    end
    GuideManager.Show(self)
end

function CourtMainCtrl:OnDestroyEvent()
    CourtBgMusicCtrl.StopPlayBgm()
end

function CourtMainCtrl:OnClickBack()
    self:OnDestroyEvent()
    res.ChangeScene("ui.controllers.home.HomeMainCtrl")
end

function CourtMainCtrl:Refresh()
    CourtMainCtrl.super.Refresh(self)
    self.view:InitView()
    local loadType = self.__loadType
    if loadType and loadType == res.LoadType.Pop then
        self.view:ShowClouds(false)
    else
        self.view:ShowClouds(true)
    end
end

-- isRefresh 在客户端倒计时走完时重新刷新服务器数据
function CourtMainCtrl:PostMessage(isRefresh, courtBuildType)
    clr.coroutine(function()
        local response = req.buildInfo()
        if api.success(response) then
            local data = response.val
            local courtBuildModel = CourtBuildModel.new()
            if isRefresh then -- 服务器判断刷新时间时比客户端慢，会先返回客户端原始等级再升级
                local oldBuildLvl = courtBuildModel:GetBuildLevel(courtBuildType)  
                courtBuildModel:InitWithProtocol(data)
                local newBuildLvl = courtBuildModel:GetBuildLevel(courtBuildType)  
                local buildTime = courtBuildModel:GetBuildTime(courtBuildType)
                if buildTime <= 0 and oldBuildLvl == newBuildLvl then 
                    local nextLvl = newBuildLvl + 1
                    courtBuildModel:SetBuildLevel(courtBuildType, nextLvl)
                    res.PushDialog("ui.controllers.court.LevelUpNoticeCtrl", courtBuildModel, courtBuildType, nextLvl)
                end
                EventSystem.SendEvent("RefreshBuild", courtBuildType, courtBuildModel)
            else
                courtBuildModel:InitWithProtocol(data)
            end
            self.view:InitView(isRefresh)
        end
    end)
end

function CourtMainCtrl:CourtLevelUp(courtBuildType) 
    local courtBuildModel = CourtBuildModel.new()
    local hasBuildUpgrading = courtBuildModel:HasBuildUpgrading()
    if hasBuildUpgrading then 
        DialogManager.ShowToast(lang.trans("has_build_upgrading"))
    else
        local nextLvl = courtBuildModel:GetBuildLevel(courtBuildType) + 1
        local isOpen, needLvl, needBuildName = courtBuildModel:IsBuildOpen(courtBuildType, nextLvl)
        if isOpen then 
            clr.coroutine(function()
                local response = req.buildUpgrade(courtBuildType)
                if api.success(response) then
                    local data = response.val
                    courtBuildModel:SetBuildTime(courtBuildType, data.lastTime)
                    courtBuildModel:SetBuildLevel(courtBuildType, data.lvl)
                    local playerInfoModel = PlayerInfoModel.new()
                    local cost = data.cost
                    playerInfoModel:CostDetail(cost)
                    CustomEvent.ConsumeDiamond("1", tonumber(cost.num))
                    EventSystem.SendEvent("RefreshBuild", courtBuildType, courtBuildModel)
                end
            end)
        else
            if needBuildName == "League" then 
                DialogManager.ShowToast(lang.trans("need_league_open", needLvl))
            elseif needBuildName == "Stadium" then 
                DialogManager.ShowToast(lang.trans("need_stadium_open", needLvl))
            end
        end
    end
end

function CourtMainCtrl:CourtComplete(courtBuildType) 
    local courtBuildModel = CourtBuildModel.new()
    local currentUpgradingType = courtBuildModel:GetBuildUpgradingType()
    if currentUpgradingType and currentUpgradingType ~= courtBuildType then 
        DialogManager.ShowToast(lang.trans("has_build_upgrading_tip"))
    else
        clr.coroutine(function()
            local response = req.buildUpgradeCompleted()
            if api.success(response) then
                local data = response.val
                courtBuildModel:SetBuildTime(courtBuildType, 0)
                local currentLvl = courtBuildModel:GetBuildLevel(courtBuildType)
                local nextLvl = currentLvl + 1
                courtBuildModel:SetBuildLevel(courtBuildType, nextLvl)
                local playerInfoModel = PlayerInfoModel.new()
                local cost = data.cost
                playerInfoModel:CostDetail(cost)
                CustomEvent.ConsumeDiamond("1", tonumber(cost.num))
                EventSystem.SendEvent("RefreshBuild", courtBuildType, courtBuildModel)
                res.PushDialog("ui.controllers.court.LevelUpNoticeCtrl", courtBuildModel, courtBuildType, nextLvl)
            end
        end)
    end
end

function CourtMainCtrl:RefreshBuildTime(courtBuildType)
    self:PostMessage(true, courtBuildType)
end

function CourtMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CourtMainCtrl:OnExitScene()
    self.view:OnExitScene()
end

function CourtMainCtrl:OnBtnShare()
    ShareHelper.CaptrueCamera(ShareHelper.TextIndex.Court)
end

function CourtMainCtrl:Click(courtBuildType)
    if courtBuildType == CourtBuildType.StadiumBuild then 
        res.PushDialog("ui.controllers.court.CourtStadiumBuildCtrl")
        GuideManager.Show(self)
    elseif courtBuildType == CourtBuildType.ScoutBuild then 
        res.PushDialog("ui.controllers.court.CourtScoutBuildCtrl")
        GuideManager.Show(self)
    elseif courtBuildType == CourtBuildType.ParkingBuild then 
        res.PushDialog("ui.controllers.court.CourtParkingBuildCtrl")
        GuideManager.Show(self)
    elseif courtBuildType == CourtBuildType.TechnologyHallBuild then 
        res.PushDialog("ui.controllers.court.technologyHall.TechnologyHallCtrl")
    end
end

return CourtMainCtrl