local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteGuessSchedule = require("ui.models.compete.guess.CompeteGuessSchedule")

local CompeteGuessMatchItemPlayerView = class(unity.base, "CompeteGuessMatchItemPlayerView")

function CompeteGuessMatchItemPlayerView:ctor()
    -- 争霸赛标识
    self.imgCompeteSign = self.___ex.imgCompeteSign
    -- 玩家名字
    self.txtName = self.___ex.txtName
    -- 正常背景
    self.imgFlagNormal = self.___ex.imgFlagNormal
    -- 获胜金色背景
    self.imgFlagWin = self.___ex.imgFlagWin
    -- 胜
    self.txtWin = self.___ex.txtWin
    -- 负
    self.txtLose = self.___ex.txtLose
    -- 球队Logo
    self.imgLogo = self.___ex.imgLogo
    -- 支持人数
    self.txtSupportNum = self.___ex.txtSupportNum
    -- 支持按钮
    self.btnSupport = self.___ex.btnSupport
    -- 支持
    self.txtSupport = self.___ex.txtSupport
    -- 已竞猜
    self.txtSupported = self.___ex.txtSupported
    self.txtMoney = self.___ex.txtMoney
end

function CompeteGuessMatchItemPlayerView:start()
end

function CompeteGuessMatchItemPlayerView:RegBtnEvent()
end

function CompeteGuessMatchItemPlayerView:InitView(playerData, cacheData, competeGuessModel)
    self.playerData = playerData
    self.data = cacheData
    self.competeGuessModel = competeGuessModel

    GameObjectHelper.FastSetActive(self.gameObject, true)

    -- 玩家信息
    self:InitPlayerInfo(playerData, cacheData)
end

