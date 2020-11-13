local CommonConstants = require("ui.common.CommonConstants")

local UIBgmManager = class(audio)

function UIBgmManager.play(snd, volume, loop, onComplete)
    if volume == nil then
        volume = CommonConstants.UIBgmVolume
    end
    if loop == nil then
        loop = false
    end
    audio.GetPlayer('uiBgm').PlayAudio('Assets/CapstonesRes/Game/Audio/UI/'..tostring(snd)..'.wav', volume, onComplete)
    audio.GetPlayer('uiBgm').loop = loop
end

function UIBgmManager.stop()
    audio.GetPlayer('uiBgm').Stop()
end

return UIBgmManager