local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Canvas = UnityEngine.Canvas
local RenderMode = UnityEngine.RenderMode
local Camera = UnityEngine.Camera

local CameraDialog = class(unity.base)

function CameraDialog:ctor()
    local canvas = self:GetComponent(Canvas)
    canvas.renderMode = RenderMode.ScreenSpaceCamera
    canvas.worldCamera = Camera.main
    canvas.sortingLayerName = "Dialog"
    self:setOrder()

    self.closeDialog = function()
        if self.withShadow then
            local scd, uds = res.GetLastSCDAndUDs(true)
            if scd then
                res.ChangeCameraDialogToDialog(scd)
                for i, v in ipairs(uds) do
                    res.ChangeCameraDialogToDialog(v)
                end
            else
                if res.NeedDialogCameraBlur() then
                    res.SetMainCameraBlurOver()
                end
            end
        end

        if type(res.curSceneInfo) == "table" and type(res.curSceneInfo.dialogs) == "table" then
            for i, v in ipairs(res.curSceneInfo.dialogs) do
                if v.view == self.content:GetComponent(clr.CapsUnityLuaBehav) then
                    table.remove(res.curSceneInfo.dialogs, i)
                    break;
                end
            end
        end

        if type(self.OnExitScene) == "function" then
            self.OnExitScene()
        end

        if self ~= clr.null and self.gameObject ~= clr.null then
            self.gameObject:SetActive(false)
            Object.Destroy(self.gameObject)
        end
    end
end

function CameraDialog:setShadow(withShadow)
    withShadow = tobool(withShadow)
    self.withShadow = withShadow
end

function CameraDialog:disableShadow()
    self.___ex.ImgShadow.enabled = false
end

function CameraDialog:enableShadow()
    self.___ex.ImgShadow.enabled = true
end

function CameraDialog:setOrder(order)
    if type(order) == "number" then
        res.SetDialogOrder(order)
        self.currentOrder = order
    else
        self.currentOrder = res.ApplyDialogOrder()
    end
    self:GetComponent(Canvas).sortingOrder = self.currentOrder
end

function CameraDialog:switchToOverlay()
    local canvas = self:GetComponent(Canvas)
    canvas.renderMode = RenderMode.ScreenSpaceOverlay
end

function CameraDialog:switchToCamera()
    local canvas = self:GetComponent(Canvas)
    canvas.renderMode = RenderMode.ScreenSpaceCamera
end

function CameraDialog:onDestroy()
    res.RestoreDialogOrder(self.currentOrder)
end

function CameraDialog:regOnButtonClick(func)
    if type(func) == 'function' then
        self.onButtonClickCallBack = func
    end
end

function CameraDialog:onPointerClick()
    if type(self.onButtonClickCallBack) == 'function' then
        self.onButtonClickCallBack()
    end
end

return CameraDialog
