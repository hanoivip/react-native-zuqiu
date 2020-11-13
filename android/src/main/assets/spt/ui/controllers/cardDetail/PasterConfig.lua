local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local PasterImageModel = require("ui.models.cardDetail.PasterImageModel")
local PasterTextModel = require("ui.models.cardDetail.PasterTextModel")
local PasterConfig = {}

local PasterBytesPathHeader = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Bytes/"
local PasterImagePathHeader = "Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/"

function PasterConfig.SetGeneralConfig(pasterMap)
    local pasterImageModel = PasterImageModel.new("bg", PasterBytesPathHeader .. "Bg_General.png", PasterBytesPathHeader .. "Bg_Week.png", PasterBytesPathHeader .. "Bg_Month.png", PasterBytesPathHeader .. "Bg_Honor.png", PasterBytesPathHeader .. "Bg_Month.png", PasterBytesPathHeader .. "Bg_General.png")
    pasterMap["bg"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("infobar", PasterBytesPathHeader .. "Info_Board_General.png", PasterBytesPathHeader .. "Info_Board_Week.png", PasterBytesPathHeader .. "Info_Board_Month.png", PasterBytesPathHeader .. "Info_Board_Honor.png", PasterBytesPathHeader .. "Info_Board_Annual.png", PasterBytesPathHeader .. "Info_Board_General.png")
    pasterMap["infobar"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("priceBorder", PasterBytesPathHeader .. "Price_Board_General.png", PasterBytesPathHeader .. "Price_Board_Week.png", PasterBytesPathHeader .. "Price_Board_Month.png", PasterBytesPathHeader .. "Price_Board_Honor.png", PasterBytesPathHeader .. "Price_Board_Annual.png", PasterBytesPathHeader .. "Price_Board_General.png")
    pasterMap["priceBorder"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("courtBorder", PasterImagePathHeader .. "Court_Border_General.png", PasterImagePathHeader .. "Court_Border_Week.png", PasterImagePathHeader .. "Court_Border_Month.png", PasterImagePathHeader .. "Court_Border_Honor.png", PasterImagePathHeader .. "Court_Border_Annual.png", PasterImagePathHeader .. "Court_Border_General.png")
    pasterMap["courtBorder"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagBase", PasterImagePathHeader .. "Tag_General.png", PasterImagePathHeader .. "Tag_Week.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_Honor.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_General.png")
    pasterMap["tagBase"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagChemical", PasterImagePathHeader .. "Tag_General.png", PasterImagePathHeader .. "Tag_Week.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_Honor.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_General.png")
    pasterMap["tagChemical"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagTrain", PasterImagePathHeader .. "Tag_General.png", PasterImagePathHeader .. "Tag_Week.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_Honor.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_General.png")
    pasterMap["tagTrain"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagAscend", PasterImagePathHeader .. "Tag_General.png", PasterImagePathHeader .. "Tag_Week.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_Honor.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_General.png")
    pasterMap["tagAscend"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagMedal", PasterImagePathHeader .. "Tag_General.png", PasterImagePathHeader .. "Tag_Week.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_Honor.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_General.png")
    pasterMap["tagMedal"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagFeature", PasterImagePathHeader .. "Tag_General.png", PasterImagePathHeader .. "Tag_Week.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_Honor.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_General.png")
    pasterMap["tagFeature"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagMemory", PasterImagePathHeader .. "Tag_General.png", PasterImagePathHeader .. "Tag_Week.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_Honor.png", PasterImagePathHeader .. "Tag_Month.png", PasterImagePathHeader .. "Tag_General.png")
    pasterMap["tagMemory"] = pasterImageModel
    local pasterTextModel = PasterTextModel.new("text_name", Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1), Color(1, 1, 1, 1), Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1))
    pasterMap["text_name"] = pasterTextModel
    pasterTextModel = PasterTextModel.new("text_powerText", Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1), Color(1, 1, 1, 1), Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1))
    pasterMap["text_powerText"] = pasterTextModel
    pasterTextModel = PasterTextModel.new("text_posText", Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1), Color(1, 1, 1, 1), Color(0.196, 0.196, 0.196, 1), Color(0.196, 0.196, 0.196, 1))
    pasterMap["text_posText"] = pasterTextModel
    local pasterTextModel = PasterTextModel.new("text_shadow_name", Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5), Color(0, 0, 0, 0.5), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5))
    pasterMap["text_shadow_name"] = pasterTextModel
    pasterTextModel = PasterTextModel.new("text_shadow_powerText", Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5), Color(0, 0, 0, 0.5), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5))
    pasterMap["text_shadow_powerText"] = pasterTextModel
    pasterTextModel = PasterTextModel.new("text_shadow_posText", Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5), Color(0, 0, 0, 0.5), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0.5))
    pasterMap["text_shadow_posText"] = pasterTextModel
