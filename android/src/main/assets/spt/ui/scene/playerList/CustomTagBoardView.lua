local Color = clr.UnityEngine.Color
local Regex = clr.System.Text.RegularExpressions.Regex
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local CustomTagBoardView = class(unity.base)

function CustomTagBoardView:ctor()
    CustomTagBoardView.super.ctor(self)
--------Start_Auto_Generate--------
    self.switchImg = self.___ex.switchImg
    self.tipBtn = self.___ex.tipBtn
    self.tabNameTitleTxt = self.___ex.tabNameTitleTxt
    self.tabColorTxt = self.___ex.tabColorTxt
    self.modifyBtn = self.___ex.modifyBtn
    self.modifyAbleGo = self.___ex.modifyAbleGo
    self.modifyDisableGo = self.___ex.modifyDisableGo
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.switchToggle = self.___ex.switchToggle
    self.tabName = self.___ex.tabName
    self.modifyButton = self.___ex.modifyButton
end

function CustomTagBoardView:start()
    -- 关闭界面
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    -- 标记开关状态改变
    self.switchToggle.onValueChanged.AddListener(function(isOn)
        self:OnSwitch(isOn)
    end)
    -- 标记名称修改
    self.modifyBtn:regOnButtonClick(function()
        if self.modifyButton.interactable and self.onModify then
            local name = Regex.Replace(self.tabName.text, "\\p{Cs}", "")
            self.onModify(name)
        end
    end)
    -- 标记关闭时的操作提示
    self.tipBtn:regOnButtonClick(function()
        DialogManager.ShowToastByLang("custom_tag_tip_1")
    end)
end

function CustomTagBoardView:InitView(tabModel, cid, customTagTxt)
    self.tabModel = tabModel
    self.cid = cid
    self.customTagTxt = customTagTxt
    local tag = tabModel:GetTagByCid(cid)
    self.tabName.text = tag
    if not state then
        self.tabColorTxt.color = Color(129/255, 129/255, 129/255)
    end
    self.state = tabModel:GetStateByCid(cid)
    self.switchToggle.isOn = self.state
    self:OnSwitch(self.state)
end

-- 标记开启/关闭状态的页面刷新
function CustomTagBoardView:OnSwitch(isOn)
    self.tabName.interactable = isOn
    self.modifyButton.interactable = isOn
    GameObjectHelper.FastSetActive(self.modifyAbleGo, isOn)
    GameObjectHelper.FastSetActive(self.modifyDisableGo, not isOn)
    GameObjectHelper.FastSetActive(self.tipBtn.gameObject, not isOn)
    local tag = self.tabModel:GetTagByCid(self.cid)
    if not tag then
        self.tabName.text = lang.transstr("custom_tag_enter")
    end
    if isOn then
        self.switchImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/Switch_Open.png")
        self.tabNameTitleTxt.color = Color(226/255, 226/255, 226/255)
        self.tabColorTxt.color = Color(169/255, 155/255, 106/255)
    else
        self.switchImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Images/Switch_Close.png")
        self.tabNameTitleTxt.color = Color(129/255, 129/255, 129/255)
        self.tabColorTxt.color = Color(129/255, 129/255, 129/255)
    end
end

-- 退出界面记录一次标记开关状态
function CustomTagBoardView:Close()
    local state = self.switchToggle.isOn
    local tag = self.tabModel:GetTagByCid(self.cid)
    if not tag then
        tag = lang.transstr("custom_tag_enter")
    end
    if state ~= self.state then
        clr.coroutine(function ()
            local response = req.albumEdit(self.cid, tag, state)
            if api.success(response) then
            local data = response.val
                local state = data.albumTag.switch
                local tag = data.albumTag.tag
                self.customTagTxt.text = tag
                GameObjectHelper.FastSetActive(self.customTagTxt.gameObject, state)
                self.tabModel:SetStateByCid(self.cid, state)
                self.tabModel:SetTagByCid(self.cid, tag)
                self:Exit()
            end
        end)
    else
        self:Exit()
    end
end

function CustomTagBoardView:Exit()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return CustomTagBoardView
