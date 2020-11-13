local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local SweepBarCtrl = class()

function SweepBarCtrl:ctor(index, sweepData, sweepBarRes, parent, showTime)
    self:Init(index, sweepData, sweepBarRes, parent, showTime)
end

function SweepBarCtrl:Init(index, sweepData, sweepBarRes, parent, showTime)
    local sweepBar = Object.Instantiate(sweepBarRes)
    sweepBar.transform:SetParent(parent.transform, false)
    sweepBar:GetComponent(clr.CapsUnityLuaBehav):InitView(index, sweepData, showTime)
end

return SweepBarCtrl
