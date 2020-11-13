if jit and jit.os == "OSX" and (jit.arch == "arm" or jit.arch == "arm64") then
    jit = nil
elseif jit then
    jit.off()
    jit.flush()
    jit=nil
end

require('clrstruct.init')
require('libs.init')
require('core.distribute')
require('core.init')
require('unity.init')
require('config')
require('coregame.Reflection')
luaevt.trig('___EVENT__POST_CONFIG')