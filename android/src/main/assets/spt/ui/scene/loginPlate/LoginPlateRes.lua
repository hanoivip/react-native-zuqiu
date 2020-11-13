local LoginPlateRes = class()

-- 登录弹板与活动类似(每个弹板用type和id为key)
-- CtrlPath 为指定活动Ctrl 一般继承自PlateBaseCtrl, 不填则默认为PlateBaseCtrl
-- ModelPath 为指定活动Model 一般继承自PlateBaseModel, 不填则默认为PlateBaseModel
local LoginPlateResPath = 
{
    Sign = 
    {
        [1] = { CtrlPath = 'ui.controllers.loginPlate.SignPlateCtrl', 
                ModelPath = 'ui.models.activity.SignModel', 
                PrefabPath = 'Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CalendarBoard.prefab'}
    },
}

function LoginPlateRes:ctor()
end

function LoginPlateRes:GetPlatePrefabPath(plateType, plateId)
    return LoginPlateResPath[plateType] and LoginPlateResPath[plateType][plateId].PrefabPath
end

function LoginPlateRes:GetPlateControllerPath(plateType, plateId)
    return LoginPlateResPath[plateType] and LoginPlateResPath[plateType][plateId].CtrlPath
end

function LoginPlateRes:GetPlateModelPath(plateType, plateId)
    return LoginPlateResPath[plateType] and LoginPlateResPath[plateType][plateId].ModelPath
end

return LoginPlateRes
