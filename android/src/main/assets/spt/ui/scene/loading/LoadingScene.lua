local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions

local LoadingScene = class(unity.base)

local UnityEngine = clr.UnityEngine
local LightmapSettings = UnityEngine.LightmapSettings
local LightmapsMode = UnityEngine.LightmapsMode

function LoadingScene:ctor()
    res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Login/ClearDataView.prefab")

    self.txtTitle = self.___ex.txtTitle
    self.barProg = self.___ex.barProg
    self.txtProg = self.___ex.txtProg
    self.screenMask = self.___ex.screenMask

    LightmapSettings.lightmapsMode = LightmapsMode.NonDirectional
    clr.DG.Tweening.Core.DOTweenComponent.Create()
    luaevt.trig("___EVENT__SHOW_CHANGE_SERVER_BUTTON")
    local function JudgeHeroMatch()
        -- if cache.getNotFirstLoad() then
            luaevt.trig("BICheckPoint", "init_login", "4.7")
            res.ChangeScene("ui.controllers.login.LoginCtrl")
        -- else
        --     cache.setNotFirstLoad(true)
        --     local fadeTweener = ShortcutExtensions.DOFade(self.screenMask, 1, 1)
        --     TweenSettingsExtensions.OnComplete(fadeTweener, function ()  --Lua assist checked flag
        --         require("coregame.MatchLoader").startHeroMatch()
        --     end)
        -- end
    end
    self:coroutine(function()
        local hasNegativeVer
        luaevt.trig("SendBIReport", "update_start", "4")
        update.update(function(hasUpdated)
            unity.waitForNextEndOfFrame()
            if hasUpdated then
                if hasNegativeVer then
                    if ___CONFIG__IGNORE_UPDATE_RESTART then
                        ___CONFIG__IGNORE_UPDATE_RESTART = nil
                        if ___CONFIG__AFTER_ENTRY_SCENE then
                            res.LoadScene(___CONFIG__AFTER_ENTRY_SCENE)
                        else
                            JudgeHeroMatch()
                        end
                    else
                        ___CONFIG__IGNORE_UPDATE_RESTART = true
                        unity.restart()
                    end
                else
                    luaevt.trig("BICheckPoint", "hot_update_success", "4.6")
					luaevt.trig("SDK_Report", "update_done")
                    unity.restart()
                end
            else
                if ___CONFIG__AFTER_ENTRY_SCENE then
                    res.LoadScene(___CONFIG__AFTER_ENTRY_SCENE)
                else
                    JudgeHeroMatch()
                end
            end
        end, function(key, val, exinfo, ex2)
            if key == 'force_cold' then
                local title = "find_update"
                local msg = "find_update_msg"
                require("ui.control.manager.DialogManager").ShowAlertPopByLang(title, msg, function()
                    luaevt.trig('Force_Cold_Update')
                end)
            elseif key == 'cnt' then
                if ex2 then
                    self.quiet = true
                else
                    local waitHandle = { waiting = true }
                    local title = lang.transstr("find_hot_update")
                    local msg = ""
                    if tonumber(exinfo) > 0 then
                        msg = lang.transstr("find_hot_update_msg1", math.ceil(tonumber(exinfo)/1024/1024 * 100) / 100)
                    else
                        msg = lang.transstr("find_hot_update_msg2")
                    end

                    luaevt.trig("BICheckPoint", "hot_update_tip", "4.3")

                    require("ui.control.manager.DialogManager").ShowContinuePop(title, msg, function ()
                        waitHandle.waiting = nil
                        luaevt.trig("BICheckPoint", "hot_update_click", "4.4")
                    end)
                    return waitHandle
                end
            elseif key == 'error' then
                luaevt.trig("BICheckPoint", "hot_update_error", "4.5")

                if self.txtTitle then
                    self.txtTitle.gameObject:SetActive(true)
                    self.txtTitle.text = self.quiet and lang.transstr("starting") or lang.transstr("update_failed")
                end
                if self.txtProg then
                    self.txtProg.gameObject:SetActive(true)
                    self.txtProg.text = self.quiet and lang.transstr("starting") or tostring(val)
                end
            elseif key == 'ver' then
                if tonumber(val) < 0 then
                    hasNegativeVer = true
                end
                if self.txtTitle then
                    self.txtTitle.gameObject:SetActive(true)
                    self.txtTitle.text = self.quiet and lang.transstr("starting") or self.txtTitle.text..'，' .. lang.transstr("version") .. '：'..val
                end
            elseif key == 'key' then
                if self.txtTitle then
                    self.txtTitle.gameObject:SetActive(true)
                    self.txtTitle.text = self.quiet and lang.transstr("starting") or lang.transstr("find_update") .. '：'..val
                end
            elseif key == 'streamlength' then
                if self.txtProg then
                    self.txtProg.gameObject:SetActive(true)
                    self.txtProg.text = self.quiet and lang.transstr("starting") or lang.transstr("downloaded") .. '：'..math.floor(val / 1024)..'KB'
                end
                if self.barProg then
                    self.barProg.gameObject:SetActive(true)
                    self.barProg.maxValue = 1
                    local value = self.barProg.value
                    value = (value + 0.01) % 1
                    self.barProg.value = value
                end
            elseif key == 'percent' then
                if self.txtProg then
                    self.txtProg.gameObject:SetActive(true)
                    if val > 0.999999 then
                        self.txtProg.text = self.quiet and lang.transstr("starting") or lang.transstr("downloaded_prepare_unzip")
                    else
                        self.txtProg.text = self.quiet and lang.transstr("starting") or lang.transstr("progress") .. '：'..(math.floor(val * 100 * 10) / 10)..'%'
                    end
                end
                if self.barProg then
                    self.barProg.gameObject:SetActive(true)
                    self.barProg.maxValue = 1
                    self.barProg.value = val
                end
            elseif key == 'unzip' then
                if self.txtTitle then
                    self.txtTitle.gameObject:SetActive(true)
                    self.txtTitle.text = self.quiet and lang.transstr("starting") or lang.transstr("unziping")
                end
            elseif key == 'unzipprog' then
                if self.barProg then
                    self.barProg.gameObject:SetActive(true)
                    self.barProg.maxValue = 1
                    local value = self.barProg.value
                    value = (value + 0.01) % 1
                    self.barProg.value = value
                end
            elseif key == "loadingBg" then
                if type(val) == "string" and string.len(val) > 0 then
                    require("ui.controllers.login.LoginCtrl").___loadingBg = val
                end
            end
        end)
        luaevt.trig("SendBIReport", "update_end", "5")
    end)
end

return LoadingScene

