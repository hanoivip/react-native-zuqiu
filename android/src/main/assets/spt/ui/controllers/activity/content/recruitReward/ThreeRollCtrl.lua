local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease

local GameObjectHelper = require("ui.common.GameObjectHelper")
local RectTransformUtility = UnityEngine.RectTransformUtility

local ThreeRollCtrl = class(unity.base)

--卡牌真正滑动方向
local switchDirection = {LEFT = "Left", RIGHT = "Right"}
local DefaultMiddleIndex = 2
local animRate = 0.6 --滚动速度

function ThreeRollCtrl:ctor()
end

function ThreeRollCtrl:InitVariables(itemDataList, middleIndex, rollRect, variablesTable)
    self.parentCtrl = variablesTable.parentCtrl
    self.scaleOriginal = variablesTable.scaleOriginal or 1
    self.scaleFactor = variablesTable.scaleFactor or 1.5
    self.originalVector = Vector3Lua(self.scaleOriginal, self.scaleOriginal, 1)
    self.scaleVector = Vector3Lua(self.scaleFactor, self.scaleFactor, 1)
    self.positionList = variablesTable.positionList
    self.offsetRatio = variablesTable.offsetRatio
    self.btnLeftSwitch = variablesTable.btnLeftSwitch or {}
    self.btnRightSwitch = variablesTable.btnRightSwitch or {}
    self.isLoop = variablesTable.isLoop --是否循环旋转,默认是
    if self.isLoop == nil then self.isLoop = true end
    self.isElastic = variablesTable.isElastic --是否弹性，默认是
    if self.isElastic == nil then self.isElastic = true end
    self.viewContentSizeX = self:CalculateViewContentSizeX() --显示界面的宽度
    if self.isElastic then self.isLoop = false end --如果有弹性，必为非循环

    self.dataList = itemDataList
    self.listCount = #self.dataList
    assert(self.listCount >= 3, "at least 3 prefabs needed!")
    self.middleIndex = middleIndex
    self.rollRect = rollRect

    self.threeObjs = {}
    self.prefabDistance = self.positionList.right.x
    self.potentialDistance = self.positionList.rHidden.x - self.positionList.right.x
    self.isAnimPlaying = false
    self.isDrag = false
    self.switchDirection = nil

    --动画完成时，用户是否处于拖拽状态,用以实现拖拽与动画的隔离判断
    self.isPlayerDragging = false
    --紧接上面，如果是，则模拟onBeginDrag，进入拖拽状态
    self.isBeginDrag = false
    --是否处于弹性拉伸的状态(overStretching不为零)
    self.isElasticUsing = false
    self.overStretchingOffset = 0
    --是否循环旋转依赖的变量
    self.minMiddleIndex = nil
    self.maxMiddleIndex = nil
    self.canLeftSwitch = true
    self.canRightSwitch = true
    if not self.isLoop then
        self:PrepareVariablesForBoundary()
    end

    self:BindClickSwitchFunc()
    self:InitEntryScene(middleIndex)
end

function ThreeRollCtrl:PrepareVariablesForBoundary()
    self.minMiddleIndex = DefaultMiddleIndex
    self.maxMiddleIndex = self.listCount - 1
end

function ThreeRollCtrl:SetSwitchBtnActive(middleIndex)
    GameObjectHelper.FastSetActive(self.btnLeftSwitch.gameObject, middleIndex > self.minMiddleIndex)

    GameObjectHelper.FastSetActive(self.btnRightSwitch.gameObject, middleIndex < self.maxMiddleIndex)
end

function ThreeRollCtrl:CheckSwitchBtnState(middleIndex)
    if not self.isLoop then
        self:SetSwitchBtnActive(middleIndex)
    end
end

