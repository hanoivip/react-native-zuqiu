local AgentView = class(unity.base)

function AgentView:ctor()
    self.menuScript = self.___ex.menuScript
    self.pageArea = self.___ex.pageArea
    self.timeLimitText = self.___ex.timeLimitText
    self.timeLimit = self.___ex.timeLimit
end

function AgentView:start()
    local menu = self.menuScript.menu
    for key, page in pairs(menu) do
        page:regOnButtonClick(function()
            self:OnBtnMenu(key)
        end)
    end
end

function AgentView:OnBtnMenu(key)
    if key == self.currentPageTag then return end
    self.currentPageTag = key
    self:OnBtnPage(key)
    self.menuScript:selectMenuItem(key)
end

function AgentView:OnBtnPage(key)
    if self.clickPage then 
        self.clickPage(key)
    end
end

function AgentView:SetTimeLimit(lastTime)
    if lastTime and lastTime ~= 0  then 
        self.timeLimit:SetActive(true)
        local timeTable = string.convertSecondToTimeTable(lastTime)
        local timeText = ""
        if timeTable.day == 0 then 
            if timeTable.hour == 0 then 
                timeText = lang.trans("agent_limit_minutes", timeTable.minute)
            else
                if timeTable.minute == 0 then 
                    self.timeLimit:SetActive(false)
                else
                    timeText = lang.trans("agent_limit_hour", timeTable.hour, timeTable.minute)
                end
            end
        else
            timeText = lang.trans("agent_limit_day", timeTable.day, timeTable.hour, timeTable.minute)
        end
        self.timeLimitText.text = timeText
    else
        self.timeLimit:SetActive(false)
    end
end

function AgentView:InitView(model, page, lastTime)
    self.currentPageTag = nil
    self.pageTag = page
    self:OnBtnMenu(self.pageTag)
    self:SetTimeLimit(lastTime)
end

return AgentView
