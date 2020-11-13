local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Canvas = UnityEngine.Canvas
local RenderMode = UnityEngine.RenderMode

local OverlayDialog = class(unity.base)

function OverlayDialog.applyOrder()
    return res.ApplyDialogOrder()
end

function OverlayDialog.getCurrentOrder()
    return res.GetCurrentDialogOrder()
end

function OverlayDialog.restoreOrder(order)
    return res.RestoreDialogOrder(order)
end

function OverlayDialog:ctor()
    self.isDummyDialog = cache.getGlobalTempData("isDummyDialog")
    if self.isDummyDialog then
        self.currentOrder = currentOrder
    else
        self.currentOrder = cache.getGlobalTempData("overlaySortingOrder") or OverlayDialog.applyOrder()
    end

    local canvas = self:GetComponent(Canvas)
    canvas.renderMode = RenderMode.ScreenSpaceOverlay
    canvas.sortingOrder = self.currentOrder

    self:coroutine(function()
        canvas.sortingOrder = self.currentOrder
    end)

    self.closeDialog = function()
        if self ~= clr.null and self.gameObject ~= clr.null then
            self.gameObject:SetActive(false)
            Object.Destroy(self.gameObject)
        end
    end
end

function OverlayDialog:setShadow(withShadow)
    withShadow = tobool(withShadow)
    self.withShadow = withShadow
end

function OverlayDialog:disableShadow()
    self.___ex.ImgShadow.enabled = false
end

function OverlayDialog:enableShadow()
    self.___ex.ImgShadow.enabled = true
end

function OverlayDialog:onDestroy()
    if not self.isDummyDialog then
        OverlayDialog.restoreOrder(self.currentOrder)
    end
end

function OverlayDialog:regOnButtonClick(func)
    if type(func) == 'function' then
        self.onButtonClickCallBack = func
    end
end

function OverlayDialog:onPointerClick()
    if type(self.onButtonClickCallBack) == 'function' then
        self.onButtonClickCallBack()
    end
end

return OverlayDialog
