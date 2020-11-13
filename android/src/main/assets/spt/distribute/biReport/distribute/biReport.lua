local biReport = {}

luaevt.reg("Have_BI_Report", function()
    return true
end)

-- 海外版不需要胡来报送
local function BICheckPoint(cate, step, seq, extra)
    -- dump("<color=red>seq : " .. tostring(seq) .. ", step : " .. tostring(step) .. "</color>")
    -- clr.coroutine(function()
    --     local done = false
    --     local resp = req.biStartup(step, seq, extra, nil, nil, true)
    --     while not done do
    --         if api.success(resp) or resp.failed ~= "network" then
    --             done = true
    --         else
    --             resp = resp:repost()
    --         end
    --     end
    -- end)    
end

luaevt.reg("SendBIReport", function(cate, step, seq)
    -- 后增BI的sequence都为小数，且这些BI都不向胡来报送
    local hasPoint = string.find(seq, ".", 1, true) and true or false
    if not hasPoint and tonumber(seq) > 1 and tonumber(seq) < 14 then
        -- dump("<color=green>seq : " .. tostring(seq) .. ", step : " .. tostring(step) .. "</color>")
        luaevt.trig("SDK_CustomPushUserOp", step, seq)
    end

    BICheckPoint(cate, step, seq)
end)

luaevt.reg("BICheckPoint", BICheckPoint)

return biReport