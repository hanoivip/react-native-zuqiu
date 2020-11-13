local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")
local PlayerDetailModel = require("ui.models.compete.championWall.CompeteChampionPlayerDetailModel")
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")

local CompeteChampionWallView = class(unity.base, "CompeteChampionWallView")

CompeteChampionWallView.menuTags = {
    big_ear = tostring(CompeteSchedule.Big_Ear_Match),
    small_ear = tostring(CompeteSchedule.Small_Ear_Match)
}

function CompeteChampionWallView:ctor()
    -- 返回按钮
    self.btnBack = self.___ex.btnBack
    -- 页签group
    self.tab = self.___ex.tab
    -- 列表
    self.championScroll = self.___ex.championScroll
    self.championScrollNone = self.___ex.championScrollNone
    -- 筛选
    self.filter_bigEar = self.___ex.filter_bigEar
    self.filter_smallEar = self.___ex.filter_smallEar
    -- 左侧标题
    self.txtTitle = self.___ex.txtTitle
    -- 左侧玩家名字
    self.txtName = self.___ex.txtName
    -- 球场
    self.objCourt = self.___ex.objCourt
    self.formation = self.___ex.formation
    -- 数据丢失
    self.txtNone = self.___ex.txtNone
    -- 冠军总览按钮
    self.btnOverview = self.___ex.btnOverview
    -- 赛季主题
    self.txtTheme = self.___ex.txtTheme
end

function CompeteChampionWallView:start()
    self:RegBtnEvent()
    self:ShowDisplayArea(false)
end

function CompeteChampionWallView:RegBtnEvent()
    self.btnBack:regOnButtonClick(function()
        if self.onClickBtnBack and type(self.onClickBtnBack) == "function" then
            self.onClickBtnBack()
        end
    end)
    self.tab:BindMenuItem(self.menuTags.big_ear, function()
        if self.onClickTab and type(self.onClickTab) == "function" then
            self.onClickTab(self.menuTags.big_ear)
        end
    end)
    self.tab:BindMenuItem(self.menuTags.small_ear, function()
        if self.onClickTab and type(self.onClickTab) == "function" then
            self.onClickTab(self.menuTags.small_ear)
        end
    end)
    self.btnOverview:regOnButtonClick(function()
        if self.onClickBtnOverview and type(self.onClickBtnOverview) == "function" then
            self.onClickBtnOverview()
        end
    end)
end

function CompeteChampionWallView:ShowDisplayArea(isShow)
    self:DisplayLeftBoard(isShow)
    self:DisplayRightBoard(isShow)
end

function CompeteChampionWallView:DisplayLeftBoard(isShow)
    GameObjectHelper.FastSetActive(self.txtTitle.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.txtName.gameObject, isShow)
    self.formation:ShowDisplayArea(isShow)
end

function CompeteChampionWallView:DisplayRightBoard(isShow)
    GameObjectHelper.FastSetActive(self.championScroll.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.championScrollNone.gameObject, not isShow)
end

function CompeteChampionWallView:InitView(competeChampionWallModel)
    self.model = competeChampionWallModel
    if not self.model then
        return
    end
    self.championScroll:RegOnItemButtonClick("clickMask", function(itemData) self:OnChampionItemClick(itemData) end)
    self:InitBigEarView()
    self:InitSmallEarView()
end

function CompeteChampionWallView:InitBigEarView()
    -- 筛选
    self.filter_bigEar:RegOnFilterItemChoosed(function(id, filterType)
        self:OnFilterItemChoosed(id, filterType)
    end)
end

function CompeteChampionWallView:InitSmallEarView()
    -- 筛选
    self.filter_smallEar:RegOnFilterItemChoosed(function(id, filterType)
        self:OnFilterItemChoosed(id, filterType)
    end)
end

function CompeteChampionWallView:RefreshView()
    self:RefreshRightBoardView() -- 必须在左侧面板前初始化
    self:RefreshLeftBoadView()
end

-- 左侧面板
function CompeteChampionWallView:SetFormationModel(playerDetailModel, otherPlayerTeamsModel)
    self.playerDetailModel = playerDetailModel
    self.otherPlayerTeamsModel = otherPlayerTeamsModel
