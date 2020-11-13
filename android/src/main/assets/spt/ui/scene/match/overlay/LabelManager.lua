local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Animator = UnityEngine.Animator
local UI = UnityEngine.UI
local Text = UI.Text
local Image = UI.Image
local Outline = UI.Outline
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time

local PrefabCache = require("ui.scene.match.overlay.PrefabCache")

local LabelManager = class(unity.base)

local whiteColor = Color(1, 1, 1)
local grayColor = Color(0.5, 0.5, 0.5)
local skillTextColor = Color(1, .922, 0.392)
local skillOutlineColor = Color(.686, .431, .078)

function LabelManager:ctor()
    self.athleteLabelsComponent = self.___ex.athleteLabelsComponent
    self.currentTextBarList = {}
    self.textBarSerialNumber = {}
    self.textBarPriority = {}
    self.currentMarkerList = {}

    self.athleteQueue = {}

    PrefabCache.labelBarPool:allocate(self.transform, 12)
end

local labelDeltaPos = Vector3(0, 1.8, 0)
local labelDeltaPixel = Vector2(0, 0)

local function RemoveLowProrityItem(queue, priority)
    if queue and priority then
        for i = #queue, 1, -1 do
            if queue[i].priority < priority then
                table.remove(queue, i)
            end
        end
    end
end

function LabelManager:DisplayLabel(athlete, athleteObject, labelText, iconName, iconValue, priority, displayTime, delayTime, textColor, outlineColor, callbackFunc)
    local onfieldId = athlete.onfieldId
    local labelInfo = {
        athlete = athlete,
        athleteObject = athleteObject,
        labelText = labelText,
        iconName = iconName,
        iconValue = iconValue,
        priority = priority or 0,
        displayTime = displayTime or 1.2,
        delayTime = delayTime,
        textColor = textColor,
        outlineColor = outlineColor,
        callbackFunc = callbackFunc,
    }

    if not self.athleteQueue[onfieldId] then
        self.athleteQueue[onfieldId] = {}
    end
    local queue = self.athleteQueue[onfieldId]
    RemoveLowProrityItem(queue, labelInfo.priority)
    table.insert(queue, labelInfo)
    self:TriggerLabel(onfieldId)
end

function LabelManager:TriggerLabel(onfieldId)
    local queue = self.athleteQueue[onfieldId]
    if queue and #queue > 0 then
        local labelInfo = queue[1]
        local athlete = labelInfo.athlete
        local priority = labelInfo.priority or 0
        if self.currentTextBarList[athlete.onfieldId] then
            local currentPriority = self.textBarPriority[athlete.onfieldId]
            if currentPriority and currentPriority >= priority then
                return
            end

            local oldTextBar = self.currentTextBarList[athlete.onfieldId]
            self.currentTextBarList[athlete.onfieldId] = nil
            self.athleteLabelsComponent:RemoveLabel(oldTextBar)
            oldTextBar:SetActive(false)
            PrefabCache.labelBarPool:returnObject(oldTextBar)
        end

        table.remove(queue, 1)

        self:coroutine(function()
            self.textBarPriority[athlete.onfieldId] = priority

            local athleteObject = labelInfo.athleteObject
            -- Serial Number for replace
            local serialNumber = self.textBarSerialNumber[athlete.onfieldId] or 0
            serialNumber = serialNumber + 1
            self.textBarSerialNumber[athlete.onfieldId] = serialNumber

            -- Generate new textBar
            local textBar = PrefabCache.labelBarPool:getObject()
            textBar:SetActive(true)

            local textBarScript = textBar:GetComponent(clr.CapsUnityLuaBehav)
            textBarScript:init(self.transform)
            textBarScript:setText(labelInfo.labelText, labelInfo.textColor or whiteColor)

            self.currentTextBarList[athlete.onfieldId] = textBar
            local height = type(athlete.height) == "number" and (athlete.height / 100) or 1.8

            local displayTime = labelInfo.displayTime or 1
            -- For skill icon
            local skillBar = textBar.transform:FindChild("SkillBar").gameObject
            local icon = nil
            local iconName = labelInfo.iconName
            if iconName ~= nil then
                icon = PrefabCache.skillIcon[iconName]
            end
            if icon then
                textBarScript:setSkillValue(labelInfo.iconValue)
                self.athleteLabelsComponent:AddLabel(textBar, labelInfo.athleteObject, Vector3(0, height, 0), labelDeltaPixel, true, false, 0, nil)
                textBarScript:setIcon(icon)
                textBarScript:playMoveIn()
                textBarScript:playFlash()
            else
                self.athleteLabelsComponent:AddLabel(textBar, labelInfo.athleteObject, Vector3(0, height, 0), labelDeltaPixel, false, false, 0, nil)
                skillBar:SetActive(false)
            end

            -- Wait for time period
            local endtime = Time.realtimeSinceStartup + displayTime
            repeat 
                coroutine.yield()
            until Time.realtimeSinceStartup >= endtime

            -- Remove if still existed
            if self.textBarSerialNumber[athlete.onfieldId] == serialNumber and self.currentTextBarList[athlete.onfieldId] == textBar then
                self.currentTextBarList[athlete.onfieldId] = nil
                self.athleteLabelsComponent:RemoveLabel(textBar)
                textBar:SetActive(false)
                PrefabCache.labelBarPool:returnObject(textBar)
            end

            if labelInfo.callbackFunc then
                labelInfo.callbackFunc()
            end

            self:TriggerLabel(onfieldId)
        end)
    end
end

function LabelManager:RemoveLabel(onfieldId, athleteObject)
    self.athleteQueue[onfieldId] = nil
    if self.currentTextBarList[onfieldId] then
        local oldTextBar = self.currentTextBarList[onfieldId]
        self.currentTextBarList[onfieldId] = nil
        self.athleteLabelsComponent:RemoveLabel(oldTextBar)
        oldTextBar:SetActive(false)
        PrefabCache.labelBarPool:returnObject(oldTextBar)
    end
end

function LabelManager:DisplayCandidateMarker(athlete, athleteObject)
    local currentMarker = self.currentMarkerList[athlete.onfieldId]
    if currentMarker then
        return
    end

    local candidateMarker = PrefabCache.candidateMarkerPool:getObject()
    candidateMarker.transform:SetParent(self.transform, false)
    candidateMarker:SetActive(true)
    self.athleteLabelsComponent:AddLabel(candidateMarker, athleteObject, labelDeltaPos, labelDeltaPixel, false, false, 0, nil)
    self.currentMarkerList[athlete.onfieldId] = candidateMarker
end

function LabelManager:RemoveCandidateMarker(athlete, athleteObject)
    local currentMarker = self.currentMarkerList[athlete.onfieldId]
    if currentMarker then
        currentMarker:SetActive(false)
        self.currentMarkerList[athlete.onfieldId] = nil
        self.athleteLabelsComponent:RemoveLabel(currentMarker, athleteObject)
        PrefabCache.candidateMarkerPool:returnObject(currentMarker)
    end
end

return LabelManager
