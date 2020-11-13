local SkillParent = class(unity.base)

function SkillParent:ctor()
    self.border = self.___ex.border
    self.parent = self.___ex.parent
    self.clickArea = self.___ex.clickArea
    self.childSpt = nil
end

function SkillParent:InitView(model)
    if not self.childSpt then
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/SkillItemJp.prefab"
        local go, spt = res.Instantiate(prefab)
        go.transform:SetParent(self.parent.transform, false)
        self.childSpt = spt
    end
    self.childSpt:InitViewInSearch(model)
end

function SkillParent:SetClickFunc(func)
    if type(func) == "function" then
        self.clickArea:regOnButtonClick(func)
    end
end

return SkillParent
