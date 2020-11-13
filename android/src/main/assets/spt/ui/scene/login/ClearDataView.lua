local DialogManager = require("ui.control.manager.DialogManager")
local ClearDataView = class(unity.base)

function ClearDataView:ctor()
    local clearCallback = function() 
        luaevt.trig("SDK_Report", "clear_cacheData")
        clr.Capstones.UnityFramework.ResManager.ResetCacheVersion()
        unity.restart()
    end

    self.___ex.btnClear:regOnButtonClick(function()
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("clear_cacheData"), clearCallback)
    end)
end

return ClearDataView