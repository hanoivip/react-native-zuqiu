local UnityEngine = clr.UnityEngine
local ForceMode2D = UnityEngine.ForceMode2D
local WaitForSeconds = UnityEngine.WaitForSeconds
local RenderTexture = UnityEngine.RenderTexture
local ToArray = clr.array
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Animator = UnityEngine.Animator
local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local Ease = Tweening.Ease
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local GameObjectHelper = require("ui.common.GameObjectHelper")
local random = math.random
local abs = math.abs
local floor = math.floor

local MarblesBallManager = class()

function MarblesBallManager:ctor()
    self.resetTrans = self.___ex.resetTrans
    self.shootPath = self.___ex.shootPath
    self.behav = self.___ex.behav
    self.lineRightTrans = self.___ex.lineRightTrans
    self.lineLeftTrans = self.___ex.lineLeftTrans
    self.lineTopTrans = self.___ex.lineTopTrans
    self.startPlat = self.___ex.startPlat
    self.absolute = self.___ex.absolute
    self.ballParentTrans = self.___ex.ballParentTrans
    self.cam = self.___ex.cam
    self.ballResetPos = {Vector3(4.1, 0.8, 0),Vector3(4.1, 1.8, 0),
                         Vector3(4.1, 2.8, 0),Vector3(4.1, 4.8, 0),
                         Vector3(4.1, 7.8, 0),Vector3(4.1, 11.8, 0),
                         Vector3(4.1, 16.8, 0),Vector3(4.1, 22.8, 0),
                         Vector3(4.1, 29.8, 0),Vector3(4.1, 40.8, 0),}
end

function MarblesBallManager:Init()
    self.ballsRig = {}
    self.ballsTrans = {}
    self.shootPathV3 = {}
    local pathChildCount = self.shootPath.childCount
    for i = 1, pathChildCount do
        local tTrans = self.shootPath:GetChild(i-1)
        local pV3 = tTrans.position
        table.insert(self.shootPathV3, pV3)
    end
    local childCount = self.ballParentTrans.transform.childCount
    for i = 1, childCount do
        local tTrans = self.ballParentTrans.transform:GetChild(i-1)
        GameObjectHelper.FastSetActive(tTrans.gameObject, false)
    end
    self:ResetBall()
    self.leftPosX = self.lineLeftTrans.position.x;
    self.rightPosX = self.lineRightTrans.position.x;
    self.deltaPos = abs(self.rightPosX - self.leftPosX) / 7
    self.linePosYDown = self.lineLeftTrans.position.y;
    self.linePosYUp = self.lineTopTrans.position.y + 0.15;
    local rt = self:GetRT()
    self.cam.targetTexture = rt;
end

function MarblesBallManager:GetRT()
    if not self.camRT then
        self.camRT = RenderTexture(665, 457, 0);
    end
    return self.camRT
end

function MarblesBallManager:AddBall(ballCount, addBallComplete)
    self:ResetBall()
    self.ballsRig = {}
    self.ballsTrans = {}
    local childCount = self.ballParentTrans.transform.childCount
    for i = 1, childCount do
        local tTrans = self.ballParentTrans.transform:GetChild(i-1)
        if i <= ballCount then
            local tRig = tTrans:GetComponent("Rigidbody2D")
            table.insert(self.ballsRig, tRig)
            table.insert(self.ballsTrans, tTrans.transform)
        end
        GameObjectHelper.FastSetActive(tTrans.gameObject, i <= ballCount)
    end
    local waitTime = 2 + ballCount * 0.2
    clr.bcoroutine(self.behav, function()
        coroutine.yield(WaitForSeconds(waitTime))
        if addBallComplete and type(addBallComplete) then
            addBallComplete()
        end
    end)
end

