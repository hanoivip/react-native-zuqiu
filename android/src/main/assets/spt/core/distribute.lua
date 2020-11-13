local distribute = {}

local ResManager = clr.Capstones.UnityFramework.ResManager

local distributeFlags = clr.table(ResManager.GetDistributeFlags())

for i, v in ipairs(distributeFlags) do
    xpcall(function() require('distribute.'..v) end, function(err) dump(err) end)
end

return distribute