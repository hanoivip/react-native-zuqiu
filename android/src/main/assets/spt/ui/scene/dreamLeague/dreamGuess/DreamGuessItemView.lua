local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local DreamLeagueCardName = require("data.DreamLeagueCardName")

local DreamGuessItemView = class(unity.base)

function DreamGuessItemView:ctor()
    self.homeIcon = self.___ex.homeIcon
    self.awayIcon = self.___ex.awayIcon
    self.homeNameTxt = self.___ex.homeNameTxt
    self.awayNameTxt = self.___ex.awayNameTxt
    self.lookBtn = self.___ex.lookBtn
    self.notEndMVP = self.___ex.notEndMVP
    self.endMVP = self.___ex.endMVP
    self.mvpTxt = self.___ex.mvpTxt
    self.numTxt = self.___ex.numTxt
    self.selectBtn = self.___ex.selectBtn
    self.beginMatchTxt = self.___ex.beginMatchTxt
    self.enterButton = self.___ex.enterButton
    self.textGradient = self.___ex.textGradient
    self.selectPlayerTxt = self.___ex.selectPlayerTxt
    self.enterBtnTxt = self.___ex.enterBtnTxt
end

function DreamGuessItemView:start()
    self.lookBtn:regOnButtonClick(function ()
        DialogManager.ShowToast(lang.trans("dream_reward", self.roomData.gift))
    end)
end

function DreamGuessItemView:InitView(roomData)
    self.roomData = roomData
    self.homeIcon.overrideSprite = AssetFinder.GetNationIcon(roomData.homeTeamEn)
    self.awayIcon.overrideSprite = AssetFinder.GetNationIcon(roomData.awayTeamEn)

    self.homeNameTxt.text = roomData.homeTeam
    self.awayNameTxt.text = roomData.awayTeam

    GameObjectHelper.FastSetActive(self.notEndMVP, roomData.resultState ~= 1)
    GameObjectHelper.FastSetActive(self.endMVP, roomData.resultState == 1)

    self.mvpTxt.text = roomData.cardName and DreamLeagueCardName[roomData.cardName].name or ""
    self.numTxt.text = tostring(roomData.guessNum) or tostring(0)
    self.beginMatchTxt.text = string.formatTimestampNoYear(roomData.matchTime) .. "-" .. roomData.tabName

    self:InitSelectPanel()
end

-- guessStatus = true未截止; = false已截止
-- resultState = 0未结束; =1已结束
function DreamGuessItemView:InitSelectPanel()
    -- 按钮
    self.enterButton.interactable = self.roomData.guessStatus and not self.roomData.guessCardName -- 未截止且没有选
    self.textGradient.enabled = self.roomData.guessStatus and not self.roomData.guessCardName
    -- 按钮文本
    if self.roomData.guessStatus and self.roomData.resultState == 0 then
        if self.roomData.guessCardName then
            self.enterBtnTxt.text = lang.trans("skillList_selectNum") -- 已选择
        else
            self.enterBtnTxt.text = lang.trans("untranslated_2601") -- 选择
        end
    elseif not self.roomData.guessStatus and self.roomData.resultState == 0 then
        self.enterBtnTxt.text = lang.trans("dream_is_time_over") -- 已截止
    elseif not self.roomData.guessStatus and self.roomData.resultState == 1 then
        self.enterBtnTxt.text = lang.trans("belatedGift_item_nil_time") -- 已结束
    end
    -- 选择文本
    self.selectPlayerTxt.text = self.roomData.guessCardName and lang.trans("dream_my_choose", DreamLeagueCardName[self.roomData.guessCardName].name) or lang.trans("dream_my_choose_no")
end

return DreamGuessItemView