function CompeteGuessMatchItemPlayerView:InitPlayerInfo(playerData, cacheData)
    -- 玩家名字
    self.txtName.text = playerData.name .. "  " .. playerData.serverName
    -- 争霸赛标识
    self:InitCompeteSign(self.imgCompeteSign, playerData.worldTournamentLevel)
    -- 球队Logo
    self:InitTeamLogo(self.imgLogo, playerData.logo)
    -- 已支持人数
    if playerData.guessCount >= 0 then
        GameObjectHelper.FastSetActive(self.txtSupportNum.gameObject, true)
        self.txtSupportNum.text = lang.trans("compete_guess_desc5", playerData.guessCount) -- 已支持人数
    else
        GameObjectHelper.FastSetActive(self.txtSupportNum.gameObject, false)
    end

    GameObjectHelper.FastSetActive(self.txtWin.gameObject, false)
    GameObjectHelper.FastSetActive(self.txtLose.gameObject, false)
    if cacheData.schedule == CompeteGuessSchedule.guessing then -- 可竞猜阶段
        if cacheData.myGuess then -- 参与过竞猜
            if cacheData.myGuess.guessPlayer == playerData.guessPlayer then -- 猜的是这个玩家
                -- 打开支持按钮
                GameObjectHelper.FastSetActive(self.btnSupport.gameObject, true)
                GameObjectHelper.FastSetActive(self.txtSupport.gameObject, false)
                GameObjectHelper.FastSetActive(self.txtSupported.gameObject, true)
                -- 显示竞猜档位
                local money = self.competeGuessModel:GetGuessMoney(cacheData.myGuess.guessStage)
                self.txtMoney.text = "X" .. string.formatNumWithUnit(money)
            else
                -- 关闭支持按钮
                GameObjectHelper.FastSetActive(self.btnSupport.gameObject, false)
            end
        else -- 未竞猜
            GameObjectHelper.FastSetActive(self.btnSupport.gameObject, true)
            GameObjectHelper.FastSetActive(self.txtSupport.gameObject, true)
            GameObjectHelper.FastSetActive(self.txtSupported.gameObject, false)
        end
        -- 显示正常背景
        GameObjectHelper.FastSetActive(self.imgFlagNormal.gameObject, true)
        GameObjectHelper.FastSetActive(self.imgFlagWin.gameObject, false)
    elseif cacheData.schedule == CompeteGuessSchedule.accounting then -- 比赛结算阶段
        if cacheData.myGuess then -- 参与过竞猜
            if cacheData.myGuess.guessPlayer == playerData.guessPlayer then -- 猜的是这个玩家
                -- 打开支持按钮
                GameObjectHelper.FastSetActive(self.btnSupport.gameObject, true)
                GameObjectHelper.FastSetActive(self.txtSupport.gameObject, false)
                GameObjectHelper.FastSetActive(self.txtSupported.gameObject, true)
                -- 显示竞猜档位
                local money = self.competeGuessModel:GetGuessMoney(cacheData.myGuess.guessStage)
                self.txtMoney.text = "X" .. string.formatNumWithUnit(money)
            else
                -- 关闭支持按钮
                GameObjectHelper.FastSetActive(self.btnSupport.gameObject, false)
            end
        else -- 未竞猜
            GameObjectHelper.FastSetActive(self.btnSupport.gameObject, false)
        end
        -- 显示正常背景
        GameObjectHelper.FastSetActive(self.imgFlagNormal.gameObject, true)
        GameObjectHelper.FastSetActive(self.imgFlagWin.gameObject, false)
    elseif cacheData.schedule == CompeteGuessSchedule.resulting then -- 比赛已经出结果
        -- 不管参没参与过都隐藏支持按钮
        GameObjectHelper.FastSetActive(self.btnSupport.gameObject, false)
        -- 显示获胜背景
        if cacheData.isMatchOver then
            if cacheData.winner == playerData.guessPlayer then
                GameObjectHelper.FastSetActive(self.imgFlagNormal.gameObject, false)
                GameObjectHelper.FastSetActive(self.imgFlagWin.gameObject, true)
                -- 获胜文字
                GameObjectHelper.FastSetActive(self.txtWin.gameObject, true)
                GameObjectHelper.FastSetActive(self.txtLose.gameObject, false)
            else
                GameObjectHelper.FastSetActive(self.imgFlagNormal.gameObject, true)
                GameObjectHelper.FastSetActive(self.imgFlagWin.gameObject, false)
                -- 失败文字
                GameObjectHelper.FastSetActive(self.txtWin.gameObject, false)
                GameObjectHelper.FastSetActive(self.txtLose.gameObject, true)
            end
        else -- 时间已过但服务器未出结果
            if cacheData.myGuess then -- 参与过竞猜
                if cacheData.myGuess.guessPlayer == playerData.guessPlayer then -- 猜的是这个玩家
                    -- 打开支持按钮
                    GameObjectHelper.FastSetActive(self.btnSupport.gameObject, true)
                    GameObjectHelper.FastSetActive(self.txtSupport.gameObject, false)
                    GameObjectHelper.FastSetActive(self.txtSupported.gameObject, true)
                    -- 显示竞猜档位
                    local money = self.competeGuessModel:GetGuessMoney(cacheData.myGuess.guessStage)
                    self.txtMoney.text = "X" .. string.formatNumWithUnit(money)
                end
            end
            -- 显示正常背景
            GameObjectHelper.FastSetActive(self.imgFlagNormal.gameObject, true)
            GameObjectHelper.FastSetActive(self.imgFlagWin.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.gameObject, false)
        dump("wrong schedule data!")
    end
end

-- 球队logo
function CompeteGuessMatchItemPlayerView:InitTeamLogo(logoRct, logoData)
    TeamLogoCtrl.BuildTeamLogo(logoRct, logoData)
end

-- 争霸赛标识
function CompeteGuessMatchItemPlayerView:InitCompeteSign(imgCompeteSign, competeSign)
    local hasCompeteSign = false
    if competeSign then
        local signData = CompeteSignConvert[tostring(competeSign)]
        if signData then
            imgCompeteSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signData.path .. ".png")
            hasCompeteSign = true
        end
    end
    GameObjectHelper.FastSetActive(imgCompeteSign.gameObject, hasCompeteSign)
end

return CompeteGuessMatchItemPlayerView
