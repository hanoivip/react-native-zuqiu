local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local CardIndexConstants = require("ui.scene.cardIndex.CardIndexConstants")

local CardIndexPopupListView = class(unity.base)

function CardIndexPopupListView:ctor()
    -- 输入框
    self.inputField = self.___ex.inputField
    -- 下拉按钮
    self.listBtn = self.___ex.listBtn
    -- 下拉列表
    self.listBox = self.___ex.listBox
    -- 滚动视图
    self.scrollerView = self.___ex.scrollerView
    -- 视图模型
    self.cardIndexViewModel = nil
    -- 列表类型
    self.listType = nil
    -- 下拉列表是否显示
    self.isListBoxShowing = false
end

function CardIndexPopupListView:InitView(cardIndexViewModel, listType)
    self.cardIndexViewModel = cardIndexViewModel
    self.listType = listType
    self.scrollerView:InitView(self.cardIndexViewModel, self.listType)
end

function CardIndexPopupListView:start()
    self:BindAll()
    self:RegisterEvent()
end

function CardIndexPopupListView:RegisterEvent()
    EventSystem.AddEvent("CardIndex.UpdateInputField", self, self.UpdateInputField)
    EventSystem.AddEvent("CardIndex.CloseOtherListBox", self, self.CloseOtherListBox)
end

function CardIndexPopupListView:RemoveEvent()
    EventSystem.RemoveEvent("CardIndex.UpdateInputField", self, self.UpdateInputField)
    EventSystem.RemoveEvent("CardIndex.CloseOtherListBox", self, self.CloseOtherListBox)
end

function CardIndexPopupListView:BindAll()
    -- 下拉按钮
    self.listBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("CardIndex.CloseOtherListBox", self.listType)
        self:ToggleListBox()
    end)
end

function CardIndexPopupListView:BuildPage()
    self:SetInputFieldText()
    self.listBox.localScale = Vector3(1, 0, 1)
end

--- 设置输入栏文本
function CardIndexPopupListView:SetInputFieldText()
    if self.listType == CardIndexConstants.ListType.POSITION then
        local pos = self.cardIndexViewModel:GetPos()
        self.inputField.text = pos or ""
    elseif self.listType == CardIndexConstants.ListType.NATIONALITY then
        local nationality = self.cardIndexViewModel:GetNationality()
        self.inputField.text = nationality or ""
    end
end

--- 切换搜索框的位置
function CardIndexPopupListView:ToggleListBox()
    self.isListBoxShowing = not self.isListBoxShowing
    local tweener = ShortcutExtensions.DOScaleY(self.listBox, self.isListBoxShowing and 1 or 0, 0.2)

    if self.isListBoxShowing then
        self.listBox.gameObject:SetActive(true)
    else
        TweenSettingsExtensions.OnComplete(tweener, function ()  --Lua assist checked flag
            self.listBox.gameObject:SetActive(false)
        end)
    end
end

function CardIndexPopupListView:CloseOtherListBox(listType)
    if self.listType ~= listType and self.isListBoxShowing then
        self:ToggleListBox()
    end
end

--- 更新输入栏
function CardIndexPopupListView:UpdateInputField(listType, text)
    if self.listType == listType then
        self.inputField.text = text
        self:ToggleListBox()
    end
end

--- 获取输入栏文本
function CardIndexPopupListView:GetInputFieldText()
    return self.inputField.text
end

function CardIndexPopupListView:onDestroy()
    self:RemoveEvent()
end

return CardIndexPopupListView
