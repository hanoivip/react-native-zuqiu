local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local TextAnchor = UnityEngine.TextAnchor
local WaitForSeconds = UnityEngine.WaitForSeconds
local TypeWriterElement = require("ui.control.typeWriter.TypeWriterElement")
local UISoundManager = require("ui.control.manager.UISoundManager")

local TypeWriter = class(unity.base)

function TypeWriter:ctor(elements, pauseTime)
    assert(type(elements) == "table")
    self.elements = elements
    self.pauseTime = pauseTime
    self.isPlaySound = true
end

function TypeWriter:StartWriter()
    clr.coroutine(function()
        for i, element in ipairs(self.elements) do
            if element:GetElementType() == ElementType.TEXT then
                local textComponent = element:GetComponent()
                local text = element:GetAttribute()
                local textTab = clr.splitstr(text)
                for j = 1, #textTab do
                    if textTab[j] == nil then
                        textTab[j] = ""
                    end
                    textComponent.text = table.concat(textTab, nil, 1, j)
                    coroutine.yield(WaitForSeconds(self.pauseTime))
                end
            end
            if element:GetElementType() == ElementType.IMAGE then
                local imageComponent = element:GetComponent()
                local imageAttribute = element:GetAttribute()
                imageComponent.sprite = imageAttribute
                imageComponent.enabled = true
                coroutine.yield(WaitForSeconds(self.pauseTime))
            end
            if element:GetElementType() == ElementType.BYTESIMAGE then
                local bytesImageComponent = element:GetComponent()
                local bytesImageAttribute = element:GetAttribute()
                bytesImageComponent.Path = bytesImageAttribute 
                bytesImageComponent:ApplySource()
                local imageComponent = bytesImageComponent.transform:GetComponent(Image)
                if imageComponent then
                    imageComponent.enabled = true
                end
                coroutine.yield(WaitForSeconds(self.pauseTime))
            end
            if element:GetElementType() == ElementType.GAMEOBJECT then
                local gameObjectComponent = element:GetComponent()
                gameObjectComponent.gameObject:SetActive(true)
                coroutine.yield(WaitForSeconds(self.pauseTime))
            end
        end
        self.isPlaySound = false
        if self.onFinished then
            self.onFinished()
        end
    end)
    clr.coroutine(function()
        while self.isPlaySound do
            self:playSound()
            coroutine.yield(WaitForSeconds(self.pauseTime * 3))
        end
    end)
end

function TypeWriter:playSound()
    UISoundManager.play("Match/matchLoading", 1)
end

function TypeWriter:regOnFinished(func)
    if type(func) == "function" then
        self.onFinished = func
    end
end

function TypeWriter:unregOnFinished()
    self.onFinished = nil
end

return TypeWriter
