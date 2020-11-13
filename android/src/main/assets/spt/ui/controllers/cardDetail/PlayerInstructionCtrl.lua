local PlayerInstructionCtrl = class()

function PlayerInstructionCtrl:ctor(cardModel)
    local viewObject, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/PlayerInstruction.prefab", "camera", true, true)
    self.view = dialogcomp.contentcomp
    self.view:InitView(cardModel)
end

return PlayerInstructionCtrl
