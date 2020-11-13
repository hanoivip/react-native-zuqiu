local LeagueConstants = require("ui.scene.league.LeagueConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CommonConstants = require("ui.common.CommonConstants")
local LeagueBgmPlayer = require("ui.scene.league.LeagueBgmPlayer")

local LeagueSponsorPageView = class(unity.base)

function LeagueSponsorPageView:ctor()
    -- 赞助商区域
    self.sponsorArea = self.___ex.sponsorArea
    -- 顶部信息条框
    self.infoBarBox = self.___ex.infoBarBox
    -- 动画管理器
    self.animator = self.___ex.animator
    -- model
    self.leagueInfoModel = nil
    -- 赞助商列表数据
    self.sponsorList = nil
    -- 选择的赞助商Id
    self.selectedSponsorID = nil
end

function LeagueSponsorPageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.sponsorList = self.leagueInfoModel:GetSponsorList()
    self:InitSponsorArea()
    GuideManager.Show()
end

function LeagueSponsorPageView:RegOnDynamicLoad(func)
    self.infoBarBox:RegOnDynamicLoad(func)
end

function LeagueSponsorPageView:start()
    self:RegisterEvent()
end

--- 注册事件
function LeagueSponsorPageView:RegisterEvent()
    EventSystem.AddEvent("LeagueSponsor_SelectSponsor", self, self.OnSelectSponsor)
end

--- 移除事件
function LeagueSponsorPageView:RemoveEvent()
    EventSystem.RemoveEvent("LeagueSponsor_SelectSponsor", self, self.OnSelectSponsor)
end

--- 初始化奖励区域
function LeagueSponsorPageView:InitSponsorArea()
    for i, sponsorData in ipairs(self.sponsorList) do
        local groupScripts = self.sponsorArea["group" .. i]
        groupScripts:InitView(self.leagueInfoModel, sponsorData)
    end
end

function LeagueSponsorPageView:OnSelectSponsor(sponsorID)
    self.selectedSponsorID = sponsorID
    self:PlayMoveOutAnim()
end

--- 选择赞助商
function LeagueSponsorPageView:RequestSelectSponsor()
    clr.coroutine(function()
        local response = req.leagueSponsor(self.selectedSponsorID)
        if api.success(response) then
            local data = response.val
            LeagueBgmPlayer.StopPlayBgm()
            self.leagueInfoModel:GetLeagueCtrl():RequestScheduleList(nil, true)
        end
    end)
end

function LeagueSponsorPageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut")
end

function LeagueSponsorPageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:RequestSelectSponsor()
    end
end

function LeagueSponsorPageView:onDestroy()
    self:RemoveEvent()
end

return LeagueSponsorPageView