function MarblesBallManager:StartClick(forceRate, maxCount, completeCallBack)
    self.timeOut = false
    self.sendCallBack = false
    clr.coroutine(function()
        ShortcutExtensions.DOScaleY(self.startPlat, 0.5, 0.5)
        coroutine.yield(WaitForSeconds(0.6))
        local tweenerY = ShortcutExtensions.DOScaleY(self.startPlat, 1, 0.3)
        TweenSettingsExtensions.SetEase(tweenerY, Ease.InBack)

        coroutine.yield(WaitForSeconds(0.2))

        local shootPathTime = 1 / forceRate
        shootPathTime = math.clamp(shootPathTime, 1, 5)
        shootPathTime = shootPathTime * 0.05
        local index = 1
        forceRate = math.clamp(forceRate, 0.1, forceRate)
        for i, v in pairs(self.ballsRig) do
            local tweener = ShortcutExtensions.DOPath(v.transform, ToArray(self.shootPathV3, Vector3), index * 0.05 + shootPathTime)
            TweenSettingsExtensions.OnComplete(tweener, function ()
                local x = random(-30, -15) * forceRate
                local y = random(-5, 5) * forceRate
                local force = Vector2(x, y)
                v:AddForce(force, ForceMode2D.Impulse)
            end)
            index = index + 1
        end

        local count = 0
        local posTable = {}
        while count < maxCount and (not self.timeOut) do
            count = 0
            posTable = {}
            for i, v in pairs(self.ballsTrans) do
                local ballPos = v.position
                local bx = ballPos.x
                local by = ballPos.y
                if by < self.linePosYUp and bx > self.leftPosX and bx < self.rightPosX then
                    local indexCell = abs(bx - self.rightPosX) / self.deltaPos
                    indexCell = floor(indexCell) + 1
                    if not posTable[indexCell] then
                        posTable[indexCell] = {}
                    end
                    posTable[indexCell][v.name] = true
                    count = count + 1
                end
            end
            coroutine.yield(WaitForSeconds(0.1))
        end
        if type(completeCallBack) == "function" and not self.timeOut then
            posTable = {}
            for i, v in pairs(self.ballsTrans) do
                local ballPos = v.position
                local bx = ballPos.x
                if bx > self.leftPosX and bx < self.rightPosX then
                    local indexCell = abs(bx - self.rightPosX) / self.deltaPos
                    indexCell = floor(indexCell) + 1
                    if not posTable[indexCell] then
                        posTable[indexCell] = {}
                    end
                    posTable[indexCell][v.name] = true
                end
            end
            completeCallBack(posTable)
            self.sendCallBack = true
        end
    end)
    if self.overTimeCoroutine then
        self.behav:StopCoroutine(self.overTimeCoroutine)
    end
    self:ShootOverTimeCheck(completeCallBack)
end

function MarblesBallManager:ShootOverTimeCheck(completeCallBack)
    self.overTimeCoroutine = clr.bcoroutine(self.behav, function()
        coroutine.yield(WaitForSeconds(9))
        if not self.sendCallBack then
            self.timeOut = true
            local posTable = {}
            if type(completeCallBack) == "function" then
                for i, v in pairs(self.ballsTrans) do
                    local ballPos = v.position
                    local bx = ballPos.x
                    if bx > self.leftPosX and bx < self.rightPosX then
                        local indexCell = abs(bx - self.rightPosX) / self.deltaPos
                        indexCell = floor(indexCell) + 1
                        if not posTable[indexCell] then
                            posTable[indexCell] = {}
                        end
                        posTable[indexCell][v.name] = true
                    end
                end
                completeCallBack(posTable)
            end
        end
    end)
end

function MarblesBallManager:RandomAbsolute(hideMapPosInfo)
    if next(hideMapPosInfo) then
        local childCount = self.absolute.childCount
        for i = 1, childCount do
            local tChild = self.absolute:GetChild(i-1)
            local tCount = tChild.childCount
            local hideIndex = hideMapPosInfo[i][1]
            for tIndex = 1, tCount do
                local index = tIndex - 1
                local cObj = tChild:GetChild(index).gameObject
                GameObjectHelper.FastSetActive(cObj, index ~= hideIndex)
            end
        end
    end
end

function MarblesBallManager:PlayAbsoluteAnim()
    local childCount = self.absolute.childCount
    for i = 1, childCount do
        local tChild = self.absolute:GetChild(i-1)
        local tCount = tChild.childCount
        for tIndex = 1, tCount do
            local index = tIndex - 1
            local cObj = tChild:GetChild(index).gameObject
            local anim = cObj:GetComponent(Animator)
            anim:Play("Absolute")
        end
    end
end

function MarblesBallManager:ResetBall()
    for i, v in pairs(self.ballsRig) do
        v.transform.position = self.ballResetPos[i]
        GameObjectHelper.FastSetActive(v.transform.gameObject, false)
    end
end

return MarblesBallManager
