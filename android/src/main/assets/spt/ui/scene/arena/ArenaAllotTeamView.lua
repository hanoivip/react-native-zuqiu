local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local ArenaAllotTeamView = class(unity.base)

function ArenaAllotTeamView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.arenaTitle = self.___ex.arenaTitle
    self.arenaAllot = self.___ex.arenaAllot
    self.teamLogoMap = self.___ex.teamLogoMap
    self.teamNameMap = self.___ex.teamNameMap
    self.btnConfirm = self.___ex.btnConfirm
    self.arenaTitleIcon = self.___ex.arenaTitleIcon
    self.displayArea = self.___ex.displayArea
    self.cup = self.___ex.cup
    self.animator = self.___ex.animator
    self:IsShowDisplayArea(false)
end

function ArenaAllotTeamView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
end

function ArenaAllotTeamView:OnBtnConfirm()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function ArenaAllotTeamView:IsShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.displayArea.gameObject, isShow)
end

function ArenaAllotTeamView:InitView(data, arenaType)
    self:IsShowDisplayArea(true)
    local title = arenaType .. "_arena"
    self.arenaTitle.text = lang.trans(title)
    local group = data.group
    local allotGroup = group.group
    local list = group.list
    local arenaIndex = ArenaIndexType[arenaType]
    self.arenaTitleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Arena/Arena" .. arenaIndex .. ".png")
    self.arenaAllot.text = lang.trans("arena_team_allot", allotGroup)
    self.cup.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Details/Bytes/Cup" .. arenaIndex .. ".png")
    --self.cup:SetNativeSize()

    for i, v in ipairs(list) do
        local playerInfoModel = PlayerInfoModel.new()
        local playerId = playerInfoModel:GetID()
        TeamLogoCtrl.BuildTeamLogo(self.teamLogoMap["s" .. i], v.logo)

        local color = playerId == v._id and Color.yellow or Color.white
        local name = self.teamNameMap["s" .. i]
        name.text = tostring(v.name)
        name.color = color
    end
end

function ArenaAllotTeamView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function ArenaAllotTeamView:ShowAnimation()
    self.animator:Play("AllotTeamEntryAnimation", 0, 0)
end

function ArenaAllotTeamView:OnClickBackAnimation()
    self.animator:Play("AllotTeamLeaveAnimation", 0, 0)
end

function ArenaAllotTeamView:OnAnimationLeave()
    self:OnBtnBack()
end

function ArenaAllotTeamView:OnBtnBack()
    if self.clickBack then 
        self.clickBack()
    end
end

return ArenaAllotTeamView
