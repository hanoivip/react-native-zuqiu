local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local MusicManager = require("ui.control.manager.MusicManager")
local AudioManager = require("unity.audio")

local LeagueBgmPlayer = {}

function LeagueBgmPlayer.StartPlayBgm()
    local leagueBgm = AudioManager.GetPlayer("music")
    leagueBgm.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/League/LeagueBgm.wav", 0.4)
    leagueBgm.loop = true
end

function LeagueBgmPlayer.StopPlayBgm()
    MusicManager.stop()
    MusicManager.play()
end

return LeagueBgmPlayer