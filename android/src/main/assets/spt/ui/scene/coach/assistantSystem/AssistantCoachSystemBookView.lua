local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachSystemBookView = class(unity.base, "AssistantCoachSystemBookView")

local RIGHT_PAGE_PATH = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSystemBookRight.prefab"
local LEFT_PAGE_PATH = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSystemBookLeft.prefab"

function AssistantCoachSystemBookView:ctor()
    -- 翻页插件
    self.book = self.___ex.book
    -- 自动翻页
    self.autoflip = self.___ex.autoflip
    -- 屏幕锁
    self.screenLock = self.___ex.screenLock

    -- 界面Model，AssistantCoachSystemModel
    self.model = nil
    -- 当前助教团队索引
    self.currTeamIdx = 1
    -- start函数是否执行完毕
    self.isStarted = false
    -- 是否Refresh
    self.isRefreshView = false
    -- 是否播放翻页动画
    self.isPlayFlipAnim = false
end

function AssistantCoachSystemBookView:start()
    self.isStarted = true
end

function AssistantCoachSystemBookView:onDestroy()
    self.isStarted = false
end

function AssistantCoachSystemBookView:InitView(assistantCoachSystemModel, isReadOnly)
    self.model = assistantCoachSystemModel
    self.isReadOnly = isReadOnly ~= nil and isReadOnly or false

    self:BuildView()
end

function AssistantCoachSystemBookView:RefreshView(desTeamIdx)
    if desTeamIdx ~= nil then
        self.currTeamIdx = desTeamIdx
    end
    self.isRefreshView = true
    self:BuildView()
    self.book:UpdateSprites()
    self.isRefreshView = false
end

function AssistantCoachSystemBookView:BuildView()
    self.book.currentPage = self.currTeamIdx * 2
    self.book.totalPageCount = self.model:GetCurrMaxTeam() * 2 + 1
    GameObjectHelper.FastSetActive(self.book.gameObject, true)
end

-- 翻到某个页面
-- @param teamIdx: 团队索引，从1开始
-- @param isScrollToStage: 是否滑动至页面
-- @param isPlayFlipAnim: 是否播放翻页动画
function AssistantCoachSystemBookView:GoToTeam(teamIdx, isScrollToStage, isPlayFlipAnim)
    if self.isStarted then
        self:Refresh(teamIdx, isPlayFlipAnim)
    end
end

function AssistantCoachSystemBookView:Refresh(teamIdx, isPlayFlipAnim)
    self.isPlayFlipAnim = isPlayFlipAnim
    if self.isPlayFlipAnim then
        GameObjectHelper.FastSetActive(self.screenLock, true)
        if self.currTeamIdx > teamIdx then
            self.autoflip:FlipLeftPage()
        elseif self.currTeamIdx < teamIdx then
            self.autoflip:FlipRightPage()
        end
        self.currTeamIdx = teamIdx
    else
        self.currTeamIdx = teamIdx
        self:RefreshView()
    end
end

-- 翻书C#脚本回调
-- @param pageIndex: 页面的索引，从1开始
-- @param bookPage: 将要生成的书页的父级
function AssistantCoachSystemBookView:onInstantiatePage(pageIndex, bookPage)
    local teamIdx = (pageIndex + pageIndex % 2) / 2
    local pagePath = (pageIndex % 2 == 1) and LEFT_PAGE_PATH or RIGHT_PAGE_PATH
    self:SetPage(bookPage, pagePath, teamIdx)
end

-- 设置书页内容
function AssistantCoachSystemBookView:SetPage(bookPage, pagePath, teamIdx)
    local pageObj = bookPage:GetChild()
    local pageView = nil
    local acModel = nil
    if self.model then
        acModel = self.model:GetAssistantCoachModelByTeamIdx(teamIdx)
    end
    if pageObj == nil or pageObj == clr.null then
        pageObj, pageView = res.Instantiate(pagePath)
        pageObj.transform:SetParent(bookPage.transform, false)
        bookPage:SetChild(pageObj)
        pageView:InitView(acModel, self.model, self.isReadOnly)
        self:RegPageEvent(pageView)
    else -- 原节点下有书页，无需生成
        pageView = res.GetLuaScript(pageObj)
        pageView:InitView(acModel, self.model, self.isReadOnly)
        self:RegPageEvent(pageView)
    end
end

-- 注册页面中按钮的点击事件
function AssistantCoachSystemBookView:RegPageEvent(pageVew)
    pageVew.onBtnSwitchTeam = function() self:OnBtnSwitchTeam() end
    pageVew.onBtnUpdateClick = function() self:OnBtnUpdateClick() end
    pageVew.onBtnSelect = function() self:OnBtnSelect() end
    pageVew.onBtnHire = function() self:OnBtnHire() end
end

function AssistantCoachSystemBookView:onFlip()
    GameObjectHelper.FastSetActive(self.screenLock, false)
    self.isPlayFlipAnim = false
end

-- 按钮事件
function AssistantCoachSystemBookView:OnBtnSwitchTeam()
    if self.onBtnSwitchTeam and type(self.onBtnSwitchTeam) == "function" then
        self.onBtnSwitchTeam()
    end
end

function AssistantCoachSystemBookView:OnBtnUpdateClick()
    if self.onBtnUpdateClick and type(self.onBtnUpdateClick) == "function" then
        self.onBtnUpdateClick()
    end
end

function AssistantCoachSystemBookView:OnBtnSelect()
    if self.onBtnSelect and type(self.onBtnSelect) == "function" then
        self.onBtnSelect()
    end
end

function AssistantCoachSystemBookView:OnBtnHire()
    if self.onBtnHire and type(self.onBtnHire) == "function" then
        self.onBtnHire()
    end
end

return AssistantCoachSystemBookView