function ThreeRollCtrl:InitRollFlagsIfUnlooped(middleIndex)
    if not self.isLoop then
        self.canRightSwitch = middleIndex > self.minMiddleIndex
        if self.canRightSwitch then
            self.maxRightRollLength = (middleIndex - 2) * self.prefabDistance
        else
            self.maxRightRollLength = 0
        end

        self.canLeftSwitch = middleIndex < self.maxMiddleIndex
        if self.canLeftSwitch then
            self.maxLeftRollLength = (self.listCount - middleIndex - 1) * self.prefabDistance
        else
            self.maxLeftRollLength = 0
        end
    end
end

function ThreeRollCtrl:BindClickSwitchFunc()
        --左翻
    self.btnRightSwitch:regOnButtonClick(function ()
        if self.isAnimPlaying or self.isDrag then return end
        self:PlayLeftSwitch()
    end)

    -- 右翻
    self.btnLeftSwitch:regOnButtonClick(function ()
        if self.isAnimPlaying or self.isDrag then return end
        self:PlayRightSwitch()
    end)
end

function ThreeRollCtrl:InitEntryScene()
    self.rollRect.pivot = Vector2(0.5, 0.5)

    if not self.middleIndex then self.middleIndex = DefaultMiddleIndex end
    self.middleIndex = self:VerifyIndex(self.middleIndex)

    local obj = nil    
    local realIndex = nil
    realIndex = self:VerifyIndex(self.middleIndex - 1)
    obj = self.parentCtrl:CreateOnePrefab(self.originalVector, self.dataList[realIndex])
    self.threeObjs[1] = obj
    obj.transform.localPosition = self:ConvertVector3(self.positionList.left)

    realIndex = self:VerifyIndex(self.middleIndex)
    obj = self.parentCtrl:CreateOnePrefab(self.scaleVector, self.dataList[realIndex])
    self.threeObjs[2] = obj
    obj.transform.localPosition = self:ConvertVector3(self.positionList.middle)

    realIndex = self:VerifyIndex(self.middleIndex + 1)
    obj = self.parentCtrl:CreateOnePrefab(self.originalVector, self.dataList[realIndex])
    self.threeObjs[3] = obj
    obj.transform.localPosition = self:ConvertVector3(self.positionList.right)

    local leftPotentialIndex = self:VerifyIndex(self.middleIndex - 2)
    self.leftPotentialNext = self.parentCtrl:CreateOnePrefab(self.originalVector, self.dataList[leftPotentialIndex])
    self.leftPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.lHidden)

    local rightPotentialIndex = self:VerifyIndex(self.middleIndex + 2)
    self.rightPotentialNext = self.parentCtrl:CreateOnePrefab(self.originalVector, self.dataList[rightPotentialIndex])
    self.rightPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.rHidden)

    self:CheckSwitchBtnState(self.middleIndex)
end

function ThreeRollCtrl:PlayRightSwitch()
    self.isAnimPlaying = true

    self:PlayNodeAnim(self.leftPotentialNext, self.positionList.left, self.originalVector)
    self:PlayNodeAnim(self.threeObjs[3], self.positionList.rHidden, self.originalVector)
    self:PlayNodeAnim(self.threeObjs[1], self.positionList.middle, self.scaleVector)
    self:PlayNodeAnim(self.threeObjs[2], self.positionList.right, self.originalVector)

    self:ResetNeedVariables(switchDirection.RIGHT)

    self:CheckSwitchBtnState(self.middleIndex)
end

function ThreeRollCtrl:PlayLeftSwitch()
    self.isAnimPlaying = true

    self:PlayNodeAnim(self.threeObjs[1], self.positionList.lHidden, self.originalVector)
    self:PlayNodeAnim(self.threeObjs[2], self.positionList.left, self.originalVector)
    self:PlayNodeAnim(self.threeObjs[3], self.positionList.middle, self.scaleVector)
    self:PlayNodeAnim(self.rightPotentialNext, self.positionList.right, self.originalVector)

    self:ResetNeedVariables(switchDirection.LEFT)

    self:CheckSwitchBtnState(self.middleIndex)
end

