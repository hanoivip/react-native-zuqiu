local BaseCtrl = class()

BaseCtrl.viewPath = nil

BaseCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

BaseCtrl.withoutPop = false

function BaseCtrl:GetLoadType()
    return self.__loadType
end

function BaseCtrl:ctor(...)
end

-- 在Instantiate界面之前的网络请求
-- @param func 请求返回之后执行的函数
function BaseCtrl:_AheadRequest(func, ...)
    local args = {...}
    local argc = select("#", ...)
    
    clr.coroutine(function()
        if self.AheadRequest then
            self:AheadRequest(unpack(args, 1, argc))
        end
        while not self.view do
            coroutine.yield()
        end
        if func then
            func()
        end
    end)
end

function BaseCtrl:Init(...)
end

function BaseCtrl:Refresh(...)
    if self.withoutPop == true then
        res.ClearCtrlStack()
    end
    if type(self.OnEnterScene) == "function" then
        self:OnEnterScene()
    end
end

function BaseCtrl:GetStatusData()
end

return BaseCtrl