end

function CompeteChampionWallView:RefreshLeftBoadView()
    local currData = self.model:GetSelectItemData()
    if currData and currData.init ~= nil and next(currData.init) then
        self:SetHasFormation(true)
        self.playerDetailModel = PlayerDetailModel.new()
        self.playerDetailModel:InitWithProtocol(currData)
        self.otherPlayerTeamsModel = OtherPlayerTeamsModel.new()
        if self.model:IsCurrItemInCurrList() then
            self:UpdateScrollItem(self.model:GetCurrIdx(), currData)
        end
        self:RefreshForamtion()
    else
        self:SetHasFormation(false)
    end
    self:RefreshTitle()
end

function CompeteChampionWallView:SetHasFormation(isShow)
    self.formation:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.txtNone.gameObject, not isShow)
end

-- 左侧信息
function CompeteChampionWallView:RefreshTitle()
    local currData = self.model:GetSelectItemData()
    if currData then
        local title = ""
        if currData.matchType == CompeteSchedule.Big_Ear_Match then
            title = tostring(currData.seasonName) .. lang.transstr("competition_season") .. lang.transstr("compete_introduce_leagueName1")
        elseif currData.matchType == CompeteSchedule.Small_Ear_Match then
            title = tostring(currData.seasonName) .. lang.transstr("competition_season") .. lang.transstr("compete_introduce_leagueName4")
        end
        self.txtTitle.text = title
        self.txtName.text = tostring(currData.serverName) .. " " .. currData.name
        self.txtTheme.text = lang.transstr("theme") .. ": " .. currData.theme
    end
end

-- 左侧阵型数据
function CompeteChampionWallView:RefreshForamtion()
    self.formation:InitView(self.playerDetailModel, self.otherPlayerTeamsModel)
end

-- 右侧面板
function CompeteChampionWallView:RefreshRightBoardView()
    local currTag = self.model:GetCurrTag() or self.menuTags.big_ear
    if currTag == self.menuTags.big_ear then
        self:RefreshBigEarView()
    elseif currTag == self.menuTags.small_ear then
        self:RefreshSmallEarView()
    end
end

function CompeteChampionWallView:RefreshBigEarView()
    self.tab:selectMenuItem(self.menuTags.big_ear)
    GameObjectHelper.FastSetActive(self.filter_bigEar.gameObject, true)
    GameObjectHelper.FastSetActive(self.filter_smallEar.gameObject, false)
    self.filter_bigEar:InitView(self.model, self, self.model:GetBigEarFilterModel())
    self:RefreshScrollView()
end

function CompeteChampionWallView:RefreshSmallEarView()
    self.tab:selectMenuItem(self.menuTags.small_ear)
    GameObjectHelper.FastSetActive(self.filter_bigEar.gameObject, false)
    GameObjectHelper.FastSetActive(self.filter_smallEar.gameObject, true)
    self.filter_smallEar:InitView(self.model, self, self.model:GetSmallEarFilterModel())
    self:RefreshScrollView()
end

function CompeteChampionWallView:RefreshScrollView()
    local itemDatas = self.model:GetCurrChampionList()
    if itemDatas ~= nil and table.nums(itemDatas) > 0 then
        self:DisplayRightBoard(true)
        self.championScroll:InitView(itemDatas, self.model)
    else
        self:DisplayRightBoard(false)
    end
end

function CompeteChampionWallView:UpdateScrollItem(idx, itemData)
    if idx ~= nil and itemData ~= nil then
        self.championScroll:UpdateItem(idx, itemData)
    end
end

function CompeteChampionWallView:OnEnterScene()
end

function CompeteChampionWallView:OnExitScene()
end

-- 页面事件回调
function CompeteChampionWallView:OnFilterItemChoosed(id, filterType)
    if self.onFilterItemChoosed and type(self.onFilterItemChoosed) == "function" then
        self.onFilterItemChoosed(id, filterType)
    end
end

function CompeteChampionWallView:OnChampionItemClick(itemData)
    if self.onChampionItemClick and type(self.onChampionItemClick) == "function" then
        self.onChampionItemClick(itemData)
    end
end

return CompeteChampionWallView
