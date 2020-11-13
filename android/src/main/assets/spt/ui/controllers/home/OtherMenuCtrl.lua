local OtherMenuCtrl = class()

function OtherMenuCtrl:ctor()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Home/OtherMenu.prefab", "camera", true, true)
end

return OtherMenuCtrl

