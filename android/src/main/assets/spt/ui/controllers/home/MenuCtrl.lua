local MenuCtrl = class()

function MenuCtrl:ctor()
    clr.coroutine(function()
        -- 打开界面
        local dlg = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Home/Menu.prefab", "camera", true, true)
    end)
end

return MenuCtrl