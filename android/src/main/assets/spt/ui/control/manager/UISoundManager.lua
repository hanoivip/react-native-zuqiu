local CommonConstants = require("ui.common.CommonConstants")

local UISoundManager = class(audio)

function UISoundManager.play(snd, volume, loop, onComplete)
    if volume == nil then
        volume = CommonConstants.UISoundVolume
    end
    if loop == nil then
        loop = false
    end
    audio.GetPlayer('ui').PlayAudio('Assets/CapstonesRes/Game/Audio/UI/'..tostring(snd)..'.wav', volume, onComplete)
    audio.GetPlayer('ui').loop = loop
end

function UISoundManager.stop()
    audio.GetPlayer('ui').Stop()
end

return UISoundManager