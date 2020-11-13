local GameObjectHelper = require("ui.common.GameObjectHelper")
local Timer = require('ui.common.Timer')
local FancyGachaMainView = class(unity.base, "FancyGachaMainView")

function FancyGachaMainView:ctor()
--------Start_Auto_Generate--------
    self.rollManagerSpt = self.___ex.rollManagerSpt
    self.titelInfoTxt = self.___ex.titelInfoTxt
    self.countDownTxt = self.___ex.countDownTxt
    self.introduceTxt = self.___ex.introduceTxt
    self.leftSwitchBtn = self.___ex.leftSwitchBtn
    self.rightSwitchBtn = self.___ex.rightSwitchBtn
    self.contentsTrans = self.___ex.contentsTrans
    self.flageImg = self.___ex.flageImg
    self.teamIconImg = self.___ex.teamIconImg
    self.allCardsBtn = self.___ex.allCardsBtn
    self.storeBtn = self.___ex.storeBtn
    self.gachaOnceBtn = self.___ex.gachaOnceBtn
    self.gachaTenTimesBtn = self.___ex.gachaTenTimesBtn
    self.safeTipGo = self.___ex.safeTipGo
    self.labelGroupSpt = self.___ex.labelGroupSpt
    self.groupTagContentTrans = self.___ex.groupTagContentTrans
    self.otherLabelGo = self.___ex.otherLabelGo
    self.onlyOneTabBtn = self.___ex.onlyOneTabBtn
    self.infoBarDynSpt = self.___ex.infoBarDynSpt
--------End_Auto_Generate----------
end

function FancyGachaMainView:start()
    self:RegBtnEvent()
end

function FancyGachaMainView:InitView(fancyGachaModel)
    if not fancyGachaModel then return end
    self.model = fancyGachaModel
    self.gachaData = self.model:GetGachaData()
    self:InitTab()
end

function FancyGachaMainView:RegOnDynamicLoad(func)
    self.infoBarDynSpt:RegOnDynamicLoad(func)
end

-- 设置倒计时
function FancyGachaMainView:ResetTimer()
    if not self.curGachaGroup:GetRemainTime() then
        if self.residualTimer ~= nil then
            self.residualTimer:Destroy()
        end
        self.countDownTxt.text = ""
        return
    end
    if self.curGachaGroup:GetRemainTime() > 0 then
        self:RefreshTimer()
    else
        self:SetRunOutOfTimeView()
    end
end

function FancyGachaMainView:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.curGachaGroup:GetRemainTime()
    local timeTitleStr = lang.transstr("residual_time")
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            if self.SetRunOutOfTimeView then
                self:SetRunOutOfTimeView()
            end
            return
        else
            if self.countDownTxt then
                self.countDownTxt.text = timeTitleStr .. string.convertSecondToTime(time)
            end
        end
    end)
end

function FancyGachaMainView:SetRunOutOfTimeView()
    self.countDownTxt.text = lang.trans("visit_endInfo")
    if self.runOutOfTime then
        self.runOutOfTime()
    end
end

function FancyGachaMainView:RegBtnEvent()
    --打开卡库一览
    self.allCardsBtn:regOnButtonClick(function()
        if self.onClickBtnAllCards and type(self.onClickBtnAllCards) == "function" then
            self.onClickBtnAllCards()
        end
    end)
    --👈切换上一标签
    self.leftSwitchBtn:regOnButtonClick(function()
        local curGroup = self.model:GetCurGroup()
        if curGroup - 1 > 0 then
            self.labelGroupSpt:selectMenuItem(curGroup - 1)
            self:OnTabClick(curGroup - 1)
        end
    end)
    --👉切换下一标签
    self.rightSwitchBtn:regOnButtonClick(function()
        local curGroup = self.model:GetCurGroup()
        if curGroup + 1 <= self.tabNum then
            self.labelGroupSpt:selectMenuItem(curGroup + 1)
            self:OnTabClick(curGroup + 1)
        end
    end)
    --打开梦幻卡商城
    self.storeBtn:regOnButtonClick(function()
        if self.onClickBtnStore and type(self.onClickBtnStore) == "function" then
            self.onClickBtnStore()
        end
    end)
    --招募一次
    self.gachaOnceBtn:regOnButtonClick(function()
        if self.onClickBtnGachaOnce and type(self.onClickBtnGachaOnce) == "function" then
            self.onClickBtnGachaOnce()
        end
    end)
    --招募十次
    self.gachaTenTimesBtn:regOnButtonClick(function()
        if self.onClickBtnGachaTenTimes and type(self.onClickBtnGachaTenTimes) == "function" then
            self.onClickBtnGachaTenTimes()
        end
    end)
    self.onlyOneTabBtn:regOnButtonClick(function()
        if type(self.clickOnlyOneTab) == "function" then
            self.clickOnlyOneTab()
        end
    end)
