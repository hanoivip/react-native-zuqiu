local FreezePopupsCtrl = class()

function FreezePopupsCtrl:ctor()
    self.matchTipsObj = nil
    self.matchTips = nil
    self:Init()
end

function FreezePopupsCtrl:Init()
    self:LoadMatchTips()
end

--- 加载提示弹窗
function FreezePopupsCtrl:LoadMatchTips()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/Template/Loading/WaitForPost.prefab", "overlay", false, false)
    self.matchTipsObj = dialog
    self.matchTips = dialogcomp.contentcomp
    self.matchTipsObj:SetActive(false)
end

--- 显示提示弹窗
function FreezePopupsCtrl:ShowPop()
    self.matchTipsObj:SetActive(true)
end

--- 隐藏提示窗口
function FreezePopupsCtrl:HidePop()
    if self.matchTipsObj ~= nil and self.matchTipsObj ~= clr.null then
        self.matchTipsObj:SetActive(false)
    end
end

--- 销毁弹窗
function FreezePopupsCtrl:DestroyPop()
    self.matchTips:Destroy()
end

return FreezePopupsCtrl
