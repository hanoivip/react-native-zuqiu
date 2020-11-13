local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local RectTransform = UnityEngine.RectTransform
local Color = UnityEngine.Color
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Time = UnityEngine.Time

local MatchConstants = require("ui.scene.match.MatchConstants")

local MatchShootProgressBar = class(unity.base)

function MatchShootProgressBar:ctor()
    -- 进度条中的单元数量
    self.itemCount = self.___ex.itemCount
    -- 物体列表
    self.itemObjList = nil
    -- 是否自动更新
    self.autoUpdate = false
    -- 是否已构建进度条
    self.hasBuildProgressBar = false
    -- 自动更新的启动时间
    self.autoUpdateStartTime = nil
    -- 进度结束后的回调
    self.progressEndCallback = nil
end

function MatchShootProgressBar:start()
    self:BuildProgressBar()
end

--- 构建进度条
function MatchShootProgressBar:BuildProgressBar()
    local itemAsset = res.LoadRes("Assets/CapstonesRes/Game/Models/TouchShoot/ProgressAtom.prefab")
    self.itemObjList = {}

    for i = 1, self.itemCount do
        local itemObj = Object.Instantiate(itemAsset)
        local rectTrans = itemObj:GetComponent(RectTransform)
        rectTrans:SetParent(self.transform, false)
        rectTrans.anchorMin = Vector2((i - 1) / self.itemCount, 0)
        rectTrans.anchorMax = Vector2(i / self.itemCount, 1)
        table.insert(self.itemObjList, itemObj)
    end

    self.hasBuildProgressBar = true
end

function MatchShootProgressBar:OnTouchShootActivated(callback)
    self.autoUpdate = true
    self.autoUpdateStartTime = TimeWrap.GetUnscaledTime()
    self.progressEndCallback = callback
end

function MatchShootProgressBar:OnTouchShootDeactivated()
    self.autoUpdate = false
end

function MatchShootProgressBar:Update()
    if self.autoUpdate and self.hasBuildProgressBar then
        local progress = 1 - (TimeWrap.GetUnscaledTime() - self.autoUpdateStartTime) / MatchConstants.ShootProgressTime

        for i = 1, self.itemCount do
            local itemObj = self.itemObjList[i]
            if (i - 1) / self.itemCount < progress then
                itemObj:SetActive(true)
            else
                itemObj:SetActive(false)
            end
        end

        if progress <= 0 then
            self.autoUpdate = false
            if self.progressEndCallback ~= nil then
                self.progressEndCallback()
            end
        end
    end
end

function MatchShootProgressBar:onDestroy()
    self.itemObjList = nil
end

return MatchShootProgressBar
