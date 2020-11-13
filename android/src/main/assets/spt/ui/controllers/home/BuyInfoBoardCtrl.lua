local BuyInfoBoardCtrl = class()

function BuyInfoBoardCtrl:ctor()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Home/BuyInfoBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:Init(100, 100)
end

return BuyInfoBoardCtrl
