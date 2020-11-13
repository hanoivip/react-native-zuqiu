local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local PeakPlayerTeamsModel = require("ui.models.peak.PeakPlayerTeamsModel")
local Formation = require("data.Formation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")

local PeakFormationItemView = class(unity.base)

function PeakFormationItemView:ctor()
    self.formationTxt = self.___ex.formationTxt
    self.changeFormationBtn = self.___ex.changeFormationBtn
    self.cardParentRect = self.___ex.cardParentRect
    self.weatherBtn = self.___ex.weatherBtn
    self.formationBtn = self.___ex.formationBtn
    self.downBtn = self.___ex.downBtn
    self.upBtn = self.___ex.upBtn
    self.empty = self.___ex.empty
    self.toggle = self.___ex.toggle
    self.hide = self.___ex.hide
end

function PeakFormationItemView:start()
    self:RegBtn()
end

function PeakFormationItemView:InitView(data, peakId, isOn)
    self.data = data
    self.ptid = tonumber(peakId) - 1
    self.toggle.isOn = isOn == 0
    
    GameObjectHelper.FastSetActive(self.hide, self.toggle.isOn)
    res.ClearChildren(self.cardParentRect)
    GameObjectHelper.FastSetActive(self.empty, not next(self.data))
    if not next(self.data) then
        self.formationTxt.text = "——"
        return
    end
    self.formationTxt.text = Formation[tostring(data.formationID)].name

    local playerCardsMapModel = PlayerCardsMapModel.new()
    local captain = data.captain
    local cid
    if captain then
        cid = playerCardsMapModel:GetCardData(captain).cid
        local cardInfo = {}
        cardInfo.card = {}
        table.insert(cardInfo.card, {id = cid, num = 0, lvl = 1, upgrade = 0})
        
        local rewardParams = {
            parentObj = self.cardParentRect,
            rewardData = cardInfo,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = false,
            hideCount = true,
            isHideLvl = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function PeakFormationItemView:RegBtn()
    self.weatherBtn:regOnButtonClick(function ()
        self:OnSetHome()
    end)
    self.formationBtn:regOnButtonClick(function ()
        self:OnFormationBtnClick()
    end)
    self.downBtn:regOnButtonClick(function ()
        if self.downBtnClick then
            self.downBtnClick()
        end
    end)
    self.upBtn:regOnButtonClick(function ()
        if self.upBtnClick then
            self.upBtnClick()
        end
    end)
end

function PeakFormationItemView:GetLockStatus()
    return self.ptid + 1, self.toggle.isOn
end

function PeakFormationItemView:ShowToggleOrFormationBtn(isShowOrderStatus)
    GameObjectHelper.FastSetActive(self.downBtn.gameObject, isShowOrderStatus)
    GameObjectHelper.FastSetActive(self.upBtn.gameObject, isShowOrderStatus)
    GameObjectHelper.FastSetActive(self.formationBtn.gameObject, not isShowOrderStatus)
    GameObjectHelper.FastSetActive(self.toggle.gameObject, false)
end

function PeakFormationItemView:ShowLockOrFormationBtn(isShowLockStatus)
    GameObjectHelper.FastSetActive(self.downBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.upBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.formationBtn.gameObject, not isShowLockStatus)
    GameObjectHelper.FastSetActive(self.toggle.gameObject, isShowLockStatus)
end

function PeakFormationItemView:OnSetHome()
    local courtBuildModel = CourtBuildModel.new()
    if courtBuildModel.data and type(courtBuildModel.data) == "table" then
        res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig["Peak" .. (self.ptid + 1)])
    else
        clr.coroutine(function()
            local response = req.buildInfo()
            if api.success(response) then
                local data = response.val
                local courtBuildModel = CourtBuildModel.new()
                courtBuildModel:InitWithProtocol(data)
                res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig["Peak" .. (self.ptid + 1)])
            end
        end)
    end
end

function PeakFormationItemView:OnFormationBtnClick()
    local modelData = {}
    if next(self.data) then
        modelData.currTid = self.ptid
        modelData.teams = {}
        modelData.teams[tostring(self.ptid)] = self.data
    end

    local peakPlayerTeamsModel = PeakPlayerTeamsModel.new(modelData, self.ptid)
	local index = tonumber(self.ptid) + 1
	peakPlayerTeamsModel:SetCourtTeamType(FormationConstants.TeamType["PEAK"] .. tostring(index))
    peakPlayerTeamsModel:SetTeamType(FormationConstants.TeamType.PEAK)
    res.PushScene("ui.controllers.peak.PeakFormationPageCtrl", peakPlayerTeamsModel)
end

return PeakFormationItemView