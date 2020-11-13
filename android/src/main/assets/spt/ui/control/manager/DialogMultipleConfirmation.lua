local ResManager = clr.Capstones.UnityFramework.ResManager
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = {}

-- key 根据不同版本开启是否需要二次确认界面
local multipleControl = {["lang_kr"] = true}
local multipleFlag = nil
function DialogMultipleConfirmation.HasMultipleConfirmation()
	if not multipleFlag then 
		local flags = ResManager.GetDistributeFlags()
		flags = clr.table(flags) or {}
		for i, flag in ipairs(flags) do
			if multipleControl[tostring(flag)] then 
				multipleFlag = flag
				return multipleControl[multipleFlag]
			end
		end
		multipleFlag = ""
	end
	return multipleControl[tostring(multipleFlag)]
end

function DialogMultipleConfirmation.MultipleConfirmation(title, msg, confirmCallback, cancelCallback, cameraType, dialogType)
    local resManager = clr.Capstones.UnityFramework.ResManager
	local hasMultipleConfirmation = DialogMultipleConfirmation.HasMultipleConfirmation()
    if hasMultipleConfirmation then 
        DialogManager.ShowConfirmPop(title, msg, confirmCallback, cancelCallback, cameraType, dialogType)
    elseif type(confirmCallback) == "function" then
        confirmCallback()
    end
end

return DialogMultipleConfirmation
