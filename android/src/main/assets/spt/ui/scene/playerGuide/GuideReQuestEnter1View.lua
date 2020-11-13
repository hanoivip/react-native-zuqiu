local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local GuideReQuestEnter1View = class(unity.base)

function GuideReQuestEnter1View:ctor()
    self.btnContinue = self.___ex.btnContinue
end

function GuideReQuestEnter1View:start()
    if self.btnContinue then
        self.btnContinue:regOnButtonClick(function()
            self:OnContinue()
        end)
    end
end

function GuideReQuestEnter1View:OnContinue()
    Object.Destroy(self.gameObject)
end

function GuideReQuestEnter1View:onDestroy()
    res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/GuideReQuestEnter2.prefab")
end

return GuideReQuestEnter1View