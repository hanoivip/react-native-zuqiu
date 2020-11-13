local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")

local PlayerLetterScrollItemView = class(unity.base)

function PlayerLetterScrollItemView:ctor()
    -- 标题
    self.title = self.___ex.title
    -- 描述
    self.info = self.___ex.info
    -- 球员头像
    self.avatarBox = self.___ex.avatarBox
    -- 完成进度
    self.progress = self.___ex.progress
    -- 进度条
    self.progressBar = self.___ex.progressBar
    -- 未读图标
    self.unreadIcon = self.___ex.unreadIcon
    -- 已读图标
    self.readIcon = self.___ex.readIcon
    -- 已回复图标
    self.doneIcon = self.___ex.doneIcon
    -- 内容框按钮
    self.contentBtn = self.___ex.contentBtn
    -- 球员信函model
    self.playerLetterItemModel = nil
    -- 信件ID
    self.letterID = nil
end

function PlayerLetterScrollItemView:InitView(playerLetterItemModel)
    self.playerLetterItemModel = playerLetterItemModel
    self.letterID = self.playerLetterItemModel:GetID()
    
    self:BuildView()
end

function PlayerLetterScrollItemView:start()
    self:BindAll()
    self:RegisterEvent()
end

function PlayerLetterScrollItemView:BindAll()
    self.contentBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.playerLetter.PlayerLetterDetailCtrl", self.letterID)
    end)
end

function PlayerLetterScrollItemView:RegisterEvent()
    EventSystem.AddEvent("PlayerLetter.RefreshLetterReadState", self, self.RefreshLetterReadState)
end

function PlayerLetterScrollItemView:RemoveEvent()
    EventSystem.RemoveEvent("PlayerLetter.RefreshLetterReadState", self, self.RefreshLetterReadState)
end

function PlayerLetterScrollItemView:BuildView()
    local staticData = self.playerLetterItemModel:GetStaticData()
    local conditionSum = self.playerLetterItemModel:GetConditionSum()
    local completedConditionSum = self.playerLetterItemModel:GetCompletedConditionSum()

    self.title.text = staticData.title
    self.info.text = staticData.desc
    self.progress.text = lang.trans("playerMail_completeness", completedConditionSum, conditionSum)
    self.progressBar.value = completedConditionSum / conditionSum

    if self.avatarBox.childCount > 0 then
        local playerAvatarBox = self.avatarBox:GetChild(0)
        local script = playerAvatarBox:GetComponent(clr.CapsUnityLuaBehav)
        script:InitView(staticData.contents.card[1].id)
        script:BuildPage()
    else
        local playerAvatarBox = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/PlayerAvatarBox.prefab")
        playerAvatarBox.transform:SetParent(self.avatarBox, false)
        local script = playerAvatarBox:GetComponent(clr.CapsUnityLuaBehav)
        script:InitView(staticData.contents.card[1].id)
    end

    self:BuildStateIcon()
end

--- 构建信件的状态图标
function PlayerLetterScrollItemView:BuildStateIcon()
    local readState = self.playerLetterItemModel:GetReadState()
    local state = self.playerLetterItemModel:GetState()
    -- 信件未读
    if readState == PlayerLetterConstants.LetterReadState.UNREAD then
        self.unreadIcon:SetActive(true)
        self.readIcon:SetActive(false)
        self.doneIcon:SetActive(false)
    -- 信件已读
    elseif readState == PlayerLetterConstants.LetterReadState.READ then
        self.unreadIcon:SetActive(false)
        -- 已回复（领奖）
        if state == PlayerLetterConstants.LetterState.HAVE_AWARD then
            self.doneIcon:SetActive(true)
            self.readIcon:SetActive(false)
        else
            self.doneIcon:SetActive(false)
            self.readIcon:SetActive(true)
        end
    end
end

--- 刷新信件阅读状态
function PlayerLetterScrollItemView:RefreshLetterReadState(letterID)
    if self.letterID == letterID then
        self:BuildStateIcon()
    end
end

function PlayerLetterScrollItemView:onDestroy()
    self:RemoveEvent()
end

return PlayerLetterScrollItemView
