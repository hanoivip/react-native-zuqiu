local UnityEngine = clr.UnityEngine

local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local Image = UnityEngine.Image

local CompeteOutScrollView = class(unity.base)

function CompeteOutScrollView:ctor()
    self.content = self.___ex.content
    self.stageCount = self.___ex.stageCount
    self.scrollRect = self.___ex.scrollRect
    self.visibleStageCount = self.___ex.visibleStageCount
    self.snappingSpeed = self.___ex.snappingSpeed
	self.space = self.___ex.space or 0

    self.stages = {}
    -- create 5 stage view and distribute them evenly in content
    for i = 1, self.stageCount do
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteOutStage.prefab"
        local obj, spt = res.Instantiate(prefab)

        obj.transform.localPosition = Vector3((i - 1) * obj.transform.rect.width, 0, 0)

        spt:Init(i, self.stageCount, self.space)
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
        [2] = { 0, 0.5 * self.teamHeight, 0, 0},
        [3] = { 0, 0.5 * self.teamHeight, 1.5 * self.teamHeight, 0},
        [4] = { 0, self.transform.rect.height / 4 - 0.5 * self.teamHeight, 1.5 * self.teamHeight, 3.5 * self.teamHeight}
    }
end

function CompeteOutScrollView:update()
    -- if dragged, move to next stage
    if self.dragged then

        local frameHorizontalNormalizedPosition = self.scrollRect.horizontalNormalizedPosition + self.dragDirection * self.snappingSpeed * 0.001

        if self.dragDirection > 0 then
            frameHorizontalNormalizedPosition = math.min(self.targetHorizontalNormalizedPosition, frameHorizontalNormalizedPosition)
        else
            frameHorizontalNormalizedPosition = math.max(self.targetHorizontalNormalizedPosition, frameHorizontalNormalizedPosition)
        end

        if math.abs(frameHorizontalNormalizedPosition - self.scrollRect.horizontalNormalizedPosition) < 0.000001 then
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

		local offset = self.content.sizeDelta.y - height
		offset = offset <=0 and 0 or offset
		local offsetHeight = self.content.anchoredPosition.y - offset
		offsetHeight = offsetHeight < 0 and 0 or offsetHeight
		self.content.anchoredPosition = Vector2(self.content.anchoredPosition.x, offsetHeight)
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
                local currentColumn = math.min(previousColumn + 1, self.stageCount - 2)

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
			local team = self.stages[integral].teams[i]
            team.lineImageX.color = color
            team.lineImageY.color = color
			team.checkImage.color = color
        end
    end

    if self.dragged or self.lastHorizontalNormalizedPosition ~= self.scrollRect.horizontalNormalizedPosition then
        -- make scroll of title follow this one
        --self.titleScrollRect.horizontalNormalizedPosition = self.scrollRect.horizontalNormalizedPosition

        -- save position
        self.lastHorizontalNormalizedPosition = self.scrollRect.horizontalNormalizedPosition
    end
end

function CompeteOutScrollView:ResetLineColor()
	local color = Color(1, 1, 1, 1)
	for index = 1, table.nums(self.stages) do
		local teamCount = self.stages[index].teamCount or 0
		for i = 1, teamCount do
			local team = self.stages[index].teams[i]
			team.lineImageX.color = color
			team.lineImageY.color = color
			team.checkImage.color = color
		end
	end
end

function CompeteOutScrollView:heightIfStageInFirstColumn(stage)
    -- how many teams
    local teamCount = self.stages[stage].teamCount
    -- total height
    local height = teamCount * self.stages[stage].teams[1].transform.rect.height + (teamCount - 1) * self.space
    height = math.max(height, self.transform.rect.height)
    return height
end

function CompeteOutScrollView:onBeginDrag(eventData)
    self.dragging = true
    self.dragDirection = 0
	local isHorizontal = tobool( math.abs(eventData.delta.x) >= math.abs(eventData.delta.y) )
	self.scrollRect.horizontal = isHorizontal
	self.scrollRect.vertical = not isHorizontal
	if not isHorizontal then 
		self.dragging = false
		self.lastHorizontalNormalizedPosition = self.scrollRect.horizontalNormalizedPosition
	end
end

function CompeteOutScrollView:onEndDrag(eventData)
	self.scrollRect.horizontal = true
	self.scrollRect.vertical = true
    if self.dragging then
        if self.dragDirection ~= 0 then
            self.dragged = true

            local stage = math.max(self.scrollRect.horizontalNormalizedPosition * (self.stageCount - self.visibleStageCount) + 1, 1)
            local nextStage = self.dragDirection > 0 and math.ceil(stage) or math.floor(stage)
            nextStage = math.max(nextStage, 1)
            nextStage = math.min(nextStage, self.stageCount - 2)

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

function CompeteOutScrollView:onDrag(eventData)
    if self.dragging and eventData.delta.x ~= 0 and self.dragDirection == 0 then
        self.dragDirection = eventData.delta.x > 0 and -1 or 1
    end
end

return CompeteOutScrollView