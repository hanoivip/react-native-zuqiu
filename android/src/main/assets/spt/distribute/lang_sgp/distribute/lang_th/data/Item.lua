local var = {} 

local Mt = { } 
Mt.__add = function(t1, t2) 
   for key, data in pairs(t2) do
      t1[key] = data
   end 
   return t1 
end 

local splitTable = {  
setmetatable(require('distribute.lang_th.data.Item.parts.part1_41155'), Mt),
setmetatable(require('distribute.lang_th.data.Item.parts.part41156_50025'), Mt),
setmetatable(require('distribute.lang_th.data.Item.parts.part50026_50191'), Mt),
} 

for i, v in ipairs(splitTable) do 
   var = var + v 
end 

return var