local Formation = require('data.Formation')

local Helper = {}

--- 判断某一位置在阵型中是否存在
-- @param pos 位置
-- @param formationId 阵型Id
function Helper.IsPosExisted(pos, formationId)
    local formation = Formation[tostring(formationId)].posArray
    for k, v in pairs(formation) do
        if pos == tonumber(v) then
            return true
        end
    end
    return false
end

--- 获取某一位置在阵型中的归一化位置
-- @param pos 位置
-- @param formationId 阵型Id
-- @param isPortrait 阵型是竖向还是横向，默认是true
-- @param isRotate 是否旋转，默认是false
function Helper.GetPos(pos, formationId, isPortrait, isRotate)
    pos = tonumber(pos)
    if isPortrait == nil then
        isPortrait = true
    end
    if isRotate == nil then
        isRotate = false
    end

    local coorArray = Formation[tostring(formationId)].coorArray
    if type(coorArray) == "table" and next(coorArray) then
        local coorIndex = nil
        local formation = Formation[tostring(formationId)].posArray
        local isIncludePosArray = false
        for i, v in ipairs(formation) do
            if pos == tonumber(v) then
                coorIndex = i
                isIncludePosArray = true
                break
            end
        end
        if isIncludePosArray then
            local coorData = coorArray[coorIndex]
            if not isRotate then
                return {x = coorData[1], y = coorData[2]}
            else
                if isPortrait then
                    return {x = coorData[2], y = -coorData[1]}
                else
                    return {x = -coorData[2], y = coorData[1]}
                end
            end
        end
    end

    local emptyCoorArray = Formation[tostring(formationId)].emptyCoorArray
    if type(emptyCoorArray) == "table" and next(emptyCoorArray) then
        local emptyCoorIndex = nil
        local formation = Formation[tostring(formationId)].emptyPosArray
        local isIncludeEmptyPosArray = false
        for i, v in ipairs(formation) do
            if pos == tonumber(v) then
                emptyCoorIndex = i
                isIncludeEmptyPosArray = true
                break
            end
        end
        if isIncludeEmptyPosArray then
            local emptyCoorData = emptyCoorArray[emptyCoorIndex]
            if not isRotate then
                return {x = emptyCoorData[1], y = emptyCoorData[2]}
            else
                if isPortrait then
                    return {x = emptyCoorData[2], y = -emptyCoorData[1]}
                else
                    return {x = -emptyCoorData[2], y = emptyCoorData[1]}
                end
            end
        end
    end

    -- 计算水平坐标
    local key = 5
    local centerKey = 3
    local totalCol = 0
    local remainderPos = pos % key

    if remainderPos == 0 then
        remainderPos = key
    end

    local centerPos = pos + (centerKey - remainderPos)

    if Helper.IsPosExisted(centerPos, formationId) then
        totalCol = key - 1
    else
        totalCol = key - 2

        if pos > centerPos then
            remainderPos = remainderPos - 1
        end
    end

    local colNum = (remainderPos - 1) % (totalCol + 1)
    local x = (colNum - totalCol / 2) / totalCol

    -- 计算垂直坐标
    local totalRow = 5
    local rowNum = math.floor((pos - 1) / totalRow)
    local y = (totalRow / 2 - rowNum) / totalRow

    -- 特殊处理，最后一排只有门将，应该放在中间
    if rowNum == totalRow then
        x = 0
    end

    if isPortrait then
        return {x = x, y = y}
    else
        return {x = y, y = -x}
    end
end

--- 获取某一位置在阵型中的坐标位置，主要用于梯形阵型中
-- @param pos 位置
-- @param formationId 阵型Id
-- @param formationWidth 阵型宽
-- @param formationHeight 阵型高
-- @param formationRotateX X轴旋转角度
-- @param isPortrait 阵型是竖向还是横向，默认是true
-- @param isRotate 是否旋转，默认是false
function Helper.GetTrapezoidFormationCoord(pos, formationID, formationWidth, formationHeight, formationRotateX, isPortrait, isRotate)
    local normalizedPos = Helper.GetPos(pos, formationID, isPortrait, isRotate)
    local x, y, scale
    local oldX = 0.5 + normalizedPos.x
    local oldY = 0.5 + normalizedPos.y
    local newX, newY = Helper.GetPerspectiveRatio(oldX, oldY, formationRotateX)
    if oldY == 0 or newY == 0 then
        scale = 1
    else
        scale = newY / oldY * 1.1
        if scale > 1 then
            scale = 1
        end
    end
    newX = newX - 0.5
    return {x = newX * formationWidth, y = newY * formationHeight, scale = scale}
end

--- 获取透视比例
-- @param horizontalRatio 水平比例，从左到右为0-1
-- @param verticalRatio 垂直比例，从下到上为0-1
-- @param rotateX X轴旋转角度
function Helper.GetPerspectiveRatio(horizontalRatio, verticalRatio, rotateX)
    -- Field of View
    local fov = 60
    -- 计算透视后的垂直比例
    local newVerticalRatio = verticalRatio * (math.sin(math.rad(90 - fov)) * math.cos(math.rad(90 - rotateX)) + math.sin(math.rad(90 - rotateX)) * math.cos(math.rad(90 - fov))) / (verticalRatio * math.cos(math.rad(90 - rotateX)) + math.cos(math.rad(90 - fov)))
    -- 计算透视后的水平比例
    local a = math.sin(math.rad(fov))
    local b = math.sqrt(math.pow(verticalRatio, 2) + math.pow(newVerticalRatio, 2) - 2 * verticalRatio * newVerticalRatio * math.cos(math.rad(rotateX)))
    local newHorizontalRatio = (2 * a * horizontalRatio + b) / (2 * (a + b))
    return newHorizontalRatio, newVerticalRatio
end

function Helper.GetPosList(formationId)
    -- TODO: Performance optimization
    local ret = {}
    local formation = Formation[tostring(formationId)].posArray
    for k, v in pairs(formation) do
        local role = tonumber(v)
        table.insert(ret, Helper.GetPos(role, formationId))
    end
    return ret
end

return Helper