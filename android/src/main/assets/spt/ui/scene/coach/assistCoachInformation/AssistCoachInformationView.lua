local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Mathf = UnityEngine.Mathf
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssistCoachFilterModel = require("ui.models.coach.assistCoachInformation.AssistCoachFilterModel")

local AssistCoachInformationView = class(unity.base, "AssistCoachInformationView")

function AssistCoachInformationView:ctor()
    -- 资源框
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 中间面板
    self.mainView = self.___ex.mainView
    -- 助理教练情报列表
    self.infoScrollView = self.___ex.infoScrollView
    -- 没有情报
    self.txtNoneInfo = self.___ex.txtNoneInfo
    -- 玩法说明
    self.btnHelp = self.___ex.btnHelp
    -- 出售按钮
    self.btnSell = self.___ex.btnSell
    self.buttonSell = self.___ex.buttonSell
    -- 分解按钮
    self.btnDecompose = self.___ex.btnDecompose
    self.buttonDecompose = self.___ex.buttonDecompose
    -- 右侧已经使用的情报
    self.sptGroove = self.___ex.sptGroove
    -- 预期助教星级
    self.sptPreStars = self.___ex.sptPreStars
    -- 招募按钮
    self.btnRecruit = self.___ex.btnRecruit
    self.buttonRecruit = self.___ex.buttonRecruit
    -- 筛选
    self.filter = self.___ex.filter
    -- 去往助教情报搜集界面
    self.btnGacha = self.___ex.btnGacha
end

function AssistCoachInformationView:start()
    self:RegBtnEvent()
end

function AssistCoachInformationView:InitView(assistCoachInformationModel)
    self.model = assistCoachInformationModel

    self:InitScrollView()
    self:InitButtonState()
    self:InitRightBoard()
    -- 筛选
    self.filter:RegOnFilterItemChoosed(function(id, filterType)
        self:OnFilterItemChoosed(id, filterType)
    end)
    self.filter:InitView(self.model, self, AssistCoachFilterModel)
end

function AssistCoachInformationView:InitScrollView()
    self.infoScrollView:RegOnItemButtonClick("btnOperate", function(aciModel)
        self:OnItemBtnOperateClick(aciModel)
    end)
    self.infoScrollView:RegOnItemButtonClick("btnSelect", function(aciModel)
        self:OnItemBtnChooseClick(aciModel)
    end)
    self.infoScrollView:RegOnItemButtonClick("btnView", function(aciModel)
        self:OnItemBtnViewClick(aciModel)
    end)
    self:UpdateInfoScrollView()
end

function AssistCoachInformationView:UpdateInfoScrollView()
    local itemDatas = self.model:GetAciModelList()
    local hasInfo = table.nums(itemDatas) > 0
    GameObjectHelper.FastSetActive(self.txtNoneInfo.gameObject, not hasInfo)
    self.infoScrollView:InitView(itemDatas, self.model)
end

function AssistCoachInformationView:GetScrollNormalizedPosition()
    self.scrollPos = self.infoScrollView:GetScrollNormalizedPosition()
end

function AssistCoachInformationView:SetScrollNormalizedPosition()
    self.infoScrollView:SetScrollNormalizedPosition(self.scrollPos)
    self.scrollPos = nil
end

function AssistCoachInformationView:UpdateInfoScrollViewItem(index, itemModel)
    self.infoScrollView:UpdateItem(index, itemModel)
end

-- 按钮状态
function AssistCoachInformationView:InitButtonState()
    local choosedState = table.nums(self.model:GetChooseState()) > 0
    self.buttonSell.interactable = self.model:GetMarketOpenState() and choosedState
    self.buttonDecompose.interactable = choosedState

    local hasInfo = self.model:IsPlayerHasInformation()
    GameObjectHelper.FastSetActive(self.btnGacha.gameObject, not hasInfo)
    GameObjectHelper.FastSetActive(self.btnRecruit.gameObject, hasInfo)
    GameObjectHelper.FastSetActive(self.btnDecompose.gameObject, hasInfo)
end

-- 右侧面板
function AssistCoachInformationView:InitRightBoard()
    self.sptGroove.onGrooveItemCancel = function(aciModel)
        self:OnGrooveItemCancel(aciModel)
    end
    self.sptGroove:InitView(self.model.MaxUsedItemNum)
    self:UpdateRightBoard()
end