end

function PasterConfig.SetBasePageConfig(pasterMap)
    local pasterImageModel = PasterImageModel.new("bottom", PasterImagePathHeader .. "Border_General.png", PasterImagePathHeader .. "Border_Week.png", PasterImagePathHeader .. "Border_Month.png", PasterImagePathHeader .. "Border_Honor.png", PasterImagePathHeader .. "Border_Month.png", PasterImagePathHeader .. "Border_General.png")
    pasterMap["bottom"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomTitle", PasterBytesPathHeader .. "Titlebar_General.png", PasterBytesPathHeader .. "Titlebar_Week.png", PasterBytesPathHeader .. "Titlebar_Month.png", PasterBytesPathHeader .. "Titlebar_Honor.png", PasterBytesPathHeader .. "Titlebar_Annual.png", PasterBytesPathHeader .. "Titlebar_General.png")
    pasterMap["bottomTitle"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomTitleBar1", PasterImagePathHeader .. "Titlebar_Progress_General.png", PasterImagePathHeader .. "Titlebar_Progress_Week.png", PasterImagePathHeader .. "Titlebar_Progress_Month.png", PasterImagePathHeader .. "Titlebar_Progress_Honor.png", PasterImagePathHeader .. "Titlebar_Progress_Annual.png", PasterImagePathHeader .. "Titlebar_Progress_General.png")
    pasterMap["bottomTitleBar1"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomTitleBar2", PasterImagePathHeader .. "Titlebar_Progress_General.png", PasterImagePathHeader .. "Titlebar_Progress_Week.png", PasterImagePathHeader .. "Titlebar_Progress_Month.png", PasterImagePathHeader .. "Titlebar_Progress_Honor.png", PasterImagePathHeader .. "Titlebar_Progress_Annual.png", PasterImagePathHeader .. "Titlebar_Progress_General.png")
    pasterMap["bottomTitleBar2"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("infoArea", PasterBytesPathHeader .. "Info_Area_General.png", PasterBytesPathHeader .. "Info_Area_General.png", PasterBytesPathHeader .. "Info_Area_Month.png", PasterBytesPathHeader .. "Info_Area_Honor.png", PasterBytesPathHeader .. "Info_Area_Month.png", PasterBytesPathHeader .. "Info_Area_General.png")
    pasterMap["infoArea"] = pasterImageModel
end

function PasterConfig.SetChemicalPageConfig(pasterMap)
    local pasterImageModel = PasterImageModel.new("bottomChemical", PasterImagePathHeader .. "Border_General.png", PasterImagePathHeader .. "Border_Week.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_Honor.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_General.png")
    pasterMap["bottomChemical"] = pasterImageModel
end

function PasterConfig.SetTrainPageConfig(pasterMap)
    local pasterImageModel = PasterImageModel.new("bottomTrain", PasterImagePathHeader .. "Border_General.png", PasterImagePathHeader .. "Border_Week.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_Honor.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_General.png")
    pasterMap["bottomTrain"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("curveArea", PasterBytesPathHeader .. "Curve_Area_General.png", PasterBytesPathHeader .. "Curve_Area_General.png", PasterBytesPathHeader .. "Curve_Area_Month.png", PasterBytesPathHeader .. "Curve_Area_Honor.png", PasterBytesPathHeader .. "Curve_Area_Month.png", PasterBytesPathHeader .. "Curve_Area_General.png")
    pasterMap["curveArea"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagBar", PasterBytesPathHeader .. "TagBar_General.png", PasterBytesPathHeader .. "TagBar_General.png", PasterBytesPathHeader .. "TagBar_Month.png", PasterBytesPathHeader .. "TagBar_Honor.png", PasterBytesPathHeader .. "TagBar_Month.png", PasterBytesPathHeader .. "TagBar_General.png")
    pasterMap["tagBar"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("tagBorder", PasterImagePathHeader .. "Tag_Border_General.png", PasterImagePathHeader .. "Tag_Border_Week.png", PasterImagePathHeader .. "Tag_Border_Month.png", PasterImagePathHeader .. "Tag_Border_Honor.png", PasterImagePathHeader .. "Tag_Border_Month.png", PasterImagePathHeader .. "Tag_Border_General.png")
    pasterMap["tagBorder"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("trainInstruction", PasterImagePathHeader .. "TrainInstruction_General.png", PasterImagePathHeader .. "TrainInstruction_Week.png", PasterImagePathHeader .. "TrainInstruction_Month.png", PasterImagePathHeader .. "TrainInstruction_Honor.png", PasterImagePathHeader .. "TrainInstruction_Month.png", PasterImagePathHeader .. "TrainInstruction_General.png")
    pasterMap["trainInstruction"] = pasterImageModel
end

function PasterConfig.SetAscendPageConfig(pasterMap)
    local pasterImageModel = PasterImageModel.new("bottomAscend1", PasterImagePathHeader .. "Border_General.png", PasterImagePathHeader .. "Border_Week.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_Honor.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_General.png")
    pasterMap["bottomAscend1"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscend2", PasterImagePathHeader .. "Border_General.png", PasterImagePathHeader .. "Border_Week.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_Honor.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_General.png")
    pasterMap["bottomAscend2"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscend3", PasterImagePathHeader .. "Border_General.png", PasterImagePathHeader .. "Border_Week.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_Honor.png", PasterImagePathHeader .. "Border1_Month.png", PasterImagePathHeader .. "Border_General.png")
    pasterMap["bottomAscend3"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscendTitle", PasterBytesPathHeader .. "Titlebar_General.png", PasterBytesPathHeader .. "Titlebar_Week.png", PasterBytesPathHeader .. "Titlebar_Month.png", PasterBytesPathHeader .. "Titlebar_Honor.png", PasterBytesPathHeader .. "Titlebar_Annual.png", PasterBytesPathHeader .. "Titlebar_General.png")
    pasterMap["bottomAscendTitle"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscendTitleBar1", PasterImagePathHeader .. "Titlebar_Progress_General.png", PasterImagePathHeader .. "Titlebar_Progress_Week.png", PasterImagePathHeader .. "Titlebar_Progress_Month.png", PasterImagePathHeader .. "Titlebar_Progress_Honor.png", PasterImagePathHeader .. "Titlebar_Progress_Annual.png", PasterImagePathHeader .. "Titlebar_Progress_General.png")
    pasterMap["bottomAscendTitleBar1"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscendTitleBar2", PasterImagePathHeader .. "Titlebar_Progress_General.png", PasterImagePathHeader .. "Titlebar_Progress_Week.png", PasterImagePathHeader .. "Titlebar_Progress_Month.png", PasterImagePathHeader .. "Titlebar_Progress_Honor.png", PasterImagePathHeader .. "Titlebar_Progress_Annual.png", PasterImagePathHeader .. "Titlebar_Progress_General.png")
    pasterMap["bottomAscendTitleBar2"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscendTitle2", PasterBytesPathHeader .. "Titlebar_General.png", PasterBytesPathHeader .. "Titlebar_Week.png", PasterBytesPathHeader .. "Titlebar_Month.png", PasterBytesPathHeader .. "Titlebar_Honor.png", PasterBytesPathHeader .. "Titlebar_Annual.png", PasterBytesPathHeader .. "Titlebar_General.png")
    pasterMap["bottomAscendTitle2"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscendTitleBar3", PasterImagePathHeader .. "Titlebar_Progress_General.png", PasterImagePathHeader .. "Titlebar_Progress_Week.png", PasterImagePathHeader .. "Titlebar_Progress_Month.png", PasterImagePathHeader .. "Titlebar_Progress_Honor.png", PasterImagePathHeader .. "Titlebar_Progress_Annual.png", PasterImagePathHeader .. "Titlebar_Progress_General.png")
    pasterMap["bottomAscendTitleBar3"] = pasterImageModel
    pasterImageModel = PasterImageModel.new("bottomAscendTitleBar4", PasterImagePathHeader .. "Titlebar_Progress_General.png", PasterImagePathHeader .. "Titlebar_Progress_Week.png", PasterImagePathHeader .. "Titlebar_Progress_Month.png", PasterImagePathHeader .. "Titlebar_Progress_Honor.png", PasterImagePathHeader .. "Titlebar_Progress_Annual.png", PasterImagePathHeader .. "Titlebar_Progress_General.png")
    pasterMap["bottomAscendTitleBar4"] = pasterImageModel
end

return PasterConfig
