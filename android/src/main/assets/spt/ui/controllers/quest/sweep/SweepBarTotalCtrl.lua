local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local SweepBarTotalCtrl = class()

function SweepBarTotalCtrl:ctor(sweepTotalData, sweepBarTotalRes, parent, showTime)
    self:Init(sweepTotalData, sweepBarTotalRes, parent, showTime)
end

function SweepBarTotalCtrl:Init(sweepTotalData, sweepBarTotalRes, parent, showTime)
    local sweepTotalBar = Object.Instantiate(sweepBarTotalRes)
    sweepTotalBar.transform:SetParent(parent.transform, false)
    sweepTotalBar:GetComponent(clr.CapsUnityLuaBehav):InitView(sweepTotalData, showTime)
end

return SweepBarTotalCtrl