function AssistCoachInformationView:UpdateRightBoard()
    self.sptGroove:RemoveAll()
    local grooveState = self.model:GetGrooveState()
    for idx = 1, self.model.MaxUsedItemNum do
        if grooveState[idx] ~= nil then
            self:PutGrooveItem(idx, grooveState[idx])
        end
    end
    -- 预期星级
    self.sptPreStars:InitView(self.model:GetPreStar())
end

-- 使用一个槽位
function AssistCoachInformationView:PutGrooveItem(idx, aciModel)
    self.sptGroove:PutGrooveItem(idx, aciModel)
end

-- 置空一个槽位
function AssistCoachInformationView:RemoveGrooveItem(idx, aciModel)
    self.sptGroove:RemoveGrooveItem(idx, aciModel)
end

function AssistCoachInformationView:OnEnterScene()
end

function AssistCoachInformationView:OnExitScene()
end

function AssistCoachInformationView:RegBtnEvent()
    -- 更换
    self.btnHelp:regOnButtonClick(function()
        self:OnBtnHelpClick()
    end)
    -- 出售
    self.btnSell:regOnButtonClick(function()
        self:OnBtnSellClick()
    end)
    -- 分解
    self.btnDecompose:regOnButtonClick(function()
        self:OnBtnDecomposeClick()
    end)
    -- 招募
    self.btnRecruit:regOnButtonClick(function()
        self:OnBtnRecruitClick()
    end)
    -- 去往情报搜集界面
    self.btnGacha:regOnButtonClick(function()
        self:OnBtnGachaClick()
    end)
end

function AssistCoachInformationView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

function AssistCoachInformationView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

-- 点击页签
function AssistCoachInformationView:OnClickTab(tag)
    if self.onClickTab and type(self.onClickTab) == "function" then
        self.onClickTab(tag)
    end
end

-- 点击左侧列表中的操作按钮
function AssistCoachInformationView:OnItemBtnOperateClick(aciModel)
    if self.onItemBtnOperateClick and type(self.onItemBtnOperateClick) == "function" then
        self.onItemBtnOperateClick(aciModel)
    end
end

-- 点选左侧列表中的某项
function AssistCoachInformationView:OnItemBtnChooseClick(aciModel)
    if self.onItemBtnChooseClick and type(self.onItemBtnChooseClick) == "function" then
        self.onItemBtnChooseClick(aciModel)
    end
end

-- 查看情报详细描述
function AssistCoachInformationView:OnItemBtnViewClick(aciModel)
    if self.onItemBtnViewClick and type(self.onItemBtnViewClick) == "function" then
        self.onItemBtnViewClick(aciModel)
    end
end

-- 玩法说明
function AssistCoachInformationView:OnBtnHelpClick()
    if self.onBtnHelpClick and type(self.onBtnHelpClick) == "function" then
        self.onBtnHelpClick()
    end
end

-- 出售
function AssistCoachInformationView:OnBtnSellClick()
    if self.onBtnSellClick and type(self.onBtnSellClick) == "function" then
        self.onBtnSellClick()
    end
end

-- 分解
function AssistCoachInformationView:OnBtnDecomposeClick()
    if self.onBtnDecomposeClick and type(self.onBtnDecomposeClick) == "function" then
        self.onBtnDecomposeClick()
    end
end

-- 招募
function AssistCoachInformationView:OnBtnRecruitClick()
    if self.onBtnRecruitClick and type(self.onBtnRecruitClick) == "function" then
        self.onBtnRecruitClick()
    end
end

-- 去往助教情报搜集界面
function AssistCoachInformationView:OnBtnGachaClick()
    if self.onBtnGachaClick and type(self.onBtnGachaClick) == "function" then
        self.onBtnGachaClick()
    end
end

-- 点击槽位中情报取消放置
function AssistCoachInformationView:OnGrooveItemCancel(aciModel)
    if self.onGrooveItemCancel and type(self.onGrooveItemCancel) == "function" then
        self.onGrooveItemCancel(aciModel)
    end
end

-- 分解后更新
function AssistCoachInformationView:UpdateAfterDecompose()
    self:UpdateInfoScrollView()
    self:InitButtonState()
    self:UpdateRightBoard()
end

-- 招募后更新
function AssistCoachInformationView:UpdateAfterRecruit()
    self:UpdateInfoScrollView()
    self:InitButtonState()
    self:UpdateRightBoard()
end

-- 筛选相关
function AssistCoachInformationView:OnFilterItemChoosed(id, filterType)
    if self.onFilterItemChoosed and type(self.onFilterItemChoosed) == "function" then
        self.onFilterItemChoosed(id, filterType)
    end
end

return AssistCoachInformationView
