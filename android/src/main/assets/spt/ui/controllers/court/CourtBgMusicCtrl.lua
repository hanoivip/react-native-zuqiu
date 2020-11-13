local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local MusicManager = require("ui.control.manager.MusicManager")
local AudioManager = require("unity.audio")

local CourtBgMusicCtrl = {}

function CourtBgMusicCtrl.StartPlayBgm()
    local courtBgm = AudioManager.GetPlayer("music")
    local index = math.random(1, 2)
    courtBgm.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/Court/Court_City" .. tostring(index) .. ".mp3", 0.5)
    courtBgm.loop = true
end

function CourtBgMusicCtrl.StopPlayBgm()
    AudioManager.GetPlayer("music").Stop()
    MusicManager.stop()
    MusicManager.play()
end

return CourtBgMusicCtrl