local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local SupportTrainingReviewItemView = class(unity.base, "SupportTrainingReviewItemView")

function SupportTrainingReviewItemView:ctor()
--------Start_Auto_Generate--------
    self.bgImg = self.___ex.bgImg
    self.titleTxt = self.___ex.titleTxt
    self.progressTxt = self.___ex.progressTxt
--------End_Auto_Generate----------
end

function SupportTrainingReviewItemView:InitView(chapterData)
    local bgImgPath, progressStr
    if chapterData.isOpen then
        bgImgPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Supporter/Supporter_TrainBGOpen.png"
        progressStr = chapterData.chapter .. "-" .. chapterData.subId
        progressStr = lang.transstr("playerMail_nowProgress") .. ":" .. progressStr
        self.progressTxt.color = Color(1, 1, 1)
    else
        bgImgPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/Supporter/Supporter_TrainBGClose.png"
        progressStr = lang.transstr("playerMail_nowProgress") .. ":" .. lang.transstr("not_unlock")
        self.progressTxt.color = Color(0.52, 0.52, 0.52)
    end
    self.bgImg.overrideSprite = res.LoadRes(bgImgPath)
    self.titleTxt.text = lang.transstr("floor_order", chapterData.chapter) .. ":" .. chapterData.chapterName
    self.progressTxt.text = progressStr
end

return SupportTrainingReviewItemView
