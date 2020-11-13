local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease

local MusicManager = class(unity.base)
table.merge(MusicManager, audio)

local playlist = {}
local playinglist = nil
local playingIndex = nil

function MusicManager:start()
    local managerName = self.___ex.musicManagerGroup or 'BGM'
    if MusicManager.managerName ~= managerName then
        MusicManager.managerName = managerName
        math.randomseed(os.time())
        playlist = {}
        if type(self.___ex.music) == 'table' then
            for k, v in pairs(self.___ex.music) do
                playlist[#playlist + 1] = v
            end
        end
        MusicManager.stop()
        MusicManager.play()
    else
        playlist = {}
        local newmap = {}
        if type(self.___ex.music) == 'table' then
            for k, v in pairs(self.___ex.music) do
                playlist[#playlist + 1] = v
                newmap[v] = true
            end
        end

        local oldplayinglist = playinglist
        playinglist = {}
        if type(oldplayinglist) == 'table' then
            for i, v in ipairs(oldplayinglist) do
                if newmap[v] then
                    playinglist[#playinglist + 1] = v
                end
            end
        end
    end
end

function MusicManager.play(volume)
    if not playinglist or not next(playinglist) then
        playinglist = clone(playlist)
    end

    local keys = table.keys(playinglist)
    if playingIndex == nil then
        playingIndex = math.random(#keys)
    end
    local key = keys[playingIndex]
    local value = playinglist[key]
    if key then
        playinglist[key] = nil
    end
    if volume == nil then
        volume = 0.4
    end
    if value then
        local player = audio.GetPlayer('music')
        player.PlayAudio(value, volume)
        player.loop = true
    end
end

function MusicManager.fadeVolume(volume)
    local isOpen = cache.getLocalData("keySettingsMusicOpen") or 1
    if isOpen == 1 then
        local player = audio.GetPlayer('music')
        local fadeOutTweener = ShortcutExtensions.DOFade(player, player.volume * volume, 3)
    end
end

function MusicManager.stop()
    local player = audio.GetPlayer('music')
    player.Stop()  --Lua assist checked flag
    playinglist = nil
    playingIndex = nil
end

function MusicManager.destroy()
    local player = audio.GetPlayer('music')
    if player and player ~= clr.null then
        Object.Destroy(player.gameObject)
    end
    playinglist = nil
end

return MusicManager
