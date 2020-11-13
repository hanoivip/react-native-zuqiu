local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local HomeMainTheme = {}

--[[
本脚本定义了套装带来的主界面颜色的改变，即主界面主题
在未装配任何套装的情况下默认主题Classic
配置中详细参数意义，见Classic中注释

名词：
    绕球场左、中、右的银灰色边框，简称边框
    球场上方显示特殊套装信息的，简称对战板
    界面上方资源区域背景，简称资源区
    左右两侧菜单区域，简称菜单
    球场中间半透明的套装logo，简称球场logo

配置可更改
    1、边框颜色
    2、资源区配色
    3、对战板配色及内容
    4、球场logo
    5、左右两侧菜单配色

引用
    HomeMain.lua
    HomeInfoBar.lua
    HomeMenuBar.lua
]]

HomeMainTheme.Default_Skin_Key = "Classic"

-- 默认
HomeMainTheme.Classic = {
    changeColor = Color(1, 1, 1), -- 边框的颜色
    currencyBgColor = Color(1, 1, 1), -- 资源区背景颜色
    menuPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Side_Bar.png", -- 菜单网格图片资源
    titlePath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/TitleBar1.png", -- 对战板背景图片资源
    topBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Stand_Top.png", -- 上边框资源
    sideBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Stand_Side.png", -- 左右边框图片资源
    isShowLogo = false, -- 是否显示球场logo
    logoSignPath = "", -- 球场logo的路径
    isShowTitleSign = false, -- 是否显示对战板中内容
    titleSignPath = "", -- 对战板内容路径
    isShowRibbon = false, -- 是否显示上边框特殊配色
    ribbonPath = "", -- 上边框资源路径
    isShowSign = false, -- 是否显示资源区右上角的logo
    signPath = "" -- 资源区右上角logo路径
}

-- 拜仁套装
HomeMainTheme.Bayern = {
    changeColor = Color(255 / 255, 15 / 255, 42 / 255),
    currencyBgColor = Color(255 / 255, 15 / 255, 42 / 255),
    menuPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Side_Bar2.png",
    titlePath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/TitleBar2.png",
    topBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Stand_Top.png",
    sideBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Stand_Side.png",
    isShowLogo = true,
    logoSignPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/BayernLogo.png",
    isShowTitleSign = true,
    titleSignPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Skin/BayernSkinTitle.prefab",
    isShowRibbon = true,
    ribbonPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Skin/BayernSkinRibbon.prefab",
    isShowSign = true,
    signPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/BayernSign.png"
}

-- 皇马套装
HomeMainTheme.RealMadrid = {
    changeColor = Color(1, 1, 1),
    currencyBgColor = Color(1, 1, 1),
    menuPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Side_Bar3.png",
    titlePath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/TitleBar3.png",
    topBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Special_Top.png",
    sideBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Special_Side.png",
    isShowLogo = true,
    logoSignPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/RealMadridLogo.png",
    isShowTitleSign = true,
    titleSignPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Skin/RealMadridSkinTitle.prefab",
    isShowRibbon = true,
    ribbonPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Skin/RealMadridSkinRibbon.prefab",
    isShowSign = true,
    signPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/RealMadraidSign.png"
}

-- 巴萨套装
HomeMainTheme.Barcelona = {
    changeColor = Color(52 / 255, 101 / 255, 201 / 255),
    currencyBgColor = Color(160 / 255, 17 / 255, 61 / 255),
    menuPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Side_Barcelona.png",
    titlePath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/TitleBar_Barcelona.png",
    topBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Special_Top.png",
    sideBarPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Special_Side.png",
    isShowLogo = true,
    logoSignPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Images/Logo_Barcelona.png",
    isShowTitleSign = true,
    titleSignPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Skin/BarcelonaSkinTitle.prefab",
    isShowRibbon = true,
    ribbonPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Skin/BarcelonaSkinRibbon.prefab",
    isShowSign = true,
    signPath = "Assets/CapstonesRes/Game/UI/Scene/Home/Res/Sign_Barcelona.png"
}

return HomeMainTheme
