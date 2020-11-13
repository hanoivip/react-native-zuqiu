local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local LoseGuideView = class(unity.base)

function LoseGuideView:ctor()
    -- 关闭按钮
    self.closeBtn = self.___ex.closeBtn
    -- 分类按钮组
    self.optionGroup = self.___ex.optionGroup
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    self.loseGuideModel = nil
end

function LoseGuideView:InitView(loseGuideModel)
    self.loseGuideModel = loseGuideModel
    self:BuildView()
end

function LoseGuideView:start()
    self:BindAll()
    self:RegisterEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function LoseGuideView:RegisterEvent()
    EventSystem.AddEvent("LoseGuide_Destroy", self, self.Destroy)
end

function LoseGuideView:RemoveEvent()
    EventSystem.RemoveEvent("LoseGuide_Destroy", self, self.Destroy)
end

function LoseGuideView:BindAll()
    -- 关闭按钮
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function LoseGuideView:BuildView()
    local isLeft = true
    local optionObj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/LoseGuide/LoseGuideOption.prefab")

    local data = self.loseGuideModel:GetData()
    for optionID, loseGuideOptionModel in pairs(data) do
        local optionGo = Object.Instantiate(optionObj)
        local optionScript = res.GetLuaScript(optionGo)
        optionGo.transform:SetParent(self.optionGroup, false)
        optionScript:InitView(loseGuideOptionModel, isLeft)
        isLeft = not isLeft
    end
end

function LoseGuideView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        self:Destroy()
    end)
end

function LoseGuideView:Destroy()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function LoseGuideView:onDestroy()
    self:RemoveEvent()
end

return LoseGuideView
