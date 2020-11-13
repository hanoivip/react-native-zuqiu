local UnityEngine = clr.UnityEngine

local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local Image = UnityEngine.Image

local ArenaOutScrollView = class(unity.base)

function ArenaOutScrollView:ctor()
    self.content = self.___ex.content
    self.stageCount = self.___ex.stageCount
    self.scrollRect = self.___ex.scrollRect
    self.visibleStageCount = self.___ex.visibleStageCount
    self.titleScrollRect = self.___ex.titleScrollRect
    self.snappingSpeed = self.___ex.snappingSpeed

    self.stages = {}
    -- create 5 stage view and distribute them evenly in content
    for i = 1, self.stageCount do
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaOutStage.prefab"
        local obj, spt = res.Instantiate(prefab)

        obj.transform.localPosition = Vector3((i - 1) * obj.transform.rect.width, 0, 0)

        spt:Init(i, self.stageCount)
        self.stages[i] = spt
        self.content.sizeDelta = Vector2(self.content.sizeDelta.x, math.max(self.content.sizeDelta.y, obj.transform.sizeDelta.y))
        obj.transform:SetParent(self.content, false)
    end

    self.stages[self.stageCount].transform.sizeDelta = Vector2(self.stages[self.stageCount].transform.sizeDelta.x, self.transform.rect.height)

    self.scrollRect.horizontalNormalizedPosition = 0
    self.scrollRect.verticalNormalizedPosition = 1

    self.lastHorizontalNormalizedPosition = -1

    self.maxHeightForStages = {}
    for i = 1, self.stageCount - 1 do
        self.maxHeightForStages[i] = self:heightIfStageInFirstColumn(i)
    end

    self.teamHeight = self.stages[1].teams[1].transform.rect.height

    -- center position
    -- stage, column
    self.tops =
    {
        [2] = { [1] = 0, [2] = 0.5 * self.teamHeight, [3] = 0.5 * self.teamHeight },
        [3] = { [1] = 0, [2] = self.transform.rect.height / 4 - 0.5 * self.teamHeight, [3] = 1.5 * self.teamHeight}
    }
end

function ArenaOutScrollView:update()
    -- if dragged, move to next stage
    if self.dragged then

        local frameHorizontalNormalizedPosition = self.scrollRect.horizontalNormalizedPosition + self.dragDirection * self.snappingSpeed * 0.001

        if self.dragDirection > 0 then
            frameHorizontalNormalizedPosition = math.min(self.targetHorizontalNormalizedPosition, frameHorizontalNormalizedPosition)
        else
            frameHorizontalNormalizedPosition = math.max(self.targetHorizontalNormalizedPosition, frameHorizontalNormalizedPosition)
        end

        if frameHorizontalNormalizedPosition == self.scrollRect.horizontalNormalizedPosition then
            self.dragged = false
        else
            self.scrollRect.horizontalNormalizedPosition = frameHorizontalNormalizedPosition
        end
    end

    -- if scrolled on X, update size and position on Y
    if self.lastHorizontalNormalizedPosition ~= self.scrollRect.horizontalNormalizedPosition then
        -- find out the target stage on the left
        -- 0: 1
        -- 0.5 : 2
        -- 1 : 3
        local stage = math.max(self.scrollRect.horizontalNormalizedPosition * (self.stageCount - self.visibleStageCount) + 1, 1)

        local integral, fractional = math.modf(stage)
        -- update height of each columns
        -- height if stage in first column
        local height1 = self.maxHeightForStages[integral + 1]
        -- height if stage in second column
        local height2 = self.maxHeightForStages[integral]
        -- height now
        local height = (height1 - height2) * fractional + height2

        self.content.sizeDelta = Vector2(self.content.sizeDelta.x, height)

        for i = 1, self.stageCount - 1 do
            local teamCount = self.stages[i].teamCount
            self.stages[i].transform.sizeDelta = Vector2(self.stages[i].transform.sizeDelta.x, math.max(teamCount * self.teamHeight, height))
        end

        -- update position of teams

        -- no need to update first team, last team or cup, so just update 2 and 3
        -- distribute teams of second or third column evenly on y
        for i, values in pairs(self.tops) do
            local column = i - stage + 1
            if column >= 1 then
                local previousColumn, previousPercentage = math.modf(column)
                local currentColumn = math.min(previousColumn + 1, 3)

                local top1 = values[previousColumn]
                local top2 = values[currentColumn]
                local top = (top2 - top1) * previousPercentage + top1

                local stageHeight = self.stages[i].transform.rect.height
                local firstPosY = stageHeight / 2 - top - self.teamHeight / 2
                local gap = (stageHeight - top * 2 - self.teamHeight * self.stages[i].teamCount) / (self.stages[i].teamCount - 1) + self.teamHeight

                for j = 1, self.stages[i].teamCount do
                    self.stages[i].teams[j].transform.anchoredPosition  = Vector2(0, firstPosY - gap * (j - 1))

                    if math.fmod(j, 2) == 1 then
                        local lineWidth = gap + self.stages[i].teams[j].lineY.sizeDelta.y -- add line height to avoid gap between line x and y
                        self.stages[i].teams[j].lineY.sizeDelta = Vector2(lineWidth, self.stages[i].teams[j].lineY.sizeDelta.y)
                    end
                end
            end
        end

        -- update alpha of lines of left most column
        local color = Color(1, 1, 1, 1 - fractional)
        for i = 1, self.stages[integral].teamCount do
            self.stages[integral].teams[i].lineImageX.color = color
            self.stages[integral].teams[i].lineImageY.color = color
        end
    end

    if self.dragged or self.lastHorizontalNormalizedPosition ~= self.scrollRect.horizontalNormalizedPosition then
        -- make scroll of title follow this one
        self.titleScrollRect.horizontalNormalizedPosition = self.scrollRect.horizontalNormalizedPosition

        -- save position
        self.lastHorizontalNormalizedPosition = self.scrollRect.horizontalNormalizedPosition
    end
end

function ArenaOutScrollView:heightIfStageInFirstColumn(stage)
    -- how many teams
    local teamCount = self.stages[stage].teamCount
    -- total height
    local height = teamCount * self.stages[stage].teams[1].transform.rect.height
    height = math.max(height, self.transform.rect.height)
    return height
end

function ArenaOutScrollView:onBeginDrag(eventData)
    self.dragging = true
    self.dragDirection = 0
end

function ArenaOutScrollView:onEndDrag(eventData)
    if self.dragging then
        if self.dragDirection ~= 0 then
            self.dragged = true

            local stage = math.max(self.scrollRect.horizontalNormalizedPosition * (self.stageCount - self.visibleStageCount) + 1, 1)
            local nextStage = self.dragDirection > 0 and math.ceil(stage) or math.floor(stage)
            nextStage = math.max(nextStage, 1)
            nextStage = math.min(nextStage, self.visibleStageCount)

            if stage ~= nextStage then
                -- 0: 1
                -- 0.5 : 2
                -- 1 : 3
                self.targetHorizontalNormalizedPosition = (nextStage - 1) / (self.stageCount - self.visibleStageCount)
            else
                self.dragged = false
            end
        end
    end

    self.dragging = false
end

function ArenaOutScrollView:onDrag(eventData)
    if self.dragging and eventData.delta.x ~= 0 and self.dragDirection == 0 then
        self.dragDirection = eventData.delta.x > 0 and -1 or 1
    end
end

return ArenaOutScrollView
