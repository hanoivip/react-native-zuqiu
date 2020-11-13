local androiddelay = {}

local specialOnBack = "forbid"
local specialOnBackFunc = nil

clr.coroutine(function()
    while true do
        luaevt.delayed()

        if clr.UnityEngine.Input.GetKeyDown(clr.UnityEngine.KeyCode.Escape) then
            if cache.getPlayerInfo() and require("ui.controllers.playerGuide.GuideManager").HasGuideOnGoing() then
                if specialOnBack == "guide_common" then
                    if res.CommonOnBackDialog() then
                    else
                        res.CommonOnBack()
                    end
                else
                    local dlg = require("ui.control.manager.DialogManager").ShowToastByLang("cannot_back_in_guide")
                    local canvas = dlg:GetComponent(Canvas)
                    canvas.sortingOrder = 20010
                end
            else
                if specialOnBack == "forbid" then
                    local dlg = require("ui.control.manager.DialogManager").ShowToastByLang("cannot_back_in_game")
                    local canvas = dlg:GetComponent(Canvas)
                    canvas.sortingOrder = 20010
                else
                    if res.CommonOnBackDialog() then
                    else
                        if specialOnBack == "exit" then
                            if luaevt.trig("SDK_HaveExit") then
                            else
                                local content = {}
                                content.title = lang.trans("title_exit_confirm")--"退出确认"
                                content.content = lang.trans("exit_confirm") --"您确定要退出游戏?"
                                content.button1Text = lang.trans("cancel")
                                content.button2Text = lang.trans("confirm")
                                content.onButton2Clicked = function()
                                    clr.UnityEngine.Application.Quit()
                                end
                                content.hideCloseIcon = true
                                local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', 'overlay', false, true, nil, nil, 10000)
                                dialogcomp.contentcomp:initData(content)
                            end
                        elseif specialOnBack == "match" then
                            if specialOnBackFunc then
                                specialOnBackFunc()
                            end
                        else
                            res.CommonOnBack()
                        end
                    end
                end
            end
        end

        coroutine.yield()
    end
end)

luaevt.reg("SetOnBackType", function(cate, type, func)
    local old_specialOnBack = specialOnBack
    local old_specialOnBackFunc = specialOnBackFunc
    specialOnBack = type
    specialOnBackFunc = func
    return old_specialOnBack, old_specialOnBackFunc
end)

return androiddelay
