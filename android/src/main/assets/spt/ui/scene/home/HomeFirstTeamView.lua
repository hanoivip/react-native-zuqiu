local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Helper = require("ui.scene.formation.Helper")
local HomeFirstTeamView = class(unity.base)

function HomeFirstTeamView:ctor()
    self.startersArea = self.___ex.startersArea
    self.tactics = self.___ex.tactics
    self.tacticsNumber = self.___ex.tacticsNumber
    self.powerValue = self.___ex.powerValue
    self.posRatio = self.___ex.posRatio -- 自适应球场比值
    self.powerParent = self.___ex.powerParent
    self.cardsMap = {}
    self.adjustView = false
end

function HomeFirstTeamView:GetStartersRes()
    if not self.startersCardRes then 
        self.startersCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Home/Starters/StarterCard.prefab")
    end
    return self.startersCardRes
end

-- 新手引导 核心玩法在 切回主界面时canvas有一个调整过程
function HomeFirstTeamView:start()
    clr.coroutine(function()
        unity.waitForNextEndOfFrame()
        if not self.adjustView then 
            self.adjustView = true
            self.posRatioRect = self.posRatio.rect
            self.rootRect = self.transform.rect
        end
        while not self.cardList do
            coroutine.yield()
        end
        
        self:InitView(self.cardList, self.cardModelMap, self.teamsModel)
        -- 在屏幕做出自适应后
    end)
end

-- 新手引导会导致homecanvas在未调整就被收回
function HomeFirstTeamView:RefreshViewRect()
    self.posRatioRect = self.posRatio.rect
    self.rootRect = self.transform.rect
    self.adjustView = true
end

local ScreenWidth = 1334 -- @param ScreenWidth 16：9屏幕标准宽度
local ScreenHeight = 750 -- @param ScreenHeight 16：9屏幕标准高度
local ScaleRatio = 0.75 -- @param ScaleRatio 卡牌缩放系数
local AdaptHeight = 1000 -- @param normalizeRatio 4：3卡牌自适应比例系数
local StandardRatio = 1 -- @param StandardRatio 标准16：9卡牌自适应比例
local AdaptRatio = 1.2 -- @param AdaptRatio 4：3卡牌自适应比例
local Angle = 10-- @param Angle 球场倾斜角度系数
function HomeFirstTeamView:InitView(cardList, cardModelMap, teamsModel)
    self.cardList = cardList
    self.cardModelMap = cardModelMap
    self.teamsModel = teamsModel
    if self.adjustView then 
        local nowTeamId = teamsModel:GetNowTeamId()
        local formationId = teamsModel:GetFormationId(nowTeamId)
        local rect = self.posRatioRect or self.posRatio.rect
        local rootRect = self.rootRect or self.transform.rect
        local width = rect.width
        local height = rect.height

        local normalizeRatio, deltaRatio = self:GetAdaptionRatio(ScreenHeight, StandardRatio, AdaptHeight, AdaptRatio)
        local ScaleRatioValue = (rootRect.height * normalizeRatio + deltaRatio) * ScaleRatio

        for i, v in ipairs(cardList) do
            if not self.cardsMap[i] then 
                local cardRes = self:GetStartersRes()
                local card = Object.Instantiate(cardRes)
                card.transform:SetParent(self.startersArea.transform, false)
                local cardScript = card:GetComponent("CapsUnityLuaBehav")
                self.cardsMap[i] = cardScript
            end
            local cardScript = self.cardsMap[i]
            local posCoords = Helper.GetPos(v.pos, formationId, true)
            cardScript.transform.localPosition = Vector3(tonumber(posCoords.x) * width, tonumber(posCoords.y) * height, 0)
            cardScript.transform.localScale = Vector3(ScaleRatioValue, ScaleRatioValue, 1)
            local cardModel = cardModelMap[tostring(v.pcid)]
            cardScript:InitView(cardModel)
            cardScript.clickCard = function() self:OnBtnCard(v.pcid) end
        end
    end
end

-- 获取自适应屏幕系数（根据标准尺寸与目标尺寸计算差值）
function HomeFirstTeamView:GetAdaptionRatio(standardHeight, standardRatio, adaptHeight, adaptRatio)
    local normalizeRatio, deltaRatio
    normalizeRatio = (adaptRatio - standardRatio) / (adaptHeight - standardHeight)
    deltaRatio = standardRatio - standardHeight * normalizeRatio
    return normalizeRatio, deltaRatio
end

function HomeFirstTeamView:SetStartersInfo(power, formationName) 
    local word, number = string.splitWordAndNumber(formationName)
    self.tactics.text = word
    self.tacticsNumber.text = number
    self.powerValue.text = power
end

function HomeFirstTeamView:OnBtnCard(pcid) 
    if self.clickCard then 
        self.clickCard(pcid)
    end
end

return HomeFirstTeamView
