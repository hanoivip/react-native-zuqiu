local UnityEngine = clr.UnityEngine
local Text = UnityEngine.UI.Text

local TacticsDlgHelper = class(unity.base)

local path = "Assets/CapstonesRes/Game/UI/Match/Formation2/TacticsDlg/HelperLine.prefab"

function TacticsDlgHelper:ctor()
    self.parentTrans = self.___ex.parentTrans
    self.titleTxt = self.___ex.titleTxt
end

function TacticsDlgHelper:InitData(helperType)
    -- 传球方式
    if helperType == "PassTactic" then
        self.titleTxt.text = lang.trans("tactics_passTactic")
        local title = lang.trans("tactics_title_1")
        local content = lang.trans("tactics_content_1")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_2")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_3")
        content = lang.trans("tactics_content_3")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_4")
        self:InitHelperLine(title, content)
    -- 进攻偏好
    elseif helperType == "AttackEmphasisDetail" then
        self.titleTxt.text = lang.trans("tactics_attackEmphasis")
        local title = lang.trans("tactics_title_4")
        local content = lang.trans("tactics_content_5")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_6")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_5")
        content = lang.trans("tactics_content_7")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_8")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_12")
        content = lang.trans("tactics_content_21")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_13")
        content = lang.trans("tactics_content_22")
        self:InitHelperLine(title, content)

    -- 进攻节奏
    elseif helperType == "AttackRhythm" then
        self.titleTxt.text = lang.trans("tactics_attackRhythm")
        local title = lang.trans("tactics_title_6")
        local content = lang.trans("tactics_content_9")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_10")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_7")
        content = lang.trans("tactics_content_11")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_12")
        self:InitHelperLine(title, content)
    -- 进攻倾向
    elseif helperType == "AttackMentality" then
        self.titleTxt.text = lang.trans("tactics_attackMentality")
        local title = lang.trans("tactics_title_8")
        local content = lang.trans("tactics_content_13")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_14")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_9")
        content = lang.trans("tactics_content_15")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_16")
        self:InitHelperLine(title, content)
    -- 防守策略
    elseif helperType == "DefenseStrategy" then
        self.titleTxt.text = lang.trans("tactics_defenseStrategy")
        local title = lang.trans("tactics_title_10")
        local content = lang.trans("tactics_content_17")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_18")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_11")
        content = lang.trans("tactics_content_19")
        self:InitHelperLine(title, content)

        title = lang.trans("tactics_title_2")
        content = lang.trans("tactics_content_20")
        self:InitHelperLine(title, content)
    end
end

function TacticsDlgHelper:InitHelperLine(title, content)
    local helperLine = res.Instantiate(path)
    helperLine.transform:SetParent(self.parentTrans, false)
    local txtComponents = helperLine:GetComponentsInChildren(Text)
    txtComponents[0].text = title
    txtComponents[1].text = content
end

return TacticsDlgHelper
