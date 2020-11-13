local QuestJumpNodeCtrl = class()
local QuestInfoModel = require("ui.models.quest.QuestInfoModel")

function QuestJumpNodeCtrl:ctor(id, parent, isSmall, isAllowChangeScene, eid, view)
    assert(id and parent)
    isAllowChangeScene = isAllowChangeScene or false
    local questInfoModel = QuestInfoModel.new()
    local prefab, spt
    if view then 
        spt = view
    else
        if isSmall then
            prefab, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ItemDetail/QuestJumpNodeSmall.prefab")
        else
            prefab, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ItemDetail/QuestJumpNode.prefab")
        end
        prefab.transform:SetParent(parent, false)
    end

    local isOpen = false
    if questInfoModel:CheckStageOpenedById(id) then
        isOpen = true
    end

    spt:Init(id, isAllowChangeScene, isOpen)
    spt:OnJumpBtnClick(function() self:Jump(id, eid) end)
    spt:OnJumpToCurrentQuest(function() self:JumpToCurrentQuest(id, eid) end)
end

function QuestJumpNodeCtrl:Jump(id, eid)
    cache.setRequiredEquipId(eid)
    res.PushScene("ui.controllers.quest.QuestPageCtrl", nil, id)
end

function QuestJumpNodeCtrl:JumpToCurrentQuest(id, eid)
    res.PushScene("ui.controllers.quest.QuestPageCtrl", nil)
end

return QuestJumpNodeCtrl
