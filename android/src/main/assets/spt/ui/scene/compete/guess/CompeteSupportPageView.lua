local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local Formation = require("data.Formation")

local CompeteSupportPageView = class(unity.base, "CompeteSupportPageView")

function  CompeteSupportPageView:ctor()
    -- 返回按钮
    self.backBtn = self.___ex.backBtn
    -- 球员容器
    self.initPlayerGroup = self.___ex.initPlayerGroup
    -- 阵型界面
    self.formationView = self.___ex.formationView
    -- 玩家logo
    self.imgPlayerLogo = self.___ex.imgPlayerLogo
    -- 玩家名字
    self.txtPlayerName = self.___ex.txtPlayerName
    -- 争霸赛标识
    self.imgCompeteSign = self.___ex.imgCompeteSign
    -- head的GameObject
    self.objHead = self.___ex.objHead
    -- 支持按钮
    self.btnSupport = self.___ex.btnSupport
    -- 档位列表
    self.rewardScroll = self.___ex.rewardScroll
    -- 阵容名字
    self.txtFormation = self.___ex.txtFormation
    -- 货币信息
    self.infoBarDynParent = self.___ex.infoBarDynParent
end

function CompeteSupportPageView:start()
    self.backBtn:regOnButtonClick(function ()
        res.PopScene()
    end)
    GameObjectHelper.FastSetActive(self.objHead.gameObject, false)
    GameObjectHelper.FastSetActive(self.initPlayerGroup.gameObject, false)
end

function CompeteSupportPageView:InitView(competeSupportPageModel, otherPlayerTeamsModel, playerDetailModel)
    self.competeSupportPageModel = competeSupportPageModel
    self.playerDetailModel = playerDetailModel
    self.otherPlayerTeamsModel = otherPlayerTeamsModel

    self.formationView:InitView(playerDetailModel, otherPlayerTeamsModel)
    -- 球队名字&区服&等级
    self.txtPlayerName.text = competeSupportPageModel:GetName() .. "  (" .. competeSupportPageModel:GetServerName() .. ")  " .. lang.transstr("friends_manager_item_level", competeSupportPageModel:GetLvl())
    -- 阵容名字
    self:InitFormationName(otherPlayerTeamsModel:GetFormationId())
    -- 球队logo
    self:InitTeamLogo(self.imgPlayerLogo, competeSupportPageModel:GetLogo())
    -- 争霸赛标识
    self:InitCompeteSign(competeSupportPageModel:GetCompeteSign(), self.imgCompeteSign)
    -- 奖励列表
    self.rewardScroll:RegOnItemButtonClick("btnClick", function(itemData) self:OnRewardItemClick(itemData) end)
    self.rewardScroll:InitView(self.competeSupportPageModel:GetRewards())
end

function CompeteSupportPageView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

-- 初始化球队logo
function CompeteSupportPageView:InitTeamLogo(logoRct, logoData)
    TeamLogoCtrl.BuildTeamLogo(logoRct, logoData)
end

-- 初始化争霸赛标识
function CompeteSupportPageView:InitCompeteSign(competeSign, imgCompeteSign)
    local hasCompeteSign = false
    if competeSign then
        local signData = CompeteSignConvert[tostring(competeSign)]
        if signData then
            imgCompeteSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signData.path .. ".png")
            hasCompeteSign = true
        end
    end
    GameObjectHelper.FastSetActive(imgCompeteSign.gameObject, hasCompeteSign)
end

-- 初始化阵容名字
function CompeteSupportPageView:InitFormationName(formationId)
    self.txtFormation.text = lang.transstr("home_formation") .. Formation[tostring(formationId)].name
end

function CompeteSupportPageView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.objHead.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.initPlayerGroup.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.rewardScroll.gameObject, isShow)
end

function CompeteSupportPageView:OnEnterScene()
    EventSystem.AddEvent("ClickPlayerCardCircle", self, self.OnCardClick)
    EventSystem.AddEvent("CompeteGuess_SupportTeam", self, self.OnBtnSupport)
end

function CompeteSupportPageView:OnExitScene()
    EventSystem.RemoveEvent("ClickPlayerCardCircle", self, self.OnCardClick)
    EventSystem.RemoveEvent("CompeteGuess_SupportTeam", self, self.OnBtnSupport)
end

function CompeteSupportPageView:OnBtnSupport()
    if self.onBtnSupport then
        self.onBtnSupport()
    end
end

function CompeteSupportPageView:OnRewardItemClick(itemData)
    if self.onRewardItemClick then
        self.onRewardItemClick(itemData)
    end
end

function CompeteSupportPageView:OnCardClick(pcid)
    if self.onCardClick then
        self.onCardClick(pcid)
    end
end

return CompeteSupportPageView