function ThreeRollCtrl:ResetNeedVariables(direction)
    local tempObj = nil
    if direction == switchDirection.LEFT then
        tempObj = self.leftPotentialNext

        self.leftPotentialNext = self.threeObjs[1]
        self.threeObjs[1] = self.threeObjs[2]
        self.threeObjs[2] = self.threeObjs[3]
        self.threeObjs[3] = self.rightPotentialNext
        
        self.rightPotentialNext = tempObj

        self.middleIndex = self:VerifyIndex(self.middleIndex + 1)

        self:ResetPotentialNextObj(direction)      
    else
        tempObj = self.rightPotentialNext

        self.rightPotentialNext = self.threeObjs[3]
        self.threeObjs[3] = self.threeObjs[2]
        self.threeObjs[2] = self.threeObjs[1]
        self.threeObjs[1] = self.leftPotentialNext

        self.leftPotentialNext = tempObj

        self.middleIndex = self:VerifyIndex(self.middleIndex - 1)
        
        self:ResetPotentialNextObj(direction)
    end
end

function ThreeRollCtrl:ResetPotentialNextObj(direction)
    if direction == switchDirection.LEFT then
        local rightNextIndex = self:VerifyIndex(self.middleIndex + 2)
        self.parentCtrl:ResetOnePrefab(self.rightPotentialNext, self.dataList[rightNextIndex])
        self.rightPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.rHidden)
    else
        local leftNextIndex = self:VerifyIndex(self.middleIndex - 2) 
        self.parentCtrl:ResetOnePrefab(self.leftPotentialNext, self.dataList[leftNextIndex])
        self.leftPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.lHidden)
    end
end

--- 播放节点动画
function ThreeRollCtrl:PlayNodeAnim(node, destination, scaleValueVector, duration)
    if not duration then duration = animRate end 
    node = node.transform
    local moveTweener = ShortcutExtensions.DOAnchorPos3D(node, self:ConvertVector3(destination), duration)
    if not self.isElasticUsing then
        local scaleTweener = ShortcutExtensions.DOScale(node, self:ConvertVector3(scaleValueVector), duration)
    end

    TweenSettingsExtensions.OnComplete(moveTweener, function ()
            self.isAnimPlaying = false

            if self.isPlayerDragging then
                self.isBeginDrag = true
            end
    end)
end

function ThreeRollCtrl:start()
end

function ThreeRollCtrl:onBeginDrag(eventData)
    self.isElasticUsing = false

    if not self.isAnimPlaying then

        self:InitRollFlagsIfUnlooped(self.middleIndex)

        local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
        self.fromPoint = Vector3Lua(pt.x, 0, 0)
        --每次新开始拖拽时的 middleIndex
        self.beginMiddleIndex = self.middleIndex
    end
end

function ThreeRollCtrl:onDrag(eventData)
    self.isPlayerDragging = true
    --动画还没结束，用户已经进行拖拽的话，用self.isBeginDrag标记，应不进行操作
    if self.isBeginDrag then
        self:onBeginDrag(eventData)
        self.isBeginDrag = false
        return
    end

    if not self.isAnimPlaying then
        local success, pt = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.transform, eventData.position, eventData.pressEventCamera, Vector2.zero)
    
        self.isDrag = true
        self:DoRollMovement(pt)
        self:SetSwitchBtnActive(self.middleIndex)
    end
end

function ThreeRollCtrl:onEndDrag(eventData)
    if not self.isAnimPlaying then
        self.isDrag = false

        if self.isElasticUsing then
            self:DoReturnToExtremePosition()
            self.isElasticUsing = false
            self:DoIfAtExtremeEnd(self.switchDirection)
            return
        end

        --顺势前进“一格”
        if self["can" .. self.switchDirection .. "Switch"] then
            if self.switchDirection == switchDirection.RIGHT then
                self:PlayRightSwitch()
            else
                self:PlayLeftSwitch()
            end
        end
    end

    self.isPlayerDragging =false
