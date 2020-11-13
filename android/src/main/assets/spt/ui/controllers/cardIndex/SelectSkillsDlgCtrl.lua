local BaseCtrl = require("ui.controllers.BaseCtrl")
local SelectSkillsDlgCtrl = class(BaseCtrl)
local SkillItemModel = require("ui.models.common.SkillItemModel")
local Skill = require("data.Skills")
local SkillType = require("ui.common.enum.SkillType")
SelectSkillsDlgCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardIndex/CardIndexSkillList.prefab"
SelectSkillsDlgCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
function SelectSkillsDlgCtrl:Init(cardIndexSearchModel)
    self.selectSkills = {}
    for k, v in pairs(Skill) do
        if v.type == SkillType.EVENT then
            local skillItemModel = SkillItemModel.new()
            skillItemModel:InitByID(k)
            table.insert(self.view.scroll.itemDatas, skillItemModel)
        end
    end

    self.view.scroll:regOnCreateItem(function(scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/CardIndex/SkillFrameInCardIndex.prefab"
        local obj, spt = res.Instantiate(prefab)
        self.view.scroll:resetItem(spt, index)
        return obj
    end)

    self.view.scroll:regOnResetItem(function(scrollSelf, spt, index)
        local skillModel = self.view.scroll.itemDatas[index]
        local sid = skillModel.sid
        if not self.selectSkills[sid] then
            spt.border:SetActive(false)
        else
            spt.border:SetActive(true)
        end
        spt:InitView(self.view.scroll.itemDatas[index])
        spt:SetClickFunc(function()
            local sidTab = table.keys(self.selectSkills)
            if not self.selectSkills[sid] then
                if #sidTab < 3 then
                    self.selectSkills[sid] = true
                    spt.border:SetActive(true)
                end
            else
                self.selectSkills[sid] = nil
                spt.border:SetActive(false)
            end
            local sidTab = table.keys(self.selectSkills)
            self.view:SetCountText(#sidTab .. " / 3")
        end)
    end)

    self.view.scroll:refresh()

    self.view.OnClose = function()
        cardIndexSearchModel:SetSkills(table.keys(self.selectSkills))
        self.view.closeDialog()
    end
end

return SelectSkillsDlgCtrl
