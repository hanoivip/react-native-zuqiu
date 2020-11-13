local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Image = UnityEngine.UI.Image
local Text = UnityEngine.UI.Text

local CardTrainingLevelView = class(unity.base)

function CardTrainingLevelView:ctor()
    self.imageDirPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Images/"
    self.normalImgPath = self.imageDirPath .. "General_N.png"
    self.normalImgHighPath = self.imageDirPath .. "General_H.png"
    self.normalImgIngPath = self.imageDirPath .. "General_I.png"

    -- 奇数最高等级使用的贴图
    self.bestImgOddPath = self.imageDirPath .. "LevelFive_N.png"
    self.bestImgHighOddPath = self.imageDirPath .. "LevelFIve_H.png"
    self.bestImgIngOddPath = self.imageDirPath .. "LevelFive_I.png"

    -- 偶数最高等级使用的贴图
    self.bestImgEvenPath = self.imageDirPath .. "LevelFive1_N.png"
    self.bestImgHighEvenPath = self.imageDirPath .. "LevelFive1_H.png"
    self.bestImgIngEvenPath = self.imageDirPath .. "LevelFive1_I.png"
end

function CardTrainingLevelView:start()
end

function CardTrainingLevelView:InitView(subId, isOdd)
    self:InitContent(subId, isOdd)
end

function CardTrainingLevelView:InitContent(subId, isOdd)
    local isIng = subId
    -- 是否是奇数
    local isOdd = isOdd

    self.txtList = clr.table(self:GetComponentsInChildren(Text))  --Lua assist checked flag
    self.imgList = clr.table(self:GetComponentsInChildren(Image))  --Lua assist checked flag

    for i = 1, #self.txtList do
        self.txtList[i].text = "<color=#d7bf7d>" .. i .. "</color>"
    end

    -- 均已完成
    if isIng == 6 then
        for i = 1, #self.imgList do
            if i ~= 5 then
                self.imgList[i].overrideSprite = res.LoadRes(self.normalImgHighPath)
                self.txtList[i].text = "<color=#51421f>" .. i .. "</color>"
            else
                if isOdd then
                    self.imgList[i].overrideSprite = res.LoadRes(self.bestImgHighOddPath)
                    self.txtList[i].text = "<color=#51421f>" .. i .. "</color>"
                else
                    self.imgList[i].overrideSprite = res.LoadRes(self.bestImgHighEvenPath)
                    self.txtList[i].text = "<color=#51421f>" .. i .. "</color>"
                end
            end
        end
    else
        for i = 1, #self.imgList do
            if i < isIng then
                self.imgList[i].overrideSprite = res.LoadRes(self.normalImgHighPath)
                self.txtList[i].text = "<color=#51421f>" .. i .. "</color>"
            elseif i == isIng and i ~= 5 then
                self.imgList[i].overrideSprite = res.LoadRes(self.normalImgIngPath)
            elseif i == isIng and i == 5 then
                if isOdd then
                    self.imgList[i].overrideSprite = res.LoadRes(self.bestImgIngOddPath)
                else
                    self.imgList[i].overrideSprite = res.LoadRes(self.bestImgIngEvenPath)
                end
            elseif i > isIng then
                if i ~= 5 then
                    self.imgList[i].overrideSprite = res.LoadRes(self.normalImgPath)
                else
                    if isOdd then
                        self.imgList[i].overrideSprite = res.LoadRes(self.bestImgOddPath)
                    else
                        self.imgList[i].overrideSprite = res.LoadRes(self.bestImgEvenPath)
                    end
                end
            end
        end
    end
end

return CardTrainingLevelView

