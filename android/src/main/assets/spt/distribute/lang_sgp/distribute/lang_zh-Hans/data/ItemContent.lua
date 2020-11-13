local var = {} 

local Mt = { } 
Mt.__add = function(t1, t2) 
   for key, data in pairs(t2) do
      t1[key] = data
   end 
   return t1 
end 

local splitTable = {  
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part101_3002170'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3002171_3004241'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3004242_3006651'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3006652_3008688'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3008689_3010688'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3010689_3012695'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3012696_3014735'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3014736_3016737'), Mt),
setmetatable(require('distribute.lang_zh-Hans.data.ItemContent.parts.part3016738_3018537'), Mt),
} 

for i, v in ipairs(splitTable) do 
   var = var + v 
end 

return var