end

function FancyGachaMainView:InitTab()
    self.tabList = {}
    if not self.labelGroupSpt.menu then
        self.labelGroupSpt.menu = {}
    end
    self.tabNum = #self.gachaData
    GameObjectHelper.FastSetActive(self.otherLabelGo, self.tabNum < 6)
    GameObjectHelper.FastSetActive(self.leftSwitchBtn.gameObject, self.tabNum > 1)
    GameObjectHelper.FastSetActive(self.rightSwitchBtn.gameObject, self.tabNum > 1)
    for i, v in pairs(self.gachaData) do
        if not self.labelGroupSpt.menu[i] then
            local obj, objSpt  = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyGacha/FancyGachaLabel.prefab")
            obj.transform:SetParent(self.groupTagContentTrans, false)
            self.tabList[i] = objSpt
            self.labelGroupSpt.menu[i] = objSpt
        end
        self.labelGroupSpt:BindMenuItem(i, function() self:OnTabClick(i) end)
        self.labelGroupSpt.menu[i]:InitView(v, i)
    end
    local defaultGroup = self.model:GetCurGroup()
    self.labelGroupSpt:selectMenuItem(defaultGroup)
    self:OnTabClick(defaultGroup, true)
    self:ShowOrHideOnlyOneTabBtn(self.tabNum == 1 and self.curGachaGroup:IsNew())
end

function FancyGachaMainView:OnTabClick(tag, init)
    self.curGachaGroup = self.gachaData[tag]
    if not init and self.curGachaGroup:IsNew() then
        if self.RequestRead then
            self.RequestRead(tag)
        end
    end
    self.model:SetCurGroup(tag)
    self:RefreshContentsView()
end

function FancyGachaMainView:RefreshContentsView()
    if not self.curGachaGroup then return end
    self.titelInfoTxt.text = self.curGachaGroup:GetName()
    self.introduceTxt.text = self.curGachaGroup:GetDes()
    self.flageImg.sprite = self.curGachaGroup:GetBoardPic()
    local teamIcon = self.curGachaGroup:GetBoardIcon()
    local safeTip = self.curGachaGroup:GetTenGachaSafeTip()
    GameObjectHelper.FastSetActive(self.teamIconImg.gameObject, teamIcon)
    GameObjectHelper.FastSetActive(self.safeTipGo, safeTip)
    if teamIcon then
        self.teamIconImg.sprite = teamIcon
    end
    local cardList = self.curGachaGroup:GetCardDisply()
    if self.initCards and type(self.initCards) == "function" then
        self.initCards(cardList)
    end
    self:ResetTimer()
end

function FancyGachaMainView:ShowOrHideOnlyOneTabBtn(isShow)
    GameObjectHelper.FastSetActive(self.onlyOneTabBtn.gameObject, isShow)
end


function FancyGachaMainView:onBeginDrag(eventData)
    self.rollManagerSpt:onBeginDrag(eventData)
end

function FancyGachaMainView:onDrag(eventData)
    self.rollManagerSpt:onDrag(eventData)
end

function FancyGachaMainView:onEndDrag(eventData)
    self.rollManagerSpt:onEndDrag(eventData)
end

function FancyGachaMainView:OnExitScene()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return FancyGachaMainView
