local UnityEngine = clr.UnityEngine
local Quaternion = UnityEngine.Quaternion
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local GameObject = UnityEngine.GameObject
local Color = UnityEngine.Color
local WaitForSeconds = UnityEngine.WaitForSeconds
local Text = UnityEngine.UI.Text
local PlayerLevel = require("data.PlayerLevel")
local UnlockOptionCtrl = require("ui.controllers.common.UnlockOptionCtrl")
local UserLevelUpView = class(unity.base)

function UserLevelUpView:ctor()
    self.content = self.___ex.content
    self.shadow = self.___ex.shadow
    self.befSp = self.___ex.befSp
    self.aftSp = self.___ex.aftSp
    self.befCount = self.___ex.befCount
    self.aftCount = self.___ex.aftCount
    self.pointer = self.___ex.pointer
    self.tip = self.___ex.tip
    self.GOTab = {}
    self.weightTab = {}
    self.middlePos = Vector2(0, 72)
    self.middleScale = 1
    self.middleWeight = 0
    self.sideScale = 0.7
    self.deltax = 160
    self.deltay = 6
    self.deltaWeight = 0.6
    self.totalTime = 0
    self.animTime = 1.5
    self.textMoveEnd = nil
    self.levelData = nil
    self.allEnd = nil
    self.closeAfterMoveEnd = 1.5
    self.PointerRadius = 60
    self.pointerStart = 0
    self.deltaAngle = 30
    self.pointerDest = 0
    self.secPerRound = 0.1
    self.timeInRound = 0
    self.pointerIndex = 0
    self.shakeAnimTime = 0.2
    self.shakeWeight = 0.05
    self.shakeTime = 0
    self.shakeCount = 0
    self.shakeRat = 0.6
end

function UserLevelUpView:InitData(levelData)
    self:PlayStartAnim()
    self.levelData = levelData
    local befLvl, aftLvl, befSp, aftSp
    local lastRewardTable = levelData
    befLvl = lastRewardTable.befLvl
    aftLvl = lastRewardTable.aftLvl
    befSp = lastRewardTable.befSp
    aftSp = lastRewardTable.aftSp
    local allDeltaWeight = (aftLvl - befLvl) * self.deltaWeight 

    for i = befLvl - 1, aftLvl + 1 do
        local GO = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/UserLevelUp/TextInLevelUp.prefab")
        GO:GetComponent(Text).text = tostring(i)
        GO.transform:SetParent(self.content.transform, false)

        if i == 0 then
            GO:SetActive(false)
        end

        table.insert(self.GOTab, GO)
        table.insert(self.weightTab, self.middleWeight + (i - befLvl) * self.deltaWeight)
    end

    self.shadow:regOnButtonClick(function()
        self:MoveEnd()
    end)

    self:SetTip(aftLvl)

    self.befSp.text = tostring(befSp)
    self.aftSp.text = tostring(aftSp)
    self.befCount.text = tostring(PlayerLevel[tostring(befLvl)].cardNumber)
    self.aftCount.text = tostring(PlayerLevel[tostring(aftLvl)].cardNumber)

    self:coroutine(function()
        local firstFrame = true
        while not self.allEnd do
            if self.totalTime < self.animTime and not self.textMoveEnd then
                local newWeightTab = {}
                for i, v in ipairs(self.weightTab) do
                    table.insert(newWeightTab, v - allDeltaWeight / self.animTime * Time.unscaledDeltaTime)
                end

                self.weightTab = newWeightTab

                if self.totalTime + Time.unscaledDeltaTime > self.animTime then
                    self:MoveEnd()
                    self:movePointer()
                    coroutine.yield()
                end

                self:SetTextStatusByWeight()
                self:movePointer()
                self.totalTime = self.totalTime + Time.unscaledDeltaTime
                if firstFrame then
                    firstFrame = false
                    coroutine.yield(UnityEngine.WaitForSeconds(1))
                end
                coroutine.yield()
            else
                self:movePointer()
                coroutine.yield()
            end
        end
    end)
end

function UserLevelUpView:MoveEnd()
    for i, v in ipairs(self.GOTab) do
        self.weightTab[i] = (i - #self.GOTab + 1) * self.deltaWeight
    end

    self.textMoveEnd = true
    self:SetTextStatusByWeight()
    self:doShakeAnim()
    local maxAnimTime = self:GetMaxAnimTime()
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(self.closeAfterMoveEnd - maxAnimTime))
        self:PlayLeaveAnim()
        coroutine.yield(WaitForSeconds(maxAnimTime))
        self:Close()
    end)
end

