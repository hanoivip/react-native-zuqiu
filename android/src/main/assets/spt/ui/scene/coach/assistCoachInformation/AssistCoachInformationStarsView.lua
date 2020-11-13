local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")

local AssistCoachInformationStarsView = class(unity.base, "AssistCoachInformationStarsView")

function AssistCoachInformationStarsView:ctor()
    self.stars = self.___ex.stars
    -- 须显示背板时设置
    self.activeStars = self.___ex.activeStars
end

function AssistCoachInformationStarsView:InitView(num)
    local capacity = table.nums(self.stars)
    local realNum = math.min(tonumber(num), capacity)
    -- 显示星背板（最高星级）+星级
	if self.activeStars then
		local maxNum = math.min(AssistantCoachModel.new().GetMaxQuality(),capacity)
    	realNum = math.min(tonumber(num), maxNum)
    	for i = 1, capacity do
    		GameObjectHelper.FastSetActive(self.stars[tostring(i)].gameObject, i <= maxNum)
        	GameObjectHelper.FastSetActive(self.activeStars[tostring(i)].gameObject, i <= realNum) 
   		end
   	-- 只显示星级
	else
    	for i = 1, capacity do
        	GameObjectHelper.FastSetActive(self.stars[tostring(i)].gameObject, i <= realNum)
   		end
   	end
end

return AssistCoachInformationStarsView