end
    
function ThreeRollCtrl:DoReturnToExtremePosition()
    self.isAnimPlaying = true

    self:PlayNodeAnim(self.threeObjs[1], self.positionList.left)
    self:PlayNodeAnim(self.threeObjs[2], self.positionList.middle)
    self:PlayNodeAnim(self.threeObjs[3], self.positionList.right)
end

function ThreeRollCtrl:DoIfAtExtremeEnd(direction)
    local middleIndex = self.minMiddleIndex
    if direction == switchDirection.LEFT then
        middleIndex = self.maxMiddleIndex
    end
    self:InitRollFlagsIfUnlooped(middleIndex)
end

--主干判断
function ThreeRollCtrl:DoRollMovement(pt)
    local mouseOffset = pt.x - self.fromPoint.x
    self.switchDirection = mouseOffset > 0 and switchDirection.RIGHT or switchDirection.LEFT
    local prefabOffset = math.abs(mouseOffset * self.offsetRatio)

    if not self["can" .. self.switchDirection .. "Switch"] then
        if self.isElastic then
            self:DoIfElasticIsUsing(prefabOffset, pt)
            return
        else
            self.fromPoint = Vector3Lua(pt.x, 0, 0)
            return
        end
    end

    if not self.isLoop then
        if prefabOffset > self["max" .. self.switchDirection .. "RollLength"] then
            if self.isElastic then
                self:DoIfElasticIsUsing(prefabOffset, pt)
                return
            else
                prefabOffset = self["max" .. self.switchDirection .. "RollLength"]
                self:DoIfAtExtremeEnd(self.switchDirection)
                self.fromPoint = Vector3Lua(pt.x, 0, 0)
            end
        end
    end

    local switchCount = prefabOffset / self.prefabDistance
    self:ResetPrefabsBySwitchCount(switchCount)

    self:UpdatePrefabPostionScaleAsMoving(prefabOffset)

    if self.isElasticUsing then
        self.isElasticUsing = not self:CheckElasticIsNotUsing(prefabOffset)
    end
end

function ThreeRollCtrl:CheckElasticIsNotUsing(prefabOffset)
    return prefabOffset < self["max" .. self.switchDirection .. "RollLength"]
 end

function ThreeRollCtrl:DoIfElasticIsUsing(prefabOffset, pt)
    self.isElasticUsing = true
    local overStretchingOffset = self:ReCalculatePrefabOffset(prefabOffset)
    self.overStretchingOffset = overStretchingOffset
    local switchCount = self["max" .. self.switchDirection .. "RollLength"] / self.prefabDistance

    self:ResetPrefabsBySwitchCount(switchCount)
    self:UpdatePrefabPostionIfElacticIsUsing(overStretchingOffset)
end

function ThreeRollCtrl:UpdatePrefabPostionIfElacticIsUsing(overStretchingOffset)
    local signedOverStretchingOffset = self.switchDirection == switchDirection.RIGHT and overStretchingOffset or -overStretchingOffset
    local signedOffsetVector = Vector3Lua(signedOverStretchingOffset, 0, 0)

    self.leftPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.lHidden)
    self.rightPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.rHidden)
    self.threeObjs[1].transform.localPosition = self:ConvertVector3(self.positionList.left + signedOffsetVector)
    self.threeObjs[1].transform.localScale = self:ConvertVector3(self.originalVector)
    self.threeObjs[2].transform.localPosition = self:ConvertVector3(self.positionList.middle + signedOffsetVector)
    self.threeObjs[2].transform.localScale = self:ConvertVector3(self.scaleVector)
    self.threeObjs[3].transform.localPosition = self:ConvertVector3(self.positionList.right + signedOffsetVector)
    self.threeObjs[3].transform.localScale = self:ConvertVector3(self.originalVector)
end

