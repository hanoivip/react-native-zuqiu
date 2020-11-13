local GuideConstants = {}

-- 是否开启引导
GuideConstants.isOpenGuide = true

-- ios提审屏蔽新手引导
if luaevt.trig("___EVENT__NOT_OPEN_FORBIDDEN") then
    GuideConstants.isOpenGuide = false
end

return GuideConstants