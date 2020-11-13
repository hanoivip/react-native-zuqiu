local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AssetFinder = require("ui.common.AssetFinder")

local CoachBaseInfoUpdateView = class(unity.base, "CoachBaseInfoUpdateView")

local Pos_Without_Dot = -28
local Pos_With_Dot = -43

function CoachBaseInfoUpdateView:ctor()
    self.canvasGroup = self.___ex.canvasGroup
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    self.txtTitleRef = self.___ex.txtTitleRef
    -- 指示器
    self.sptIndicators = self.___ex.sptIndicators
    -- 滑动框
    self.scrollView = self.___ex.scrollView
    self.scrollRect = self.___ex.scrollRect
    self.rctScrollView = self.___ex.rctScrollView
    -- 左右箭头
    self.btnArrowLeft = self.___ex.btnArrowLeft
    self.btnArrowRight = self.___ex.btnArrowRight

    -- 滑动框数据
    self.itemDatas = nil
    self.index = 1
end

function CoachBaseInfoUpdateView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function CoachBaseInfoUpdateView:InitView(coachBaseInfoUpdateModel)
    self.model = coachBaseInfoUpdateModel
    -- 设置标题
    local title = self.model:GetBoardTitle()
    self.txtTitle.text = title
    self.txtTitleRef.text = title
    if self.model:IsFormationBoard() then
        GameObjectHelper.FastSetActive(self.sptIndicators.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnArrowLeft.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnArrowRight.gameObject, false)
        self:InitFormationScrollView()
    elseif self.model:IsTacticsBoard() then
        GameObjectHelper.FastSetActive(self.sptIndicators.gameObject, true)
        GameObjectHelper.FastSetActive(self.btnArrowLeft.gameObject, true)
        GameObjectHelper.FastSetActive(self.btnArrowRight.gameObject, true)
        self:InitTacticsScrollView()
        self:InitIndicators()
        self.scrollView:scrollToCellImmediate(self.index)
    else
        dump("wrong board type!")
    end
end

function CoachBaseInfoUpdateView:RegBtnEvent()
    self.btnArrowLeft:regOnButtonClick(function()
        self:OnClickBtnArrowLeft()
    end)

    self.btnArrowRight:regOnButtonClick(function()
        self:OnClickBtnArrowRight()
    end)
end

function CoachBaseInfoUpdateView:OnEnterScene()
    EventSystem.AddEvent("CoachBaseInfoUpdate_OnChangeSelectedFormation", self, self.OnChangeSelectedFormation)
end

function CoachBaseInfoUpdateView:OnExitScene()
    EventSystem.RemoveEvent("CoachBaseInfoUpdate_OnChangeSelectedFormation", self, self.OnChangeSelectedFormation)
end

function CoachBaseInfoUpdateView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 初始化阵型面板的滑动框
function CoachBaseInfoUpdateView:InitFormationScrollView()
    self.itemDatas = self.model:GetFormationScrollData()
    self.rctScrollView.anchoredPosition = Vector2(0, Pos_Without_Dot)
    self.scrollView:RegOnItemButtonClick("btnChange", function(itemData) self:OnItemBtnChangeClick(itemData) end)
    self.scrollView:RegOnItemButtonClick("btnUpdate", function(itemData) self:OnItemBtnUpdateClick(itemData) end)
    self.scrollView:InitView(self.itemDatas)
    self.index = 1
    self:UpdateCtiItem(self.index)
end

-- 初始化战术面板的滑动框
function CoachBaseInfoUpdateView:InitTacticsScrollView()
    self.itemDatas = self.model:GetTacticsScrollData()
    self.rctScrollView.anchoredPosition = Vector2(0, Pos_With_Dot)
    self.scrollView:RegOnItemButtonClick("btnChange", function(itemData) self:OnItemBtnChangeClick(itemData) end)
    self.scrollView:RegOnItemButtonClick("btnUpdate", function(itemData) self:OnItemBtnUpdateClick(itemData) end)
    self.scrollView:InitView(self.itemDatas)
    self.scrollView:unregOnItemIndexChanged()
    self.scrollView:regOnItemIndexChanged(function(index)
        self:OnScrollViewIndexChanged(index)
    end)
    self.index = tonumber(self.model:GetUsedTacticIndex())
    self:UpdateCtiItem(self.index)
end

-- 滑动框滑动同步修改指示点
function CoachBaseInfoUpdateView:OnScrollViewIndexChanged(index)
    if self.itemDatas then
        self.index = index
        self.sptIndicators:GotoIndex(index)
        self:UpdateCtiItem(index)
        self:DisplayArrow()
    end
end

-- 左右箭头显示
function CoachBaseInfoUpdateView:DisplayArrow()
    if self.model:IsTacticsBoard() then
        GameObjectHelper.FastSetActive(self.btnArrowLeft.gameObject, self.index > 1)
        GameObjectHelper.FastSetActive(self.btnArrowRight.gameObject, self.index < #self.itemDatas)
    end
end

-- 更新消耗物品显示
function CoachBaseInfoUpdateView:UpdateCtiItem(index)
    if not index then index = self.index end
    if self.itemDatas then
        local ctiId = self.itemDatas[index].ctiId
        local ctiConfig = self.itemDatas[index].ctiConfig
    end
end

-- 初始化指示点
function CoachBaseInfoUpdateView:InitIndicators()
    if not self.itemDatas then return end

    local num = #self.itemDatas
    self.sptIndicators:InitView(num)
end

-- 箭头点击事件
function CoachBaseInfoUpdateView:OnClickBtnArrowLeft()
    if self.onClickBtnArrowLeft then
        self.onClickBtnArrowLeft()
    end
end

function CoachBaseInfoUpdateView:OnClickBtnArrowRight()
    if self.onClickBtnArrowRight then
        self.onClickBtnArrowRight()
    end
end

-- 切换阵型或切换战术按钮点击事件
function CoachBaseInfoUpdateView:OnItemBtnChangeClick(itemData)
    if self.onItemBtnChangeClick then
        self.onItemBtnChangeClick(itemData)
    end
end

-- 选择阵型后更新
function CoachBaseInfoUpdateView:OnChangeSelectedFormation(formationData)
    if self.onChangeSelectedFormation then
        self.onChangeSelectedFormation(formationData)
    end
end

-- 升级
function CoachBaseInfoUpdateView:OnItemBtnUpdateClick(itemData)
    if self.onItemBtnUpdateClick then
        self.onItemBtnUpdateClick(itemData)
    end
end

-- 升级后发送事件
function CoachBaseInfoUpdateView:SendUpdateAfterFormationUpgrade(idx, formationId, newData)
    EventSystem.SendEvent("CoachBaseInfoUpdate_UpdateAfterFormationUpgrade", idx, formationId, newData)
end

function CoachBaseInfoUpdateView:SendUpdateAfterTacticUpgrade(idx, tacticType, id, newData)
    EventSystem.SendEvent("CoachBaseInfoUpdate_UpdateAfterTacticUpgrade", idx, tacticType, id, newData)
end

return CoachBaseInfoUpdateView