--用于维护self.middleIndex和reset prefabs
function ThreeRollCtrl:ResetPrefabsBySwitchCount(switchCount)
    if switchCount >= 1 then
        local middleIndex = nil
        if self.switchDirection == switchDirection.RIGHT then
            middleIndex = self.beginMiddleIndex - math.floor(switchCount)
        else
            middleIndex = self.beginMiddleIndex + math.floor(switchCount)
        end
        --兼容elastic
        if self.isElastic then
            if middleIndex > self.maxMiddleIndex then middleIndex = self.maxMiddleIndex end
            if middleIndex < self.minMiddleIndex then middleIndex = self.minMiddleIndex end
        end

        middleIndex = self:VerifyIndex(middleIndex)
        if middleIndex ~= self.middleIndex then
            self.middleIndex = middleIndex
            self:ResetPrefabObjs()

            if not self.isLoop and self.middleIndex == self:GetExtremeMiddleIndexByDirection(self.switchDirection) and not self.isElastic then
                self.beginMiddleIndex = self.middleIndex
            end
        end
    else
        if self.middleIndex ~= self.beginMiddleIndex then
            self.middleIndex = self.beginMiddleIndex
            self:ResetPrefabObjs()
        end
    end
end

function ThreeRollCtrl:UpdatePrefabPostionScaleAsMoving(prefabOffset)
    local realOffset = prefabOffset % self.prefabDistance
    if self.switchDirection == switchDirection.LEFT then
        realOffset = -realOffset
    end
    local realOffsetVector = Vector3Lua(realOffset, 0, 0)

    local ToHiddenOffset = math.abs(realOffset) / self.prefabDistance * self.potentialDistance
    if self.switchDirection == switchDirection.RIGHT then
        self.threeObjs[1].transform.localPosition = self:ConvertVector3(self.positionList.left + realOffsetVector)
        self:DoScacleForPrefab(self.threeObjs[1], self.positionList.left.x + realOffset)
        
        local ToHiddenOffsetVector = Vector3Lua(ToHiddenOffset, 0, 0)
        self.threeObjs[3].transform.localPosition = self:ConvertVector3(self.positionList.right + ToHiddenOffsetVector)
        self:DoScacleForPrefab(self.threeObjs[3], self.positionList.right.x + ToHiddenOffset)
    else
        local ToHiddenOffsetVector = Vector3Lua(ToHiddenOffset, 0, 0)
        self.threeObjs[1].transform.localPosition = self:ConvertVector3(self.positionList.left - ToHiddenOffsetVector)
        self:DoScacleForPrefab(self.threeObjs[1], self.positionList.left.x - ToHiddenOffset)

        self.threeObjs[3].transform.localPosition = self:ConvertVector3(self.positionList.right + realOffsetVector)
        self:DoScacleForPrefab(self.threeObjs[3], self.positionList.right.x + realOffset)
    end
    
    self.threeObjs[2].transform.localPosition = self:ConvertVector3(self.positionList.middle + realOffsetVector)
    self:DoScacleForPrefab(self.threeObjs[2], self.positionList.middle.x + realOffset)

    self:ManagePotentialCase(realOffset)
end

function ThreeRollCtrl:ManagePotentialCase(realOffset)
    local realPotentialOffset = math.abs(realOffset) / self.prefabDistance * self.potentialDistance
    local realPotentialOffsetVector = Vector3Lua(realPotentialOffset, 0, 0)
    
    if self.switchDirection == switchDirection.RIGHT then                                                                                                 
        self.leftPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.lHidden + realPotentialOffsetVector)
        self.leftPotentialNext.transform.localScale = self:ConvertVector3(self.originalVector)

        if self.rightPotentialNext.transform.localPosition.x ~= self.positionList.rHidden.x then --上一帧left 下一帧 right, 导致rightPotentialNext位置停留在上一帧的位置，未恢复到原位 得特殊处理一些self.rightPotentialNext
            self.rightPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.rHidden)
            self.rightPotentialNext.transform.localScale = self:ConvertVector3(self.originalVector)
        end
    else
        self.rightPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.rHidden - realPotentialOffsetVector)
        self.rightPotentialNext.transform.localScale = self:ConvertVector3(self.originalVector)

        if self.leftPotentialNext.transform.localPosition ~= self.positionList.lHidden.x then
            self.leftPotentialNext.transform.localPosition = self:ConvertVector3(self.positionList.lHidden)
            self.leftPotentialNext.transform.localScale = self:ConvertVector3(self.originalVector)
        end
    end
