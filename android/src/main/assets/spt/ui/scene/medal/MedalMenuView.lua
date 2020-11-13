local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local Skills = require("data.Skills")
local MedalMenuView = class(unity.base)

function MedalMenuView:ctor()
    self.close = self.___ex.close
    self.scrollView = self.___ex.scrollView
    self.canvasGroup = self.___ex.canvasGroup
    self:RegScrollViewHandle()
end

function MedalMenuView:start()
    DialogAnimation.Appear(self.transform)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
end

function MedalMenuView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MedalMenuView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/BenedictionBar.prefab")
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index] 
        spt:InitView(data)
    end)
end

function MedalMenuView:InitView()
    local medalSkills = {}
    for sid, v in pairs(Skills) do
        if tonumber(v.isMedalSkill) == 1 then 
            table.insert(medalSkills, v)
        end
    end
    self.scrollView:refresh(medalSkills)
end

return MedalMenuView
