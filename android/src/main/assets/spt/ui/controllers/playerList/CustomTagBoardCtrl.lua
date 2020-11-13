local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CustomTagBoardCtrl = class(BaseCtrl)

CustomTagBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerList/CustomTagBoard.prefab"

function CustomTagBoardCtrl:Refresh(tabModel, cid, customTagTxt)
    self.tabModel = tabModel
    self.cid = cid
    self.customTagTxt = customTagTxt
    self.view:InitView(tabModel, cid, customTagTxt)
    self:Init()
end

function CustomTagBoardCtrl:Init()
    self.view.onModify = function(name) self:OnModify(name) end
end

-- 修改标记名称
function CustomTagBoardCtrl:OnModify(name)
    local oldTag = self.tabModel:GetTagByCid(self.cid)
    if name == "" then    -- 标记不能为空
        DialogManager.ShowToastByLang("chat_emptytips")
        return
    elseif name == oldTag then     -- 标记没有修改
        DialogManager.ShowToastByLang("custom_tag_name_no_change")
        return
    end
    clr.coroutine(function()
        local response = req.albumEdit(self.cid, name, true)
        if api.success(response) then
            DialogManager.ShowToastByLang("settings_modifySuccess")
            local data = response.val
            local tag = data.albumTag.tag
            self.customTagTxt.text = tag
            self.tabModel:SetTagByCid(self.cid, tag)
        else
            self.view.tabName.text = oldTag or lang.transstr("custom_tag_enter")
        end
    end)
end

return CustomTagBoardCtrl