end

function ThreeRollCtrl:ResetPrefabObjs()
    local obj = nil    
    local realIndex = nil
    realIndex = self:VerifyIndex(self.middleIndex - 1)
    obj = self.parentCtrl:ResetOnePrefab(self.threeObjs[1], self.dataList[realIndex])

    realIndex = self:VerifyIndex(self.middleIndex)
    obj = self.parentCtrl:ResetOnePrefab(self.threeObjs[2], self.dataList[realIndex])

    realIndex = self:VerifyIndex(self.middleIndex + 1)
    obj = self.parentCtrl:ResetOnePrefab(self.threeObjs[3], self.dataList[realIndex])

    local leftPotentialIndex = self:VerifyIndex(self.middleIndex - 2)
    self.leftPotentialNext = self.parentCtrl:ResetOnePrefab(self.leftPotentialNext, self.dataList[leftPotentialIndex])

    local rightPotentialIndex = self:VerifyIndex(self.middleIndex + 2)
    self.rightPotentialNext = self.parentCtrl:ResetOnePrefab(self.rightPotentialNext, self.dataList[rightPotentialIndex])
end

function ThreeRollCtrl:DoScacleForPrefab(obj, currentPositionX)
    local scaleValue = self.scaleOriginal
    if currentPositionX < self.positionList.right.x and currentPositionX > self.positionList.left.x then
        scaleValue = self.scaleOriginal + (self.scaleFactor - self.scaleOriginal) * (currentPositionX - self.positionList.left.x) / self.prefabDistance

        if scaleValue > self.scaleFactor then
            scaleValue = self.scaleFactor - (self.scaleFactor - self.scaleOriginal) * currentPositionX / self.prefabDistance
        end
        if scaleValue < self.scaleOriginal then
            scaleValue = self.scaleOriginal
        end
    end 
    obj.transform.localScale = Vector3(scaleValue, scaleValue, 1)
end

function ThreeRollCtrl:ConvertVector3(vector)
    return Vector3(vector.x, vector.y, vector.z)
end

function ThreeRollCtrl:GetExtremeMiddleIndexByDirection(direction)
    return direction == switchDirection.LEFT and self.maxMiddleIndex or self.minMiddleIndex
end

function ThreeRollCtrl:GetOppositeDirection(direction)
    return direction == switchDirection.LEFT and switchDirection.RIGHT or switchDirection.LEFT
end

function ThreeRollCtrl:VerifyIndex(index)
    if index >= 1 and index <= self.listCount then
        return index
    end
    if index > self.listCount then
        return index % self.listCount
    end
    if index < 0 then
        return self:VerifyIndex(index + self.listCount)
    end
    if index == 0 then
       return self.listCount
    end
end

function ThreeRollCtrl:ReCalculatePrefabOffset(offset)
    local overStretchingOffset = offset - self["max" .. self.switchDirection .. "RollLength"]
    local rubberOffset = self:RubberDelta(overStretchingOffset, self.viewContentSizeX)
    return rubberOffset
end

function ThreeRollCtrl:RubberDelta(overStretching, viewSize)
    if not viewSize or tonumber(viewSize) == 0 then return 0 end
    return (1 - (1 / ((math.abs(overStretching) * 0.55 / viewSize) + 1))) * viewSize
end

function ThreeRollCtrl:CalculateViewContentSizeX()
    return self.positionList.rHidden.x - self.positionList.left.x
end

return ThreeRollCtrl