function UserLevelUpView:GetMaxAnimTime()
    local maxTime = 0
    if type(self.leaveAnim) == "table" then
        for k, v in pairs(self.leaveAnim) do
            if v.length then
                maxTime = math.max(maxTime, v.length)
            end
        end
    end
    return maxTime
end

function UserLevelUpView:doShakeAnim()
    self:coroutine(function()
        while true do
            local newWeightTab = {}
            if self.shakeTime > self.shakeAnimTime then
                self.shakeCount = self.shakeCount + 1
                self.shakeTime = 0
            end
            for i, v in ipairs(self.weightTab) do
                local startWeight, destWeight
                if self.shakeCount > 0 then
                    startWeight = (i - #self.GOTab + 1) * self.deltaWeight - self.shakeWeight * math.pow(-self.shakeRat, self.shakeCount - 1)
                else
                    startWeight = (i - #self.GOTab + 1) * self.deltaWeight
                end

                destWeight = (i - #self.GOTab + 1) * self.deltaWeight - self.shakeWeight * math.pow(-self.shakeRat, self.shakeCount)
                table.insert(newWeightTab, math.lerp(startWeight, destWeight, self.shakeTime / self.shakeAnimTime))
            end
            self.weightTab = newWeightTab
            self:SetTextStatusByWeight()
            self.shakeTime = self.shakeTime + Time.unscaledDeltaTime
            coroutine.yield()
        end
    end)
end

function UserLevelUpView:onDestroy()
    UnlockOptionCtrl.new(self.levelData)
end

function UserLevelUpView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function UserLevelUpView:SetTextStatusByWeight()
    local PointerX = self:GetPointerX()
    local pointerIndex = -1
    for i, v in ipairs(self.weightTab) do
        local weight = v
        local GO = self.GOTab[i]
        local absWeight = math.abs(weight)

        GO.transform.anchoredPosition = Vector2(self.middlePos.x + weight * self.deltax / self.deltaWeight, self.middlePos.y - absWeight * self.deltay / self.deltaWeight)

        if pointerIndex < 0 and PointerX <= GO.transform.anchoredPosition.x - GO.transform.rect.width / 4 then
            pointerIndex = i - 1
        end

        if absWeight > 1 then
            GO:GetComponent(Text).color = Color(1, 1, 1, 0)
            GO:GetComponent(Text).color = Color(1, 1, 1, 0)
        else
            GO:GetComponent(Text).color = Color(1, 1, 1, 1 - absWeight)
            GO.transform.localScale = Vector3(self.middleScale * (1 - absWeight) + self.sideScale * absWeight, self.middleScale * (1 - absWeight) + self.sideScale * absWeight, 1)
        end
    end

    if self.pointerIndex and pointerIndex - self.pointerIndex > 0 then
        self.pointerStart = self.pointerDest
        if (self.pointerDest - self.pointer.localEulerAngles.z) % 360 > 180 then
            self.pointerDest = math.min(self.pointer.localEulerAngles.z + (pointerIndex - self.pointerIndex) * self.deltaAngle * math.cos(self.pointer.localEulerAngles.z / 180), 90)
        else
            self.pointerDest = math.min(self.pointerDest + (pointerIndex - self.pointerIndex) * self.deltaAngle * math.cos(self.pointer.localEulerAngles.z / 180), 90)
        end

        self.pointerIndex = pointerIndex
    end
end

function UserLevelUpView:movePointer()
    self.timeInRound = self.timeInRound + Time.unscaledDeltaTime
    if self.timeInRound > self.secPerRound then
        self.pointer.localRotation = Quaternion.Euler(Vector3(0, 0, self.pointerDest))
        self.timeInRound = 0
        self.pointerStart = self.pointerDest
        self.pointerDest = -self.pointerDest * self.shakeRat
    else
        self.pointer.localRotation = Quaternion.Euler(Vector3(0, 0, math.lerp(self.pointerStart, self.pointerDest, self.timeInRound / self.secPerRound)))
    end
end

function UserLevelUpView:SetTip(lvl)
    if PlayerLevel[tostring(lvl)] and PlayerLevel[tostring(lvl)].tip then
        self.tip.text = PlayerLevel[tostring(lvl)].tip
    else
        self.tip.GameObject:SetActive(false)
    end
end

function UserLevelUpView:GetPointerX()
    return -self.PointerRadius * math.sin(self.pointer.localEulerAngles.z / 180)
end

-- 报错临时屏蔽
function UserLevelUpView:PlayStartAnim()

end

function UserLevelUpView:PlayLeaveAnim()

end

return UserLevelUpView
