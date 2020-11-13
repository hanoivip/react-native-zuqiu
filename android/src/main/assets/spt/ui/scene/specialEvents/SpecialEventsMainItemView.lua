local SpecialEventsMainItemView = class(unity.base)

function SpecialEventsMainItemView:ctor()
    self.chineseTitle = self.___ex.chineseTitle
    self.englishTitle = self.___ex.englishTitle
    self.target = self.___ex.target
    self.open = self.___ex.open
    self.closed = self.___ex.closed
    self.pending = self.___ex.pending
    self.pendingTime = self.___ex.pendingTime
    self.flagEnable1Image = self.___ex.flagEnable1Image
    self.flagEnableSkill = self.___ex.flagEnableSkill
    self.flagEnableSkillImage = self.___ex.flagEnableSkillImage
    self.flagEnable = self.___ex.flagEnable
    self.flagEnable2Image = self.___ex.flagEnable2Image
    self.flagDisable = self.___ex.flagDisable
    self.flagDisable1Image = self.___ex.flagDisable1Image
    self.flagDisableSkill = self.___ex.flagDisableSkill
    self.flagDisableSkillImage = self.___ex.flagDisableSkillImage
    self.flagDisable2Image = self.___ex.flagDisable2Image
    self.flagSkillEfffect = self.___ex.flagSkillEfffect
    self.downGlow = self.___ex.downGlow
    self.redPoint = self.___ex.redPoint
    self.itemButton = self.___ex.itemButton
end

function SpecialEventsMainItemView:InitView(model, timeString)
    self.model = model

    self.chineseTitle.text = model.title
    self.englishTitle.text = model.titleEnglish
    self.target.text = model.desc

    local spriteId = model.isSkill and "Skill" or tostring(model.id)

    local sprite1 =
        res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/Image/Main/Flag" .. spriteId .. "_1.png")
    local sprite2 =
        res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/Image/Main/Flag" .. spriteId .. "_2.png")
    local spriteSkill =
        model.isSkill and
        res.LoadRes(
            "Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/Image/Main/FlagSkill" .. tostring(model.id) .. "_3.png"
        ) or
        nil

    local enabled = (model.openStatus == "open")

    if enabled then
        self.flagEnable:SetActive(true)
        self.flagEnable1Image.overrideSprite = sprite1
        self.flagEnable2Image.overrideSprite = sprite2
        self.flagDisable:SetActive(false)

        if model.isSkill then
            self.flagEnableSkill:SetActive(true)
            self.flagSkillEfffect:SetActive(true)
            self.flagEnableSkillImage.overrideSprite = spriteSkill
        else
            self.flagEnableSkill:SetActive(false)
            self.flagSkillEfffect:SetActive(false)
        end

        local downGlowChildName = "DownGlow" .. spriteId
        for i = 0, self.downGlow.childCount - 1 do
            local child = self.downGlow:GetChild(i)
            child.gameObject:SetActive(child.gameObject.name == downGlowChildName)
        end
    else
        self.flagEnable:SetActive(false)
        self.flagDisable1Image.overrideSprite = sprite1
        self.flagDisable2Image.overrideSprite = sprite2
        self.flagDisable:SetActive(true)

        if model.isSkill then
            self.flagDisableSkill:SetActive(true)
            self.flagDisableSkillImage.overrideSprite = spriteSkill
        else
            self.flagDisableSkill:SetActive(false)
        end
    end

    if model.openStatus == "open" then
        self.open:SetActive(true)
        self.pending:SetActive(false)
        self.closed:SetActive(false)
    elseif model.openStatus == "mask" then
        self.open:SetActive(false)
        self.pending:SetActive(true)
        self.closed:SetActive(false)
        self.pendingTime.text = timeString
    else
        self.open:SetActive(false)
        self.pending:SetActive(false)
        self.closed:SetActive(true)
    end

    self.redPoint:SetActive(model.showRedPoint)
end

return SpecialEventsMainItemView
