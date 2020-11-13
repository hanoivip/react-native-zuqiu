local OldPlayerModel = require("ui.models.oldPlayer.OldPlayerModel")
local SevenDayLoginModel = require("ui.models.activity.SevenDayLoginModel")
local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")
local HomeEnterBtnGroupCtrl = class()

function HomeEnterBtnGroupCtrl:ctor(view, viewParent, parentCtrl)
    self.parentCtrl = parentCtrl
    if view then 
        self.HomeEnterBtnGroupView = view
    end
    self.HomeEnterBtnGroupView.clickOldPlayer = function() self:OnBtnOldPlayer(true) end
    self.HomeEnterBtnGroupView.clickSevenDay = function() self:OnBtnSevenDay(true) end
    EventSystem.AddEvent("HomeEnterBtnAtuoShow", self, self.AtuoShow)
end

function HomeEnterBtnGroupCtrl:InitWithProtocol(data)
    local flags = {}
    flags.bcShow = data.bcShow
    flags.sevenDayShow = data.sevenDayShow
    flags.oldPlayerShow = data.oldPlayer
    cache.setEnterBtnGroupShowFlags(flags)
    self.HomeEnterBtnGroupView:InitView()
    self:BeginShowPage()
end

function HomeEnterBtnGroupCtrl:BeginShowPage()
     if not cache.getEnterBtnGroupFirstShowFlags() then
        self:InitShowOrder()
        cache.setEnterBtnGroupFirstShowFlags(true)
        self:AtuoShow()
    end
end

-- 关一个弹一个
function HomeEnterBtnGroupCtrl:AtuoShow()
    local mStack = cache.getEnterBtnGroupStack()
    if mStack then
        local mFunc = cache.stackpop(mStack)
        if mFunc then
            mFunc()
        end
    end
end

--栈，所以要倒着放
function HomeEnterBtnGroupCtrl:InitShowOrder()
    if self.backPages then
        for k,v in pairs(self.backPages) do
            if v and type(v) == "function" then
                self:AddPage(v)
            end
        end
    end

    local showFlag = cache.getEnterBtnGroupShowFlags()
    if showFlag.oldPlayerShow then
        self:AddPage(function()
            self:OnBtnOldPlayer(false)
        end)
    end
    
    if showFlag.sevenDayShow then
        self:AddPage(function()
            self:OnBtnSevenDay(false)
        end)
    end
    
    if self.frontPages then
        for k,v in pairs(self.frontPages) do
            if v and type(v) == "function" then
                self:AddPage(v)
            end
        end
    end
end

--加推荐页签
function HomeEnterBtnGroupCtrl:AddPage(func)
    if cache.getEnterBtnGroupFirstShowFlags() then
        return
    end
    local mStack = cache.getEnterBtnGroupStack()
    if not mStack then
        mStack = cache.stacknew()
    end
    cache.stackpush(mStack, func)
    cache.setEnterBtnGroupStack(mStack)
end

--外部加推荐页签
function HomeEnterBtnGroupCtrl:AddPageFront(func)
    if not self.frontPages then
        self.frontPages = {}
    end
    table.insert(self.frontPages, func)
end

function HomeEnterBtnGroupCtrl:AddPageBack(func)
    if not self.backPages then
        self.backPages = {}
    end
    table.insert(self.backPages, func)
end

function HomeEnterBtnGroupCtrl:OnBtnOldPlayer(isBtnClick)
    clr.coroutine(function()
        local response = req.oldPlayerCallBack()
        if api.success(response) then
            local data = response.val
            if data and data.list and next(data.list) then
                self.oldPlayerModel = OldPlayerModel.new(isBtnClick)
                self.oldPlayerModel:InitWithProtocol(data.list)
                if not self.oldPlayerModel:IsShowView() then
                    EventSystem.SendEvent("HomeEnterBtnAtuoShow")
                    return
                end
                res.PushDialog("ui.controllers.oldPlayer.OldPlayerCtrl", self.oldPlayerModel)
            else
                if isBtnClick then
                    DialogManager.ShowToast(lang.trans("visit_endInfo"))
                end
                EventSystem.SendEvent("HomeEnterBtnAtuoShow")
            end
        end
    end)
end

function HomeEnterBtnGroupCtrl:OnBtnSevenDay(isBtnClick)
    clr.coroutine(function()
        local response = req.activitySevenDayLogin()
        if api.success(response) then
            local data = response.val
            if data.list and next(data.list) then
                self.sevenDayLoginModel = SevenDayLoginModel.new(isBtnClick)
                self.sevenDayLoginModel:InitWithProtocol(data.list)
                if not self.sevenDayLoginModel:IsShowView() then
                    EventSystem.SendEvent("HomeEnterBtnAtuoShow")
                    return
                end
                res.PushDialog("ui.controllers.activity.content.SevenDayLoginCtrl", self.sevenDayLoginModel)
            end
        end
    end)
end

function HomeEnterBtnGroupCtrl:OnExitScene()
    EventSystem.RemoveEvent("HomeEnterBtnAtuoShow", self, self.AtuoShow)
end

return HomeEnterBtnGroupCtrl
